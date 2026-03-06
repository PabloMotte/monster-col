extends Character

@export var stop_radius := 24
@export var dialog: Array[String]
@export var defeat_dialog: Array[String]
@export var monsters : Array[MonsterResource]
var defeated := false:
	set(newValue):
		defeated = newValue
		_save_trainer()

func test_defeat():
	defeated = true
	


func _enter_tree() -> void:
	super._enter_tree()
	if unique_id not in Data.char_data:
		_save_trainer()
	else:
		defeated = Data.char_data[unique_id]['defeated']
		monsters = Data.char_data[unique_id]['monsters']
		
func _ready() -> void:
	super._ready()
	if monsters.size():
		for monster : MonsterResource in monsters:
			monster.initialise()

func _save_trainer() -> void:
	Data.char_data[unique_id] = {'defeated': defeated,
								'monsters': monsters}


func _process(delta: float) -> void:
	if $RayCast2D.get_collider() == get_player() and not Data.current_char and look_around and not defeated:
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
		change_view(view_direction)

func _on_walk_wait_timer_timeout() -> void:
	direction = get_char_direction(get_player())


func show_dialog():
	$DialogBox.set_text(dialog[dialog_index] if not defeated else defeat_dialog[dialog_index])
	$DialogBox.show()


func advance_dialog():
	var current_dialog = dialog if not defeated else defeat_dialog
	if dialog_index < current_dialog.size() - 1:
		dialog_index += 1
		show_dialog()
	else:
		$DialogBox.hide()
		if defeated:
			get_player().can_move = true
		else:
			print('Battle!! Player vs. %s' % name)
			Data.current_pos = get_player().position
			Data.current_face_dir = get_player().view_direction
			Data.enemy_monsters = monsters.duplicate(true)
			Data.trainer_fight = true
			TransitionLayer.transition(Data.Location.BATTLE, Data.current_loc)
			Data.char_data[unique_id]['defeated'] = true
		dialog_index = 0
		Data.current_char = null
