class_name StampScreen
extends Control
## The "stamp" prototype (G7, Stelio's idea): the pile at the top left, the shape to stamp and
## the upcoming ones at the top right, the piece in hand, and the grid below. Drag the shape
## onto the pile: it takes the tiles under it; then drag the tiled piece onto the grid.
## The rules are in StampGame (game/core/).

const MENU_SCENE: String = "res://game/ui/main_menu.tscn"
## Size of the upcoming shapes compared with the pile's cells.
const PREVIEW_SCALE: float = 0.5

@export var rules: StampRules
@export var art: TileArt

var game: StampGame
var level_index: int = 0
## Seed of the shapes; tests set it before start_level.
var shape_seed: int = 0
var _stamp_drag: PieceDrag = PieceDrag.new()
var _piece_drag: PieceDrag = PieceDrag.new()

@onready var _pile: PileView = %Pile
@onready var _shape_tray: TrayView = %ShapeTray
@onready var _next_tray: TrayView = %NextTray
@onready var _hand: TrayView = %Hand
@onready var _board: BoardView = %Board
@onready var _score: Label = %ScoreLabel
@onready var _level: Label = %LevelLabel
@onready var _end: Control = %EndPanel
@onready var _end_title: Label = %EndTitle
@onready var _end_score: Label = %EndScoreLabel
@onready var _next: Button = %NextButton


func _ready() -> void:
	(%Background as ColorRect).color = art.background
	var layer: DragLayer = %DragLayer as DragLayer
	layer.art = art
	for view: Control in [_pile, _board]:
		(view as BoardView).art = art
	for tray: TrayView in [_shape_tray, _next_tray, _hand]:
		tray.art = art
	_hand.show_slots = true
	_next_tray.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stamp_drag.art = art
	_stamp_drag.connect_views(_pile, _shape_tray, layer)
	_stamp_drag.piece_in = func(_slot: int) -> Piece: return game.current_shape()
	_stamp_drag.can_place = func(_slot: int, origin: Vector2i) -> bool:
		return game.can_stamp(origin)
	_stamp_drag.place = func(_slot: int, origin: Vector2i) -> MoveResult: return game.stamp(origin)
	_stamp_drag.placed.connect(func(_result: MoveResult) -> void: refresh())
	add_child(_stamp_drag)
	_piece_drag.art = art
	_piece_drag.connect_views(_board, _hand, layer)
	_piece_drag.piece_in = func(slot: int) -> Piece: return game.hand[slot]
	_piece_drag.can_place = func(slot: int, origin: Vector2i) -> bool:
		return game.can_place(slot, origin)
	_piece_drag.place = func(slot: int, origin: Vector2i) -> MoveResult:
		return game.place(slot, origin)
	_piece_drag.placed.connect(func(_result: MoveResult) -> void: refresh())
	add_child(_piece_drag)
	(%MenuButton as Button).pressed.connect(back_to_menu)
	(%EndMenuButton as Button).pressed.connect(back_to_menu)
	(%RetryButton as Button).pressed.connect(func() -> void: start_level(level_index))
	_next.pressed.connect(func() -> void: start_level(level_index + 1))
	_board.resized.connect(refresh)
	shape_seed = int(Time.get_unix_time_from_system()) ^ Time.get_ticks_usec()
	start_level(0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		back_to_menu()


func start_level(index: int) -> void:
	level_index = clampi(index, 0, rules.levels.size() - 1)
	game = StampGame.new(rules, rules.levels[level_index], shape_seed + level_index)
	_pile.pile = game.pile
	_board.grid = game.grid
	_stamp_drag.cancel()
	_piece_drag.cancel()
	refresh()


func refresh() -> void:
	if game == null:
		return
	_pile.refresh()
	_board.queue_redraw()
	_shape_tray.board_cell = _pile.cell_size()
	var current: Array[Piece] = [game.current_shape()]
	_shape_tray.set_pieces(current)
	_next_tray.board_cell = _pile.cell_size() * PREVIEW_SCALE
	_next_tray.set_pieces(game.queue.slice(1))
	_hand.board_cell = _board.cell_size()
	_hand.set_pieces(game.hand)
	_score.text = tr("HUD_SCORE") % game.score()
	_level.text = tr("HUD_LEVEL") % [level_index + 1, rules.levels.size()]
	var won: bool = game.is_won()
	_end.visible = won or game.is_lost()
	_stamp_drag.locked = _end.visible
	_piece_drag.locked = _end.visible
	_end_title.text = "LEVEL_WON" if won else "GAME_OVER"
	_end_score.text = tr("HUD_SCORE") % game.score()
	_next.visible = won and level_index + 1 < rules.levels.size()


func back_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)


## The pointer position that stamps the current shape with its corner on `origin` (tests).
func pointer_for_stamp(origin: Vector2i) -> Vector2:
	return _stamp_drag.pointer_for(game.current_shape(), origin)


## The pointer position that drops the piece in hand with its corner on `origin` (tests).
func pointer_for_place(origin: Vector2i) -> Vector2:
	return _piece_drag.pointer_for(game.hand[0], origin)
