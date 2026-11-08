extends GdUnitTestSuite
## The mahjong pile of prototype 2 (game/core/tile_stack.gd): which tiles are free.


func _tile(x: int, y: int, layer: int) -> StackTile:
	return StackTile.new(Vector2i(x, y), layer, Piece.uniform([Vector2i.ZERO], 0))


func test_a_row_frees_only_its_ends() -> void:
	var stack: TileStack = TileStack.new([_tile(0, 0, 0), _tile(2, 0, 0), _tile(4, 0, 0)])
	assert_that(stack.free_tiles()).is_equal([0, 2] as Array[int])
	assert_object(stack.take(1)).is_null()
	assert_object(stack.take(0)).is_not_null()
	assert_bool(stack.is_free(1)).is_true()
	assert_int(stack.remaining()).is_equal(2)


func test_a_tile_on_top_blocks_the_tiles_it_straddles() -> void:
	var stack: TileStack = TileStack.new([_tile(0, 0, 0), _tile(2, 0, 0), _tile(1, 0, 1)])
	assert_that(stack.free_tiles()).is_equal([2] as Array[int])
	stack.take(2)
	assert_that(stack.free_tiles()).is_equal([0, 1] as Array[int])


func test_tiles_half_a_row_apart_still_block_each_other_sideways() -> void:
	var stack: TileStack = TileStack.new([_tile(0, 0, 0), _tile(2, 1, 0), _tile(4, 0, 0)])
	assert_bool(stack.is_free(1)).is_false()
	assert_bool(stack.is_free(0)).is_true()


func test_a_taken_tile_is_gone() -> void:
	var stack: TileStack = TileStack.new([_tile(0, 0, 0)])
	stack.take(0)
	assert_bool(stack.is_empty()).is_true()
	assert_bool(stack.is_free(0)).is_false()
	assert_object(stack.take(0)).is_null()
