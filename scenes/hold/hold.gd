extends VBoxContainer

func _on_hold_updated(held_piece: PieceInfo) -> void:
    $%PieceDisplay.displayed_piece = held_piece
