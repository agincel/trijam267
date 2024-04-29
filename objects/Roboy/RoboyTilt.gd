extends Node3D

@export var RobotHead: Node3D
@export var RobotDrillRoot: Node3D
@export var RobotDrillRotationRoot: Node3D
@export var Character: CharacterBody3D

@export var HeadOffsetRatio = 0.12
@export var DrillTiltRatio = 0.82
@export var DrillRotationSpeed = -40

var HeadStartingOffset := Vector3.ZERO
var DrillStartingOffset := Vector3.ZERO

const VEL_MAX = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	HeadStartingOffset = RobotHead.global_position - self.global_position
	DrillStartingOffset = RobotDrillRoot.global_position - self.global_position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	
	RobotDrillRotationRoot.rotation += Vector3(0, DrillRotationSpeed * delta, 0)
	pass
