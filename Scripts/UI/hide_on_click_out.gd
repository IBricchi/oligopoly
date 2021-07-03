extends Control

func _input(event: InputEvent):
	if (event is InputEventMouseButton) and event.pressed:
		var evLocal: InputEvent = make_input_local(event)
		if !Rect2(Vector2(0,0),rect_size).has_point(evLocal.position):
			visible = false
