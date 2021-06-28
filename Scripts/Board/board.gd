extends Node

var tile_count: int
var tiles: Array

func _ready():
	tile_count = $tiles.get_child_count()
	for i in range(tile_count):
		tiles.append(get_node("tiles/%d" % i))

func request_board_tiles() -> Array:
	return tiles
