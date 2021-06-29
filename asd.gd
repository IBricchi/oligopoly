extends Spatial

export var tile_type : int = 0
# 0 is a property tile
# 1 is a chance card
# 2 is a time travel card
# 3 is start


var owners: Dictionary = {}
# dictionry which stores owners and the turn where they initially were bought

func _ready():
	pass
	
	
func player_lands():
	if tile_type == 0:
		if owners.empty():
			pass # subtract some money from player


func player_passes():
	if tile_type == 3:
		pass # add money to player
