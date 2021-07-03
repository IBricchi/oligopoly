extends Spatial

var idx: int
export var tile_type : int = 0
# 0 is a property tile
# 1 is a chance card
# 2 is a time travel card
# 3 is start

var owners: Dictionary = {}
# dictionary which stores owners and the turn where they initially were bought

func _ready():
	idx = int(name)
	pass
	
signal buy_property_popup(idx)
func player_lands(player_idx: int):
	match tile_type:
		0:
			if owners.empty():
				if player_idx == 0: # if main player
					emit_signal("buy_property_popup", idx)
		_:
			print("Unkown or unimplemented tile type")

func player_passes(player_idx: int):
	match tile_type:
		_:
			print("Unkown or unimplemented tile type")
