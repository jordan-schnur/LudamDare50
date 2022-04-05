extends CPUParticles

func start_me():
	var translation2 = to_global(translation)
	var root = get_tree().root
	var main_scene = root.get_child(root.get_child_count() - 1)
	get_parent().remove_child(self)
	main_scene.add_child(self)
	self.set_owner(main_scene)
	self.emitting = true
	self.translation = translation2
