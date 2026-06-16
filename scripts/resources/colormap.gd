class_name Colormap
extends Resource

@export var mapping: Dictionary[StringName, Color] = {}

func _init(p_mapping: Dictionary[StringName, Color] = {}) -> void:
    mapping = p_mapping
