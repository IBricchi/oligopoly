extends AcceptDialog


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_button("Hell yeah I'll buy it.")
	get_ok().text = "Fuck no."

func on_landed_on_available_property():
	popup_centered_ratio(0.35)
	
