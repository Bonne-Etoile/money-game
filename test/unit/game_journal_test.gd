extends GdUnitTestSuite
## The games journal (GameJournal, Diagnostics.log_game): each game, move by move, as one JSON
## line, to tune the difficulty from real games.

const RULES: TileBlocksRules = preload("res://game/data/tile_blocks_rules.tres")
const PATH: String = "user://test_saves/games.jsonl"


func before_test() -> void:
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(PATH)
	Diagnostics.games_path = PATH


func after_test() -> void:
	Diagnostics.games_path = ""
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(PATH)


func _single(symbol: int) -> Piece:
	return Piece.new([Vector2i.ZERO], PackedInt32Array([symbol]))


func _played_game() -> Array:
	var game: TileBlocksGame = TileBlocksGame.new(RULES, 4)
	var journal: GameJournal = GameJournal.new("endless", 1200, game, "2026-11-12T17:00:00")
	game.grid.set_symbol(Vector2i(1, 0), 2)
	game.grid.set_symbol(Vector2i(2, 0), 2)
	game.hand[0] = _single(2)
	journal.note_move(game, game.place(0, Vector2i(0, 0)), 1500)
	journal.note_event("new_hand", game, 2000)
	return [game, journal]


func test_a_game_keeps_each_move_and_event() -> void:
	var played: Array = _played_game()
	var game: TileBlocksGame = played[0]
	var journal: GameJournal = played[1]
	var entry: Dictionary = journal.finish(game, 61000, "lost")
	assert_str(entry["mode"]).is_equal("endless")
	assert_int(entry["record"]).is_equal(1200)
	assert_str(entry["ended"]).is_equal("lost")
	assert_int(entry["moves"]).is_equal(1)
	assert_int(entry["seconds"]).is_equal(61)
	var moves: Array = entry["move_log"]
	assert_int(moves.size()).is_equal(1)
	var move: Dictionary = moves[0]
	assert_int(move["t"]).is_equal(1500)
	assert_int(move["groups"]).is_equal(1)
	assert_int(move["cleared"]).is_equal(3)
	assert_int(move["score"]).is_equal(game.score())
	var events: Array = entry["events"]
	var event: Dictionary = events[0]
	assert_str(event["kind"]).is_equal("new_hand")


func test_each_game_is_one_line_of_json() -> void:
	var played: Array = _played_game()
	var game: TileBlocksGame = played[0]
	var journal: GameJournal = played[1]
	Diagnostics.log_game(journal.finish(game, 1000, "lost"))
	Diagnostics.log_game(journal.finish(game, 2000, "left"))
	var lines: PackedStringArray = FileAccess.get_file_as_string(PATH).strip_edges().split("\n")
	assert_int(lines.size()).is_equal(2)
	var second: Dictionary = JSON.parse_string(lines[1])
	assert_str(second["ended"]).is_equal("left")


func test_nothing_is_written_without_a_path() -> void:
	Diagnostics.games_path = ""
	var played: Array = _played_game()
	var game: TileBlocksGame = played[0]
	var journal: GameJournal = played[1]
	Diagnostics.log_game(journal.finish(game, 0, "lost"))
	assert_bool(FileAccess.file_exists(PATH)).is_false()
