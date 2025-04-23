extends CharacterBody3D

signal interact_object

@onready var ray_cast_3d: RayCast3D = $Head/Camera3D/RayCast3D
@onready var right_hand: Marker3D = $Head/RightCarryObjectMarker
@onready var left_hand: Marker3D = $Head/LeftCarryObjectMarker

@onready var pickupObject_label: Label = $PickupObject
@onready var handFull_label: Label = $Handfull
@onready var oxygenTemp_label: Label = $OxygenTemp
@onready var oxygen_counter_label: Label = $"../GUI/Main/OxCounter"
@onready var usekey_label: Label = $UseKey
@onready var opendoor_label: Label = $OpenDoor
@onready var money_label: Label = $MoneyLabel
@onready var depth_label: Label = $DepthMeter
@onready var upgrade_label: Label = $Upgrade
var inupgrade: bool = false
var dead: bool = false

# Variables for movment
var speed
var SENSITIVITY = 0.001

var base_walk_speed = 5.0
var base_sprint_speed = 8.0
var base_swim_speed = 2.5
var base_swim_up_speed = 2.5
var base_dive_speed = -2.0

var WALK_SPEED = base_walk_speed
var SPRINT_SPEED = base_sprint_speed
var SWIM_SPEED = base_swim_speed 
var swim_up_speed = base_swim_up_speed
var dive_speed = base_dive_speed

# Variables for head bobbing
const BOB_FREQ = 2.4
var BOB_AMP: float = 0.08
var t_bob = 0.0

# Variables for handling swiming
var onground: bool = true
var diving: bool = false
var underwater: bool = false
var onwatersurface: bool = false

# Variables for object picking
var picked_right_object
var picked_left_object
var handfull = false
var strength = 1.0
var overall_weight = 0.0

# Variables for oxygen system
@onready var oxygen_bar: TextureProgressBar = $"../GUI/Main/Ox_Bar"
var oxygen_level: float = 100.0
var oxygen_decrease_rate: float = 3.0  # Oxygen decrease per second
var oxygen_recharge_rate: float = 40.0  # Oxygen recharge per second
var oxygen_timer: Timer = null
var oxygen_tank_limit: int = 0
var oxygen_tank_counter: int = 0
@onready var oxygen_particle = $Bubble/GPUParticles3D
var bubble_bursted = false

# Variables for flashlight system
@onready var flash_bar: TextureProgressBar = $"../GUI/Main/Flash_Bar"
var flashlight_status: bool = false
var flashlight_battery: float = 100.0
var flashlight_drain_rate: float = 8.0  # Battery drain per second
var flashlight_recharge_rate: float = 5.0  # Battery recharge per second
var flashlight_timer: Timer = null
var flashlight_cooldown: float = 2.0  # Cooldown before recharging
var flashlight_cooldown_timer: float = 0.0
var flashed = false

# Variables for currency
var current_money: int = 1000000

var menu_open: bool = false

@onready var flashlight = $Head/Camera3D/SpotLight3D
@onready var head = $Head
@onready var camera = $Head/Camera3D

#Water Shader
var target_opacity = 0.0
var blue_target_opacity = 0.0
var opacity = 0.0
var opacity_blue = 0.0
var lerp_speed = 5.0  # Adjust speed as needed
@onready var undershader = $underwater_shader.material
@onready var blueshader = $underwater_shader_blue.material

#enemy 
signal player_hit
var health := 3
@onready var scab: CharacterBody3D = $"../scab"
@export var enemy_path: NodePath

func _ready():
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#get hit
	
	var enemy = get_node_or_null(enemy_path)
	print("Player ready. Trying to connect to:", enemy)
	if enemy:
		enemy.connect("player_hit", Callable(self, "_on_player_hit"))
	# Create a timer for managing oxygen
	oxygen_timer = Timer.new()
	oxygen_timer.wait_time = 1.0  # Tick every second
	oxygen_timer.autostart = false
	oxygen_timer.one_shot = false
	oxygen_timer.connect("timeout", Callable(self, "_on_oxygen_timer_tick"))
	add_child(oxygen_timer)
	
	# Create a timer for Flashlight system
	flashlight_timer = Timer.new()
	flashlight_timer.wait_time = 0.1  # Tick every 0.1 seconds
	flashlight_timer.autostart = true
	flashlight_timer.one_shot = false
	flashlight_timer.connect("timeout", Callable(self, "_update_flashlight"))
	add_child(flashlight_timer)
	
	update_money()

func _unhandled_input(event):
	if event is InputEventMouseMotion and menu_open == false:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70), deg_to_rad(60))

