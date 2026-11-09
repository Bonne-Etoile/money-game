class_name Pointer
extends RefCounted
## Simulated finger for the scenario tests: taps and drags in game-screen coordinates.
## Simulated mouse events are in window pixels (the window is scaled from the 720 x 1280
## game screen), hence the conversion.


static func on_screen(runner: GdUnitSceneRunner, point: Vector2) -> Vector2:
	return runner.scene().get_viewport().get_screen_transform() * point


static func tap(runner: GdUnitSceneRunner, point: Vector2) -> void:
	runner.set_mouse_position(on_screen(runner, point))
	runner.simulate_mouse_button_press(MOUSE_BUTTON_LEFT)
	await runner.await_input_processed()
	runner.simulate_mouse_button_release(MOUSE_BUTTON_LEFT)
	await runner.await_input_processed()


static func drag(runner: GdUnitSceneRunner, from: Vector2, to: Vector2) -> void:
	runner.set_mouse_position(on_screen(runner, from))
	runner.simulate_mouse_button_press(MOUSE_BUTTON_LEFT)
	await runner.await_input_processed()
	runner.simulate_mouse_move(on_screen(runner, to.lerp(from, 0.5)))
	await runner.await_input_processed()
	runner.simulate_mouse_move(on_screen(runner, to))
	await runner.await_input_processed()
	runner.simulate_mouse_button_release(MOUSE_BUTTON_LEFT)
	await runner.await_input_processed()
