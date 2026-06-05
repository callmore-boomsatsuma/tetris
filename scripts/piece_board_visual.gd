@tool
extends "res://scripts/piece_visual.gd"

var movement_tween: Tween = null
var rotation_tween: Tween = null

func _on_piece_moved(new_pos: Vector2i, warp: bool) -> void:
	if warp:
		position = Vector2(new_pos) * cell_size
	else:
		cleanup_tween(movement_tween)
		movement_tween = create_tween()
		movement_tween.tween_property(self , "position", Vector2(new_pos) * cell_size, 0.05)

func _on_piece_rotated(new_rot: PieceInfo.RotationDirection, warp: bool) -> void:
	if warp:
		rotation = new_rot * (TAU / 4)
	else:
		cleanup_tween(movement_tween)
		rotation_tween = create_tween()
		var dir := lerp_angle(rotation, new_rot * (TAU / 4), 1)
		rotation_tween.tween_property(self , "rotation", dir, 0.05)

func _on_piece_locked(pos: Vector2i) -> void:
	hide()

func _on_piece_spawned(spawn_position: Vector2i, new_piece: PieceInfo) -> void:
	cleanup_tween(movement_tween)
	cleanup_tween(rotation_tween)
	position = Vector2(spawn_position) * cell_size
	piece = new_piece
	show()

func cleanup_tween(tween: Tween) -> void:
	if tween != null:
		if not tween.is_running():
			return
		tween.kill()
