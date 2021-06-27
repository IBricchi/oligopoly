extends RigidBody

var settings: Node

signal rolled_value(val)

func _ready():
	visible = false
	settings = get_tree().get_root().get_node("game")
	settings.connect("roll_dice", self, "_on_roll_dice")

func _physics_process(delta):
	if visible and linear_velocity == Vector3.ZERO:
		var rot: Vector3 = ((rotation * 180 / PI).round())
		rot.x = fposmod(rot.x,360)
		rot.y = fposmod(rot.y,360)
		rot.z = fposmod(rot.z,360)
		var val: int;
		if rot.x == 0 and rot.z == 90:
			val = 1
		elif rot.x == 270 and rot.z == 0:
			val = 2
		elif rot.x == 0 and rot.z == 180:
			val = 3
		elif rot.x == 0 and rot.z == 0:
			val = 4
		elif rot.x == 90 and rot.z == 0:
			val = 5
		else:
			val = 6
		emit_signal("rolled_value", val)
		visible = false

func _on_roll_dice():
	var s_pos: Vector3 = Vector3(rand_range(-3,3), 5, rand_range(-3,3))
	var s_dir: Vector3 = Vector3(rand_range(0,TAU),rand_range(0,TAU),rand_range(0,TAU))
	translation = s_pos
	rotation = s_dir
	visible = true
	linear_velocity = Vector3.DOWN
