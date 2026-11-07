//! Geographic features drawn with rough ink: areas, routes, and points.

use skribble_leptoskit::Theme;
use skribble_leptoskit::Tone;
use skribble_rough::DrawConfig;
use skribble_rough::DrawOptions;
use skribble_rough::FillOptions;
use skribble_rough::FillStyle;
use skribble_rough::Filler;
use skribble_rough::Generator;
use skribble_rough::Point;
use skribble_rough::RoughSvgPaths;

use crate::camera::Camera;
use crate::camera::LatLng;
use crate::paint::MapDrawing;

/// One geographic feature painted over the map.
///
/// A feature is data, not a widget: the map projects its points with the
/// camera it is given, so the same feature draws correctly at every zoom and
/// on every platform. Features outside the viewport are left out.
///
/// ```
/// use skribble_leptoskit_maps::LatLng;
/// use skribble_leptoskit_maps::MapFeature;
///
/// let park = MapFeature::area(vec![
/// 	LatLng::new(51.505, -0.09),
/// 	LatLng::new(51.505, -0.08),
/// 	LatLng::new(51.5, -0.075),
/// ]);
/// let walk = MapFeature::route(vec![LatLng::new(51.5, -0.1), LatLng::new(51.51, -0.09)]);
/// let stop = MapFeature::point(LatLng::new(51.51, -0.1));
/// assert_eq!([park, walk, stop].len(), 3);
/// ```
#[derive(Debug, Clone, PartialEq)]
pub enum MapFeature {
	/// A closed area, drawn with a rough outline and a light hachure fill.
	Area {
		/// The ring of geographic points that closes the area.
		ring: Vec<LatLng>,
		/// The hachure colour. Defaults to the theme's accent.
		tone: Option<Tone>,
	},
	/// A route through ordered points, drawn as a round-capped line with a
	/// slight wobble.
	Route {
		/// The geographic points the route passes through, in order.
		points: Vec<LatLng>,
		/// The line colour. Defaults to the theme's ink.
		tone: Option<Tone>,
	},
	/// A small hand-drawn dot at one coordinate, for places that need no pin.
	Point {
		/// Where the dot sits.
		position: LatLng,
		/// The dot's fill colour. Defaults to the theme's accent.
		tone: Option<Tone>,
	},
}

impl MapFeature {
	/// A closed area with a hachure fill in the theme's accent.
	#[must_use]
	pub fn area(ring: impl Into<Vec<LatLng>>) -> Self {
		Self::Area {
			ring: ring.into(),
			tone: None,
		}
	}

	/// A route in the theme's ink.
	#[must_use]
	pub fn route(points: impl Into<Vec<LatLng>>) -> Self {
		Self::Route {
			points: points.into(),
			tone: None,
		}
	}

	/// A small dot filled with the theme's accent.
	#[must_use]
	pub fn point(position: LatLng) -> Self {
		Self::Point {
			position,
			tone: None,
		}
	}

	/// The feature's colour, when it names one.
	#[must_use]
	pub fn tone(&self) -> Option<Tone> {
		match self {
			Self::Area { tone, .. } | Self::Route { tone, .. } | Self::Point { tone, .. } => *tone,
		}
	}

	/// The same feature in `tone`.
	#[must_use]
	pub fn with_tone(mut self, tone: Tone) -> Self {
		match &mut self {
			Self::Area { tone: named, .. }
			| Self::Route { tone: named, .. }
			| Self::Point { tone: named, .. } => *named = Some(tone),
		}
		self
	}

	/// Every coordinate the feature is drawn through.
	#[must_use]
	pub fn points(&self) -> Vec<LatLng> {
		match self {
			Self::Area { ring, .. } => ring.clone(),
			Self::Route { points, .. } => points.clone(),
			Self::Point { position, .. } => vec![*position],
		}
	}
}

