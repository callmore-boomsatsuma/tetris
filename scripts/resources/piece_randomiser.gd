@abstract
class_name PieceRandomiser
extends Resource

@abstract
func get_next_piece() -> PieceInfo

@abstract
func get_piece_queue(amount := -1) -> Array[PieceInfo]
