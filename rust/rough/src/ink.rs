//! Pen-shaped ink: rough centrelines turned into filled outlines with tapered
//! ends, pressure, and lighter repeat passes.

use std::f64::consts::PI;
use std::fmt::Write as _;

use crate::Drawable;
use crate::Op;
use crate::OpSetKind;
use crate::Randomizer;
use crate::RoughPen;
use crate::math::clamp;
use crate::math::dart_double_to_string;
use crate::math::format_number;

/// Receives the outline of an [`InkStroke`]: SVG path data, a canvas, or
/// anything else that speaks moves, lines, and quadratic curves.
pub trait InkOutlineSink {
	/// Starts a new contour at (`x`, `y`).
	fn move_to(&mut self, x: f64, y: f64);
	/// A straight segment to (`x`, `y`).
	fn line_to(&mut self, x: f64, y: f64);
	/// A quadratic Bézier segment through the control point (`cx`, `cy`).
	fn quadratic_to(&mut self, cx: f64, cy: f64, x: f64, y: f64);
	/// Closes the current contour.
	fn close(&mut self);
}

/// Writes an [`InkStroke`] outline as SVG path data with three decimals.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct SvgInkOutline {
	data: String,
}

impl SvgInkOutline {
	/// The accumulated path data.
	pub fn into_string(self) -> String {
		self.data
	}

	fn command(&mut self, command: char, values: &[f64]) {
		self.data.push(command);
		for (index, value) in values.iter().enumerate() {
			if index > 0 {
				self.data.push(' ');
			}
			self.data.push_str(&format_number(*value, 3));
		}
	}
}

impl InkOutlineSink for SvgInkOutline {
	fn move_to(&mut self, x: f64, y: f64) {
		self.command('M', &[x, y]);
	}

	fn line_to(&mut self, x: f64, y: f64) {
		self.command('L', &[x, y]);
	}

	fn quadratic_to(&mut self, cx: f64, cy: f64, x: f64, y: f64) {
		self.command('Q', &[cx, cy, x, y]);
	}

	fn close(&mut self) {
		self.data.push('Z');
	}
}

/// Writes an [`InkStroke`] outline as compact SVG path data, for drawings
/// that ship to a browser or over the air.
///
/// The pen samples a stroke every pen width or so, which keeps the taper
/// smooth but writes far more points than a screen can show. This sink drops
/// the samples that lie within `tolerance` of the line through their
/// neighbours, then draws through the rest with the same midpoint curves, and
/// writes two decimals with no spare spaces. The outline moves by at most
/// about `tolerance`; [`SvgInkOutline`] keeps every sample, for parity with
/// the other engines.
#[derive(Debug, Clone, PartialEq)]
pub struct CompactSvgInkOutline {
	tolerance: f64,
	commands: Vec<OutlineCommand>,
}

#[derive(Debug, Clone, Copy, PartialEq)]
enum OutlineCommand {
	Move(f64, f64),
	Line(f64, f64),
	Quadratic(f64, f64, f64, f64),
	Close,
}

impl CompactSvgInkOutline {
	/// A sink that keeps the outline within `tolerance` of the pen's samples.
	/// A tolerance of zero, or one that isn't finite, keeps every sample.
	pub fn new(tolerance: f64) -> Self {
		Self {
			tolerance: if tolerance.is_finite() {
				tolerance.max(0.0)
			} else {
				0.0
			},
			commands: Vec::new(),
		}
	}

	/// The compacted path data.
	pub fn into_string(self) -> String {
		let mut data = String::new();
		let commands = &self.commands;
		let mut index = 0;
		while index < commands.len() {
			// A smoothed side is a line to its first sample, a curve through
			// each sample with the midpoint after it as its end, and a line to
			// its last sample. Its samples are the line ends and the controls.
			if let OutlineCommand::Line(x, y) = commands[index] {
				let mut end = index + 1;
				let mut samples = vec![(x, y)];
				while let Some(OutlineCommand::Quadratic(cx, cy, ..)) = commands.get(end) {
					samples.push((*cx, *cy));
					end += 1;
				}
				if end > index + 1
					&& let Some(OutlineCommand::Line(lx, ly)) = commands.get(end)
				{
					samples.push((*lx, *ly));
					let kept = simplify(&samples, self.tolerance);
					write_command(&mut data, 'L', &[kept[0].0, kept[0].1]);
					for pair in kept[1..].windows(2) {
						let ((x, y), (next_x, next_y)) = (pair[0], pair[1]);
						write_command(
							&mut data,
							'Q',
							&[x, y, (x + next_x) / 2.0, (y + next_y) / 2.0],
						);
					}
					let (last_x, last_y) = kept[kept.len() - 1];
					write_command(&mut data, 'L', &[last_x, last_y]);
					index = end + 1;
					continue;
				}
			}
			match commands[index] {
				OutlineCommand::Move(x, y) => write_command(&mut data, 'M', &[x, y]),
				OutlineCommand::Line(x, y) => write_command(&mut data, 'L', &[x, y]),
				OutlineCommand::Quadratic(cx, cy, x, y) => {
					write_command(&mut data, 'Q', &[cx, cy, x, y]);
				}
				OutlineCommand::Close => data.push('Z'),
			}
			index += 1;
		}
		data
	}
}

impl Default for CompactSvgInkOutline {
	/// A quarter of a logical pixel: invisible at any zoom a screen uses.
	fn default() -> Self {
		Self::new(0.25)
	}
}

