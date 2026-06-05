@tool
class_name KickTable
extends Resource

@export var north: Array[Vector2i] = []
@export var east: Array[Vector2i] = []
@export var south: Array[Vector2i] = []
@export var west: Array[Vector2i] = []

func get_kick_table(direction: PieceInfo.RotationDirection) -> Array[Vector2i]:
    assert(direction >= 0 and direction < PieceInfo.RotationDirection.MAX)
    match direction:
        PieceInfo.RotationDirection.NORTH:
            return north
        PieceInfo.RotationDirection.EAST:
            return east
        PieceInfo.RotationDirection.SOUTH:
            return south
        PieceInfo.RotationDirection.WEST:
            return west
    # This will never happen if the game is well written, but gdscript doesn't understand.
    return []
