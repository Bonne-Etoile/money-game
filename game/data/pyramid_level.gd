class_name PyramidLevel
extends Resource
## A hand-made level of prototype 2: the pile of tiles (LevelLayout reads it).

## One text per layer, bottom layer first. Each character is a half tile; a letter marks the
## top-left corner of a tile and names its shape (PyramidRules.legend); "." is empty.
@export_multiline var layers: Array[String] = []
## Seed of the tiles' symbols.
@export var symbol_seed: int = 1
## Whether each symbol comes in threes (the tile count must then be a multiple of 3), so that
## every tile can end in a trio; otherwise symbols are drawn freely.
@export var symbols_in_threes: bool = false
## Tiles already on the grid at the start, one text per row from the top: "#" is a tile, any
## other character an empty cell. Empty list: the grid starts empty.
@export var grid_rows: Array[String] = []
