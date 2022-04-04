extends RigidBody
signal sharp_stick_hit()

#func _physics_process(delta):
	#var v = linear_velocity.normalized()
	#rotation.x = sin(v.y)


func _on_Area_body_entered(body):
	if body.is_in_group("enemy"):
		sleeping = true
		emit_signal("sharp_stick_hit")
		$DespawnTimer.start()


func _on_DespawnTimer_timeout():
	queue_free()
