extends Spatial

signal enemy_timer_changed(time)
signal score_changed(score)
signal enemy_spawned()
signal game_start()
signal game_end()
signal player_damaged(new_health, max_health)

export var player_height = 2
export var camera_distance = 2
export var angleInDeg = 45
var enemy_spawned = false
var game_started = false
var score = 0
var enemy_start_spawn = Vector3(0, 3, 11)

func _ready():
	print("Ready main")
	
	$StartingCameraPivot/Camera.make_current()
	#enemy_start_spawn = to_global($Enemy.translation)


func _on_Player_player_moved(old_position, new_position, old_rotation, new_rotation):
	var angle = deg2rad(angleInDeg)
	var offset = Vector3.ZERO
	offset.x = sin(angle) * camera_distance
	offset.y = cos(angle) * camera_distance
	#$Camera.look_at_from_position(new_position + offset, new_position + Vector3(0, player_height, 0), Vector3.UP)

func _input(event):
	if $Player.has_camera_control:
		if event.is_action_pressed("ui_accept"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if event.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_EnemySpawnTimer_timeout():
	emit_signal("enemy_spawned")
	enemy_spawned = true
	$Enemy.translation = enemy_start_spawn
	$Enemy.chase()


func _on_Heartbeat_timeout():
	if enemy_spawned == false: 
		emit_signal("enemy_timer_changed", floor($EnemySpawnTimer.time_left))
	else:
		score += 1
		emit_signal("score_changed", score)

func _on_Control_start_game_please():
	emit_signal("game_start")
	init_game()

func _on_Control_restart_game_please():
	emit_signal("game_start")
	init_game()

func PickRandomPlayerPosition():
	randomize()
	return $PlayerSpawnLocations.get_child(rand_range(0, $PlayerSpawnLocations.get_child_count()-1)).translation + Vector3(0, 2, 0)
		
	
func init_game():
	$Enemy.translation = enemy_start_spawn
	$Enemy.show()
	var playerSpawn = PickRandomPlayerPosition()
	$Player.translation = playerSpawn
	enemy_spawned = false
	$Player.has_camera_control = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Enemy.init_enemy($Player, $Navigation)
	score = 0
	$EnemySpawnTimer.start()
	_on_Player_health_changed($Player.max_health)

func _on_Player_health_changed(new_health):
	emit_signal("player_damaged", new_health, $Player.max_health)

func _on_Player_player_died():
	$Enemy.current_state = $Enemy.STATE.PLAYER_DEAD
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	enemy_spawned = false
	$StartingCameraPivot/Camera.make_current()
	emit_signal("game_end")
