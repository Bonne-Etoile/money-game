class_name LevelLayout
extends RefCounted
## Reads the pile of a hand-made level (PyramidLevel.layers): one text per layer, bottom
## first; each character is a half tile, a letter marks the top-left corner of a tile and
## names its shape (PyramidRules.legend), anything else is empty. The grid may start with
## tiles on it (PyramidLevel.grid_rows, "#").

const GRID_TILE: String = "#"


static func tiles_of(level: PyramidLevel, rules: PyramidRules) -> Array[StackTile]:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = level.symbol_seed
	var tiles: Array[StackTile] = []
	var shapes: Array[PieceShape] = []
	for layer in level.layers.size():
		var rows: PackedStringArray = level.layers[layer].split("\n", false)
		for y in rows.size():
			for x in rows[y].length():
				var letter: String = rows[y][x]
				var shape_key: String = rules.legend.get(letter, "")
				var shape: PieceShape = rules.shape_set.find(shape_key)
				if shape == null:
					continue
				shapes.append(shape)
				tiles.append(StackTile.new(Vector2i(x, y), layer, null))
	var symbols: PackedInt32Array = _symbols(tiles.size(), level, rules, rng)
	for index in tiles.size():
		tiles[index].piece = Piece.uniform(shapes[index].cells, symbols[index])
	return tiles


## One symbol per tile: drawn freely, or each symbol three times, shuffled.
static func _symbols(
	count: int, level: PyramidLevel, rules: PyramidRules, rng: RandomNumberGenerator
) -> PackedInt32Array:
	var symbols: PackedInt32Array = []
	for index in count:
		if level.symbols_in_threes:
			symbols.append(int(index / 3.0) % rules.symbol_count)
		else:
			symbols.append(rng.randi_range(0, rules.symbol_count - 1))
	if level.symbols_in_threes:
		for index in range(count - 1, 0, -1):
			var other: int = rng.randi_range(0, index)
			var kept: int = symbols[index]
			symbols[index] = symbols[other]
			symbols[other] = kept
	return symbols


## Puts the level's starting tiles on the grid (symbols drawn after those of the pile).
static func fill_grid(level: PyramidLevel, rules: PyramidRules, grid: TileGrid) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = level.symbol_seed + 1
	for y in level.grid_rows.size():
		var row: String = level.grid_rows[y]
		for x in row.length():
			if row[x] == GRID_TILE:
				grid.set_symbol(Vector2i(x, y), rng.randi_range(0, rules.symbol_count - 1))
