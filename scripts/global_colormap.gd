@tool
class_name GlobalColormap

static var colormap = preload("res://resources/global_colormap.tres")

static func get_all_colors() -> Array[StringName]:
    return colormap.mapping.keys()

static func get_color(color_name: StringName) -> Color:
    return colormap.mapping[color_name]

const DEFAULT_COLOR := &"gray"
