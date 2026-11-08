extends GdUnitTestSuite
## Saves (game/core/save_game.gd, save_slots.gd): versioned JSON, read without trust, written
## without ever losing the previous save.

const DIRECTORY: String = "user://test_saves"


func before_test() -> void:
	SaveSlots.new(DIRECTORY).delete(1)
	SaveSlots.new(DIRECTORY).delete(2)


func _save(money: int, saved_at: int) -> SaveGame:
	var save: SaveGame = SaveGame.new()
	save.progress.earn(money)
	save.saved_at = saved_at
	return save


func test_a_save_reads_back_the_same() -> void:
	var read: SaveGame = SaveGame.from_json(_save(42, 1000).to_json())
	assert_int(read.progress.money).is_equal(42)
	assert_int(read.saved_at).is_equal(1000)


func test_what_is_not_a_save_is_refused() -> void:
	assert_object(SaveGame.from_json("not json")).is_null()
	assert_object(SaveGame.from_json("[1, 2]")).is_null()
	assert_object(SaveGame.from_json('{"version": 1}')).is_null()
	# A save from a newer version of the game is never read as if it were this one.
	var future: Dictionary = _save(1, 0).to_dict()
	future["version"] = SaveGame.VERSION + 1
	assert_object(SaveGame.from_dict(future)).is_null()


func test_invalid_values_keep_their_defaults() -> void:
	var save: SaveGame = SaveGame.from_json(
		'{"version": 1, "progress": {"money": "lots", "play_time": -5}}'
	)
	assert_int(save.progress.money).is_equal(0)
	assert_float(save.progress.play_time).is_equal(0.0)


func test_slots_write_read_and_list_the_latest_first() -> void:
	var slots: SaveSlots = SaveSlots.new(DIRECTORY)
	assert_int(slots.new_slot()).is_equal(1)
	assert_bool(slots.write(1, _save(5, 100))).is_true()
	assert_bool(slots.write(2, _save(7, 200))).is_true()
	assert_array(slots.slots()).is_equal([1, 2])
	assert_int(slots.latest()).is_equal(2)
	assert_int(slots.read(1).progress.money).is_equal(5)


func test_a_slot_falls_back_on_its_backup() -> void:
	var slots: SaveSlots = SaveSlots.new(DIRECTORY)
	slots.write(1, _save(5, 100))
	# A crash between the two renames leaves only the backup.
	DirAccess.rename_absolute(slots.path(1), slots.path(1) + ".bak")
	assert_int(slots.read(1).progress.money).is_equal(5)
	assert_array(slots.slots()).is_equal([1])


func test_progress_never_spends_more_than_it_has() -> void:
	var progress: GameProgress = GameProgress.new()
	progress.earn(10)
	progress.earn(-3)
	assert_bool(progress.spend(11)).is_false()
	assert_bool(progress.spend(4)).is_true()
	assert_int(progress.money).is_equal(6)
