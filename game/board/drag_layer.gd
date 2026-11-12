class_name DragLayer
extends Control
## Draws the piece being dragged, at full board size, over everything else.

var art: TileArt
var _piece: Piece
var _corner: Vector2 = Vector2.ZERO
var _cell: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func show_piece(piece: Piece, corner: Vector2, cell: float) -> void:
	_piece = piece
	_corner = corner - global_position
	_cell = cell
	queue_redraw()


func hide_piece() -> void:
	_piece = null
	queue_redraw()


func _draw() -> void:
	if _piece != null and art != null:
		# A shadow below and to the side: the piece looks lifted off the grid.
		var lift: Vector2 = Vector2(0.12, 0.22) * _cell
		var gap: float = _cell * art.cell_gap / 2.0
		for cell in _piece.cells:
			var rect: Rect2 = Rect2(_corner + lift + Vector2(cell) * _cell, Vector2.ONE * _cell)
			TileDrawing.draw_box(self, rect.grow(-gap), art.drag_shadow)
		PieceDrawing.draw_piece(self, _piece, _corner, _cell, art)
