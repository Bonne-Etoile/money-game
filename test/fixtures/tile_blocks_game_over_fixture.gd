extends Node
## Screenshot of prototype 1 at game over (make screenshots): the panel offers to go on after
## a rewarded ad, to play again, or to go back to the menu, and says what was missing for the
## record.

const SCENE: PackedScene = preload("res://game/proto_tiles/tile_blocks.tscn")


func _ready() -> void:
	var screen: TileBlocksScreen = SCENE.instantiate()
	GameState.progress.stats.best_score = 400
	# A player past their first games: the continue is offered (AdPacingRules).
	GameState.progress.stats.games_played = 10
	add_child(screen)
	screen.start(1)
	screen.game.scores.score = 280
	var size: int = screen.game.grid.size
	for y in size:
		for x in size:
			if Vector2i(x, y) != Vector2i(size - 1, size - 1):
				screen.game.grid.set_symbol(Vector2i(x, y), (x + y) % 2)
	var bar: Piece = Piece.new([Vector2i(0, 0), Vector2i(1, 0)], PackedInt32Array([0, 1]))
	screen.game.hand.assign([bar, null, null])
	screen.refresh()
