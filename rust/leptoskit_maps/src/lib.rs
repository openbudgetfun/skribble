//! Hand-drawn maps for leptoskit apps, from the skribble design system.
//!
//! This crate draws its own vector map: there are no tiles, no network
//! requests, and no extra dependencies. A [`Camera`] projects geographic
//! coordinates into a flat Web Mercator viewport, and the rough engine from
//! [`skribble_rough`] inks areas, routes, dots, and pins on paper. The result
//! is the same [`Vector`](leptoskit::native::Element) tree on the web and on
//! every native platform.
//!
//! ```
//! use leptoskit::prelude::*;
//! use skribble_leptoskit_maps::Camera;
//! use skribble_leptoskit_maps::LatLng;
//! use skribble_leptoskit_maps::MapFeature;
//! use skribble_leptoskit_maps::MapPin;
//! use skribble_leptoskit_maps::PinCategory;
//! use skribble_leptoskit_maps::WiredMap;
//!
//! pub fn city_walk(on_pin: impl Fn() + Send + Sync + 'static) -> Element {
//! 	let start = LatLng::new(51.5074, -0.1278);
//! 	let end = LatLng::new(51.5160, -0.1100);
//! 	view! {
//! 		<WiredMap
//! 			camera=Camera::new(start, 14.0)
//! 			width=360.0
//! 			height=240.0
//! 			features=vec![MapFeature::route(vec![start, end])]
//! 			pins=vec![
//! 				MapPin::new(start, "Start").with_category(PinCategory::Coffee).with_on_press(on_pin),
//! 				MapPin::new(end, "Finish"),
//! 			]
//! 			label="A sketched walking route"
//! 		/>
//! 	}
//! }
//! # let _ = city_walk(|| {});
//! ```
//!
//! # Components
//!
//! | Component                                        | Draws                                                        |
//! | ------------------------------------------------ | ------------------------------------------------------------ |
//! | [`WiredMap`](fn@WiredMap)                        | Paper, a faint graticule, and rough features and pins        |
//! | [`WiredMapZoomControls`](fn@WiredMapZoomControls)| Two hand-drawn buttons that propose a closer or further camera |
//!
//! [`Camera`], [`LatLng`], and [`LatLngBounds`] do the projection;
//! [`MapFeature`] describes areas, routes, and dots; [`MapPin`] and
//! [`PinCategory`] describe the places worth a sticker; and [`MapStyle`] picks
//! the paper behind them all.
//!
//! # Projection
//!
//! A camera keeps north up, so one flat projection places everything:
//!
//! ```
//! use skribble_leptoskit_maps::Camera;
//! use skribble_leptoskit_maps::LatLng;
//!
//! let camera = Camera::new(LatLng::new(0.0, 0.0), 3.0);
//! let (x, y) = camera.project(LatLng::new(0.0, 0.0), 400.0, 240.0);
//! assert_eq!((x, y), (200.0, 120.0));
//!
//! let back = camera.unproject(x, y, 400.0, 240.0);
//! assert!(back.lat.abs() < 0.000_001 && back.lng.abs() < 0.000_001);
//! ```
//!
//! Latitudes are clamped to [`MAX_LATITUDE`], longitudes wrap across the
//! antimeridian, and [`Camera::fit`] frames a [`LatLngBounds`] in a viewport
//! with padding.

mod camera;
mod feature;
mod map;
mod paint;
mod pin;
mod style;
mod zoom;

pub use camera::Camera;
pub use camera::LatLng;
pub use camera::LatLngBounds;
pub use camera::MAX_LATITUDE;
pub use camera::MAX_ZOOM;
pub use camera::MIN_ZOOM;
pub use camera::TILE_SIZE;
pub use feature::MapFeature;
pub use map::WiredMap;
pub use pin::MapPin;
pub use pin::PIN_HEIGHT;
pub use pin::PIN_WIDTH;
pub use pin::PinCategory;
pub use style::MapStyle;
pub use zoom::WiredMapZoomControls;
