extends AnimationPlayer

func _ready():
	var play_offset: float = rand_range(0,4)
	play("idle")
	advance(play_offset)
	pass
