class_name TrayView
extends Control
## The pieces waiting to be placed, side by side. Pressing one starts a drag: the tray keeps
## the pointer until it is released, and reports where it goes (global coordinates).

signal drag_started(slot: int, pointer: Vector2)
signal drag_moved(pointer: Vector2)
signal drag_ended(pointer: Vector2)

var art: TileArt
## Side of a cell on the board; pieces in the tray are drawn smaller (TileArt.tray_scale).
var board_cell: float = 64.0
## The slot being dragged, drawn empty (-1: none).
var hidden_slot: int = -1
var _pieces: Array[Piece] = []
var _dragging: bool = false


func _ready() -> void:
	resized.connect(queue_redraw)


func set_pieces(pieces: Array[Piece]) -> void:
	_pieces = pieces.duplicate()
	queue_redraw()


func slot_count() -> int:
	return _pieces.size()


func slot_rect(slot: int) -> Rect2:
	var width: float = size.x / maxi(_pieces.size(), 1)
	return Rect2(Vector2(width * slot, 0.0), Vector2(width, size.y))


## Centre of a slot, in global coordinates.
func slot_center(slot: int) -> Vector2:
	return global_position + slot_rect(slot).get_center()


func slot_at(local_point: Vector2) -> int:
	for slot in _pieces.size():
		if slot_rect(slot).has_point(local_point):
			return slot
	return -1


func _gui_input(event: InputEvent) -> void:
	var pointer: InputEventMouse = event as InputEventMouse
	if pointer == null:
		return
	if event.is_action_pressed("pointer"):
		var slot: int = slot_at(pointer.position)
		if slot >= 0 and _pieces[slot] != null:
			_dragging = true
			drag_started.emit(slot, pointer.global_position)
			accept_event()
	elif _dragging and event.is_action_released("pointer"):
		_dragging = false
		drag_ended.emit(pointer.global_position)
		accept_event()
	elif _dragging and event is InputEventMouseMotion:
		drag_moved.emit(pointer.global_position)
		accept_event()


func _draw() -> void:
	if art == null:
		return
	var cell: float = board_cell * art.tray_scale
	for slot in _pieces.size():
		var piece: Piece = _pieces[slot]
		if piece == null or slot == hidden_slot:
			continue
		var extent: Vector2 = Vector2(piece.extent()) * cell
		var corner: Vector2 = slot_rect(slot).get_center() - extent / 2.0
		PieceDrawing.draw_piece(self, piece, corner, cell, art)
