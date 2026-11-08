class_name SaveSlots
extends RefCounted
## The saved playthroughs: one file per slot (`slot_<n>.json`) in a directory, each a
## SaveGame overwritten by its own autosaves. Written to a temporary file first, the old save
## kept aside (`.bak`) until the new one is in place: a crash while saving never loses the
## slot (reading falls back on the `.bak`).

const PREFIX: String = "slot_"
const EXTENSION: String = ".json"


## A saved playthrough and its slot.
class Entry:
	var slot: int = 0
	var save: SaveGame = null


var directory: String = ""


func _init(saves_directory: String) -> void:
	directory = saves_directory


func path(slot: int) -> String:
	return directory.path_join("%s%d%s" % [PREFIX, slot, EXTENSION])


## The slots with a file, in increasing order.
func slots() -> Array[int]:
	var found: Array[int] = []
	if not DirAccess.dir_exists_absolute(directory):
		return found
	for file in DirAccess.get_files_at(directory):
		# A save interrupted between its two renames is only left as its `.bak`.
		var name: String = file.trim_suffix(".bak")
		if not name.begins_with(PREFIX) or not name.ends_with(EXTENSION):
			continue
		var number: String = name.trim_prefix(PREFIX).trim_suffix(EXTENSION)
		if number.is_valid_int() and number.to_int() > 0 and not number.to_int() in found:
			found.append(number.to_int())
	found.sort()
	return found


## The save in `slot`, or null (no file, unreadable, or from a newer version).
func read(slot: int) -> SaveGame:
	for file: String in [path(slot), path(slot) + ".bak"]:
		if FileAccess.file_exists(file):
			var save: SaveGame = SaveGame.from_json(FileAccess.get_file_as_string(file))
			if save != null:
				return save
	return null


## Writes `save` in `slot`; returns false when it could not be written.
func write(slot: int, save: SaveGame) -> bool:
	if slot <= 0 or DirAccess.make_dir_recursive_absolute(directory) != OK:
		return false
	var temporary: String = path(slot) + ".tmp"
	var file: FileAccess = FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(save.to_json())
	file.close()
	var backup: String = path(slot) + ".bak"
	var had_save: bool = FileAccess.file_exists(path(slot))
	if had_save:
		if FileAccess.file_exists(backup):
			DirAccess.remove_absolute(backup)
		if DirAccess.rename_absolute(path(slot), backup) != OK:
			return false
	if DirAccess.rename_absolute(temporary, path(slot)) != OK:
		return false
	if had_save:
		DirAccess.remove_absolute(backup)
	return true


func delete(slot: int) -> void:
	for file: String in [path(slot), path(slot) + ".bak", path(slot) + ".tmp"]:
		if FileAccess.file_exists(file):
			DirAccess.remove_absolute(file)


## A slot no save uses yet.
func new_slot() -> int:
	var used: Array[int] = slots()
	return 1 if used.is_empty() else used[used.size() - 1] + 1


## Every readable save, the most recent first.
func entries() -> Array[Entry]:
	var found: Array[Entry] = []
	for slot in slots():
		var save: SaveGame = read(slot)
		if save == null:
			continue
		var entry: Entry = Entry.new()
		entry.slot = slot
		entry.save = save
		found.append(entry)
	found.sort_custom(
		func(a: Entry, b: Entry) -> bool:
			if a.save.saved_at != b.save.saved_at:
				return a.save.saved_at > b.save.saved_at
			return a.slot > b.slot
	)
	return found


## The slot of the most recent save, or -1 when there is none.
func latest() -> int:
	var found: Array[Entry] = entries()
	return -1 if found.is_empty() else found[0].slot
