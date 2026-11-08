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
		PieceDrawing.draw_piece(self, _piece, _corner, _cell, art)
