class_name BoardView
extends Control
## Draws a TileGrid in its frame, the ghost of the piece being dragged (and the cells it would
## clear, glowing), the placed tiles landing, and the cleared cells flashing and shrinking away.
## Only draws: the rules live in game/core/.

## Part of a clear's time the cleared tiles stay lit before they shrink away.
const FLASH_LIT: float = 0.3

var grid: TileGrid
var art: TileArt
## Gold and ice of a level (G17), drawn over their tiles; null in the endless game.
var layer: LevelBoard = null
## The origin the dragged piece would take, valid only while `_ghost` is set.
var ghost_origin: Vector2i = Vector2i.ZERO
var _ghost: Piece
var _ghost_valid: bool = false
## Cells the ghost would clear (they glow), and the time that makes the glow breathe.
var _preview: Array[Vector2i] = []
var _glow_time: float = 0.0
## Tiles just placed, landing (JuiceRules.pop_scale, pop_seconds).
var _pop_cells: Array[Vector2i] = []
var _pop_left: float = 0.0
var _pop_seconds: float = 0.0
var _pop_scale: float = 1.0
## A placement shown to a player who hesitates (G15), drawn as faint tiles.
var _hint: Piece
var _hint_origin: Vector2i = Vector2i.ZERO
var _flash_cells: Array[Vector2i] = []
var _flash_symbols: PackedInt32Array = []
var _flash_left: float = 0.0
## Shake of the drawing (a strong clear), in pixels; the cells do not move for the rules.
var _shake: float = 0.0
var _shake_left: float = 0.0
var _shake_seconds: float = 0.0
var _shake_rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	set_process(false)
	resized.connect(queue_redraw)


## Side of a cell, in pixels.
func cell_size() -> float:
	if grid == null or grid.size == 0:
		return 0.0
	return minf(size.x, size.y) / grid.size


func cell_rect(cell: Vector2i) -> Rect2:
	var side: float = cell_size()
	var gap: float = side * art.cell_gap / 2.0
	return Rect2(Vector2(cell) * side, Vector2.ONE * side).grow(-gap)


## The cell whose top-left corner is nearest to `global_point`.
func nearest_cell(global_point: Vector2) -> Vector2i:
	var local: Vector2 = (global_point - global_position) / cell_size()
	return Vector2i(local.round())


## Centre of `cell`, in global coordinates.
func cell_center(cell: Vector2i) -> Vector2:
	return global_position + (Vector2(cell) + Vector2.ONE / 2.0) * cell_size()


func set_ghost(piece: Piece, origin: Vector2i, valid: bool) -> void:
	_ghost = piece
	ghost_origin = origin
	_ghost_valid = valid
	queue_redraw()


func clear_ghost() -> void:
	_ghost = null
	_preview.clear()
	queue_redraw()


## Cells the ghost would clear: they glow until the ghost moves or goes.
func set_preview(cells: Array[Vector2i]) -> void:
	_preview = cells.duplicate()
	set_process(true)
	queue_redraw()


func preview_cells() -> Array[Vector2i]:
	return _preview


## The tiles of `cells` land a little bigger (`scale`) and settle within `seconds`.
func pop(cells: Array[Vector2i], scale_from: float, seconds: float) -> void:
	if seconds <= 0.0:
		return
	_pop_cells = cells.duplicate()
	_pop_left = seconds
	_pop_seconds = seconds
	_pop_scale = scale_from
	set_process(true)
	queue_redraw()


func set_hint(piece: Piece, origin: Vector2i) -> void:
	_hint = piece
	_hint_origin = origin
	queue_redraw()


func clear_hint() -> void:
	if _hint != null:
		_hint = null
		queue_redraw()


func has_hint() -> bool:
	return _hint != null


func has_ghost() -> bool:
	return _ghost != null


func ghost_valid() -> bool:
	return _ghost_valid


## Grid cells under the ghost.
func ghost_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if _ghost != null:
		for cell in _ghost.cells:
			cells.append(ghost_origin + cell)
	return cells


## Shakes the drawing `pixels` wide, fading out over `seconds`.
func shake(pixels: float, seconds: float) -> void:
	if pixels <= 0.0 or seconds <= 0.0:
		return
	_shake = pixels
	_shake_left = seconds
	_shake_seconds = seconds
	set_process(true)


func is_shaking() -> bool:
	return _shake_left > 0.0


## Shows the cells just cleared fading out.
func flash(result: MoveResult) -> void:
	_flash_cells = result.clear.cells.duplicate()
	_flash_symbols = result.cleared_symbols.duplicate()
	_flash_left = art.flash_seconds
	set_process(not _flash_cells.is_empty())
	queue_redraw()


func _process(delta: float) -> void:
	_flash_left -= delta
	_shake_left = maxf(_shake_left - delta, 0.0)
	_pop_left = maxf(_pop_left - delta, 0.0)
	_glow_time += delta
	if _flash_left <= 0.0:
		_flash_cells.clear()
	if _pop_left <= 0.0:
		_pop_cells.clear()
	set_process(
		(
			not _flash_cells.is_empty()
			or _shake_left > 0.0
			or not _pop_cells.is_empty()
			or not _preview.is_empty()
		)
	)
	queue_redraw()


