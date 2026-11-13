extends Node

signal score_changed(new_score: int)

var score: int = 0:
	set(v):
		score = v
		score_changed.emit(score)

func reset() -> void:
	score = 0
