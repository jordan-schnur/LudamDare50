extends Spatial

export var ROTATION_TIME = 30

func _ready():
	$AngleTween.interpolate_property(self, "rotation",
			Vector3(0, 0, 0), Vector3(0, 2 * PI, 0), ROTATION_TIME,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$AngleTween.start()
