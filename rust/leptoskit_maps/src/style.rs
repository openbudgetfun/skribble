//! Map backgrounds: the paper behind the ink and its faint graticule.

use leptoskit::native::Color;
use skribble_leptoskit::Tone;
use skribble_rough::DrawConfig;
use skribble_rough::DrawOptions;
use skribble_rough::FillOptions;
use skribble_rough::FillStyle;
use skribble_rough::Filler;
use skribble_rough::Generator;
use skribble_rough::RoughPen;
use skribble_rough::RoughSvgPaths;

use crate::camera::Camera;
use crate::camera::LatLng;
use crate::camera::MAX_LATITUDE;
use crate::paint::MapDrawing;

/// The paper a map is drawn on, and the grid sketched over it.
///
/// A map has no tiles and no network, so its background is ink on paper. The
/// presets cover warm paper, charcoal, and plain paper, and a map with no
/// named style uses [`MapStyle::PAPER`]. Build your own when a product has
/// its own colour:
///
/// ```
/// use skribble_leptoskit::Palette;
/// use skribble_leptoskit::Tone;
/// use skribble_leptoskit_maps::MapStyle;
///
/// pub const BLUE: MapStyle = MapStyle {
/// 	paper: Tone::fixed(Palette::LIGHT.accent),
/// 	graticule: None,
/// };
/// assert!(BLUE.graticule.is_none());
/// ```
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct MapStyle {
	/// The colour behind every feature and pin.
	pub paper: Tone,
	/// The colour of the hand-drawn graticule, or `None` for plain paper.
	pub graticule: Option<Tone>,
}

impl MapStyle {
	/// Warm paper with a faint graticule, in both light and dark appearances.
	pub const PAPER: Self = Self {
		paper: Tone {
			light: Color::rgba(0xfb, 0xf7, 0xec, 0xff),
			dark: Color::rgba(0x20, 0x1f, 0x1b, 0xff),
		},
		graticule: Some(Tone {
			light: Color::rgba(0x1f, 0x1d, 0x1a, 0x24),
			dark: Color::rgba(0xf2, 0xef, 0xe6, 0x28),
		}),
	};

	/// Charcoal paper with a chalk graticule, the low-light preset.
	pub const DARK: Self = Self {
		paper: Tone {
			light: Color::rgba(0x2e, 0x2c, 0x27, 0xff),
			dark: Color::rgba(0x14, 0x13, 0x0f, 0xff),
		},
		graticule: Some(Tone {
			light: Color::rgba(0xf2, 0xef, 0xe6, 0x38),
			dark: Color::rgba(0xf2, 0xef, 0xe6, 0x30),
		}),
	};

	/// Paper with nothing sketched over it.
	pub const PLAIN: Self = Self {
		paper: Tone {
			light: Color::rgba(0xfd, 0xfb, 0xf5, 0xff),
			dark: Color::rgba(0x1b, 0x1a, 0x17, 0xff),
		},
		graticule: None,
	};
}

impl Default for MapStyle {
	fn default() -> Self {
		Self::PAPER
	}
}

/// The fewest pixels allowed between neighbouring graticule lines.
const MIN_GRID_SPACING: f64 = 56.0;

/// The degree steps a graticule may choose from, fine to coarse.
const GRID_STEPS: [f64; 13] = [
	0.01, 0.02, 0.05, 0.1, 0.25, 0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 30.0, 45.0,
];

