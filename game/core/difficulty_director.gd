class_name DifficultyDirector
extends RefCounted
## The adaptive difficulty (DifficultyRules): a level from 0 (pure chance) up, from how well
## the player did in their recent games (PlayerStats) and how well the game under way goes
## (its score, its combo). The level says how many pieces are drawn for each new one; the
## one with the least room is given (PieceGenerator.next_piece_among).

var rules: DifficultyRules
## Level at the start of the game, from the player's recent games.
var start_level: int = 0


func _init(difficulty_rules: DifficultyRules, stats: PlayerStats) -> void:
	rules = difficulty_rules
	if stats != null and stats.games_played >= rules.beginner_games:
		var per_level: int = maxi(rules.average_points_per_start_level, 1)
		start_level = mini(stats.average_recent_score() / per_level, rules.max_start_level)


func max_level() -> int:
	return maxi(rules.candidates_per_level.size() - 1, 0)


## The level for a game at `score` with `combo` moves in a row that cleared something.
func level(score: int, combo: int) -> int:
	var reached: int = start_level + score / maxi(rules.points_per_level, 1)
	if rules.combo_for_extra_level > 0 and combo >= rules.combo_for_extra_level:
		reached += 1
	return clampi(reached, 0, max_level())


## Pieces to draw at `at_level` for each new piece (at least 1).
func candidates(at_level: int) -> int:
	if rules.candidates_per_level.is_empty():
		return 1
	return maxi(rules.candidates_per_level[clampi(at_level, 0, max_level())], 1)
