extends Node3D

@export var CoinTemplate: PackedScene
@export var NotificationArea: Area3D
@export var DigArea: Node3D

@export var MAX_DISTANCE = 5
@export var IN_RANGE_DISTANCE = 1
@export var COIN_SPAWN_DISTANCE = 1.4

var have_been_dug = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_notification_area_entered(body):
	if (not have_been_dug and body.has_method("register_dig_site")):
		body.register_dig_site(DigArea.global_position, self)

func _on_notification_area_exited(body):
	if (not have_been_dug and body.has_method("register_dig_site")):
		body.register_dig_site(Vector3.ZERO, null)

func dig_check(body, pos):
	print("dig check!")
	var dist = (pos - DigArea.global_position).length()
	print(dist)
	print(dist <= IN_RANGE_DISTANCE)
	if (dist <= IN_RANGE_DISTANCE):
		#they dug!
		#spawn four coins, one in each cardinal direction from the player
		print("They did it!")
		var coinOffsets = [
			Vector3(COIN_SPAWN_DISTANCE, 0.5, 0),
			Vector3(-COIN_SPAWN_DISTANCE, 0.5, 0),
			Vector3(0, 0.5, COIN_SPAWN_DISTANCE),
			Vector3(0, 0.5, -COIN_SPAWN_DISTANCE)
		]
		for offset in coinOffsets:
			var newCoin = CoinTemplate.instantiate()
			self.get_parent_node_3d().add_child(newCoin)
			newCoin.global_position = pos + offset
			
		have_been_dug = true
		body.register_dig_site(Vector3.ZERO, null)
		body.dig(0, false)
		Audio.play("res://sounds/cash_register.wav")