impl InkOutlineSink for CompactSvgInkOutline {
	fn move_to(&mut self, x: f64, y: f64) {
		self.commands.push(OutlineCommand::Move(x, y));
	}

	fn line_to(&mut self, x: f64, y: f64) {
		self.commands.push(OutlineCommand::Line(x, y));
	}

	fn quadratic_to(&mut self, cx: f64, cy: f64, x: f64, y: f64) {
		self.commands.push(OutlineCommand::Quadratic(cx, cy, x, y));
	}

	fn close(&mut self) {
		self.commands.push(OutlineCommand::Close);
	}
}

/// Appends `command` and its values with two decimals, separated only
/// where a value doesn't already start with a minus sign.
fn write_command(data: &mut String, command: char, values: &[f64]) {
	data.push(command);
	for (index, value) in values.iter().enumerate() {
		let number = format_number(*value, 2);
		if index > 0 && !number.starts_with('-') {
			data.push(' ');
		}
		data.push_str(&number);
	}
}

/// The points of `polyline` that keep every dropped point within `tolerance`
/// of the line between the points kept on either side of it
/// (Ramer–Douglas–Peucker). The first and last points always stay.
fn simplify(polyline: &[(f64, f64)], tolerance: f64) -> Vec<(f64, f64)> {
	if polyline.len() < 3 || tolerance <= 0.0 {
		return polyline.to_vec();
	}
	let mut keep = vec![false; polyline.len()];
	keep[0] = true;
	keep[polyline.len() - 1] = true;
	let mut spans = vec![(0, polyline.len() - 1)];
	while let Some((first, last)) = spans.pop() {
		let (ax, ay) = polyline[first];
		let (bx, by) = polyline[last];
		let (dx, dy) = (bx - ax, by - ay);
		let length = dx.hypot(dy);
		let mut farthest = (0.0, first);
		for (index, &(px, py)) in polyline.iter().enumerate().take(last).skip(first + 1) {
			let distance = if length == 0.0 {
				(px - ax).hypot(py - ay)
			} else {
				((px - ax) * dy - (py - ay) * dx).abs() / length
			};
			if distance > farthest.0 {
				farthest = (distance, index);
			}
		}
		if farthest.0 > tolerance {
			keep[farthest.1] = true;
			spans.push((first, farthest.1));
			spans.push((farthest.1, last));
		}
	}
	polyline
		.iter()
		.zip(keep)
		.filter_map(|(point, kept)| kept.then_some(*point))
		.collect()
}

/// How one [`InkStroke`] is laid down.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct InkStrokeOptions {
	/// Full ink width.
	pub width: f64,
	/// How ink leaves the pen.
	pub pen: RoughPen,
	/// Chooses loop starts and pressure phase.
	pub seed: i64,
	/// Scales this stroke relative to `width`.
	pub weight: f64,
	/// Share of each contour to ink, from 0.05 to 1.
	pub coverage: f64,
}

impl InkStrokeOptions {
	/// A full-coverage stroke `width` wide drawn with `pen`, seeded with 1.
	pub fn new(width: f64, pen: RoughPen) -> Self {
		Self {
			width,
			pen,
			seed: 1,
			weight: 1.0,
			coverage: 1.0,
		}
	}
}

/// One pen stroke along rough centreline geometry, sampled once.
///
/// The operations are flattened and resampled at a spacing tied to the pen
/// width, then each sample gets a width from the [`RoughPen`].
/// [`InkStroke::write_outline`] turns the samples into a filled shape,
/// completely or up to a distance for draw-on animation, without sampling
/// again.
#[derive(Debug, Clone, PartialEq)]
pub struct InkStroke {
	contours: Vec<InkContour>,
	length: f64,
}

impl InkStroke {
	/// Samples `ops` as one stroke.
	pub fn new(ops: &[Op], options: InkStrokeOptions) -> Self {
		let mut random = Randomizer::new(options.seed);
		let width = options.width * options.weight;
		let coverage = clamp(options.coverage, 0.05, 1.0);
		let contours: Vec<InkContour> = flatten(ops)
			.iter()
			.filter_map(|polyline| {
				InkContour::sample(polyline, width, options.pen, &mut random, coverage)
			})
			.collect();
		let length = contours.iter().map(InkContour::length).sum();
		Self { contours, length }
	}

	/// Total distance the pen travels, including loop closures.
	pub fn length(&self) -> f64 {
		self.length
	}

	/// The outline of the whole stroke as SVG path data, to be filled.
	pub fn svg_path_data(&self) -> String {
		let mut sink = SvgInkOutline::default();
		self.write_outline(&mut sink, f64::INFINITY);
		sink.into_string()
	}

	/// The outline of the whole stroke as compact SVG path data, within
	/// `tolerance` of [`InkStroke::svg_path_data`]: see
	/// [`CompactSvgInkOutline`].
	pub fn compact_svg_path_data(&self, tolerance: f64) -> String {
		let mut sink = CompactSvgInkOutline::new(tolerance);
		self.write_outline(&mut sink, f64::INFINITY);
		sink.into_string()
	}

	/// Writes the filled outline of the first `distance` the pen travels.
	/// Pass [`f64::INFINITY`] for the whole stroke. A cut end is round and
	/// keeps the width it had at that point, like a pen still on the paper.
	pub fn write_outline(&self, sink: &mut impl InkOutlineSink, distance: f64) {
		let mut remaining = distance;
		for contour in &self.contours {
			if remaining <= 0.0 {
				break;
			}
			contour.write(sink, remaining);
			remaining -= contour.length();
		}
	}
}

