extends Container

onready var toggle: Button = $"../cont/expand"

func _ready():
	toggle.connect("button_down", self, "_on_button_down")

func _on_button_down():
	visible = true

func _input(event: InputEvent):
	if (event is InputEventMouseButton) and event.pressed:
		var evLocal: InputEvent = make_input_local(event)
		if !Rect2(Vector2(0,0),rect_size).has_point(evLocal.position):
			visible = false
