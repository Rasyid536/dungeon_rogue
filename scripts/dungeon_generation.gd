extends TileMapLayer

var room_count = 10;
var min_size = 5;
var max_size = 10;

var astar = AStarGrid2D.new()

var screen_resolution = Vector2(1152, 648);
var tile_size = 16;

var grid_width = int(screen_resolution.x / tile_size);
var grid_height = int(screen_resolution.y / tile_size);

var FLOOR_TILE = Vector2i(0, 0)
var PATH_TILE = Vector2i(1, 0)
var WALL_TILE = Vector2i(2, 0)

func _ready() -> void: 
	randomize();
	make_dungeon();

func _process(delta: float):
	if Input.is_action_just_pressed("a"):
		clear()
		make_dungeon()

func make_dungeon() -> void:
	var room_list = [];
	var room_has_made = 0;
	var max_room_create_attempt = 300;
	var room_create_attempt = 0;

	while room_has_made < randi_range(5, 8) and room_create_attempt < max_room_create_attempt:
		room_create_attempt += 1;

		var width = randi_range(min_size, max_size);
		var height = randi_range(min_size, max_size);

		var x = randi_range(2, grid_width - width - 2);
		var y = randi_range(2, grid_height - height - 2);

		var new_room = Rect2i(x - 1, y - 1, width + 2, height + 2);
		var overlap = false;
		for old_room in room_list:
			if new_room.intersects(old_room):
				overlap = true;
				break;
		if overlap:
			continue;

		var created_room = Rect2i(x, y, width, height);
		room_list.append(created_room);
		room_has_made += 1;

		for cols in range(-1, width + 1) :
			for rows in range(-1, height + 1):
				place_tile(Vector2i(x + cols, y + rows), WALL_TILE);

		for cols in range(width) :
			for rows in range(height):
				place_tile(Vector2i(x + cols, y + rows), FLOOR_TILE);

	# --- SETUP A* UNTUK KORIDOR ---
	astar = AStarGrid2D.new()
	astar.region = Rect2i(0, 0, grid_width, grid_height)
	astar.cell_size = Vector2(tile_size, tile_size)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER 
	astar.update()

	# Set bobot awal untuk membuat koridor
	for x in range (grid_width):
		for y in range(grid_height):
			var pos = Vector2i(x, y)
			var this_atlas = get_cell_atlas_coords(pos)
			
			if this_atlas == WALL_TILE:
				astar.set_point_weight_scale(pos, 100.0)
			else:
				astar.set_point_weight_scale(pos, 1.0)

	# Membuat koridor antar ruangan
	for i in range(room_list.size() - 1):
		var center_now = Vector2i(
			room_list[i].position.x + (room_list[i].size.x / 2),
			room_list[i].position.y + (room_list[i].size.y / 2)
		)
		var center_next = Vector2i(
			room_list[i+1].position.x + (room_list[i+1].size.x / 2),
			room_list[i+1].position.y + (room_list[i+1].size.y / 2)
		)
		
		var smart_path = astar.get_id_path(center_now, center_next);
	
		for pos in smart_path:
			var at_this_atlas = get_cell_atlas_coords(pos)
			var tile_id = get_cell_source_id(pos)
			
			if at_this_atlas == FLOOR_TILE:
				continue 
			elif tile_id == -1 or at_this_atlas == WALL_TILE:
				place_tile(pos, PATH_TILE)

	# --- RE-SETUP A* FINAL UNTUK MUSUH SETELAH KORIDOR JADI ---
	# Di sini kita tandai tembok sebagai SOLID (tidak bisa dilewati musuh)
	# dan lantai/path sebagai area yang bisa dilewati.
	astar.clear()
	astar.region = Rect2i(0, 0, grid_width, grid_height)
	astar.cell_size = Vector2(tile_size, tile_size)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

	for x in range(grid_width):
		for y in range(grid_height):
			var pos = Vector2i(x, y)
			var tile_id = get_cell_source_id(pos)
			var atlas_coords = get_cell_atlas_coords(pos)
			
			# Jika kosong atau tembok, set solid (musuh tidak bisa lewat)
			if tile_id == -1 or atlas_coords == WALL_TILE:
				astar.set_point_solid(pos, true)
			else:
				astar.set_point_solid(pos, false)

func place_tile(pos: Vector2i, tile_type: Vector2i):
	if pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height:
		set_cell(pos, 0, tile_type)
