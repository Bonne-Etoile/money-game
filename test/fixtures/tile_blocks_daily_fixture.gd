extends Node
## Screenshot of the daily challenge at game over (make screenshots, G14 and G16): the player
## came back after days away, so the continue is free, and the panel shows the streak.

const SCENE: PackedScene = preload("res://game/proto_tiles/daily.tscn")


func _ready() -> void:
	GameState.day_override = 700
	GameState.progress.stats.start_session(690)
	GameState.progress.stats.start_session(700)
	GameState.progress.stats.finish_daily(699, 320)
	GameState.progress.stats.finish_daily(700, 320)
	var screen: TileBlocksScreen = SCENE.instantiate()
	add_child(screen)
	screen.game.scores.score = 180
	TileBlocksDriver.lose(screen)
