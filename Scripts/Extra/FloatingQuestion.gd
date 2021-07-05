extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true
	var phi = rand_range(0,2*PI)
	translation = Vector3(10*cos(phi), 30, 10*sin(phi))
	angular_velocity = Vector3(rand_range(0,2), rand_range(10,20), rand_range(0,2))

func _process(delta):
	if translation.y < - 40:
		self.queue_free() 
