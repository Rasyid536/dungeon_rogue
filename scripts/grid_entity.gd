# grid_entity.gd
class_name GridEntity
extends CharacterBody2D

signal finished_movement(entity) # Sinyal penanda selesai 1 langkah grid

@export var move_speed: float = 200.0
var is_moving: bool = false
var move_queue: Array[Vector2i] = []
var target_tile: Vector2i 

@onready var tilemap: TileMapLayer = $".."

func _process(delta: float) -> void:
	# --- PHASE 1: GET COMMAND FROM QUEUE ---
	if not is_moving and move_queue.size() > 0:
		var next_dir = move_queue.pop_front() 
		var next_tile = target_tile + next_dir
		
		if can_walk(next_tile):
			target_tile = next_tile 
			is_moving = true        

	# --- PHASE 2: ANIMASI YANG DIPERBAIKI ---
	if is_moving:
		var target_pos = tilemap.map_to_local(target_tile);
		global_position = global_position.move_toward(target_pos, move_speed * delta)

		# Cek langsung apakah posisinya sudah persis di tujuan
		if global_position == target_pos:
			is_moving = false          
			emit_signal("finished_movement", self) # Sinyal sekarang dijamin 100% terkirim!

func can_walk(tile_pos: Vector2i) -> bool:
	var atlas_coords = tilemap.get_cell_atlas_coords(tile_pos)
	var tile_id = tilemap.get_cell_source_id(tile_pos)
	
	if tile_id == -1 or atlas_coords == Vector2i(2, 0):
		return false 
	return true

func force_spawn_in_room(spawn_atlas_coord: Vector2i = Vector2i(0, 0)) -> void:
	await get_tree().process_frame
	if not tilemap: return
	
	var used_cells = tilemap.get_used_cells()
	for pos in used_cells:
		if tilemap.get_cell_atlas_coords(pos) == spawn_atlas_coord:
			target_tile = pos
			global_position = tilemap.map_to_local(pos)
			break
