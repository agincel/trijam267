extends Area3D
@export var JumpStrength = 30
@export var Model: Node3D

var startingScale

# Called when the node enters the scene tree for the first time.
func _ready():
	startingScale = Model.scale
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Model.scale = Model.scale.lerp(startingScale, delta * 10)
	pass

func _on_body_entered(body):
	if body.has_method("set_gravity"):
		Model.scale = Vector3(startingScale.x * 0.75, startingScale.y * 1.3, startingScale.z * 0.75)
		Audio.play("res://sounds/boing.wav") # Play sound
		body.set_gravity(-1 * JumpStrength)
	if body.has_method("restore_jumps"):
		body.restore_jumps()
