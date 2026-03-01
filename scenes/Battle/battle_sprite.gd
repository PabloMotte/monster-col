extends Sprite2D

var monster_res: MonsterResource
var paused := false
var readiness: float
var playable: bool = false

signal is_ready(battle_sprite: Sprite2D)

# TODO : for the future
# var ready : bool = true # in setup set this to false if battle is a surprise, and set ReadyProgressBar to 100 if ready else 0
# add a pixel width border around progress bars, especially required for colour-vision problems
# highlight finished and paused readiness bars

func _process(delta: float) -> void:
	if not paused:
		# progress bar loses the float values with small increments, so store the float elsewhere and just assign
		readiness += monster_res.get_stat('speed') * delta
		$Control/ReadyProgressBar.value = readiness

func setup(pos: Vector2, is_player: bool, res: MonsterResource) -> void:
	position = pos
	flip_h = is_player
	playable = is_player
	monster_res = res
	texture = load(Data.monster_data[monster_res.id]['battle texture'])
	ui_setup()
	
func ui_setup() -> void:
	$Control/NameContainer/MarginContainer/Label.text = Data.monster_data[monster_res.id]['name']
	$Control/ReadyProgressBar.value = 0.0


func _on_ready_progress_bar_value_changed(value: float) -> void:
	if value >= 100:
		for battle_sprite in get_tree().get_nodes_in_group('BattleSprites'):
			battle_sprite.paused = true
		$Control/ReadyProgressBar.value = 0.0
		readiness = 0.0
		is_ready.emit(self)
