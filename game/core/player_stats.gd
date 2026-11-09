class_name PlayerStats
extends RefCounted
## What the player does, kept across sessions (in GameProgress, so in the save): sessions,
## games and scores (the adaptive difficulty reads them), rewarded ads offered, watched or
## closed early per placement, and bonuses used. Read without trust from JSON (JsonRead).
## Only GameState changes it.

## Scores kept for the average of the recent games.
const RECENT_GAMES: int = 10

## Times the game was started.
var sessions: int = 0
## Games ended (lost and left, or left for a new one) with at least one move.
var games_played: int = 0
var best_score: int = 0
var total_moves: int = 0
## Scores of the last RECENT_GAMES games, the oldest first.
var recent_scores: Array[int] = []
## Times a rewarded ad was offered when it was worth the most, per placement (the continue
## button on the game-over panel, a bonus that costs an ad when pieces stop fitting).
var ad_offers: Dictionary[String, int] = {}
## Rewarded ads watched to the end, per placement.
var ads_watched: Dictionary[String, int] = {}
## Rewarded ads closed before the reward, per placement.
var ads_skipped: Dictionary[String, int] = {}
## Bonuses used, per kind (TileBlocksGame.BONUS_*).
var bonuses_used: Dictionary[String, int] = {}


func start_session() -> void:
	sessions += 1


## A game ended with `score` after `moves` moves (ignored without a move).
func finish_game(score: int, moves: int) -> void:
	if moves <= 0:
		return
	games_played += 1
	total_moves += moves
	note_score(score)
	recent_scores.append(maxi(score, 0))
	while recent_scores.size() > RECENT_GAMES:
		recent_scores.remove_at(0)


## Keeps `score` as the best one when it is.
func note_score(score: int) -> void:
	best_score = maxi(best_score, score)


func record_offer(placement: String) -> void:
	_add(ad_offers, placement)


func record_ad(placement: String, rewarded: bool) -> void:
	_add(ads_watched if rewarded else ads_skipped, placement)


func record_bonus(kind: String) -> void:
	_add(bonuses_used, kind)


## Average score of the recent games (0 without any).
func average_recent_score() -> int:
	if recent_scores.is_empty():
		return 0
	var total: int = 0
	for score in recent_scores:
		total += score
	return total / recent_scores.size()


## Rewarded ads watched to the end, all placements together.
func ads_watched_total() -> int:
	var total: int = 0
	for placement: String in ads_watched:
		total += ads_watched[placement]
	return total


func to_dict() -> Dictionary:
	return {
		"sessions": sessions,
		"games_played": games_played,
		"best_score": best_score,
		"total_moves": total_moves,
		"recent_scores": recent_scores.duplicate(),
		"ad_offers": ad_offers.duplicate(),
		"ads_watched": ads_watched.duplicate(),
		"ads_skipped": ads_skipped.duplicate(),
		"bonuses_used": bonuses_used.duplicate(),
	}


## Reads saved statistics without trusting them: anything invalid keeps its default.
static func from_dict(data: Dictionary) -> PlayerStats:
	var stats: PlayerStats = PlayerStats.new()
	stats.sessions = maxi(JsonRead.integer(data, "sessions"), 0)
	stats.games_played = maxi(JsonRead.integer(data, "games_played"), 0)
	stats.best_score = maxi(JsonRead.integer(data, "best_score"), 0)
	stats.total_moves = maxi(JsonRead.integer(data, "total_moves"), 0)
	for value in JsonRead.numbers(JsonRead.array(data, "recent_scores")):
		stats.recent_scores.append(maxi(roundi(value), 0))
	while stats.recent_scores.size() > RECENT_GAMES:
		stats.recent_scores.remove_at(0)
	stats.ad_offers = _counts(JsonRead.dictionary(data, "ad_offers"))
	stats.ads_watched = _counts(JsonRead.dictionary(data, "ads_watched"))
	stats.ads_skipped = _counts(JsonRead.dictionary(data, "ads_skipped"))
	stats.bonuses_used = _counts(JsonRead.dictionary(data, "bonuses_used"))
	return stats


## Counts by name: keys that are text, values that are whole numbers above zero.
static func _counts(data: Dictionary) -> Dictionary[String, int]:
	var counts: Dictionary[String, int] = {}
	for key: Variant in data:
		if key is String:
			var name: String = key
			var count: int = JsonRead.integer(data, name)
			if count > 0:
				counts[name] = count
	return counts


static func _add(counts: Dictionary[String, int], key: String) -> void:
	var count: int = counts.get(key, 0)
	counts[key] = count + 1
