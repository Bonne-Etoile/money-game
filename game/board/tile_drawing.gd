class_name TileDrawing
extends RefCounted
## Draws a mahjong-like tile (ivory face over a darker side) with its symbol: each symbol is a
## shape and a colour (TileArt), so that colour is never the only cue. No image needed.

const SYMBOL_SHAPES: int = 6
## Height of the visible side under the face, as a fraction of the tile.
const SIDE: float = 0.12
## Corner radius, as a fraction of the tile.
const CORNER: float = 0.16
## Margin around the symbol, as a fraction of the face.
const SYMBOL_MARGIN: float = 0.22

static var _box: StyleBoxFlat = StyleBoxFlat.new()


## A tile in `rect`; `tint` multiplies every colour (ghosts, fading). A negative symbol is a
## stone (TileGrid.STONE, level mode): a grey block without symbol.
static func draw_tile(
	canvas: CanvasItem, rect: Rect2, symbol: int, art: TileArt, tint: Color = Color.WHITE
) -> void:
	if symbol < 0:
		draw_box(canvas, rect, art.stone_side * tint)
		var top: Rect2 = Rect2(rect.position, Vector2(rect.size.x, rect.size.y * (1.0 - SIDE)))
		draw_box(canvas, top, art.stone_face * tint)
		return
	draw_box(canvas, rect, art.tile_side * tint)
	var face: Rect2 = Rect2(rect.position, Vector2(rect.size.x, rect.size.y * (1.0 - SIDE)))
	draw_box(canvas, face, art.tile_face * tint)
	var color: Color = art.symbol_colors[symbol % art.symbol_colors.size()] * tint
	draw_symbol(canvas, face.grow(-face.size.x * SYMBOL_MARGIN), symbol, color)


## A rounded rectangle.
static func draw_box(canvas: CanvasItem, rect: Rect2, color: Color) -> void:
	_box.bg_color = color
	_box.set_corner_radius_all(int(rect.size.x * CORNER))
	_box.draw(canvas.get_canvas_item(), rect)


static func draw_symbol(canvas: CanvasItem, rect: Rect2, symbol: int, color: Color) -> void:
	var center: Vector2 = rect.get_center()
	var radius: float = minf(rect.size.x, rect.size.y) / 2.0
	match symbol % SYMBOL_SHAPES:
		0:
			canvas.draw_circle(center, radius, color)
		1:
			canvas.draw_rect(
				Rect2(center - Vector2.ONE * radius * 0.85, Vector2.ONE * radius * 1.7), color
			)
		2:
			canvas.draw_colored_polygon(_regular(center, radius * 1.1, 3, -PI / 2.0), color)
		3:
			canvas.draw_colored_polygon(_regular(center, radius * 1.05, 4, -PI / 2.0), color)
		4:
			canvas.draw_colored_polygon(_star(center, radius * 1.1), color)
		_:
			var arm: Vector2 = Vector2(radius * 2.0, radius * 0.7)
			canvas.draw_rect(Rect2(center - arm / 2.0, arm), color)
			canvas.draw_rect(
				Rect2(center - Vector2(arm.y, arm.x) / 2.0, Vector2(arm.y, arm.x)), color
			)


static func _regular(
	center: Vector2, radius: float, sides: int, start: float
) -> PackedVector2Array:
	var points: PackedVector2Array = []
	for index in sides:
		points.append(center + Vector2.from_angle(start + TAU * index / sides) * radius)
	return points


static func _star(center: Vector2, radius: float) -> PackedVector2Array:
	var points: PackedVector2Array = []
	for index in 10:
		var length: float = radius if index % 2 == 0 else radius * 0.45
		points.append(center + Vector2.from_angle(-PI / 2.0 + TAU * index / 10.0) * length)
	return points
