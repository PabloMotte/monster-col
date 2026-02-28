extends Character

@export var stop_radius := 24
@export var look_around := true
@export var dialog: Array[String]
@export var defeat_dialog: Array[String]
@onready var player : Character = get_tree().get_first_node_in_group("Player")
var dialog_index: int = 0
var defeated := false

	
func _process(delta: float) -> void:
	if $RayCast2D.get_collider() == player and not Data.current_character and look_around:
		Data.current_character = self
		look_around = false
		$Timers/WalkWaitTimer.start()
	if direction:
		animate(delta)
		if position.distance_to(player.position) < stop_radius:
			direction = Vector2.ZERO
			$Sprite2D.frame_coords.x = 0
			$Timers/WalkWaitTimer.stop()
			show_dialog()
		move()

func _on_watch_timer_timeout() -> void:
	if look_around:
		view_direction = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN].pick_random()
		$Sprite2D.frame_coords.y = Data.character_view_directions[view_direction]
		$RayCast2D.target_position = view_direction * view_distance


func _on_walk_wait_timer_timeout() -> void:
	if Data.current_character == self:
		direction = get_char_direction(player)

func show_dialog() -> void:
	var current_dialog = defeat_dialog if defeated else dialog
	$DialogBox.set_text(current_dialog[dialog_index])
	$DialogBox.show()
	
func advance_dialog() -> void:
	var current_dialog = defeat_dialog if defeated else dialog
	if dialog_index < current_dialog.size()-1:
		dialog_index += 1
		show_dialog()
	else:
		$DialogBox.hide()
		if !defeated:
			print("BATTLE!!")
			defeated = true
		Data.current_character = null
		dialog_index = 0
