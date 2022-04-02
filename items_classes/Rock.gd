extends Node

func _ready():
	print("Rock Ready")

	# Called every frame. 'delta' is the elapsed time since the previous frame.
	#func _process(delta):
	#	pass


func _on_Area_body_entered(body):
	print("Body Entered Pickup")
	if body.is_in_group("player"):
		print("Body Touched")
