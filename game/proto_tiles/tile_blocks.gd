class_name TileBlocksScreen
extends Control
## Prototype 1, "tile blocks": the grid, the score, the three pieces to drag onto the grid,
## the bonus buttons (new pieces, mirror: free uses, then one use per rewarded ad), and the
## game-over panel, which offers to go on after a rewarded ad. The rules are in
## TileBlocksGame (game/core/); this scene shows them, turns the player's drags into moves
## and tells GameState what the player does (games, ad offers, bonuses).

const MENU_SCENE: String = "res://game/ui/main_menu.tscn"
## What each rewarded ad is for (Ads.show_rewarded).
const CONTINUE_PLACEMENT: String = "tile_blocks_continue"
const NEW_HAND_PLACEMENT: String = "tile_blocks_new_hand"
const MIRROR_PLACEMENT: String = "tile_blocks_mirror"
## Colour the bonus buttons pulse to while the player is in trouble.
const CALL_COLOR: Color = Color(1.0, 0.8, 0.3)
const CALL_PULSE_SECONDS: float = 0.45
## Text colour of a button that plays a rewarded ad: the player sees at once which ones do.
const AD_TEXT_COLOR: Color = Color(0.55, 0.85, 1.0)

@export var rules: TileBlocksRules
@export var art: TileArt

var game: TileBlocksGame
## Whether the next tap on a piece flips it (the mirror bonus) instead of turning it.
var mirroring: bool = false
var _drag: PieceDrag = PieceDrag.new()
## What the last refresh showed, to notice when it changes (offers are counted once).
var _was_over: bool = false
var _was_in_trouble: bool = false
var _call_tween: Tween = null

@onready var _background: ColorRect = %Background
@onready var _board: BoardView = %Board
@onready var _tray: TrayView = %Tray
@onready var _score: Label = %ScoreLabel
@onready var _level: Label = %LevelLabel
@onready var _combo: Label = %ComboLabel
@onready var _hint: Label = %HintLabel
@onready var _new_hand: Button = %NewHandButton
@onready var _mirror: Button = %MirrorButton
@onready var _game_over: Control = %GameOver
@onready var _final_score: Label = %FinalScoreLabel
@onready var _best_score: Label = %BestScoreLabel
@onready var _continue: Button = %ContinueButton
@onready var _over_new_hand: Button = %GameOverNewHandButton


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
	_new_hand.pressed.connect(use_new_hand)
	_over_new_hand.pressed.connect(use_new_hand)
	_mirror.pressed.connect(toggle_mirror)
	Events.rewarded_ad_ready_changed.connect(_on_rewarded_ad_ready_changed)
	Events.rewarded_ad_finished.connect(_on_rewarded_ad_finished)
	_tray.tapped.connect(_on_piece_tapped)
	_board.resized.connect(refresh)
	start(_new_seed())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		back_to_menu()


## A new game; the same seed gives the same pieces (tests). The game under way, if any,
## counts as played.
func start(random_seed: int) -> void:
	_finish_game()
	game = TileBlocksGame.new(rules, random_seed, GameState.progress.stats)
	_board.grid = game.grid
	_drag.cancel()
	mirroring = false
	_was_over = false
	_was_in_trouble = false
	refresh()


## Shows the state of the game again (after a move, or after a test changed it).
func refresh() -> void:
	if game == null:
		return
	_tray.board_cell = _board.cell_size()
	_tray.set_pieces(game.hand)
	_board.queue_redraw()
	_score.text = tr("HUD_SCORE") % game.score()
	_level.text = tr("HUD_DIFFICULTY") % game.level()
	_combo.text = tr("HUD_COMBO") % game.scores.combo
	_combo.visible = game.scores.combo >= 2
	var over: bool = game.is_over()
	if over:
		mirroring = false
		GameState.note_score(game.score())
	_hint.text = "HINT_MIRROR" if mirroring else "HINT_ROTATE"
	_show_bonus(_new_hand, TileBlocksGame.BONUS_NEW_HAND, "BONUS_NEW_HAND")
	_show_bonus(_mirror, TileBlocksGame.BONUS_MIRROR, "BONUS_MIRROR")
	if mirroring:
		_mirror.text = "BONUS_CANCEL"
		_mirror.disabled = false
	_final_score.text = tr("HUD_SCORE") % game.score()
	_best_score.text = tr("HUD_BEST") % GameState.progress.stats.best_score
	_game_over.visible = over
	_drag.locked = over
	_continue.visible = game.can_revive()
	_continue.disabled = not Ads.is_rewarded_ready()
	_mark_ad(_continue, true)
	_show_bonus(_over_new_hand, TileBlocksGame.BONUS_NEW_HAND, "BONUS_NEW_HAND")
	_over_new_hand.visible = (
		game.charges(TileBlocksGame.BONUS_NEW_HAND) > 0 or _can_buy(TileBlocksGame.BONUS_NEW_HAND)
	)
	_note_offers(over)
	_call_for_bonuses(game.is_in_trouble())


func back_to_menu() -> void:
	_finish_game()
	get_tree().change_scene_to_file(MENU_SCENE)


## The pointer position that drops the piece of `slot` with its corner on `origin` (tests).
func pointer_for(slot: int, origin: Vector2i) -> Vector2:
	return _drag.pointer_for(game.hand[slot], origin)


## The "new pieces" bonus button: uses a free use, or offers a rewarded ad for one.
func use_new_hand() -> void:
	if game.charges(TileBlocksGame.BONUS_NEW_HAND) > 0:
		_apply_new_hand()
	elif _can_buy(TileBlocksGame.BONUS_NEW_HAND) and Ads.is_rewarded_ready():
		Ads.show_rewarded(NEW_HAND_PLACEMENT)


