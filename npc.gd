extends CharacterBody2D

const tile_size: Vector2 = Vector2(32,32)
var sprite_node_pos_tween: Tween 
@export var walk_speed: float = 0.5 # NPCs usually move slower

@onready var raycasts = {
	Vector2.UP: $up,
	Vector2.DOWN: $down,
	Vector2.LEFT: $left,
	Vector2.RIGHT: $right
}

func play_walk_animation(dir: Vector2):

	if dir == Vector2.UP: $Sprite2D/PlayerAnimation.play("npc1_right")
	
func update_facing_direction(dir: Vector2):
	match dir:
		Vector2.RIGHT: $Sprite2D/PlayerAnimation.play("idle_right")
func _ready():
	# Start a timer to make the NPC move every 2 seconds
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0
	timer.autostart = true
	timer.timeout.connect(_on_move_timer_timeout)
	timer.start()
	
func _move(dir: Vector2, duration: float):
	global_position += dir * tile_size
	$Sprite2D.global_position -= dir * tile_size
func _on_move_timer_timeout():
	# 1. Pick a random direction
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var random_dir = directions[randi() % directions.size()]
	
	# 2. Face the direction
	update_facing_direction(random_dir)
	
	# 3. Move if the path is clear
	if not raycasts[random_dir].is_colliding():
		play_walk_animation(random_dir)
		_move(random_dir, walk_speed)
		
