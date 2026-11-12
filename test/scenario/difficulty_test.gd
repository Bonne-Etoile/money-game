extends GdUnitTestSuite
## The adaptive difficulty on screen (game/proto_tiles/tile_blocks.tscn): once the player has a
## record, the level shown in the top bar stays calm far from it and climbs close to it.

const SCENE: String = "res://game/proto_tiles/tile_blocks.tscn"


func before_test() -> void:
	GameState.reset()
	GameState.progress.stats.games_played = 10


func _screen() -> GdUnitSceneRunner:
	var runner: GdUnitSceneRunner = scene_runner(SCENE)
	(runner.scene() as TileBlocksScreen).start(1)
	await runner.simulate_frames(2)
	return runner


func test_the_difficulty_stays_calm_until_close_to_the_record() -> void:
	GameState.progress.stats.best_score = 5000
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var label: Label = runner.find_child("LevelLabel") as Label
	screen.game.scores.score = 3000
	screen.refresh()
	assert_int(screen.game.level()).is_equal(0)
	assert_str(label.text).is_equal(tr("HUD_DIFFICULTY") % 0)
	screen.game.scores.score = 4500
	screen.refresh()
	assert_int(screen.game.level()).is_equal(3)
	assert_str(label.text).is_equal(tr("HUD_DIFFICULTY") % 3)
