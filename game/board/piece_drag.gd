class_name PieceDrag
extends Node
## Turns drags from a TrayView into moves on a BoardView: the dragged piece follows the
## pointer (drawn above the finger), its landing place shows as a ghost on the grid, and
## releasing it over the grid asks the game to place it. Shared by both prototypes; the game
## itself is reached through the callables, so this node knows no rules.

## A piece was placed (`result` comes from the game; the board already flashed it).
signal placed(result: MoveResult)
## A piece was picked up from the tray.
signal picked(slot: int)
## A dragged piece went back to the tray (dropped off the grid or where it does not fit).
signal returned

var board: BoardView
var tray: TrayView
var layer: DragLayer
var art: TileArt
## func(slot: int) -> Piece: the piece waiting in a slot of the tray.
var piece_in: Callable
## func(slot: int, origin: Vector2i) -> bool
var can_place: Callable
## func(slot: int, origin: Vector2i) -> MoveResult (null when not allowed)
var place: Callable
## func(slot: int, origin: Vector2i) -> Array[Vector2i]: the cells the move would clear (they
## glow on the board while the piece hovers there); not set: nothing glows.
var clears_for: Callable
## Whether drags are refused (end of game, panel shown).
var locked: bool = false
var _slot: int = -1
## Where the glowing cells were last worked out for (so they are not looked for each frame).
var _preview_origin: Vector2i = Vector2i(-999, -999)


func connect_views(board_view: BoardView, tray_view: TrayView, drag_layer: DragLayer) -> void:
	board = board_view
	tray = tray_view
	layer = drag_layer
	tray.drag_started.connect(_on_started)
	tray.drag_moved.connect(_on_moved)
	tray.drag_ended.connect(_on_ended)


func is_dragging() -> bool:
	return _slot >= 0


## Where the top-left corner of the dragged piece is drawn: above the pointer, so that the
## finger does not hide it.
func dragged_corner(piece: Piece, pointer: Vector2) -> Vector2:
	var cell: float = board.cell_size()
	var extent: Vector2 = Vector2(piece.extent()) * cell
	return pointer - Vector2(extent.x / 2.0, extent.y + art.drag_lift_cells * cell)


## The pointer position that drops `piece` with its top-left corner on `origin` (the reverse
## of dragged_corner; used by tests and screenshots).
func pointer_for(piece: Piece, origin: Vector2i) -> Vector2:
	var cell: float = board.cell_size()
	var extent: Vector2 = Vector2(piece.extent()) * cell
	var corner: Vector2 = board.global_position + Vector2(origin) * cell
	return corner + Vector2(extent.x / 2.0, extent.y + art.drag_lift_cells * cell)


func cancel() -> void:
	_slot = -1
	tray.hidden_slot = -1
	_preview_origin = Vector2i(-999, -999)
	tray.queue_redraw()
	layer.hide_piece()
	board.clear_ghost()


func _on_started(slot: int, pointer: Vector2) -> void:
	if locked or _piece(slot) == null:
		return
	_slot = slot
	tray.hidden_slot = slot
	tray.queue_redraw()
	picked.emit(slot)
	_on_moved(pointer)


func _on_moved(pointer: Vector2) -> void:
	var piece: Piece = _piece(_slot)
	if piece == null:
		return
	var corner: Vector2 = dragged_corner(piece, pointer)
	layer.show_piece(piece, corner, board.cell_size())
	var origin: Vector2i = board.nearest_cell(corner)
	if _overlaps_board(piece, origin):
		var valid: bool = can_place.call(_slot, origin)
		board.set_ghost(piece, origin, valid)
		_show_preview(origin, valid)
	else:
		board.clear_ghost()
		_preview_origin = Vector2i(-999, -999)


func _show_preview(origin: Vector2i, valid: bool) -> void:
	if origin == _preview_origin or not clears_for.is_valid():
		return
	_preview_origin = origin
	var cells: Array[Vector2i] = []
	if valid:
		var found: Array[Vector2i] = clears_for.call(_slot, origin)
		cells = found
	board.set_preview(cells)


func _on_ended(pointer: Vector2) -> void:
	if _slot < 0:
		return
	_on_moved(pointer)
	var slot: int = _slot
	var origin: Vector2i = board.ghost_origin
	var over_board: bool = board.has_ghost()
	cancel()
	if not over_board:
		returned.emit()
		return
	var result: MoveResult = place.call(slot, origin)
	if result != null:
		board.flash(result)
		placed.emit(result)
	else:
		returned.emit()


func _piece(slot: int) -> Piece:
	if slot < 0:
		return null
	var piece: Piece = piece_in.call(slot)
	return piece


func _overlaps_board(piece: Piece, origin: Vector2i) -> bool:
	for cell in piece.cells:
		if board.grid.has_cell(origin + cell):
			return true
	return false
