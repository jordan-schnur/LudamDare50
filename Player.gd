extends KinematicBody

signal player_moved(old_position, new_position, old_rotation, new_rotation)
signal player_forward()
signal player_backward()
signal strafe_right()
signal strafe_left()
signal movement_stopped()
signal health_changed(new_health)
signal player_died()
signal start_enemy_pulse()

export var speed = 14 #m/s
export var gravity = 75 #m/s^2
export var player_height = 2
export var camera_distance = 10
export var start_camera_angle = 45
export var mouse_sensitivity = 0.002
export var max_health = 1
export (NodePath) var throwable_container
export (NodePath) var enemy
export (Array, PackedScene) var throwables
var health = max_health
var velocity = Vector3.ZERO
var rotx = 0
var has_camera_control = false
var throwable_map = {}
var default_speed = speed

func _ready():
	#var offset = (-new_rotation.normalized()) * camera_distance

	#var o = Vector3(camera_distance/2, camera_distance / 2, 2)
	rotx = deg2rad(start_camera_angle)
	var offset = Vector3.ZERO
	offset.z = sin(rotx) * camera_distance
	offset.y = cos(rotx) * camera_distance
	$CameraPivot/Camera.translation = offset
	$CameraPivot/Camera.look_at(translation + Vector3(0, player_height, 0), Vector3.UP)
	ItemFactory.connect("item_used", self, "_on_ItemFactor_ItemUsed")
	
	throwable_map = {
		ItemFactory.ITEM.POINTY_STICK: throwables[0],
		ItemFactory.ITEM.EXPLODER_TOAD: throwables[1]
		}

func _input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and has_camera_control:
		if event is InputEventMouseMotion:
			$CameraPivot.rotate_y(-event.relative.x * mouse_sensitivity)
			
			var xOffset = (-event.relative.y * mouse_sensitivity)
			if rotx + xOffset > PI/2:
				rotx = PI/2
			elif rotx + xOffset < PI/6:
				rotx = PI/6
			else:
				rotx += xOffset
			#$CameraPivot.rotation.x = rotx - $CameraPivot/Camera.rotation.x
			var offset = Vector3.ZERO
			offset.z = sin(rotx) * camera_distance
			offset.y = cos(rotx) * camera_distance
			$CameraPivot/Camera.translation = offset
			$CameraPivot/Camera.look_at(translation + Vector3(0, player_height, 0), Vector3.UP)

var throwable_multiplier = 1
func _physics_process(delta):
	var old_pos = translation
	var old_rot = rotation
	
	var direction = Vector3.ZERO
	var offset = 0
	var is_moving = false
	
	if has_camera_control:
		if Input.is_action_pressed("strafe_left"):
			direction.x -= 1
			offset = PI / 2
			throwable_multiplier = 1
			emit_signal("strafe_left")
		elif Input.is_action_pressed("strafe_right"):
			direction.x += 1
			offset = -PI / 2
			throwable_multiplier = 1
			emit_signal("strafe_right")
		elif Input.is_action_pressed("move_forward"):
			direction.z += 1
			throwable_multiplier = 1
			emit_signal("player_forward")
		elif Input.is_action_pressed("move_back"):
			throwable_multiplier = -1
			direction.z -= 1
			offset = -PI
			emit_signal("player_backward")
		
		if direction != Vector3.ZERO:
			direction = direction.normalized()
			is_moving = true
		
	
		var camera_rotation = $CameraPivot.rotation.y
		$Pivot.rotation.y = camera_rotation
		var vx = sin(camera_rotation + PI + offset)
		var vz = cos(camera_rotation + PI + offset)
		#camera_rotation.x = 0
		if is_moving:
			velocity.x = vx * speed
			velocity.z = vz * speed
			if !$RunningSound.playing:
				$RunningSound.play()
		else:
			if $RunningSound.playing:
				$RunningSound.stop()
			emit_signal("movement_stopped")
			velocity.x = 0
			velocity.z = 0
	else:
		emit_signal("movement_stopped")
		velocity.x = 0
		velocity.z = 0
	velocity.y -= gravity * delta
	
	var velocity2 = move_and_slide(velocity, Vector3.UP)
	emit_signal("player_moved", old_pos, translation, old_rot, rotation)


func _on_Player_player_backward():
	pass # Replace with function body.


func _on_Enemy_hit_player():
	health -= 1
	if health <= 0:
		emit_signal("player_died")
	emit_signal("health_changed", health)


func _on_Main_game_start():
	$CameraPivot/Camera.make_current()
	has_camera_control = true
	
func _on_ItemFactor_ItemUsed(ID):
	for key in throwable_map:
		if (key == ID):
			
			var instance = throwable_map[key].instance()
			
			if ID == ItemFactory.ITEM.POINTY_STICK:
				instance.translation = translation + Vector3(0, 1, 0)
				#instance.rotate_z((7 * PI) / 4)
				instance.rotate_y($CameraPivot.rotation.y)
				get_node(throwable_container).add_child(instance)
				var camera_rotation = $CameraPivot.rotation.y
				$Pivot.rotation.y = camera_rotation
				
					
				var vx = sin(camera_rotation + PI)
				var vz = cos(camera_rotation + PI)
				
				var impulse = 6
				instance.connect("sharp_stick_hit", get_node(enemy), "_on_SharpStick_hit")
				instance.start_throw(Vector3(vx, 0, vz))
				$ThrowSound.play()
				#TODO: Add curve path, add impuse when running
				#instance.apply_central_impulse(Vector3(vx * impulse, impulse, vz * impulse))
			elif ID == ItemFactory.ITEM.EXPLODER_TOAD:
				instance.translation = translation + Vector3(0, 1, 0)
				#instance.rotate_z((7 * PI) / 4)
				instance.rotate_y($CameraPivot.rotation.y)
				get_node(throwable_container).add_child(instance)
				var camera_rotation = $CameraPivot.rotation.y
				$Pivot.rotation.y = camera_rotation
				var vx = sin(camera_rotation + PI)
				var vz = cos(camera_rotation + PI)
				var impulse = 6
				instance.connect("explode_toad_hit_enemy", get_node(enemy), "_on_ToadExplodeHit")
				instance.connect("explode_toad_hit_player", self, "_on_ToadExplodeHit")
				#TODO: Add curve path, add impuse when running
				instance.apply_central_impulse(Vector3(vx * impulse, impulse, vz * impulse))
				$ThrowSound.play()
			break
	if ID == ItemFactory.ITEM.RED_VIAL:
		health += 1
		emit_signal("health_changed", health)
		$DrinkSound.play()
	elif ID == ItemFactory.ITEM.GREEN_VIAL:
		speed = default_speed*1.3
		$SpeedBoostTimer.start()
		$DrinkSound.play()
	elif ID == ItemFactory.ITEM.BLUE_VIAL:
		print("Blue Vial")
		emit_signal("start_enemy_pulse")
		$DrinkSound.play()


func _on_Main_game_end():
	has_camera_control = false
	
func _on_ToadExplodeHit(): 
	print("Boom")
	_on_Enemy_hit_player()


func _on_SpeedBoostTimer_timeout():
	print("Timeout")
	speed = default_speed
