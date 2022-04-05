extends KinematicBody

export var full_rotation_time = 3 #rad/sec
export var bob_height = .2 # +-
export var item_id: int
var pivot
var elapsed_time = 0

class_name ItemPickupBase

func _ready():
	assert(item_id != null && get_node("Area") != null && get_node("Pivot") != null)
	pivot = get_node("Pivot")
	get_node("Area").connect("body_entered", self, "_on_Area_body_entered")

func _physics_process(delta):
	elapsed_time += delta
	pivot.translation.y = sin(elapsed_time) * bob_height
	pivot.rotation.y = (elapsed_time / full_rotation_time) * 2 * PI
	
func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		ItemFactory.addItemToInventory(item_id, 1)
		queue_free()
