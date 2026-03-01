class_name Character extends CharacterBody2D

@export var char_style: Data.CharacterStyle
@export var view_distance := 50
var direction: Vector2
var speed = 60
var current_h_frame: float
var view_direction: Vector2i
var can_move := true

func _ready() -> void:
	$Sprite2D.texture = load(Data.character_texture_data[char_style])


func move():
	velocity = direction * speed
	move_and_slide()


func animate(delta):
	if direction:
		var face_dir: Vector2i = Vector2i(round(direction.x),round(direction.y))
		$Sprite2D.frame_coords.y = Data.character_view_directions[face_dir]
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
