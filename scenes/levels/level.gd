extends Node2D

func _ready() -> void:
	# tileset animation
	var tileset: TileSet = $BG/Floor.tile_set as TileSet
	# coastal tiles are (3 (t, m, b) rows x 4 animation cells) x 2 (l, r) [24 cells, water on outer edges]
	#       followed by (1 rows x 4 animation cells) x 2 (t, b) [8 cells]
	#       followed by (3 (t, m, b) rows x 4 animation cells) x 2 (l, r) [24 cells, water on inner edges]
	var atlas_source: TileSetAtlasSource = tileset.get_source(3) as TileSetAtlasSource
	for y in atlas_source.get_atlas_grid_size().y:
		for x in int(atlas_source.get_atlas_grid_size().x * 0.25):
			var pos = Vector2i(x * 4, y)
			atlas_source.set_tile_animation_frames_count(pos, 4)
			atlas_source.set_tile_animation_speed(pos, Data.TILE_ANIMATION_SPEED)
	# water tiles are just four animation cells and fifth cell not part of an animation (ice?)
	var water_source: TileSetAtlasSource = tileset.get_source(1) as TileSetAtlasSource
	water_source.set_tile_animation_speed(Vector2.ZERO, Data.TILE_ANIMATION_SPEED)

	# sprite collisions
	for sprite: Sprite2D in $Objects/SimpleObjects.get_children():
		var texture := sprite.texture
		var shape := RectangleShape2D.new()
		shape.size = texture.get_size()
		shape.size.y *= 0.58
		if 'Tree' in sprite.name or  'Palm' in sprite.name:
			shape.size.x *= 0.4
			shape.size.y *= 0.6
		var collision_shape := CollisionShape2D.new()
		collision_shape.shape = shape
		var static_body := StaticBody2D.new()
		static_body.add_child(collision_shape)
		sprite.add_child(static_body)

	# Change BG colour
	RenderingServer.set_default_clear_color(Color.BLACK)
	
func player_start_pos(target: Data.Location) -> void:
	for gate in $TransitionGates.get_children():
		if target == gate.target:
			$Objects/Characters/Player.position = gate.position + gate.get_start_offset()
			var view_dir: Vector2i = gate.get_start_offset().normalized() as Vector2i
			$Objects/Characters/Player.change_view(view_dir)
