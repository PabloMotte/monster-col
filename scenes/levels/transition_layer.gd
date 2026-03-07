extends CanvasLayer

func _ready() -> void:
	$ColorRect.modulate.a = 0.0
	
	
func transition(target_loc: Data.Location, current_loc: Data.Location):
	$ColorRect.color = Color.BLACK
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 1.0, 0.8)
	tween.tween_interval(0.5)
	tween.tween_callback(_change_scene.bind(target_loc, current_loc))
	tween.tween_property($ColorRect, "modulate:a", 0.0, 0.8)
	
func _change_scene(target_loc: Data.Location, current_loc: Data.Location):
	if get_tree().current_scene:
		get_tree().current_scene.queue_free()
	var scene = load(Data.LEVEL_PATHS[target_loc]).instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	if target_loc != Data.Location.BATTLE:
		scene.player_start_position(current_loc)
		Data.current_loc = target_loc
	if current_loc == Data.Location.BATTLE:
		prints(Data.current_pos, Data.current_face_dir)
		scene.place_player_post_battle(Data.current_pos, Data.current_face_dir)


func white_screen(character: Character) -> void:
	$ColorRect.color = Color.WHITE
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 1.0, 0.8)
	tween.tween_callback(_heal_sound.bind(character))
	tween.tween_interval(0.5)
	tween.tween_callback(_heal_monsters.bind(character))
	tween.tween_property($ColorRect, "modulate:a", 0.0, 0.8)

func _heal_sound(character: Character) -> void:
	character.heal_sound()

func _heal_monsters(character: Character) -> void:
	for monster in Data.player_monsters:
		monster.heal()
	character.finish_dialog()
