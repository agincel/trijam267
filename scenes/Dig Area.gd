extends Node3D

@export var NotificationArea: Area3D
@export var DigArea: Node3D

@export var MAX_DISTANCE = 5
@export var IN_RANGE_DISTANCE = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_notification_area_entered(body):
	if (body.has_method("register_dig_site")):
		body.register_dig_site(DigArea.global_position, self)

func _on_notification_area_exited(body):
	if (body.has_method("register_dig_site")):
		body.register_dig_site(Vector3.ZERO, null)
