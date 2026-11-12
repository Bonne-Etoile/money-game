class_name DragLayer
extends Control
## Draws the piece being dragged over everything else: a little bigger than on the grid and
## raised above its landing place (which the board shows as a silhouette), with a shadow, so
## that it looks lifted in the hand.

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
	if _piece == null or art == null:
		return
	# Grown around its centre, then raised.
	var extent: Vector2 = Vector2(_piece.extent()) * _cell
	var cell: float = _cell * art.drag_scale
	var corner: Vector2 = _corner + extent / 2.0 - extent * art.drag_scale / 2.0
	corner.y -= art.drag_raise_cells * _cell
	var gap: float = cell * art.cell_gap / 2.0
	var shadow: Vector2 = art.drag_shadow_offset * _cell
	for at in _piece.cells:
		var rect: Rect2 = Rect2(corner + shadow + Vector2(at) * cell, Vector2.ONE * cell)
		TileDrawing.draw_box(self, rect.grow(-gap), art.drag_shadow)
	PieceDrawing.draw_piece(self, _piece, corner, cell, art)