/// The graticule for `camera`, in the map's own pixel space.
pub(crate) fn graticule(
	camera: Camera,
	width: f32,
	height: f32,
	tone: Tone,
	seed: i64,
) -> MapDrawing {
	let mut drawing = MapDrawing::new(f64::from(width), f64::from(height));
	let world = camera.world_size();
	if !world.is_finite() || world <= 0.0 {
		return drawing;
	}
	let step = grid_step(world);
	let mut index = 0_i64;

	// Longitude lines are evenly spaced in world pixels, so they need no
	// wrapping: each multiple of the step lands on one screen column.
	let (centre_x, _) = camera.project_f64(camera.center);
	let left = centre_x - f64::from(width) / 2.0;
	let spacing = world * step / 360.0;
	if spacing > 0.0 {
		let first = (left / spacing).floor() as i64;
		let last = ((left + f64::from(width)) / spacing).ceil() as i64;
		if last - first <= 400 {
			for line in first..=last {
				let x = line as f64 * spacing - left;
				push_line(
					&mut drawing,
					(x, 0.0, x, f64::from(height)),
					tone,
					seed.wrapping_add(index),
				);
				index = index.wrapping_add(1);
			}
		}
	}

	// Latitude lines are not evenly spaced in pixels, so each one is projected
	// and kept only when it lands inside the viewport.
	let top = camera
		.unproject(width / 2.0, 0.0, width, height)
		.lat
		.min(MAX_LATITUDE);
	let bottom = camera
		.unproject(width / 2.0, height, width, height)
		.lat
		.max(-MAX_LATITUDE);
	let first = (bottom / step).floor() as i64;
	let last = (top / step).ceil() as i64;
	if last - first <= 200 {
		for line in first..=last {
			let latitude = (line as f64 * step).clamp(-MAX_LATITUDE, MAX_LATITUDE);
			let (_, y) = camera.project(LatLng::new(latitude, camera.center.lng), width, height);
			push_line(
				&mut drawing,
				(0.0, f64::from(y), f64::from(width), f64::from(y)),
				tone,
				seed.wrapping_add(index),
			);
			index = index.wrapping_add(1);
		}
	}

	drawing
}

/// The finest step whose lines stay at least [`MIN_GRID_SPACING`] apart.
fn grid_step(world: f64) -> f64 {
	let mut step = GRID_STEPS[GRID_STEPS.len() - 1];
	for candidate in GRID_STEPS {
		if world * candidate / 360.0 >= MIN_GRID_SPACING {
			step = candidate;
			break;
		}
	}
	step
}

/// Adds one faint, slightly wobbly line to the graticule.
fn push_line(drawing: &mut MapDrawing, line: (f64, f64, f64, f64), tone: Tone, seed: i64) {
	let options = DrawOptions {
		seed,
		roughness: 0.7,
		max_randomness_offset: 0.7,
		line_wobble: 0.25,
		pen: RoughPen::UNIFORM,
		..DrawOptions::default()
	};
	let mut generator = Generator::new(
		DrawConfig::new(options),
		Filler::new(
			FillStyle::None,
			FillOptions::default(),
			DrawConfig::new(options),
		),
	);
	let paths = RoughSvgPaths::from_drawable(&generator.line(line.0, line.1, line.2, line.3));
	drawing.push_stroke(paths.outline, tone, 1.0);
}

#[cfg(test)]
mod tests {
	use super::*;

	const SIZE: (f32, f32) = (320.0, 200.0);

	fn camera() -> Camera {
		Camera::new(LatLng::new(0.0, 0.0), 2.0)
	}

	#[test]
	fn a_graticule_draws_lines_in_its_tone() {
		let drawing = graticule(
			camera(),
			SIZE.0,
			SIZE.1,
			MapStyle::PAPER.graticule.expect("a grid"),
			1,
		);
		assert!(!drawing.is_empty());
		assert!(
			drawing
				.paths
				.iter()
				.all(|path| path.paint.tone() == MapStyle::PAPER.graticule.expect("a grid"))
		);
	}

	#[test]
	fn the_grid_step_keeps_lines_apart_at_every_zoom() {
		for zoom in 0..=20 {
			let world = 512.0 * 2f64.powi(zoom);
			let step = grid_step(world);
			let spacing = world * step / 360.0;
			assert!(spacing >= MIN_GRID_SPACING, "zoom {zoom} spaced {spacing}");
		}
	}

	#[test]
	fn the_same_seed_draws_the_same_graticule() {
		let tone = MapStyle::PAPER.graticule.expect("a grid");
		assert_eq!(
			graticule(camera(), SIZE.0, SIZE.1, tone, 2),
			graticule(camera(), SIZE.0, SIZE.1, tone, 2)
		);
	}

	#[test]
	fn plain_paper_names_no_grid() {
		assert!(MapStyle::PLAIN.graticule.is_none());
		assert!(MapStyle::PAPER.graticule.is_some());
		assert!(MapStyle::DARK.graticule.is_some());
		assert_eq!(MapStyle::default(), MapStyle::PAPER);
	}
}
