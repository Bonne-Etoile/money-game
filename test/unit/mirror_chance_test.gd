extends GdUnitTestSuite
## The mirror's great move (game/core/mirror_chance.gd): found only when the grid fills up and
## a piece of the hand, flipped, clears more than unflipped.

const RULES: TileBlocksRules = preload("res://game/data/tile_blocks_rules.tres")


func test_a_flip_that_clears_two_lines_is_a_chance() -> void:
	var game: TileBlocksGame = MirrorChanceSetup.z_hole_game()
	var chance: MirrorChance = MirrorChance.find(game)
	assert_object(chance).is_not_null()
	assert_int(chance.slot).is_equal(0)
	assert_int(chance.clears).is_equal(2)
	var placed: Array[Vector2i] = []
	for cell in chance.piece.cells:
		placed.append(chance.origin + cell)
	placed.sort()
	var hole: Array[Vector2i] = MirrorChanceSetup.Z_HOLE.duplicate()
	hole.sort()
	assert_that(placed).is_equal(hole)


func test_no_chance_while_the_grid_has_room() -> void:
	var game: TileBlocksGame = MirrorChanceSetup.z_hole_game()
	var rules: TileBlocksRules = RULES.duplicate()
	rules.mirror_chance_fill_percent = 90
	game.rules = rules
	assert_object(MirrorChance.find(game)).is_null()


func test_no_chance_when_the_flip_clears_too_little_or_is_off() -> void:
	var game: TileBlocksGame = MirrorChanceSetup.z_hole_game()
	var rules: TileBlocksRules = RULES.duplicate()
	rules.mirror_chance_min_clears = 3
	game.rules = rules
	assert_object(MirrorChance.find(game)).is_null()
	rules.mirror_chance_min_clears = 0
	assert_object(MirrorChance.find(game)).is_null()


func test_no_chance_when_the_piece_does_as_well_unflipped() -> void:
	var game: TileBlocksGame = MirrorChanceSetup.z_hole_game()
	game.hand[0] = game.hand[0].mirrored()
	assert_object(MirrorChance.find(game)).is_null()