/// A flattened contour with the distance travelled at each point.
#[derive(Debug, Clone, Default)]
struct Polyline {
	xs: Vec<f64>,
	ys: Vec<f64>,
	distances: Vec<f64>,
}

impl Polyline {
	fn starting_at(x: f64, y: f64) -> Self {
		Self {
			xs: vec![x],
			ys: vec![y],
			distances: vec![0.0],
		}
	}

	fn length(&self) -> f64 {
		self.distances.last().copied().unwrap_or(0.0)
	}

	fn is_empty(&self) -> bool {
		self.xs.len() < 2 || self.length() == 0.0
	}

	fn last_point(&self) -> (f64, f64) {
		(self.xs[self.xs.len() - 1], self.ys[self.ys.len() - 1])
	}

	fn add(&mut self, x: f64, y: f64) {
		let (px, py) = self.last_point();
		let step = distance_between(px, py, x, y);
		if step < 1e-6 {
			return;
		}
		self.xs.push(x);
		self.ys.push(y);
		self.distances.push(self.length() + step);
	}

	/// The point `distance` along the polyline, by binary search.
	fn at(&self, distance: f64) -> (f64, f64) {
		let Self { xs, ys, distances } = self;
		let d = clamp(distance, 0.0, self.length());
		let mut low = 0;
		let mut high = distances.len() - 1;
		while high - low > 1 {
			let mid = (low + high) >> 1;
			if distances[mid] <= d {
				low = mid;
			} else {
				high = mid;
			}
		}
		let span = distances[high] - distances[low];
		let t = if span == 0.0 {
			0.0
		} else {
			(d - distances[low]) / span
		};
		(
			xs[low] + (xs[high] - xs[low]) * t,
			ys[low] + (ys[high] - ys[low]) * t,
		)
	}
}

/// Walks forward along a polyline, resuming from the last segment.
struct PolylineWalker<'a> {
	polyline: &'a Polyline,
	segment: usize,
}

impl PolylineWalker<'_> {
	fn point_at(&mut self, distance: f64) -> (f64, f64) {
		let Polyline { xs, ys, distances } = self.polyline;
		let last = distances.len() - 1;
		let d = clamp(distance, 0.0, self.polyline.length());
		if d < distances[self.segment] {
			self.segment = 0;
		}
		while self.segment < last - 1 && distances[self.segment + 1] < d {
			self.segment += 1;
		}
		let s = self.segment;
		let from = distances[s];
		let span = distances[s + 1] - from;
		let t = if span == 0.0 { 0.0 } else { (d - from) / span };
		(
			xs[s] + (xs[s + 1] - xs[s]) * t,
			ys[s] + (ys[s + 1] - ys[s]) * t,
		)
	}
}

fn distance_between(x0: f64, y0: f64, x1: f64, y1: f64) -> f64 {
	let dx = x1 - x0;
	let dy = y1 - y0;
	(dx * dx + dy * dy).sqrt()
}

/// Splits `ops` into contours and flattens their curves into polylines.
fn flatten(ops: &[Op]) -> Vec<Polyline> {
	let mut result = Vec::new();
	let mut current: Option<Polyline> = None;
	let finish = |polyline: Option<Polyline>, result: &mut Vec<Polyline>| {
		if let Some(polyline) = polyline
			&& polyline.xs.len() > 1
			&& polyline.length() > 0.0
		{
			result.push(polyline);
		}
	};

	for op in ops {
		match *op {
			Op::Move { to, .. } => {
				finish(current.take(), &mut result);
				current = Some(Polyline::starting_at(to.x, to.y));
			}
			Op::LineTo(to) => match current.as_mut() {
				Some(polyline) => polyline.add(to.x, to.y),
				None => current = Some(Polyline::starting_at(to.x, to.y)),
			},
			Op::CurveTo {
				control1: c1,
				control2: c2,
				end,
			} => {
				let Some(polyline) = current.as_mut() else {
					current = Some(Polyline::starting_at(end.x, end.y));
					continue;
				};
				let (x0, y0) = polyline.last_point();
				// The control polygon bounds the curve's length. A segment every
				// two units stays within a hair of the gentle bends rough
				// geometry makes, and resampling smooths the tangents.
				let hull = distance_between(x0, y0, c1.x, c1.y)
					+ distance_between(c1.x, c1.y, c2.x, c2.y)
					+ distance_between(c2.x, c2.y, end.x, end.y);
				let segments = clamp((hull / 2.0).ceil(), 2.0, 64.0) as usize;
				for i in 1..=segments {
					let t = i as f64 / segments as f64;
					let u = 1.0 - t;
					let a = u * u * u;
					let b = 3.0 * u * u * t;
					let c = 3.0 * u * t * t;
					let d = t * t * t;
					polyline.add(
						a * x0 + b * c1.x + c * c2.x + d * end.x,
						a * y0 + b * c1.y + c * c2.y + d * end.y,
					);
				}
			}
		}
	}
	finish(current, &mut result);
	result
}

fn ease_out(t: f64) -> f64 {
	1.0 - (1.0 - t) * (1.0 - t)
}

/// One sampled contour: positions, unit normals, and the ink's half-width at
/// each sample.
#[derive(Debug, Clone, PartialEq)]
struct InkContour {
	xs: Vec<f64>,
	ys: Vec<f64>,
	nxs: Vec<f64>,
	nys: Vec<f64>,
	radii: Vec<f64>,
	distances: Vec<f64>,
}

