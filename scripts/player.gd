extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var acceleration: float = 1200.0
@export var friction: float = 1400.0
@export var death_y: float = 600.0  # rơi thấp hơn mức này thì chết

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sfx: AudioStreamPlayer = $JumpSfx
@onready var die_sfx: AudioStreamPlayer = $DieSfx

func _physics_process(delta: float) -> void:
	if global_position.y > death_y:
		die()
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		jump_sfx.play()

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()
	_update_animation(direction)

func _update_animation(direction: float) -> void:
	if not is_on_floor():
		sprite.play("jump")
	elif direction != 0:
		sprite.play("run")
	else:
		sprite.play("idle")

func die() -> void:
	if is_dead:
		return  # tránh gọi die() nhiều lần cùng lúc
	is_dead = true
	set_physics_process(false)  # đứng im, không điều khiển được nữa
	sprite.stop()
	get_tree().call_group("music", "stop")
	die_sfx.play()
	await die_sfx.finished
	GameState.reset()
	get_tree().reload_current_scene()
