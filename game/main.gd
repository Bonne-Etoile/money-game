extends Control
## The game scene (placeholder): the money counter on a plain background. Escape saves and goes back
## to the start menu. Replace its content with the game; keep it launchable on its own (tests,
## screenshots).

const MENU_SCENE: String = "res://game/ui/main_menu.tscn"

@onready var _money: Label = %MoneyLabel


func _ready() -> void:
	Events.money_changed.connect(_show_money)
	_show_money(GameState.progress.money)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		GameState.save_game()
		get_tree().change_scene_to_file(MENU_SCENE)


## A text with values is a key with %d: its node keeps an empty `text` in the scene.
func _show_money(total: int) -> void:
	_money.text = tr("HUD_MONEY") % total
