class_name GridGroups
extends RefCounted
## Groups of identical symbols touching each other by a side (pure logic).

const NEIGHBOURS: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]


## The cells connected to `start` that carry its symbol, in a map cell -> symbol.
static func group_of(start: Vector2i, symbol_of: Dictionary[Vector2i, int]) -> Array[Vector2i]:
	var group: Array[Vector2i] = []
	if not symbol_of.has(start):
		return group
	var symbol: int = symbol_of[start]
	var seen: Dictionary[Vector2i, bool] = {start: true}
	var pending: Array[Vector2i] = [start]
	while not pending.is_empty():
		var cell: Vector2i = pending.pop_back()
		group.append(cell)
		for step in NEIGHBOURS:
			var next: Vector2i = cell + step
			if not seen.has(next) and symbol_of.get(next, -1) == symbol:
				seen[next] = true
				pending.append(next)
	return group
