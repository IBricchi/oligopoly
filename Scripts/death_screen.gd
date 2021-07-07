extends Control

onready var play: Button = $"cont/cont/options/play/button"
onready var mm: Button = $"cont/cont/options/menu/button"

func _ready():
	mm.connect("button_down", self, "_on_mm")
	play.connect("button_down", self, "_on_play")

func _on_mm():
	get_tree().change_scene("res://Scenes/title_screen.tscn")

func _on_play():
	get_tree().change_scene("res://Scenes/game.tscn")
