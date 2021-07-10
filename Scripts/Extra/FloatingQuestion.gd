extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true
	var phi = rand_range(0,2*PI)
	translation = Vector3(rand_range(10,14)*cos(phi), rand_range(7,12), rand_range(10,14)*sin(phi))
	angular_velocity = Vector3(rand_range(0,2), rand_range(10,20), rand_range(0,2))
	$Timer.start()
	
	# sadly the mesh is fucked
	#var material = $"question/MeshInstance".get_surface_material(0).duplicate()
	#material.albedo_color = Color(rand_range(0,200)/200, rand_range(0,200)/200, rand_range(0,200)/200)
	#$question.set_surface_material(0, material)



func _on_Timer_timeout():
	self.queue_free()
