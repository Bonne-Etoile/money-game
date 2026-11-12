extends GdUnitTestSuite
## When rewarded ads may be offered across games (game/core/ad_pacing.gd) and the count of ads
## watched per day (PlayerStats), with the settings of game/data/ad_pacing_rules.tres.

## The limits themselves (the game turns them all off since 2026-11-12, Stelio: no limit).
const PACING: AdPacingRules = preload("res://test/fixtures/limited_ad_pacing.tres")


func _player(games: int) -> PlayerStats:
	var stats: PlayerStats = PlayerStats.new()
	stats.games_played = games
	return stats


func test_a_new_player_is_offered_no_ad_in_the_first_games_except_in_levels() -> void:
	var stats: PlayerStats = _player(PACING.games_without_ads - 1)
	assert_bool(AdPacing.can_offer(PACING, stats, 100, true)).is_false()
	assert_bool(AdPacing.can_offer(PACING, stats, 100, false)).is_true()
	stats.games_played = PACING.games_without_ads
	assert_bool(AdPacing.can_offer(PACING, stats, 100, true)).is_true()


func test_no_ad_beyond_the_daily_limit_until_the_next_day() -> void:
	var stats: PlayerStats = _player(50)
	for _ad in PACING.rewarded_per_day:
		assert_bool(AdPacing.can_offer(PACING, stats, 100, true)).is_true()
		stats.count_rewarded(100)
	assert_int(stats.rewarded_on(100)).is_equal(PACING.rewarded_per_day)
	assert_bool(AdPacing.can_offer(PACING, stats, 100, true)).is_false()
	assert_bool(AdPacing.can_offer(PACING, stats, 100, false)).is_false()
	assert_int(stats.rewarded_on(101)).is_equal(0)
	assert_bool(AdPacing.can_offer(PACING, stats, 101, true)).is_true()
	stats.count_rewarded(101)
	assert_int(stats.rewarded_on(101)).is_equal(1)


func test_a_continue_is_offered_only_for_a_game_close_enough_to_the_record() -> void:
	var played: int = PACING.revive_always_games
	var record: int = 1000
	var needed: int = record * PACING.revive_min_record_percent / 100
	assert_bool(AdPacing.worth_reviving(PACING, needed - 1, record, played)).is_false()
	assert_bool(AdPacing.worth_reviving(PACING, needed, record, played)).is_true()
	# In the first games, and without a record, always.
	assert_bool(AdPacing.worth_reviving(PACING, 0, record, played - 1)).is_true()
	assert_bool(AdPacing.worth_reviving(PACING, 0, 0, played)).is_true()


func test_zero_turns_the_limits_off() -> void:
	var rules: AdPacingRules = PACING.duplicate()
	rules.rewarded_per_day = 0
	rules.games_without_ads = 0
	var stats: PlayerStats = _player(0)
	for _ad in 100:
		stats.count_rewarded(100)
	assert_bool(AdPacing.can_offer(rules, stats, 100, true)).is_true()


func test_the_daily_count_is_saved_and_read_without_trust() -> void:
	var stats: PlayerStats = _player(4)
	stats.count_rewarded(300)
	stats.count_rewarded(300)
	var read: PlayerStats = PlayerStats.from_dict(stats.to_dict())
	assert_int(read.rewarded_on(300)).is_equal(2)
	var broken: PlayerStats = PlayerStats.from_dict({"rewarded_day": "x", "rewarded_that_day": -3})
	assert_int(broken.rewarded_day).is_equal(0)
	assert_int(broken.rewarded_that_day).is_equal(0)


func test_a_version_4_save_is_migrated_with_no_ad_counted() -> void:
	var data: Dictionary = {
		"version": 4, "progress": {"money": 0, "stats": {"games_played": 7, "levels_won": 2}}
	}
	var save: SaveGame = SaveGame.from_dict(data)
	assert_object(save).is_not_null()
	assert_int(save.progress.stats.games_played).is_equal(7)
	assert_int(save.progress.stats.rewarded_on(1)).is_equal(0)
	var migrated: Dictionary = SaveGame.migrate(data, 4)
	var stats: Dictionary = JsonRead.dictionary(JsonRead.dictionary(migrated, "progress"), "stats")
	assert_bool(stats.has("rewarded_that_day")).is_true()
	assert_int(JsonRead.integer(migrated, "version")).is_equal(SaveGame.VERSION)
