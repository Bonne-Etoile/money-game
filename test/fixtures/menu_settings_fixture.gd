extends Node
## Screenshot of the start menu with its settings panel open (make screenshots).

const SCENE: PackedScene = preload("res://game/ui/main_menu.tscn")


func _ready() -> void:
	var menu: MainMenu = SCENE.instantiate()
	menu.opens_game = false
	add_child(menu)
	menu.show_page(&"settings")
