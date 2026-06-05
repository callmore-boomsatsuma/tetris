class_name GameManager
extends Node

var piece_set: Array[PieceInfo] = [
	preload("res://resources/pieces/piece_j.tres"),
	preload("res://resources/pieces/piece_l.tres"),
	preload("res://resources/pieces/piece_s.tres"),
	preload("res://resources/pieces/piece_t.tres"),
	preload("res://resources/pieces/piece_z.tres"),
	preload("res://resources/pieces/piece_i.tres"),
	preload("res://resources/pieces/piece_o.tres"),
]

var controling_piece := false
var piece_position := Vector2i.ZERO
var piece_rotation := PieceInfo.RotationDirection.NORTH
var active_piece := piece_set[0]
@export var board: Board

@export var piece_randomiser: PieceRandomiser

var held_piece: PieceInfo = null

var piece_entry_delay := 0.0
var piece_fall_delay := 0.0
var piece_lock_delay := 0.0

var piece_auto_shift_delay := 0.0
var piece_last_moved_direction := Vector2i.ZERO

var input_queue_hard_drop := false
var input_queue_soft_drop := false
var input_queue_movement_vector := Vector2i.ZERO
var input_queue_movement := true
var input_queue_rotation := 0
var input_queue_hold := false

signal piece_moved(new_position: Vector2i, warp: bool)
signal piece_rotated(new_rotation: PieceInfo.RotationDirection, warp: bool)
signal piece_locked(position: Vector2i)
signal piece_spawned(position: Vector2i, piece: PieceInfo)

signal ghost_piece_moved(new_position: Vector2i, warp: bool)
signal ghost_piece_rotated(new_rotation: PieceInfo.RotationDirection, warp: bool)
signal ghost_piece_locked(position: Vector2i)
signal ghost_piece_spawned(position: Vector2i, piece: PieceInfo)

signal update_next_queue(next_queue: Array[PieceInfo])

func _ready():
	spawn_piece()

	piece_moved.connect(_on_piece_moved)
	piece_rotated.connect(_on_piece_rotated)
	piece_locked.connect(_on_piece_locked)

func _physics_process(delta: float) -> void:
	if piece_entry_delay > 0:
		piece_entry_delay -= delta
		if piece_entry_delay <= 0:
			piece_entry_delay_timeout()

	if not controling_piece:
		input_queue_hard_drop = false
		input_queue_hold = false
		input_queue_rotation = 0
		input_queue_soft_drop = false
		handle_input_auto_repeat_charging()
		return
	
	if input_queue_hold:
		if held_piece == null:
			held_piece = active_piece
			spawn_piece()
		else:
			var temp = active_piece
			active_piece = held_piece
			held_piece = temp
			init_piece()
		print("hold")
		
		input_queue_hold = false

	if input_queue_movement:
		handle_horizontal_movement_input(input_queue_movement_vector)
		input_queue_movement = false

	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		piece_auto_shift_delay -= delta
		if piece_auto_shift_delay <= 0:
			try_move_active_piece(piece_last_moved_direction)
			piece_auto_shift_delay = 0.025

	if input_queue_hard_drop:
		hard_drop()
		input_queue_hard_drop = false
	
	if input_queue_soft_drop:
		fall_row()
	
	match input_queue_rotation:
		-1:
			try_rotate_piece_left()
		1:
			try_rotate_piece_right()
	input_queue_rotation = 0
	
	if is_piece_able_to_fall():
		var fall_multiplier := 1.0
		if Input.is_action_pressed("soft_drop"):
			fall_multiplier = 20.0
		piece_fall_delay -= delta * fall_multiplier
		while piece_fall_delay <= 0:
			if not fall_row():
				print("Piece cannot fall anymore, break out!")
				reset_fall_delay()
				break
			piece_fall_delay += get_fall_delay()
	elif piece_lock_delay > 0:
		piece_lock_delay -= delta
		if piece_lock_delay <= 0:
			lock_piece()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hard_drop"):
		input_queue_hard_drop = true
		get_viewport().set_input_as_handled()
		return
	
	elif event.is_action_pressed("move_left"):
		input_queue_movement_vector = Vector2i.LEFT
		input_queue_movement = true
		get_viewport().set_input_as_handled()
		return
	elif event.is_action_released("move_left"):
		print("released move_left")
		if Input.is_action_pressed("move_right"):
			input_queue_movement_vector = Vector2i.RIGHT
			input_queue_movement = true
		else:
			input_queue_movement_vector = Vector2i.ZERO
		get_viewport().set_input_as_handled()
		return

	elif event.is_action_pressed("move_right"):
		input_queue_movement_vector = Vector2i.RIGHT
		input_queue_movement = true
		get_viewport().set_input_as_handled()
		return
	elif event.is_action_released("move_right"):
		if Input.is_action_pressed("move_left"):
			input_queue_movement_vector = Vector2i.LEFT
			input_queue_movement = true
		else:
			input_queue_movement_vector = Vector2i.ZERO
		get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("rotate_left"):
		input_queue_rotation = -1
		get_viewport().set_input_as_handled()
		return
	elif event.is_action_pressed("rotate_right"):
		input_queue_rotation = 1
		get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("hold"):
		input_queue_hold = true
		get_viewport().set_input_as_handled()
		return
	
	assert(not get_viewport().is_input_handled(), "Input was handled but not returned early.")