func _process(delta):
	# Flashlight Battery Flash Effect
	if flashlight_battery <= 30 and not flashed:
		flashed = true  # Mark that we flashed
		flash_light_twice()
	
	# Reset the flashed state if battery is recharged above 30
	if flashlight_battery > 30:
		flashed = false
	
	if oxygen_level <= 60 and not bubble_bursted:
		bubble_bursted = true
		emit_bubble()
	
	if oxygen_level > 60:
		bubble_bursted = false
	
	# Depth
	if depth_label:
		depth_label.text = "ระดับความลึก: " + str(-int(global_transform.origin.y)) + "ft"

	# Water Shader
	opacity = lerp(opacity, target_opacity, lerp_speed * delta)
	undershader.set_shader_parameter("opacity", opacity)
	opacity_blue = lerp(opacity_blue, blue_target_opacity, lerp_speed * delta)
	blueshader.set_shader_parameter("opacity", opacity_blue)

	# Oxygen
	if oxygen_level == 00.00:
		oxygenTemp_label.text = "dead"
	elif oxygen_level < 60.00 and oxygen_level > 00.00 :
		oxygenTemp_label.text = str(oxygen_level)
	else:
		oxygenTemp_label.text = str(oxygen_level)
	
	oxygen_bar.value = oxygen_level
	
	# Flashlight
	if flashlight_status and flashlight_battery > 0:
		flashlight_battery -= flashlight_drain_rate * delta
		if flashlight_battery <= 0:
			flashlight_battery = 0
			flashlight_status = false
			flashlight.visible = false
			flashlight_cooldown_timer = flashlight_cooldown  # Start cooldown
	elif not flashlight_status and flashlight_battery < 100.0:
		if flashlight_cooldown_timer > 0:
			flashlight_cooldown_timer -= delta
		else:
			flashlight_battery += flashlight_recharge_rate * delta
			flashlight_battery = min(flashlight_battery, 100.0)
	
	flash_bar.value = flashlight_battery
	
	
	# Detect Item
	if ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		# Check for null and valid instance
		if collider != null and is_instance_valid(collider):
			
			interact_object.emit(collider)
			# Check if it's pickable
			if collider.has_method("is_pickable") and collider.is_pickable():
				show_interact_lable()
			else:
				disable_interact_lable()
			# Check if it's openable
			if collider.has_method("is_openable"):
				if not collider.is_openable():
					show_insertkey_lable()
					disable_opendoor_lable()
				else:
					disable_insertkey_lable()
					show_opendoor_lable()
			else:
				disable_insertkey_lable()
				disable_opendoor_lable()
		else:
			# Collider is invalid or null, make sure we disable everything
			interact_object.emit(null)
			disable_interact_lable()
			disable_insertkey_lable()
			disable_opendoor_lable()
	else:
		# Not colliding with anything
		interact_object.emit(null)
		disable_interact_lable()
		disable_insertkey_lable()
		disable_opendoor_lable()

func _input(event):
	#Temp
	if event.is_action_pressed("quit"):
		get_tree().quit()
	
	#Put down object
	if event.is_action_pressed("interaction"):
		# Check if the player is looking at a pickupable object
		if ray_cast_3d.is_colliding():
			var collider = ray_cast_3d.get_collider()
			if collider and collider is CharacterBody3D:
				# Pick up the object if a hand is free
				pick_up_object(collider)
				check_handfull()
				return
		
		# If not looking at an object, put down currently held items
		if picked_right_object:
			picked_right_object.reparent(get_tree().current_scene)
			picked_right_object.put_down()
			picked_right_object = null
			check_handfull()
		
		elif picked_left_object:
			picked_left_object.reparent(get_tree().current_scene)
			picked_left_object.put_down()
			picked_left_object = null
			check_handfull()

	#Flashlight
	if event.is_action_pressed("flashlight") and flashlight_battery > 0:
		flashlight_status = !flashlight_status
		flashlight.visible = flashlight_status
	
	#Oxygen
	if event.is_action_pressed("oxygen") and oxygen_tank_counter > 0 and underwater:
		oxygen_tank_counter -= 1
		oxygen_level = 100
		oxygen_counter_label.text = str(oxygen_tank_counter)


