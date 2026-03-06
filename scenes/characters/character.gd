class_name Character extends CharacterBody2D

var _player: Character
@export var char_style: Data.CharacterStyle
@export var view_distance := 50
var direction: Vector2
var speed = 60
var current_h_frame: float
var view_direction: Vector2i
@export var look_around: bool = true
var can_move := true
var dialog_index: int
var unique_id: String

func _enter_tree() -> void:
	unique_id = get_unique_id()

func _ready() -> void:
	$Sprite2D.texture = load(Data.character_texture_data[char_style])

func get_player():
	if !_player:
		_player = get_tree().get_first_node_in_group('Player')
	return _player

func move():
	velocity = direction * speed
	move_and_slide()


func get_unique_id() -> String:
	var current_scene_name = get_owner().scene_file_path.get_file().get_basename()
	var node_name = name
	return current_scene_name + "_" + node_name

func animate(delta):
	if direction:
		var face_dir: Vector2i = Vector2i(round(direction.x),round(direction.y))
		change_view(face_dir)
		current_h_frame += Data.ANIMATION_SPEED * delta
	else:
		current_h_frame = 0
	$Sprite2D.frame_coords.x = int(current_h_frame) % $Sprite2D.hframes


func get_char_direction(target_char) -> Vector2i:
	if target_char and self:
		var dir = (target_char.position - position).normalized()
		return Vector2i(round(dir.x), round(dir.y))
	else:
		return Vector2i.DOWN


func change_view(target: Vector2i):
	$Sprite2D.frame_coords.y = Data.character_view_directions[target]
	update_raycast(target)

func update_raycast(target: Vector2i) -> void:
	$RayCast2D.target_position = target * view_distance
