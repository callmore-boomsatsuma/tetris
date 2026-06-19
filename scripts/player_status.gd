class_name PlayerStatus
extends Node

@export var score: int = 0
@export var level: int = 1
@export var lines: int = 0

var pieces_placed: int = 0
var b2b: int = 0

signal score_changed(score: int)
signal level_changed(level: int)
signal lines_changed(lines: int)
signal pieces_placed_changed(pieces: int)

func _on_lines_scored(p_lines: int, spin: GameManager.SpinType) -> void:
	add_lines(p_lines)
	var score_add := 0
	if p_lines > 4:
		score_add = 2 * p_lines
	else:
		match p_lines:
			4: score_add = 8
			3: score_add = 5
			2: score_add = 3
			1: score_add = 1
	if p_lines >= 4 or spin != GameManager.SpinType.None:
		b2b += 1
	else:
		b2b = 0
	
	if b2b > 1:
		score_add = floori(score_add * 1.5)
		
	add_score(score_add)

func _on_piece_placed(piece: PieceInfo) -> void:
	add_pieces_placed(piece)

func _ready():
	score_changed.emit(score)
	level_changed.emit(level)
	lines_changed.emit(lines)
	pieces_placed_changed.emit(pieces_placed)

func add_lines(amount: int) -> void:
	lines += amount
	prints("Lines:", lines)
	lines_changed.emit(lines)

	if floori(lines / 10.0) + 1 > level:
		set_level(floori(lines / 10.0) + 1)

func set_level(new_level: int) -> void:
	if level == new_level:
		return
	level = new_level
	prints("Level:", level)
	level_changed.emit(new_level)

func add_score(amount: int) -> void:
	score += amount
	prints("Score:", score)
	score_changed.emit(score)

func add_pieces_placed(_piece: PieceInfo) -> void:
	pieces_placed += 1
	pieces_placed_changed.emit(pieces_placed)
