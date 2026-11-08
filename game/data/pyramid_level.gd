class_name PyramidLevel
extends Resource
## A hand-made level of prototype 2: the pile of tiles (LevelLayout reads it).

## One text per layer, bottom layer first. Each character is a half tile; a letter marks the
## top-left corner of a tile and names its shape (PyramidRules.legend); "." is empty.
@export_multiline var layers: Array[String] = []
## Seed of the tiles' symbols (only their look in this prototype).
@export var symbol_seed: int = 1
## Tiles already on the grid at the start, one text per row from the top: "#" is a tile, any
## other character an empty cell. Empty list: the grid starts empty.
@export var grid_rows: Array[String] = []
