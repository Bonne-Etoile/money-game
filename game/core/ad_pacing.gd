class_name AdPacing
extends RefCounted
## When rewarded ads may be offered, across games (AdPacingRules): not to a new player, not
## beyond the daily limit, and a continue only for a game worth going on. The limits within a
## game are kept by TileBlocksGame. Never reads the pieces or the grid, and the pieces never
## depend on it.


## Whether a rewarded ad may be offered now on `today`; `for_new_players`: the first games of a
## new player count (endless mode and daily challenge, not the level mode).
static func can_offer(
	rules: AdPacingRules, stats: PlayerStats, today: int, for_new_players: bool
) -> bool:
	if for_new_players and stats.games_played < rules.games_without_ads:
		return false
	return rules.rewarded_per_day <= 0 or stats.rewarded_on(today) < rules.rewarded_per_day


## Whether a game at `score` is worth a continue after an ad, against `record` (0: none yet),
## for a player who ended `games_played` games.
static func worth_reviving(
	rules: AdPacingRules, score: int, record: int, games_played: int
) -> bool:
	if games_played < rules.revive_always_games or record <= 0:
		return true
	return score * 100 >= record * rules.revive_min_record_percent