impl InkContour {
	fn length(&self) -> f64 {
		self.distances[self.distances.len() - 1]
	}

	fn sample(
		polyline: &Polyline,
		width: f64,
		pen: RoughPen,
		random: &mut Randomizer,
		coverage: f64,
	) -> Option<Self> {
		if polyline.is_empty() || !width.is_finite() || width <= 0.0 {
			return None;
		}

		let contour_length = polyline.length();
		// Ink is sampled along the contour's length, so an infinite or NaN
		// one has no samples to take.
		if !contour_length.is_finite() {
			return None;
		}
		let (start_x, start_y) = (polyline.xs[0], polyline.ys[0]);
		let (end_x, end_y) = polyline.last_point();
		let start_to_end = distance_between(start_x, start_y, end_x, end_y);

		// A loop whose ends meet keeps going a little past its start. Its start
		// moves to a seeded point so the seam is not always at the same corner.
		let closed = contour_length > width * 4.0 && start_to_end < width;
		let partial = coverage < 1.0;
		let drawn = if partial {
			contour_length * coverage * (0.75 + 0.25 * random.next_double())
		} else {
			contour_length
		};
		let from = if closed {
			random.next_double() * contour_length
		} else if partial {
			random.next_double() * (contour_length - drawn)
		} else {
			0.0
		};
		let closing = if closed && !partial {
			pen.closure.max(0.0) * width
		} else {
			0.0
		};
		let total = drawn + closing;
		// The closing tail curls inward, and less on small loops, so it never
		// reaches past the outline painters reserve room for.
		let drift = if closing > 0.0 {
			pen.closure_drift.abs()
				* width * (contour_length / (60.0 * width)).min(1.0)
				* inward_sign(polyline, from)
		} else {
			0.0
		};

		let step = clamp(width * 0.8, 0.4, 3.0);
		let count = (total / step).ceil().max(1.0) as usize;
		let taper_in = (total * 0.3).min(pen.taper_in.max(0.0) * width);
		let taper_out = (total * 0.4).min(pen.taper_out.max(0.0) * width);
		let start_width = clamp(pen.start_width, 0.05, 1.0);
		let end_width = clamp(pen.end_width, 0.05, 1.0);
		let pressure = clamp(pen.pressure, 0.0, 1.0);
		let wavelength = pen.pressure_wavelength.max(1.0);
		let phase1 = random.next_double() * PI * 2.0;
		let phase2 = random.next_double() * PI * 2.0;

		// Positions first, in one forward walk along the polyline.
		let mut xs = Vec::with_capacity(count + 1);
		let mut ys = Vec::with_capacity(count + 1);
		let mut distances = Vec::with_capacity(count + 1);
		let mut walker = PolylineWalker {
			polyline,
			segment: 0,
		};
		for i in 0..=count {
			let travelled = total * i as f64 / count as f64;
			let mut at = from + travelled;
			if closed {
				at = dart_modulo(at, contour_length);
			}
			let (x, y) = walker.point_at(at);
			xs.push(x);
			ys.push(y);
			distances.push(travelled);
		}

		// Tangents from neighbouring samples smooth the flattening without
		// rounding off real corners. Widths come from the pen.
		let mut nxs = Vec::with_capacity(count + 1);
		let mut nys = Vec::with_capacity(count + 1);
		let mut radii = Vec::with_capacity(count + 1);
		let (mut tx, mut ty) = (1.0, 0.0);
		for (i, &travelled) in distances.iter().enumerate() {
			let before = i.saturating_sub(1);
			let after = (i + 1).min(count);
			let dx = xs[after] - xs[before];
			let dy = ys[after] - ys[before];
			let tangent_length = (dx * dx + dy * dy).sqrt();
			if tangent_length > 1e-9 {
				tx = dx / tangent_length;
				ty = dy / tangent_length;
			}
			nxs.push(-ty);
			nys.push(tx);

			let mut factor = 1.0;
			if taper_in > 0.0 && travelled < taper_in {
				factor *= start_width + (1.0 - start_width) * ease_out(travelled / taper_in);
			}
			let to_end = total - travelled;
			if taper_out > 0.0 && to_end < taper_out {
				factor *= end_width + (1.0 - end_width) * ease_out(to_end / taper_out);
			}
			if pressure > 0.0 {
				let cycle = travelled / wavelength * PI * 2.0;
				factor *= 1.0
					+ pressure
						* (0.65 * (cycle + phase1).sin() + 0.35 * (cycle * 2.7 + phase2).sin());
			}
			radii.push((factor * width).max(0.1) / 2.0);
		}

		// The closing stretch eases off the line it is retracing.
		if closing > 0.0 {
			for (i, &travelled) in distances.iter().enumerate() {
				if travelled <= drawn {
					continue;
				}
				let off = drift * ease_out((travelled - drawn) / closing);
				xs[i] += nxs[i] * off;
				ys[i] += nys[i] * off;
			}
		}

		Some(Self {
			xs,
			ys,
			nxs,
			nys,
			radii,
			distances,
		})
	}

