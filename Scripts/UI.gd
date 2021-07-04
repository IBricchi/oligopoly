extends MarginContainer

signal roll
signal ti_handled
signal buy_property(idx)
signal add_player(time)
signal change_time(time)

onready var roll: Button = $"areas/right/list/roll_cont/roll"
onready var add_player: Button = $"areas/left/menu/list/add_player/add_cont/add"
onready var change_time: Button = $"areas/left/menu/list/change_time/change_cont/change"
onready var property_popup: Container = $"property_popup"

func _ready():
	roll.connect("button_up", self, "_on_roll")
	
	add_player.connect("button_up", self, "_on_add_player")
	change_time.connect("button_up", self, "_on_change_time")
	
	property_popup.connect("buy_property", self, "_on_buy_property")

func _on_roll():
	emit_signal("roll")

onready var add_player_val: LineEdit = $"areas/left/menu/list/add_player/num_cont/num"
func _on_add_player():
	var time_str = add_player_val.text
	if time_str.is_valid_integer():
		var time: int = int(time_str)
		emit_signal("add_player", time)
	else:
		print("Invalid time for adding player!")

onready var change_time_val: LineEdit = $"areas/left/menu/list/change_time/num_cont/num"
func _on_change_time():
	var time_str = change_time_val.text
	if time_str.is_valid_integer():
		var time: int = int(time_str)
		emit_signal("change_time", time)
	else:
		print("Invalid time for changing time!")

func _on_buy_property(tile_idx: int, do: bool):
	if do:
		emit_signal("buy_property", tile_idx)
	else:
		emit_signal("ti_handled")

onready var global_time: Label = $"areas/right/list/time/global/val"
func set_global_time(time: int):
	global_time.text = "Global: %d" % time
	
onready var player_time: Label = $"areas/right/list/time/player/val"
func set_player_time(time: int):
	player_time.text = "Player: %d" % time

onready var player_money: Label = $"areas/right/list/money/player/val"
func set_player_money(ammount: int):
	player_money.text = "Money: £%d" % ammount

func show_property_popup(tile_idx: int, price: int, can_buy: bool):
	property_popup.popup(tile_idx, price, can_buy)

