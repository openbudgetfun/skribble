//! Degenerate input must finish: empty, reversed, and non-finite arcs,
//! negative boxes, infinite edges, and fill patterns with no length.
//!
//! Each case runs on its own thread with a deadline, so a regression fails
//! the test instead of hanging the suite.

use std::f64::consts::PI;
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

use skribble_rough::DrawConfig;
use skribble_rough::DrawOptions;
use skribble_rough::Drawable;
use skribble_rough::DrawableInk;
use skribble_rough::DrawableInkOptions;
use skribble_rough::FillOptions;
use skribble_rough::FillStyle;
use skribble_rough::Filler;
use skribble_rough::Generator;
use skribble_rough::Shape;
use skribble_rough::SketchOptions;
use skribble_rough::sketch;

/// Runs `draw` and fails if it takes longer than ten seconds.
fn finishes<T: Send + 'static>(name: &str, draw: impl FnOnce() -> T + Send + 'static) -> T {
	let (send, receive) = mpsc::channel();
	thread::spawn(move || {
		let _ = send.send(draw());
	});
	receive
		.recv_timeout(Duration::from_secs(10))
		.unwrap_or_else(|_| panic!("{name} did not finish"))
}

fn generator(options: DrawOptions, style: FillStyle, pattern: FillOptions) -> Generator {
	Generator::new(
		DrawConfig::new(options),
		Filler::new(style, pattern, DrawConfig::new(options)),
	)
}

fn hachure() -> Generator {
	let options = DrawOptions {
		seed: 3,
		..DrawOptions::default()
	};
	generator(options, FillStyle::Hachure, FillOptions::default())
}

fn op_count(drawable: &Drawable) -> usize {
	drawable.sets.iter().map(|set| set.ops.len()).sum()
}

#[test]
fn empty_reversed_and_non_finite_arcs_draw_nothing() {
	for (start, stop) in [
		(1.0, 1.0),
		(1.0, 0.99),
		(PI, 0.0),
		(f64::NEG_INFINITY, 1.0),
		(0.0, f64::INFINITY),
		(f64::NAN, 1.0),
	] {
		for closed in [false, true] {
			let drawable = finishes("an empty arc", move || {
				hachure().arc(50.0, 50.0, 100.0, 100.0, start, stop, closed)
			});
			assert_eq!(
				op_count(&drawable),
				0,
				"sweep {start} to {stop} should draw nothing"
			);
			// No filler ran, so the only set is the empty outline.
			assert_eq!(drawable.sets.len(), 1);
		}
	}
}

#[test]
fn ordinary_arcs_keep_their_geometry() {
	let draw = || hachure().arc(100.0, 100.0, 160.0, 120.0, 0.3, PI * 1.4, true);
	let first = draw();
	assert!(op_count(&first) > 0);
	assert_eq!(first, draw());
}

#[test]
fn far_negative_and_tiny_sweeps_finish() {
	let far = finishes("a far-off arc", || {
		hachure().arc(50.0, 50.0, 100.0, 100.0, -1e12, -1e12 + 1.0, false)
	});
	assert!(op_count(&far) > 0);

	// A progress ring a hair above zero: the sampler steps by half the sweep.
	let tiny = finishes("a tiny arc", || {
		hachure().arc(50.0, 50.0, 100.0, 100.0, 0.0, 1e-12, false)
	});
	assert!(op_count(&tiny) > 0);
}

#[test]
fn step_counts_that_never_advance_finish() {
	for curve_step_count in [-1.0, 1e300] {
		let options = DrawOptions {
			curve_step_count,
			..DrawOptions::default()
		};
		finishes("a stalled arc", move || {
			generator(options, FillStyle::Hachure, FillOptions::default())
				.arc(50.0, 50.0, 100.0, 100.0, 0.0, 1.0, true)
		});
		finishes("a stalled ellipse", move || {
			generator(options, FillStyle::Hachure, FillOptions::default())
				.ellipse(50.0, 50.0, 100.0, 100.0)
		});
	}
}

#[test]
fn negative_rounded_rectangles_have_square_corners() {
	for (width, height) in [(-10.0, 20.0), (20.0, -10.0)] {
		let drawable = finishes("a negative rounded rectangle", move || {
			hachure().rounded_rectangle(0.0, 0.0, width, height, [4.0; 4])
		});
		let outline = drawable.sets.last().expect("an outline");
		assert!(!outline.ops.is_empty());
	}
}

#[test]
fn infinite_edges_finish_without_ink() {
	let drawable = finishes("an infinite line", || {
		hachure().line(0.0, 0.0, f64::INFINITY, 0.0)
	});
	let ink = DrawableInk::new(&drawable, DrawableInkOptions::new(1.5, 1.0));
	assert!(
		ink.sets
			.iter()
			.all(|set| set.svg_paths().iter().all(|path| path.data.is_empty()))
	);

	let filled = finishes("an infinite rectangle", || {
		hachure().rectangle(0.0, 0.0, 100.0, f64::INFINITY)
	});
	assert!(
		filled.sets[0].ops.is_empty(),
		"no hachure for an infinite box"
	);
}

#[test]
fn dash_patterns_without_length_draw_whole_lines() {
	let options = DrawOptions {
		seed: 3,
		..DrawOptions::default()
	};
	let hachure_ops = generator(options, FillStyle::Hachure, FillOptions::default())
		.rectangle(0.0, 0.0, 100.0, 100.0)
		.sets[0]
		.ops
		.len();
	for (dash_offset, dash_gap) in [(0.0, 0.0), (-1.0, 1.0), (1e-12, 0.0), (f64::NAN, 2.0)] {
		let pattern = FillOptions {
			dash_offset,
			dash_gap,
			..FillOptions::default()
		};
		let drawable = finishes("a dashed fill", move || {
			generator(options, FillStyle::Dashed, pattern).rectangle(0.0, 0.0, 100.0, 100.0)
		});
		assert_eq!(
			drawable.sets[0].ops.len(),
			hachure_ops,
			"dash {dash_offset} gap {dash_gap} should draw undashed hachure"
		);
	}
}

#[test]
fn hachure_gaps_of_zero_or_less_finish() {
	for hachure_gap in [0.0, -5.0, f64::INFINITY] {
		let options = SketchOptions {
			fill: Some("red".to_owned()),
			pattern: FillOptions {
				hachure_gap,
				..FillOptions::default()
			},
			..SketchOptions::default()
		};
		finishes("a hachure fill", move || {
			sketch(&[Shape::rectangle(0.0, 0.0, 100.0, 100.0)], &options)
		})
		.expect("a rectangle draws");
	}
}
