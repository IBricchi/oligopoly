tool
extends Spatial

var idx: int

# enum for tyle types
# 0 is a property tile
# 1 is a chance card
# 2 is a time travel card
# 3 is start
enum tt {
	property,
	chance,
	time_warp
	start,
}
export (tt) var tile_type : int = 0 setget set_tile_type
func set_tile_type(new_val):
	tile_type = new_val
	var target_child = $"body/model".get_child(tile_type)
	for child in $"body/model".get_children():
		if child == target_child:
			child.visible = true
		else:
			child.visible = false

var owners: Dictionary = {}
# dictionary which stores owners and the turn where they initially were bought

func _ready():
	idx = int(name)
	$"body/model".get_child(tile_type).visible = true

signal queue_property_prompt(idx)
func player_lands(player_idx: int):
	match tile_type:
		tt.property:
			if owners.empty():
				if player_idx == 0: # if main player
					emit_signal("queue_property_prompt", idx)
		_:
			print("Land: Unimplemented tile type")

func player_passes(player_idx: int):
	match tile_type:
		_:
			print("Pass: Unimplemented tile type")
