extends Node
## Screenshot of a level whose pieces ran out (make screenshots): the hand is empty, and the
## end panel offers "+5 pieces" after a rewarded ad, or to try again (no "new pieces").

const SCENE: PackedScene = preload("res://game/levels/level.tscn")


func _ready() -> void:
	var screen: LevelScreen = SCENE.instantiate()
	screen.level_index = 0
	add_child(screen)
	screen.level.pieces_left = 1
	screen.game.pieces_cap = 1
	screen.game.hand.assign([Piece.new([Vector2i.ZERO], PackedInt32Array([0])), null, null])
	screen.level.place(0, Vector2i(0, 0))
	screen.refresh()
