extends Button

onready var menu: Container = $"../../../Instructions"

func _ready():
	connect("button_up", self, "_on_button_up")

func _on_button_up():
	menu.visible = true
