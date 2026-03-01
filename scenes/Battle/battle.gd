extends Node2D

var battle_sprite_scene := preload("res://scenes/Battle/battle_sprite.tscn")

func _ready() -> void:
	battle_sprite_setup($StartPositions/Player, $BattleSprites/Player, true)
	battle_sprite_setup($StartPositions/Enemy, $BattleSprites/Enemy, false)

func battle_sprite_setup(start_positions: Node2D, parent: Node2D, is_player: bool) -> void:
	for start_position : Marker2D in start_positions.get_children():
		var pos := start_position.position
		create_battle_sprite(pos, parent, is_player)
		
func create_battle_sprite(pos: Vector2, parent: Node2D, is_player: bool) -> void:
	var battle_sprite := battle_sprite_scene.instantiate()
	battle_sprite.setup(pos, is_player)
	parent.add_child(battle_sprite)
	
