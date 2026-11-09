extends GdUnitTestSuite
## What the player does (game/core/player_stats.gd) and the adaptive difficulty that reads it
## (game/core/difficulty_director.gd).

const DIFFICULTY: DifficultyRules = preload("res://game/data/difficulty_rules.tres")


func test_games_keep_the_best_and_the_recent_scores() -> void:
	var stats: PlayerStats = PlayerStats.new()
	stats.finish_game(50, 0)
	assert_int(stats.games_played).is_equal(0)
	for score in PlayerStats.RECENT_GAMES + 2:
		stats.finish_game(score * 10, 3)
	assert_int(stats.games_played).is_equal(PlayerStats.RECENT_GAMES + 2)
	assert_int(stats.total_moves).is_equal((PlayerStats.RECENT_GAMES + 2) * 3)
	assert_int(stats.best_score).is_equal((PlayerStats.RECENT_GAMES + 1) * 10)
	assert_int(stats.recent_scores.size()).is_equal(PlayerStats.RECENT_GAMES)
	assert_int(stats.recent_scores[0]).is_equal(20)
	assert_int(stats.average_recent_score()).is_equal(65)


func test_ads_offers_and_bonuses_are_counted_per_placement() -> void:
	var stats: PlayerStats = PlayerStats.new()
	stats.record_offer("continue")
	stats.record_ad("continue", true)
	stats.record_ad("new_hand", true)
	stats.record_ad("new_hand", false)
	stats.record_bonus("mirror")
	assert_int(stats.ad_offers["continue"]).is_equal(1)
	assert_int(stats.ads_watched_total()).is_equal(2)
	assert_int(stats.ads_skipped["new_hand"]).is_equal(1)
	assert_int(stats.bonuses_used["mirror"]).is_equal(1)


func test_statistics_read_back_the_same_and_without_trust() -> void:
	var stats: PlayerStats = PlayerStats.new()
	stats.start_session()
	stats.finish_game(120, 9)
	stats.record_ad("continue", true)
	var json: String = JSON.stringify(stats.to_dict())
	var parsed: Dictionary = JSON.parse_string(json)
	var read: PlayerStats = PlayerStats.from_dict(parsed)
	assert_int(read.sessions).is_equal(1)
	assert_int(read.best_score).is_equal(120)
	assert_that(read.recent_scores).is_equal([120] as Array[int])
	assert_int(read.ads_watched["continue"]).is_equal(1)
	var bad: PlayerStats = PlayerStats.from_dict(
		{"sessions": "many", "best_score": -4, "recent_scores": [1, "x"], "ads_watched": [1]}
	)
	assert_int(bad.sessions).is_equal(0)
	assert_int(bad.best_score).is_equal(0)
	assert_that(bad.recent_scores).is_equal([1] as Array[int])
	assert_int(bad.ads_watched.size()).is_equal(0)


func test_a_new_player_starts_at_level_zero() -> void:
	var director: DifficultyDirector = DifficultyDirector.new(DIFFICULTY, PlayerStats.new())
	assert_int(director.level(0, 0)).is_equal(0)
	assert_int(director.candidates(0)).is_equal(1)


func test_the_level_rises_with_the_score_and_a_combo() -> void:
	var director: DifficultyDirector = DifficultyDirector.new(DIFFICULTY, null)
	assert_int(director.level(DIFFICULTY.points_per_level, 0)).is_equal(1)
	var combo: int = DIFFICULTY.combo_for_extra_level
	assert_int(director.level(DIFFICULTY.points_per_level, combo)).is_equal(2)
	assert_int(director.level(1000000, combo)).is_equal(director.max_level())
	assert_int(director.candidates(director.max_level())).is_greater(1)


func test_a_good_player_starts_higher_once_past_the_first_games() -> void:
	var stats: PlayerStats = PlayerStats.new()
	stats.finish_game(100000, 50)
	assert_int(DifficultyDirector.new(DIFFICULTY, stats).start_level).is_equal(0)
	for _game in DIFFICULTY.beginner_games:
		stats.finish_game(100000, 50)
	var director: DifficultyDirector = DifficultyDirector.new(DIFFICULTY, stats)
	assert_int(director.start_level).is_equal(DIFFICULTY.max_start_level)
	assert_int(director.level(0, 0)).is_equal(DIFFICULTY.max_start_level)