func handle_input_auto_repeat_charging() -> void:
	if not input_queue_movement:
		return

	input_queue_movement = false
	piece_last_moved_direction = input_queue_movement_vector
	print("charging auto repeat")


func handle_horizontal_movement_input(movement: Vector2i) -> void:
	try_move_active_piece(movement)
	piece_last_moved_direction = movement
	piece_auto_shift_delay = 0.2


func spawn_piece() -> void:
	active_piece = get_next_piece()
	init_piece()


func init_piece() -> void:
	controling_piece = true
	force_warp_active_piece(Vector2i(4, 1))
	set_piece_rotation(PieceInfo.RotationDirection.NORTH)
	reset_fall_delay()
	reset_lock_delay()
	piece_spawned.emit(piece_position, active_piece)
	handle_initial_rotation_system()
	ghost_piece_spawned.emit(piece_position, active_piece)
	update_ghost_piece()

func handle_initial_rotation_system() -> void:
	var rotation := int(Input.is_action_pressed("rotate_right")) - int(Input.is_action_pressed("rotate_left"))
	if rotation != 0:
		try_rotate_piece(rotation)


func force_warp_active_piece(to: Vector2i) -> void:
	piece_position = to
	piece_moved.emit(piece_position, true)

func try_move_active_piece(offset: Vector2i) -> bool:
	if can_move_active_piece(offset):
		piece_position += offset
		piece_moved.emit(piece_position, false)
		return true
	return false

func can_move_active_piece(offset: Vector2i) -> bool:
	var board_rect := Rect2i(Vector2i.ZERO, board.size)
	for pos in get_active_piece_cells():
		var point := pos + piece_position + offset
		if not board_rect.has_point(point):
			return false
		if board.is_cell_solid(point):
			return false
	return true

func hard_drop() -> void:
	while fall_row():
		pass
	lock_piece()

func fall_row() -> bool:
	if try_move_active_piece(Vector2i.DOWN):
		# reset_fall_delay()
		reset_lock_delay()
		return true
	return false

func lock_piece() -> void:
	controling_piece = false
	piece_locked.emit(piece_position)
	ghost_piece_locked.emit(piece_position)
	for pos in get_active_piece_cells():
		var point := pos + piece_position
		board.set_cell(point, CellData.new(active_piece.color))
	
	clear_lines()

func piece_entry_delay_timeout() -> void:
	spawn_piece()

func reset_fall_delay() -> void:
	piece_fall_delay = get_fall_delay()

func get_fall_delay() -> float:
	# return 5.0
	return 0.25
	# return 1 / 60.0
	# return 0.0001