func _physics_process(delta: float) -> void:
	if onground == true and not menu_open:
		#Oxygen
		if oxygen_level < 100.0:
			oxygen_level += oxygen_recharge_rate * delta
			oxygen_level = min(oxygen_level, 100.0)
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		# Handle Sprint.
		if Input.is_action_pressed("sprint_n_dive"):
			speed = SPRINT_SPEED
		else:
			speed = WALK_SPEED

		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = 0.0
			velocity.z = 0.0
		
		# Head bob
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = _headbob(t_bob)
		
		move_and_slide()
	
	if diving == true: 
		velocity.y = lerp(velocity.y, 0.0, 1 * delta)
		velocity.x = lerp(velocity.x, 0.0, 2 * delta)
		velocity.z = lerp(velocity.z, 0.0, 2 * delta)
		move_and_slide()
	
	if onwatersurface == true:
		#Oxygen
		if oxygen_level < 100.0:
			oxygen_level += oxygen_recharge_rate * delta
			oxygen_level = min(oxygen_level, 100.0)
		if Input.is_action_just_pressed("swim_up"):
			onwatersurface = false
			velocity.y = 5.5
			
	if underwater == true:
		#Oxygen
		oxygen_level -= oxygen_decrease_rate * delta
		
		if oxygen_level <= 0:
			oxygen_level = 0
			outoff_oxygen()
		#Movement
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		#Headbob when AFK
		if abs(velocity.x) < 0.02 and abs(velocity.z) < 0.02:
			t_bob += delta * 0.5
			BOB_AMP = 0.3
			camera.transform.origin = _headbob(t_bob)
		
		#Normal Headbob
		t_bob += delta * 0.6
		BOB_AMP = 0.09
		camera.transform.origin = _headbob(t_bob)
		
		if direction:
			velocity.x = direction.x * SWIM_SPEED
			velocity.z = direction.z * SWIM_SPEED
		else:
			velocity.x = lerp(velocity.x, 0.0, 2 * delta)
			velocity.z = lerp(velocity.z, 0.0, 2 * delta)
		
		# Vertical movement
		if Input.is_action_pressed("swim_up"):  # Move up
			velocity.y = swim_up_speed
		elif Input.is_action_just_pressed("sprint_n_dive") or Input.is_action_pressed("sprint_n_dive"):    # Move down
			velocity.y = dive_speed
		else:
			velocity.y = lerp(velocity.y, 0.0, 5 * delta)  # Gradually stop vertical movement
		
		move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func _on_water_surface_detector_area_entered(area: Area3D) -> void:
	print("on water surface")
	onwatersurface = false

func _on_water_surface_detector_area_exited(area: Area3D) -> void:
	print("not on water surface")
	onwatersurface = true
	onground = true
	await get_tree().create_timer(0.5).timeout
	onwatersurface = false

func _on_deep_water_detector_area_entered(area: Area3D) -> void:
	print("enter water")
	onground = false
	diving = true
	target_opacity = 1.0 #Shader
	blue_target_opacity = 0.089 #Shader
	
	# Reset sprinting so "sprint_n_dive" can be re-detected properly
	if Input.is_action_pressed("sprint_n_dive"):
		Input.action_release("sprint_n_dive")
	
	await get_tree().create_timer(0.75).timeout
	diving = false
	underwater = true

func _on_deep_water_detector_area_exited(area: Area3D) -> void:
	print("exit water")
	oxygen_reset()
	target_opacity = 0.0 #Shader
	blue_target_opacity = 0.0 #Shader
	underwater = false
	onground = true
	BOB_AMP = 0.08

#Lable

func show_insertkey_lable():
	usekey_label.visible = true

func disable_insertkey_lable():
	usekey_label.visible = false

func show_opendoor_lable():
	opendoor_label.visible = true

func disable_opendoor_lable():
	opendoor_label.visible = false

#Item & Hand

func pick_up_object(object):
	if object.oncooldown:
		print("This object is on cooldown!")
		return  # Prevent picking up the object
	
	if not picked_right_object:
		# Assign the object to the right hand
		object.reparent($Head)
		object.global_position = right_hand.global_position
		object.rotation = Vector3.ZERO
		await get_tree().create_timer(0.1).timeout
		picked_right_object = object
		check_handfull()
	elif not picked_left_object:
		# Assign the object to the left hand
		object.reparent($Head)
		object.global_position = left_hand.global_position
		object.rotation = Vector3.ZERO
		await get_tree().create_timer(0.1).timeout
		picked_left_object = object
		check_handfull()
	else:
		# Both hands are full
		print("Hands are full!")
		check_handfull()

func check_handfull():
	if picked_left_object and picked_right_object:
		handfull = true
		show_handfull_lable()
	else:
		handfull = false
		disable_handfull_lable()

func _is_handfull() -> bool:
	return handfull

func show_interact_lable():
	pickupObject_label.visible = true

func disable_interact_lable():
	pickupObject_label.visible = false

