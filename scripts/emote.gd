extends Node2D

@export var type:int = 0
@export var ownerName:String = "PLAYER"

signal on_clear(e1: Node2D, e2: Node2D)

func _ready():
	$RigidBody2D.contact_monitor = false
	_apply_type()
	$ContactTimer.start()	
	
func set_type(new_type:int):
	type = new_type
	_apply_type()
	
func _apply_type():
	$RigidBody2D/EmoteSprite.play(str(type))
	var bodyScale = (type+3)*0.17
	$RigidBody2D/EmoteSprite.scale = Vector2(bodyScale, bodyScale)
	$RigidBody2D/CollisionShape2D.scale = Vector2(bodyScale, bodyScale)

func _on_body_entered(body: RigidBody2D):
	if(type != 9 && type == body.get_parent().type):
		on_clear.emit(self, body.get_parent())
		
func _on_any_body_entered(body: Node):
	var collision_force = Vector2.ZERO
	if(is_instance_of(body, RigidBody2D)):
		collision_force = body.linear_velocity-$RigidBody2D.linear_velocity
	else:
		collision_force = $RigidBody2D.linear_velocity
	var force_module = abs(collision_force)
	var force = force_module.x+force_module.y
	if(force > 50):
		var volume = mini(-80+(force/10),0)
		$TouchAudio.volume_db = volume
		$TouchAudio.play()

func _on_contact_timer_timeout():
	$RigidBody2D.contact_monitor = true
