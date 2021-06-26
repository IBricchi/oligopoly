extends Node

var board: Spatial

var tiles_set: bool = false
var current_tile: int
var board_tiles: Array

var player: KinematicBody

var dice: RigidBody

signal player_step(target)
signal request_board_tiles(tiles)
signal roll_dice

func _ready():
	board = $board
	player = $player
	
	dice = $dice
	dice.connect("rolled_value", self, "_on_rolled_value")

func _process(delta):
	if !tiles_set:
		tiles_set = false
		emit_signal("request_board_tiles", board_tiles)
	
	if Input.is_action_just_pressed("space"):
		current_tile = (current_tile + 1) % board_tiles.size()
		emit_signal("player_step", board_tiles[current_tile])
	
	if Input.is_action_just_pressed("lc"):
		emit_signal("roll_dice")

func _on_rolled_value(val: int):
	print("Rolled a %d" % val)
	
