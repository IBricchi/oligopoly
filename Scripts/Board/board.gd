extends Node

var settings: Node

var tile_count: int

func _ready():
	settings = get_tree().get_root().get_node("game")
	settings.connect("request_board_tiles", self, "_on_request_board_tiles")

	tile_count = get_child_count()

var request_recieved = false
func _on_request_board_tiles(tiles):
	if !request_recieved:
		request_recieved = true
		tiles.clear()
		for i in range(tile_count):
			tiles.append(get_node("tiles/%d" % i))
