extends ScrollContainer

#onready var player = $"list/player"
#onready var money = $"list/money"
#onready var properties = $"list/properties"

var player
var money
var properties

func _ready():
	pass

const lease_label: Resource = preload("res://Scenes/UI/lease_label.tscn")

func update_val(p):
	player = $"list/player"
	player.text = "%d" % p.idx
	money = $"list/money"
	money.text = "%d" % p.money
	properties = $"list/properties"
	for child in properties.get_children():
		properties.remove_child(child)
	for prop in p.leases:
		var new_label = lease_label.instance()
		new_label.text = "%d" % prop.get("tile")
		properties.add_child(new_label)
