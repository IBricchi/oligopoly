extends MarginContainer

signal roll
signal ti_handled
signal buy_property(idx)
signal confirm_chanceconfirm_chance
signal debug(t, time)

onready var roll: Button = $"areas/left/list/roll_cont/roll"
onready var property_popup: Container = $"property_popup"
onready var chance_popup: Container = $"chance_popup"

onready var d1b: Button = $"areas/right/menu/list/d1/cont/b"
onready var d2b: Button = $"areas/right/menu/list/d2/cont/b"
onready var d3b: Button = $"areas/right/menu/list/d3/cont/b"

func _ready():
	roll.connect("button_up", self, "_on_roll")
	
	d1b.connect("button_up", self, "_on_d1")
	d2b.connect("button_up", self, "_on_d2")
	d3b.connect("button_up", self, "_on_d3")
	
	property_popup.connect("buy_property", self, "_on_buy_property")
	chance_popup.connect("confirm_chance", self, "_on_confirm_chance")

func _on_roll():
	emit_signal("roll")

func _on_buy_property(tile_idx: int, do: bool):
	if do:
		emit_signal("buy_property", tile_idx)
	else:
		emit_signal("ti_handled")

func _on_confirm_chance():
	emit_signal("ti_handled")

onready var global_time: Label = $"areas/left/list/time/global/val"
func set_global_time(time: int):
	global_time.text = "Global: %d" % time
	
onready var player_time: Label = $"areas/left/list/time/player/val"
func set_player_time(time: int):
	player_time.text = "Player: %d" % time

func show_property_popup(tile_idx: int, price: int, can_buy: bool):
	property_popup.popup(tile_idx, price, can_buy)

func show_chance_popup(command: String, val: int):
	chance_popup.popup(command, val)

onready var player_data_scene: Resource = preload("res://Scenes/UI/player_data.tscn")
onready var player_data_list: Container = $"areas/left/list/mar/cont/player_data"
func update_pd(players: Array):
	for child in player_data_list.get_children():
		player_data_list.remove_child(child)
	for player in players:
		var new_player_data: Container = player_data_scene.instance()
		new_player_data.update_val(player)
		player_data_list.add_child(new_player_data)

### DEBUG HELPERS
onready var d1: LineEdit = $"areas/right/menu/list/d1/num_cont/num"
func _on_d1():
	var v = d1.text
	if v.is_valid_integer():
		var b: int = int(v)
		emit_signal("debug", 1, b)
	else:
		print("Invalid d1")

onready var d2: LineEdit = $"areas/right/menu/list/d2/num_cont/num"
func _on_d2():
	var v = d2.text
	if v.is_valid_integer():
		var b: int = int(v)
		emit_signal("debug", 2, b)
	else:
		print("Invalid d2!")

onready var d3: LineEdit = $"areas/right/menu/list/d3/num_cont/num"
func _on_d3():
	var v = d3.text
	if v.is_valid_integer():
		var b: int = int(v)
		emit_signal("debug", 3, b)
	else:
		print("Invalid d3!")
