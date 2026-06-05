@tool
extends Panel

@export var displayed_piece: PieceInfo:
	set(value):
		if not is_node_ready():
			return
		$%PieceVisual.piece = value
	get:
		if not is_node_ready():
			return
		return $%PieceVisual.piece 
