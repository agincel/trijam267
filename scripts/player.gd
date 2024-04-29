extends CharacterBody3D

signal coin_collected
signal dig_start
signal dig_end

signal dig_site_register

@export_subgroup("Components")
@export var view: Node3D
@export var particles_trail: CPUParticles3D
@export var particles_digging: GPUParticles3D
@export var sound_footsteps: AudioStreamPlayer
@export var sound_digging: AudioStreamPlayer
@export var model: Node3D
@export var animation: AnimationPlayer

@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 7
@export var DOWNWARD_GRAVITY = 24
@export var NUM_JUMPS = 2
@export var JUMP_BUFFER_DURATION = 0.2
@export var COYOTE_BUFFER_DURATION = 0.2

@export_subgroup("Dash")
@export var DASH_SPEED = 666
@export var DASH_DURATION = 0.33
@export var DASH_VERTICAL_SPEED = 5

@export_subgroup("Dig")
@export var DIG_DOWN_SPEED = 10
@export var DIG_DOWNWARD_BODY_OFFSET = 0.175

var movement_velocity: Vector3
var rotation_direction: float
var verticalSpeed = 0
var jumpTimer = 0
var timeSinceGrounded = 0

var previously_floored = false

var numJumps = 2
var coins = 0
var num_dashes = 1
var dash_remaining = 0.0
var dash_velocity = Vector3.ZERO

var is_digging = false
var current_dig_target = null
var current_dig_handler = null
var time_spent_digging = 0
const DIG_CHECK_TIME = 0.6

# Functions
func _physics_process(delta):
	# Handle functions
	
	handle_controls(delta)
	handle_vertical_speed(delta)
	dig_check(delta)
	
	handle_effects()
	
	# Movement
	var applied_velocity: Vector3
	
	if (is_digging):
		applied_velocity = velocity.lerp(Vector3.ZERO, delta * 6)
	elif (dash_remaining > 0):
		applied_velocity = velocity.lerp(movement_velocity, delta * 3)
		dash_remaining -= delta
	else:
		applied_velocity = velocity.lerp(movement_velocity, delta * 18)
		
	applied_velocity.y = -verticalSpeed	
	velocity = applied_velocity
	move_and_slide()
	
	# Rotation
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
		
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)
	
	# Falling/respawning
	if position.y < -10:
		get_tree().reload_current_scene()
	
	# Animation for scale (jumping and landing)
	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)
	if is_digging:
		model.position = model.position.lerp(Vector3(model.position.x, -DIG_DOWNWARD_BODY_OFFSET, model.position.z), delta * 10)
	else:
		model.position = model.position.lerp(Vector3(model.position.x, 0, model.position.z), delta * 10)
	
	# Animation when landing
	if is_on_floor() and verticalSpeed > 2 and !previously_floored:
		model.scale = Vector3(1.25, 0.75, 1.25)
		Audio.play("res://sounds/land.ogg")
	
	previously_floored = is_on_floor()
	if previously_floored:
		timeSinceGrounded = 0
	else:
		timeSinceGrounded += delta

# Handle animation(s)
func handle_effects():
	particles_trail.emitting = false
	sound_footsteps.stream_paused = true
	sound_digging.stream_paused = not (is_digging and is_on_floor())
	
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			particles_trail.emitting = true
			sound_footsteps.stream_paused = false
		
		if is_digging and not particles_digging.emitting:
			particles_digging.emitting = true

	if (not is_digging or not is_on_floor()) and particles_digging.emitting:
		particles_digging.emitting = false


func get_input_3d():
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	
	input = input.rotated(Vector3.UP, view.rotation.y).limit_length(1)
	
	return input
	
	
# Handle movement input
func handle_controls(delta):
	# Movement
	if jumpTimer > 0:
		jumpTimer -= delta
	
	var input = get_input_3d()
	movement_velocity = input * movement_speed * delta
	if Input.is_action_just_pressed("jump"):
		jumpTimer = JUMP_BUFFER_DURATION
	
	# Jumping
	if jumpTimer > 0 and numJumps > 0:
		jump()
		
	if Input.is_action_just_pressed("dash") and dash_remaining <= 0 and num_dashes > 0:
		dash(delta)
	if Input.is_action_just_pressed("dig"):
		dig(delta, true)
	elif Input.is_action_just_released("dig"):
		dig(delta, false)

# Handle gravity
func handle_vertical_speed(delta):
	verticalSpeed += DOWNWARD_GRAVITY * delta
	
	if verticalSpeed > 0 and is_on_floor():
		restore_jumps()
		verticalSpeed = 0

# Jumping
func jump():
	if verticalSpeed > -jump_strength:
		jumpTimer = 0
		verticalSpeed = -jump_strength
		model.scale = Vector3(0.5, 1.5, 0.5)
		dig(0, false)
		Audio.play("res://sounds/jump.ogg")
		if timeSinceGrounded < COYOTE_BUFFER_DURATION:
			numJumps -= 1
		else:
			numJumps = 0
		
func dash(delta):
	var dash_direction = get_input_3d()
	if dash_direction.length_squared() <= 0:
		dash_direction = Quaternion.from_euler(Vector3(0, rotation.y, 0)) * Vector3.BACK
	
	Audio.play("res://sounds/whoosh.wav") # Play sound
	velocity = dash_direction.normalized() * DASH_SPEED * delta
	dash_remaining = DASH_DURATION
	verticalSpeed = -1 * DASH_VERTICAL_SPEED
	model.scale = Vector3(0.7, 0.7, 1.8)
	
	if not is_on_floor():
		num_dashes -= 1

func dig(delta, is_pressed):
	if is_pressed:
		if not is_digging:
			time_spent_digging = 0
			dig_start.emit()
			is_digging = true
			if (is_on_floor()):
				pass #todo particle and other logic
			else:
				if verticalSpeed < DIG_DOWN_SPEED:
					Audio.play("res://sounds/whoosh_low.wav") # Play sound
					set_gravity(DIG_DOWN_SPEED)
	else:
		if is_digging:
			dig_end.emit()
			pass #todo logic to stop digging if we were digging
		is_digging = false
		
func dig_check(delta):
	if is_digging and is_on_floor() and current_dig_handler != null:
		if (time_spent_digging < DIG_CHECK_TIME and time_spent_digging + delta >= DIG_CHECK_TIME):
			# report the check to our handler!
			print("perform check!")
			current_dig_handler.dig_check(self, model.global_position)
		time_spent_digging += delta
		print(time_spent_digging)
		

# Collecting coins
func collect_coin():
	coins += 1
	coin_collected.emit(coins)
	

func set_gravity(ySpeed):
	verticalSpeed = ySpeed

func restore_jumps():
	numJumps = NUM_JUMPS
	num_dashes = 1

func register_dig_site(pos, handler):
	current_dig_target = pos
	current_dig_handler = handler
	dig_site_register.emit(pos, handler)