/// Draws every visible feature into one coordinate space the size of the map.
pub(crate) fn drawing(
	camera: Camera,
	width: f32,
	height: f32,
	features: &[MapFeature],
	theme: Theme,
	seed: i64,
) -> MapDrawing {
	let mut drawing = MapDrawing::new(f64::from(width), f64::from(height));
	for (index, feature) in features.iter().enumerate() {
		let feature_seed = seed.wrapping_add(index as i64);
		match feature {
			MapFeature::Area { ring, tone } => {
				let points = project_all(&camera, ring, width, height);
				if points.len() < 3 || !visible(&points, width, height) || !has_area(&points) {
					continue;
				}
				let mut generator = generator(feature_seed, theme, FillStyle::Hachure);
				let paths = RoughSvgPaths::from_drawable(&generator.polygon(&points));
				drawing.push_stroke(
					paths.sketch,
					tone.unwrap_or(theme.accent()),
					sketch_weight(theme),
				);
				drawing.push_stroke(paths.outline, theme.ink(), theme.stroke_width);
			}
			MapFeature::Route {
				points: route,
				tone,
			} => {
				let points = project_all(&camera, route, width, height);
				if points.len() < 2 || !visible(&points, width, height) {
					continue;
				}
				let mut generator = generator(feature_seed, theme, FillStyle::None);
				let paths = RoughSvgPaths::from_drawable(&generator.linear_path(&points, false));
				drawing.push_stroke(
					paths.outline,
					tone.unwrap_or(theme.ink()),
					(theme.stroke_width + 1.0).max(2.0),
				);
			}
			MapFeature::Point { position, tone } => {
				let (x, y) = camera.project(*position, width, height);
				let point = Point::new(f64::from(x), f64::from(y));
				if !visible(&[point], width, height) {
					continue;
				}
				let mut generator = generator(feature_seed, theme, FillStyle::Solid);
				let paths =
					RoughSvgPaths::from_drawable(&generator.ellipse(point.x, point.y, 10.0, 10.0));
				drawing.push_fill(paths.solid, tone.unwrap_or(theme.accent()));
				drawing.push_stroke(paths.outline, theme.ink(), theme.stroke_width);
			}
		}
	}
	drawing
}

/// A generator with the map's restrained wobble.
fn generator(seed: i64, theme: Theme, fill: FillStyle) -> Generator {
	let options = DrawOptions {
		seed,
		roughness: theme.roughness.min(1.25),
		max_randomness_offset: 1.0,
		line_wobble: 0.35,
		..DrawOptions::default()
	};
	let pattern = FillOptions {
		hachure_gap: 9.0,
		hachure_angle: 320.0,
		fill_weight: 0.8,
		..FillOptions::default()
	};
	Generator::new(
		DrawConfig::new(options),
		Filler::new(fill, pattern, DrawConfig::new(options)),
	)
}

/// Hachure lines are lighter than outlines.
fn sketch_weight(theme: Theme) -> f32 {
	(theme.stroke_width * 0.55).max(0.8)
}

/// Projects a run of coordinates, unwrapping each one against the previous so
/// a line across the antimeridian stays short.
fn project_all(camera: &Camera, points: &[LatLng], width: f32, height: f32) -> Vec<Point> {
	let world = camera.world_size();
	let mut projected: Vec<Point> = Vec::with_capacity(points.len());
	for point in points {
		let (x, y) = camera.project(*point, width, height);
		let mut x = f64::from(x);
		if let Some(previous) = projected.last()
			&& world > 0.0
		{
			while x - previous.x > world / 2.0 {
				x -= world;
			}
			while previous.x - x > world / 2.0 {
				x += world;
			}
		}
		projected.push(Point::new(x, f64::from(y)));
	}
	projected
}

/// Whether any part of `points` falls inside the viewport, allowing for the
/// few pixels of ink that spill past a path's centrelines.
fn visible(points: &[Point], width: f32, height: f32) -> bool {
	const MARGIN: f64 = 8.0;
	let Some(first) = points.first() else {
		return false;
	};
	let (mut left, mut top, mut right, mut bottom) = (first.x, first.y, first.x, first.y);
	for point in points.iter().skip(1) {
		left = left.min(point.x);
		top = top.min(point.y);
		right = right.max(point.x);
		bottom = bottom.max(point.y);
	}
	right >= -MARGIN
		&& left <= f64::from(width) + MARGIN
		&& bottom >= -MARGIN
		&& top <= f64::from(height) + MARGIN
}

/// Whether a ring encloses more than a hairline, so a degenerate ring draws
/// nothing rather than a smudge.
fn has_area(points: &[Point]) -> bool {
	let Some(first) = points.first() else {
		return false;
	};
	let (mut left, mut top, mut right, mut bottom) = (first.x, first.y, first.x, first.y);
	for point in points.iter().skip(1) {
		left = left.min(point.x);
		top = top.min(point.y);
		right = right.max(point.x);
		bottom = bottom.max(point.y);
	}
	right - left >= 0.5 || bottom - top >= 0.5
}

#[cfg(test)]
mod tests {
	use skribble_leptoskit::Palette;

	use super::*;
	use crate::paint::MapPaint;

