@tool
class_name BoardVisual
extends Node2D

@export var sprite_frames: SpriteFrames

var cells: Dictionary[Vector2i, CellData] = {}
@export var cell_size := Vector2.ONE * 16:
	set(value):
		cell_size = value
		queue_redraw()

func _draw() -> void:
	draw_set_transform(-cell_size / 2, 0, cell_size)
	for loc in cells:
		var data := cells[loc]
		if sprite_frames:
			draw_tile(loc, data)
		else:
			draw_tile_solid(loc, data)

const colors := {
	Color(0.0, 1.0, 1.0): "cyan",
	Color(0.0, 0.0, 1.0): "blue",
	Color(1.0, 0.498, 0.0): "orange",
	Color(1.0, 1.0, 0.0): "yellow",
	Color(0.0, 1.0, 0.0): "green",
	Color(0.498, 0.0, 1.0): "purple",
	Color(1.0, 0.0, 0.0): "red",
}

func draw_tile(location: Vector2i, data: CellData) -> void:
	assert(sprite_frames != null)
	draw_texture_rect(sprite_frames.get_frame_texture(colors[data.color], data.connections), Rect2(location, Vector2.ONE), false, data.color)

func draw_tile_solid(location: Vector2i, data: CellData) -> void:
	draw_rect(Rect2(location, Vector2.ONE), data.color)


func _on_board_cell_changed(loc: Vector2i, data: CellData) -> void:
	cells[loc] = data
	queue_redraw()

func _on_board_cell_cleared(loc: Vector2i) -> void:
	cells.erase(loc)
	queue_redraw()