	/// Writes the outline of this contour, cut at `distance` when shorter.
	fn write(&self, sink: &mut impl InkOutlineSink, distance: f64) {
		let Self {
			xs,
			ys,
			nxs,
			nys,
			radii,
			distances,
		} = self;
		let mut last = xs.len() - 1;
		let mut cut = 1.0;
		if distance < self.length() {
			last = 1;
			while last < distances.len() - 1 && distances[last] < distance {
				last += 1;
			}
			let span = distances[last] - distances[last - 1];
			cut = if span == 0.0 {
				1.0
			} else {
				(distance - distances[last - 1]) / span
			};
		}

		let value = |values: &[f64], i: usize| {
			if i == last {
				values[i - 1] + (values[i] - values[i - 1]) * cut
			} else {
				values[i]
			}
		};

		let mut left_x = Vec::with_capacity(last + 1);
		let mut left_y = Vec::with_capacity(last + 1);
		let mut right_x = Vec::with_capacity(last + 1);
		let mut right_y = Vec::with_capacity(last + 1);
		let mut previous_nx = nxs[0];
		let mut previous_ny = nys[0];
		for i in 0..=last {
			let x = value(xs, i);
			let y = value(ys, i);
			let nx = value(nxs, i);
			let ny = value(nys, i);
			let r = value(radii, i);
			// A sharp turn between samples leaves a notch on its outer side.
			// Sweep that side around the corner so the joint stays round.
			let dot = previous_nx * nx + previous_ny * ny;
			if i > 0 && dot < 0.82 {
				let angle = (previous_nx * ny - previous_ny * nx).atan2(dot);
				let steps = (angle.abs() / 0.35).ceil() as usize;
				let (outer_x, outer_y, sign) = if angle > 0.0 {
					(&mut right_x, &mut right_y, -1.0)
				} else {
					(&mut left_x, &mut left_y, 1.0)
				};
				let base = previous_ny.atan2(previous_nx);
				for s in 1..steps {
					let a = base + angle * s as f64 / steps as f64;
					outer_x.push(x + sign * a.cos() * r);
					outer_y.push(y + sign * a.sin() * r);
				}
			}
			left_x.push(x + nx * r);
			left_y.push(y + ny * r);
			right_x.push(x - nx * r);
			right_y.push(y - ny * r);
			previous_nx = nx;
			previous_ny = ny;
		}

		sink.move_to(left_x[0], left_y[0]);
		smooth(sink, &left_x, &left_y, false);
		cap(
			sink,
			[value(xs, last), value(ys, last)],
			[value(nxs, last), value(nys, last)],
			value(radii, last),
			true,
		);
		smooth(sink, &right_x, &right_y, true);
		cap(sink, [xs[0], ys[0]], [nxs[0], nys[0]], radii[0], false);
		sink.close();
	}
}

/// Dart's `%` on doubles: the result takes the divisor's sign.
fn dart_modulo(a: f64, b: f64) -> f64 {
	let r = a % b;
	if r < 0.0 { r + b.abs() } else { r }
}

/// `1` when the normal at `distance` points into the loop, otherwise `-1`.
fn inward_sign(polyline: &Polyline, distance: f64) -> f64 {
	let count = polyline.xs.len() as f64;
	let cx = polyline.xs.iter().sum::<f64>() / count;
	let cy = polyline.ys.iter().sum::<f64>() / count;
	let (x, y) = polyline.at(distance);
	let (ax, ay) = polyline.at((distance + 1.0).min(polyline.length()));
	let (bx, by) = polyline.at((distance - 1.0).max(0.0));
	let nx = -(ay - by);
	let ny = ax - bx;
	if nx * (cx - x) + ny * (cy - y) >= 0.0 {
		1.0
	} else {
		-1.0
	}
}

/// Draws through the midpoints of the points with each point as a control,
/// which keeps the edge smooth between samples.
fn smooth(sink: &mut impl InkOutlineSink, xs: &[f64], ys: &[f64], reversed: bool) {
	let n = xs.len();
	let at = |i: usize| if reversed { n - 1 - i } else { i };
	sink.line_to(xs[at(0)], ys[at(0)]);
	for i in 1..n.saturating_sub(1) {
		let here = at(i);
		let next = at(i + 1);
		sink.quadratic_to(
			xs[here],
			ys[here],
			(xs[here] + xs[next]) / 2.0,
			(ys[here] + ys[next]) / 2.0,
		);
	}
	sink.line_to(xs[at(n - 1)], ys[at(n - 1)]);
}

/// A half circle from one side of the stroke to the other, bulging along the
/// direction of travel at the end and against it at the start.
fn cap(
	sink: &mut impl InkOutlineSink,
	[x, y]: [f64; 2],
	[nx, ny]: [f64; 2],
	radius: f64,
	forward: bool,
) {
	let (fx, fy) = if forward { (nx, ny) } else { (-nx, -ny) };
	let (ax, ay) = if forward { (ny, -nx) } else { (-ny, nx) };
	let steps = 6;
	for i in 1..=steps {
		let angle = PI * f64::from(i) / f64::from(steps);
		let (s, c) = angle.sin_cos();
		sink.line_to(
			x + (fx * c + ax * s) * radius,
			y + (fy * c + ay * s) * radius,
		);
	}
}

/// One SVG `<path>` of exported ink.
#[derive(Debug, Clone, PartialEq)]
pub struct InkSvgPath {
	/// Which part of the drawing this path came from.
	pub kind: OpSetKind,
	/// The SVG `d` attribute.
	pub data: String,
	/// Whether `data` is filled; otherwise it is stroked.
	pub filled: bool,
	/// The stroke width when not filled; zero for fills.
	pub stroke_width: f64,
}

