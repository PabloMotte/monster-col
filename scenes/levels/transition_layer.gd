extends CanvasLayer

func _ready() -> void:
	$ColorRect.modulate.a = 0.0

func transition(target_location: Data.Location, current_location: Data.Location) -> void:
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 1.0, 0.8)
	tween.tween_interval(0.5)
	tween.tween_callback(_change_scene.bind(target_location, current_location))
	tween.tween_property($ColorRect, "modulate:a", 0.0, 0.8)
	
func _change_scene(target_location: Data.Location, current_location:Data.Location) -> void:
	if get_tree().current_scene:
		get_tree().current_scene.queue_free()
	var scene = load(Data.LEVEL_PATHS[target_location]).instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	scene.player_start_pos(current_location)
	Data.current_location = target_location
