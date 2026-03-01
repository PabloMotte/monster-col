extends Character

var interactable: Character

func _process(delta: float) -> void:
	get_input()
	if can_move:
		move()
		animate(delta)
		update_view_direction()
		check_interactable()


func get_input():
	if not Data.current_char:
		direction = Input.get_vector("left", "right", "up", "down")
		if Input.is_action_just_pressed("action") and interactable:
			Data.current_char = interactable
			Data.current_char.change_view(-get_char_direction(Data.current_char))
			Data.current_char.look_around = false
			Data.current_char.show_dialog()
	else:
		direction = Vector2.ZERO
		change_view(get_char_direction(Data.current_char))
		if Input.is_action_just_pressed("action"):
			Data.current_char.advance_dialog()
	
	if Input.is_action_just_pressed("ui_focus_next"):
		for trainer in get_tree().get_nodes_in_group('Trainers'):
			trainer.test_defeat()


func update_view_direction():
	if direction:
		var y = round(direction.y) if direction.x == 0 else 0
		view_direction = Vector2i(round(direction.x),y)
		$RayCast2D.target_position = view_direction * view_distance


func check_interactable():
	if $RayCast2D.collide_with_bodies:
		interactable = $RayCast2D.get_collider()


func stop():
	direction = Vector2.ZERO
	can_move = false
