extends KinematicBody

var settings: Node
var anim: AnimationPlayer

var target: Spatial;

func _ready():
	settings = get_tree().get_root().get_node("game")
	settings.connect("player_step", self, "_on_player_step")
	
	anim = $anim

export var gravity: float = 100
export var speed: float = 10
export var min_dist: float = 0.1

var is_at_target: bool = true
var velocity: Vector3 = Vector3.ZERO

func _physics_process(delta):	
	if(!is_at_target):
		var dir: Vector3 = Vector3.ZERO
		dir.x = target.translation.x - translation.x
		dir.z = target.translation.z - translation.z
		if abs(dir.x) < min_dist and abs(dir.z) < min_dist:
			is_at_target = true
			velocity.x = 0
			velocity.z = 0
			translation.x = target.translation.x
			translation.z = target.translation.z
		else:
			dir = dir.normalized()
			look_at(translation + dir, Vector3.UP)
			velocity.x = speed * dir.x
			velocity.z = speed * dir.z
	
	velocity.y -= gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP)
	
func _on_player_step(in_target: Spatial):
	target = in_target
	is_at_target = false
	velocity.y += 2
	anim.play("step")
	
