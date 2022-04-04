extends RigidBody
signal explode_toad_hit_enemy()
signal explode_toad_hit_player()

#func _physics_process(delta):
	#var v = linear_velocity.normalized()
	#rotation.x = sin(v.y)


#func _on_Area_body_entered(body):
	#if body.is_in_group("enemy"):
	#	print("hit Enemy")
	#	sleeping = true
	#	emit_signal("sharp_stick_hit")
	#elif body.is_in


func _on_ExplodeToadThrowable_body_entered(body):
	if body.is_in_group("navmesh") or body.is_in_group("enemy"):
		$DespawnTimer.start()
		$CPUParticles.emitting = true
		for b in $Area.get_overlapping_bodies():
			if b.is_in_group("enemy"):
				emit_signal("explode_toad_hit_enemy")
			elif b.is_in_group("player"):
				emit_signal("explode_toad_hit_player")
			


func _on_DespawnTimer_timeout():
	queue_free()
