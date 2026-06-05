@tool
class_name PieceInfo
extends Resource

@export var cells: Array[Vector2i]:
    set(value):
        cells = value
        emit_changed()
@export var color: Color:
    set(value):
        color = value
        emit_changed()
@export var kick_table: KickTable:
    set(value):
        kick_table = value
        emit_changed()

## Offset to render this piece in cells when drawn as an icon.
@export var display_offset: Vector2:
    set(value):
        display_offset = value
        emit_changed()

func _init(
    p_cells: Array[Vector2i] = [],
    p_color: Color = Color.WHITE,
    p_kick_table: KickTable = null,
    p_display_offset := Vector2.ZERO
) -> void:
    cells = p_cells
    color = p_color
    kick_table = p_kick_table
    display_offset = p_display_offset

enum RotationDirection {
	NORTH,
	EAST,
	SOUTH,
	WEST,

    MAX,
}

func rotation_direction_rotate_left(rot: RotationDirection) -> RotationDirection:
    return posmod(rot - 1, RotationDirection.MAX) as RotationDirection

func rotation_direction_rotate_right(rot: RotationDirection) -> RotationDirection:
    return posmod(rot + 1, RotationDirection.MAX) as RotationDirection
