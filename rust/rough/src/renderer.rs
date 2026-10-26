//! Rough strokes: the jittered lines, curves, and ellipses every shape is
//! built from.

use std::f64::consts::PI;
use std::f64::consts::TAU;

use crate::DrawConfig;
use crate::Op;
use crate::OpSet;
use crate::Point;
use crate::math::clamp;

/// Edges at least this long wander locally instead of bowing as one curve.
const WANDER_LENGTH: f64 = 48.0;

/// One rough stroke from (`x1`, `y1`) to (`x2`, `y2`). The `overlay` stroke is
/// the lighter second pass.
fn line(
	x1: f64,
	y1: f64,
	x2: f64,
	y2: f64,
	config: &mut DrawConfig,
	start: bool,
	overlay: bool,
) -> Vec<Op> {
	let options = config.options;
	let length_sq = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2);
	let length = length_sq.sqrt();

	if length >= WANDER_LENGTH && options.roughness > 0.0 && options.line_wobble > 0.0 {
		return wandering_line(x1, y1, x2, y2, config, overlay);
	}

	let gain = if length < 200.0 {
		1.0
	} else if length > 500.0 {
		0.4
	} else {
		-0.001_666_8 * length + 1.233_334
	};
	let mut offset = options.max_randomness_offset;
	if offset * offset * 100.0 > length_sq {
		offset = length / 10.0;
	}
	let half_offset = offset / 2.0;
	let diverge_point = 0.2 + config.next_double() * 0.2;

	// Bowing grows with length, but never past the displacement painters
	// reserve as bleed: a very long edge would otherwise leave its card.
	let bow_limit = options.bowing.abs() * options.max_randomness_offset;
	let bow_x = clamp(
		options.bowing * options.max_randomness_offset * (y2 - y1) / 200.0,
		-bow_limit,
		bow_limit,
	);
	let bow_y = clamp(
		options.bowing * options.max_randomness_offset * (x1 - x2) / 200.0,
		-bow_limit,
		bow_limit,
	);
	let offset_x = config.offset_symmetric(bow_x, gain);
	let offset_y = config.offset_symmetric(bow_y, gain);

	let mut ops = Vec::with_capacity(2);
	if start {
		let to = if overlay {
			Point::new(
				x1 + config.offset_symmetric(half_offset, gain),
				y1 + config.offset_symmetric(half_offset, gain),
			)
		} else {
			Point::new(
				x1 + config.offset_symmetric(offset, gain),
				y1 + config.offset_symmetric(offset, gain),
			)
		};
		ops.push(Op::Move {
			to,
			pass: u32::from(overlay),
		});
	}

	let jitter = if overlay { half_offset } else { offset };
	let mut random = || config.offset_symmetric(jitter, gain);
	let control1 = Point::new(
		offset_x + x1 + (x2 - x1) * diverge_point + random(),
		offset_y + y1 + (y2 - y1) * diverge_point + random(),
	);
	let control2 = Point::new(
		offset_x + x1 + 2.0 * (x2 - x1) * diverge_point + random(),
		offset_y + y1 + 2.0 * (y2 - y1) * diverge_point + random(),
	);
	let end = Point::new(x2 + random(), y2 + random());
	ops.push(Op::CurveTo {
		control1,
		control2,
		end,
	});
	ops
}

