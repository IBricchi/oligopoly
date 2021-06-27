extends KinematicBody

var settings: Node
var anim: AnimationPlayer

var target_queue: Array;

func _ready():
	settings = get_tree().get_root().get_node("game")
	settings.connect("player_step", self, "_on_player_step")
	
	anim = $anim

export var gravity: float = 100
export var speed: float = 10
export var min_dist: float = 0.1

var first_frame: bool = true
var velocity: Vector3 = Vector3.ZERO

func _physics_process(delta):	
	if(not target_queue.empty()):
		if first_frame:
			first_frame = false
			anim.stop()
			anim.play("step")
			velocity.y = 2
			
		var target: Spatial = target_queue.front()
		var dir: Vector3 = Vector3.ZERO
		dir.x = target.translation.x - translation.x
		dir.z = target.translation.z - translation.z
		
		if abs(dir.x) < min_dist and abs(dir.z) < min_dist:
			velocity.x = 0
			velocity.z = 0
			translation.x = target.translation.x
			translation.z = target.translation.z
			
			target_queue.pop_front()
			
			first_frame = true
		else:
			dir = dir.normalized()
			velocity.x = speed * dir.x
			velocity.z = speed * dir.z
			look_at(translation + dir, Vector3.UP)
	
	velocity.y -= gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP)
	
func _on_player_step(target: Spatial):
	target_queue.push_back(target)
	
