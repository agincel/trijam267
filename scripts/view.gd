extends Node3D

@export_group("Properties")
@export var target: Node
@export var vertical_offset = 1

@export_group("Zoom")
@export var zoom_minimum = 16
@export var zoom_maximum = 4
@export var zoom_speed = 10

@export_group("Rotation")
@export var rotation_speed = 120
@export var mouse_rotation_speed = 10

var camera_rotation:Vector3
var zoom = 10
var last_delta = 1 / 60

var controller_dtm = 11
var mouse_dtm = 999

var did_use_mouse = false

@onready var camera = $Camera

func _ready():
	camera_rotation = rotation_degrees # Initial rotation
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass

func _physics_process(delta):
	# Set position and rotation to targets
	
	self.position = self.position.lerp(target.position + (vertical_offset * Vector3.UP), delta * 4)
	
	if did_use_mouse:
		rotation_degrees = camera_rotation
	else:
		rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * controller_dtm)
	
	camera.position = camera.position.lerp(Vector3(0, 0, zoom), 8 * delta)
	
	handle_input(delta)

# Handle input

func handle_input(delta):
	# Rotation
	last_delta = delta
	var input := Vector3.ZERO
	
	input.y = -1 * Input.get_axis("camera_left", "camera_right")
	input.x = -1 * Input.get_axis("camera_up", "camera_down")
	
	if input.length_squared() > 0:
		did_use_mouse = false
	
	camera_rotation += input.limit_length(1.0) * rotation_speed * delta
	camera_rotation.x = clamp(camera_rotation.x, -80, -10)
	
	# Zooming
	
	zoom += Input.get_axis("zoom_in", "zoom_out") * zoom_speed * delta
	zoom = clamp(zoom, zoom_maximum, zoom_minimum)

func _input(event):
	if event is InputEventMouseMotion:
		# While dragging, move the sprite with the mouse.
		var input := Vector3.ZERO
		
		input.y = -1 * event.relative.x
		input.x = -1 * event.relative.y
		
		if input.length_squared() > 0:
			did_use_mouse = true
		
		camera_rotation += input * mouse_rotation_speed * last_delta
		camera_rotation.x = clamp(camera_rotation.x, -80, -10)