/// Long edges need local changes of direction: one cubic looks like a ruler
/// even with displaced endpoints. Every control point stays within the pen's
/// reserved jitter band, so larger cards do not need larger painting insets.
fn wandering_line(
	x1: f64,
	y1: f64,
	x2: f64,
	y2: f64,
	config: &mut DrawConfig,
	overlay: bool,
) -> Vec<Op> {
	let options = config.options;
	let dx = x2 - x1;
	let dy = y2 - y1;
	let length = (dx * dx + dy * dy).sqrt();
	let segments = (length / WANDER_LENGTH).ceil() as usize;
	let count = segments as f64;
	let limit = options.max_randomness_offset * options.roughness;
	let offset = options.max_randomness_offset * if overlay { 0.85 } else { 1.0 };
	let bow = config.offset_symmetric(offset, 1.0) * options.bowing * 0.3;

	let displacements: Vec<f64> = (0..=segments)
		.map(|i| {
			let t = i as f64 / count;
			let end_gain = if i == 0 || i == segments { 0.45 } else { 1.0 };
			clamp(
				(config.offset_symmetric(offset, 1.0) * 0.7 * end_gain + bow * (t * PI).sin())
					* options.line_wobble,
				-limit,
				limit,
			)
		})
		.collect();

	let at = |t: f64, displacement: f64| {
		Point::new(
			x1 + dx * t - (dy / length) * displacement,
			y1 + dy * t + (dx / length) * displacement,
		)
	};

	let mut ops = Vec::with_capacity(segments + 1);
	ops.push(Op::Move {
		to: at(0.0, displacements[0]),
		pass: u32::from(overlay),
	});
	for i in 0..segments {
		let before = displacements[i.saturating_sub(1)];
		let start = displacements[i];
		let end = displacements[i + 1];
		let after = displacements[(i + 2).min(segments)];
		let control1 = clamp(start + (end - before) / 6.0, -limit, limit);
		let control2 = clamp(end - (after - start) / 6.0, -limit, limit);
		let step = i as f64;
		ops.push(Op::CurveTo {
			control1: at((step + 1.0 / 3.0) / count, control1),
			control2: at((step + 2.0 / 3.0) / count, control2),
			end: at((step + 1.0) / count, end),
		});
	}
	ops
}

/// A line drawn twice: a full stroke and a lighter overlay pass.
pub(crate) fn double_line(x1: f64, y1: f64, x2: f64, y2: f64, config: &mut DrawConfig) -> Vec<Op> {
	let mut ops = line(x1, y1, x2, y2, config, true, false);
	ops.extend(line(x1, y1, x2, y2, config, true, true));
	ops
}

/// Fits a Catmull-Rom curve through `points`, drawn as pen `pass`.
pub(crate) fn curve(points: &[Point], config: &mut DrawConfig, pass: u32) -> Vec<Op> {
	match points.len() {
		0 | 1 => Vec::new(),
		2 => double_line(points[0].x, points[0].y, points[1].x, points[1].y, config),
		3 => vec![
			Op::Move {
				to: points[1],
				pass,
			},
			Op::CurveTo {
				control1: points[1],
				control2: points[2],
				end: points[2],
			},
		],
		len => {
			let s = 1.0 - config.options.curve_tightness;
			let mut ops = Vec::with_capacity(len - 2);
			ops.push(Op::Move {
				to: points[1],
				pass,
			});
			for i in 1..len - 2 {
				let (previous, p, next, after_next) =
					(points[i - 1], points[i], points[i + 1], points[i + 2]);
				ops.push(Op::CurveTo {
					control1: Point::new(
						p.x + (s * next.x - s * previous.x) / 6.0,
						p.y + (s * next.y - s * previous.y) / 6.0,
					),
					control2: Point::new(
						next.x + (s * p.x - s * after_next.x) / 6.0,
						next.y + (s * p.y - s * after_next.y) / 6.0,
					),
					end: next,
				});
			}
			ops
		}
	}
}

/// A curve through `points` after jittering each by up to `offset`.
fn curve_with_offset(points: &[Point], offset: f64, config: &mut DrawConfig, pass: u32) -> Vec<Op> {
	let (Some(&first), Some(&last)) = (points.first(), points.last()) else {
		return Vec::new();
	};
	let mut jitter = |p: Point| {
		Point::new(
			p.x + config.offset_symmetric(offset, 1.0),
			p.y + config.offset_symmetric(offset, 1.0),
		)
	};

	let mut jittered = Vec::with_capacity(points.len() + 2);
	jittered.push(jitter(first));
	jittered.extend(points.iter().map(|&p| jitter(p)));
	jittered.push(jitter(last));
	curve(&jittered, config, pass)
}

