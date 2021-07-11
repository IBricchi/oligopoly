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
var player_colours: Array = [] ## Array of Vector3s containing the colors (order doesnt matter)
var chance_tile_overide = null
var chance_data: Array = []

# turn data
var turn_queue: Array = []


onready var audio : Node = $AudioStreamPlayer

func _ready():
	# setup UI
	randomize()
	
	UI.connect("roll", self, "_on_roll_dice")
	UI.connect("ti_handled", self, "_on_ti_handled")
	UI.connect("debug", self, "_on_debug")
	UI.connect("buy_property", self, "_on_ui_buy_property")
	
	# setup board
	board_tiles = board.request_board_tiles()
	for tile in board_tiles:
		tile.connect("queue_property_action", self, "_on_queue_property_action")
		tile.connect("drop_qm", self, "_on_drop_qm")
		tile.connect("queue_chance", self, "_on_queue_chance")
		tile.connect("queue_time_travel", self, "_on_queue_time_travel")
		tile.connect("add_money", self, "change_player_money")
	
	# setup player
	player = initiate_player(0, global_time, 0, 500, [])
	
	# setup dice
	dice.connect("rolled_value", self, "_on_rolled_value")
	

# UI connections
var can_roll: bool = false
func _on_roll_dice():
	if can_roll:
		can_roll = false
		dice.roll_dice()

func _on_debug(t: int, val: int):
	match t:
		1:
			_on_rolled_value(val)
		2:
			global_time += 1
			change_time(val)
			handle_turn_instruction()
		3:
			change_player_money(0, val)

func _on_ti_handled():
	handle_turn_instruction()

func _on_ui_buy_property(tile_idx: int):
	player_buy_property(0, tile_idx)
	handle_turn_instruction()

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

func _on_drop_qm():
	drop_question_marks()

func _on_queue_chance():
	var command: String
	var val: int
	
	
	var rand_action: int = round(rand_range(0 -.4,5 +.4))
	
	match rand_action:
		0:
			command = "advance_time"
			val = round(rand_range(3,10))
		1:
			command = "rewind_time"
			val = round(rand_range(3,10))
		2:
			command = "add_money"
			val = round(rand_range(1,50)) * 10
			chance_data.push_back({
				"command": command,
				"val": val
			})
		3:
			command = "loose_money"
			val = round(rand_range(1,50)) * 10
			chance_data.push_back({
				"command": command,
				"val": val
			})
		4:
			command = "move_forward"
			val = round(rand_range(1,10))
			chance_data.push_back({
				"command": command,
				"val": val
			})
		5:
			command = "move_back"
			val = round(rand_range(1,10))
			chance_data.push_back({
				"command": command,
				"val": val
			})
		6:
			command = "switch_colour"
			val = 0
		_:
			print("This should be impossible")
	
	
	turn_queue.push_back({
		"command": "chance_prompt",
		"action": command,
		"val": val
	})
	turn_queue.push_back({
		"command": command,
		"val": val
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
	players[idx].step()	
	if idx == 0:
		if chance_tile_overide == null:
			global_time += 1
			ui_update_times()	
		
		handle_turn_instruction()
	else:
		check_instructions()

func _on_player_vanished(idx: int, check_instr: bool):
	if idx != 0:
		remove_player(idx)
		if check_instr:
			check_instructions()

var death_can_remove: Array = []
func _on_player_died(idx: int):
	if idx == 0:
		Global.turns_on_death = player.time
		get_tree().change_scene("res://Scenes/death_screen.tscn")
	elif death_can_remove.has(idx):
		death_can_remove.erase(idx)
		remove_player(idx)
	else:
		death_can_remove.push_back(idx)

func _on_lease_lost():
	UI.update_pd(players)

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
	player.connect("player_died", self, "_on_player_died")
	player.connect("lease_lost", self, "_on_lease_lost")
	
	players.push_back(player)
	add_child(player)
	UI.update_pd(players)
	
	return player

# there is currently no checks for infinite looping
func generate_path(s_idx: int, e_idx: int, forward: bool = true) -> Array:
	if (forward and s_idx == (e_idx + 1) % board_tiles.size()) or (!forward and s_idx == (e_idx - 1 + board_tiles.size()) % board_tiles.size()):
		return []
	var idx: int = s_idx
	var path: Array = [board_tiles[idx]]
	while idx != e_idx:
		if forward:
			idx = (idx + 1) % board_tiles.size()
		else:
			idx = (idx - 1 + board_tiles.size()) % board_tiles.size()
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
				var tr: int = min(5 + player.time%10, 10)
				var next_time: int = 0
				
				if global_time < -tr+3:
					next_time = global_time - rand_range(2,5)
				elif global_time < tr + 3:
					next_time = rand_range(-tr, global_time - 3)
				else:
					next_time = rand_range(-tr, tr)
				
				change_time(next_time)
				handle_turn_instruction()
			"chance_prompt":
				UI.show_chance_popup(instruction.get("action"), instruction.get("val"))
			"move_forward":
				chance_tile_overide = player.tile
				var val: int = instruction.get("val")
				var next: int = (player.tile + 1)%board_tiles.size()
				var target: int = (player.tile + val)%board_tiles.size()
				var path: Array = generate_path(next, target)
				player.tile = target
				player.queue_target(path)
			"move_back":
				chance_tile_overide = player.tile
				var val: int = instruction.get("val")
				var next: int = (player.tile - 1)%board_tiles.size()
				var target: int = (player.tile - val + board_tiles.size())%board_tiles.size()
				var path: Array = generate_path(next, target, false)
				player.tile = target
				player.queue_target(path, false)
			"add_money":
				var val: int = instruction.get("val")
				change_player_money(0, val)
				handle_turn_instruction()
			"loose_money":
				var val: int = instruction.get("val")
				change_player_money(0, -val)
				handle_turn_instruction()
			"advance_time":
				var val: int = instruction.get("val")
				change_time(global_time + val)
				handle_turn_instruction()
			"rewind_time":
				var val: int = instruction.get("val")
				change_time(global_time - val)
				handle_turn_instruction()
			"switch_colour":
				players[0].switch_color()
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
		"ttl": 9
	})
	UI.update_pd(players)

