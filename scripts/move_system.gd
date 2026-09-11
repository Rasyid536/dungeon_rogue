extends CharacterBody2D

# ==============================================================================
# --- VARIABLES (Can be set in Inspector) ---
# ==============================================================================
@export var tile_size: int = 16    # Size of 1 box/tile in pixels (e.g. 16x16)
@export var move_speed: float = 80.0 # Movement speed animation between tiles

# ==============================================================================
# --- STATUS & QUEUE VARIABLES ---
# ==============================================================================
var is_moving: bool = false         # Marks if player is MOVING between tiles
var move_queue: Array[Vector2i] = [] # "Queue": Stores the sequence of button presses you press
# Target grid coordinates (X, Y) that the player is currently heading to
var target_tile: Vector2i 
# Reference to the adjacent TileMapLayer node
@onready var tilemap: TileMapLayer = $".."

# ==============================================================================
# --- INITIALIZATION FUNCTION (Called when game starts) ---
# ==============================================================================
func _ready() -> void:
	# Wait 1 frame so TileMap finishes generating the dungeon
	await get_tree().process_frame
	
	# Move player to the initial room
	spawn_di_ruangan()

func spawn_di_ruangan() -> void:
	# Get list of all tile positions drawn on the map
	var used_cells = tilemap.get_used_cells()
	
	# Find one by one until finding the tile that is TILE_FLOOR (0, 0)
	for pos in used_cells:
		if tilemap.get_cell_atlas_coords(pos) == Vector2i(0, 0):
			target_tile = pos # Set initial target grid coordinates
			
			# Convert grid coordinates (e.g. 5, 8) to actual pixel position on screen
			global_position = tilemap.map_to_local(pos)
			break # Stop searching after spawn position is found

# ==============================================================================
# Get input from keyboard
# ==============================================================================
func _unhandled_input(event: InputEvent) -> void:
	var dir = Vector2i.ZERO # Holds the pressed direction (default: zero)
	
	# Detect which direction key the player pressed
	if event.is_action_pressed("ui_right"):
		dir = Vector2i.RIGHT # Vector2i(1, 0) -> Right
	elif event.is_action_pressed("ui_left"):
		dir = Vector2i.LEFT  # Vector2i(-1, 0) -> Left
	elif event.is_action_pressed("ui_down"):
		dir = Vector2i.DOWN  # Vector2i(0, 1) -> Down
	elif event.is_action_pressed("ui_up"):
		dir = Vector2i.UP    # Vector2i(0, -1) -> Up

	# If a direction button is pressed AND the queue is not full (max 3 inputs)
	if dir != Vector2i.ZERO and move_queue.size() < 3:
		move_queue.append(dir) # Add movement command to the back of the queue

# ==============================================================================
# Main game loop running every frame
# ==============================================================================
func _process(delta: float) -> void:
	# --- PHASE 1: GET COMMAND FROM QUEUE ---
	# If player is NOT moving AND there are commands in the queue
	if not is_moving and move_queue.size() > 0:
		# Get the first command from the queue (FIFO: First-In, First-Out)
		var next_dir = move_queue.pop_front() 
		
		# Calculate new tile location (current location + movement direction)
		var next_tile = target_tile + next_dir
		
		# Check if destination tile is safe to step on (not wall/empty)
		if can_walk(next_tile):
			target_tile = next_tile # Set new target
			is_moving = true        # Change status to MOVING

	# Phase 2: Smooth sliding (lerp) animation
	# If player is MOVING:
	if is_moving:
		# Get real pixel position on screen from target tile
		var target_pos = tilemap.map_to_local(target_tile)
		
		# Smooth sliding (lerp) from old position to target_pos
		global_position = global_position.lerp(target_pos, move_speed * delta)
		
		# If distance between player and target point is very close (less than 0.5 pixels)
		if global_position.distance_to(target_pos) < 0.5:
			global_position = target_pos # Lock position exactly in the middle of the tile
			is_moving = false            # Change status back to IDLE

# ==============================================================================
# Check for obstacles (walls / empty areas)
# ==============================================================================
func can_walk(tile_pos: Vector2i) -> bool:
	# Get tile ID and atlas coordinates at the target position
	var atlas_coords = tilemap.get_cell_atlas_coords(tile_pos)
	var tile_id = tilemap.get_cell_source_id(tile_pos)
	
	# If ID == -1, it means area is outside dungeon / empty tile (NOT WALKABLE)
	if tile_id == -1:
		return false
		
	# If the tile image is TILE_WALL at coordinate Vector2i(2, 0) in TileSet
	if atlas_coords == Vector2i(2, 0):
		return false # NOT WALKABLE
		
	# Tile is blocking / not walkable
	return true
