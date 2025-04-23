extends OmniLight3D

@export var min_energy := 0.0
@export var max_energy := 4.0
@export var flicker_speed := 0.1

var timer := 0.0

func _process(delta):
	timer -= delta
	if timer <= 0.0:
		# Randomize energy within the min and max range
		light_energy = randf_range(min_energy, max_energy)
		# Set the timer for the next flicker
		timer = randf_range(flicker_speed * 0.5, flicker_speed * 1.5)
