class_name TileBlocksScreen
extends Control
## Prototype 1, "tile blocks": the grid, the score and the race to the record, the three
## pieces to drag onto the grid, the bonus buttons (new pieces, mirror: free uses, then one use
## per rewarded ad), and the game-over panel, which offers to go on after a rewarded ad. The
## rules are in TileBlocksGame (game/core/); this scene shows them, turns the player's drags
## into moves and tells GameState what the player does (games, ad offers, bonuses). Rewarded
## ads are offered only within their limits (AdPacingRules): not in a new player's first games,
## not beyond the daily limit, a continue only for a game worth going on.

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
## The record label grows this much, then shrinks back, when the record is beaten.
const RECORD_POP_SCALE: float = 1.4
const RECORD_POP_SECONDS: float = 0.25

@export var rules: TileBlocksRules
@export var art: TileArt
@export var juice: JuiceRules
## The daily challenge (G16): the same pieces for everyone today (a seed from the date), a
## difficulty that does not depend on the player's past games, and today's best as the record.
@export var daily: bool = false

var game: TileBlocksGame
## The race against the record of the game under way.
var chase: RecordChase = RecordChase.new(0)
## Whether the next tap on a piece flips it (the mirror bonus) instead of turning it.
var mirroring: bool = false
## Seconds since the player last did something (for the hint, G15).
var idle_seconds: float = 0.0
## The mirror's great move shown now (MirrorChance), or null.
var mirror_chance: MirrorChance = null
## Made in _ready, not here: the level scene swaps this script for LevelScreen, and a node
## made by the first script would be left orphaned.
var _drag: PieceDrag
## What the last refresh showed, to notice when it changes (offers are counted once).
var _was_over: bool = false
var _was_in_trouble: bool = false
var _call_tween: Tween = null
## The bonus buttons pulsing now.
var _called: Array[Button] = []
## Whether the hint was looked for since the player last did something.
var _hint_looked_for: bool = false
## The score the last refresh showed, to notice the moment the record is beaten.
var _shown_score: int = 0
## The fade of the end of a game (panel, grey grid).
var _mood_tween: Tween = null
## The combo the last refresh showed, to make the label jump when it grows.
var _shown_combo: int = 0

@onready var _board: BoardView = %Board
@onready var _tray: TrayView = %Tray
@onready var _score: Label = %ScoreLabel
@onready var _level: Label = %LevelLabel
@onready var _combo: Label = %ComboLabel
@onready var _record: Label = %RecordLabel
@onready var _record_progress: ProgressBar = %RecordProgress
@onready var _record_gap: Label = %RecordGapLabel
@onready var _hint: Label = %HintLabel
@onready var _new_hand: Button = %NewHandButton
@onready var _mirror: Button = %MirrorButton
@onready var _game_over: Control = %GameOver
@onready var _final_score: Label = %FinalScoreLabel
@onready var _best_score: Label = %BestScoreLabel
@onready var _continue: Button = %ContinueButton
@onready var _over_new_hand: Button = %GameOverNewHandButton
@onready var _end_title: Label = %GameOverTitle
@onready var _next_level: Button = %NextLevelButton
@onready var _extra_pieces: Button = %ExtraPiecesButton
@onready var _effects: ClearEffects = %Effects
@onready var _sounds: GameSounds = %Sounds


func _ready() -> void:
	_drag = PieceDrag.new()
	_board.art = art
	_tray.art = art
	(%DragLayer as DragLayer).art = art
	_drag.art = art
	_drag.connect_views(_board, _tray, %DragLayer as DragLayer)
	_drag.piece_in = func(slot: int) -> Piece: return game.hand[slot]
	_drag.can_place = func(slot: int, origin: Vector2i) -> bool: return game.can_place(slot, origin)
	_drag.place = func(slot: int, origin: Vector2i) -> MoveResult: return _place_piece(slot, origin)
	_drag.clears_for = func(slot: int, origin: Vector2i) -> Array[Vector2i]:
		if not game.can_place(slot, origin):
			return []
		return game.grid.clears_if_placed(game.hand[slot], origin, game.rules.match_size)
	_drag.placed.connect(_on_placed)
	_drag.picked.connect(func(_slot: int) -> void: _sounds.play_pick())
	_drag.returned.connect(_sounds.play_return)
	_effects.rules = juice
	_effects.rainbow = art.symbol_colors
	_tray.appear_seconds = juice.tray_appear_seconds
	add_child(_drag)
	(%MenuButton as Button).pressed.connect(back_to_menu)
	(%ReplayButton as Button).pressed.connect(
		func() -> void:
			_sounds.play_button()
			start(_first_seed())
	)
	(%GameOverMenuButton as Button).pressed.connect(back_to_menu)
	_continue.pressed.connect(continue_game)
	_new_hand.pressed.connect(use_new_hand)
	_over_new_hand.pressed.connect(use_new_hand)
	_mirror.pressed.connect(toggle_mirror)
	Events.rewarded_ad_ready_changed.connect(_on_rewarded_ad_ready_changed)
	Events.rewarded_ad_finished.connect(_on_rewarded_ad_finished)
	_tray.tapped.connect(_on_piece_tapped)
	_tray.drag_started.connect(func(_slot: int, _pointer: Vector2) -> void: _reset_idle())
	_board.resized.connect(refresh)
	start(_first_seed())


