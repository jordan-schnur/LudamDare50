extends Node
signal item_added

class_name AbstractItem

var required_materials: Array
var item_name: String
var id: int

func _ready():
	print("AbstractItem Ready")
	print("Called")

func add_item(item):
	print("Adding item abstract: " + str(item))
