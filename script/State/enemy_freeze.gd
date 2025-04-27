extends State
class_name EnemyFreeze

@onready var enemy = get_parent().get_parent()
@onready var animation_tree: AnimationTree = $"../../AnimationTree"
@onready var animation_playback: AnimationNodeStateMachinePlayback
@onready var player = get_tree().get_first_node_in_group("player")
@onready var ray_cast = player.get_node("Head/Camera3D/RayCast3D") 



func _ready():
	animation_playback = animation_tree.get("parameters/playback")

func enter():
	print("🧊 ENTERED FREEZE STATE")
	if animation_playback:
		animation_playback.travel("idle")

func physics_process(delta):
	if not player:
		return

	if is_player_looking_at_enemy():
		enemy.velocity = Vector3.ZERO
		enemy.move_and_slide()
	else:
		print("🚶 Player looked away. Switch to chase.")
		emit_signal("Transitioned", self, "EnemyChaseEye")


func is_player_looking_at_enemy() -> bool:
	if not ray_cast or not enemy:
		return false

	var to_enemy = (enemy.global_position - ray_cast.global_position).normalized()
	var cast_direction = -ray_cast.global_transform.basis.z.normalized()

	var angle = cast_direction.angle_to(to_enemy)


	return angle < deg_to_rad(50)  # Try adjusting this value



	