func _process(delta: float) -> void:
	if game == null or rules.hint_after_seconds <= 0.0 or _hint_looked_for:
		return
	if _game_over.visible or _drag.is_dragging():
		return
	idle_seconds += delta
	if idle_seconds >= rules.hint_after_seconds:
		_hint_looked_for = true
		var hint: MoveHint = MoveHint.find(game)
		if hint != null:
			_board.set_hint(hint.piece, hint.origin)


## The player did something: the hint goes, and the wait for the next one starts again.
func _reset_idle() -> void:
	idle_seconds = 0.0
	_hint_looked_for = false
	_board.clear_hint()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		back_to_menu()


## A new game; the same seed gives the same pieces (tests). The game under way, if any,
## counts as played.
func start(random_seed: int) -> void:
	_finish_game()
	game = _make_game(random_seed)
	var stats: PlayerStats = GameState.progress.stats
	chase = RecordChase.new(stats.daily_best_on(GameState.today()) if daily else stats.best_score)
	_shown_score = 0
	_shown_combo = 0
	_clear_end_mood()
	_reset_idle()
	_board.grid = game.grid
	_drag.cancel()
	mirroring = false
	_was_over = false
	_was_in_trouble = false
	mirror_chance = null
	refresh()


## Shows the state of the game again (after a move, or after a test changed it).
func refresh() -> void:
	if game == null:
		return
	_tray.board_cell = _board.cell_size()
	_tray.set_pieces(game.hand)
	_board.queue_redraw()
	_score.text = tr("HUD_SCORE") % game.score()
	_level.text = _top_text()
	_combo.text = tr("HUD_COMBO") % game.scores.combo
	_combo.visible = game.scores.combo >= 2
	if game.scores.combo > _shown_combo and _combo.visible:
		_punch(_combo, juice.score_punch_scale)
	_shown_combo = game.scores.combo
	_show_record()
	var over: bool = _is_finished()
	if over:
		mirroring = false
		_on_finished()
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
	var gift: bool = has_comeback_gift()
	_continue.visible = game.can_revive() and (gift or _can_continue_with_ad())
	_continue.text = "BUTTON_CONTINUE_FREE" if gift else "BUTTON_CONTINUE_AD"
	_continue.disabled = not gift and not Ads.is_rewarded_ready()
	_mark_ad(_continue, not gift)
	if daily:
		_best_score.text = (
			tr("HUD_DAILY_STREAK")
			% maxi(GameState.progress.stats.daily_streak_on(GameState.today()), 1)
		)
	_show_bonus(_over_new_hand, TileBlocksGame.BONUS_NEW_HAND, "BONUS_NEW_HAND")
	_over_new_hand.visible = (
		game.charges(TileBlocksGame.BONUS_NEW_HAND) > 0 or _can_buy(TileBlocksGame.BONUS_NEW_HAND)
	)
	_show_end_panel()
	var had_chance: bool = mirror_chance != null
	_show_mirror_chance(over)
	_show_end_mood(over)
	_note_offers(over)
	if mirror_chance != null and not had_chance and _mirror_costs_ad():
		GameState.record_offer(MIRROR_PLACEMENT)
	_call_for_bonuses(game.is_in_trouble(), mirror_chance != null)


## The end of a game, felt: the panel fades in; a lost game also greys the grid out and plays
## a gentle falling phrase. Back to normal colours when the game goes on (continue, new game).
func _show_end_mood(over: bool) -> void:
	if over == _was_over:
		return
	_clear_end_mood()
	if not over:
		return
	_mood_tween = create_tween().set_parallel()
	_game_over.modulate.a = 0.0
	_mood_tween.tween_property(_game_over, "modulate:a", 1.0, juice.game_over_fade_seconds * 0.5)
	if _is_lost_end():
		_sounds.play_game_over()
		_mood_tween.tween_property(
			_board, "modulate", art.game_over_tint, juice.game_over_fade_seconds
		)


