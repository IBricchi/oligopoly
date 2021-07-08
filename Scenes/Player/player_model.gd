extends Spatial

func _ready():
	### decide on the color
	var got_color = false
	var color_vector: Vector3
	
	
	## look for a new color that is not in the neighborhood of any previous one
	while not got_color:
		color_vector = Vector3(rand_range(0,200)/200.0,rand_range(0,200)/200.0, rand_range(0,200)/200.0)
		got_color = true
		for v in get_tree().get_root().get_node("/root/game/").player_colours:
			if (v-color_vector).length() < 0.1:
				got_color = false
	
	get_tree().get_root().get_node("/root/game/").player_colours.append(color_vector)\
	
	## set new material with that color
	var material = $Pawn.get_surface_material(0).duplicate()
	material.albedo_color = Color(color_vector.x, color_vector.y, color_vector.z)
	$Pawn.set_surface_material(0, material)
	
	


