extends KinematicBody

export var speed = 14 #m/s
export var gravity = 75 #m/s^2
export var player_height = 2
export var debug_mode = true
export (NodePath) var drawPath
export (PackedScene) var pulseScene
var velocity = Vector3.ZERO

const STATE = {
	CHASE = 0,
	DOWN = 1, 
	PULSE = 2,
	IDLE = 3,
}

var current_state = STATE.IDLE
var navigation: Navigation
var player: KinematicBody

var current_node = 0
var current_path: PoolVector3Array
var path_needs_refresh = false
var node_increment_distance = 0.5 #meters

var m = SpatialMaterial.new()
var draw: ImmediateGeometry

func init_enemy(plr, nav):
	navigation = nav
	player = plr
	path_needs_refresh = true
	current_state = STATE.CHASE
	$NavigationRefreshTimer.start()
	enemy_pulse(10, 30)
	
func enemy_pulse(live_time, radius):
	var pulse = pulseScene.instance()
	add_child(pulse)
	pulse.start(live_time, radius)
	
func _physics_process(delta):
	if path_needs_refresh:
		#print("Refreshed")
		current_path = navigation.get_simple_path(translation, player.translation)
		print(current_path.size())
		path_needs_refresh = false
		current_node = 0
		if debug_mode:
			draw_path(current_path)
		
	velocity.y -= gravity * delta
	
	var active_node = get_active_node()
	
	if current_state == STATE.CHASE and current_path.size() != 0:
		var dir = (active_node - translation).normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		
		var diff = Vector2(active_node.x - translation.x, active_node.y - translation.y)
		
		$Pivot.rotation.y = atan(diff.y/dir.x)
		#$Pivot.look_at(transform +, Vector3.UP)
	else:
		#print("In idle")
		velocity.x = 0
		velocity.y = 0

	velocity = move_and_slide(velocity, Vector3.UP)
	


func get_active_node():
	if current_path.size() != 0 and current_state == STATE.CHASE:
		var active_node = current_path[current_node]
		if translation.distance_to(active_node) < node_increment_distance:
			if current_node + 1 == current_path.size():
				current_state = STATE.IDLE
				velocity.x = 0
				velocity.y = 0
				return active_node
			else: 
				current_node += 1
				#print("At node " + str(current_node-1) + ". Moving on to " + str(current_path[current_node]))
				return current_path[current_node]
		else:
			return active_node

func _on_NavigationRefreshTimer_timeout():
	if current_state == STATE.CHASE:
		path_needs_refresh = true

func pulse():
	print("Pulse")
	
		
func draw_path(path_array):
	var im = get_node(drawPath)
	im.set_material_override(m)
	im.clear()
	im.begin(Mesh.PRIMITIVE_POINTS, null)
	im.add_vertex(path_array[0])
	im.add_vertex(path_array[path_array.size() - 1])
	im.end()
	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for x in current_path:
		im.add_vertex(x)
	im.end()