func _clear_end_mood() -> void:
	if _mood_tween != null:
		_mood_tween.kill()
		_mood_tween = null
	_board.modulate = Color.WHITE
	_game_over.modulate.a = 1.0


## Whether the game ended lost (the level screen: a level can end won).
func _is_lost_end() -> bool:
	return true


## A new game for `random_seed` (the level screen makes a level instead).
func _make_game(random_seed: int) -> TileBlocksGame:
	var stats: PlayerStats = GameState.progress.stats
	return TileBlocksGame.new(_game_rules(), random_seed, null if daily else stats)


## Places a piece of the hand (the level screen counts its pieces).
func _place_piece(slot: int, origin: Vector2i) -> MoveResult:
	return game.place(slot, origin)


## Whether the game is over: the game-over panel shows (a level: won or lost).
func _is_finished() -> bool:
	return game.is_over()


## The game just ended, or the panel shows again: the best score is kept.
func _on_finished() -> void:
	GameState.note_score(game.score())


## The text in the middle of the top bar.
func _top_text() -> String:
	return tr("HUD_DAILY") if daily else tr("HUD_DIFFICULTY") % game.level()


## The end panel's title and level buttons (the level screen shows them).
func _show_end_panel() -> void:
	_end_title.text = "GAME_OVER"
	_next_level.visible = false
	_extra_pieces.visible = false


## The record, always on screen, with a bar that fills up towards it; when it is beaten, the
## label says so and pops.
func _show_record() -> void:
	var score: int = game.score()
	if chase.is_beaten(score):
		_record.text = tr("NEW_RECORD")
	else:
		_record.text = tr("HUD_DAILY_BEST" if daily else "HUD_BEST") % chase.record
	_record_progress.visible = chase.has_record()
	_record_progress.value = 100 if chase.is_beaten(score) else chase.percent(score)
	if chase.beaten_between(_shown_score, score):
		_pop_record()
		_effects.fireworks(art.symbol_colors)
		_sounds.play_record()
	_shown_score = score
	if chase.is_beaten(score):
		_record_gap.text = tr("NEW_RECORD")
	else:
		_record_gap.text = tr("DAILY_MISSING" if daily else "RECORD_MISSING") % chase.missing(score)
	_record_gap.visible = chase.has_record()


func _pop_record() -> void:
	_record.pivot_offset = _record.size / 2.0
	var pop: Tween = create_tween()
	pop.tween_property(_record, "scale", Vector2.ONE * RECORD_POP_SCALE, RECORD_POP_SECONDS)
	pop.tween_property(_record, "scale", Vector2.ONE, RECORD_POP_SECONDS)


## The rules of a new game: the scene's, with the player's choice of how pieces come back.
func _game_rules() -> TileBlocksRules:
	var refill_each_slot: bool = not Options.settings.refill_together
	if rules.refill_each_slot == refill_each_slot:
		return rules
	var chosen: TileBlocksRules = rules.duplicate()
	chosen.refill_each_slot = refill_each_slot
	return chosen


## Whether the next continue is free: the comeback gift (G14), once a day after days away.
func has_comeback_gift() -> bool:
	return GameState.has_comeback_gift(rules.comeback_days)


## The continue button: free with the comeback gift, otherwise after a rewarded ad.
func continue_game() -> void:
	if has_comeback_gift():
		if game.revive():
			GameState.use_comeback_gift()
			refresh()
	elif _can_continue_with_ad() and Ads.is_rewarded_ready():
		Ads.show_rewarded(_continue_placement())


## What the continue's rewarded ad is for (the level screen has its own).
func _continue_placement() -> String:
	return CONTINUE_PLACEMENT


## The continue after its rewarded ad; false when not allowed.
func _revive_with_ad() -> bool:
	return game.revive(true)


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
	_sounds.play_button()
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
		_sounds.play_rotate()
		refresh()


