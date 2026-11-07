//! Web Mercator projection and the camera that frames a map.
//!
//! The projection matches the flat, pitch-free coordinate plane a vector map
//! uses: a 512-pixel world at zoom zero, doubling with every zoom level. A
//! map that keeps north up and scale uniform can place every feature with
//! this one formula, on the web and on native alike.
//!
//! ```
//! use skribble_leptoskit_maps::Camera;
//! use skribble_leptoskit_maps::LatLng;
//!
//! let camera = Camera::new(LatLng::new(51.5074, -0.1278), 12.0);
//! let (x, y) = camera.project(LatLng::new(51.5074, -0.1278), 320.0, 200.0);
//! assert!((x - 160.0).abs() < 0.01);
//! assert!((y - 100.0).abs() < 0.01);
//! ```

use std::f64::consts::PI;

/// The highest latitude Web Mercator can represent, in degrees.
///
/// Projection clamps every latitude to this value, so the poles map to the
/// top and bottom edges of the square world instead of infinity.
pub const MAX_LATITUDE: f64 = 85.051_128_78;

/// The logical world size at zoom zero, in pixels.
///
/// This is the tile size vector map providers use, and it keeps a hand-drawn
/// feature aligned with the coordinates an app already has.
pub const TILE_SIZE: f64 = 512.0;

/// The closest zoom a camera can use.
pub const MIN_ZOOM: f64 = 0.0;

/// The furthest zoom a camera can use.
pub const MAX_ZOOM: f64 = 20.0;

/// A geographic coordinate in degrees.
///
/// Latitude is positive to the north and longitude positive to the east, the
/// order maps and routing services usually hand to an app.
#[derive(Debug, Clone, Copy, Default, PartialEq)]
pub struct LatLng {
	/// Latitude in degrees, north positive.
	pub lat: f64,
	/// Longitude in degrees, east positive.
	pub lng: f64,
}

impl LatLng {
	/// A coordinate from its latitude and longitude in degrees.
	#[must_use]
	pub const fn new(lat: f64, lng: f64) -> Self {
		Self { lat, lng }
	}

	/// The same point in the range projection can draw.
	///
	/// The latitude is clamped to [`MAX_LATITUDE`] and the longitude is
	/// wrapped into `-180..180`, so a point across the antimeridian keeps
	/// describing the place it names.
	#[must_use]
	pub fn wrapped(self) -> Self {
		Self {
			lat: self.lat.clamp(-MAX_LATITUDE, MAX_LATITUDE),
			lng: wrap_longitude(self.lng),
		}
	}
}

/// A geographic rectangle, from its south-west and north-east corners.
///
/// The corners describe a box on the ground, so the north-east latitude is
/// the northern edge. A western longitude greater than the eastern one is
/// read as a box across the antimeridian.
#[derive(Debug, Clone, Copy, Default, PartialEq)]
pub struct LatLngBounds {
	/// The south-west corner.
	pub south_west: LatLng,
	/// The north-east corner.
	pub north_east: LatLng,
}

impl LatLngBounds {
	/// A box from its two opposite corners.
	#[must_use]
	pub const fn new(south_west: LatLng, north_east: LatLng) -> Self {
		Self {
			south_west,
			north_east,
		}
	}
}

/// A flat Web Mercator camera: where a map looks and how close.
///
/// A camera keeps north up and draws without pitch or rotation, so the whole
/// viewport is one linear projection. Combine it with the map's viewport size
/// to place features, pins, and labels:
///
/// ```
/// use skribble_leptoskit_maps::Camera;
/// use skribble_leptoskit_maps::LatLng;
///
/// let camera = Camera::new(LatLng::new(48.8584, 2.2945), 15.0);
/// let (x, y) = camera.project(LatLng::new(48.8584, 2.2945), 360.0, 240.0);
/// assert!((x - 180.0).abs() < 0.01);
/// assert!((y - 120.0).abs() < 0.01);
/// ```
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Camera {
	/// The geographic coordinate at the centre of the viewport.
	pub center: LatLng,
	/// The continuous zoom level, from [`MIN_ZOOM`] to [`MAX_ZOOM`].
	pub zoom: f64,
}

