extends MarginContainer

signal roll
signal add_player(time)

onready var roll: Button = $areas/right/list/roll_cont/roll
onready var add_player: Button = $"areas/left/menu/list/add_cont/add"
onready var add_player_val: LineEdit = $"areas/left/menu/list/num_cont/num"

func _ready():
	roll.connect("button_up", self, "_on_roll")
	
	add_player.connect("button_up", self, "_on_add_player")

func _on_roll():
	emit_signal("roll")

func _on_add_player():
	var time_str = add_player_val.text
	if time_str.is_valid_integer():
		var time: int = int(add_player_val.text)
		emit_signal("add_player", time)
	else:
		print("Invalid time for adding player!")
