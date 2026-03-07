class_name MonsterResource extends Resource

@export var id: Data.Monster
@export var level: int
@export var LEVEL_MODIFIER: float = 0.1
var is_defending: bool
var current_hp: float:
	set(new_value):
		current_hp = clampf(new_value, -1.0, get_stat('max hp'))
var current_ep: float:
	set(new_value):
		current_ep = clampf(new_value, -1.0, get_stat('max ep'))
var current_xp: int:
	set(new_value):
		current_xp = new_value
		if current_xp >= (level * Data.LEVEL_XP_MULT):
			current_xp -= (level * Data.LEVEL_XP_MULT)
			level += 1
			level_up.emit()

@export var LOW_HP_FACTOR: float = 0.15
const HEALTH_COLOUR: Color = Color.GREEN
const HEALTH_LOW_COLOUR: Color = Color.GOLD
@export var LOW_EP_FACTOR: float = 0.15
const ENERGY_COLOUR: Color = Color.CORNFLOWER_BLUE
const ENERGY_LOW_COLOUR: Color = Color.PURPLE

signal level_up()

func setup(new_id: Data.Monster, new_level: int) -> void:
	id = new_id
	level = new_level
	initialise()

func initialise() -> void:
	current_hp = get_stat('max hp')
	current_ep = get_stat('max ep')
	current_xp = 0
	
func get_attribute(attribute: String) -> Variant:
	return Data.monster_data[id][attribute]

func get_stat(stat: String) -> float:
	return Data.monster_data[id]['stats'][stat] * level
	
func get_element() -> Data.Element:
	return Data.monster_data[id]['element']

func get_attacks() -> Array[Data.Attack]:
	var attacks: Array[Data.Attack]
	for level_req in Data.monster_data[id]['attacks'].keys():
		if level >= level_req:
			attacks.append(Data.monster_data[id]['attacks'][level_req])
	return attacks

func get_available_attack() -> Array[Data.Attack]:
	var attacks := get_attacks()
	var available_attacks : Array[Data.Attack] = []
	for attack:Data.Attack in attacks:
		if Data.attack_data[attack]['cost'] <= current_ep:
			available_attacks.append(attack)
	return available_attacks

func get_random_attack() -> Data.Attack:
	var available_attacks : Array[Data.Attack] = get_available_attack()
	return available_attacks.pick_random() if available_attacks.size() else null
	
func heal() -> void:
	current_hp = get_stat('max hp')
	current_ep = get_stat('max ep')

## increase damage, resistance and ep restore by a fraction of the level
func level_mod() -> float:
	return 1.0 + (level * LEVEL_MODIFIER)

func get_low_hp() -> float:
	return get_stat('max hp') * LOW_HP_FACTOR

func get_low_ep() -> float:
	return get_stat('max ep') * LOW_EP_FACTOR