impl Camera {
	/// A camera looking at `center` from `zoom`.
	///
	/// The centre is wrapped into the drawable range and the zoom is clamped
	/// to [`MIN_ZOOM`] and [`MAX_ZOOM`], so a camera is always usable.
	#[must_use]
	pub fn new(center: LatLng, zoom: f64) -> Self {
		Self {
			center: center.wrapped(),
			zoom: zoom.clamp(MIN_ZOOM, MAX_ZOOM),
		}
	}

	/// The width of the whole world at this zoom, in pixels.
	#[must_use]
	pub fn world_size(&self) -> f64 {
		TILE_SIZE * 2f64.powf(self.zoom)
	}

	/// Projects `point` into viewport pixels, with the origin at the top-left
	/// corner of a `width` by `height` viewport.
	///
	/// Longitude differences wrap around the world, so a point just across
	/// the antimeridian projects just past the opposite edge rather than a
	/// whole world away.
	#[must_use]
	pub fn project(&self, point: LatLng, width: f32, height: f32) -> (f32, f32) {
		let (x, y) = self.project_f64(point);
		let center = self.project_f64(self.center);
		let world = self.world_size();
		let mut delta_x = x - center.0;
		if world > 0.0 {
			while delta_x > world / 2.0 {
				delta_x -= world;
			}
			while delta_x < -world / 2.0 {
				delta_x += world;
			}
		}
		(
			(f64::from(width) / 2.0 + delta_x) as f32,
			(f64::from(height) / 2.0 + y - center.1) as f32,
		)
	}

	/// Projects `point` into this camera's global pixel plane.
	pub(crate) fn project_f64(&self, point: LatLng) -> (f64, f64) {
		project_to_world(point, self.zoom)
	}

	/// Converts a viewport pixel back to a geographic coordinate.
	///
	/// `x` and `y` are measured from the top-left corner of a `width` by
	/// `height` viewport.
	#[must_use]
	pub fn unproject(&self, x: f32, y: f32, width: f32, height: f32) -> LatLng {
		let (center_x, center_y) = self.project_f64(self.center);
		let world_x = center_x + f64::from(x) - f64::from(width) / 2.0;
		let world_y = center_y + f64::from(y) - f64::from(height) / 2.0;
		unproject_from_world(world_x, world_y, self.zoom)
	}

	/// The camera that frames `bounds` in a `width` by `height` viewport,
	/// leaving `padding` pixels of breathing room at every edge.
	///
	/// The zoom is clamped to [`MIN_ZOOM`] and [`MAX_ZOOM`], so a single
	/// point, a tiny park, or a whole continent all produce a usable camera.
	///
	/// ```
	/// use skribble_leptoskit_maps::Camera;
	/// use skribble_leptoskit_maps::LatLng;
	/// use skribble_leptoskit_maps::LatLngBounds;
	///
	/// let bounds = LatLngBounds::new(LatLng::new(51.50, -0.13), LatLng::new(51.52, -0.10));
	/// let camera = Camera::fit(bounds, 320.0, 200.0, 16.0);
	/// assert!(camera.zoom > 10.0);
	/// ```
	#[must_use]
	pub fn fit(bounds: LatLngBounds, width: f32, height: f32, padding: f32) -> Self {
		let (west, south) = project_to_world(bounds.south_west, 0.0);
		let (east, north) = project_to_world(bounds.north_east, 0.0);
		let east = if east < west { east + TILE_SIZE } else { east };
		let top = south.min(north);
		let bottom = south.max(north);
		let span_x = (east - west).abs().max(0.000_001);
		let span_y = (bottom - top).max(0.000_001);

		let padding = f64::from(if padding.is_finite() {
			padding.max(0.0)
		} else {
			0.0
		});
		let usable_width = (f64::from(width) - padding * 2.0).max(1.0);
		let usable_height = (f64::from(height) - padding * 2.0).max(1.0);
		let zoom = (usable_width / span_x)
			.log2()
			.min((usable_height / span_y).log2())
			.clamp(MIN_ZOOM, MAX_ZOOM);

		let scale = 2f64.powf(zoom);
		let center_x = (west + east) / 2.0 * scale;
		let center_y = (top + bottom) / 2.0 * scale;
		Self {
			center: unproject_from_world(center_x, center_y, zoom),
			zoom,
		}
	}
}

