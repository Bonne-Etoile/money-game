extends Node
## The playthrough under way (GameProgress) and its save slot. The only place that changes the
## state: scenes call its methods, which apply GameProgress's rules and emit Events' signals.
## Saves are written only when a slot is chosen: tests and screenshots never write anything.
## The exported game opens the player's latest slot at start (one profile, no slot menu) and
## counts the session; it also keeps what the player does (PlayerStats) for the adaptive
## difficulty and the ad statistics.

const SAVES_DIRECTORY: String = "user://saves"

var progress: GameProgress = GameProgress.new()
var saves: SaveSlots = SaveSlots.new(SAVES_DIRECTORY)
## The slot of the playthrough, or 0: nothing is saved (tests, screenshots).
var slot: int = 0
## The day number to use instead of the system's (tests, screenshots); -1: the system's.
var day_override: int = -1


func _ready() -> void:
	Events.rewarded_ad_finished.connect(_on_rewarded_ad_finished)
	if OS.has_feature("template"):
		open_profile()


## Opens the player's latest playthrough (a new one the first time) and counts a session.
func open_profile() -> void:
	var latest: int = saves.latest()
	if latest <= 0 or not load_game(latest):
		new_game()
	progress.stats.start_session(today())
	save_game()


## A game ended with `score` after `moves` moves.
func record_game(score: int, moves: int) -> void:
	progress.stats.finish_game(score, moves)
	Diagnostics.note("game ended: score %d, %d moves" % [score, moves])
	save_game()


## Keeps `score` as the best one when it is (a game is not over until the player leaves it).
func note_score(score: int) -> void:
	progress.stats.note_score(score)


## Today's day number (DailyChallenge.day_of), from the system's local date.
func today() -> int:
	if day_override >= 0:
		return day_override
	var date: Dictionary = Time.get_date_dict_from_system()
	return DailyChallenge.day_of(
		JsonRead.integer(date, "year"),
		JsonRead.integer(date, "month"),
		JsonRead.integer(date, "day")
	)


## The comeback gift (G14): a free continue today after `days` away.
func has_comeback_gift(days: int) -> bool:
	return progress.stats.has_comeback_gift(today(), days)


func use_comeback_gift() -> void:
	progress.stats.use_comeback_gift(today())
	Diagnostics.note("comeback gift used")
	save_game()


## Level `index` of the level mode was won (G17).
func record_level_won(index: int) -> void:
	progress.stats.win_level(index)
	Diagnostics.note("level %d won" % (index + 1))
	save_game()


## A daily challenge game ended with `score` (G16).
func record_daily(score: int) -> void:
	progress.stats.finish_daily(today(), score)
	save_game()


## A rewarded ad was offered for `placement` at a moment it was worth the most.
func record_offer(placement: String) -> void:
	progress.stats.record_offer(placement)


func record_bonus(kind: String) -> void:
	progress.stats.record_bonus(kind)
	Diagnostics.note("bonus: %s" % kind)


## Back to a blank state, saved nowhere (called before each test).
func reset() -> void:
	progress = GameProgress.new()
	slot = 0
	day_override = -1
	Events.money_changed.emit(progress.money)


## A new playthrough in a new slot.
func new_game() -> void:
	reset()
	slot = saves.new_slot()
	save_game()
	Events.game_started.emit()


## Loads the playthrough of `slot_number`; false when it cannot be read.
func load_game(slot_number: int) -> bool:
	var save: SaveGame = saves.read(slot_number)
	if save == null:
		return false
	progress = save.progress
	slot = slot_number
	Events.money_changed.emit(progress.money)
	Events.game_started.emit()
	return true


## Writes the playthrough in its slot (nothing when no slot is chosen).
func save_game() -> bool:
	if slot <= 0:
		return false
	var save: SaveGame = SaveGame.new()
	save.progress = progress
	save.saved_at = int(Time.get_unix_time_from_system())
	return saves.write(slot, save)


func earn(amount: int) -> void:
	progress.earn(amount)
	Events.money_changed.emit(progress.money)


func _on_rewarded_ad_finished(placement: String, rewarded: bool) -> void:
	progress.stats.record_ad(placement, rewarded)
	save_game()


func spend(amount: int) -> bool:
	if not progress.spend(amount):
		return false
	Events.money_changed.emit(progress.money)
	save_game()
	return true
