class_name LevelScreen
extends TileBlocksScreen
## A level of the level mode (G17), on the screen of the endless game: the level's starting
## grid (gold, ice, stones drawn by the board), its goal with a bar in place of the record, the
## pieces left in the top bar, and an end panel that offers the next level, "+5 pieces" after a
## rewarded ad when the pieces ran out, a continue after a rewarded ad when no piece fits, or
## to try again. The rules are in LevelGame.

const MAP_SCENE: String = "res://game/levels/level_map.tscn"
const EXTRA_PIECES_PLACEMENT: String = "level_extra_pieces"
const LEVEL_CONTINUE_PLACEMENT: String = "level_continue"
const GOAL_KEYS: Dictionary[LevelDefinition.Goal, String] = {
	LevelDefinition.Goal.SCORE: "GOAL_SCORE",
	LevelDefinition.Goal.TRIOS: "GOAL_TRIOS",
	LevelDefinition.Goal.GOLD: "GOAL_GOLD",
}
## Symbol names for the goals, by symbol (0 circle ... 4 star).
const SYMBOL_KEYS: Array[String] = [
	"SYMBOL_CIRCLES", "SYMBOL_SQUARES", "SYMBOL_TRIANGLES", "SYMBOL_DIAMONDS", "SYMBOL_STARS"
]

@export var levels: LevelSet
## The level played, from 0 (set before the screen enters the tree).
@export var level_index: int = 0

var level: LevelGame
var _won_noted: bool = false


func _ready() -> void:
	super._ready()
	_next_level.pressed.connect(next_level)
	_extra_pieces.pressed.connect(buy_extra_pieces)


## Plays the level after this one (the map when it was the last).
func next_level() -> void:
	if level_index + 1 >= levels.levels.size():
		_open_map()
		return
	level_index += 1
	start(_first_seed())


## "+5 pieces": a rewarded ad, then more pieces (LevelSet.extra_pieces).
func buy_extra_pieces() -> void:
	if level.can_add_pieces() and _ads_open() and Ads.is_rewarded_ready():
		Ads.show_rewarded(EXTRA_PIECES_PLACEMENT)


func back_to_menu() -> void:
	_finish_game()
	_open_map()


func _open_map() -> void:
	get_tree().change_scene_to_file(MAP_SCENE)


func _make_game(_random_seed: int) -> TileBlocksGame:
	level = LevelGame.new(levels.levels[level_index], rules, levels)
	_won_noted = false
	_board.layer = level.game.layer
	return level.game


func _place_piece(slot: int, origin: Vector2i) -> MoveResult:
	return level.place(slot, origin)


func _is_finished() -> bool:
	return level.is_won() or level.is_lost()


func _on_finished() -> void:
	if level.is_won() and not _won_noted:
		_won_noted = true
		GameState.record_level_won(level_index)
		_sounds.play_record()
		_effects.fireworks(art.symbol_colors)


func _is_lost_end() -> bool:
	return not level.is_won()


func _top_text() -> String:
	return tr("HUD_LEVEL_PIECES") % [level_index + 1, level.pieces_left]


## The goal in place of the record: what to do, how far, and a bar.
func _show_record() -> void:
	var goal: LevelDefinition = level.definition
	var text: String = tr(GOAL_KEYS[goal.goal])
	if goal.goal == LevelDefinition.Goal.TRIOS:
		text = text % [goal.goal_count, tr(SYMBOL_KEYS[goal.goal_symbol % SYMBOL_KEYS.size()])]
	elif goal.goal == LevelDefinition.Goal.SCORE:
		text = text % goal.goal_count
	_record.text = (
		text + "  " + tr("GOAL_PROGRESS") % [mini(level.progress(), level.target()), level.target()]
	)
	_record_progress.visible = true
	_record_progress.value = (
		100.0 * mini(level.progress(), level.target()) / maxi(level.target(), 1)
	)
	_record_gap.visible = false


func _show_end_panel() -> void:
	var won: bool = level.is_won()
	if won:
		_end_title.text = "LEVEL_WON"
	elif level.pieces_left <= 0:
		_end_title.text = "LEVEL_NO_PIECES"
	else:
		_end_title.text = "GAME_OVER"
	_next_level.visible = won
	# New pieces make no sense once a level is over: its pieces are counted.
	_over_new_hand.visible = false
	_extra_pieces.visible = level.can_add_pieces() and _ads_open()
	_extra_pieces.text = tr("BUTTON_EXTRA_PIECES_AD") % levels.extra_pieces
	_extra_pieces.disabled = not Ads.is_rewarded_ready()
	_mark_ad(_extra_pieces, true)
	_best_score.visible = false
	(%ReplayButton as Button).text = "BUTTON_RETRY"


## A continue in a level always costs a rewarded ad: no comeback gift here.
func has_comeback_gift() -> bool:
	return false


## The continue of a level: when no piece fits but pieces are left (LevelGame.can_revive).
func _can_continue_with_ad() -> bool:
	return level != null and level.can_revive() and _ads_open()


func _continue_placement() -> String:
	return LEVEL_CONTINUE_PLACEMENT


func _revive_with_ad() -> bool:
	return level.revive()


## In the level mode, a new player may see ads from the start: there are no free games to
## learn with first (only the daily limit counts).
func _ads_open() -> bool:
	return GameState.can_offer_rewarded(game.pacing, false)


## The ad offers of a level: "+5 pieces" too.
func _note_offers(over: bool) -> void:
	if over and not _was_over and Ads.is_rewarded_ready() and _ads_open():
		if level.can_add_pieces():
			GameState.record_offer(EXTRA_PIECES_PLACEMENT)
	super._note_offers(over)


func _on_rewarded_ad_finished(placement: String, rewarded: bool) -> void:
	if placement == EXTRA_PIECES_PLACEMENT:
		if rewarded and level != null and level.add_pieces():
			refresh()
		return
	super._on_rewarded_ad_finished(placement, rewarded)


## A level does not count as a game of the endless mode.
func _finish_game() -> void:
	game = null


## Each level always deals the same pieces.
func _first_seed() -> int:
	return levels.levels[level_index].random_seed
