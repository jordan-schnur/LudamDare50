extends Spatial
signal pulse_finished()
signal pulse_started()
signal player_found()

export var pulse_live_time = 5
export var pulse_radius = 20
var player: KinematicBody
var player_found = false

func start(live_time, radius, plr):
	player = plr
	pulse_live_time = live_time
	pulse_radius = radius
	var tween = get_node("TweenShape")
	tween.interpolate_property($MeshInstance, "scale",
			Vector3(0, $MeshInstance.scale.y, 0), Vector3(pulse_radius, $MeshInstance.scale.y, pulse_radius), pulse_live_time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	$CPUParticles.emitting = true
	emit_signal("pulse_started")

func _physics_process(delta):
	if !player_found:
		if to_global(translation).distance_to(player.translation) <= $MeshInstance.scale.x:
			emit_signal("player_found")
			player_found = true
			$PulseTimer.start(rand_range(2, 4))

func _on_PulseTimer_timeout():
	emit_signal("pulse_finished")
	queue_free()


func _on_TweenShape_tween_completed(object, key):
	queue_free()
