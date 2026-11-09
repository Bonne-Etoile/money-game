class_name PyramidScreen
extends Control
## Prototype 2, "the pyramid gives the pieces": the pile at the top, the tray of taken pieces,
## the grid below, and the end-of-level panel. The rules are in PyramidGame (game/core/).

const MENU_SCENE: String = "res://game/ui/main_menu.tscn"

@export var rules: PyramidRules
@export var art: TileArt

var game: PyramidGame
## Index of the level under way in `rules.levels`.
var level_index: int = 0
var _drag: PieceDrag = PieceDrag.new()

@onready var _board: BoardView = %Board
@onready var _tray: TrayView = %Tray
@onready var _stack: StackView = %Stack
@onready var _score: Label = %ScoreLabel
@onready var _level: Label = %LevelLabel
@onready var _end: Control = %EndPanel
@onready var _end_title: Label = %EndTitle
@onready var _end_score: Label = %EndScoreLabel
@onready var _next: Button = %NextButton


func _ready() -> void:
	(%Background as ColorRect).color = art.background
	_board.art = art
	_tray.art = art
	_tray.show_slots = true
	_stack.art = art
	(%DragLayer as DragLayer).art = art
	_drag.art = art
	_drag.connect_views(_board, _tray, %DragLayer as DragLayer)
	_drag.piece_in = func(slot: int) -> Piece: return game.tray[slot]
	_drag.can_place = func(slot: int, origin: Vector2i) -> bool: return game.can_place(slot, origin)
	_drag.place = func(slot: int, origin: Vector2i) -> MoveResult: return game.place(slot, origin)
	_drag.placed.connect(func(_result: MoveResult) -> void: refresh())
	add_child(_drag)
	_stack.tile_tapped.connect(take)
	_tray.tapped.connect(rotate_piece)
	(%MenuButton as Button).pressed.connect(back_to_menu)
	(%EndMenuButton as Button).pressed.connect(back_to_menu)
	(%RetryButton as Button).pressed.connect(func() -> void: start_level(level_index))
	_next.pressed.connect(func() -> void: start_level(level_index + 1))
	_board.resized.connect(refresh)
	start_level(0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		back_to_menu()


func start_level(index: int) -> void:
	level_index = clampi(index, 0, rules.levels.size() - 1)
	game = PyramidGame.new(rules, rules.levels[level_index])
	_board.grid = game.grid
	_stack.stack = game.stack
	_drag.cancel()
	refresh()


## Takes a tile of the pile into the tray (when it is free and the tray has room).
func take(index: int) -> void:
	if _end.visible or _drag.is_dragging():
		return
	if game.take(index):
		refresh()


func refresh() -> void:
	if game == null:
		return
	_tray.board_cell = _board.cell_size()
	_tray.set_pieces(game.tray)
	_stack.can_take = game.tray.has(null)
	_stack.queue_redraw()
	_board.queue_redraw()
	_score.text = tr("HUD_SCORE") % game.score()
	_level.text = tr("HUD_LEVEL") % [level_index + 1, rules.levels.size()]
	var won: bool = game.is_won()
	_end.visible = won or game.is_lost()
	_drag.locked = _end.visible
	_end_title.text = "LEVEL_WON" if won else "GAME_OVER"
	_end_score.text = tr("HUD_SCORE") % game.score()
	_next.visible = won and level_index + 1 < rules.levels.size()


func back_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)


## The pointer position that drops the piece of `slot` with its corner on `origin` (tests).
func pointer_for(slot: int, origin: Vector2i) -> Vector2:
	return _drag.pointer_for(game.tray[slot], origin)


## Turns a piece of the tray a quarter turn (a tap on it).
func rotate_piece(slot: int) -> void:
	if game.rotate(slot):
		refresh()
