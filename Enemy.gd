extends KinematicBody

signal hit_player()

export var speed = 14 #m/s
export var gravity = 75 #m/s^2
export var player_height = 2
export var hit_distance = 3
export var escape_time = 2 * 1000
export var debug_mode = true
export (NodePath) var drawPath
export (PackedScene) var pulseScene
export (NodePath) var pulse_container
var velocity = Vector3.ZERO
var can_hit = true
var can_see_player = false
var can_pulse = true
var last_player_seen_time = 0

const STATE = {
	CHASE = 0,
	DOWN = 1, 
	PULSE = 2,
	IDLE = 3,
	PLAYER_DEAD = 4,
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
	print("Init enemy")
	navigation = nav
	player = plr
	#path_needs_refresh = true
	$NavigationRefreshTimer.start()
	#enemy_pulse(10, 30)
	
func enemy_pulse(live_time, radius):
	current_state = STATE.PULSE
	var pulse = pulseScene.instance()
	can_pulse = false
	pulse.translation = Vector3(0, 1, 0)
	get_node(pulse_container).add_child(pulse)
	pulse.connect("player_found", self, "_on_Pulse_PlayerFound")
	pulse.connect("pulse_finished", self, "_on_Pulse_Finished")
	pulse.start(live_time, radius, player)
	
	
var last_state = current_state
func _physics_process(delta):
	if current_state != last_state:
		last_state = current_state
		
		if current_state == STATE.CHASE:
			last_player_seen_time = OS.get_ticks_msec()
			$AnimationPlayer.play("RunningForward")
		elif current_state == STATE.IDLE:
			$AnimationPlayer.play("IdleBreathing")
		elif current_state == STATE.PULSE:
			$AnimationPlayer.play("Roaring")
			$AnimationPlayer.queue("PulseAnimation")
			$AnimationPlayer.queue("IdleBreathing")
			
	# Check if enemy hasn't seen player in x seconds, if 
	if current_state == STATE.CHASE and can_pulse:
		var space_state = get_world().direct_space_state
		
		var result = space_state.intersect_ray(to_global(translation) + Vector3(0, 5, 0), player.translation + Vector3(0, .5, 0), [player])
		
		if result.size() == 0:
			#print("Player Seen")
			last_player_seen_time = OS.get_ticks_msec()
		
		if OS.get_ticks_msec() - last_player_seen_time > escape_time:
			print("pulsing")
			current_state = STATE.PULSE
		
	
	if path_needs_refresh:
		current_path = navigation.get_simple_path(translation, player.translation)
		path_needs_refresh = false
		current_node = 0
		if debug_mode:
			draw_path(current_path)
		
	velocity.y -= gravity * delta
	
	var active_node = get_active_node()
	
	if current_state == STATE.CHASE and current_path.size() != 0:
		if can_hit and player.translation.distance_to(translation) < hit_distance:
			print("Player Hit")
			can_hit = false
			$HitRefreshTImer.start(4)
			emit_signal("hit_player")
		
		var dir = (active_node - translation).normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		
		var diff = Vector2(active_node.x - translation.x, active_node.y - translation.y)
		
		$LookAtCheat.look_at(active_node, Vector3.UP)
		$Pivot.rotation.y = $LookAtCheat.rotation.y
		#$Pivot.look_at(transform +, Vector3.UP)
	else:
		#print("In idle")
		velocity.x = 0
		velocity.z = 0

	velocity = move_and_slide(velocity, Vector3.UP)
	
func _on_PulseAnimationCallback():
	enemy_pulse(12, 75)

func get_active_node():
	if current_path.size() != 0 and current_state == STATE.CHASE:
		var active_node = current_path[current_node]
		if translation.distance_to(active_node) < node_increment_distance:
			if current_node + 1 == current_path.size():
				current_state = STATE.IDLE
				$IdleResetTImer.start(5)
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

func chase():
	current_state = STATE.CHASE
	path_needs_refresh = true

func idle():
	current_state = STATE.IDLE
		
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


func _on_HitRefreshTImer_timeout():
	can_hit = true

func _on_Main_game_end():
	current_state = STATE.PLAYER_DEAD

#func _on_IdleResetTImer_timeout():
	#if current_state != STATE.PLAYER_DEAD:	
		#path_needs_refresh = true
		#current_state = STATE.CHASE
		
func _on_IdleBreathing():
	print("IdleBreathing")

func _on_PulseTimer_timeout():
	can_pulse = true 

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "PulseAnimation":
		chase()
	elif anim_name == "GettingUp":
		chase()
	elif anim_name == "Hit1":
		chase()

func _on_Pulse_PlayerFound():
	current_state = STATE.CHASE
	
func _on_Pulse_Finished():
	$PulseTimer.start()
	
func _on_SharpStick_hit():
	current_state = STATE.DOWN
	$AnimationPlayer.play("Hit1")

func _on_ToadExplodeHit():
	current_state = STATE.DOWN
	$AnimationPlayer.play("KnockedOver")
	$AnimationPlayer.queue("GettingUp")
