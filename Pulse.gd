extends Spatial

export var pulse_live_time = 5
export var pulse_radius = 20

func start(live_time, radius):
	pulse_live_time = live_time
	pulse_radius = radius
	var tween = get_node("Tween")
	tween.interpolate_property($MeshInstance, "scale",
			Vector3(0, $MeshInstance.scale.y, 0), Vector3(pulse_radius, $MeshInstance.scale.y, pulse_radius), pulse_live_time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	$PulseTimer.start(pulse_live_time)

func _on_PulseTimer_timeout():
	queue_free()
