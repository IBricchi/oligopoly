extends Control

onready var prompt: Label = $"cont/title/Label"
onready var mm: Button = $"cont/options/menu/button"
onready var play: Button = $"cont/options/play/button"

func _ready():
	mm.connect("button_down", self, "_on_mm")
	play.connect("button_down", self, "_on_play")
	prompt.text = "You ran out of money in %d turns.\n This led to your immediate \n spontaneous combustion." % Global.turns_on_death

func _on_mm():
	get_tree().change_scene("res://Scenes/title_screen.tscn")

func _on_play():
	get_tree().change_scene("res://Scenes/game.tscn")
