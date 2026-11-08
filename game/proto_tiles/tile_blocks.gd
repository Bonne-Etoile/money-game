class_name TileBlocksScreen
extends Control
## Prototype 1, "tile blocks": the grid, the score, the three pieces to drag onto the grid,
## and the game-over panel. The rules are in TileBlocksGame (game/core/); this scene shows
## them and turns the player's drags into moves.

const MENU_SCENE: String = "res://game/ui/main_menu.tscn"

@export var rules: TileBlocksRules
@export var art: TileArt

var game: TileBlocksGame
var _drag_slot: int = -1

@onready var _background: ColorRect = %Background
@onready var _board: BoardView = %Board
@onready var _tray: TrayView = %Tray
@onready var _drag_layer: DragLayer = %DragLayer
@onready var _score: Label = %ScoreLabel
@onready var _combo: Label = %ComboLabel
@onready var _game_over: Control = %GameOver
@onready var _final_score: Label = %FinalScoreLabel


func _ready() -> void:
	_background.color = art.background
	_board.art = art
	_tray.art = art
	_drag_layer.art = art
	_tray.drag_started.connect(_on_drag_started)
	_tray.drag_moved.connect(_on_drag_moved)
	_tray.drag_ended.connect(_on_drag_ended)
	(%MenuButton as Button).pressed.connect(back_to_menu)
	(%ReplayButton as Button).pressed.connect(func() -> void: start(_new_seed()))
	(%GameOverMenuButton as Button).pressed.connect(back_to_menu)
	_board.resized.connect(func() -> void: _tray.board_cell = _board.cell_size())
	start(_new_seed())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		back_to_menu()


## A new game; the same seed gives the same pieces (tests).
func start(random_seed: int) -> void:
	game = TileBlocksGame.new(rules, random_seed)
	_board.grid = game.grid
	_cancel_drag()
	refresh()


## Shows the state of the game again (after a move, or after a test changed it).
func refresh() -> void:
	_tray.board_cell = _board.cell_size()
	_tray.set_pieces(game.hand)
	_board.queue_redraw()
	_score.text = tr("HUD_SCORE") % game.score()
	_combo.text = tr("HUD_COMBO") % game.scores.combo
	_combo.visible = game.scores.combo >= 2
	_final_score.text = tr("HUD_SCORE") % game.score()
	_game_over.visible = game.is_over()


func back_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)


## Where the top-left corner of the dragged piece is drawn: above the pointer, so that the
## finger does not hide it.
func dragged_corner(piece: Piece, pointer: Vector2) -> Vector2:
	var cell: float = _board.cell_size()
	var extent: Vector2 = Vector2(piece.extent()) * cell
	return pointer - Vector2(extent.x / 2.0, extent.y + art.drag_lift_cells * cell)


## The pointer position that drops the piece of `slot` with its top-left corner on `origin`
## (tests, and the reverse of dragged_corner).
func pointer_for(slot: int, origin: Vector2i) -> Vector2:
	var piece: Piece = game.hand[slot]
	var cell: float = _board.cell_size()
	var extent: Vector2 = Vector2(piece.extent()) * cell
	var corner: Vector2 = _board.global_position + Vector2(origin) * cell
	return corner + Vector2(extent.x / 2.0, extent.y + art.drag_lift_cells * cell)


func _on_drag_started(slot: int, pointer: Vector2) -> void:
	if game.is_over():
		return
	_drag_slot = slot
	_tray.hidden_slot = slot
	_tray.queue_redraw()
	_on_drag_moved(pointer)


func _on_drag_moved(pointer: Vector2) -> void:
	if _drag_slot < 0:
		return
	var piece: Piece = game.hand[_drag_slot]
	var corner: Vector2 = dragged_corner(piece, pointer)
	_drag_layer.show_piece(piece, corner, _board.cell_size())
	var origin: Vector2i = _board.nearest_cell(corner)
	if _overlaps_board(piece, origin):
		_board.set_ghost(piece, origin, game.can_place(_drag_slot, origin))
	else:
		_board.clear_ghost()


func _on_drag_ended(pointer: Vector2) -> void:
	if _drag_slot < 0:
		return
	_on_drag_moved(pointer)
	var slot: int = _drag_slot
	var origin: Vector2i = _board.ghost_origin
	var over_board: bool = _board.has_ghost()
	_cancel_drag()
	if over_board:
		var result: MoveResult = game.place(slot, origin)
		if result != null:
			_board.flash(result)
	refresh()


func _cancel_drag() -> void:
	_drag_slot = -1
	_tray.hidden_slot = -1
	_drag_layer.hide_piece()
	_board.clear_ghost()


func _overlaps_board(piece: Piece, origin: Vector2i) -> bool:
	for cell in piece.cells:
		if game.grid.has_cell(origin + cell):
			return true
	return false


func _new_seed() -> int:
	return int(Time.get_unix_time_from_system() * 1000.0) ^ Time.get_ticks_usec()
