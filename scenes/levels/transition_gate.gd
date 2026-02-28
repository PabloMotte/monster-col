extends Area2D

@export var target: Data.Location
@export var current: Data.Location
@export_enum("Left", "Right", "Up", "Down") var start_offset = "Up"
@export var distance : int = 30

func _on_body_entered(player: Character) -> void:
	#print("Player in %d", Time.get_ticks_msec())
	player.stop()
	# transition
	TransitionLayer.transition(target, current)

func _on_body_exited(_player: Character) -> void:
	#print("Player out %d", Time.get_ticks_msec())
	pass

func get_start_offset() -> Vector2:
	return {"Left": Vector2.LEFT, 
			"Right": Vector2.RIGHT, 
			"Up": Vector2.UP, 
			"Down": Vector2.DOWN}[start_offset] * distance
	
