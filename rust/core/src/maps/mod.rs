//! Hand-drawn vector maps: a Web Mercator camera, rough areas, routes, dots,
//! pins, a paper background, and zoom buttons.
//!
//! There are no tiles and no network. A [`Camera`] projects geographic
//! coordinates into a flat viewport, and the rough engine inks features on
//! paper. Every drawing is in the map's own pixel space, so a feature never
//! drifts from the pin that marks it:
//!
//! ```
//! use skribble_core::Theme;
//! use skribble_core::maps::Camera;
//! use skribble_core::maps::LatLng;
//! use skribble_core::maps::MapFeature;
//! use skribble_core::maps::MapStyle;
//! use skribble_core::maps::features_drawing;
//! use skribble_core::maps::graticule;
//!
//! let start = LatLng::new(51.5074, -0.1278);
//! let end = LatLng::new(51.5160, -0.1100);
//! let camera = Camera::new(start, 14.0);
//! let style = MapStyle::PAPER;
//! let theme = style.inked(Theme::SKRIBBLE);
//!
//! let grid = graticule(camera, 360.0, 240.0, style.graticule.expect("paper has a grid"), 1);
//! let route = features_drawing(camera, 360.0, 240.0, &[MapFeature::route(vec![start, end])], theme, 1);
//! assert!(!grid.is_empty() && !route.is_empty());
//! ```
//!
//! A camera keeps north up, so one flat projection places everything:
//!
//! ```
//! use skribble_core::maps::Camera;
//! use skribble_core::maps::LatLng;
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
pub use feature::features_drawing;
pub use pin::PIN_HEIGHT;
pub use pin::PIN_INK;
pub use pin::PIN_LABEL_GAP;
pub use pin::PIN_LABEL_WIDTH;
pub use pin::PIN_STICKER;
pub use pin::PIN_WIDTH;
pub use pin::PinCategory;
pub use pin::pin_drawing;
pub use pin::pin_origin;
pub use style::MapStyle;
pub use style::graticule;
pub use zoom::ZOOM_BUTTON_SIZE;
pub use zoom::zoom_button_drawing;
pub use zoom::zoom_steps;
