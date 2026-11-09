class_name DifficultyDirector
extends RefCounted
## The adaptive difficulty (DifficultyRules), in both directions: a level from how well the
## player did in their recent games (PlayerStats) and how well the game under way goes (its
## score, its combo). Level 0 is pure chance. Above 0, several pieces are drawn for each new one
## and the one with the least room is given; below 0 (a new player, or a run of poor games),
## the one with the most room (PieceGenerator.next_piece_among).

var rules: DifficultyRules
## Level at the start of the game, from the player's recent games.
var start_level: int = 0


func _init(difficulty_rules: DifficultyRules, stats: PlayerStats) -> void:
	rules = difficulty_rules
	if stats == null:
		return
	if stats.games_played < rules.beginner_games or _poor_run(stats):
		start_level = maxi(rules.help_level, min_level())
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


## The level for a game at `score` with `combo` moves in a row that cleared something.
func level(score: int, combo: int) -> int:
	var reached: int = start_level + score / maxi(rules.points_per_level, 1)
	if rules.combo_for_extra_level > 0 and combo >= rules.combo_for_extra_level:
		reached += 1
	return clampi(reached, min_level(), max_level())


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
