extends MarginContainer

var tile_idx: int

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
	emit_signal("buy_property", tile_idx, true)
	visible = false

func popup(idx: int):
	tile_idx = idx
	visible = true