## The feedback of a move (G13), stronger as the move is: the piece lands with a clack and
## its points rise; a clear sweeps light along its lines, throws fragments and sparkles,
## shakes the board, plays an arpeggio rising with the combo, shows a word of praise and
## vibrates; then the screen shows the new state.
func _on_placed(result: MoveResult) -> void:
	_reset_idle()
	_sounds.play_place()
	_board.pop(result.placed, juice.pop_scale, juice.pop_seconds)
	var piece_center: Vector2 = _center_of(result.placed)
	if result.points > 0:
		_effects.points(tr("POINTS_GAINED") % result.points, piece_center, CALL_COLOR)
		_punch(_score, juice.score_punch_scale)
	var strength: int = ClearPraise.strength(result, juice.empty_grid_strength)
	if strength > 0:
		var strong: bool = strength >= juice.sparkle_min_strength
		_sounds.play_clear(ClearPraise.combo_pitch(result.combo, juice.combo_semitones), strong)
		_burst(result, strength)
		_beams(result)
		_effects.ring(
			piece_center, _board.cell_size() * juice.ring_cells, CALL_COLOR, juice.ring_seconds
		)
		if strong:
			_effects.sparkles(
				piece_center,
				juice.sparkles_per_strength * strength,
				juice.fragment_speed,
				art.symbol_colors
			)
		_board.shake(
			minf(strength * juice.shake_pixels_per_clear, juice.shake_max_pixels),
			juice.shake_seconds
		)
		_praise(result, strength)
		if Options.settings.vibration:
			Input.vibrate_handheld(
				mini(juice.vibration_ms_per_clear * strength, juice.vibration_max_ms)
			)
	if result.empty_grid:
		_sounds.play_empty_grid()
		var board_center: Vector2 = _board.global_position + _board.size / 2.0
		_effects.ring(board_center, _board.size.x, Color.WHITE, juice.ring_seconds * 2.0)
		_effects.fireworks(art.symbol_colors)
	refresh()


func _burst(result: MoveResult, strength: int) -> void:
	var centers: Array[Vector2] = []
	var colors: Array[Color] = []
	for index in result.clear.cells.size():
		centers.append(_board.cell_center(result.clear.cells[index]))
		var symbol: int = result.cleared_symbols[index]
		colors.append(
			art.stone_face if symbol < 0 else art.symbol_colors[symbol % art.symbol_colors.size()]
		)
	var per_cell: int = juice.fragments_per_cell + juice.fragments_per_strength * (strength - 1)
	_effects.burst(centers, colors, per_cell, juice.fragment_speed)


## Light along each cleared row and column (a full one: every cell of it was cleared).
func _beams(result: MoveResult) -> void:
	var cleared: Dictionary[Vector2i, bool] = {}
	for cell in result.clear.cells:
		cleared[cell] = true
	var lines: int = game.grid.size
	var side: float = _board.cell_size()
	for line in lines:
		var row: bool = true
		var column: bool = true
		for step in lines:
			row = row and cleared.has(Vector2i(step, line))
			column = column and cleared.has(Vector2i(line, step))
		if row:
			var at: Vector2 = _board.global_position + Vector2(0.0, line * side)
			_effects.beam(Rect2(at, Vector2(lines * side, side)), CALL_COLOR)
		if column:
			var at: Vector2 = _board.global_position + Vector2(line * side, 0.0)
			_effects.beam(Rect2(at, Vector2(side, lines * side)), CALL_COLOR)


func _praise(result: MoveResult, strength: int) -> void:
	var text: String = ""
	var word: int = ClearPraise.word(strength, juice.praise_thresholds)
	if result.empty_grid:
		text = tr("PRAISE_EMPTY_GRID") % rules.scoring.empty_grid_bonus
		word = juice.praise_thresholds.size()
	elif word > 0:
		text = tr("PRAISE_%d" % word)
	if not text.is_empty():
		var center: Vector2 = _board.global_position + _board.size / 2.0
		_effects.praise(text, center, word)


## Centre of `cells` of the grid, in global coordinates.
func _center_of(cells: Array[Vector2i]) -> Vector2:
	var total: Vector2 = Vector2.ZERO
	for cell in cells:
		total += _board.cell_center(cell)
	return total / maxf(cells.size(), 1.0)


