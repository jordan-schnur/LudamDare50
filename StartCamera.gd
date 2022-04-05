extends Camera

var nav: Navigation
var minBound = Vector2(-200, -200)
var maxBound = Vector2(200, 200)
var current_node = 0
var current_path: PoolVector3Array
var node_increment_distance = .75
var speed = .1

func _ready():
	randomize()

func _get_new_path():
	var rX = rand_range(minBound.x, maxBound.x)
	var rZ = rand_range(minBound.y, maxBound.y)
	var end_point = nav.get_closest_point(Vector3(rX, 1, rZ))
	
	current_path = nav.get_simple_path(translation, end_point, true)
	
func get_active_node():
	if current_path.size() != 0:
		var active_node = current_path[current_node]
		if translation.distance_to(active_node) < node_increment_distance:
			if current_node + 1 == current_path.size():
				_get_new_path()
				print("new path")
				return active_node
			else: 
				current_node += 1
				#print("At node " + str(current_node-1) + ". Moving on to " + str(current_path[current_node]))
				return current_path[current_node]
		else:
			return active_node
			
var frames = 0
var last_tween_time = OS.get_ticks_msec()
var last_rotation = Vector3.ZERO
var sample_time = 1000 #ms
var test = 0

func _physics_process(delta):
	var active_node = get_active_node()
	if (OS.get_ticks_msec()-last_tween_time > sample_time):
		var tween = get_node("AngleTween")
		tween.interpolate_property(self, "rotation",
				last_rotation, Vector3(0,get_node("../Spatial").rotation.y, 0), sample_time/1000.0,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		last_rotation = Vector3(0,get_node("../Spatial").rotation.y, 0)
		last_tween_time = OS.get_ticks_msec()
		print(rad2deg(translation.signed_angle_to(active_node, Vector3(0, 1, 0))))
		
		var a = rad2deg(translation.signed_angle_to(active_node, Vector3(0, 1, 0)))
		
		if (a < 0):
			print("Turn right")
		else:
			print("turn left")
		test = 0

	
	if current_path.size() != 0:
		var direction = translation.direction_to(active_node)
		var last_angle = get_node("../Spatial").rotation
		get_node("../Spatial").look_at_from_position(translation, translation + direction * speed, Vector3.UP)
		test += get_node("../Spatial").rotation.y-last_angle.y
		#print(get_node("../Spatial").rotation.y-last_angle.y)
		
		
		#rotation = Vector3(0,get_node("../Spatial").rotation.y, 0)
		translation += direction * speed
	else:
		print("Path bad")

func _start_camera():
	nav = get_node("../../Navigation")
	_get_new_path()
