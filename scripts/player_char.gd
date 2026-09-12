# player.gd
extends GridEntity

@onready var fog: TileMapLayer = $"../../fog"


func _ready() -> void:
	add_to_group("player")

	await get_tree().process_frame

	force_spawn_in_room()

	await get_tree().process_frame

	# Buka fog di posisi awal player
	if fog:
		fog.reveal_area(target_tile)

	# Hubungkan signal selesai bergerak
	finished_movement.connect(_on_finished_movement)


func _process(delta: float) -> void:
	super(delta)

	# Tombol spawn ulang
	if Input.is_action_just_pressed("a"):
		force_spawn_in_room()

		if fog:
			fog.reveal_area(target_tile)

	# Input arah
	var dir = Vector2i.ZERO

	if Input.is_action_just_pressed("ui_right"):
		dir = Vector2i.RIGHT
	elif Input.is_action_just_pressed("ui_left"):
		dir = Vector2i.LEFT
	elif Input.is_action_just_pressed("ui_down"):
		dir = Vector2i.DOWN
	elif Input.is_action_just_pressed("ui_up"):
		dir = Vector2i.UP

	# Diagonal
	if Input.is_action_just_pressed("y"):
		dir = Vector2i(-1, -1)

	if Input.is_action_just_pressed("u"):
		dir = Vector2i(1, -1)

	if Input.is_action_just_pressed("b"):
		dir = Vector2i(-1, 1)

	if Input.is_action_just_pressed("n"):
		dir = Vector2i(1, 1)

	if dir != Vector2i.ZERO and move_queue.size() < 3:
		move_queue.append(dir)


func _on_finished_movement(entity) -> void:
	if fog:
		fog.reveal_area(target_tile)
