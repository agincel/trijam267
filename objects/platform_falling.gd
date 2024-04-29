extends Node3D

var falling := false
var gravity := 0.0

var starting_y

func _ready():
	starting_y = position.y

func _process(delta):
	scale = scale.lerp(Vector3(1, 1, 1), delta * 10) # Animate scale
	
	position.y -= gravity * delta
	
	if position.y < -40:
		position.y = starting_y
		falling = false
		gravity = 0
	
	if falling and gravity <= 15:
		gravity += 8 * delta


func _on_body_entered(_body):
	if !falling:
		Audio.play("res://sounds/fall.ogg") # Play sound
		scale = Vector3(1.25, 1, 1.25) # Animate scale
		
	falling = true
