@tool
class_name BoardVisual
extends Node2D

var cells: Dictionary[Vector2i, CellData] = {}
@export var cell_size := Vector2.ONE * 16:
    set(value):
        cell_size = value
        queue_redraw()

func _draw() -> void:
    draw_set_transform(-cell_size / 2, 0, cell_size)
    for loc in cells:
        var data := cells[loc]
        draw_rect(Rect2(loc, Vector2.ONE), data.color)


func _on_board_cell_changed(loc: Vector2i, data: CellData) -> void:
    cells[loc] = data
    queue_redraw()

func _on_board_cell_cleared(loc: Vector2i) -> void:
    cells.erase(loc)
    queue_redraw()
