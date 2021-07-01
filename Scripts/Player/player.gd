extends KinematicBody

onready var anim: AnimationPlayer = $anim
onready var body: Spatial = $body_cont/body

var idx: int
var time: int
var tile: int

var target_queue: Array

func _ready():
	pass	

export var gravity: float = 5
export var speed: float = 2.5
export var min_dist: float = 0.1

var first_frame: bool = true
var velocity: Vector3 = Vector3.ZERO
var just_frame: bool = false

signal player_landed(idx)

func _physics_process(delta):	
	if not target_queue.empty():
		if not target_queue.front().empty():
			just_frame = true
			if first_frame:
				first_frame = false
				anim.stop()
				anim.play("step")
				velocity.y = 2
				
			var target: Spatial = target_queue.front().front()
			var dir: Vector3 = Vector3.ZERO
			dir.x = target.translation.x - translation.x
			dir.z = target.translation.z - translation.z
			
			if abs(dir.x) < min_dist and abs(dir.z) < min_dist:
				velocity.x = 0
				velocity.z = 0
				translation.x = target.translation.x
				translation.z = target.translation.z
				
				target_queue.front().pop_front()
				
				first_frame = true
			else:
				dir = dir.normalized()
				velocity.x = speed * dir.x
				velocity.z = speed * dir.z
				body.look_at(translation + dir, Vector3.UP)
		else:
			just_frame = false
			target_queue.pop_front()
			emit_signal("player_landed", idx)
	
	velocity.y -= gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP)
	
func queue_target(target: Array):
	target_queue.push_back(target)
