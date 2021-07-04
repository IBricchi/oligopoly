extends KinematicBody

onready var anim: AnimationPlayer = $anim
onready var body: Spatial = $body_cont/body

var idx: int
var time: int
var tile: int
var continuity: int
var money: int
var leaces: Array

var target_queue: Array

export var gravity: float = 5
export var speed: float = 2.5
export var min_dist: float = 0.1

var first_frame: bool = true
var velocity: Vector3 = Vector3.ZERO
var just_frame: bool = false
var has_hit_floor: bool = false

signal player_first_land(idx)
signal player_landed(idx)
signal player_vanished(idx)

func _ready():
	pass

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
				
				if target_queue.front().empty():
					target.player_lands(idx)
				else:
					target.player_passes(idx)
				
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
	
	if not has_hit_floor and is_on_floor():
		has_hit_floor = true
		emit_signal("player_first_land", idx)
	
func queue_target(target: Array):
	target_queue.push_back(target)

func step():
	time += 1
	var new_leaces: Array = []
	for leace in leaces:
		leace["ttl"] -= 1
		if leace["ttl"] > 0:
			new_leaces.push_back(leace)
		else:
			print("Player %d lost leace for tile %d" % [idx, leace["tile"]])
	leaces = new_leaces

func force_land():
	emit_signal("player_landed", idx)	

func vanish():
	emit_signal("player_vanished", idx)