func reset_lock_delay() -> void:
	piece_lock_delay = get_lock_delay()

func get_lock_delay() -> float:
	return 1.5

func is_piece_able_to_fall() -> bool:
	return can_move_active_piece(Vector2i.DOWN)

## Returns an index into the kick table, or -1 if no valid kick was found
func test_kick_tables(from_kick_table: Array[Vector2i], to_kick_table: Array[Vector2i]) -> int:
	assert(from_kick_table.size() == to_kick_table.size())
	for i in range(from_kick_table.size()):
		var from_offset := from_kick_table[i]
		var to_offset := to_kick_table[i]
		if can_move_active_piece(from_offset - to_offset):
			return i
	return -1

func try_rotate_piece(dir: int) -> bool:
	var from_kick_table := active_piece.kick_table.get_kick_table(piece_rotation)
	rotate_active_piece(dir)
	var to_kick_table := active_piece.kick_table.get_kick_table(piece_rotation)
	var kick_result := test_kick_tables(from_kick_table, to_kick_table)
	if kick_result >= 0:
		var move_result := try_move_active_piece(from_kick_table[kick_result] - to_kick_table[kick_result])
		assert(move_result)
		return true
	# Undo the rotation
	rotate_active_piece(-dir)
	return false

func try_rotate_piece_left() -> bool:
	return try_rotate_piece(-1)

func try_rotate_piece_right() -> bool:
	return try_rotate_piece(1)

func rotate_piece_left() -> void:
	rotate_active_piece(-1)

func rotate_piece_right() -> void:
	rotate_active_piece(1)

func get_active_piece_cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	result.resize(active_piece.cells.size())
	for i in range(active_piece.cells.size()):
		match piece_rotation:
			PieceInfo.RotationDirection.NORTH:
				result[i] = active_piece.cells[i]
			PieceInfo.RotationDirection.EAST:
				result[i] = Vector2i(-active_piece.cells[i].y, active_piece.cells[i].x)
			PieceInfo.RotationDirection.SOUTH:
				result[i] = active_piece.cells[i] * -1
			PieceInfo.RotationDirection.WEST:
				result[i] = Vector2i(-active_piece.cells[i].y, active_piece.cells[i].x) * -1
	return result

func rotate_active_piece(offset: int) -> void:
	piece_rotation = posmod(piece_rotation + offset, PieceInfo.RotationDirection.MAX) as PieceInfo.RotationDirection
	piece_rotated.emit(piece_rotation, false)

func set_piece_rotation(new_rotation: PieceInfo.RotationDirection) -> void:
	piece_rotation = new_rotation
	piece_rotated.emit(piece_rotation, true)

func clear_lines() -> void:
	for row in range(board.size.y):
		if check_row(row):
			board.clear_row(row)
			board.fall_above_rows(row)

func check_row(row: int) -> bool:
	for x in range(board.size.x):
		if not board.is_cell_solid(Vector2i(x, row)):
			return false
	return true

func _on_piece_locked(pos: Vector2i) -> void:
	piece_entry_delay = 0.5
	# piece_entry_delay = 0.01
	piece_auto_shift_delay = 0
	piece_last_moved_direction = Vector2i.ZERO

func _on_piece_moved(new_pos: Vector2i, warp: bool) -> void:
	update_ghost_piece()

func _on_piece_rotated(new_rot: PieceInfo.RotationDirection, warp: bool) -> void:
	update_ghost_piece()

func update_ghost_piece() -> void:
	var y := 0
	while can_move_active_piece(Vector2i.DOWN * (y + 1)):
		y += 1
	ghost_piece_moved.emit(piece_position + Vector2i.DOWN * y, true)
	ghost_piece_rotated.emit(piece_rotation, true)

func get_next_piece() -> PieceInfo:
	var next_piece := piece_randomiser.get_next_piece()
	update_next_queue.emit(piece_randomiser.get_piece_queue(6))
	return next_piece
