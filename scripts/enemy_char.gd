# enemy.gd
extends GridEntity

@export var view_radius: float = 6.0 # Jarak pandang musuh

var player: Node2D
var astar_ref: AStarGrid2D
var difficulty : int;

func _ready() -> void:
	difficulty = 3
	add_to_group("entities");
	add_to_group("enemies");
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	# Ambil referensi A* dari TileMap induk
	if tilemap and "astar" in tilemap:
		astar_ref = tilemap.astar

	# Sambungkan sinyal agar musuh bergerak HANYA saat player selesai melangkah
	if player and player.has_signal("finished_movement"):
		player.finished_movement.connect(_on_player_moved)

func _process(delta: float) -> void:
	super(delta) # Wajib dipanggil agar fungsi gerak GridEntity tetap berjalan
	
	# Atur apakah musuh terlihat atau menghilang
	if player:
		var distance = Vector2(target_tile).distance_to(Vector2(player.target_tile))
		if distance <= view_radius:
			visible = true
		else:
			visible = false

func _on_player_moved(_entity) -> void:
	if not player or not astar_ref:
		return
		
	# Cek jarak. Jika di luar radius, musuh diam (skip giliran)
	var distance = Vector2(target_tile).distance_to(Vector2(player.target_tile))
	if distance > view_radius:
		return
		
	# Minta jalur A* dari posisi musuh ke posisi player
	var path = astar_ref.get_id_path(target_tile, player.target_tile)
  
	# Jika jalur valid, ambil langkah pertama terdekat
	if path.size() > 1:
		var next_step: Vector2i = path[1]
		var direction = next_step - target_tile
		
		# Bersihkan antrean lama (cegah macet) lalu masukkan arah baru
		move_queue.clear()
		move_queue.append(direction)

func damage_to_enemy():
	if (randi_range(1, difficulty) == 3):
		$"../../Control/combat".text = "player wins"
		queue_free();
