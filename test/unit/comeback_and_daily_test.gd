extends GdUnitTestSuite
## The comeback gift (G14) and the daily challenge (G16): days given by the tests, never read
## from the clock (PlayerStats, DailyChallenge, SaveGame migration).

const DAYS: int = 3
const RULES: TileBlocksRules = preload("res://game/data/tile_blocks_rules.tres")


func test_a_new_player_gets_no_comeback_gift() -> void:
	var stats: PlayerStats = PlayerStats.new()
	stats.start_session(100)
	assert_bool(stats.has_comeback_gift(100, DAYS)).is_false()


func test_a_player_back_after_days_away_gets_one_free_continue_that_day() -> void:
	var stats: PlayerStats = PlayerStats.new()
	stats.start_session(100)
	stats.start_session(102)
	assert_bool(stats.has_comeback_gift(102, DAYS)).is_false()
	stats.start_session(105)
	assert_bool(stats.has_comeback_gift(105, DAYS)).is_true()
	# A second session the same day keeps it.
	stats.start_session(105)
	assert_bool(stats.has_comeback_gift(105, DAYS)).is_true()
	stats.use_comeback_gift(105)
	assert_bool(stats.has_comeback_gift(105, DAYS)).is_false()
	# The next day, the player is no longer coming back.
	stats.start_session(106)
	assert_bool(stats.has_comeback_gift(106, DAYS)).is_false()


func test_the_gift_is_off_when_the_setting_is_zero() -> void:
	var stats: PlayerStats = PlayerStats.new()
	stats.start_session(100)
	stats.start_session(130)
	assert_bool(stats.has_comeback_gift(130, 0)).is_false()


func test_the_same_day_gives_the_same_pieces() -> void:
	var day: int = DailyChallenge.day_of(2026, 11, 9)
	assert_int(DailyChallenge.day_of(2026, 11, 10)).is_equal(day + 1)
	assert_int(DailyChallenge.seed_for(day)).is_equal(DailyChallenge.seed_for(day))
	assert_int(DailyChallenge.seed_for(day)).is_not_equal(DailyChallenge.seed_for(day + 1))
	var first: TileBlocksGame = TileBlocksGame.new(RULES, DailyChallenge.seed_for(day))
	var second: TileBlocksGame = TileBlocksGame.new(RULES, DailyChallenge.seed_for(day))
	for slot in first.hand.size():
		assert_that(first.hand[slot].cells).is_equal(second.hand[slot].cells)
		assert_that(first.hand[slot].symbols).is_equal(second.hand[slot].symbols)


func test_the_daily_best_and_the_streak() -> void:
	var stats: PlayerStats = PlayerStats.new()
	stats.finish_daily(200, 300)
	stats.finish_daily(200, 120)
	assert_int(stats.daily_best_on(200)).is_equal(300)
	assert_int(stats.daily_streak_on(200)).is_equal(1)
	stats.finish_daily(201, 50)
	assert_int(stats.daily_best_on(201)).is_equal(50)
	assert_int(stats.daily_best_on(200)).is_equal(0)
	assert_int(stats.daily_streak_on(202)).is_equal(2)
	# A day missed: the streak no longer counts, then starts again.
	assert_int(stats.daily_streak_on(203)).is_equal(0)
	stats.finish_daily(204, 10)
	assert_int(stats.daily_streak_on(204)).is_equal(1)


func test_days_read_back_the_same_and_without_trust() -> void:
	var stats: PlayerStats = PlayerStats.new()
	stats.start_session(100)
	stats.start_session(110)
	stats.finish_daily(110, 77)
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(stats.to_dict()))
	var read: PlayerStats = PlayerStats.from_dict(parsed)
	assert_int(read.last_session_day).is_equal(110)
	assert_int(read.away_days).is_equal(10)
	assert_int(read.daily_best_on(110)).is_equal(77)
	var bad: PlayerStats = PlayerStats.from_dict({"away_days": "long", "daily_streak": -3})
	assert_int(bad.away_days).is_equal(0)
	assert_int(bad.daily_streak).is_equal(0)


func test_a_version_2_save_is_migrated_with_no_days() -> void:
	var old: Dictionary = {
		"version": 2, "progress": {"money": 0, "stats": {"sessions": 4, "best_score": 900}}
	}
	var save: SaveGame = SaveGame.from_dict(old)
	assert_int(save.progress.stats.sessions).is_equal(4)
	# Records start again at version 6 (the combo bonus got a cap).
	assert_int(save.progress.stats.best_score).is_equal(0)
	assert_int(save.progress.stats.last_session_day).is_equal(0)
	var migrated: Dictionary = SaveGame.migrate(old, 2)
	var stats: Dictionary = JsonRead.dictionary(JsonRead.dictionary(migrated, "progress"), "stats")
	assert_bool(stats.has("daily_streak")).is_true()
	assert_int(JsonRead.integer(migrated, "version")).is_equal(SaveGame.VERSION)
