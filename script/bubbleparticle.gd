extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func emit_bubble_once():
	$GPUParticles3D.emitting = false # Reset just in case
	$GPUParticles3D.restart()        # Important: restarts the system
	$GPUParticles3D.emitting = true  # Triggers the one-shot emission
