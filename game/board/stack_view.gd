class_name StackView
extends Control
## Draws the mahjong pile of prototype 2 (TileStack): each tile shows the piece it gives;
## tiles that cannot be taken yet are darker. Tapping a tile reports it (the game decides).

signal tile_tapped(index: int)

## Tile height compared with its width (mahjong tiles are taller than wide).
const TILE_RATIO: float = 1.2
## How far each layer is drawn up and to the left, in half tiles, to look stacked.
const LAYER_SHIFT: Vector2 = Vector2(-0.18, -0.22)
## Darkening of the tiles that are not free.
const BLOCKED_TINT: Color = Color(0.55, 0.55, 0.6)
## Size of the piece drawn on a tile, as a fraction of the tile width.
const PIECE_SPAN: float = 0.7

var stack: TileStack
var art: TileArt
## Whether tiles may be taken now (dark otherwise, e.g. the tray is full).
var can_take: bool = true


func _ready() -> void:
	resized.connect(queue_redraw)


## Rectangle of a tile, local coordinates.
func tile_rect(index: int) -> Rect2:
	var half: Vector2 = _half_tile()
	var tile: StackTile = stack.tiles[index]
	var corner: Vector2 = Vector2(tile.position) * half + LAYER_SHIFT * half.x * tile.layer
	return Rect2(_offset() + corner, half * 2.0)


## Centre of a tile, in global coordinates.
func tile_center(index: int) -> Vector2:
	return global_position + tile_rect(index).get_center()


## The topmost remaining tile under `local_point`, or -1.
func tile_at(local_point: Vector2) -> int:
	var order: Array[int] = _draw_order()
	order.reverse()
	for index in order:
		if tile_rect(index).has_point(local_point):
			return index
	return -1


func _gui_input(event: InputEvent) -> void:
	var pointer: InputEventMouse = event as InputEventMouse
	if pointer != null and event.is_action_pressed("pointer"):
		var index: int = tile_at(pointer.position)
		if index >= 0:
			tile_tapped.emit(index)
			accept_event()


func _draw() -> void:
	if stack == null or art == null:
		return
	for index in _draw_order():
		var rect: Rect2 = tile_rect(index)
		var takeable: bool = can_take and stack.is_free(index)
		var tint: Color = Color.WHITE if takeable else BLOCKED_TINT
		var gap: float = rect.size.x * art.cell_gap / 2.0
		_draw_tile(rect.grow(-gap), stack.tiles[index].piece, tint)


func _draw_tile(rect: Rect2, piece: Piece, tint: Color) -> void:
	var side: float = rect.size.y * TileDrawing.SIDE
	TileDrawing.draw_box(self, rect, art.tile_side * tint)
	var face: Rect2 = Rect2(rect.position, rect.size - Vector2(0.0, side))
	TileDrawing.draw_box(self, face, art.tile_face * tint)
	if piece.cells.size() == 1:
		var color: Color = art.symbol_colors[piece.symbols[0] % art.symbol_colors.size()]
		var margin: float = face.size.x * TileDrawing.SYMBOL_MARGIN
		TileDrawing.draw_symbol(self, face.grow(-margin), piece.symbols[0], color * tint)
		return
	var extent: Vector2i = piece.extent()
	var cell: float = face.size.x * PIECE_SPAN / maxf(maxi(extent.x, extent.y), 2.0)
	var corner: Vector2 = face.get_center() - Vector2(extent) * cell / 2.0
	for index in piece.cells.size():
		var color: Color = art.symbol_colors[piece.symbols[index] % art.symbol_colors.size()]
		var box: Rect2 = Rect2(corner + Vector2(piece.cells[index]) * cell, Vector2.ONE * cell)
		TileDrawing.draw_box(self, box.grow(-cell * 0.08), color * tint)


## Remaining tiles, lowest layer first, then top to bottom and left to right.
func _draw_order() -> Array[int]:
	var order: Array[int] = []
	for index in stack.tiles.size():
		if not stack.tiles[index].removed:
			order.append(index)
	order.sort_custom(
		func(a: int, b: int) -> bool:
			var ta: StackTile = stack.tiles[a]
			var tb: StackTile = stack.tiles[b]
			if ta.layer != tb.layer:
				return ta.layer < tb.layer
			if ta.position.y != tb.position.y:
				return ta.position.y < tb.position.y
			return ta.position.x < tb.position.x
	)
	return order


## Size of a half tile, so that the whole pile fits the view.
func _half_tile() -> Vector2:
	var bounds: Vector2 = Vector2(_bounds())
	var width: float = minf(size.x / bounds.x, size.y / (bounds.y * TILE_RATIO))
	return Vector2(width, width * TILE_RATIO)


## The pile centred in the view.
func _offset() -> Vector2:
	var half: Vector2 = _half_tile()
	return (size - Vector2(_bounds()) * half) / 2.0 - LAYER_SHIFT * half.x


## Extent of the pile in half tiles (with a margin for the layer shift), whole level.
func _bounds() -> Vector2i:
	var corner: Vector2i = Vector2i(2, 2)
	for tile in stack.tiles:
		corner = Vector2i(maxi(corner.x, tile.position.x + 2), maxi(corner.y, tile.position.y + 2))
	return corner + Vector2i.ONE
