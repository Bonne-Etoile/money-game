class_name PileView
extends BoardView
## Draws the pile of the "stamp" prototype (StampPile): each column shows its height as
## stacked tile edges and its top tile. As a BoardView, it takes the ghost of the shape being
## dragged; `grid` holds the top symbols (refresh() keeps it in step).

## How far each tile of a column is drawn above the one below, as a fraction of a cell.
const LIFT: float = 0.07

var pile: StampPile


## Copies the pile's top symbols into `grid` and redraws.
func refresh() -> void:
	grid = pile.surface()
	queue_redraw()


func _draw() -> void:
	if pile == null or art == null:
		return
	var side: float = cell_size()
	draw_rect(Rect2(Vector2.ZERO, Vector2.ONE * side * pile.size), art.grid_background)
	for y in pile.size:
		for x in pile.size:
			var cell: Vector2i = Vector2i(x, y)
			var rect: Rect2 = cell_rect(cell)
			var height: int = pile.height(cell)
			if height == 0:
				TileDrawing.draw_box(self, rect, art.empty_cell)
				continue
			for level in height - 1:
				var lower: Rect2 = rect
				lower.position.y -= level * LIFT * side
				TileDrawing.draw_box(self, lower, art.tile_side)
			var top: Rect2 = rect
			top.position.y -= (height - 1) * LIFT * side
			TileDrawing.draw_tile(self, top, pile.top_symbol(cell), art)
	_draw_shape_ghost()


func _draw_shape_ghost() -> void:
	if not has_ghost():
		return
	var tint: Color = art.ghost_valid if ghost_valid() else art.ghost_invalid
	for cell in ghost_cells():
		if pile.has_cell(cell):
			TileDrawing.draw_box(self, cell_rect(cell), tint)