	const SIZE: (f32, f32) = (320.0, 200.0);

	fn camera() -> Camera {
		Camera::new(LatLng::new(51.5074, -0.1278), 12.0)
	}

	fn park() -> MapFeature {
		MapFeature::area(vec![
			LatLng::new(51.500, -0.140),
			LatLng::new(51.500, -0.110),
			LatLng::new(51.515, -0.120),
		])
	}

	#[test]
	fn an_area_draws_a_hachure_fill_under_an_outline() {
		let drawing = drawing(camera(), SIZE.0, SIZE.1, &[park()], Theme::SKRIBBLE, 3);
		assert!(!drawing.is_empty());
		let tones: Vec<_> = drawing.paths.iter().map(|path| path.paint.tone()).collect();
		assert_eq!(tones, vec![Theme::SKRIBBLE.accent(), Theme::SKRIBBLE.ink()]);
		assert!(matches!(drawing.paths[0].paint, MapPaint::Stroke { .. }));
	}

	#[test]
	fn a_route_draws_one_round_capped_line() {
		let route = MapFeature::route(vec![
			LatLng::new(51.500, -0.140),
			LatLng::new(51.515, -0.120),
		]);
		let drawing = drawing(camera(), SIZE.0, SIZE.1, &[route], Theme::SKRIBBLE, 4);
		assert_eq!(drawing.paths.len(), 1);
		assert_eq!(drawing.paths[0].paint, {
			MapPaint::Stroke {
				tone: Theme::SKRIBBLE.ink(),
				width: 3.0,
			}
		});
	}

	#[test]
	fn a_point_draws_a_solid_dot_with_an_outline() {
		let dot = MapFeature::point(LatLng::new(51.5074, -0.1278));
		let drawing = drawing(camera(), SIZE.0, SIZE.1, &[dot], Theme::SKRIBBLE, 5);
		assert_eq!(drawing.paths.len(), 2);
		assert!(matches!(drawing.paths[0].paint, MapPaint::Fill(_)));
		assert!(matches!(drawing.paths[1].paint, MapPaint::Stroke { .. }));
	}

	#[test]
	fn a_feature_outside_the_viewport_is_culled() {
		let far = MapFeature::area(vec![
			LatLng::new(-33.9, 151.2),
			LatLng::new(-33.9, 151.3),
			LatLng::new(-33.8, 151.25),
		]);
		let drawing = drawing(camera(), SIZE.0, SIZE.1, &[far], Theme::SKRIBBLE, 6);
		assert!(drawing.is_empty());
	}

	#[test]
	fn culling_judges_the_whole_route_not_just_its_first_point() {
		// Starts off-screen and ends off the other edge, crossing the viewport.
		let across = MapFeature::route(vec![
			LatLng::new(51.5074, -0.400),
			LatLng::new(51.5074, 0.200),
		]);
		let drawing = drawing(camera(), SIZE.0, SIZE.1, &[across], Theme::SKRIBBLE, 7);
		assert!(!drawing.is_empty());
	}

	#[test]
	fn degenerate_features_draw_nothing() {
		let empty_area = MapFeature::area(Vec::new());
		let flat_route = MapFeature::route(vec![LatLng::new(51.5, -0.12)]);
		let same = LatLng::new(51.5074, -0.1278);
		let collapsed = MapFeature::area(vec![same, same, same]);
		let drawing = drawing(
			camera(),
			SIZE.0,
			SIZE.1,
			&[empty_area, flat_route, collapsed],
			Theme::SKRIBBLE,
			8,
		);
		assert!(drawing.is_empty());
	}

	#[test]
	fn a_named_tone_replaces_the_theme_default() {
		let tone = Tone::fixed(Palette::LIGHT.accent);
		let drawing = drawing(
			camera(),
			SIZE.0,
			SIZE.1,
			&[park().with_tone(tone)],
			Theme::SKRIBBLE,
			9,
		);
		assert_eq!(drawing.paths[0].paint.tone(), tone);
	}

	#[test]
	fn the_same_seed_draws_the_same_features() {
		let first = drawing(camera(), SIZE.0, SIZE.1, &[park()], Theme::SKRIBBLE, 10);
		let second = drawing(camera(), SIZE.0, SIZE.1, &[park()], Theme::SKRIBBLE, 10);
		let other = drawing(camera(), SIZE.0, SIZE.1, &[park()], Theme::SKRIBBLE, 11);
		assert_eq!(first, second);
		assert_ne!(first, other);
	}
}
