extends Node

export var spawnAmount = 20
export (Array, PackedScene) var itemScenes
export (NodePath) var spawnPath
export (NodePath) var navigationPath

var nav: Navigation
var minBound = Vector2(-200, -200)
var maxBound = Vector2(200, 200)

func _ready():
	for i in range(0, spawnAmount-1):
		var rand = int(round(rand_range(0, itemScenes.size()-1)))
		var item = itemScenes[rand].instance()
		
		#var path = get_node(spawnPath)
		#path.unit_offset = randf()
		#item.translation = path.translation + Vector3(0, 1, 0)
		nav = get_node(navigationPath)
		var rX = rand_range(minBound.x, maxBound.x)
		var rZ = rand_range(minBound.y, maxBound.y)
		item.translation = nav.get_closest_point(Vector3(rX, 1, rZ))
		add_child(item)
