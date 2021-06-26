extends RigidBody

var settings: Node

func _ready():
	settings = get_tree().get_root().get_node("game")
	settings.connect("player_step", self, "_on_player_step")
	
func _on_player_step():
	print("test")
	play("step")
