class_name MoveResult
extends RefCounted
## What one placement did: for the board to show it (cleared cells flash) and for the tests.

## Grid cells the piece covered.
var placed: Array[Vector2i] = []
var clear: GridClear = GridClear.new()
## The symbols of the cleared cells, before they were removed (for the flash).
var cleared_symbols: PackedInt32Array = []
var points: int = 0
var combo: int = 0
