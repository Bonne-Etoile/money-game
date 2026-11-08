class_name TileBlocksScreen
extends Control
## Prototype 1, "tile blocks": the grid, the score, the three pieces to drag onto the grid,
## and the game-over panel, which offers to go on after a rewarded ad. The rules are in
## TileBlocksGame (game/core/); this scene shows them and turns the player's drags into moves.

const MENU_SCENE: String = "res://game/ui/main_menu.tscn"
## What the rewarded ad of the game-over panel is for (Ads.show_rewarded).
const CONTINUE_PLACEMENT: String = "tile_blocks_continue"

@export var rules: TileBlocksRules
@export var art: TileArt

var game: TileBlocksGame
var _drag: PieceDrag = PieceDrag.new()

@onready var _background: ColorRect = %Background
@onready var _board: BoardView = %Board
@onready var _tray: TrayView = %Tray
@onready var _score: Label = %ScoreLabel
@onready var _combo: Label = %ComboLabel
@onready var _game_over: Control = %GameOver
@onready var _final_score: Label = %FinalScoreLabel
@onready var _continue: Button = %ContinueButton


func _ready() -> void:
	_background.color = art.background
	_board.art = art
	_tray.art = art
	(%DragLayer as DragLayer).art = art
	_drag.art = art
	_drag.connect_views(_board, _tray, %DragLayer as DragLayer)
	_drag.piece_in = func(slot: int) -> Piece: return game.hand[slot]
	_drag.can_place = func(slot: int, origin: Vector2i) -> bool: return game.can_place(slot, origin)
	_drag.place = func(slot: int, origin: Vector2i) -> MoveResult: return game.place(slot, origin)
	_drag.placed.connect(func(_result: MoveResult) -> void: refresh())
	add_child(_drag)
	(%MenuButton as Button).pressed.connect(back_to_menu)
	(%ReplayButton as Button).pressed.connect(func() -> void: start(_new_seed()))
	(%GameOverMenuButton as Button).pressed.connect(back_to_menu)
	_continue.pressed.connect(func() -> void: Ads.show_rewarded(CONTINUE_PLACEMENT))
	Events.rewarded_ad_ready_changed.connect(_on_rewarded_ad_ready_changed)
	Events.rewarded_ad_finished.connect(_on_rewarded_ad_finished)
	_board.resized.connect(refresh)
	start(_new_seed())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		back_to_menu()


## A new game; the same seed gives the same pieces (tests).
func start(random_seed: int) -> void:
	game = TileBlocksGame.new(rules, random_seed)
	_board.grid = game.grid
	_drag.cancel()
	refresh()


## Shows the state of the game again (after a move, or after a test changed it).
func refresh() -> void:
	if game == null:
		return
	_tray.board_cell = _board.cell_size()
	_tray.set_pieces(game.hand)
	_board.queue_redraw()
	_score.text = tr("HUD_SCORE") % game.score()
	_combo.text = tr("HUD_COMBO") % game.scores.combo
	_combo.visible = game.scores.combo >= 2
	_final_score.text = tr("HUD_SCORE") % game.score()
	_game_over.visible = game.is_over()
	_drag.locked = _game_over.visible
	_continue.visible = game.can_revive()
	_continue.disabled = not Ads.is_rewarded_ready()


func back_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)


## The pointer position that drops the piece of `slot` with its corner on `origin` (tests).
func pointer_for(slot: int, origin: Vector2i) -> Vector2:
	return _drag.pointer_for(game.hand[slot], origin)


func _on_rewarded_ad_ready_changed(_is_ready: bool) -> void:
	refresh()


## The game goes on only when the player watched the ad to the end.
func _on_rewarded_ad_finished(placement: String, rewarded: bool) -> void:
	if placement == CONTINUE_PLACEMENT and rewarded and game.revive():
		refresh()


func _new_seed() -> int:
	return int(Time.get_unix_time_from_system() * 1000.0) ^ Time.get_ticks_usec()
