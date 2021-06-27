extends Node

var board: Spatial

var tiles_set: bool = false
var current_tile: int
var board_tiles: Array

var player: KinematicBody

var player_set: bool = false
var player_scene: Resource = preload("res://Scenes/Player/player.tscn")

var dice: RigidBody

var global_time: int = 0
var memory: Dictionary = {}

signal player_step(target)
signal request_board_tiles(tiles)
signal roll_dice

func _ready():
	board = $board
	
	dice = $dice
	dice.connect("rolled_value", self, "_on_rolled_value")
	dice.connect("player_landed", self, "_on_player_landed")

var can_roll: bool = false
func _process(delta):
	if !tiles_set:
		tiles_set = true
		emit_signal("request_board_tiles", board_tiles)
	
	if !player_set and !board_tiles.empty():
		player_set = true
		can_roll = true
		player = player_scene.instance()
		player.translation = board_tiles.front().translation + Vector3.UP * 3
		player.scale *= 0.4
		var rand_offset: Vector3 = Vector3(rand_range(-1,1),0,rand_range(-1,1))
		player.get_node("body_cont").translation = rand_offset
		player.get_node("CollisionShape").translation = rand_offset
		add_child(player)
	
	if can_roll and Input.is_action_just_pressed("lc"):
		can_roll = false
		emit_signal("roll_dice")

func _on_rolled_value(val: int):
	can_roll = true
	global_time += 1
	var target: int = (current_tile + val)%board_tiles.size()
	while current_tile != target:
		current_tile = (current_tile + 1) % board_tiles.size()
		emit_signal("player_step", board_tiles[current_tile])

func _on_player_landed(player_time: int):
	memory[global_time] = {
		"player_time": player_time,
		"position": current_tile
	}
