class_name PlayerStatus
extends Node

@export var score: int = 0
@export var level: int = 1
@export var lines: int = 0

var pieces_placed: int = 0

signal score_changed(score: int)
signal level_changed(level: int)
signal lines_changed(lines: int)
signal pieces_placed_changed(pieces: int)

func _on_lines_scored(p_lines: int, _spin: GameManager.SpinType, _b2b: bool) -> void:
	add_lines(p_lines)
	if p_lines > 4:
		add_score(200 * p_lines)
	else:
		match p_lines:
			4: add_score(800)
			3: add_score(500)
			2: add_score(300)
			1: add_score(100)

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