/// The prepared ink for one op set.
#[derive(Debug, Clone, PartialEq)]
pub struct DrawableInkSet {
	/// Which part of the drawing this set is.
	pub kind: OpSetKind,
	/// The rough centreline or fill polygon.
	pub ops: Vec<Op>,
	/// The pen width for this set.
	pub width: f64,
	/// Pen strokes, one per contour, or `None` when the set keeps a plain
	/// centreline (uniform pens, solid fills, or ink turned off).
	pub strokes: Option<Vec<InkStroke>>,
}

impl DrawableInkSet {
	/// This set as SVG paths.
	pub fn svg_paths(&self) -> Vec<InkSvgPath> {
		self.paths(None)
	}

	/// This set as compact SVG paths, within `tolerance` of
	/// [`DrawableInkSet::svg_paths`]: pen strokes go through
	/// [`CompactSvgInkOutline`] and centrelines keep two decimals.
	pub fn compact_svg_paths(&self, tolerance: f64) -> Vec<InkSvgPath> {
		self.paths(Some(tolerance))
	}

	fn paths(&self, compact: Option<f64>) -> Vec<InkSvgPath> {
		if let Some(strokes) = &self.strokes {
			return strokes
				.iter()
				.map(|stroke| InkSvgPath {
					kind: self.kind,
					data: match compact {
						Some(tolerance) => stroke.compact_svg_path_data(tolerance),
						None => stroke.svg_path_data(),
					},
					filled: true,
					stroke_width: 0.0,
				})
				.collect();
		}
		if self.ops.is_empty() {
			return Vec::new();
		}

		let filled = self.kind == OpSetKind::FillPath;
		if compact.is_some() {
			let mut data = String::new();
			for op in &self.ops {
				let values = op
					.points()
					.flat_map(|point| [point.x, point.y])
					.collect::<Vec<_>>();
				write_command(&mut data, op.command(), &values);
			}
			if filled {
				data.push('Z');
			}
			return vec![InkSvgPath {
				kind: self.kind,
				data,
				filled,
				stroke_width: if filled { 0.0 } else { self.width },
			}];
		}

		let mut data = String::new();
		for op in &self.ops {
			data.push(op.command());
			for (index, point) in op.points().enumerate() {
				if index > 0 {
					data.push(' ');
				}
				let _ = write!(
					data,
					"{} {}",
					dart_double_to_string(point.x),
					dart_double_to_string(point.y)
				);
			}
			data.push(' ');
		}
		let mut data = data.trim_end().to_owned();
		if filled {
			data.push_str(" Z");
		}
		vec![InkSvgPath {
			kind: self.kind,
			data,
			filled,
			stroke_width: if filled { 0.0 } else { self.width },
		}]
	}
}

/// Which parts of a drawable are inked with the pen.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct DrawableInkOptions {
	/// Pen width for outlines.
	pub outline_width: f64,
	/// Pen width for sketched fills.
	pub sketch_width: f64,
	/// Ink outlines with the pen.
	pub ink_outline: bool,
	/// Ink sketched fills with the pen.
	pub ink_sketch: bool,
	/// Ink every part as a filled outline even when the pen is uniform, which
	/// would otherwise keep a cheaper plain centreline.
	pub ink_uniform: bool,
}

impl DrawableInkOptions {
	/// Inks outlines `outline_width` wide and sketched fills `sketch_width`
	/// wide.
	pub fn new(outline_width: f64, sketch_width: f64) -> Self {
		Self {
			outline_width,
			sketch_width,
			ink_outline: true,
			ink_sketch: true,
			ink_uniform: false,
		}
	}
}

/// The ink a [`Drawable`] lays down, prepared once.
///
/// Splits each op set into contours and gives every contour an [`InkStroke`]
/// from the drawable's [`RoughPen`], with repeat passes lighter and partial.
/// Matches `DrawableInk` in Dart, so exported ink is the ink skribble paints.
#[derive(Debug, Clone, PartialEq)]
pub struct DrawableInk {
	/// One entry per op set, in the drawable's order.
	pub sets: Vec<DrawableInkSet>,
}

impl DrawableInk {
	/// Prepares the ink for `drawable`.
	pub fn new(drawable: &Drawable, options: DrawableInkOptions) -> Self {
		let pen = drawable.pen;
		let mut index: i64 = 0;
		let sets = drawable
			.sets
			.iter()
			.map(|set| {
				let (width, wanted) = match set.kind {
					OpSetKind::Path => (options.outline_width, options.ink_outline),
					OpSetKind::FillSketch => (options.sketch_width, options.ink_sketch),
					OpSetKind::FillPath => (options.sketch_width, false),
				};
				let inked = (options.ink_uniform || !pen.is_uniform()) && width > 0.0 && wanted;
				let strokes = inked.then(|| {
					split_contours(&set.ops)
						.into_iter()
						.map(|(contour, pass)| {
							let seed = drawable.seed.wrapping_mul(7919).wrapping_add(index);
							index += 1;
							let repeat = pass != 0;
							InkStroke::new(
								contour,
								InkStrokeOptions {
									width,
									pen,
									seed,
									weight: if repeat { pen.repeat_width } else { 1.0 },
									coverage: if repeat { pen.repeat_coverage } else { 1.0 },
								},
							)
						})
						.collect()
				});
				DrawableInkSet {
					kind: set.kind,
					ops: set.ops.clone(),
					width,
					strokes,
				}
			})
			.collect();
		Self { sets }
	}

	/// The ink as SVG paths, in paint order: solid fills, sketched fills, then
	/// outlines.
	pub fn svg_paths(&self) -> Vec<InkSvgPath> {
		self.paths(None)
	}

