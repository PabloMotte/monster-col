extends Character

@onready var player = get_tree().get_first_node_in_group('Player')
@export var stop_radius := 24
@export var look_around := true
@export var dialog: Array[String]
@export var defeat_dialog: Array[String]
var dialog_index: int
var defeated := false:
	set(value):
		defeated = value
		Data.char_data[unique_id]['defeated'] = value
var unique_id: String

func test_defeat():
	defeated = true
	


func get_player():
	return get_tree().get_first_node_in_group('Player')


func _enter_tree() -> void:
	unique_id = get_unique_id()
	if unique_id not in Data.char_data:
		Data.char_data[unique_id] = {'defeated': defeated}
	else:
		defeated = Data.char_data[unique_id]['defeated']


func get_unique_id() -> String:
	var current_scene_name = get_owner().scene_file_path.get_file().get_basename()
	var node_name = name
	return current_scene_name + "_" + node_name


func _process(delta: float) -> void:
	if $RayCast2D.get_collider() == get_player() and not Data.current_char and look_around:
		Data.current_char = self
		look_around = false
		$Timers/WalkWaitTimer.start()
	if direction:
		animate(delta)
		if position.distance_to(get_player().position) < stop_radius:
			direction = Vector2.ZERO
			$Sprite2D.frame_coords.x = 0
			show_dialog()
		move()


func _on_watch_timer_timeout() -> void:
	if look_around:
		view_direction = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN].pick_random()
		$Sprite2D.frame_coords.y = Data.character_view_directions[view_direction]
		$RayCast2D.target_position = view_direction * view_distance


func _on_walk_wait_timer_timeout() -> void:
	direction = get_char_direction(get_player())


func show_dialog():
	$DialogBox.set_text(dialog[0] if not defeated else defeat_dialog[0])
	$DialogBox.show()


func advance_dialog():
	var current_dialog = dialog if not defeated else defeat_dialog
	if dialog_index < current_dialog.size() - 1:
		dialog_index += 1
		$DialogBox.set_text(current_dialog[dialog_index])
	else:
		$DialogBox.hide()
		print('start battle')
		Data.current_char = null
		dialog_index = 0
