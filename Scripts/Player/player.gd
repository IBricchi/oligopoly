extends KinematicBody

onready var anim: AnimationPlayer = $anim
onready var body: Spatial = $body_cont/body
onready var smoke_particles: Node = $body_cont/body/ParticleBody/Smoke
onready var spark_particles: Node = $body_cont/body/ParticleBody/Spark
onready var fire_particles: Node = $body_cont/body/ParticleBody/Flame
onready var green_money_particles: Node = $body_cont/body/ParticleBody/Euros_pos
onready var red_money_particles: Node = $body_cont/body/ParticleBody/Euros_neg
onready var fire_light: Node = $OmniLight
onready var player_mesh: Node = $body_cont/body/player
onready var vanish_noise: Node = $AudioStreamPlayer
onready var death_noise: Node = $AudioStreamPlayer2
onready var audio_player_lands: Node = $AudioStreamPlayer3D

onready var particletimer : Node = $Timer
onready var deathtimer : Node = $Timer2

var idx: int
var time: int
var tile: int
var continuity: int
var money: int
var leases: Array

var target_queue: Array

export var gravity: float = 5
export var speed: float = 2.5
export var min_dist: float = 0.1

var first_frame: bool = true
var velocity: Vector3 = Vector3.ZERO
var just_frame: bool = false
var has_hit_floor: bool = false
var allow_passes: bool = true
var check_instr: bool = true

signal player_first_land(idx)
signal player_landed(idx)
signal player_vanished(idx, check_instr)
signal player_died(idx)
signal lease_lost

func _ready():
	player_mesh.visible = true
	vanish_noise.play()
	
	smoke_particles.one_shot = true
	spark_particles.one_shot = true
	fire_particles.one_shot = true
	
	fire_particles.emitting = false
	fire_light.visible = false
	
	smoke_particles.emitting = true
	spark_particles.emitting = true
	
	red_money_particles.emitting = false
	green_money_particles.emitting = false
	
func _physics_process(delta):	
	if not target_queue.empty():
		if not target_queue.front().empty():
			just_frame = true
			if first_frame:
				first_frame = false
				anim.stop()
				anim.play("step")	
				audio_player_lands.play()
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
				elif allow_passes:
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
			audio_player_lands.play()
			emit_signal("player_landed", idx)
	
	velocity.y -= gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP)
	
	if not has_hit_floor and is_on_floor():
		has_hit_floor = true
		emit_signal("player_first_land", idx)
	
func queue_target(target: Array, in_allow_passes: bool = true):
	target_queue.push_back(target)
	allow_passes = in_allow_passes

func step():
	time += 1
	var new_leases: Array = []
	for lease in leases:
		lease["ttl"] -= 1
		if lease["ttl"] > 0:
			new_leases.push_back(lease)
		else:
			print("Player %d lost lease for tile %d" % [idx, lease["tile"]])
	if leases.size() != new_leases.size():
		emit_signal("lease_lost")
	leases = new_leases

func force_land():
	emit_signal("player_landed", idx)

func vanish(in_check_instr: bool = true):
	player_mesh.visible = false
	smoke_particles.emitting = true
	spark_particles.emitting = true
	vanish_noise.play()
	particletimer.set_wait_time(2)
	particletimer.start()
	check_instr = in_check_instr

func time_travel_player():
	vanish_noise.play()
	smoke_particles.emitting = true
	spark_particles.emitting = true
	

func kill():
	player_mesh.visible = false
	death_noise.play()
	smoke_particles.gravity.y = 1
	smoke_particles.emitting = true
	fire_particles.emitting = true
	fire_light.visible = true
	deathtimer.set_wait_time(2)
	deathtimer.start()
	
func _on_Timer_timeout(): ## particletimer
	emit_signal("player_vanished", idx, check_instr)
	

func _on_Timer2_timeout(): ### deathtimer
  emit_signal("player_died", idx)

func switch_color():
	player_mesh.switch_color()

func money_particles(val : int):
	if val < 0 : 
		red_money_particles.amount = int(val/20)
		red_money_particles.emitting = true
	else:
		green_money_particles.amount = int(val/20)
		green_money_particles.emitting = true
