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
			message = "Move forward %d tiles." % val
			accept = "Move"
		"add_money":
			message = "Congratulations, you won £%d." % val
			accept = "Gimme that cash!"
		"advance_time":
			message = "Move %d turns into the future" % val
			accept = "Take me"
	prompt.text = message
	yes.text = accept
	visible = true
