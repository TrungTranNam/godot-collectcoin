extends Area2D

@export var value: int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sfx: AudioStreamPlayer = $Sfx

func _ready() -> void:
	sprite.play("spin")
	sprite.frame = randi() % sprite.sprite_frames.get_frame_count("spin")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.score += value
		hide()
		set_deferred("monitoring", false)  # không cho nhặt 2 lần
		sfx.play()
		await sfx.finished  # chờ phát xong mới xoá, nếu không tiếng bị cắt
		queue_free()
