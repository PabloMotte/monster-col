extends Node2D

func _ready() -> void:
	# tileset animation
	var tileset = $BG/Floor.tile_set as TileSet
	var atlas_source = tileset.get_source(2) as TileSetAtlasSource
	for y in atlas_source.get_atlas_grid_size().y:
		for x in int(atlas_source.get_atlas_grid_size().x * 0.25):
			var pos = Vector2i(x * 4, y)
			atlas_source.set_tile_animation_frames_count(pos, 4)
			atlas_source.set_tile_animation_speed(pos, Data.TILE_ANIMATION_SPEED)
	var water_source = tileset.get_source(1)
	water_source.set_tile_animation_speed(Vector2.ZERO, Data.TILE_ANIMATION_SPEED)
	
	# sprite collisions
	for sprite: Sprite2D in $Objects/SimpleObjects.get_children():
		var texture = sprite.texture
		var shape = RectangleShape2D.new()
		shape.size = texture.get_size()
		shape.size.y *= 0.68
		if 'Tree' in sprite.name or 'Palm' in sprite.name:
			shape.size.x *= 0.4
			shape.size.y *= 0.8
		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = shape
		var static_body = StaticBody2D.new()
		static_body.add_child(collision_shape)
		sprite.add_child(static_body)
	
	# change bg color
	RenderingServer.set_default_clear_color(Color.BLACK)


func player_start_position(target: Data.Location):
	for gate in $TransitionGates.get_children():
		if gate.target == target:
			$Objects/Characters/Player.position = gate.position + gate.get_start_offset()
			var view_dir = gate.get_start_offset().normalized() as Vector2i
			$Objects/Characters/Player.change_view(view_dir)