## The mirror bonus button: the next tap on a piece flips it (a free use, or one bought with a
## rewarded ad); pressed again, it cancels without using anything.
func toggle_mirror() -> void:
	if mirroring:
		mirroring = false
	elif game.charges(TileBlocksGame.BONUS_MIRROR) > 0:
		mirroring = true
	elif _can_buy(TileBlocksGame.BONUS_MIRROR) and Ads.is_rewarded_ready():
		Ads.show_rewarded(MIRROR_PLACEMENT)
	refresh()


## Turns a piece of the tray a quarter turn (a tap on it), or flips it in mirror mode.
func rotate_piece(slot: int) -> void:
	if game.rotate(slot):
		refresh()


func _on_piece_tapped(slot: int) -> void:
	if not mirroring:
		rotate_piece(slot)
	elif game.mirror(slot):
		mirroring = false
		GameState.record_bonus(TileBlocksGame.BONUS_MIRROR)
		refresh()


func _apply_new_hand() -> void:
	if game.new_hand():
		_drag.cancel()
		GameState.record_bonus(TileBlocksGame.BONUS_NEW_HAND)
		refresh()


## Whether a use of `bonus` can still be bought with a rewarded ad in this game.
func _can_buy(bonus: String) -> bool:
	return game.can_earn(bonus)


## A bonus button: its free uses left, or "(ad)" when a rewarded ad buys one (disabled until
## the ad is ready), or disabled when none is left.
func _show_bonus(button: Button, bonus: String, key: String) -> void:
	var left: int = game.charges(bonus)
	var costs_ad: bool = left <= 0 and _can_buy(bonus)
	if costs_ad:
		button.text = tr(key + "_AD")
		button.disabled = not Ads.is_rewarded_ready()
	else:
		button.text = tr(key) % left
		button.disabled = left <= 0
	_mark_ad(button, costs_ad)


static func _mark_ad(button: Button, costs_ad: bool) -> void:
	for state: String in ["font_color", "font_hover_color", "font_pressed_color"]:
		if costs_ad:
			button.add_theme_color_override(state, AD_TEXT_COLOR)
		else:
			button.remove_theme_color_override(state)


## Counts the ad offers the player sees at the moment they are worth the most: the game-over
## panel with "continue", and the bonuses that cost an ad when the player gets in trouble.
func _note_offers(over: bool) -> void:
	var ad_ready: bool = Ads.is_rewarded_ready()
	if over and not _was_over and ad_ready:
		if game.can_revive():
			GameState.record_offer(CONTINUE_PLACEMENT)
		if (
			game.charges(TileBlocksGame.BONUS_NEW_HAND) <= 0
			and _can_buy(TileBlocksGame.BONUS_NEW_HAND)
		):
			GameState.record_offer(NEW_HAND_PLACEMENT)
	var in_trouble: bool = game.is_in_trouble()
	if in_trouble and not _was_in_trouble and ad_ready:
		for bonus: String in [TileBlocksGame.BONUS_NEW_HAND, TileBlocksGame.BONUS_MIRROR]:
			if game.charges(bonus) <= 0 and _can_buy(bonus):
				GameState.record_offer(_placement_of(bonus))
	_was_over = over
	_was_in_trouble = in_trouble


## While the player is in trouble, the bonus buttons pulse to call for attention.
func _call_for_bonuses(in_trouble: bool) -> void:
	if in_trouble == (_call_tween != null):
		return
	if _call_tween != null:
		_call_tween.kill()
		_call_tween = null
	for button: Button in [_new_hand, _mirror]:
		button.modulate = Color.WHITE
	if not in_trouble:
		return
	_call_tween = create_tween().set_loops()
	for color: Color in [CALL_COLOR, Color.WHITE]:
		_call_tween.tween_property(_new_hand, "modulate", color, CALL_PULSE_SECONDS)
		_call_tween.parallel().tween_property(_mirror, "modulate", color, CALL_PULSE_SECONDS)


## Whether the bonus buttons are calling for attention (tests).
func is_calling_for_bonuses() -> bool:
	return _call_tween != null


func _placement_of(bonus: String) -> String:
	return NEW_HAND_PLACEMENT if bonus == TileBlocksGame.BONUS_NEW_HAND else MIRROR_PLACEMENT


func _on_rewarded_ad_ready_changed(_is_ready: bool) -> void:
	refresh()


## A reward is given only when the player watched the ad to the end: the game goes on, or the
## bonus is used at once (new pieces) or ready for the next tap on a piece (mirror).
func _on_rewarded_ad_finished(placement: String, rewarded: bool) -> void:
	if not rewarded or game == null:
		return
	if placement == CONTINUE_PLACEMENT and game.revive():
		refresh()
	elif placement == NEW_HAND_PLACEMENT and game.earn(TileBlocksGame.BONUS_NEW_HAND):
		_apply_new_hand()
	elif placement == MIRROR_PLACEMENT and game.earn(TileBlocksGame.BONUS_MIRROR):
		mirroring = not game.is_over()
		refresh()


## The game under way counts as played (when a piece was placed).
func _finish_game() -> void:
	if game != null and game.moves > 0:
		GameState.record_game(game.score(), game.moves)
	game = null


func _new_seed() -> int:
	return int(Time.get_unix_time_from_system() * 1000.0) ^ Time.get_ticks_usec()
