extends GdUnitTestSuite
## The limits of rewarded ads within a game (TileBlocksGame, AdPacingRules): in all, for
## bonuses, and spaced out by pieces placed.

const RULES: TileBlocksRules = preload("res://game/data/tile_blocks_rules.tres")


func _game() -> TileBlocksGame:
	return TileBlocksGame.new(RULES, 1)


func _single(symbol: int) -> Piece:
	return Piece.new([Vector2i.ZERO], PackedInt32Array([symbol]))


func _fill(game: TileBlocksGame) -> void:
	for y in game.grid.size:
		for x in game.grid.size:
			game.grid.set_symbol(Vector2i(x, y), (x + y) % 2)


## Places `count` pieces of one cell along the rows of the grid.
func _play(game: TileBlocksGame, count: int) -> void:
	for _move in count:
		var move: int = game.moves
		game.hand[0] = _single(move % 2)
		assert_object(game.place(0, Vector2i(move % 8, move / 8 * 2))).is_not_null()


func test_bonus_ads_are_spaced_out_by_pieces_placed() -> void:
	var game: TileBlocksGame = _game()
	var pacing: AdPacingRules = RULES.ad_pacing
	assert_bool(game.earn(TileBlocksGame.BONUS_NEW_HAND)).is_true()
	# Another bonus at once: no, whichever it is.
	assert_bool(game.can_earn(TileBlocksGame.BONUS_MIRROR)).is_false()
	assert_bool(game.earn(TileBlocksGame.BONUS_MIRROR)).is_false()
	_play(game, pacing.moves_between_bonus_ads - 1)
	assert_bool(game.can_earn(TileBlocksGame.BONUS_MIRROR)).is_false()
	_play(game, 1)
	assert_bool(game.earn(TileBlocksGame.BONUS_MIRROR)).is_true()


func test_bonus_ads_are_limited_per_game_all_bonuses_together() -> void:
	var game: TileBlocksGame = _game()
	var pacing: AdPacingRules = RULES.ad_pacing
	for ad in pacing.bonus_ads_per_game:
		var bonus: String = TileBlocksGame.BONUSES[ad % TileBlocksGame.BONUSES.size()]
		assert_bool(game.earn(bonus)).is_true()
		_play(game, pacing.moves_between_bonus_ads)
	assert_int(game.bonus_ads()).is_equal(pacing.bonus_ads_per_game)
	for bonus in TileBlocksGame.BONUSES:
		assert_bool(game.can_earn(bonus)).is_false()
	# The continue after an ad is still there: it is the last ad of the game.
	_fill(game)
	assert_bool(game.can_revive_with_ad()).is_true()
	assert_bool(game.revive(true)).is_true()
	assert_int(game.ads_used).is_equal(pacing.ads_per_game)
	assert_int(game.ads_left()).is_equal(0)


func test_a_game_with_no_ads_left_has_no_continue_after_an_ad_but_a_free_one() -> void:
	var game: TileBlocksGame = _game()
	game.ads_used = RULES.ad_pacing.ads_per_game
	_fill(game)
	assert_bool(game.can_revive_with_ad()).is_false()
	assert_bool(game.revive(true)).is_false()
	assert_bool(game.can_revive()).is_true()
	assert_bool(game.revive()).is_true()
