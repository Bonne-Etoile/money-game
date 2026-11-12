class_name GameIcons
extends RefCounted
## The interface's small pictures, drawn by code (no image): menu bars, crown, gear, home,
## replay, back, the "an ad plays" badge, lock, star, check, new pieces, mirror, calendar,
## tiles. Each is drawn in a square, in one colour.

const MENU: StringName = &"menu"
const CROWN: StringName = &"crown"
const GEAR: StringName = &"gear"
const HOME: StringName = &"home"
const REPLAY: StringName = &"replay"
const BACK: StringName = &"back"
const AD: StringName = &"ad"
const LOCK: StringName = &"lock"
const STAR: StringName = &"star"
const CHECK: StringName = &"check"
const NEW_PIECES: StringName = &"new_pieces"
const MIRROR: StringName = &"mirror"
const CALENDAR: StringName = &"calendar"
const TILES: StringName = &"tiles"
const NEXT: StringName = &"next"
const CLOSE: StringName = &"close"

static var _box: StyleBoxFlat = StyleBoxFlat.new()


## Draws `glyph` centred on `center`, `radius` pixels from its centre to its edge.
static func draw(
	canvas: CanvasItem, glyph: StringName, center: Vector2, radius: float, color: Color
) -> void:
	var to: Transform2D = Transform2D(0.0, Vector2.ONE * radius, 0.0, center)
	var thick: float = radius * 0.24
	match glyph:
		MENU:
			for y: float in [-0.6, 0.0, 0.6]:
				_bar(canvas, to * Vector2(-0.8, y), to * Vector2(0.8, y), thick, color)
		CROWN:
			_fill(
				canvas,
				to,
				[
					Vector2(-0.95, 0.72),
					Vector2(-1.0, -0.42),
					Vector2(-0.48, 0.08),
					Vector2(0.0, -0.78),
					Vector2(0.48, 0.08),
					Vector2(1.0, -0.42),
					Vector2(0.95, 0.72),
				],
				color
			)
			for tip: Vector2 in [Vector2(-1.0, -0.5), Vector2(0.0, -0.86), Vector2(1.0, -0.5)]:
				canvas.draw_circle(to * tip, radius * 0.15, color, true, -1.0, true)
		GEAR:
			canvas.draw_arc(center, radius * 0.55, 0.0, TAU, 32, color, radius * 0.34, true)
			for tooth in 8:
				var direction: Vector2 = Vector2.from_angle(TAU * tooth / 8.0)
				canvas.draw_line(
					center + direction * radius * 0.62,
					center + direction * radius * 0.98,
					color,
					radius * 0.3,
					true
				)
		HOME:
			_fill(canvas, to, [Vector2(-1.0, 0.0), Vector2(0.0, -0.92), Vector2(1.0, 0.0)], color)
			_fill(
				canvas,
				to,
				[
					Vector2(-0.68, -0.05),
					Vector2(0.68, -0.05),
					Vector2(0.68, 0.88),
					Vector2(0.22, 0.88),
					Vector2(0.22, 0.3),
					Vector2(-0.22, 0.3),
					Vector2(-0.22, 0.88),
					Vector2(-0.68, 0.88),
				],
				color
			)
		REPLAY:
			_turn_arrow(canvas, center, radius * 0.72, -PI * 0.35, PI * 1.25, thick, color)
		NEW_PIECES:
			_turn_arrow(canvas, center, radius * 0.74, -PI * 0.9, -PI * 0.1, thick, color)
			_turn_arrow(canvas, center, radius * 0.74, PI * 0.1, PI * 0.9, thick, color)
		BACK:
			_bar(canvas, to * Vector2(0.35, -0.75), to * Vector2(-0.4, 0.0), thick, color)
			_bar(canvas, to * Vector2(-0.4, 0.0), to * Vector2(0.35, 0.75), thick, color)
		NEXT:
			_bar(canvas, to * Vector2(-0.35, -0.75), to * Vector2(0.4, 0.0), thick, color)
			_bar(canvas, to * Vector2(0.4, 0.0), to * Vector2(-0.35, 0.75), thick, color)
		CLOSE:
			_bar(canvas, to * Vector2(-0.6, -0.6), to * Vector2(0.6, 0.6), thick, color)
			_bar(canvas, to * Vector2(-0.6, 0.6), to * Vector2(0.6, -0.6), thick, color)
		AD:
			# A screen with a play triangle: a video plays.
			_outline(
				canvas, Rect2(to * Vector2(-1.0, -0.72), Vector2(2.0, 1.44) * radius), color, 0.16
			)
			_fill(
				canvas, to, [Vector2(-0.3, -0.38), Vector2(0.45, 0.0), Vector2(-0.3, 0.38)], color
			)
		LOCK:
			canvas.draw_arc(
				to * Vector2(0.0, -0.25), radius * 0.42, PI, TAU, 16, color, thick, true
			)
			_bar(canvas, to * Vector2(-0.42, -0.25), to * Vector2(-0.42, 0.0), thick, color)
			_bar(canvas, to * Vector2(0.42, -0.25), to * Vector2(0.42, 0.0), thick, color)
			_solid(
				canvas, Rect2(to * Vector2(-0.72, -0.05), Vector2(1.44, 1.0) * radius), color, 0.2
			)
		STAR:
			var points: Array[Vector2] = []
			for index in 10:
				var length: float = 1.0 if index % 2 == 0 else 0.48
				points.append(Vector2.from_angle(-PI / 2.0 + TAU * index / 10.0) * length)
			_fill(canvas, to, points, color)
		CHECK:
			_bar(canvas, to * Vector2(-0.7, 0.05), to * Vector2(-0.2, 0.55), thick * 1.2, color)
			_bar(canvas, to * Vector2(-0.2, 0.55), to * Vector2(0.75, -0.5), thick * 1.2, color)
		MIRROR:
			_fill(
				canvas, to, [Vector2(-0.25, -0.7), Vector2(-0.25, 0.7), Vector2(-1.0, 0.7)], color
			)
			var other: PackedVector2Array = (
				to
				* PackedVector2Array(
					[
						Vector2(0.25, -0.7),
						Vector2(0.25, 0.7),
						Vector2(1.0, 0.7),
						Vector2(0.25, -0.7),
					]
				)
			)
			canvas.draw_polyline(other, color, thick * 0.6, true)
			for dash: float in [-0.85, -0.3, 0.25, 0.8]:
				canvas.draw_line(
					to * Vector2(0.0, dash - 0.12),
					to * Vector2(0.0, dash + 0.12),
					color,
					thick * 0.5
				)
		CALENDAR:
			_outline(
				canvas, Rect2(to * Vector2(-0.85, -0.7), Vector2(1.7, 1.6) * radius), color, 0.2
			)
			_bar(canvas, to * Vector2(-0.7, -0.3), to * Vector2(0.7, -0.3), thick * 0.7, color)
			_bar(canvas, to * Vector2(-0.4, -0.95), to * Vector2(-0.4, -0.6), thick * 0.8, color)
			_bar(canvas, to * Vector2(0.4, -0.95), to * Vector2(0.4, -0.6), thick * 0.8, color)
			canvas.draw_circle(to * Vector2(0.0, 0.3), radius * 0.2, color, true, -1.0, true)
		TILES:
			for corner: Vector2 in [
				Vector2(-0.9, -0.9), Vector2(0.1, -0.9), Vector2(-0.9, 0.1), Vector2(0.1, 0.1)
			]:
				_solid(canvas, Rect2(to * corner, Vector2.ONE * 0.8 * radius), color, 0.22)


