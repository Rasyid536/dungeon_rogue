# enemy.gd
extends GridEntity

var player: Node2D
var astar_ref: AStarGrid2D

func _ready() -> void:
	await get_tree().process_frame
	force_spawn_in_room(Vector2i(1, 0)) # Ganti koordinat atlas tile spawn musuh jika ada
	
	player = get_tree().get_first_node_in_group("player")
	
	# Ambil referensi A* dari TileMap induk
	if tilemap and "astar" in tilemap:
		astar_ref = tilemap.astar

	# Sambungkan sinyal agar musuh bergerak HANYA saat player selesai melangkah
	if player and player.has_signal("finished_movement"):
		player.finished_movement.connect(_on_player_moved)

func _on_player_moved(_entity) -> void:
	if not player or not astar_ref:
		return
		
	# Minta jalur A* dari posisi musuh ke posisi player
	var path = astar_ref.get_id_path(target_tile, player.target_tile)
  
	# Jika jalur valid, ambil langkah pertama terdekat
	if path.size() > 1:
		var next_step: Vector2i = path[1]
		var direction = next_step - target_tile
		
		if move_queue.size() == 0:
			move_queue.append(direction)
