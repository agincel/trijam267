extends Area3D
@export var JumpStrength = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if body.has_method("set_gravity"):
		body.set_gravity(-1 * JumpStrength)
	if body.has_method("restore_jumps"):
		body.restore_jumps()
