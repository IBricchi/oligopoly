extends Node

# UI data
onready var UI: MarginContainer = $UI

# board data
onready var board: Spatial = $board
var board_tiles: Array

# silly question mark
var question_scene: Resource = preload("res://Scenes/Extra/FloatingQuestion.tscn")

# player data
var player: KinematicBody
var player_scene: Resource = preload("res://Scenes/Player/player.tscn")

# dice data
onready var dice: RigidBody = $dice

# memory data
var memory: Dictionary = {}
var global_time: int = 1
var players: Array = []

# turn data
var turn_queue: Array = []

func _ready():
	# setup UI
	UI.connect("roll", self, "_on_roll_dice")
	UI.connect("ti_handled", self, "_on_ti_handled")
	UI.connect("add_player", self, "_on_add_player")
	UI.connect("change_time", self, "_on_change_time")
	
	# setup board
	board_tiles = board.request_board_tiles()
	for tile in board_tiles:
		tile.connect("queue_property_prompt", self, "_on_queue_property_prompt")
		tile.connect("queue_time_travel", self, "_on_queue_time_travel")
		tile.connect("add_money", self, "change_player_money")
	
	# setup player
	player = initiate_player(0, global_time, 0, 500)
	change_player_money(0,0)
	
	# setup dice
	dice.connect("rolled_value", self, "_on_rolled_value")

# UI connections
var can_roll: bool = false
func _on_roll_dice():
	if can_roll:
		can_roll = false
		dice.roll_dice()

func _on_ti_handled():
	handle_turn_instruction()

func _on_add_player(time: int):
	_on_rolled_value(time)

func _on_change_time(time: int):
	change_time(time)
	handle_turn_instruction()

# Board connections
func _on_queue_property_prompt(tile_idx: int):
	turn_queue.push_back({
		"command": "property_prompt",
		"tile": tile_idx
	})

func _on_queue_time_travel():
	turn_queue.push_back({
		"command": "time_travel"
	})

# Dice connection
func _on_rolled_value(val: int):	
	var next: int = (player.tile + 1)%board_tiles.size()
	var target: int = (player.tile + val)%board_tiles.size()
	var path: Array = generate_path(next, target)
	player.tile = target
	player.queue_target(path)

# Player connections
var instructions: Array

func _on_player_first_land(idx: int):
	check_instructions()

func _on_player_landed(idx: int):
	if idx == 0:
		global_time += 1
		player.time += 1
		ui_update_times()	
		
		handle_turn_instruction()
	else:
		check_instructions()

var vanished_count = 0
func _on_player_vanished(idx: int):
	if idx != 0:
		remove_child(players[idx])
		check_instructions()
	vanished_count += 1
	if(vanished_count == players.size()):
		vanished_count = 0
		players = [player]

# Helpers
func initiate_player(tile_idx: int, time: int, continuity: int, money: int) -> KinematicBody:
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
	player.continuity = continuity
	player.money = money
	
	player.connect("player_first_land", self, "_on_player_first_land")
	player.connect("player_landed", self, "_on_player_landed")
	player.connect("player_vanished", self, "_on_player_vanished")
	
	players.push_back(player)
	add_child(player)
	
	return player

# there is currently no checks for infinite looping
func generate_path(s_idx: int, e_idx: int) -> Array:
	if s_idx == (e_idx + 1) % board_tiles.size():
		return []
	var idx: int = s_idx
	var path: Array = [board_tiles[idx]]
	while idx != e_idx:
		idx = (idx + 1) % board_tiles.size()
		path.push_back(board_tiles[idx])
	return path

func handle_turn_instruction():
	if turn_queue.empty():
		generate_instructions()
		check_instructions()
	else:
		var instruction: Dictionary = turn_queue.pop_front()
		var command: String = instruction.get("command")
		match command:
			"property_prompt":
				var tile: int = instruction.get("tile")
				handle_turn_instruction()
#				UI.show_property_popup(tile)
			"time_travel":
				if randf() < 0.7:
					change_time(global_time - round(rand_range(3,10)))
				else:
					change_time(global_time + round(rand_range(3,8)))
				handle_turn_instruction()
			_:
				print("Unkown Command '%s'" % command)

func generate_instructions():
	# get existing continuities
	var prev_continuity: Array
	for player in players:
		prev_continuity.push_back(player.continuity)
		
	var time_state = memory.get(global_time)
	var time_continuities: Dictionary = {}
	if time_state != null:
		for player_data in time_state:
			time_continuities[player_data.get("continuity")] = player_data
			
	var next_state = memory.get(global_time + 1)
	var next_continuities: Dictionary = {}
	if next_state != null:
		for player_data in next_state:
			next_continuities[player_data.get("continuity")] = player_data
	
	# add new players
	for continuity in time_continuities.keys():
		if not prev_continuity.has(continuity) and next_continuities.has(continuity):
			instructions.append({
				"command": "add",
				"data": time_continuities.get(continuity)
			})
	
	# move players
	for player in players:
		if player.idx != 0:
			var data: Dictionary = {}
			for player_data in time_state:
				if player.continuity == player_data.get("continuity"):
					data = player_data
			instructions.append({
				"player": player,
				"command": "mov",
				"data": data
			})
			if not next_continuities.has(player.continuity):
				instructions.append({
					"player": player,
					"command": "rem"
				})

func execute_instruction():
	var instruction: Dictionary = instructions.pop_front()
	var player = instruction.get("player")
	var command = instruction.get("command")
	var data = instruction.get("data")
	match command:
		"add":
			initiate_player(data.get("tile"), global_time, data.get("continuity"), data.get("money"))
		"mov":
			var next: int = (player.tile + 1)%board_tiles.size()
			var target: int = data.get("tile")
			var path: Array = generate_path(next, target)
			player.tile = target
			player.time += 1
			player.queue_target(path)
		"rem":
			remove_player(player.idx)
			remove_child(player)
		_:
			print("Unkown Command '%s'" % command)

func check_instructions():
	if not instructions.empty():
		execute_instruction()
	else:
		can_roll = true
		add_memory()

func change_time(time: int):
	add_memory()
	
	global_time = time
	ui_update_times()
	for player in players:
		player.vanish()
		
	player.continuity += 1

func ui_update_times():
	UI.set_global_time(global_time)
	UI.set_player_time(player.time)

func change_player_money(idx: int, ammount: int):
	players[idx].money += ammount
	if idx == 0:
		UI.set_player_money(player.money)

func add_memory():
	var new_mem: Dictionary = {
		"player_time": player.time,
		"tile": player.tile,
		"continuity": player.continuity,
		"money": player.money
	}
	
	if memory.has(global_time):
		memory[global_time].push_back(new_mem)
	else:
		memory[global_time] = [new_mem]

func remove_player(idx: int):
	players[idx].vanish()
	vanished_count = 0
	for i in range(idx+1, players.size()):
		players[i].idx -= 1
	players.remove(idx)
	
# drops question marks from the sky 
func drop_question_marks():
	for i in range(12):
		var floating_question: RigidBody
		floating_question = question_scene.instance()
		self.add_child(floating_question)
			
