extends Node3D

@export var RobotHead: Node3D
@export var RobotDrillRoot: Node3D
@export var Character: CharacterBody3D

@export var HeadOffsetRatio = 0.5
@export var DrillTiltRatio = 15

var HeadStartingOffset := Vector3.ZERO
var DrillStartingOffset := Vector3.ZERO

const VEL_MAX = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	HeadStartingOffset = self.global_position - RobotHead.global_position
	DrillStartingOffset = self.global_position - RobotDrillRoot.global_position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var vel = Character.velocity
	vel.y = 0
	vel = vel.limit_length(VEL_MAX)
	
	RobotHead.global_position = self.global_position + HeadStartingOffset + (vel * HeadOffsetRatio)
	RobotDrillRoot.global_rotation = Vector3(vel.z * DrillTiltRatio, 0, vel.x * DrillTiltRatio * -1)
	pass
