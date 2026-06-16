class_name CellData
extends RefCounted

var color := GlobalColormap.DEFAULT_COLOR
@warning_ignore("int_as_enum_without_match")
var connections: Connection = 0 as Connection

@warning_ignore("int_as_enum_without_match")
func _init(p_color := GlobalColormap.DEFAULT_COLOR, p_connections := 0 as Connection) -> void:
    color = p_color
    connections = p_connections

enum Connection {
    NONE = 0,
    NORTH = 0b0001,
    EAST = 0b0010,
    SOUTH = 0b0100,
    WEST = 0b1000,
}
