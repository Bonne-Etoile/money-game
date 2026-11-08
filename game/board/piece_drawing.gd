class_name PieceDrawing
extends RefCounted
## Draws a whole piece, cell by cell, with the board's gaps between tiles.


static func draw_piece(
	canvas: CanvasItem,
	piece: Piece,
	corner: Vector2,
	cell: float,
	art: TileArt,
	tint: Color = Color.WHITE
) -> void:
	var gap: float = cell * art.cell_gap / 2.0
	for index in piece.cells.size():
		var rect: Rect2 = Rect2(corner + Vector2(piece.cells[index]) * cell, Vector2.ONE * cell)
		TileDrawing.draw_tile(canvas, rect.grow(-gap), piece.symbols[index], art, tint)
