class_name LevelPicture
extends Control
## The big mahjong tile of the level map (G17): a mosaic of small tiles, one per level, grey
## until its level is won, then in its symbol's colours. Finished, it is a full tile to show.

## Two columns: the big tile stands upright, like a mahjong tile.
const COLUMNS: int = 2

var art: TileArt
var tiles: int = 0:
	set(value):
		tiles = value
		queue_redraw()
var won: int = 0:
	set(value):
		won = value
		queue_redraw()


func _draw() -> void:
	if art == null or tiles <= 0:
		return
	var rows: int = ceili(float(tiles) / COLUMNS)
	var cell: float = minf(size.x / COLUMNS, size.y / rows)
	var origin: Vector2 = (size - Vector2(COLUMNS, rows) * cell) / 2.0
	var whole: Rect2 = Rect2(origin, Vector2(COLUMNS, rows) * cell).grow(cell * 0.12)
	TileDrawing.draw_box(self, whole, art.tile_side)
	TileDrawing.draw_box(self, whole.grow(-cell * 0.06), art.tile_face)
	for index in tiles:
		var rect: Rect2 = Rect2(
			origin + Vector2(index % COLUMNS, index / COLUMNS) * cell, Vector2.ONE * cell
		)
		rect = rect.grow(-cell * 0.05)
		if index < won:
			TileDrawing.draw_tile(self, rect, index % art.symbol_colors.size(), art)
		else:
			TileDrawing.draw_box(self, rect, art.empty_cell)
