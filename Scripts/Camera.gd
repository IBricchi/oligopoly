extends Camera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var angle: float
var drag_enabled: bool
var mouse_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	angle = 0
	translation = Vector3(0,10,9)
	rotation_degrees = Vector3(-45,0,0)
	


func _physics_process(delta):
	if drag_enabled:
		angle += 0.007*(mouse_pos.x-get_viewport().get_mouse_position().x)
		mouse_pos = get_viewport().get_mouse_position()
		translation = Vector3(9*sin(angle),10,9*cos(angle))
		#rotation_degrees = Vector3(-40,90*sin(angle),0)
	self.look_at(Vector3(0,0,0),Vector3(0,1,0))

	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			drag_enabled = event.pressed
			mouse_pos = get_viewport().get_mouse_position()
			
