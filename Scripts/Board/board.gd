tool
extends Node

var tile_count: int
var tiles: Array

func _ready():
	tile_count = $tiles.get_child_count()
	for i in range(tile_count):
		var tile = get_node("tiles/%d" % i)
		tiles.append(tile)
		tile.get_node("body/number/cont/val").text = "%d" % i
		

func request_board_tiles() -> Array:
	return tiles
