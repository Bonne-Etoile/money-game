class_name TileBlocksGame
extends RefCounted
## Prototype 1, "tile blocks" (docs/etude-concurrence.md, appendix B, idea 1): pieces of tiles
## placed on a grid; the player may turn them (TileBlocksRules.can_rotate). A full row or
## column clears, and so do 3 identical symbols touching each other. A new piece takes the
## place of a placed one (or three come when the hand is empty); the game is over when
## no piece of the hand fits anywhere, unless the player revives it (after a rewarded ad).
## New pieces get harder as the player does well, easier when they struggle (DifficultyDirector),
## and a new hand never leaves the player without a move while the grid has room
## (DifficultyRules.playable_until_fill_percent). Bonuses (new pieces,
## mirror) have a few free uses per game, then one more use per rewarded ad. Rewarded ads are
## limited per game (AdPacingRules): in all, for bonuses, and spaced out by pieces placed.

## Replaces every piece of the hand by one with room (TileBlocksGame.new_hand).
const BONUS_NEW_HAND: String = "new_hand"
## Flips a piece of the hand left to right (TileBlocksGame.mirror).
const BONUS_MIRROR: String = "mirror"
const BONUSES: Array[String] = [BONUS_NEW_HAND, BONUS_MIRROR]

var rules: TileBlocksRules
var grid: TileGrid
## The pieces offered; null where a piece was already placed.
var hand: Array[Piece] = []
var scores: ScoreKeeper
## Revives used in this game (at most `rules.revives_per_game`).
var revives_used: int = 0
## Pieces placed in this game.
var moves: int = 0
## How hard new pieces are; null: pure chance.
var difficulty: DifficultyDirector = null
## Uses of each bonus left (BONUS_*).
var bonus_charges: Dictionary[String, int] = {}
## Uses of each bonus earned with a rewarded ad in this game.
var bonus_ads_used: Dictionary[String, int] = {}
## Rewarded ads that gave something in this game, all kinds together (continue, bonuses, extra
## pieces of a level).
var ads_used: int = 0
var pacing: AdPacingRules
## The level's tiles that need more than a clear (gold, ice; level mode, G17); null: none.
var layer: LevelBoard = null
var _generator: PieceGenerator
## Pieces placed when a bonus was last earned with an ad (-1: none yet in this game).
var _last_bonus_ad_move: int = -1


## `stats`: the player's past games, for the starting difficulty (null: a new player).
func _init(game_rules: TileBlocksRules, random_seed: int, stats: PlayerStats = null) -> void:
	rules = game_rules
	pacing = rules.ad_pacing if rules.ad_pacing != null else AdPacingRules.new()
	grid = TileGrid.new(rules.grid_size)
	scores = ScoreKeeper.new(rules.scoring)
	if rules.difficulty != null:
		difficulty = DifficultyDirector.new(rules.difficulty, stats)
	for bonus in BONUSES:
		bonus_charges[bonus] = maxi(rules.bonus_free_uses, 0)
		bonus_ads_used[bonus] = 0
	_generator = PieceGenerator.new(
		rules.shape_set.pick(rules.shape_keys), rules.symbol_count, rules.match_size, random_seed
	)
	_refill_hand()


func score() -> int:
	return scores.score


func can_place(slot: int, origin: Vector2i) -> bool:
	return _piece_in(slot) != null and grid.can_place(hand[slot], origin)


## Places the piece of `slot` at `origin`, clears what is to clear and scores; null when the
## move is not allowed.
func place(slot: int, origin: Vector2i) -> MoveResult:
	if not can_place(slot, origin):
		return null
	var piece: Piece = hand[slot]
	grid.place(piece, origin)
	hand[slot] = null
	var result: MoveResult = MoveResult.new()
	for cell in piece.cells:
		result.placed.append(origin + cell)
	result.clear = grid.find_clears(rules.match_size)
	for cell in result.clear.cells:
		result.cleared_symbols.append(grid.symbol_at(cell))
	if layer == null:
		grid.remove(result.clear.cells)
	else:
		grid.remove(layer.apply_clear(result.clear.cells))
	result.points = scores.score_move(piece.cells.size(), result.clear)
	if not result.clear.is_empty() and grid.filled_count() == 0:
		result.empty_grid = true
		scores.add(rules.scoring.empty_grid_bonus)
		result.points += rules.scoring.empty_grid_bonus
	result.combo = scores.combo
	moves += 1
	if rules.refill_each_slot:
		hand[slot] = _next_piece()
		_keep_playable([slot])
	elif hand.all(func(waiting: Piece) -> bool: return waiting == null):
		_refill_hand()
	return result


## Turns the piece of `slot` a quarter turn clockwise; false when not allowed.
func rotate(slot: int) -> bool:
	if not rules.can_rotate or _piece_in(slot) == null:
		return false
	hand[slot] = hand[slot].rotated()
	return true


## Over when no piece left in the hand fits anywhere (in any of its turns, when the player
## can turn pieces).
func is_over() -> bool:
	for piece in hand:
		if piece != null and _fits_somehow(piece):
			return false
	return true


func _fits_somehow(piece: Piece) -> bool:
	var turned: Piece = piece
	for _turn in 4 if rules.can_rotate else 1:
		if grid.fits_anywhere(turned):
			return true
		turned = turned.rotated()
	return false


## True when the game is over and a revive is left (free, or after an ad).
func can_revive() -> bool:
	return revives_used < rules.revives_per_game and is_over()


