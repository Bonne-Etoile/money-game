extends Node
## Screenshot of the hint on prototype 1 (make screenshots, G15): after a long wait, a
## placement that clears shows as faint tiles on the grid.

const SCENE: PackedScene = preload("res://game/proto_tiles/tile_blocks.tscn")


func _ready() -> void:
	var screen: TileBlocksScreen = SCENE.instantiate()
	add_child(screen)
	screen.start(4)
	for x in 7:
		screen.game.grid.set_symbol(Vector2i(x, 6), x % 2)
	screen.game.grid.set_symbol(Vector2i(2, 2), 2)
	screen.refresh()
	screen.idle_seconds = screen.rules.hint_after_seconds
