extends SceneTree
## Plays endless games with a greedy robot (GridRobot) and prints how long they last, to
## tune the difficulty: godot --headless --script res://tools/simulate_endless.gd -- [games]
## [record] [variant]. Variants of the rules are tried side by side (see _variants); the robot
## turns pieces only where the rules let it. Slow: a few minutes per variant for 8 games.

const RULES: TileBlocksRules = preload("res://game/data/tile_blocks_rules.tres")
const MAX_MOVES: int = 300


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var games: int = int(args[0]) if args.size() > 0 else 20
	var record: int = int(args[1]) if args.size() > 1 else 0
	var variants: Array[String] = _variants()
	if args.size() > 2:
		variants = [args[2]]
	for variant: String in variants:
		var rules: TileBlocksRules = _rules_for(variant)
		var total_moves: int = 0
		var total_score: int = 0
		var capped: int = 0
		var lengths: Array[int] = []
		for random_seed in games:
			var stats: PlayerStats = null
			if record > 0:
				stats = PlayerStats.new()
				for _game in 5:
					stats.finish_game(record / 2, 20)
				stats.note_score(record)
			var game: TileBlocksGame = TileBlocksGame.new(rules, random_seed + 1000, stats)
			while not game.is_over() and game.moves < MAX_MOVES:
				_best_move(game)
			if game.moves >= MAX_MOVES:
				capped += 1
			total_moves += game.moves
			total_score += game.score()
			lengths.append(game.moves)
		lengths.sort()
		print(
			(
				"%-28s moves avg %4d median %4d | score avg %6d | %2d/%d never lost"
				% [
					variant,
					total_moves / games,
					lengths[games / 2],
					total_score / games,
					capped,
					games
				]
			)
		)
	quit()


func _variants() -> Array[String]:
	return ["current", "turning", "big_shapes", "no_guarantee"]


func _rules_for(variant: String) -> TileBlocksRules:
	var rules: TileBlocksRules = RULES.for_endless().duplicate()
	match variant:
		"turning":
			rules = RULES.duplicate()
		"match4":
			rules.match_size = 4
		"symbols6":
			rules.symbol_count = 6
		"big_shapes":
			rules.shape_keys = _big_shapes()
		"calm30":
			rules.difficulty = rules.difficulty.duplicate()
			rules.difficulty.record_calm_percent = 30
			rules.difficulty.record_percent_per_level = 15
		"no_long_game":
			rules.difficulty = rules.difficulty.duplicate()
			rules.difficulty.long_game_moves = 0
		"no_guarantee":
			rules.difficulty = rules.difficulty.duplicate()
			rules.difficulty.playable_until_fill_percent = 0
	return rules


func _big_shapes() -> Array[String]:
	var keys: Array[String] = RULES.turned_shape_keys.duplicate()
	keys.append_array(["i5h", "i5v", "o3"])
	return keys


## Plays the best placement of any piece in any turn (GridRobot.value).
func _best_move(game: TileBlocksGame) -> void:
	var best: int = -1
	var best_slot: int = -1
	var best_turns: int = 0
	var best_origin: Vector2i = Vector2i.ZERO
	for slot in game.hand.size():
		var piece: Piece = game.hand[slot]
		if piece == null:
			continue
		for turns in 4 if game.rules.can_rotate else 1:
			for y in game.grid.size:
				for x in game.grid.size:
					var origin: Vector2i = Vector2i(x, y)
					var value: int = GridRobot.value(
						game.grid, piece, origin, game.rules.match_size
					)
					if value > best:
						best = value
						best_slot = slot
						best_turns = turns
						best_origin = origin
			piece = piece.rotated()
	for _turn in best_turns:
		game.rotate(best_slot)
	game.place(best_slot, best_origin)
