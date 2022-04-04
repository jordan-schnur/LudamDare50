extends Control
signal start_game_pressed()


func _on_StartButton_pressed():
	emit_signal("start_game_pressed")


func _on_Quit_pressed():
	get_tree().quit()