## Makes `control` jump: bigger, then back to its size.
func _punch(control: Control, scale_to: float) -> void:
	control.pivot_offset = control.size / 2.0
	var tween: Tween = control.create_tween()
	tween.tween_property(control, "scale", Vector2.ONE * scale_to, 0.08)
	tween.tween_property(control, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(
		Tween.EASE_OUT
	)


func _on_piece_tapped(slot: int) -> void:
	_reset_idle()
	if not mirroring:
		rotate_piece(slot)
	elif game.mirror(slot):
		mirroring = false
		_sounds.play_mirror()
		GameState.record_bonus(TileBlocksGame.BONUS_MIRROR)
		refresh()


func _apply_new_hand() -> void:
	if game.new_hand():
		_sounds.play_new_hand()
		_reset_idle()
		_drag.cancel()
		GameState.record_bonus(TileBlocksGame.BONUS_NEW_HAND)
		refresh()


## Whether a use of `bonus` can be bought with a rewarded ad now.
func _can_buy(bonus: String) -> bool:
	return _ads_open() and game.can_earn(bonus)


## Whether rewarded ads may be offered now (AdPacing): not in a new player's first games, not
## beyond the daily limit.
func _ads_open() -> bool:
	return GameState.can_offer_rewarded(game.pacing, true)


## Whether the continue can be bought with a rewarded ad: ads open, ads left in this game, and
## a game worth going on (close enough to the record, or one of the player's first games).
func _can_continue_with_ad() -> bool:
	if not _ads_open() or not game.can_revive_with_ad():
		return false
	var played: int = GameState.progress.stats.games_played
	return AdPacing.worth_reviving(game.pacing, game.score(), chase.record, played)


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
		if _can_continue_with_ad() and not has_comeback_gift():
			GameState.record_offer(_continue_placement())
		if (
			_over_new_hand.visible
			and game.charges(TileBlocksGame.BONUS_NEW_HAND) <= 0
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


## The mirror's great move (MirrorChance): when the mirror can be used (a free use, or a
## rewarded ad ready), its move shows on the grid and the mirror button pulses.
func _show_mirror_chance(over: bool) -> void:
	var shown: bool = mirror_chance != null
	mirror_chance = null
	var usable: bool = (
		mirroring
		or game.charges(TileBlocksGame.BONUS_MIRROR) > 0
		or (_can_buy(TileBlocksGame.BONUS_MIRROR) and Ads.is_rewarded_ready())
	)
	if not over and usable:
		mirror_chance = MirrorChance.find(game)
	if mirror_chance != null:
		_hint_looked_for = true
		_board.set_hint(mirror_chance.piece, mirror_chance.origin)
	elif shown:
		_board.clear_hint()


## Whether the next use of the mirror costs a rewarded ad.
func _mirror_costs_ad() -> bool:
	return game.charges(TileBlocksGame.BONUS_MIRROR) <= 0 and _can_buy(TileBlocksGame.BONUS_MIRROR)


## While the player is in trouble, the bonus buttons pulse to call for attention; the mirror
## alone when it opens a great move.
func _call_for_bonuses(in_trouble: bool, mirror_has_chance: bool) -> void:
	var buttons: Array[Button] = []
	if in_trouble:
		buttons = [_new_hand, _mirror]
	elif mirror_has_chance:
		buttons = [_mirror]
	if buttons == _called:
		return
	_called = buttons
	if _call_tween != null:
		_call_tween.kill()
		_call_tween = null
	for button: Button in [_new_hand, _mirror]:
		button.modulate = Color.WHITE
	if buttons.is_empty():
		return
	_call_tween = create_tween().set_loops()
	for color: Color in [CALL_COLOR, Color.WHITE]:
		_call_tween.tween_property(buttons[0], "modulate", color, CALL_PULSE_SECONDS)
		for button: Button in buttons.slice(1):
			_call_tween.parallel().tween_property(button, "modulate", color, CALL_PULSE_SECONDS)


## Whether the bonus buttons are calling for attention (tests).
func is_calling_for_bonuses() -> bool:
	return _call_tween != null


## The bonus buttons pulsing now (tests).
func called_buttons() -> Array[Button]:
	return _called


func _placement_of(bonus: String) -> String:
	return NEW_HAND_PLACEMENT if bonus == TileBlocksGame.BONUS_NEW_HAND else MIRROR_PLACEMENT


func _on_rewarded_ad_ready_changed(_is_ready: bool) -> void:
	refresh()


## A reward is given only when the player watched the ad to the end: the game goes on, or the
## bonus is used at once (new pieces) or ready for the next tap on a piece (mirror).
func _on_rewarded_ad_finished(placement: String, rewarded: bool) -> void:
	if not rewarded or game == null:
		return
	if placement == _continue_placement() and _revive_with_ad():
		refresh()
	elif placement == NEW_HAND_PLACEMENT and game.earn(TileBlocksGame.BONUS_NEW_HAND):
		_apply_new_hand()
	elif placement == MIRROR_PLACEMENT and game.earn(TileBlocksGame.BONUS_MIRROR):
		mirroring = not game.is_over()
		refresh()


## The game under way counts as played (when a piece was placed).
func _finish_game() -> void:
	if game != null and game.moves > 0:
		if daily:
			GameState.record_daily(game.score())
		GameState.record_game(game.score(), game.moves)
	game = null


## The seed of a new game: today's challenge, or a fresh one.
func _first_seed() -> int:
	return DailyChallenge.seed_for(GameState.today()) if daily else _new_seed()


func _new_seed() -> int:
	return int(Time.get_unix_time_from_system() * 1000.0) ^ Time.get_ticks_usec()
