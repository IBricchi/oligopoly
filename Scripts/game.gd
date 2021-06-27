extends Node

var board: Spatial

var tiles_set: bool = false
var current_tile: int
var board_tiles: Array

var player: KinematicBody

var dice: RigidBody

var global_time: int = 0
var memory: Dictionary = {}

signal player_step(target)
signal request_board_tiles(tiles)
signal roll_dice

func _ready():
	board = $board
	player = $player
	
	dice = $dice
	dice.connect("rolled_value", self, "_on_rolled_value")
	dice.connect("player_landed", self, "_on_player_landed")

var can_roll: bool = true
func _process(delta):
	if !tiles_set:
		tiles_set = false
		emit_signal("request_board_tiles", board_tiles)
	
	if can_roll and Input.is_action_just_pressed("lc"):
		can_roll = false
		emit_signal("roll_dice")

func _on_rolled_value(val: int):
	can_roll = true
	var target: int = (current_tile + val)%board_tiles.size()
	while current_tile != target:
		current_tile = (current_tile + 1) % board_tiles.size()
		emit_signal("player_step", board_tiles[current_tile])

func _on_player_landed(player_time: int):
	memory[global_time] = {
		"player_time": player_time,
		"position": current_tile
	}
