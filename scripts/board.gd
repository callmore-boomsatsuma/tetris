@tool
class_name Board
extends Node

var cells: Dictionary[Vector2i, CellData] = {}

@export var size := Vector2i(10, 20)

@export_tool_button("Randomise board") var randomise_board_action = random_generate_board
const rand_colors: Array[Color] = [
	Color.RED,
	Color.BLUE,
	Color.YELLOW,
	Color.GREEN,
]

signal cell_changed(loc: Vector2i, data: CellData)
signal cell_cleared(loc: Vector2i)

func random_generate_board() -> void:
	for loc in cells.keys():
		clear_cell(loc)

	for y in range(size.y):
		for x in range(size.x):
			if randf() >= 0.75:
				set_cell(Vector2i(x, y), CellData.new(rand_colors.pick_random(), randi_range(0, 15)))

func set_cell(loc: Vector2i, data: CellData) -> void:
	cells[loc] = data
	cell_changed.emit(loc, data)

func clear_cell(loc: Vector2i) -> void:
	cells.erase(loc)
	cell_cleared.emit(loc)

func is_cell_solid(loc: Vector2i) -> bool:
	return loc in cells

func try_remove_connection(pos, connection: CellData.Connection) -> bool:
	if pos not in cells:
		return false
	var cell := cells[pos]
	cell.connections &= ~connection
	cell_changed.emit(pos, cell)
	return true

func clear_row(row: int) -> void:
	for i in range(size.x):
		var pos := Vector2i(i, row)
		clear_cell(pos)
		try_remove_connection(pos + Vector2i.UP, CellData.Connection.SOUTH)
		try_remove_connection(pos + Vector2i.DOWN, CellData.Connection.NORTH)

func fall_above_rows(row: int) -> void:
	var keys := cells.keys()
	keys = keys.filter(func(k: Vector2i): return k.y < row)
	keys.sort_custom(func(a: Vector2i, b: Vector2i):
		if a.y > b.y:
			return true
		elif a.y == b.y:
			if a.x < b.x:
				return true
		return false)
	for k in keys:
		set_cell(k + Vector2i.DOWN, cells[k])
		clear_cell(k)
