extends MarginContainer

signal roll
signal add_player(time)

var roll: Button
var add_player: Button
var add_player_val: LineEdit

func _ready():
	roll = $roll_cont/roll
	roll.connect("button_up", self, "_on_roll")
	
	add_player = $areas/right/cont/menu/list/add_cont/add
	add_player.connect("button_up", self, "_on_add_player")
	
	add_player_val = $areas/right/cont/menu/list/num_cont/num

func _on_roll():
	emit_signal("roll")

func _on_add_player():
	var time_str = add_player_val.text
	if time_str.is_valid_integer():
		var time: int = int(add_player_val.text)
	else:
		print("Invalid time for adding player!")
