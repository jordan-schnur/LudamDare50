extends KinematicBody

signal player_moved(old_position, new_position, old_rotation, new_rotation)

export var speed = 14 #m/s
export var gravity = 75 #m/s^2
export var player_height = 2
export var camera_distance = 10
export var start_camera_angle = 45
export var mouse_sensitivity = 0.002
var velocity = Vector3.ZERO
var rotx = 0

func _ready():
	#var offset = (-new_rotation.normalized()) * camera_distance

	#var o = Vector3(camera_distance/2, camera_distance / 2, 2)
	rotx = deg2rad(start_camera_angle)
	var offset = Vector3.ZERO
	offset.z = sin(rotx) * camera_distance
	offset.y = cos(rotx) * camera_distance
	$CameraPivot/Camera.translation = offset
	$CameraPivot/Camera.look_at(translation + Vector3(0, player_height, 0), Vector3.UP)

func _unhandled_input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			$CameraPivot.rotate_y(-event.relative.x * mouse_sensitivity)
			
			var xOffset = (-event.relative.y * mouse_sensitivity)
			if rotx + xOffset > PI:
				rotx = PI - 0.0174533
			elif rotx + xOffset < 0:
				rotx = 0
			else:
				rotx += xOffset
			#$CameraPivot.rotation.x = rotx - $CameraPivot/Camera.rotation.x
			var offset = Vector3.ZERO
			offset.z = sin(rotx) * camera_distance
			offset.y = cos(rotx) * camera_distance
			$CameraPivot/Camera.translation = offset
			$CameraPivot/Camera.look_at(translation + Vector3(0, player_height, 0), Vector3.UP)
			
				


func _physics_process(delta):
	var old_pos = translation
	var old_rot = rotation
	
	var direction = Vector3.ZERO
	var is_moving = false
	if Input.is_action_pressed("move_forward"):
		direction.z += 1
	if Input.is_action_pressed("move_back"):
		direction.z -= 1
	if Input.is_action_pressed("strafe_left"):
		direction.x -= 1
	if Input.is_action_pressed("strafe_right"):
		direction.x += 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		is_moving = true

	var camera_rotation = $CameraPivot.rotation.y
	$Model.rotation.y = camera_rotation
	var vx = sin(camera_rotation + PI)
	var vz = cos(camera_rotation + PI)
	#camera_rotation.x = 0
	if is_moving:
		velocity.x = vx * speed
		velocity.z = vz * speed
	else:
		velocity.x = 0
		velocity.z = 0
	velocity.y -= gravity * delta
	
	var velocity2 = move_and_slide(velocity, Vector3.UP)
	emit_signal("player_moved", old_pos, translation, old_rot, rotation)