func show_handfull_lable():
	handFull_label.visible = true

func disable_handfull_lable():
	handFull_label.visible = false

#Dead

func outoff_oxygen():
	dead = true
	print("DEAD!")

#Money

func update_money():
	money_label.text = str(current_money)

func add_money(amount):
	current_money = current_money+amount
	update_money()

func balance() -> int:
	return current_money

#Menu

func menu_set_open():
		menu_open = true

func menu_set_close():
		menu_open = false

#Weight

func add_weight(weight: float):
	overall_weight += weight
	swim_up_speed -= 1.0
	dive_speed += 1.0
	speed_adjustment()

func remove_weight(weight: float):
	overall_weight = max(overall_weight - weight, 0.0)
	swim_up_speed += 1.0
	dive_speed -= 1.0
	speed_adjustment()

func speed_adjustment():
	var weight_penalty = overall_weight * strength
	
	#var base_walk_speed = 5.0
	#var base_sprint_speed = 8.0
	#var base_swim_speed = 5.0
	#var base_swim_up_speed = 2.5
	#var base_dive_speed = -2.0
	
	if weight_penalty >= base_swim_speed:
		WALK_SPEED = 0.0
		SPRINT_SPEED = 0.0
		SWIM_SPEED = 0.0
		swim_up_speed = 0.0
		dive_speed = 0.0
	else:
		WALK_SPEED = max(base_walk_speed - weight_penalty, 0.0)
		SPRINT_SPEED = max(base_sprint_speed - weight_penalty, 0.0)
		SWIM_SPEED = max(base_swim_speed - weight_penalty, 0.0)
		swim_up_speed = base_swim_up_speed
		dive_speed = base_dive_speed

#Upgrade

func oxygen_reset():
	oxygen_tank_counter = oxygen_tank_limit
	oxygen_counter_label.text = str(oxygen_tank_counter)

func oxygen_upgrade():
	oxygen_tank_limit += 1
	oxygen_tank_counter = oxygen_tank_limit
	oxygen_counter_label.text = str(oxygen_tank_counter)

func inupgrade_area() -> bool:
	return inupgrade

func upgrade_label_show():
	upgrade_label.show()
	inupgrade = true

func upgrade_label_hide():
	upgrade_label.hide()
	inupgrade = false

func light_upgrade(range,bright,drain):
	#range = 10
	#attenuation = 0.8
	flashlight_drain_rate = drain
	flashlight.spot_range += range
	flashlight.spot_attenuation -= bright

func strength_upgrade(strengthmodify):
	#strength = 1
	strength -= strengthmodify

func speed_upgrade(speedmodify):
	base_walk_speed += speedmodify
	base_sprint_speed += speedmodify
	base_swim_speed += speedmodify/1.5
	base_swim_up_speed += speedmodify
	base_dive_speed -= speedmodify/1.5
	
	update_speed()

func update_speed():
	WALK_SPEED = base_walk_speed
	SPRINT_SPEED = base_sprint_speed
	SWIM_SPEED = base_swim_speed 
	swim_up_speed = base_swim_up_speed
	dive_speed = base_dive_speed

#Flashlight

func flash_light_twice():
	var flash_timer = get_tree().create_timer(0.1)
	flashlight.visible = false
	await flash_timer.timeout
	flashlight.visible = true
	flash_timer = get_tree().create_timer(0.1)
	await flash_timer.timeout
	flashlight.visible = false
	flash_timer = get_tree().create_timer(0.2)
	await flash_timer.timeout
	flashlight.visible = true

#Oxygen
func emit_bubble():
	oxygen_particle.emitting = false # Reset just in case
	oxygen_particle.restart()        # Important: restarts the system
	oxygen_particle.emitting = true  # Triggers the one-shot emission
	
#enemy
func _on_player_hit():
	print("💥 Player got hit by enemy!")
	health -= 1



#REF Movement https://www.youtube.com/watch?v=A3HLeyaBCq4&ab_channel=LegionGames
#REF Swimming https://www.youtube.com/watch?v=HzQvI4wwr-0&ab_channel=MajikayoGames
#REF PickUp https://www.youtube.com/watch?v=UT11Zmx75yg&t=14s&ab_channel=DevDrache
#REF UnderWaterShader https://www.youtube.com/watch?v=uYGjFo5rqnw&ab_channel=swydev
#REF Water https://www.youtube.com/watch?v=7L6ZUYj1hs8&ab_channel=StayAtHomeDev
#REF enemy https://youtu.be/iV710Vm5qm0?si=DR2RCjs4l8gW3cZc
