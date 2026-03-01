extends CanvasLayer

func _ready() -> void:
	$ColorRect.modulate.a = 0.0
	
	
func transition(target_loc: Data.Location, current_loc: Data.Location):
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
	scene.player_start_position(current_loc)
	Data.current_loc = target_loc
