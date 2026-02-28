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
	if not Data.current_character:
		direction = Input.get_vector("left", "right", "up", "down")
		if Input.is_action_just_pressed("action") and interactable:
			Data.current_character = interactable
			Data.current_character.change_view(-get_char_direction(Data.current_character))
			Data.current_character.look_around = false
			Data.current_character.show_dialog()
	else:
		direction = Vector2.ZERO
		change_view(get_char_direction(Data.current_character))
		if Input.is_action_just_pressed("action"):
			Data.current_character.advance_dialog()

func update_view_direction():
	if direction:
		var y := roundi(direction.y) if direction.x == 0 else 0
		view_direction = Vector2i(roundi(direction.x), y)
		$RayCast2D.target_position = view_direction * view_distance
		
func check_interactable():
	if $RayCast2D.collide_with_bodies:
		interactable = $RayCast2D.get_collider()

func stop() -> void:
	direction = Vector2.ZERO
	can_move = false
	
