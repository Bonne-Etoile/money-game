class_name LevelBoard
extends RefCounted
## The tiles of a level that a plain clear does not simply remove (G17): gold tiles (freed by
## a line or a trio: the goal of some levels) and ice (a tile under ice needs two clears: the
## first breaks the ice, the second removes the tile). Stones are TileGrid.STONE cells. Pure
## logic: TileBlocksGame asks it which cleared cells really go.

## Ice layers left on each cell that has some.
var ice: Dictionary[Vector2i, int] = {}
## Gold tiles still on the grid.
var gold: Dictionary[Vector2i, bool] = {}
## Gold tiles freed so far.
var gold_freed: int = 0
## Gold tiles at the start.
var gold_total: int = 0


## Of the cells a move clears, those whose tile really goes: a cell under ice loses a layer of
## ice and keeps its tile; a gold tile that goes is freed.
func apply_clear(cells: Array[Vector2i]) -> Array[Vector2i]:
	var removed: Array[Vector2i] = []
	for cell in cells:
		var layers: int = ice.get(cell, 0)
		if layers > 0:
			if layers == 1:
				ice.erase(cell)
			else:
				ice[cell] = layers - 1
			continue
		removed.append(cell)
		if gold.has(cell):
			gold.erase(cell)
			gold_freed += 1
	return removed


func has_ice(cell: Vector2i) -> bool:
	return ice.get(cell, 0) > 0


func is_gold(cell: Vector2i) -> bool:
	return gold.has(cell)
