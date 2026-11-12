class_name DifficultyDirector
extends RefCounted
## The adaptive difficulty (DifficultyRules), in both directions: a level from how well the
## player did in their recent games (PlayerStats) and how well the game under way goes (its
## score, its combo). Once the player has a record, the score raises the level only from a
## share of it on: calm at the start, tension near the record. Level 0 is pure chance. Above 0,
## several pieces are drawn for each new one and the one with the least room is given; below 0
## (a new player, or a run of poor games), the one with the most room
## (PieceGenerator.next_piece_among).

var rules: DifficultyRules
## Level at the start of the game, from the player's recent games.
var start_level: int = 0
## The player's record before this game (0: none, or too low to follow it).
var record: int = 0


func _init(difficulty_rules: DifficultyRules, stats: PlayerStats) -> void:
	rules = difficulty_rules
	if stats == null:
		return
	if rules.record_points_from > 0 and stats.best_score >= rules.record_points_from:
		record = stats.best_score
	if stats.games_played < rules.beginner_games or _poor_run(stats):
		start_level = maxi(rules.help_level, min_level())
		return
	if record > 0:
		# The climb follows the record from a calm start: no head start on top of it.
		return
	var per_level: int = maxi(rules.average_points_per_start_level, 1)
	start_level = mini(stats.average_recent_score() / per_level, rules.max_start_level)


func max_level() -> int:
	return maxi(rules.candidates_per_level.size() - 1, 0)


## The easiest level (0 when no help is set).
func min_level() -> int:
	return -rules.help_candidates_per_level.size()


## Whether the player's last games were all under their average (DifficultyRules
## .poor_games_for_help).
func _poor_run(stats: PlayerStats) -> bool:
	var count: int = rules.poor_games_for_help
	if count <= 0 or stats.recent_scores.size() < count + 1:
		return false
	var average: int = stats.average_recent_score()
	for index in range(stats.recent_scores.size() - count, stats.recent_scores.size()):
		if stats.recent_scores[index] >= average:
			return false
	return true


## The level for a game at `score` after `moves` moves, with `combo` moves in a row that
## cleared something.
func level(score: int, combo: int, moves: int = 0) -> int:
	var reached: int = start_level + maxi(_score_levels(score), _long_game_levels(moves))
	if rules.combo_for_extra_level > 0 and combo >= rules.combo_for_extra_level:
		reached += 1
	return clampi(reached, min_level(), max_level())


## Levels a long game adds (DifficultyRules.long_game_moves): its length stays bounded.
func _long_game_levels(moves: int) -> int:
	if rules.long_game_moves <= 0 or moves < rules.long_game_moves:
		return 0
	return 1 + (moves - rules.long_game_moves) / maxi(rules.long_game_moves_per_level, 1)


## Levels the score of the game adds: per `points_per_level`, or from the record once there is
## one (DifficultyRules.record_calm_percent, record_percent_per_level).
func _score_levels(score: int) -> int:
	if record <= 0:
		return score / maxi(rules.points_per_level, 1)
	var above_calm: int = score * 100 - record * rules.record_calm_percent
	if above_calm < 0:
		return 0
	return 1 + above_calm / maxi(record * rules.record_percent_per_level, 1)


## Pieces to draw at `at_level` for each new piece (at least 1).
func candidates(at_level: int) -> int:
	if at_level < 0 and not rules.help_candidates_per_level.is_empty():
		var help: int = clampi(-at_level - 1, 0, rules.help_candidates_per_level.size() - 1)
		return maxi(rules.help_candidates_per_level[help], 1)
	if rules.candidates_per_level.is_empty():
		return 1
	return maxi(rules.candidates_per_level[clampi(at_level, 0, max_level())], 1)


## Whether new pieces should have the least room (true) or the most (false, helping).
func hardest(at_level: int) -> bool:
	return at_level >= 0


## Whether the playability guarantee holds on a grid with `filled` cells out of `cells`.
func guarantees_play(filled: int, cells: int) -> bool:
	var percent: int = rules.playable_until_fill_percent
	return percent > 0 and filled * 100 <= cells * percent