/// The jittered points of one pass around an elliptical arc.
fn arc_ops(
	increment: f64,
	center: Point,
	rx: f64,
	ry: f64,
	start: f64,
	stop: f64,
	offset: f64,
	config: &mut DrawConfig,
	pass: u32,
) -> Vec<Op> {
	let rad_offset = start + config.offset_symmetric(0.1, 1.0);
	let mut points = Vec::new();
	points.push(Point::new(
		config.offset_symmetric(offset, 1.0) + center.x + 0.9 * rx * (rad_offset - increment).cos(),
		config.offset_symmetric(offset, 1.0) + center.y + 0.9 * ry * (rad_offset - increment).sin(),
	));
	// An arc with no sweep has a zero step, which would never reach `stop`;
	// the other engines hang on it, so it draws only its end points here.
	let mut angle = rad_offset;
	while increment > 0.0 && angle <= stop {
		points.push(Point::new(
			config.offset_symmetric(offset, 1.0) + center.x + rx * angle.cos(),
			config.offset_symmetric(offset, 1.0) + center.y + ry * angle.sin(),
		));
		angle += increment;
	}
	let end = Point::new(center.x + rx * stop.cos(), center.y + ry * stop.sin());
	points.push(end);
	points.push(end);
	curve(&points, config, pass)
}

/// Radii and angular step for a rough ellipse.
#[derive(Debug, Clone, Copy, PartialEq)]
pub(crate) struct EllipseParams {
	pub(crate) rx: f64,
	pub(crate) ry: f64,
	pub(crate) increment: f64,
}

/// Radii and step size for a rough ellipse `width` by `height`.
pub(crate) fn ellipse_params(width: f64, height: f64, config: &mut DrawConfig) -> EllipseParams {
	let options = config.options;
	let half_width = width / 2.0;
	let half_height = height / 2.0;
	let psq =
		(PI * 2.0 * ((half_width * half_width + half_height * half_height) / 2.0).sqrt()).sqrt();
	let step_count = options
		.curve_step_count
		.max(options.curve_step_count / 200f64.sqrt() * psq);
	let increment = PI * 2.0 / step_count;
	let curve_fit_randomness = 1.0 - options.curve_fitting;

	let rx = (width / 2.0).abs();
	let ry = (height / 2.0).abs();
	let rx = rx + config.offset_symmetric(rx * curve_fit_randomness, 1.0);
	let ry = ry + config.offset_symmetric(ry * curve_fit_randomness, 1.0);
	EllipseParams { rx, ry, increment }
}

/// Jittered points around an ellipse, with the overlap that closes it.
pub(crate) fn ellipse_points(
	params: EllipseParams,
	center: Point,
	offset: f64,
	overlap: f64,
	config: &mut DrawConfig,
) -> Vec<Point> {
	let EllipseParams { rx, ry, increment } = params;
	let rad_offset = config.offset_symmetric(0.5, 1.0) - PI / 2.0;
	let mut jittered = |angle: f64, scale: f64| {
		Point::new(
			config.offset_symmetric(offset, 1.0) + center.x + scale * rx * angle.cos(),
			config.offset_symmetric(offset, 1.0) + center.y + scale * ry * angle.sin(),
		)
	};

	let mut points = vec![jittered(rad_offset - increment, 0.9)];
	let mut angle = rad_offset;
	while increment > 0.0 && angle < PI * 2.0 + rad_offset - 0.01 {
		points.push(jittered(angle, 1.0));
		angle += increment;
	}
	points.push(jittered(rad_offset + PI * 2.0 + overlap * 0.5, 1.0));
	points.push(jittered(rad_offset + overlap, 0.98));
	points.push(jittered(rad_offset + overlap * 0.5, 0.9));
	points
}

/// The two-pass outline of a rough ellipse centred on `center`.
pub(crate) fn ellipse_set(center: Point, params: EllipseParams, config: &mut DrawConfig) -> OpSet {
	// The inner draw comes first, as in `offset(0.1, offset(0.4, 1))`.
	let overlap_max = config.offset(0.4, 1.0, 1.0);
	let overlap = params.increment * config.offset(0.1, overlap_max, 1.0);
	let first = ellipse_points(params, center, 1.0, overlap, config);
	let second = ellipse_points(params, center, 1.5, 0.0, config);
	let mut ops = curve(&first, config, 0);
	ops.extend(curve(&second, config, 1));
	OpSet::path(ops)
}

/// A straight rough line.
pub(crate) fn line_set(x1: f64, y1: f64, x2: f64, y2: f64, config: &mut DrawConfig) -> OpSet {
	OpSet::path(double_line(x1, y1, x2, y2, config))
}

/// A rough ellipse `width` by `height` centred on `center`.
pub(crate) fn ellipse(center: Point, width: f64, height: f64, config: &mut DrawConfig) -> OpSet {
	let params = ellipse_params(width, height, config);
	ellipse_set(center, params, config)
}

