extends Control

export (PackedScene) var ITEM_TEXTURE_RECT

var itemIdsToUIs = {}

func _ready():
	#Connect to inventory changed signal in singleton
	get_node("/root/ItemFactory").connect("inventory_changed", self, "_on_Inventory_Changed")
	
	print("UI Ready")
	for key in ItemFactory.inventory:
		var texRect = ITEM_TEXTURE_RECT.instance()
		var item = ItemFactory.inventory[key]
		itemIdsToUIs[key] = texRect
		texRect.name = item.name + "Slot"
		texRect.get_node("ItemCount").text = str(item.count)
		texRect.hint_tooltip = item.name
		$Inventory.add_child(texRect)
		
func _on_Inventory_Changed(item_id, new_count):
	itemIdsToUIs[item_id].get_node("ItemCount").text = str(new_count)


func _on_Main_enemy_timer_changed(time):
	$InGameUI/MonsterLabel.text = "You have %s seconds to prepare before the monster comes!" % time
