extends Node
signal inventory_changed(item_id, new_count)

const ITEM = {
	ROCK = 0,
	STICK = 1,
	TOAD = 2,
	VIAL = 3,
	RED_TEAR = 4,
	BLUE_TEAR = 5,
	YELLOW_TEAR = 6,
	GREEN_TEAR = 7,
	SPIDER_EYE = 8,
	WILLOW_BARK = 9,
}

var inventory: Dictionary

func _ready():
	print("ItemFactory Ready")
	createItem(ITEM.ROCK, "Rock", 0, null)
	createItem(ITEM.STICK, "Stick", 0, null)
	createItem(ITEM.TOAD, "Toad", 0, null)
	createItem(ITEM.VIAL, "Vial", 0, null)
	createItem(ITEM.RED_TEAR, "Red Tear", 0, null)
	createItem(ITEM.BLUE_TEAR, "Blue Tear", 0, null)
	createItem(ITEM.YELLOW_TEAR, "Yellow Tear", 0, null)
	createItem(ITEM.GREEN_TEAR, "Green Tear", 0, null)
	createItem(ITEM.SPIDER_EYE, "Spider Eye", 0, null)
	createItem(ITEM.WILLOW_BARK, "Willow Bark", 0, null)
	
# name of item, id of item, array of crafting material ids
func createItem(id, name, count, crafting_materials_ids):
	print("Creating " + str(name) + "("+ str(id) +")")
	inventory[id] = {
		"count": count,
		"crafting_materials": crafting_materials_ids,
		"id": id,
		"name": name, 
		}

func addItemToInventory(ID, count):
	inventory[ID].count += count
	emit_signal("inventory_changed", ID, inventory[ID].count)

func remoteItemFromInventory(ID, count):
	inventory[ID].count -= count
	emit_signal("inventory_changed", ID, inventory[ID].count)

func getItemById(ID):
	return inventory[ID]

func getNameById(ID):
	return inventory[ID].name
