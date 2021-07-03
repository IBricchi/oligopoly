extends Button

onready var menu: Container = $"../../menu"

func _ready():
	connect("button_up", self, "_on_button_up")

func _on_button_up():
	menu.visible = true
