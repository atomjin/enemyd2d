extends CanvasLayer

@onready var texture_rect = $TextureRect
@onready var viewport = $Viewport
@onready var scream = $AudioStreamPlayer

func show_jumpscare_with_model(model_scene: PackedScene, scream_sound: AudioStream, duration := 1.5):
	# Clear previous content in the viewport
	for child in viewport.get_children():
		if not (child is Camera3D or child is DirectionalLight3D):
			child.queue_free()

	# Instance the enemy model
	var model = model_scene.instantiate()
	viewport.add_child(model)

	# Make the CanvasLayer visible
	visible = true
	texture_rect.visible = true

	# Set the texture from viewport
	texture_rect.texture = viewport.get_texture()

	# Play scream sound
	scream.stream = scream_sound
	scream.play()

	# Wait and then hide
	await get_tree().create_timer(duration).timeout
	visible = false
	texture_rect.visible = false
