class_name BagRandomiser
extends PieceRandomiser

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
@export var rng_seed: int:
	get:
		return _rng.seed if _rng != null else -1
	set(value):
		_rng.seed = value
		_init_randomiser()
		emit_changed()

@export var pieces: Array[PieceInfo]:
	set(value):
		pieces = value
		emit_changed()

@export var queue_size := 10:
	set(value):
		queue_size = value
		if not pieces.is_empty():
			_ensure_queue(value)
		emit_changed()

var _piece_index := 0
var _bag: Array[PieceInfo] = []
var _queue: Array[PieceInfo] = []

func _init(p_rng_seed = null, p_pieces: Array[PieceInfo] = [], p_queue_size = 10) -> void:
	if p_rng_seed != null:
		rng_seed = p_rng_seed
	else:
		_rng.randomize()
	pieces = p_pieces
	queue_size = p_queue_size

func _init_randomiser() -> void:
	_piece_index = 0
	if not pieces.is_empty():
		_ensure_queue(queue_size)

func _append_piece_to_queue() -> void:
	if _bag.is_empty():
		_refill_bag()
	var piece := _bag.pop_at(_rng.randi_range(0, _bag.size() - 1)) as PieceInfo
	_queue.append(piece)

func _refill_bag() -> void:
	assert(not pieces.is_empty())
	_bag.clear()
	_bag.append_array(pieces)

func _ensure_queue(size := -1) -> void:
	if size < 0:
		size = queue_size
	while _queue.size() < size:
		_append_piece_to_queue()

func get_next_piece() -> PieceInfo:
	_ensure_queue(queue_size + 1)
	var piece := _queue.pop_front() as PieceInfo
	assert(piece != null)
	return piece

func get_piece_queue(amount := -1) -> Array[PieceInfo]:
	if amount < 0:
		return _queue.duplicate()
	else:
		# Ensure the queue has that many pieces, and return a duplicate of them
		_ensure_queue(amount)
		return _queue.slice(0, amount)
