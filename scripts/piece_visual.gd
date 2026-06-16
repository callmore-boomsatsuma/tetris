@tool
extends Node2D

@export var sprite_frames: SpriteFrames

@export var piece: PieceInfo:
	get:
		return piece
	set(value):
		if piece != null:
			piece.changed.disconnect(queue_redraw)
		if value != null:
			value.changed.connect(queue_redraw)
		piece = value
		queue_redraw()
@export var cell_size := Vector2.ONE * 16.0:
	set(value):
		cell_size = value
		queue_redraw()


const connection_offsets: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]

func _draw() -> void:
	if piece == null:
		return
	for i in range(piece.cells.size()):
		var connections := CellData.Connection.NONE
		for conn in range(connection_offsets.size()):
			var offs := piece.cells[i] + connection_offsets[conn]
			print(offs)
			if offs in piece.cells:
				connections |= 1 << i

		if sprite_frames != null:
			_draw_tile_textured(piece.cells[i], piece.color, connections)
		else:
			_draw_tile_solid(piece.cells[i], piece.color)

func _draw_tile_solid(pos: Vector2i, color: StringName) -> void:
	draw_rect(Rect2(Vector2(pos) * cell_size - (cell_size / 2), cell_size), GlobalColormap.get_color(color))

func _draw_tile_textured(pos: Vector2i, color: StringName, connections: CellData.Connection) -> void:
	draw_texture_rect(sprite_frames.get_frame_texture(color, connections), Rect2(Vector2(pos) * cell_size - (cell_size / 2), cell_size), false)
