extends Control

var play: TextureButton
var settings: TextureButton

func _ready():
	play = $menu/play/button
	play.connect("button_down", self, "_on_button_down")

	settings = $menu/settings/button

func _on_button_down():
	get_tree().change_scene("res://Scenes/game.tscn")