impl Default for Camera {
	fn default() -> Self {
		Self::new(LatLng::default(), MIN_ZOOM)
	}
}

/// Projects `point` into the global pixel plane at `zoom`.
fn project_to_world(point: LatLng, zoom: f64) -> (f64, f64) {
	let wrapped = point.wrapped();
	let scale = TILE_SIZE * 2f64.powf(zoom);
	let sin_latitude = (wrapped.lat * PI / 180.0).sin();
	let x = (wrapped.lng + 180.0) / 360.0;
	let y = 0.5 - ((1.0 + sin_latitude) / (1.0 - sin_latitude)).ln() / (4.0 * PI);
	(x * scale, y * scale)
}

/// Converts a global pixel at `zoom` back to a coordinate.
fn unproject_from_world(x: f64, y: f64, zoom: f64) -> LatLng {
	let scale = TILE_SIZE * 2f64.powf(zoom);
	let longitude = wrap_longitude(x / scale * 360.0 - 180.0);
	let mercator_y = PI - 2.0 * PI * y / scale;
	let hyperbolic_sine = (mercator_y.exp() - (-mercator_y).exp()) / 2.0;
	let latitude = 180.0 / PI * hyperbolic_sine.atan();
	LatLng::new(latitude.clamp(-MAX_LATITUDE, MAX_LATITUDE), longitude)
}

/// Wraps `longitude` into `-180..180`.
fn wrap_longitude(longitude: f64) -> f64 {
	if !longitude.is_finite() {
		return 0.0;
	}
	(longitude + 180.0).rem_euclid(360.0) - 180.0
}

#[cfg(test)]
mod tests {
	use super::*;

	const SIZE: (f32, f32) = (320.0, 200.0);
	const TOLERANCE: f64 = 0.01;

	fn close(actual: f64, expected: f64) -> bool {
		(actual - expected).abs() < TOLERANCE
	}

	fn london() -> LatLng {
		LatLng::new(51.5074, -0.1278)
	}

	#[test]
	fn the_centre_projects_to_the_middle_of_the_viewport() {
		let camera = Camera::new(london(), 12.0);
		let (x, y) = camera.project(london(), SIZE.0, SIZE.1);
		assert!(close(f64::from(x), 160.0), "{x}");
		assert!(close(f64::from(y), 100.0), "{y}");
	}

	#[test]
	fn projection_and_unprojection_round_trip() {
		let camera = Camera::new(london(), 14.5);
		for point in [
			LatLng::new(51.5, -0.12),
			LatLng::new(51.49, -0.14),
			LatLng::new(51.52, -0.10),
		] {
			let (x, y) = camera.project(point, SIZE.0, SIZE.1);
			let back = camera.unproject(x, y, SIZE.0, SIZE.1);
			assert!(close(back.lat, point.lat), "{back:?} for {point:?}");
			assert!(close(back.lng, point.lng), "{back:?} for {point:?}");
		}
	}

	#[test]
	fn a_known_point_lands_where_the_world_projection_says() {
		let camera = Camera::new(LatLng::new(0.0, 0.0), 0.0);
		let (x, y) = camera.project(LatLng::new(0.0, 0.0), 512.0, 512.0);
		assert!(close(f64::from(x), 256.0), "{x}");
		assert!(close(f64::from(y), 256.0), "{y}");

		let north_west = camera.project(LatLng::new(MAX_LATITUDE, -180.0), 512.0, 512.0);
		assert!(f64::from(north_west.0) < 1.0, "{north_west:?}");
		assert!(f64::from(north_west.1) < 1.0, "{north_west:?}");
	}

