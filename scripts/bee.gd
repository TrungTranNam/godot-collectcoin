extends Area2D

@export var detect_range: float = 120.0   # khoảng cách phát hiện người chơi
@export var windup_time: float = 0.7      # thời gian báo hiệu trước khi lao
@export var dash_speed: float = 140.0
@export var dash_time: float = 1.5        # lao trong bao lâu
@export var return_speed: float = 60.0

enum State { IDLE, WINDUP, DASH, RETURN }

var state := State.IDLE
var home: Vector2
var dir := Vector2.ZERO
var t := 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	home = global_position
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	t += delta
	var player := get_tree().get_first_node_in_group("player") as Node2D

	match state:
		State.IDLE:
			global_position.y = home.y + sin(t * 4.0) * 4.0
			if player:
				_face(player.global_position.x)          # luôn nhìn theo nhân vật
				if global_position.distance_to(player.global_position) < detect_range:
					_set_state(State.WINDUP)
					sprite.modulate = Color(1, 0.5, 0.5)

		State.WINDUP:
			sprite.position.x = randf_range(-1.5, 1.5)
			if player:
				_face(player.global_position.x)          # vừa rung vừa ngắm theo
			if t > windup_time:
				sprite.position.x = 0
				sprite.modulate = Color.WHITE
				if player:
					dir = global_position.direction_to(player.global_position)
				_face(global_position.x + dir.x)         # quay theo hướng lao
				_set_state(State.DASH)

		State.DASH:
			var speed := dash_speed * clampf(t / 0.4, 0.2, 1.0)  # tăng tốc trong 0.4s đầu
			global_position += dir * speed * delta
			if t > dash_time:
				_set_state(State.RETURN)

		State.RETURN:
			global_position = global_position.move_toward(home, return_speed * delta)
			_face(home.x)                                # quay về phía tổ
			if global_position == home:
				_set_state(State.IDLE)

func _set_state(s: State) -> void:
	state = s
	t = 0.0

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
		
func _face(target_x: float) -> void:
	sprite.flip_h = target_x > global_position.x  # asset quay trái → mục tiêu bên phải thì lật
