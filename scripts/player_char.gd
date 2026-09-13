# player.gd
extends GridEntity

signal player_died()
signal clear_fog_activated() # [TAMBAHAN] Sinyal saat skill dikeluarkan

var player_hp : int
@onready var fog_tile = $"../../Fog"
var is_player_regen : int = 0
var light_charges : int = 0 # [TAMBAHAN] Menyimpan jumlah item light

func _ready() -> void:
	player_hp = 10
	add_to_group("player")
	add_to_group("entities")
	await get_tree().process_frame
	force_spawn_in_room()
	$".".combat.connect(player_combat)
	$".".turn_emitter.connect(player_regen)
	fog_tile.reveal_area(target_tile)

func _process(delta: float) -> void:
	hp_controller()
	if Input.is_action_just_pressed("q"):
		print("player_mati")
		player_hp = 0
	super(delta) # <-- WAJIB ADA: Agar fungsi gerak dasar dari GridEntity tetap aktif!

	# Tombol spawn ulang
	if Input.is_action_just_pressed("a"):
		force_spawn_in_room()

	# --- LOGIKA TILE MAP (Ambil Item & Cek Tangga) ---
	var current_atlas = tilemap.get_cell_atlas_coords(target_tile)
	
	# Cek Ambil Item Light
	if current_atlas == Vector2i(4, 0): # Pastikan ini sesuai dengan LIGHT_TILE
		tilemap.set_cell(target_tile, 0, Vector2i(0, 0)) # Ubah jadi lantai biasa
		light_charges += 1
		$"../../Control/sun".text = "u have sun"

	# --- LOGIKA PAKAI SKILL LIGHT ---
	if Input.is_action_just_pressed("f"): # Pastikan 'f' terdaftar di Input Map
		if light_charges > 0:
			light_charges -= 1
			print("Skill Clear Fog Aktif! Sisa item: ", light_charges)
			$"../../Control/sun".text = "u have lost a sun"
			$"../../Fog".clear();
			player_hp -= randi_range(1, 8);
			# Panggil fungsi clear fog di sini jika dibutuhkan
		else:
			$"../../Control/sun".text = "u has no sun"

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
	
	if fog_tile:
		fog_tile.reveal_area(target_tile)
	
	if Input.is_action_just_pressed(">"):
		# Cek apakah tile yang sedang diinjak player adalah STAIR_TILE (3, 0)
		if current_atlas == Vector2i(3, 0): 
			tilemap.next_floor() 
			force_spawn_in_room(Vector2i(0, 0)) 

func hp_controller():
	if (player_hp > 10):
		player_hp = 10
	
	if (player_hp <= 0):
		player_hp = 0
		player_died.emit()
		#player mati disini
		#bikin ui (default deactivate, terus activate disini)
		if (Input.is_action_just_pressed("enter")):
			get_tree().quit();
		queue_free()
	$"../../Control/hp text".text = "hp : " + str(player_hp)

func player_combat(do: String, entity):
	print(do)
	player_hp -= randi_range(1, 2)
	entity.damage_to_enemy()
	print("kills")

func player_regen():
	if (player_hp < 10):
		is_player_regen += 1
		if is_player_regen >= randi_range(7, 8):
			player_hp += 1
	elif player_hp == 10:
		is_player_regen = 0
