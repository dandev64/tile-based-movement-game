extends CharacterBody2D

const tile_size: Vector2 = Vector2(32,32)
var sprite_node_pos_tween: Tween #makes movement look smooth
@export var walk_speed: float =0.185
@export var sprint_speed: float=0.1 
@onready var tile_map: TileMapLayer = $"../TileMapLayer"

func _physics_process(delta: float) -> void:
	if !sprite_node_pos_tween or !sprite_node_pos_tween.is_running():
		var is_sprinting = Input.is_action_pressed("sprint")
		var current_speed = sprint_speed if is_sprinting else walk_speed
		
		#Check to see if we are doing anything
		var input_dir = Vector2.ZERO
		if Input.is_action_pressed("ui_up"): input_dir = Vector2.UP
		elif Input.is_action_pressed("ui_down"): input_dir = Vector2.DOWN
		elif Input.is_action_pressed("ui_left"): input_dir = Vector2.LEFT
		elif Input.is_action_pressed("ui_right"): input_dir = Vector2.RIGHT
		
		if input_dir != Vector2.ZERO:
			update_facing_direction(input_dir) 
			if not is_colliding_in_direction(input_dir):
				play_walk_animation(input_dir, is_sprinting)
				_move(input_dir, current_speed)
			else:
				$Sprite2D/PlayerAnimation.stop(false)
		#NO INPUT
		else:
			$Sprite2D/PlayerAnimation.stop()
			
			
func update_facing_direction(dir: Vector2):
	match dir:
		Vector2.UP: $Sprite2D/PlayerAnimation.play("idle_up")
		Vector2.DOWN: $Sprite2D/PlayerAnimation.play("idle_down")
		Vector2.LEFT: $Sprite2D/PlayerAnimation.play("idle_left")
		Vector2.RIGHT: $Sprite2D/PlayerAnimation.play("idle_right")
		
		
		
# Check collision based on direction
func is_colliding_in_direction(dir: Vector2) -> bool:
	if dir == Vector2.UP: return $up.is_colliding()
	if dir == Vector2.DOWN: return $down.is_colliding()
	if dir == Vector2.LEFT: return $left.is_colliding()
	if dir == Vector2.RIGHT: return $right.is_colliding()
	return false

func play_walk_animation(dir: Vector2, is_sprinting: bool):
	var walk_or_run = "run_" if is_sprinting else "walk_"
	
	if dir == Vector2.UP: $Sprite2D/PlayerAnimation.play(walk_or_run + "up")
	elif dir == Vector2.DOWN: $Sprite2D/PlayerAnimation.play(walk_or_run + "down")
	elif dir == Vector2.LEFT: $Sprite2D/PlayerAnimation.play(walk_or_run + "left")
	elif dir == Vector2.RIGHT: $Sprite2D/PlayerAnimation.play(walk_or_run  + "right")

func _move(dir: Vector2, duration: float):
	global_position += dir * tile_size
	$Sprite2D.global_position -= dir * tile_size


	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($Sprite2D, "global_position", global_position, duration).set_trans(Tween.TRANS_SINE)
	
	#sprite_node_pos_tween.finished.connect(is_ice.bind(dir)) #FOR ICE BUT UHHH
	
func is_ice(last_dir: Vector2): #Als for Ice 
	var current_tile = tile_map.local_to_map(global_position)
	
	var data = tile_map.get_cell_tile_data(current_tile)
	
	if data: 
		var tile_type = data.get_custom_data("special_tile")
		
		if tile_type == "ice":
			if not is_colliding_in_direction(last_dir):
				_move(last_dir, sprint_speed)
			else: 
				$Sprite2D/PlayerAnimation.stop(false)
			
		
