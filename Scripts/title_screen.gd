extends Control

onready var play: TextureButton = $"cont/options/play/button"
onready var settings: TextureButton = $"cont/options/settings/button"

func _ready():
	play.connect("button_down", self, "_on_button_down")

func _on_button_down():
	get_tree().change_scene("res://Scenes/game.tscn")
