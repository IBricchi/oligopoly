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

var buy_cost: int = 100
var rent_cost: int = 200

func _ready():
	idx = int(name)
	$"body/model".get_child(tile_type).visible = true

signal queue_property_action(player_idx, idx)
signal queue_time_travel
signal add_money(idx, ammount)

func player_lands(player_idx: int):
	match tile_type:
		tt.property:
			emit_signal("queue_property_action", player_idx, idx)
		tt.chance:
			get_node("/root/game").drop_question_marks()
			print("chance not yet implemented")
		tt.time_warp:
			$"/root/game".players[player_idx].emit_particles()
			if player_idx == 0:
				emit_signal("queue_time_travel")
		tt.start:
			emit_signal("add_money", player_idx, 200)

func player_passes(player_idx: int):
	match tile_type:
		tt.start:
			emit_signal("add_money", player_idx, 200)
		_:
			pass # only matters for start

### if the tile is clicked
func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed: 
			print("heewoo")
