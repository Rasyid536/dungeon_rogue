# enemy.gd
extends GridEntity

@export var view_radius: float = 6.0 

var player: Node2D
var astar_ref: AStarGrid2D
var difficulty : int = 3

@onready var tile_ref = "res://scripts/enemy_char.gd";

func _ready() -> void:
	add_to_group("entities")
	add_to_group("enemies")
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	if tilemap and "astar" in tilemap:
		astar_ref = tilemap.astar

	if player and player.has_signal("finished_movement"):
		player.finished_movement.connect(_on_player_moved)
	$"../../TileMapLayer/Player".change_floor.connect(increase_diff)

func _process(delta: float) -> void:
	super(delta) 
	
	if player:
		var distance = Vector2(target_tile).distance_to(Vector2(player.target_tile))
		if distance <= view_radius:
			visible = true
		else:
			visible = false

func _on_player_moved(_entity) -> void:
	if not player or not astar_ref:
		return
		
	var distance = Vector2(target_tile).distance_to(Vector2(player.target_tile))
	if distance > view_radius:
		return
		
	var path = astar_ref.get_id_path(target_tile, player.target_tile)
  
	if path.size() > 1:
		var next_step: Vector2i = path[1]
		var direction = next_step - target_tile
		
		move_queue.clear()
		move_queue.append(direction)

func damage_to_enemy():
	if (randi_range(1, difficulty) == 1):
		$"../../Control/combat".text = "player wins"
		queue_free()

func increase_diff(dlevel):
	difficulty = tilemap.dlevel * 2;
	print ("dlevel : ", dlevel);
	print("diff : ", difficulty);
