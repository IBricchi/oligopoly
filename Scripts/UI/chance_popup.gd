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
			message = "You get shoved forward %d tiles." % val
			accept = "Ummf"
		"move_back":
			message = "You slipped on a bannana and fell back %d tiles." % val
			accept = "Ahhhh"
		"add_money":
			message = "A time rip opens and out pops £%d." % val
			accept = "Gimme that cash!"
		"loose_money":
			message = "You trip and drop £%d in a time rip." % val
			accept = "No my money!"
		"advance_time":
			message = "There was some residual time energy from your last hop and you move %d turns into the future" % val
			accept = "ZOOOOP"
		"rewind_time":
			message = "You slipped on a time bannada and fell back %d moves in the past." % val
			accept = "Ahhhh (but in time)"
	prompt.text = message
	yes.text = accept
	visible = true
