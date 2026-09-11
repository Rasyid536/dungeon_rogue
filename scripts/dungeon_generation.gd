extends TileMapLayer

var room_count = 10;
var min_size = 5;
var max_size = 10;

var screen_resolution = Vector2(1152, 648);
var tile_size;

var grid_width = int(screen_resolution.x / tile_size);
var grid_height = int(screen_resolution.y / tile_size);

var FLOOR_TILE = Vector2i(0, 0)
var PATH_TILE= Vector2i(0, 0)
var  WALL_TILE = Vector2i(0, 0)

func _ready() : 
	randomize();
	make_dungeon();


