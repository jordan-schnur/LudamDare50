extends Node

export var spawnAmount = 20
export (Array, PackedScene) var itemScenes

func _ready():
	var totalItems = itemScenes.size()
	for i in range(0, spawnAmount):
		print(i)
