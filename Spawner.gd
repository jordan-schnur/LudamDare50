extends Node

export var spawnAmount = 20
export (Array, PackedScene) var itemScenes
export (NodePath) var spawnPath

func _ready():
	for i in range(0, spawnAmount-1):
		var rand = int(round(rand_range(0, itemScenes.size())))
		var item = itemScenes[rand].instance()
		
		var path = get_node(spawnPath)
		path.unit_offset = randf()
		item.translation = path.translation + Vector3(0, 1, 0)
		add_child(item)
