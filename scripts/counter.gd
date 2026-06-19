extends Control

func _update_counter(new_value: int) -> void:
	$VBoxContainer/Readout.text = "%d" % new_value