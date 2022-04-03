extends Spatial

signal enemy_timer_changed(time)
signal score_changed(score)
signal enemy_spawned()
signal game_start()
signal game_end()

export var player_height = 2
export var camera_distance = 2
export var angleInDeg = 45
var enemy_spawned = false
var game_started = false

func _ready():
	 print("Ready main")


func _on_Player_player_moved(old_position, new_position, old_rotation, new_rotation):
	var angle = deg2rad(angleInDeg)
	var offset = Vector3.ZERO
	offset.x = sin(angle) * camera_distance
	offset.y = cos(angle) * camera_distance
	#$Camera.look_at_from_position(new_position + offset, new_position + Vector3(0, player_height, 0), Vector3.UP)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



func _on_EnemySpawnTimer_timeout():
	$Enemy.init_enemy($Player, $Navigation)


func _on_Heartbeat_timeout():
	if enemy_spawned == false: 
		emit_signal("enemy_timer_changed", floor($EnemySpawnTimer.time_left))
	