var block_mov: bool = false
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
		if (block_mov or not prev_continuity.has(continuity)) and next_continuities.has(continuity):
			instructions.append({
				"command": "add",
				"data": time_continuities.get(continuity)
			})
	
	if time_state == null:
		return

	if block_mov:
		block_mov = false
		return
	
	# move players
	for player in players:
		if player.idx != 0:
			var data: Dictionary = {}
			for player_data in time_state:
				if player.continuity == player_data.get("continuity"):
					data = player_data
#					break
			if data.empty():
				continue
			# move players
			instructions.append({
				"player": player,
				"command": "mov",
				"data": data
			})
			# check chance properties
			for chance_command in data.get("chance_commands"):
				instructions.append({
					"player": player,
					"command": chance_command.get("command"),
					"val": chance_command.get("val")
				})
			# find any properties that need to be bought
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
			# find if player needs to be removed
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
			check_instructions()
		"rem":
			var player = instruction.get("player")
			player.vanish()
		"batch_rem":
			var players: Array = instruction.get("players")
			var param: bool = true
			for player in players:
				player.vanish(param)
				param = false
		"kill":
			var player = instruction.get("player")
			if death_can_remove.has(player.idx):
				remove_player(player.idx)
				death_can_remove.erase(player.idx)
			else:
				death_can_remove.push_back(player.idx)
		"move_forward":
			var player = instruction.get("player")
			var val: int = instruction.get("val")
			var next: int = (player.tile + 1)%board_tiles.size()
			var target: int = (player.tile + val)%board_tiles.size()
			var path: Array = generate_path(next, target)
			player.tile = target
			player.queue_target(path)
		"move_back":
			var player = instruction.get("player")
			var val: int = instruction.get("val")
			var next: int = (player.tile - 1)%board_tiles.size()
			var target: int = (player.tile - val + board_tiles.size())%board_tiles.size()
			var path: Array = generate_path(next, target, false)
			player.tile = target
			player.queue_target(path, false)
		"add_money":
			var player = instruction.get("player")
			var val: int = instruction.get("val")
			change_player_money(player.idx, val)
			check_instructions()
		"loose_money":
			var player = instruction.get("player")
			var val: int = instruction.get("val")
			change_player_money(player.idx, -val)
			check_instructions()
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
	
	player.time_travel_player()
	
	global_time = time
	ui_update_times()
	block_mov = true
	if players.size() > 1:
		instructions.append({
			"command": "batch_rem",
			"players": players.slice(1,players.size()-1),
		})
		
	player.continuity += 1

func ui_update_times():
	UI.set_global_time(global_time)
	UI.set_player_time(player.time)

func change_player_money(idx: int, ammount: int):
	players[idx].change_money(ammount)
	if players[idx].money < 0:
		players[idx].kill()
		if idx != 0:
			instructions.append({
				"player": players[idx],
				"command": "kill"
			})
	UI.update_pd(players)

func add_memory():
	var tile = player.tile
	if chance_tile_overide != null:
		tile = chance_tile_overide
		chance_tile_overide = null
	
	var new_mem: Dictionary = {
		"player_time": player.time,
		"tile": tile,
		"continuity": player.continuity,
		"money": player.money,
		"leases": player.leases.duplicate(true),
		"chance_commands": chance_data.duplicate(true)
	}
	
	chance_data = []
	
	if memory.has(global_time):
		memory[global_time].push_back(new_mem)
	else:
		memory[global_time] = [new_mem]

func remove_player(idx: int):
	for i in range(idx+1, players.size()):
		players[i].idx -= 1
	remove_child(players[idx])
	players.remove(idx)
	UI.update_pd(players)
	
# drops question marks from the sky 
func drop_question_marks():
	for i in range(25):
		var floating_question: RigidBody
		floating_question = question_scene.instance()
		self.add_child(floating_question)



func _on_AudioStreamPlayer_finished():
	audio.play()
