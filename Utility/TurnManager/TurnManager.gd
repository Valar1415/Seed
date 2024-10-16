#https://www.youtube.com/watch?v=umC2i8jwUKM
extends Resource
class_name TurnManager

signal ally_turn_started()
signal enemy_turn_started()

enum {ALLY_TURN, ENEMY_TURN}

var turn : int:
	get: return turn
	set(value):
		turn = value
		match turn:
			ALLY_TURN: emit_signal("ally_turn_started")
			ENEMY_TURN: emit_signal("enemy_turn_started")
