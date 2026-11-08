class_name SaveGame
extends RefCounted
## A saved playthrough: versioned JSON, never a Godot resource (loading a resource can run
## code, so a shared save would be an attack vector). Older versions are migrated when read;
## every change of the format bumps VERSION, adds a step to `migrate` and a test.

const VERSION: int = 1

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


## Brings a save of `version` up to VERSION, one step per version. Example of a step:
##   if version == 1:
##       var progress: Dictionary = JsonRead.dictionary(migrated, "progress")
##       progress["new_field"] = 0
##       migrated["progress"] = progress
static func migrate(data: Dictionary, version: int) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	while version < VERSION:
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
