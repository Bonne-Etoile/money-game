extends GdUnitTestSuite
## The game scene (game/main.tscn): the money counter follows GameState through Events.

const MAIN_SCENE: String = "res://game/main.tscn"


func before_test() -> void:
	GameState.reset()


func after_test() -> void:
	GameState.reset()


func test_the_counter_shows_the_money_at_start_and_when_it_changes() -> void:
	GameState.earn(12)
	var runner: GdUnitSceneRunner = scene_runner(MAIN_SCENE)
	await runner.simulate_frames(2)
	var label: Label = runner.find_child("MoneyLabel") as Label
	assert_str(label.text).contains("12")
	GameState.earn(8)
	assert_str(label.text).contains("20")
