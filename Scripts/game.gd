extends Node

# UI data
onready var UI: MarginContainer = $UI

# board data
onready var board: Spatial = $board
var board_tiles: Array

# player data
var player: KinematicBody
var player_scene: Resource = preload("res://Scenes/Player/player.tscn")

# dice data
onready var dice: RigidBody = $dice

# memory data
var memory: Dictionary = {}
var global_time: int = 1
var players: Array = []

func _ready():
	# setup UI
	UI.connect("roll", self, "_on_roll_dice")
	UI.connect("add_player", self, "_on_add_player")
	UI.connect("change_time", self, "_on_change_time")
	
	# setup board
	board_tiles = board.request_board_tiles()
	
	# setup player
	player = initiate_player(0, global_time)
	players.push_back(player)
	add_memory()
	
	# setup dice
	dice.connect("rolled_value", self, "_on_rolled_value")

# UI connections
var can_roll: bool = true
func _on_roll_dice():
	if can_roll:
		can_roll = false
		dice.roll_dice()

func _on_add_player(time: int):
	if !memory.has(time):
		print("player has not been in this time period yet")
	else:
		print(memory[time])
		var player_data = memory[time][0]
		var tile = player_data.get("tile")
		var player = initiate_player(tile, time)
		players.push_back(player)

func _on_change_time(time: int):
	global_time = time
	ui_update_times()
	for player in players:
		player.vanish()
	var time_state = memory.get(time)
	if time_state != null:
		for player_data in time_state:
			var tile = player_data.get("tile")
			var player = initiate_player(tile, time)
			players.push_back(player)
	add_memory()

# Dice connection
func _on_rolled_value(val: int):	
	var next: int = (player.tile + 1)%board_tiles.size()
	var target: int = (player.tile + val)%board_tiles.size()
	var path: Array = generate_path(next, target)
	player.tile = target
	player.queue_target(path)

# Player connections
var instructions: Array
func _on_player_landed(idx: int):
	if idx == 0: # if main player
		global_time += 1
		player.time += 1
		ui_update_times()	
		
		add_memory()
		instructions = generate_instructions()
		
		board_tiles[player.tile].player_lands() ## calls node function
		
	if not instructions.empty():
		execute_instruction()
	else:
		can_roll = true		

var vanished_count = 0
func _on_player_vanished(idx: int):
	if idx != 0:
		remove_child(players[idx])
	vanished_count += 1
	if(vanished_count == players.size()):
		vanished_count = 0
		players = [player]

# Helpers
func initiate_player(tile_idx: int, time: int) -> KinematicBody:
	var player: KinematicBody = player_scene.instance()
	var initial_tile: Spatial  = board_tiles[tile_idx]
	var initial_position: Vector3 = initial_tile.translation
	
	player.translation = initial_position + Vector3.UP * 3
	player.scale *= 0.4
	
	var rand_offset: Vector3 = Vector3(rand_range(-1.5,1.5),0,rand_range(-1.5,1.5))
	player.get_node("col").translation += rand_offset
	player.get_node("body_cont").translation += rand_offset
	
	player.idx = players.size()
	player.tile = tile_idx
	player.time = time
	
	player.connect("player_landed", self, "_on_player_landed")
	player.connect("player_vanished", self, "_on_player_vanished")
	add_child(player)
	
	return player

# there is currently no checks for infinite looping
func generate_path(s_idx: int, e_idx: int) -> Array:
	var idx: int = s_idx
	var path: Array = [board_tiles[idx]]
	while idx != e_idx:
		idx = (idx + 1) % board_tiles.size()
		path.push_back(board_tiles[idx])
	return path

func generate_instructions() -> Array:
	var instructions: Array = []
	
	for player in players:
		if player.idx != 0:
			var data: Dictionary = memory.get(player.time + 1)[0]
			instructions.append({
				"player": player,
				"command": "move",
				"data": data
			})
	
	return instructions

func execute_instruction():
	var instruction: Dictionary = instructions.pop_front()
	var player = instruction.get("player")
	var command = instruction.get("command")
	var data = instruction.get("data")
	match command:
		"move":
			var next: int = (player.tile + 1)%board_tiles.size()
			var target: int = data.get("tile")
			var path: Array = generate_path(next, target)
			player.tile = target
			player.time += 1
			player.queue_target(path)
		_:
			print("Unkown Command '%s'" % command)

func ui_update_times():
	UI.set_global_time(global_time)
	UI.set_player_time(player.time)

func add_memory():
	if memory.has(global_time):
		memory[global_time].push_back({
			"player_time": player.time,
			"tile": player.tile
		})
	else:
		memory[global_time] = [{
			"player_time": player.time,
			"tile": player.tile
		}]