/// Rough lines joining `points`, back to the first when `close` is set.
pub(crate) fn linear_path(points: &[Point], close: bool, config: &mut DrawConfig) -> OpSet {
	match points {
		[] | [_] => OpSet::path(Vec::new()),
		[a, b] => line_set(a.x, a.y, b.x, b.y, config),
		_ => {
			let mut ops = Vec::new();
			for pair in points.windows(2) {
				ops.extend(double_line(
					pair[0].x, pair[0].y, pair[1].x, pair[1].y, config,
				));
			}
			if close {
				let (first, last) = (points[0], points[points.len() - 1]);
				ops.extend(double_line(last.x, last.y, first.x, first.y, config));
			}
			OpSet::path(ops)
		}
	}
}

/// Normalises an arc's angles the way rough.js does: positive, and never
/// more than one full turn.
fn normalised_angles(start: f64, stop: f64) -> (f64, f64) {
	let (mut start, mut stop) = (start, stop);
	while start < 0.0 {
		start += TAU;
		stop += TAU;
	}
	if stop - start > TAU {
		(0.0, TAU)
	} else {
		(start, stop)
	}
}

/// The outline of an elliptical arc, as a pie slice when `closed`.
pub(crate) fn arc(
	center: Point,
	width: f64,
	height: f64,
	start: f64,
	stop: f64,
	closed: bool,
	rough_closure: bool,
	config: &mut DrawConfig,
) -> OpSet {
	let mut rx = (width / 2.0).abs();
	let mut ry = (height / 2.0).abs();
	rx += config.offset_symmetric(rx * 0.01, 1.0);
	ry += config.offset_symmetric(ry * 0.01, 1.0);
	let (start, stop) = normalised_angles(start, stop);
	let ellipse_increment = PI * 2.0 / config.options.curve_step_count;
	let increment = (ellipse_increment / 2.0).min((stop - start) / 2.0);

	let mut ops = arc_ops(increment, center, rx, ry, start, stop, 1.0, config, 0);
	ops.extend(arc_ops(
		increment, center, rx, ry, start, stop, 1.5, config, 1,
	));
	if closed {
		let start_point = Point::new(center.x + rx * start.cos(), center.y + ry * start.sin());
		if rough_closure {
			let stop_point = Point::new(center.x + rx * stop.cos(), center.y + ry * stop.sin());
			ops.extend(double_line(
				center.x,
				center.y,
				start_point.x,
				start_point.y,
				config,
			));
			ops.extend(double_line(
				center.x,
				center.y,
				stop_point.x,
				stop_point.y,
				config,
			));
		} else {
			ops.push(Op::LineTo(center));
			ops.push(Op::LineTo(start_point));
		}
	}
	OpSet::path(ops)
}

/// The polygon an arc's fill covers: points along the arc, then its centre.
pub(crate) fn arc_polygon(
	center: Point,
	width: f64,
	height: f64,
	start: f64,
	stop: f64,
	config: &mut DrawConfig,
) -> Vec<Point> {
	let mut rx = (width / 2.0).abs();
	let mut ry = (height / 2.0).abs();
	rx += config.offset_symmetric(rx * 0.01, 1.0);
	ry += config.offset_symmetric(ry * 0.01, 1.0);
	let (start, stop) = normalised_angles(start, stop);
	let ellipse_increment = PI * 2.0 / config.options.curve_step_count;
	let increment = (ellipse_increment / 2.0).min((stop - start) / 2.0);

	let mut points = Vec::new();
	let mut angle = start;
	while increment > 0.0 && angle <= stop {
		points.push(Point::new(
			center.x + rx * angle.cos(),
			center.y + ry * angle.sin(),
		));
		angle += increment;
	}
	points.push(Point::new(
		center.x + rx * stop.cos(),
		center.y + ry * stop.sin(),
	));
	points.push(center);
	points
}

/// A smooth curve through `points`, drawn twice.
pub(crate) fn curve_set(points: &[Point], config: &mut DrawConfig) -> OpSet {
	let roughness = config.options.roughness;
	let mut ops = curve_with_offset(points, 1.0 * (1.0 + roughness * 0.2), config, 0);
	ops.extend(curve_with_offset(
		points,
		1.5 * (1.0 + roughness * 0.2),
		config,
		1,
	));
	OpSet::path(ops)
}
