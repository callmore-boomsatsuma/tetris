extends Control

@export var next_queue_entry_root: Node
@export var next_queue_entry_scene: PackedScene

func _ready() -> void:
	pass

func _on_update_next_queue(next_queue: Array[PieceInfo]) -> void:
	var entry_count := next_queue_entry_root.get_child_count()
	if entry_count > next_queue.size():
		for i in range(next_queue.size(), entry_count):
			next_queue_entry_root.get_child(i).queue_free()
	elif entry_count < next_queue.size():
		for i in range(next_queue.size() - entry_count):
			next_queue_entry_root.add_child(next_queue_entry_scene.instantiate())
	
	for i in range(next_queue.size()):
		var piece := next_queue[i]
		next_queue_entry_root.get_child(i).displayed_piece = piece