	#[test]
	fn latitude_is_clamped_to_the_mercator_limit_for_both_poles() {
		let camera = Camera::new(LatLng::new(0.0, 0.0), 3.0);
		let north = camera.project(LatLng::new(90.0, 10.0), SIZE.0, SIZE.1);
		let limit = camera.project(LatLng::new(MAX_LATITUDE, 10.0), SIZE.0, SIZE.1);
		let south = camera.project(LatLng::new(-90.0, 10.0), SIZE.0, SIZE.1);
		let bottom = camera.project(LatLng::new(-MAX_LATITUDE, 10.0), SIZE.0, SIZE.1);
		assert_eq!(north, limit);
		assert_eq!(south, bottom);
	}

	#[test]
	fn points_across_the_antimeridian_stay_near_their_neighbour() {
		let camera = Camera::new(LatLng::new(0.0, 179.0), 4.0);
		let east = camera.project(LatLng::new(0.0, 178.0), SIZE.0, SIZE.1);
		let across = camera.project(LatLng::new(0.0, -179.0), SIZE.0, SIZE.1);
		assert!(across.0 > east.0, "{across:?} east of {east:?}");
		assert!(f64::from(across.0 - east.0) < 100.0, "{across:?}");
	}

	#[test]
	fn fit_frames_every_corner_inside_the_padding() {
		let bounds = LatLngBounds::new(LatLng::new(51.48, -0.16), LatLng::new(51.54, -0.08));
		let padding = 16.0;
		let camera = Camera::fit(bounds, SIZE.0, SIZE.1, padding);

		for corner in [bounds.south_west, bounds.north_east] {
			let (x, y) = camera.project(corner, SIZE.0, SIZE.1);
			assert!(f64::from(x) >= f64::from(padding) - TOLERANCE, "{corner:?}");
			assert!(
				f64::from(x) <= f64::from(SIZE.0) - f64::from(padding) + TOLERANCE,
				"{corner:?}"
			);
			assert!(f64::from(y) >= f64::from(padding) - TOLERANCE, "{corner:?}");
			assert!(
				f64::from(y) <= f64::from(SIZE.1) - f64::from(padding) + TOLERANCE,
				"{corner:?}"
			);
		}
	}

	#[test]
	fn fit_centres_the_bounds() {
		let bounds = LatLngBounds::new(LatLng::new(-10.0, -10.0), LatLng::new(10.0, 10.0));
		let camera = Camera::fit(bounds, SIZE.0, SIZE.1, 0.0);
		let (x, y) = camera.project(LatLng::new(0.0, 0.0), SIZE.0, SIZE.1);
		assert!(close(f64::from(x), f64::from(SIZE.0) / 2.0), "{x}");
		assert!(close(f64::from(y), f64::from(SIZE.1) / 2.0), "{y}");
	}

	#[test]
	fn fit_keeps_a_single_point_at_the_maximum_zoom() {
		let point = LatLng::new(35.6595, 139.7005);
		let camera = Camera::fit(LatLngBounds::new(point, point), SIZE.0, SIZE.1, 8.0);
		assert_eq!(camera.zoom, MAX_ZOOM);
		assert!(close(camera.center.lat, point.lat));
		assert!(close(camera.center.lng, point.lng));
	}

	#[test]
	fn fit_accepts_a_box_across_the_antimeridian() {
		let bounds = LatLngBounds::new(LatLng::new(-5.0, 170.0), LatLng::new(5.0, -170.0));
		let camera = Camera::fit(bounds, SIZE.0, SIZE.1, 8.0);
		let (x, _) = camera.project(LatLng::new(0.0, 180.0), SIZE.0, SIZE.1);
		assert!(close(f64::from(x), f64::from(SIZE.0) / 2.0), "{x}");
	}

	#[test]
	fn constructors_wrap_the_centre_and_clamp_the_zoom() {
		let camera = Camera::new(LatLng::new(120.0, 540.0), 42.0);
		assert_eq!(camera.zoom, MAX_ZOOM);
		assert!(close(camera.center.lat, MAX_LATITUDE));
		assert!(close(camera.center.lng, -180.0));
		assert_eq!(Camera::default().zoom, MIN_ZOOM);
	}
}
