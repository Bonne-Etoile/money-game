extends GdUnitTestSuite
## Pieces (game/core/piece.gd) and their random drawing (game/core/piece_generator.gd).

const SHAPES: PieceShapeSet = preload("res://game/data/piece_shapes.tres")


func test_extent_and_largest_group() -> void:
	var cells: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]
	var piece: Piece = Piece.new(cells, PackedInt32Array([2, 2, 2, 0]))
	assert_that(piece.extent()).is_equal(Vector2i(3, 2))
	assert_int(piece.largest_group()).is_equal(3)
	assert_int(Piece.uniform(cells, 1).largest_group()).is_equal(4)


func test_the_same_seed_gives_the_same_pieces() -> void:
	var first: PieceGenerator = PieceGenerator.new(SHAPES.shapes, 5, 3, 42)
	var second: PieceGenerator = PieceGenerator.new(SHAPES.shapes, 5, 3, 42)
	for _draw in 20:
		var a: Piece = first.next_piece()
		var b: Piece = second.next_piece()
		assert_that(a.cells).is_equal(b.cells)
		assert_that(a.symbols).is_equal(b.symbols)


func test_a_drawn_piece_never_clears_by_itself() -> void:
	var generator: PieceGenerator = PieceGenerator.new(SHAPES.shapes, 5, 3, 7)
	for _draw in 300:
		var piece: Piece = generator.next_piece()
		assert_int(piece.largest_group()).is_less(3)
		for symbol in piece.symbols:
			assert_int(symbol).is_between(0, 4)


func test_every_shape_starts_at_the_top_left_corner() -> void:
	for shape in SHAPES.shapes:
		var left: int = 99
		var top: int = 99
		for cell in shape.cells:
			left = mini(left, cell.x)
			top = mini(top, cell.y)
		assert_int(left).override_failure_message(shape.key).is_equal(0)
		assert_int(top).override_failure_message(shape.key).is_equal(0)
		assert_object(SHAPES.find(shape.key)).is_same(shape)
