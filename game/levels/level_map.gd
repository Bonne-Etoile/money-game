class_name LevelMap
extends Control
## The map of the level mode (G17): a big mahjong tile made of one small tile per level, which
## takes its colours as levels are won, and a button per level (open once the ones before it
## are won). Pressing one plays it (LevelScreen).

const LEVEL_SCENE: PackedScene = preload("res://game/levels/level.tscn")
const MENU_SCENE: String = "res://game/ui/main_menu.tscn"
## Text colour of a won level's button.
const WON_COLOR: Color = Color(1.0, 0.85, 0.3)

@export var levels: LevelSet
@export var art: TileArt
## Whether the level buttons open their level (tests turn it off and check `chosen_level`).
@export var opens_level: bool = true

var chosen_level: int = -1

@onready var _picture: LevelPicture = %Picture
@onready var _buttons: GridContainer = %LevelButtons


func _ready() -> void:
	(%BackButton as Button).pressed.connect(back_to_menu)
	var won: int = GameState.progress.stats.levels_won
	_picture.art = art
	_picture.tiles = levels.levels.size()
	_picture.won = won
	for index in levels.levels.size():
		var button: Button = Button.new()
		button.text = tr("LEVEL_BUTTON") % (index + 1)
		button.custom_minimum_size = Vector2(140, 88)
		button.add_theme_font_size_override("font_size", 32)
		button.disabled = index > won
		if index < won:
			button.add_theme_color_override("font_color", WON_COLOR)
		button.pressed.connect(play.bind(index))
		_buttons.add_child(button)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		back_to_menu()


## Plays level `index` (from 0).
func play(index: int) -> void:
	chosen_level = index
	if not opens_level:
		return
	var screen: LevelScreen = LEVEL_SCENE.instantiate()
	screen.level_index = index
	get_tree().change_scene_to_node(screen)


## The button of level `index` (tests).
func level_button(index: int) -> Button:
	return _buttons.get_child(index) as Button


func back_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
