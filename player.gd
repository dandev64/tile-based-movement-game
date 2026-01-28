extends CharacterBody2D

const tile_size: Vector2 = Vector2(32,32)
var sprite_node_pos_tween: Tween 
var last_direction: Vector2 = Vector2.DOWN 

@export var walk_speed: float = 0.185
@export var sprint_speed: float = 0.1 
@onready var tile_map: TileMapLayer = $"../TileMapLayer"
@onready var anim: AnimationPlayer = $Sprite2D/PlayerAnimation

func _physics_process(_delta: float) -> void:
	if !sprite_node_pos_tween or !sprite_node_pos_tween.is_running():
		var is_sprinting = Input.is_action_pressed("sprint")
		var current_speed = sprint_speed if is_sprinting else walk_speed
		
		var input_dir = Vector2.ZERO
		if Input.is_action_pressed("ui_up"): input_dir = Vector2.UP
		elif Input.is_action_pressed("ui_down"): input_dir = Vector2.DOWN
		elif Input.is_action_pressed("ui_left"): input_dir = Vector2.LEFT
		elif Input.is_action_pressed("ui_right"): input_dir = Vector2.RIGHT
		
		if input_dir != Vector2.ZERO:
			last_direction = input_dir 
			if not is_colliding_in_direction(input_dir):
				play_animation("run_" if is_sprinting else "walk_", input_dir)
				_move(input_dir, current_speed)
			else:
				play_animation("idle_", input_dir)
		else:
			play_animation("idle_", last_direction)

func get_dir(dir: Vector2) -> String:
	if dir == Vector2.UP: return "up"
	if dir == Vector2.LEFT: return "left"
	if dir == Vector2.RIGHT: return "right"
	return "down"

func play_animation(prefix: String, dir: Vector2):
	anim.play(prefix + get_dir(dir))

func is_colliding_in_direction(dir: Vector2) -> bool:
	return get_node(get_dir(dir)).is_colliding()

func _move(dir: Vector2, duration: float):
	global_position += dir * tile_size
	$Sprite2D.global_position -= dir * tile_size

	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($Sprite2D, "global_position", global_position, duration).set_trans(Tween.TRANS_SINE)
