extends Node2D

var grass_cover_scene = preload("res://scenes/levels/grass_cover.tscn")
@onready var player = $Objects/Characters/Player
var encounter_area: bool :
	set(new_value):
		encounter_area = new_value
		if encounter_area and not $Timers/EncounterTimer.time_left:
			$Timers/EncounterTimer.start()

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
	
	# grass cover
	for cell in $BG/Grass.get_used_cells():
		var grass_cover = grass_cover_scene.instantiate()
		$Objects.add_child(grass_cover)
		grass_cover.position = Vector2(cell.x * 16 + 8, cell.y * 16 + 3)
	
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
	
#
#func print_mon(index : int, monsters: Array[MonsterResource]):
	#for monster_res in monsters:
		#print("%d : %s [%d, %d]" % [index,
			#Data.monster_data[monster_res.id]['name'],
			#Data.monster_data[monster_res.id]['element'],
			#monster_res.level,
		#])
	
func _process(_delta: float) -> void:
	var player_grid_position := Vector2i(player.position.x / 16, player.position.y / 16)
	#biome check
	var tile_data = $BG/Floor.get_cell_tile_data(player_grid_position)
	Data.current_biome = (tile_data.get_custom_data('Biome')) as Data.Biome
	# grass check
	var grass = $BG/Grass.get_cell_tile_data(player_grid_position) as TileData
	var snow = (Data.current_biome == Data.Biome.ICE)
	encounter_area = (grass or snow)

func player_start_position(target: Data.Location):
	for gate in $TransitionGates.get_children():
		if gate.target == target:
			$Objects/Characters/Player.position = gate.position + gate.get_start_offset()
			var view_dir = gate.get_start_offset().normalized() as Vector2i
			$Objects/Characters/Player.change_view(view_dir)

func place_player_post_battle(pos: Vector2, view_dir : Vector2) -> void:
	player.position = pos
	player.change_view(view_dir)


func _on_encounter_timer_timeout() -> void:
	if encounter_area:
		Data.current_pos = player.position
		Data.current_face_dir = player.view_direction
		Data.trainer_fight = false
		Data.enemy_monsters = get_biome_monsters(Data.current_biome)
		TransitionLayer.transition(Data.Location.BATTLE, Data.current_loc)

func get_biome_monsters(current_biome : Data.Biome) -> Array[MonsterResource]:
	var monster_selection : Array[Data.Monster] = []
	var monsters : Array[MonsterResource] = []
	var required_element : Data.Element
	# how many monsters do we want? Try to skew random number towards the lower end of 1 to 5
	var number_of_monsters : int = maxi(int(randfn(2, 1)), 1)
	# calculate average player monster level
	var average_level: int = calculate_monster_average(Data.player_monsters)
	# convert biome to element
	var element_conv = {
		Data.Biome.DESERT: Data.Element.FIRE,
		Data.Biome.ICE: Data.Element.WATER,
		Data.Biome.GRASS: Data.Element.PLANT,		
	}
	required_element = element_conv[current_biome]
	# find all monsters that could match the element required
	for monster : Data.Monster in Data.Monster.values():
		if Data.monster_data[monster]['element'] == required_element:
			monster_selection.append(monster)
	# select a few at random
	for i in number_of_monsters:
		# what level should this monster be? Try to skew random number towards the 
		# player monster average level area of 5 to 50
		var level : int = maxi(int(randfn(average_level, 5)), 0) + 4
		var found_monster : MonsterResource = Data.new_monster_res(monster_selection.pick_random(), level)
		monsters.append(found_monster)
	return monsters

func calculate_monster_average(monsters: Array[MonsterResource]) -> int:
	var total_level: float = 0.0
	var avg: int = 5
	if monsters.size() > 0:
		for monster_res in monsters:
			total_level += monster_res.level
		var avg_f : float = (total_level / monsters.size())
		avg = floori(avg_f)
	return avg
	
	
