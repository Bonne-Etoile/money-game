class_name GridClear
extends RefCounted
## What a move clears: the cells, and how many full lines and symbol groups made it.

var cells: Array[Vector2i] = []
## Full rows and columns.
var lines: int = 0
## Groups of identical symbols touching each other.
var groups: int = 0


func is_empty() -> bool:
	return cells.is_empty()


## Lines and groups together.
func count() -> int:
	return lines + groups
