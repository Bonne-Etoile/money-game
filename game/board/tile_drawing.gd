class_name TileDrawing
extends RefCounted
## Draws a mahjong tile: an ivory face over the jade back every tile shares, with a rim, a
## seam and a soft light, and its symbol engraved and inked like a printed tile. Each symbol
## is a shape and an ink (TileArt), so that colour is never the only cue. No image needed.

const SYMBOL_SHAPES: int = 6
## Height of the visible back under the face, and of its darker lip, as fractions of the tile.
const SIDE: float = 0.14
const LIP: float = 0.05
## Height of the seam between the face and the back, as a fraction of the tile.
const SEAM: float = 0.03
## Corner radius, as a fraction of the tile.
const CORNER: float = 0.17
## The symbol's radius, as a fraction of the face's width.
const SYMBOL_RADIUS: float = 0.27
## The soft light covers this much of the face, from the top.
const LIGHT_HEIGHT: float = 0.45
## How far the engraving's shadow (up) and light (down) are from the symbol, as fractions of
## the tile.
const ENGRAVE_SHADOW: float = 0.014
const ENGRAVE_LIGHT: float = 0.022
## Points of the circle symbol.
const CIRCLE_POINTS: int = 28

static var _box: StyleBoxFlat = StyleBoxFlat.new()
static var _edge: StyleBoxFlat = _make_edge()
static var _face: StyleBoxFlat = StyleBoxFlat.new()
static var _light: GradientTexture2D = _make_light()
## The symbols' outlines around (0, 0), for a radius of 1, closed (the first point again at
## the end); balanced so that every shape looks the same size.
static var _shapes: Array[PackedVector2Array] = _make_shapes()
## A smaller shape inlaid in each symbol in the face's colour, like the ornaments of a tile.
static var _inlays: Array[PackedVector2Array] = _make_inlays()


## A tile in `rect`; `tint` multiplies every colour (hints, fading). A negative symbol is a
## stone (TileGrid.STONE, level mode): a grey block, speckled and cracked.
static func draw_tile(
	canvas: CanvasItem, rect: Rect2, symbol: int, art: TileArt, tint: Color = Color.WHITE
) -> void:
	if symbol < 0:
		_draw_stone(canvas, rect, art, tint)
		return
	var face: Rect2 = draw_blank(canvas, rect, art, tint)
	var ink: Color = art.symbol_colors[symbol % art.symbol_colors.size()]
	draw_symbol(canvas, face, symbol, ink, art.tile_face, tint)


## A tile without symbol in `rect`; returns its face (to draw on).
static func draw_blank(
	canvas: CanvasItem, rect: Rect2, art: TileArt, tint: Color = Color.WHITE
) -> Rect2:
	var radius: float = rect.size.x * CORNER
	draw_box(canvas, rect, art.tile_back_lip * tint, radius)
	draw_box(canvas, rect.grow_side(SIDE_BOTTOM, -rect.size.y * LIP), art.tile_back * tint, radius)
	var face: Rect2 = Rect2(rect.position, Vector2(rect.size.x, rect.size.y * (1.0 - SIDE)))
	draw_box(canvas, face.grow_side(SIDE_BOTTOM, rect.size.y * SEAM), art.tile_seam * tint, radius)
	var rim: int = maxi(roundi(rect.size.x * 0.03), 1)
	_face.bg_color = art.tile_face * tint
	_face.border_color = art.tile_face.lerp(Color.WHITE, art.tile_rim.a) * tint
	_face.border_width_top = rim
	_face.border_width_left = rim
	_face.border_blend = true
	_face.set_corner_radius_all(int(radius))
	_face.draw(canvas.get_canvas_item(), face)
	var light: Color = art.tile_light * tint
	if light.a > 0.0:
		var inset: float = radius * 0.5
		canvas.draw_texture_rect(
			_light,
			Rect2(
				face.position + Vector2(inset, rim),
				Vector2(face.size.x - inset * 2.0, face.size.y * LIGHT_HEIGHT)
			),
			false,
			light
		)
	return face


## A rounded rectangle; `radius` in pixels (negative: a tile's corner).
static func draw_box(canvas: CanvasItem, rect: Rect2, color: Color, radius: float = -1.0) -> void:
	_box.bg_color = color
	_box.set_corner_radius_all(int(rect.size.x * CORNER if radius < 0.0 else radius))
	_box.draw(canvas.get_canvas_item(), rect)


## The outline of a rounded rectangle, `width` pixels wide inwards.
static func draw_outline(
	canvas: CanvasItem, rect: Rect2, color: Color, width: float, radius: float = -1.0
) -> void:
	_edge.border_color = color
	_edge.set_border_width_all(maxi(roundi(width), 1))
	_edge.set_corner_radius_all(int(rect.size.x * CORNER if radius < 0.0 else radius))
	_edge.draw(canvas.get_canvas_item(), rect)


