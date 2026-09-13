extends TileMapLayer

@export var reveal_radius: int = 1

var fog_tile := Vector2i(0, 0)

var grid_width: int = 72
var grid_height: int = 40


func _ready() -> void:
	fill_fog()


func fill_fog() -> void:
	clear()

	for x in range(grid_width):
		for y in range(grid_height):
			var pos := Vector2i(x, y)

			set_cell(
				pos,
				0,
				fog_tile
			)


func reveal_area(center: Vector2i) -> void:
	for x in range(
		center.x - reveal_radius,
		center.x + reveal_radius + 1
	):
		for y in range(
			center.y - reveal_radius,
			center.y + reveal_radius + 1
		):
			var pos := Vector2i(x, y)

			if pos.x < 0 or pos.x >= grid_width:
				continue

			if pos.y < 0 or pos.y >= grid_height:
				continue

			erase_cell(pos)

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("i")):
		clear();
