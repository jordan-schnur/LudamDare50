extends KinematicBody
signal sharp_stick_hit()

var gravity = 9.8 #m/2
var is_active = false
var velocity = Vector3.ZERO
var speed = 10 #m/2

func _physics_process(delta):
	#var v = linear_velocity.normalized()
	#rotation.x = sin(v.y)
	if is_active:
		velocity.y -= gravity * delta
		rotation.x = sin(velocity.y * delta)
		translation += velocity * delta
		

func start_throw(dir):
	velocity = dir
	velocity.y = cos(PI/4)
	velocity = velocity.normalized() * speed
	rotation.x = PI/4
	is_active = true

func _on_Area_body_entered(body):
	if is_active:
		if body.is_in_group("enemy"):
			print("hit")
			is_active = false
			emit_signal("sharp_stick_hit")
			$DespawnTimer.start()
		elif body.is_in_group("map"):
			print("hit2")
			is_active = false
			$DespawnTimer.start()
		if !is_active:
			$AudioStreamPlayer3D.play()

func _on_DespawnTimer_timeout():
	print("Despawn")
	queue_free()
