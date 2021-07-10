extends MarginContainer

onready var prompt: Label = $"body/split/margin/centre/prompt"
onready var yes: Button = $"body/split/options/MarginContainer2/yes"

signal confirm_chance

func _ready():
	yes.connect("button_up", self, "_on_yes")
	
func _on_yes():
	emit_signal("confirm_chance")
	visible = false

func popup(command: String, val: int):
	var message: String
	var accept: String
	match command:
		"move_forward":
			message = "A solar storm rages.\n You get shoved forward %d tiles." % val
			accept = "Ummf"
		"move_back":
			message = "You slipped on a banana peel and fell back %d tiles. \n\n How did that thing even get here?" % val
			accept = "Ahhhh ..."
		"add_money":
			message = "Out of nowhere a time rip opens and out pops £%d. \n You decide not to question this." % val
			accept = "Gimme that cash!"
		"loose_money":
			message = "You trip and drop £%d in a time rip. \n You can do nothing but stare as your cash floats into the abyss." % val
			accept = "Oh no my money!"
		"advance_time":
			message = "There was some residual time energy from your last hop and you move %d turns into the future." % val
			accept = "ZOOOOP"
		"rewind_time":
			message = "You slipped on a time banana and fell back %d moves in the past." % val
			accept = "Ahhhh ... (but in time)"
		"switch_colour":
			message = "You feel a very strange sensation ... \n You glance down and realize your skin tone has completely changed!"
			accept = "Do I even have skin ?"
	prompt.text = message
	yes.text = accept
	visible = true