## True when a revive is left and this game may still show a rewarded ad for it.
func can_revive_with_ad() -> bool:
	return can_revive() and ads_left() > 0


## Goes on with a lost game: clears a cross of `rules.revive_clear_lines` rows and columns in
## the middle of the grid, without points, so that every piece of the hand fits again.
## `with_ad`: the revive was paid by a rewarded ad (it counts). False when not allowed.
func revive(with_ad: bool = false) -> bool:
	if not (can_revive_with_ad() if with_ad else can_revive()):
		return false
	revives_used += 1
	if with_ad:
		ads_used += 1
	var lines: int = mini(rules.revive_clear_lines, grid.size)
	var first: int = (grid.size - lines) >> 1
	var cells: Array[Vector2i] = []
	for line in range(first, first + lines):
		for along in grid.size:
			cells.append(Vector2i(along, line))
			cells.append(Vector2i(line, along))
	grid.remove(cells)
	return true


## The difficulty level now (0 without adaptive difficulty).
func level() -> int:
	return 0 if difficulty == null else difficulty.level(score(), scores.combo)


## Pieces of the hand that fit somewhere (in some turn).
func pieces_that_fit() -> int:
	var count: int = 0
	for piece in hand:
		if piece != null and _fits_somehow(piece):
			count += 1
	return count


## True when the game goes on but hardly any piece fits (TileBlocksRules.trouble_fitting_pieces):
## the moment to offer a bonus.
func is_in_trouble() -> bool:
	return not is_over() and pieces_that_fit() <= rules.trouble_fitting_pieces


func charges(bonus: String) -> int:
	return bonus_charges.get(bonus, 0)


## Rewarded ads this game may still show (AdPacingRules.ads_per_game; 0 there: no limit).
func ads_left() -> int:
	if pacing.ads_per_game <= 0:
		return 1
	return maxi(pacing.ads_per_game - ads_used, 0)


## A rewarded ad of another kind (extra pieces of a level) was watched: it counts. False when
## this game may show no more.
func use_ad() -> bool:
	if ads_left() <= 0:
		return false
	ads_used += 1
	return true


## Whether a rewarded ad can earn a use of `bonus` now: ads left in this game, bonus ads left,
## and enough pieces placed since the last one (AdPacingRules).
func can_earn(bonus: String) -> bool:
	if not bonus_ads_used.has(bonus) or ads_left() <= 0:
		return false
	if pacing.bonus_ads_per_game > 0 and bonus_ads() >= pacing.bonus_ads_per_game:
		return false
	return _last_bonus_ad_move < 0 or moves - _last_bonus_ad_move >= pacing.moves_between_bonus_ads


## Bonus uses earned with rewarded ads in this game, all bonuses together.
func bonus_ads() -> int:
	var total: int = 0
	for bonus: String in bonus_ads_used:
		total += bonus_ads_used[bonus]
	return total


## A use of `bonus` earned by watching a rewarded ad; false when no more can be earned now.
func earn(bonus: String) -> bool:
	if not can_earn(bonus):
		return false
	bonus_ads_used[bonus] += 1
	bonus_charges[bonus] += 1
	ads_used += 1
	_last_bonus_ad_move = moves
	return true


## Bonus: every piece of the hand is replaced by a new one, the one with the most room among a
## few drawn (TileBlocksRules.new_hand_candidates). Takes a use; false when none is left.
func new_hand() -> bool:
	if charges(BONUS_NEW_HAND) <= 0:
		return false
	bonus_charges[BONUS_NEW_HAND] -= 1
	for slot in hand.size():
		hand[slot] = _generator.next_piece_among(
			grid, rules.new_hand_candidates, false, rules.can_rotate
		)
	return true


## Bonus: the piece of `slot` flipped left to right. Takes a use; false when none is left or
## the slot is empty.
func mirror(slot: int) -> bool:
	if charges(BONUS_MIRROR) <= 0 or _piece_in(slot) == null:
		return false
	bonus_charges[BONUS_MIRROR] -= 1
	hand[slot] = hand[slot].mirrored()
	return true


func _piece_in(slot: int) -> Piece:
	if slot < 0 or slot >= hand.size():
		return null
	return hand[slot]


## Deals a whole new hand (start of a game, all pieces placed without `refill_each_slot`).
func _refill_hand() -> void:
	hand.clear()
	var slots: Array[int] = []
	for slot in rules.hand_size:
		hand.append(_next_piece())
		slots.append(slot)
	_keep_playable(slots)


## A new hand on the grid as it is (tests of the playability guarantee).
func deal_hand() -> void:
	_refill_hand()


## Playability guarantee: when the new pieces of `slots` leave no piece of the hand that fits,
## while the grid still has room, the last of them is replaced by a piece that fits.
func _keep_playable(slots: Array[int]) -> void:
	if difficulty == null or slots.is_empty() or not is_over():
		return
	if not difficulty.guarantees_play(grid.filled_count(), grid.size * grid.size):
		return
	var fitting: Piece = _generator.piece_that_fits(grid, rules.can_rotate)
	if fitting != null:
		hand[slots[-1]] = fitting


## A new piece, as hard (or as easy) as the difficulty level says.
func _next_piece() -> Piece:
	if difficulty == null:
		return _generator.next_piece()
	var at_level: int = level()
	var candidates: int = difficulty.candidates(at_level)
	return _generator.next_piece_among(
		grid, candidates, difficulty.hardest(at_level), rules.can_rotate
	)
