class_name Character extends CharacterBody2D

@export var char_style: Data.CharacterStyle
@export var view_distance: int = 50
var view_direction: Vector2i
var direction: Vector2
var can_move: bool = true

var speed: int = 60
var current_h_frame: float

func _ready() -> void:
	$Sprite2D.texture = load(Data.character_texture_data[char_style])

func move() -> void:
	velocity = direction * speed
	move_and_slide()
	
func animate(delta: float) -> void:
	if direction:
		var face_dir: Vector2i = Vector2i(round(direction.x), round(direction.y))
		$Sprite2D.frame_coords.y = Data.character_view_directions[face_dir]
		current_h_frame += Data.ANIMATION_SPEED * delta
	else:
		current_h_frame = 0
	$Sprite2D.frame_coords.x = int(current_h_frame) % $Sprite2D.hframes

func get_char_direction(target_char: Character) -> Vector2i:
	return get_pos_direction(target_char.position)

func get_pos_direction(target_pos: Vector2) -> Vector2i:
	var dir := (target_pos - position).normalized()
	return Vector2i(round(dir.x), round(dir.y))

func change_view(target: Vector2i) -> void:
	$Sprite2D.frame_coords.y = Data.character_view_directions[target]
