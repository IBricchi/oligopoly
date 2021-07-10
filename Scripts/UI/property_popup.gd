extends MarginContainer

var tile_idx: int
var respond: bool

onready var prompt: Label = $"body/split/margin/centre/prompt"
onready var no: Button = $"body/split/options/MarginContainer/no"
onready var yes: Button = $"body/split/options/MarginContainer2/yes"

signal buy_property(idx,do)

func _ready():
	no.connect("button_up", self, "_on_no")
	yes.connect("button_up", self, "_on_yes")

func _on_no():
	emit_signal("buy_property", tile_idx, false)	
	visible = false
	
func _on_yes():
	emit_signal("buy_property", tile_idx, true and respond)
	visible = false

func popup(idx: int, price: int, can_buy: bool):
	tile_idx = idx
	respond = can_buy
	if can_buy:
		prompt.text = "Tile %d is for sale. \n Would you like to buy it for €%d ?" % [idx, price]
		no.text = "No thanks"
		no.visible = true
		yes.text = "Yes, buy"
	else:
		prompt.text = "You don't have enough money to buy this property."
		no.visible = false
		yes.text = "Unfortunate"
	visible = true
