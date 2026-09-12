# player.gd
extends GridEntity

func _ready() -> void:
	add_to_group("player")
	await get_tree().process_frame
	force_spawn_in_room()

func _process(delta: float) -> void:
	super(delta) # <-- WAJIB ADA: Agar fungsi gerak dasar dari GridEntity tetap aktif!

	# Tombol spawn ulang
	if Input.is_action_just_pressed("a"):
		force_spawn_in_room()

	# Cek input arah via _process
	var dir = Vector2i.ZERO
	if Input.is_action_just_pressed("ui_right"): dir = Vector2i.RIGHT
	elif Input.is_action_just_pressed("ui_left"): dir = Vector2i.LEFT
	elif Input.is_action_just_pressed("ui_down"): dir = Vector2i.DOWN
	elif Input.is_action_just_pressed("ui_up"): dir = Vector2i.UP
	
	if Input.is_action_just_pressed("y"): dir = Vector2i(-1, -1)
	if Input.is_action_just_pressed("u"): dir = Vector2i(1, -1)
	if Input.is_action_just_pressed("b"): dir = Vector2i(-1, 1)
	if Input.is_action_just_pressed("n"): dir = Vector2i(1, 1)
	
	if dir != Vector2i.ZERO and move_queue.size() < 3:
		move_queue.append(dir)
