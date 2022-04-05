extends Control

signal start_game_please()
signal restart_game_please()

export (PackedScene) var ITEM_TEXTURE_RECT

var itemIdsToUIs = {}
var craftables: Dictionary
var current_selected = -1
var current_selected_index = -1

var score = 0
var survied_time = 0

func _ready():
	#Connect to inventory changed signal in singleton
	get_node("/root/ItemFactory").connect("inventory_changed", self, "_on_Inventory_Changed")
	get_node("/root/ItemFactory").connect("item_added", self, "_on_Inventory_Added")
	
	print("UI Ready")
	for key in ItemFactory.inventory:
		var texRect = ITEM_TEXTURE_RECT.instance()
		var item = ItemFactory.inventory[key]
		if item.resource_location != null:
			var texture = load("res://art/ui/" + item.resource_location)
			texRect.texture = texture
		if item.crafting_materials == null:	
			# Base Items
			itemIdsToUIs[key] = texRect
			texRect.name = item.name + "Slot"
			texRect.get_node("ItemCount").text = str(item.count)
			texRect.hint_tooltip = item.name
			$Inventory.add_child(texRect)
		else:
			# Craftables
			itemIdsToUIs[key] = texRect
			craftables[key] = {"selected": texRect.get_node("Selected"), "id": key}
			texRect.name = item.name + "Slot"
			texRect.get_node("ItemCount").text = str(item.count)
			texRect.hint_tooltip = item.name
			texRect.get_node("Outline").hide()
			texRect.hide()
			$Craftables.add_child(texRect)
	
	#Remove this
	#_on_MainMenu_start_game_pressed()
	
func updateSelection():
	var visible_count = 0
	var visible: Dictionary
	var current_selected_deleted = false
	for key in craftables:
		if craftables[key].id == current_selected and !craftables[key].selected.get_parent().is_visible():
			current_selected_deleted = true
			
		if craftables[key].selected.get_parent().is_visible():
			visible[key] = craftables[key]
			visible_count += 1
	
	#print("Visible count %s" % visible_count)
	if visible_count == 0:
		current_selected = -1
		current_selected_index = -1
		for key in craftables:
			craftables[key].selected.hide()
	if visible_count == 1 and current_selected == -1:
		for key in visible:
			craftables[key].selected.show()
			current_selected = key
	if visible_count == 1:
		current_selected_index = 0
	if current_selected_deleted:
		if visible_count == 1:
			for key in visible:
				craftables[key].selected.show()
				current_selected = key
		elif visible_count > 1:
			for key in visible:
				craftables[key].selected.show()
				current_selected = key
				break
			
	
func _input(event):
	if Input.is_action_just_pressed("left_cycle_craftables"):
		var visible_count = 0
		var visible: Dictionary
		for key in craftables:
			if craftables[key].selected.get_parent().is_visible():
				visible[key] = craftables[key]
				visible_count += 1
		if visible_count > 1:
			$UINavSound.play()
			var old_selected = current_selected
			var old_index
			var i = 0
			for key in visible:
				if visible[key].id == old_selected:
					visible[key].selected.hide()
					old_index = i
					break
				i += 1
			var new_index = old_index
			if old_index == 0:
				new_index = visible.size() - 1
			else:
				new_index -= 1
			var j = 0
			for key in visible:
				if j == new_index:
					current_selected = key
				j += 1
			current_selected_index = new_index
			visible[current_selected].selected.show()
	if Input.is_action_just_pressed("right_cycle_craftables"):
		var visible_count = 0
		var visible: Dictionary
		for key in craftables:
			if craftables[key].selected.get_parent().is_visible():
				visible[key] = craftables[key]
				visible_count += 1
		if visible_count > 1:
			$UINavSound.play()
			var old_selected = current_selected
			var old_index
			var i = 0
			for key in visible:
				if visible[key].id == old_selected:
					visible[key].selected.hide()
					old_index = i
					break
				i += 1
			var new_index = old_index
			if old_index == visible.size() - 1:
				new_index = 0
			else:
				new_index += 1
			var j = 0
			for key in visible:
				if j == new_index:
					current_selected = key
				j += 1
			current_selected_index = new_index
			visible[current_selected].selected.show()
	if Input.is_action_just_pressed("craft_item") and current_selected != -1:
		var success = ItemFactory.tryToCraftItem(current_selected)
		if success:
			$CraftSound.play()
	if Input.is_action_just_released("use_item") and current_selected != -1:
		ItemFactory.useItem(current_selected)
	if Input.is_action_just_pressed("debug"):
		$StateLabel.visible = !$StateLabel.visible
		
		
func _on_Inventory_Changed(item_id, new_count):
	itemIdsToUIs[item_id].get_node("ItemCount").text = str(new_count)
	# Update craftables list w
	
	for key in ItemFactory.inventory:
		var item = ItemFactory.inventory[key]
		
		if item.crafting_materials != null and item.count == 0:
			var can_be_crafted = true
			for crafting_id in item.crafting_materials:
				var crafting_item = ItemFactory.getItemById(crafting_id)
				if crafting_item.count < 1:
					#print("Don't have " + crafting_item.name + " to make " + item.name)
					can_be_crafted = false
					#break
				
			if can_be_crafted:
				itemIdsToUIs[key].show()
			else:
				itemIdsToUIs[key].hide()
				itemIdsToUIs[key].get_node("Selected").hide()
	updateSelection()


func _on_Main_enemy_timer_changed(time):
	$InGameUI/MonsterLabel.text = "You have %s seconds to prepare before the monster comes!" % time


func _on_Main_enemy_spawned():
	$InGameUI/MonsterLabel.hide()
	$InGameUI/Score.show()
	$InGameUI/TimeSurvived.show()
	$InGameUI/Health.show()
	print("Enemy Spawned")
	$GameTimer.start(1)

func _on_Main_game_start(max_health):
	$InGameUI/Health.text = "Health: %s" % max_health
	$Inventory.show()
	$Craftables.show()

func _on_GameTimer_timeout():
	survied_time += 1
	$InGameUI/TimeSurvived.text = "Time Surived: %s" % survied_time


func _on_Main_game_end():
	$GameTimer.stop()
	$GameOver/TimeSurvived.text = "You surivied "+ str(survied_time) +" seconds and had a score of " + str(score) + " points."
	
	$Inventory.hide()
	$InGameUI.hide()
	$Craftables.hide()
	$GameOver.show()


func _on_Main_score_changed(new_score):
	score = new_score
	$InGameUI/Score.text = "Score: %s" % score


func _on_MainMenu_start_game_pressed():
	init_ui()
	emit_signal("start_game_please")

func init_ui():
	$MainMenu.hide()
	$Inventory.show()
	$Craftables.show()
	$InGameUI.show()
	$InGameUI/Score.show()
	$InGameUI/TimeSurvived.show()
	$InGameUI/Health.show()
	$InGameUI/MonsterLabel.show()
	survied_time = 0
	score = 0
	ItemFactory.emptyInventory()

func _on_Quit_pressed():
	get_tree().quit()


func _on_RestartButton_pressed():
	print("Restart")
	$GameOver.hide()
	init_ui()
	emit_signal("restart_game_please")

func _on_Main_player_damaged(new_health, max_health):
	$InGameUI/Health.text = "Health: "+ str(new_health)


func _on_Enemy_state_changed(new_state):
	$StateLabel.text = "Enemy State: %s" % new_state
	
func _on_Inventory_Added(ID):
	$ItemAddedSound.play()
