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
	UI.connect("buy_property", self, "_on_ui_buy_property")
	
	# setup board
	board_tiles = board.request_board_tiles()
	for tile in board_tiles:
		tile.connect("queue_property_action", self, "_on_queue_property_action")
		tile.connect("queue_time_travel", self, "_on_queue_time_travel")
		tile.connect("add_money", self, "change_player_money")
	
	# setup player
	player = initiate_player(0, global_time, 0, 500, [])
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

func _on_ui_buy_property(tile_idx: int):
	player_buy_property(0, tile_idx)

# Board connections
func _on_queue_property_action(idx: int, tile_idx: int):
	var owners: Array = get_tile_owners(tile_idx)
		
	if not owners.empty():
		if not owners.has(idx):
			var tile = board_tiles[tile_idx]
			var rent_fee = tile.rent_cost
			for player_idx in owners:
				change_player_money(idx, -rent_fee)
				change_player_money(player_idx, rent_fee)
	elif idx == 0:
		var instruction: Dictionary = {
			"command": "property_prompt",
			"tile": tile_idx,
			"price": board_tiles[tile_idx].buy_cost,
			"can_buy": false
		}
		if player.money >= board_tiles[tile_idx].buy_cost:
			instruction["can_buy"] = true
		turn_queue.push_back(instruction)

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
	players[idx].step()	
	if idx == 0:
		global_time += 1
		ui_update_times()	
		
		handle_turn_instruction()
	else:
		check_instructions()

func _on_player_vanished(idx: int):
	if idx != 0:
		remove_child(players[idx])
		check_instructions()

# Helpers
func initiate_player(tile_idx: int, time: int, continuity: int, money: int, leases: Array) -> KinematicBody:
	var player: KinematicBody = player_scene.instance()
	var initial_tile: Spatial  = board_tiles[tile_idx]
	var initial_position: Vector3 = initial_tile.translation
	
	player.translation = initial_position + Vector3.UP * 3
	player.scale *= 0.4
	
	var rand_offset: Vector3 = Vector3(rand_range(-1.3,1.3),0,rand_range(-1.3,1.3))
	player.get_node("col").translation += rand_offset
	player.get_node("body_cont").translation += rand_offset
	
	player.idx = players.size()
	player.tile = tile_idx
	player.time = time
	player.continuity = continuity
	player.money = money
	player.leases = leases.duplicate(true)
	
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
				UI.show_property_popup(instruction.get("tile"), instruction.get("price"), instruction.get("can_buy"))
			"time_travel":
				if randf() < 0.7:
					change_time(global_time - round(rand_range(3,10)))
				else:
					change_time(global_time + round(rand_range(3,8)))
				handle_turn_instruction()
			_:
				print("Unkown Command '%s'" % command)

func get_tile_owners(tile_idx: int) -> Array:
	var owners: Array = []
	for player in players:
		for lease in player.leases:
			if lease.get("tile") == tile_idx:
				owners.push_back(player.idx)
				break
	return owners

func player_buy_property(idx: int, tile_idx: int):
	var player = players[idx]
	var tile = board_tiles[tile_idx]
	change_player_money(idx, -tile.buy_cost)
	player.leases.push_back({
		"tile": tile_idx,
		"ttl": 10
	})
	if idx == 0:
		handle_turn_instruction()

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
	
	if time_state == null:
		return

	# move players
	for player in players:
		if player.idx != 0:
			var data: Dictionary = {}
			for player_data in time_state:
				if player.continuity == player_data.get("continuity"):
					data = player_data
			if data.empty():
				continue
			instructions.append({
				"player": player,
				"command": "mov",
				"data": data
			})
			for lease in data.get("leases"):
				var new_lease: bool = true
				for owned_lease in player.leases:
					if owned_lease.get("tile") == lease.get("tile"):
						new_lease = false
						break
				if new_lease:
					instructions.append({
						"player": player,
						"command": "buy_property",
						"lease": lease
					})
			if not next_continuities.has(player.continuity):
				instructions.append({
					"player": player,
					"command": "rem"
				})

func execute_instruction():
	var instruction: Dictionary = instructions.pop_front()
	var command = instruction.get("command")
	match command:
		"add":
			var data = instruction.get("data")
			initiate_player(data.get("tile"), global_time, data.get("continuity"), data.get("money"), data.get("leases"))
		"mov":
			var player = instruction.get("player")
			var data = instruction.get("data")
			var next: int = (player.tile + 1)%board_tiles.size()
			var target: int = data.get("tile")
			var path: Array = generate_path(next, target)
			player.tile = target
			player.queue_target(path)
		"buy_property":
			var player = instruction.get("player")
			var lease = instruction.get("lease")
			var tile = lease.get("tile")
			if get_tile_owners(tile).empty() and player.money >= board_tiles[tile].buy_cost:
				player_buy_property(player.idx, tile)
		"rem":
			var player = instruction.get("player")
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
		if player.idx != 0:
			instructions.append({
					"player": player,
					"command": "rem"
				})
		
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
		"money": player.money,
		"leases": player.leases.duplicate(true)
	}
	
	if memory.has(global_time):
		memory[global_time].push_back(new_mem)
	else:
		memory[global_time] = [new_mem]

func remove_player(idx: int):
	players[idx].vanish()
	for i in range(idx+1, players.size()):
		players[i].idx -= 1
	players.remove(idx)
	
# drops question marks from the sky 
func drop_question_marks():
	for i in range(12):
		var floating_question: RigidBody
		floating_question = question_scene.instance()
		self.add_child(floating_question)
			
