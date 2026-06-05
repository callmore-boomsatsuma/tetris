@tool
extends "res://scripts/piece_visual.gd"

func _draw() -> void:
	if piece == null:
		return
	draw_set_transform(piece.display_offset * cell_size, 0, Vector2.ONE)
	super._draw()