## A line with round ends.
static func _bar(
	canvas: CanvasItem, from: Vector2, to: Vector2, width: float, color: Color
) -> void:
	canvas.draw_line(from, to, color, width, true)
	canvas.draw_circle(from, width / 2.0, color, true, -1.0, true)
	canvas.draw_circle(to, width / 2.0, color, true, -1.0, true)


static func _fill(
	canvas: CanvasItem, to: Transform2D, points: Array[Vector2], color: Color
) -> void:
	var moved: PackedVector2Array = to * PackedVector2Array(points)
	canvas.draw_colored_polygon(moved, color)
	moved.append(moved[0])
	canvas.draw_polyline(moved, color, 1.0, true)


## A rounded rectangle, its corners `corner` of its height.
static func _solid(canvas: CanvasItem, rect: Rect2, color: Color, corner: float) -> void:
	_box.draw_center = true
	_box.bg_color = color
	_box.set_border_width_all(0)
	_box.set_corner_radius_all(int(rect.size.y * corner))
	_box.draw(canvas.get_canvas_item(), rect)


static func _outline(canvas: CanvasItem, rect: Rect2, color: Color, corner: float) -> void:
	_box.draw_center = false
	_box.border_color = color
	_box.set_border_width_all(maxi(roundi(rect.size.y * 0.11), 2))
	_box.set_corner_radius_all(int(rect.size.y * corner))
	_box.draw(canvas.get_canvas_item(), rect)


## An arc from `start` to `end` (radians) ending with an arrow head.
static func _turn_arrow(
	canvas: CanvasItem,
	center: Vector2,
	radius: float,
	start: float,
	end: float,
	width: float,
	color: Color
) -> void:
	canvas.draw_arc(center, radius, start, end, 24, color, width, true)
	var tip: Vector2 = center + Vector2.from_angle(end) * radius
	var along: Vector2 = Vector2.from_angle(end + PI / 2.0)
	var across: Vector2 = Vector2.from_angle(end)
	var head: PackedVector2Array = [
		tip + along * width * 1.7,
		tip + across * width * 1.5 - along * width * 0.4,
		tip - across * width * 1.5 - along * width * 0.4,
	]
	canvas.draw_colored_polygon(head, color)
