extends Node
## The playthrough under way (GameProgress) and its save slot. The only place that changes the
## state: scenes call its methods, which apply GameProgress's rules and emit Events' signals.
## Saves are written only when a slot is chosen: tests and screenshots never write anything.

const SAVES_DIRECTORY: String = "user://saves"

var progress: GameProgress = GameProgress.new()
var saves: SaveSlots = SaveSlots.new(SAVES_DIRECTORY)
## The slot of the playthrough, or 0: nothing is saved (tests, screenshots).
var slot: int = 0


## Back to a blank state, saved nowhere (called before each test).
func reset() -> void:
	progress = GameProgress.new()
	slot = 0
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


func spend(amount: int) -> bool:
	if not progress.spend(amount):
		return false
	Events.money_changed.emit(progress.money)
	save_game()
	return true
