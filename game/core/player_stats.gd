class_name PlayerStats
extends RefCounted
## What the player does, kept across sessions (in GameProgress, so in the save): sessions,
## games and scores (the adaptive difficulty reads them), rewarded ads offered, watched or
## closed early per placement, and bonuses used; the days played (the comeback gift, G14) and
## the daily challenge (G16). Days are numbered from the Unix epoch (DailyChallenge.day_of),
## always given by the caller: no clock here. Read without trust from JSON (JsonRead). Only
## GameState changes it.

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
## The day of the last session (0: never played).
var last_session_day: int = 0
## Days the player stayed away before the first session of `last_session_day` (0: played the
## day before, or a new player).
var away_days: int = 0
## The day the comeback gift was used (one per day).
var gift_used_day: int = 0
## The day of the last daily challenge played, its best score that day, and the days in a row
## the challenge was played up to it.
var daily_day: int = 0
var daily_best: int = 0
var daily_streak: int = 0
## Levels of the level mode won (G17): level N is open once the N - 1 before it are won.
var levels_won: int = 0


## A session starts on `today`: the first one of a day notes how long the player stayed away.
func start_session(today: int) -> void:
	sessions += 1
	if today != last_session_day:
		away_days = today - last_session_day if last_session_day > 0 else 0
		last_session_day = today


## Whether the comeback gift (a free continue, G14) is there on `today`: the player came back
## after at least `days` away, and has not used it today.
func has_comeback_gift(today: int, days: int) -> bool:
	return days > 0 and today == last_session_day and away_days >= days and gift_used_day != today


func use_comeback_gift(today: int) -> void:
	gift_used_day = today


## A daily challenge game ended on `day` with `score`: the best of the day, and the streak of
## days in a row.
func finish_daily(day: int, score: int) -> void:
	if day != daily_day:
		daily_streak = daily_streak + 1 if daily_day > 0 and day == daily_day + 1 else 1
		daily_day = day
		daily_best = 0
	daily_best = maxi(daily_best, score)


## Level `index` (from 0) was won: the next one opens.
func win_level(index: int) -> void:
	levels_won = maxi(levels_won, index + 1)


## The best daily challenge score of `day` (0 when not played that day).
func daily_best_on(day: int) -> int:
	return daily_best if day == daily_day else 0


## The days in a row of daily challenges that still counts on `today` (played today or
## yesterday), else 0.
func daily_streak_on(today: int) -> int:
	return daily_streak if daily_day > 0 and today - daily_day <= 1 else 0


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
		"last_session_day": last_session_day,
		"away_days": away_days,
		"gift_used_day": gift_used_day,
		"daily_day": daily_day,
		"daily_best": daily_best,
		"daily_streak": daily_streak,
		"levels_won": levels_won,
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
	stats.last_session_day = maxi(JsonRead.integer(data, "last_session_day"), 0)
	stats.away_days = maxi(JsonRead.integer(data, "away_days"), 0)
	stats.gift_used_day = maxi(JsonRead.integer(data, "gift_used_day"), 0)
	stats.daily_day = maxi(JsonRead.integer(data, "daily_day"), 0)
	stats.daily_best = maxi(JsonRead.integer(data, "daily_best"), 0)
	stats.daily_streak = maxi(JsonRead.integer(data, "daily_streak"), 0)
	stats.levels_won = maxi(JsonRead.integer(data, "levels_won"), 0)
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
