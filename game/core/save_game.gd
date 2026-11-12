class_name SaveGame
extends RefCounted
## A saved playthrough: versioned JSON, never a Godot resource (loading a resource can run
## code, so a shared save would be an attack vector). Older versions are migrated when read;
## every change of the format bumps VERSION, adds a step to `migrate` and a test.

const VERSION: int = 6

var progress: GameProgress = GameProgress.new()
## When it was saved (Unix time, seconds).
var saved_at: int = 0


func to_dict() -> Dictionary:
	return {"version": VERSION, "saved_at": saved_at, "progress": progress.to_dict()}


func to_json() -> String:
	return JSON.stringify(to_dict(), "\t")


## Reads a save, migrating older versions; null when it is not a save of this game or comes
## from a newer version.
static func from_dict(data: Dictionary) -> SaveGame:
	var version: int = JsonRead.integer(data, "version", -1)
	if version < 1 or version > VERSION or not data.get("progress") is Dictionary:
		return null
	var migrated: Dictionary = migrate(data, version)
	var save: SaveGame = SaveGame.new()
	save.saved_at = maxi(JsonRead.integer(migrated, "saved_at"), 0)
	save.progress = GameProgress.from_dict(JsonRead.dictionary(migrated, "progress"))
	return save


## Brings a save of `version` up to VERSION, one step per version.
static func migrate(data: Dictionary, version: int) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	while version < VERSION:
		if version == 1:
			# Version 2 keeps what the player does (PlayerStats): none before.
			var progress: Dictionary = JsonRead.dictionary(migrated, "progress")
			progress["stats"] = PlayerStats.new().to_dict()
			migrated["progress"] = progress
		elif version == 2:
			# Version 3 keeps the days played and the daily challenge (G14, G16): none before.
			var progress: Dictionary = JsonRead.dictionary(migrated, "progress")
			var stats: Dictionary = JsonRead.dictionary(progress, "stats")
			for key: String in [
				"last_session_day",
				"away_days",
				"gift_used_day",
				"daily_day",
				"daily_best",
				"daily_streak",
			]:
				stats[key] = 0
			progress["stats"] = stats
			migrated["progress"] = progress
		elif version == 3:
			# Version 4 keeps the levels won (G17): none before.
			var progress: Dictionary = JsonRead.dictionary(migrated, "progress")
			var stats: Dictionary = JsonRead.dictionary(progress, "stats")
			stats["levels_won"] = 0
			progress["stats"] = stats
			migrated["progress"] = progress
		elif version == 4:
			# Version 5 counts the rewarded ads watched each day (the daily limit): none before.
			var progress: Dictionary = JsonRead.dictionary(migrated, "progress")
			var stats: Dictionary = JsonRead.dictionary(progress, "stats")
			stats["rewarded_day"] = 0
			stats["rewarded_that_day"] = 0
			progress["stats"] = stats
			migrated["progress"] = progress
		elif version == 5:
			# Version 6 caps the combo bonus (G19): scores made before are not comparable, the
			# records start again.
			var progress: Dictionary = JsonRead.dictionary(migrated, "progress")
			var stats: Dictionary = JsonRead.dictionary(progress, "stats")
			stats["best_score"] = 0
			stats["recent_scores"] = []
			stats["daily_best"] = 0
			progress["stats"] = stats
			migrated["progress"] = progress
		version += 1
	migrated["version"] = VERSION
	return migrated


## Reads a save from its JSON text; null when it is not valid (quietly: a broken file is
## passed over for its backup).
static func from_json(text: String) -> SaveGame:
	var json: JSON = JSON.new()
	if json.parse(text) != OK or not json.data is Dictionary:
		return null
	var data: Dictionary = json.data
	return from_dict(data)
