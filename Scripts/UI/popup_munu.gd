extends PopupPanel

var toggle: Button

func _ready():
	(true)
	toggle = get_parent().get_node("expand")
	toggle.connect("button_down", self, "_on_button_down")

func _on_button_down():
	popup()
