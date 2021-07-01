extends Spatial

export var tile_type : int = 0
# 0 is a property tile
# 1 is a chance card
# 2 is a time travel card
# 3 is start


var owners: Dictionary = {}
# dictionary which stores owners and the turn where they initially were bought

func _ready():
	pass
	
	
func player_lands():
	if tile_type == 0:
		if owners.empty():
			get_tree().get_root().get_node("game/PropertyPopup").on_landed_on_available_property()


func player_passes():
	if tile_type == 3:
		pass # add money to player
