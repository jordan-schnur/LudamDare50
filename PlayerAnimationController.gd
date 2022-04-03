extends Spatial

var is_playing = false
const DIRS = {
	FOWARD = "Running",
	BACKWARD = "RunningBackwards",
	LEFT = "RunningLeft",
	RIGHT = "RunningRight",
}
var currently_playing

func update_animation(animation):
	if !is_playing or currently_playing != animation:
		is_playing = true
		currently_playing = animation
		$Armature/AnimationPlayer.play(animation)
		$Armature/AnimationPlayer.get_animation(animation).loop = true

func _on_Player_strafe_right():
	update_animation(DIRS.RIGHT)

func _on_Player_strafe_left():
	update_animation(DIRS.LEFT)


func _on_Player_player_forward():
	update_animation(DIRS.FOWARD)

func _on_Player_player_backward():
	update_animation(DIRS.BACKWARD)


func _on_Player_movement_stopped():
	if is_playing:
		is_playing = false
		currently_playing = null
		$Armature/AnimationPlayer.stop()