	/// The ink as compact SVG paths, in paint order, within `tolerance` of
	/// [`DrawableInk::svg_paths`]. See [`DrawableInkSet::compact_svg_paths`].
	pub fn compact_svg_paths(&self, tolerance: f64) -> Vec<InkSvgPath> {
		self.paths(Some(tolerance))
	}

	fn paths(&self, compact: Option<f64>) -> Vec<InkSvgPath> {
		[OpSetKind::FillPath, OpSetKind::FillSketch, OpSetKind::Path]
			.into_iter()
			.flat_map(|kind| {
				self.sets
					.iter()
					.filter(move |set| set.kind == kind)
					.flat_map(move |set| set.paths(compact))
			})
			.collect()
	}
}

/// Splits operations into contours, with the pass that drew each.
fn split_contours(ops: &[Op]) -> Vec<(&[Op], u32)> {
	let mut contours = Vec::new();
	let mut start = 0;
	let mut pass = 0;
	for (index, op) in ops.iter().enumerate() {
		if let Op::Move { pass: next, .. } = *op {
			if index > start {
				contours.push((&ops[start..index], pass));
			}
			start = index;
			pass = next;
		}
	}
	if start < ops.len() {
		contours.push((&ops[start..], pass));
	}
	contours
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::Point;

	fn square() -> Vec<Op> {
		vec![
			Op::move_to(Point::new(0.0, 0.0)),
			Op::LineTo(Point::new(40.0, 0.0)),
			Op::LineTo(Point::new(40.0, 40.0)),
			Op::LineTo(Point::new(0.0, 40.0)),
			Op::LineTo(Point::new(0.0, 0.0)),
		]
	}

	#[test]
	fn closed_loops_travel_past_their_start() {
		let stroke = InkStroke::new(&square(), InkStrokeOptions::new(2.0, RoughPen::INK));
		assert!(
			stroke.length() > 160.0,
			"{} is not past 160",
			stroke.length()
		);
	}

	#[test]
	fn a_partial_outline_is_shorter_than_the_whole() {
		let stroke = InkStroke::new(&square(), InkStrokeOptions::new(2.0, RoughPen::INK));
		let mut whole = SvgInkOutline::default();
		stroke.write_outline(&mut whole, f64::INFINITY);
		let mut half = SvgInkOutline::default();
		stroke.write_outline(&mut half, stroke.length() / 2.0);
		assert!(half.into_string().len() < whole.into_string().len());
	}

	#[test]
	fn contours_split_at_every_move() {
		let ops = [
			Op::move_to(Point::new(0.0, 0.0)),
			Op::LineTo(Point::new(1.0, 1.0)),
			Op::Move {
				to: Point::new(2.0, 2.0),
				pass: 1,
			},
			Op::LineTo(Point::new(3.0, 3.0)),
		];
		let contours = split_contours(&ops);
		assert_eq!(contours.len(), 2);
		assert_eq!(contours[0].1, 0);
		assert_eq!(contours[1].1, 1);
	}

	fn count(data: &str, command: char) -> usize {
		data.chars().filter(|c| *c == command).count()
	}

	/// Every number in `data`, in order.
	fn numbers(data: &str) -> Vec<f64> {
		let mut out = Vec::new();
		let mut current = String::new();
		for c in data.chars() {
			if c.is_ascii_digit() || c == '.' || (c == '-' && current.is_empty()) {
				current.push(c);
			} else {
				if !current.is_empty() {
					out.push(current.parse().unwrap());
					current.clear();
				}
				if c == '-' {
					current.push(c);
				}
			}
		}
		if !current.is_empty() {
			out.push(current.parse().unwrap());
		}
		out
	}

	fn curve() -> Vec<Op> {
		vec![
			Op::move_to(Point::new(0.0, 20.0)),
			Op::CurveTo {
				control1: Point::new(30.0, -10.0),
				control2: Point::new(70.0, 50.0),
				end: Point::new(100.0, 20.0),
			},
		]
	}

	#[test]
	fn compact_ink_keeps_far_fewer_samples_than_exact_ink() {
		let stroke = InkStroke::new(&curve(), InkStrokeOptions::new(2.0, RoughPen::INK));
		let exact = stroke.svg_path_data();
		let compact = stroke.compact_svg_path_data(0.25);
		assert!(
			compact.len() * 3 < exact.len(),
			"{} vs {}",
			compact.len(),
			exact.len()
		);
		assert!(count(&compact, 'Q') * 3 < count(&exact, 'Q'));
		// The contour still starts, closes, and caps the same way.
		assert!(compact.starts_with('M'));
		assert!(compact.ends_with('Z'));
		assert_eq!(count(&compact, 'M'), count(&exact, 'M'));
		assert_eq!(count(&compact, 'Z'), count(&exact, 'Z'));
	}

	#[test]
	fn compact_ink_stays_inside_the_exact_outline_box() {
		let stroke = InkStroke::new(&curve(), InkStrokeOptions::new(3.0, RoughPen::BRUSH));
		let bounds = |data: &str| {
			let values = numbers(data);
			let xs = values.iter().step_by(2).copied().collect::<Vec<_>>();
			let ys = values
				.iter()
				.skip(1)
				.step_by(2)
				.copied()
				.collect::<Vec<_>>();
			(
				xs.iter().copied().fold(f64::INFINITY, f64::min),
				xs.iter().copied().fold(f64::NEG_INFINITY, f64::max),
				ys.iter().copied().fold(f64::INFINITY, f64::min),
				ys.iter().copied().fold(f64::NEG_INFINITY, f64::max),
			)
		};
		let exact = bounds(&stroke.svg_path_data());
		let compact = bounds(&stroke.compact_svg_path_data(0.25));
		for (a, b) in [
			(exact.0, compact.0),
			(exact.1, compact.1),
			(exact.2, compact.2),
			(exact.3, compact.3),
		] {
			assert!((a - b).abs() <= 0.26, "{a} vs {b}");
		}
	}

	#[test]
	fn zero_or_unusable_tolerance_keeps_every_sample() {
		let stroke = InkStroke::new(&curve(), InkStrokeOptions::new(2.0, RoughPen::INK));
		let exact = count(&stroke.svg_path_data(), 'Q');
		for tolerance in [0.0, -1.0, f64::NAN, f64::INFINITY] {
			let kept = count(&stroke.compact_svg_path_data(tolerance), 'Q');
			assert_eq!(kept, exact, "tolerance {tolerance}");
		}
	}

	#[test]
	fn the_default_compact_sink_allows_a_quarter_pixel() {
		assert_eq!(
			CompactSvgInkOutline::default(),
			CompactSvgInkOutline::new(0.25)
		);
	}

	#[test]
	fn commands_outside_a_smoothed_side_pass_through() {
		let mut sink = CompactSvgInkOutline::new(1.0);
		sink.move_to(0.0, 0.0);
		sink.quadratic_to(1.0, 1.0, 2.0, -2.5);
		sink.line_to(3.0, 3.0);
		sink.line_to(-4.125, 5.0);
		sink.close();
		assert_eq!(sink.into_string(), "M0 0Q1 1 2-2.5L3 3L-4.13 5Z");
	}

	#[test]
	fn a_line_with_no_curves_after_it_is_written_as_it_is() {
		let mut sink = CompactSvgInkOutline::new(1.0);
		sink.move_to(0.0, 0.0);
		sink.line_to(1.0, 0.0);
		sink.quadratic_to(2.0, 0.0, 3.0, 0.0);
		sink.close();
		assert_eq!(sink.into_string(), "M0 0L1 0Q2 0 3 0Z");
	}

	#[test]
	fn simplify_drops_points_on_the_line_and_keeps_corners() {
		let line = [(0.0, 0.0), (1.0, 0.01), (2.0, 0.0), (3.0, 2.0), (4.0, 4.0)];
		assert_eq!(
			simplify(&line, 0.1),
			vec![(0.0, 0.0), (2.0, 0.0), (4.0, 4.0)]
		);
		assert_eq!(simplify(&line, 0.0), line.to_vec());
		assert_eq!(simplify(&line[..2], 5.0), line[..2].to_vec());
	}

	#[test]
	fn simplify_measures_from_the_point_when_a_span_closes_on_itself() {
		let loop_ = [(0.0, 0.0), (0.05, 0.0), (3.0, 0.0), (0.0, 0.0)];
		assert_eq!(
			simplify(&loop_, 0.5),
			vec![(0.0, 0.0), (3.0, 0.0), (0.0, 0.0)]
		);
	}

	#[test]
	fn compact_paths_write_centrelines_with_two_decimals() {
		let ops = vec![
			Op::move_to(Point::new(0.123_456, 1.0)),
			Op::LineTo(Point::new(10.987_654, -2.5)),
		];
		let drawable = Drawable {
			sets: vec![
				crate::OpSet {
					kind: OpSetKind::Path,
					ops: ops.clone(),
				},
				crate::OpSet {
					kind: OpSetKind::FillPath,
					ops,
				},
			],
			seed: 1,
			pen: RoughPen::UNIFORM,
		};
		let ink = DrawableInk::new(&drawable, DrawableInkOptions::new(2.0, 1.0));
		let paths = ink.compact_svg_paths(0.25);
		assert_eq!(paths.len(), 2);
		assert_eq!(paths[0].data, "M0.12 1L10.99-2.5Z");
		assert!(paths[0].filled);
		assert_eq!(paths[1].data, "M0.12 1L10.99-2.5");
		assert!(!paths[1].filled);
		assert_eq!(paths[1].stroke_width, 2.0);
		// The exact paths are unchanged.
		assert!(ink.svg_paths()[1].data.contains("0.123456"));
	}

	#[test]
	fn compact_paths_ink_pen_strokes() {
		let drawable = Drawable {
			sets: vec![crate::OpSet {
				kind: OpSetKind::Path,
				ops: curve(),
			}],
			seed: 3,
			pen: RoughPen::INK,
		};
		let ink = DrawableInk::new(&drawable, DrawableInkOptions::new(2.0, 1.0));
		let exact = ink.svg_paths();
		let compact = ink.compact_svg_paths(0.25);
		assert_eq!(exact.len(), compact.len());
		assert!(compact[0].filled);
		assert!(compact[0].data.len() * 3 < exact[0].data.len());
		assert_eq!(compact, ink.sets[0].compact_svg_paths(0.25));
	}

	#[test]
	fn empty_sets_have_no_compact_paths() {
		let drawable = Drawable {
			sets: vec![crate::OpSet {
				kind: OpSetKind::Path,
				ops: Vec::new(),
			}],
			seed: 1,
			pen: RoughPen::UNIFORM,
		};
		let ink = DrawableInk::new(&drawable, DrawableInkOptions::new(2.0, 1.0));
		assert!(ink.compact_svg_paths(0.25).is_empty());
	}
}
