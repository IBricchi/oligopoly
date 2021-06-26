extends RigidBody

var settings: Node

signal rolled_value(val)

func _ready():
	visible = false
	settings = get_tree().get_root().get_node("game")
	settings.connect("roll_dice", self, "_on_roll_dice")

func _physics_process(delta):
	if visible and linear_velocity == Vector3.ZERO:
		var dir: Vector3 = rotation.normalized()
		if dir == Vector3.UP:
			emit_signal("rolled_value", 1)
		elif dir == Vector3.LEFT:
			emit_signal("rolled_value", 2)
		elif dir == Vector3.RIGHT:
			emit_signal("rolled_value", 3)
		elif dir == Vector3.FORWARD:
			emit_signal("rolled_value", 4)
		elif dir == Vector3.BACK:
			emit_signal("rolled_value", 5)
		else:
			emit_signal("rolled_value", 6)
		visible = false

func _on_roll_dice():
	var s_pos: Vector3 = Vector3(rand_range(-3,3), 5, rand_range(-3,3))
	var s_dir: Vector3 = Vector3(rand_range(0,TAU),rand_range(0,TAU),rand_range(0,TAU))
	translation = s_pos
	rotation = s_dir
	visible = true
	
