extends Node
## Screenshot of the mirror's great move (make screenshots): the grid fills up, the S in the
## hand clears two lines once flipped, so the move shows on the grid and the mirror pulses.

const SCENE: PackedScene = preload("res://game/proto_tiles/tile_blocks.tscn")


func _ready() -> void:
	var screen: TileBlocksScreen = SCENE.instantiate()
	GameState.progress.stats.games_played = 10
	add_child(screen)
	screen.start(1)
	var setup: TileBlocksGame = MirrorChanceSetup.z_hole_game()
	screen.game.grid = setup.grid
	(screen.find_child("Board") as BoardView).grid = setup.grid
	var one: Piece = Piece.new([Vector2i.ZERO], PackedInt32Array([0]))
	screen.game.hand.assign([setup.hand[0], one, one])
	screen.refresh()
