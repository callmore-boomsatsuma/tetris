@tool
extends Node2D

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


func _draw() -> void:
	if piece == null:
		return
	for i in range(piece.cells.size()):
		draw_rect(Rect2(Vector2(piece.cells[i]) * cell_size - (cell_size / 2), cell_size), piece.color)
