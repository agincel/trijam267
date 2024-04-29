extends Node3D

@export var RobotHead: Node3D
@export var RobotDrillRoot: Node3D
@export var RobotDrillRotationRoot: Node3D
@export var AntennaRotationRoot: Node3D
@export var AntennaLight: OmniLight3D
@export var Character: CharacterBody3D

@export var HeadOffsetRatio = 0.12
@export var DrillTiltRatio = 0.82
@export var DrillRotationSpeed = -40
@export var DrillRotationSpeedDigging = -70
@export var AntennaRotationSpeedIdle = 5
@export var AntennaRotationSpeedMax = 25

var is_digging = false

var HeadStartingOffset := Vector3.ZERO
var DrillStartingOffset := Vector3.ZERO

const VEL_MAX = 3
var currentAntennaRotationSpeed = 10

var startColor
var current_dig_target := Vector3.ZERO
var current_dig_handler = null

# Called when the node enters the scene tree for the first time.
func _ready():
	HeadStartingOffset = RobotHead.global_position - self.global_position
	DrillStartingOffset = RobotDrillRoot.global_position - self.global_position
	currentAntennaRotationSpeed = AntennaRotationSpeedIdle
	startColor = AntennaLight.light_color
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	HandlePlayerTilt(delta)
	
	if (current_dig_handler != null):
		var distanceVector = current_dig_target - self.global_position
		var dist = distanceVector.length()
		
		if (dist <= current_dig_handler.IN_RANGE_DISTANCE):
			AntennaLight.light_color = Color.GREEN
		else:
			AntennaLight.light_color = startColor
			
		currentAntennaRotationSpeed = clampf(
			lerpf(
				AntennaRotationSpeedMax, 
				AntennaRotationSpeedIdle, 
				(dist - current_dig_handler.IN_RANGE_DISTANCE) / (current_dig_handler.MAX_DISTANCE - current_dig_handler.IN_RANGE_DISTANCE)
				), AntennaRotationSpeedIdle, AntennaRotationSpeedMax)

func HandlePlayerTilt(delta):
	var vel = Character.velocity
	vel.y = 0
	vel = vel.limit_length(VEL_MAX)
	
	RobotHead.global_position = RobotHead.global_position.lerp(self.global_position + HeadStartingOffset + (vel * HeadOffsetRatio), delta * 10)

	var drill_to_box = RobotDrillRoot.global_position.direction_to(RobotHead.global_position)
	drill_to_box.y = 0
	var drill_to_box_converted = Vector3(drill_to_box.z, 0, -1 * drill_to_box.x)
	# slowly changes the rotation to face the angle
	RobotDrillRoot.global_position = self.global_position + DrillStartingOffset
	RobotDrillRoot.global_rotation = RobotDrillRoot.global_rotation.slerp(drill_to_box_converted * DrillTiltRatio, .8)
	
	if not is_digging:
		RobotDrillRotationRoot.rotation += Vector3(0, DrillRotationSpeed * delta, 0)
	else:
		RobotDrillRotationRoot.rotation += Vector3(0, DrillRotationSpeedDigging * delta, 0)
	pass
	
	AntennaRotationRoot.rotation += Vector3(0, currentAntennaRotationSpeed * delta, 0)

func _on_player_dig_start():
	is_digging = true

func _on_player_dig_end():
	is_digging = false

func _on_player_dig_site_register(pos, handler):
	current_dig_target = pos
	current_dig_handler = handler