## A symbol engraved in the middle of `face` and inked in `ink`: a light edge below and a
## shadow above (it sits in the tile), a darker outline, and an inlay in `paper`.
static func draw_symbol(
	canvas: CanvasItem,
	face: Rect2,
	symbol: int,
	ink: Color,
	paper: Color,
	tint: Color = Color.WHITE
) -> void:
	var shape: int = symbol % SYMBOL_SHAPES
	var radius: float = face.size.x * SYMBOL_RADIUS
	var center: Vector2 = face.get_center()
	var size: float = face.size.x
	var light: Transform2D = Transform2D(
		0.0, Vector2.ONE * radius, 0.0, center + Vector2(0.0, size * ENGRAVE_LIGHT)
	)
	var shadow: Transform2D = Transform2D(
		0.0, Vector2.ONE * radius, 0.0, center - Vector2(0.0, size * ENGRAVE_SHADOW)
	)
	var at: Transform2D = Transform2D(0.0, Vector2.ONE * radius, 0.0, center)
	var outline: PackedVector2Array = at * _shapes[shape]
	var dark: Color = ink.darkened(0.3) * tint
	canvas.draw_colored_polygon(light * _shapes[shape], Color(1, 1, 1, 0.75) * tint)
	canvas.draw_colored_polygon(shadow * _shapes[shape], Color(dark, dark.a * 0.55))
	canvas.draw_colored_polygon(outline, ink * tint)
	canvas.draw_polyline(outline, dark, maxf(radius * 0.09, 1.5), true)
	canvas.draw_polyline(
		at * _inlays[shape], Color(paper, 0.85) * tint, maxf(radius * 0.13, 1.5), true
	)


## A stone: a grey block with darker speckles and a crack.
static func _draw_stone(canvas: CanvasItem, rect: Rect2, art: TileArt, tint: Color) -> void:
	draw_box(canvas, rect, art.stone_side * tint)
	var top: Rect2 = Rect2(rect.position, Vector2(rect.size.x, rect.size.y * (1.0 - SIDE)))
	draw_box(canvas, top, art.stone_face * tint)
	draw_outline(canvas, top, art.stone_face.lightened(0.18) * tint, top.size.x * 0.03)
	var mark: Color = art.stone_mark * tint
	var side: float = top.size.x
	for speck: Vector3 in [
		Vector3(0.24, 0.3, 0.05), Vector3(0.7, 0.62, 0.065), Vector3(0.36, 0.74, 0.04)
	]:
		canvas.draw_circle(
			top.position + Vector2(speck.x, speck.y) * side, speck.z * side, mark, true, -1.0, true
		)
	var crack: PackedVector2Array = [
		top.position + Vector2(0.56, 0.1) * side,
		top.position + Vector2(0.66, 0.26) * side,
		top.position + Vector2(0.55, 0.38) * side,
		top.position + Vector2(0.63, 0.5) * side,
	]
	canvas.draw_polyline(crack, mark, maxf(side * 0.035, 1.5), true)
	crack = [crack[1], top.position + Vector2(0.8, 0.3) * side]
	canvas.draw_polyline(crack, mark, maxf(side * 0.03, 1.5), true)


static func _make_edge() -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.draw_center = false
	return box


## White fading out downwards: the light on the top of a face.
static func _make_light() -> GradientTexture2D:
	var gradient: Gradient = Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color(1, 1, 1, 0))
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0.5, 0.0)
	texture.fill_to = Vector2(0.5, 1.0)
	texture.width = 4
	texture.height = 32
	return texture


static func _make_shapes() -> Array[PackedVector2Array]:
	var shapes: Array[PackedVector2Array] = [
		_regular(0.98, CIRCLE_POINTS, 0.0),
		_rounded_square(0.84, 0.2),
		_shifted(_regular(1.26, 3, -PI / 2.0), Vector2(0.0, 0.26)),
		_regular(1.17, 4, -PI / 2.0),
		_shifted(_star(1.2, 0.5), Vector2(0.0, 0.06)),
		_plus(1.0, 0.36),
	]
	for index in shapes.size():
		shapes[index].append(shapes[index][0])
	return shapes


static func _make_inlays() -> Array[PackedVector2Array]:
	var inlays: Array[PackedVector2Array] = [
		_regular(0.52, 20, 0.0),
		_rounded_square(0.42, 0.1),
		_shifted(_regular(0.56, 3, -PI / 2.0), Vector2(0.0, 0.26)),
		_regular(0.56, 4, -PI / 2.0),
		_shifted(_regular(0.2, 10, 0.0), Vector2(0.0, 0.06)),
		_regular(0.2, 4, PI / 4.0),
	]
	for index in inlays.size():
		inlays[index].append(inlays[index][0])
	return inlays


static func _regular(radius: float, sides: int, start: float) -> PackedVector2Array:
	var points: PackedVector2Array = []
	for index in sides:
		points.append(Vector2.from_angle(start + TAU * index / sides) * radius)
	return points


static func _shifted(points: PackedVector2Array, by: Vector2) -> PackedVector2Array:
	return Transform2D(0.0, by) * points


static func _star(radius: float, inner: float) -> PackedVector2Array:
	var points: PackedVector2Array = []
	for index in 10:
		var length: float = radius if index % 2 == 0 else radius * inner
		points.append(Vector2.from_angle(-PI / 2.0 + TAU * index / 10.0) * length)
	return points


## A square of half-side `half` with corners rounded by `corner`.
static func _rounded_square(half: float, corner: float) -> PackedVector2Array:
	var points: PackedVector2Array = []
	for quarter in 4:
		var turn: float = quarter * PI / 2.0
		var center: Vector2 = (Vector2.ONE * (half - corner)).rotated(turn)
		for step in 5:
			points.append(center + Vector2.from_angle(turn + step * PI / 8.0) * corner)
	return points


## A plus whose arms reach `reach` and are `half` wide on each side.
static func _plus(reach: float, half: float) -> PackedVector2Array:
	return PackedVector2Array(
		[
			Vector2(-half, -reach),
			Vector2(half, -reach),
			Vector2(half, -half),
			Vector2(reach, -half),
			Vector2(reach, half),
			Vector2(half, half),
			Vector2(half, reach),
			Vector2(-half, reach),
			Vector2(-half, half),
			Vector2(-reach, half),
			Vector2(-reach, -half),
			Vector2(-half, -half),
		]
	)