func _draw() -> void:
	if grid == null or art == null:
		return
	var side: float = cell_size()
	if _shake_left > 0.0:
		var strength: float = _shake * _shake_left / _shake_seconds
		draw_set_transform(
			Vector2(_shake_rng.randf_range(-1, 1), _shake_rng.randf_range(-1, 1)) * strength
		)
	var whole: Rect2 = Rect2(Vector2.ZERO, Vector2.ONE * side * grid.size)
	var frame: float = side * art.frame_width
	TileDrawing.draw_box(self, whole.grow(frame), art.frame_color.darkened(0.35))
	TileDrawing.draw_box(
		self, whole.grow(frame * 0.8).grow_side(SIDE_BOTTOM, -frame * 0.2), art.frame_color
	)
	TileDrawing.draw_box(self, whole.grow(frame * 0.35), art.grid_background)
	for y in grid.size:
		for x in grid.size:
			var cell: Vector2i = Vector2i(x, y)
			var symbol: int = grid.symbol_at(cell)
			var rect: Rect2 = cell_rect(cell)
			if symbol == TileGrid.EMPTY:
				TileDrawing.draw_box(self, rect, art.empty_cell_rim)
				TileDrawing.draw_box(
					self, rect.grow_side(SIDE_TOP, -rect.size.y * 0.06), art.empty_cell
				)
			elif not _pop_cells.has(cell):
				TileDrawing.draw_tile(self, rect, symbol, art)
				_draw_layer(cell)
	_draw_preview()
	_draw_pops()
	_draw_hint()
	_draw_flash()
	_draw_ghost()


func _draw_flash() -> void:
	if _flash_cells.is_empty():
		return
	# First lit up (white-hot), then shrinking away while fading.
	var elapsed: float = 1.0 - clampf(_flash_left / art.flash_seconds, 0.0, 1.0)
	var lit: float = clampf(1.0 - elapsed / FLASH_LIT, 0.0, 1.0)
	var shrink: float = clampf((elapsed - FLASH_LIT) / (1.0 - FLASH_LIT), 0.0, 1.0)
	var scale_now: float = 1.0 + 0.12 * lit - shrink
	for index in _flash_cells.size():
		var rect: Rect2 = cell_rect(_flash_cells[index])
		var grown: Rect2 = Rect2(
			rect.get_center() - rect.size * scale_now / 2.0, rect.size * scale_now
		)
		var tint: Color = Color.WHITE.lerp(art.flash, 1.0 - lit)
		tint.a = 1.0 - shrink * shrink
		TileDrawing.draw_tile(self, grown, _flash_symbols[index], art, tint)
		if lit > 0.0:
			TileDrawing.draw_box(self, grown, Color(1, 1, 1, lit * 0.8))


## Gold tiles get a golden frame; tiles under ice a pale blue sheet.
func _draw_layer(cell: Vector2i) -> void:
	if layer == null:
		return
	var rect: Rect2 = cell_rect(cell)
	if layer.is_gold(cell):
		draw_rect(rect.grow(-rect.size.x * 0.04), art.gold_color, false, rect.size.x * 0.08)
	if layer.has_ice(cell):
		TileDrawing.draw_box(self, rect, art.ice_color)


func _draw_hint() -> void:
	if _hint == null:
		return
	for index in _hint.cells.size():
		var rect: Rect2 = cell_rect(_hint_origin + _hint.cells[index])
		TileDrawing.draw_tile(self, rect, _hint.symbols[index], art, art.hint_tint)


## A valid ghost shows the piece's own tiles, see-through; an invalid one, red boxes.
func _draw_ghost() -> void:
	if _ghost == null:
		return
	for index in _ghost.cells.size():
		var target: Vector2i = ghost_origin + _ghost.cells[index]
		if not grid.has_cell(target):
			continue
		if _ghost_valid:
			TileDrawing.draw_tile(
				self, cell_rect(target), _ghost.symbols[index], art, art.ghost_valid
			)
		else:
			TileDrawing.draw_box(self, cell_rect(target), art.ghost_invalid)


## The cells the ghost would clear glow, breathing.
func _draw_preview() -> void:
	if _preview.is_empty():
		return
	var glow: Color = art.preview_glow
	glow.a *= 0.75 + 0.25 * sin(_glow_time * TAU * 2.0)
	for cell in _preview:
		var rect: Rect2 = cell_rect(cell)
		var symbol: int = grid.symbol_at(cell)
		if symbol != TileGrid.EMPTY:
			TileDrawing.draw_tile(self, rect, symbol, art)
		TileDrawing.draw_box(self, rect.grow(rect.size.x * 0.04), glow)


## Tiles just placed: drawn bigger, settling back with a little bounce.
func _draw_pops() -> void:
	if _pop_cells.is_empty():
		return
	var progress: float = 1.0 - _pop_left / _pop_seconds
	var bounce: float = 1.0 + (_pop_scale - 1.0) * (1.0 - progress) * cos(progress * PI * 1.5)
	for cell in _pop_cells:
		var symbol: int = grid.symbol_at(cell)
		if symbol == TileGrid.EMPTY:
			continue
		var rect: Rect2 = cell_rect(cell)
		var size_now: Vector2 = rect.size * bounce
		TileDrawing.draw_tile(
			self, Rect2(rect.get_center() - size_now / 2.0, size_now), symbol, art
		)
		_draw_layer(cell)
