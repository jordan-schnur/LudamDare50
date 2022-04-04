extends Node
signal inventory_changed(item_id, new_count)
signal item_used(item_id)

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
	POINTY_STICK = 10,
	RED_VIAL = 11,
	BLUE_VIAL = 12,
	GREEN_VIAL = 13,
	YELLOW_VIAL = 14,
	EXPLODER_TOAD = 15,
}

var inventory: Dictionary
var craftables: Dictionary

func _ready():
	print("ItemFactory Ready")
	createItem(ITEM.ROCK, "Rock", 0, null, null)
	createItem(ITEM.STICK, "Stick", 0, null, "Sticks.png")
	createItem(ITEM.TOAD, "Toad", 0, null, "ToadBasic.png")
	createItem(ITEM.VIAL, "Vial", 0, null, "VialEmpty.png")
	createItem(ITEM.RED_TEAR, "Red Tear", 0, null, "TearRed.png")
	createItem(ITEM.BLUE_TEAR, "Blue Tear", 0, null, "TearBlue.png")
	createItem(ITEM.YELLOW_TEAR, "Yellow Tear", 0, null, "TearYellow.png")
	createItem(ITEM.GREEN_TEAR, "Green Tear", 0, null, "TearGreen.png")
	#createItem(ITEM.SPIDER_EYE, "Spider Eye", 0, null)
	#createItem(ITEM.WILLOW_BARK, "Willow Bark", 0, null)
	createItem(ITEM.POINTY_STICK, "Pointy Stick", 0, [ITEM.ROCK, ITEM.STICK], "SharpStick.png")
	createItem(ITEM.RED_VIAL, "Red Vial", 0, [ITEM.VIAL, ITEM.RED_TEAR], "VialRed.png") # Give more health
	createItem(ITEM.BLUE_VIAL, "Blue Vial", 0, [ITEM.VIAL, ITEM.BLUE_TEAR], "VialBlue.png") #StartPulse
	createItem(ITEM.GREEN_VIAL, "Green Vial", 0, [ITEM.VIAL, ITEM.GREEN_TEAR], "VialGreen.png") #Green makes you faster
	createItem(ITEM.EXPLODER_TOAD, "Exploder Toad", 0, [ITEM.TOAD, ITEM.YELLOW_TEAR], "ToadExplode.png")
	
	
# name of item, id of item, array of crafting material ids
func createItem(id, name, count, crafting_materials_ids, resource_location):
	#print("Creating " + str(name) + "("+ str(id) +")")
	inventory[id] = {
		"count": count,
		"crafting_materials": crafting_materials_ids,
		"id": id,
		"name": name, 
		"resource_location": resource_location
		}
	if crafting_materials_ids != null:
		craftables[id] = inventory[id]

func addItemToInventory(ID, count):
	inventory[ID].count += count
	emit_signal("inventory_changed", ID, inventory[ID].count)

func remoteItemFromInventory(ID, count):
	inventory[ID].count -= count
	emit_signal("inventory_changed", ID, inventory[ID].count)
	
func emptyInventory():
	for key in inventory:
		ItemFactory.inventory[key].count = 10
		emit_signal("inventory_changed", inventory[key].id, ItemFactory.inventory[key].count)
		
func tryToCraftItem(ID):
	var item = inventory[ID]
	if item.crafting_materials != null:
		var can_craft = true
		for crafting_id in item.crafting_materials:
			var crafting_item = getItemById(crafting_id)
			if crafting_item.count < 1: 
				can_craft = false
				break
		if can_craft:
			item.count += 1
			emit_signal("inventory_changed", ID, item.count)
			for crafting_id in item.crafting_materials:
				var crafting_item = getItemById(crafting_id)
				crafting_item.count -= 1
				emit_signal("inventory_changed", crafting_item.id, crafting_item.count)
			return true
	return false
	

func useItem(ID):
	var item = inventory[ID]
	if item.crafting_materials != null and item.count > 0:
		item.count -= 1
		#TODO: Add signal to cause effect
		emit_signal("inventory_changed", ID, item.count)
		emit_signal("item_used", ID)

func getItemById(ID):
	return inventory[ID]

func getNameById(ID):
	return inventory[ID].name
