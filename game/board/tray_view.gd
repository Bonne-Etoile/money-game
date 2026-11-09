class_name TrayView
extends Control
## The pieces waiting to be placed, side by side. Pressing one and moving starts a drag: the
## tray keeps the pointer until it is released, and reports where it goes (global
## coordinates). Pressing and releasing without moving is a tap (to turn the piece).

signal drag_started(slot: int, pointer: Vector2)
signal drag_moved(pointer: Vector2)
signal drag_ended(pointer: Vector2)
## A piece was touched and released without moving (to turn it).
signal tapped(slot: int)

## How far the pointer moves, in pixels, before a touch becomes a drag rather than a tap.
const TAP_SLOP: float = 16.0
## Space around a slot's box, in pixels.
const SLOT_MARGIN: float = 8.0

var art: TileArt
## Side of a cell on the board; pieces in the tray are drawn smaller (TileArt.tray_scale).
var board_cell: float = 64.0
## The slot being dragged, drawn empty (-1: none).
var hidden_slot: int = -1
## Whether each slot is drawn as a box, empty or not (prototype 2's small tray).
var show_slots: bool = false
var _pieces: Array[Piece] = []
var _dragging: bool = false
## The slot under the pointer since it was pressed (-1: none).
var _pressed_slot: int = -1
var _press_point: Vector2 = Vector2.ZERO


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
			_pressed_slot = slot
			_press_point = pointer.global_position
			_dragging = false
			accept_event()
	elif _pressed_slot >= 0 and event.is_action_released("pointer"):
		if _dragging:
			drag_ended.emit(pointer.global_position)
		else:
			tapped.emit(_pressed_slot)
		_pressed_slot = -1
		_dragging = false
		accept_event()
	elif _pressed_slot >= 0 and event is InputEventMouseMotion:
		if not _dragging and pointer.global_position.distance_to(_press_point) > TAP_SLOP:
			_dragging = true
			drag_started.emit(_pressed_slot, _press_point)
		if _dragging:
			drag_moved.emit(pointer.global_position)
		accept_event()


func _draw() -> void:
	if art == null:
		return
	var cell: float = board_cell * art.tray_scale
	for slot in _pieces.size():
		if show_slots:
			TileDrawing.draw_box(self, slot_rect(slot).grow(-SLOT_MARGIN), art.empty_cell)
		var piece: Piece = _pieces[slot]
		if piece == null or slot == hidden_slot:
			continue
		var extent: Vector2 = Vector2(piece.extent()) * cell
		var corner: Vector2 = slot_rect(slot).get_center() - extent / 2.0
		PieceDrawing.draw_piece(self, piece, corner, cell, art)
