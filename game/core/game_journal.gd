class_name GameJournal
extends RefCounted
## One game, move by move, kept to tune the difficulty from real games: the screen notes each
## move and each bonus, then Diagnostics writes the entry as a line of user://logs/games.jsonl.
## Short keys keep the file small; times are milliseconds since the start of the game.

## Format of an entry: raised when its fields change.
const VERSION: int = 1

var entry: Dictionary = {}
var _moves: Array[Dictionary] = []
var _events: Array[Dictionary] = []


## `mode`: "endless", "daily" or "level"; `record`: the best score before this game;
## `started`: when (local date and time, ISO 8601).
func _init(mode: String, record: int, game: TileBlocksGame, started: String) -> void:
	entry = {
		"v": VERSION,
		"mode": mode,
		"started": started,
		"record": record,
		"start_level": game.level(),
	}


## A piece placed (`result`), `msec` after the start of the game.
func note_move(game: TileBlocksGame, result: MoveResult, msec: int) -> void:
	var cells: int = game.grid.size * game.grid.size
	(
		_moves
		. append(
			{
				"t": msec,
				"cells": result.placed.size(),
				"lines": result.clear.lines,
				"groups": result.clear.groups,
				"cleared": result.clear.cells.size(),
				"pts": result.points,
				"combo": result.combo,
				"score": game.score(),
				"level": game.level(),
				"fill": game.grid.filled_count() * 100 / maxi(cells, 1),
				"fit": game.pieces_that_fit(),
			}
		)
	)


## Something else the player did (`kind`: "revive", "revive_ad", "new_hand", "mirror"...).
func note_event(kind: String, game: TileBlocksGame, msec: int) -> void:
	_events.append({"t": msec, "kind": kind, "move": game.moves, "score": game.score()})


## The whole entry: `ended` says how ("lost", or "left" for a game given up under way).
func finish(game: TileBlocksGame, msec: int, ended: String) -> Dictionary:
	var whole: Dictionary = entry.duplicate()
	whole["ended"] = ended
	whole["score"] = game.score()
	whole["moves"] = game.moves
	whole["seconds"] = msec / 1000
	whole["revives"] = game.revives_used
	whole["ads"] = game.ads_used
	whole["events"] = _events.duplicate()
	whole["move_log"] = _moves.duplicate()
	return whole
