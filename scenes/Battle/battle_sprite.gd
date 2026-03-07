extends Sprite2D

var monster_res: MonsterResource
var paused := false
var readiness: float
var playable: bool = false
var index: int

signal is_ready(battle_sprite: Sprite2D)
signal death(is_player: bool, index: int, res: MonsterResource)

# TODO : for the future
# var ready : bool = true # in setup set this to false if battle is a surprise, and set ReadyProgressBar to 100 if ready else 0
# add a pixel width border around progress bars, especially required for colour-vision problems
# highlight finished and paused readiness bars

func _process(delta: float) -> void:
	if not paused:
		# progress bar loses the float values with small increments, so store the float elsewhere and just assign
		readiness += monster_res.get_stat('speed') * delta
		$Control/ReadyProgressBar.value = readiness
		change_energy(monster_res.get_stat('max ep') * monster_res.get_stat('speed') * delta * 0.05 * monster_res.level_mod())
		#change_energy(mo0nster_res.get_stat('max ep') * delta * 0.01)

func setup(pos: Vector2, is_player: bool, res: MonsterResource, new_index: int) -> void:
	position = pos
	flip_h = is_player
	playable = is_player
	monster_res = res
	monster_res.connect("level_up", ui_setup)
	index = new_index
	texture = load(Data.monster_data[monster_res.id]['battle texture'])
	ui_setup()
	
func ui_setup() -> void:
	$Control/NameContainer/MarginContainer/Label.text = Data.monster_data[monster_res.id]['name']
	$Control/ReadyProgressBar.value = 0.0
	$Control/StatsContainers/HealthBar.max_value = monster_res.get_stat("max hp")
	$Control/StatsContainers/HealthBar.value = monster_res.current_hp
	$Control/StatsContainers/HealthBar.set_tint_progress(monster_res.HEALTH_COLOUR)
	$Control/StatsContainers/Control/EnergyBar.max_value = monster_res.get_stat("max ep")
	$Control/StatsContainers/Control/EnergyBar.value = monster_res.current_ep
	$Control/StatsContainers/Control/EnergyBar.set_tint_progress(monster_res.ENERGY_COLOUR)
	$Control/LevelContainer/Label.text = "%d" % monster_res.level
	$Control/LevelContainer/TextureProgressBar.max_value = monster_res.level * Data.LEVEL_XP_MULT
	$Control/LevelContainer/TextureProgressBar.value = monster_res.current_xp

func attack_animation() -> void:
	$AnimationPlayer.play("Attack")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("Idle")

func change_health(amount: float, element: Data.Element) -> float:
	# attack damage modified by receiving monster level if that monster is defending
	var defense: float = (monster_res.level_mod() if monster_res.is_defending else 1.0)
	# damage modified by attacking/receiving monster element types (fire > plant > water > fire > ...)
	var modifier: float = Data.element_modifier[element][monster_res.get_element()]
	var modified_amount : float = amount * (modifier / defense)
	# healing not modified by receiving monster for any reason
	monster_res.current_hp -= (modified_amount if amount >= 0 else amount)
	# animate the health bar
	var tween = create_tween()
	tween.tween_property($Control/StatsContainers/HealthBar, "value", monster_res.current_hp, 0.5)
	tween.tween_callback(check_death)
	# Colour the health bar differently if it is low
	if monster_res.current_hp <= monster_res.get_low_hp():
		$Control/StatsContainers/HealthBar.set_tint_progress(monster_res.HEALTH_LOW_COLOUR)
	else:
		$Control/StatsContainers/HealthBar.set_tint_progress(monster_res.HEALTH_COLOUR)
	# return the modified amount so it can be used upstream
	return (modified_amount if amount >= 0 else amount)

func change_energy(amount: float) -> void:
	monster_res.current_ep += amount
	var tween = create_tween()
	tween.tween_property($Control/StatsContainers/Control/EnergyBar, "value", monster_res.current_ep, 0.5)
	if monster_res.current_ep <= monster_res.get_low_ep():
		$Control/StatsContainers/Control/EnergyBar.set_tint_progress(monster_res.ENERGY_LOW_COLOUR)
	else:
		$Control/StatsContainers/Control/EnergyBar.set_tint_progress(monster_res.ENERGY_COLOUR)

func change(res: MonsterResource) -> void:
	texture = load(Data.monster_data[res.id]['battle texture'])
	monster_res = res
	ui_setup()

func check_death() -> void:
	if monster_res.current_hp <= 0:
		death.emit(playable, index, monster_res)
		queue_free()

func add_xp(amount: int) -> void:
	monster_res.current_xp += amount
	$Control/LevelContainer/TextureProgressBar.value = monster_res.current_xp

func _on_ready_progress_bar_value_changed(value: float) -> void:
	if value >= 100:
		for battle_sprite in get_tree().get_nodes_in_group('BattleSprites'):
			battle_sprite.paused = true
		$Control/ReadyProgressBar.value = 0.0
		readiness = 0.0
		is_ready.emit(self)
