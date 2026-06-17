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
			if offs in piece.cells:
				connections |= 1 << conn

		if sprite_frames != null:
			_draw_tile_textured(piece.cells[i], piece.color, connections)
		else:
			_draw_tile_solid(piece.cells[i], piece.color)


var draw_transform_stack: Array[Transform2D] = []
func push_draw_transform_matrix(xform: Transform2D) -> void:
	draw_transform_stack.push_back(xform)
	_update_draw_transform()
		
func push_draw_transform(position: Vector2, rotation: float = 0.0, scale: Vector2 = Vector2(1, 1)) -> void:
	push_draw_transform_matrix(Transform2D(rotation, scale, 0, position))

func pop_draw_transform() -> void:
	draw_transform_stack.pop_back()
	_update_draw_transform()

func _update_draw_transform() -> void:
	var total_xform: Transform2D
	if draw_transform_stack.is_empty():
		total_xform = Transform2D.IDENTITY
	else:
		total_xform = draw_transform_stack.reduce(func(x: Transform2D, y: Transform2D): return x * y) as Transform2D
	draw_set_transform_matrix(total_xform)


func _draw_tile_solid(pos: Vector2i, color: StringName) -> void:
	draw_rect(Rect2(Vector2(pos) * cell_size - (cell_size / 2), cell_size), GlobalColormap.get_color(color))

func _draw_tile_textured(pos: Vector2i, color: StringName, connections: CellData.Connection) -> void:
	push_draw_transform(Vector2.ZERO, -rotation, Vector2.ONE)
	var rot_count := wrapi(roundi(rotation / (TAU / 4)), 0, 4)
	var new_connections := (connections << rot_count) & 0b1111
	new_connections |= connections >> (4 - rot_count)
	assert(new_connections <= 0b1111)

	draw_texture_rect(sprite_frames.get_frame_texture(color, new_connections), Rect2(Vector2(pos).rotated(rotation) * cell_size - (cell_size / 2), cell_size), false)
	pop_draw_transform()
