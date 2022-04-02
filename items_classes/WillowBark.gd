extends KinematicBody

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		ItemFactory.addItemToInventory(ItemFactory.ITEM.WILLOW_BARK, 1)
		queue_free()
