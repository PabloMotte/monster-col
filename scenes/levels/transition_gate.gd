extends Area2D

@export var target: Data.Location
@export var current: Data.Location
@export_enum("Up", "Down", "Left", "Right") var start_offset = "Up"
@export var distance := 30

func _on_body_entered(player: Character) -> void:
	player.stop()
	TransitionLayer.transition(target, current)


func get_start_offset() -> Vector2:
	return {
		"Up": Vector2.UP, 
		"Down":Vector2.DOWN, 
		"Right":Vector2.RIGHT, 
		"Left":Vector2.LEFT
		}[start_offset] * distance
