@tool
extends Panel

@export var displayed_piece: PieceInfo:
	set(value):
		$%PieceVisual.piece = value
	get:
		return $%PieceVisual.piece
