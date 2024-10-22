extends Node


enum Gamestate {REST, COMBAT}

var current_gamestate = Gamestate.REST

func get_game_state_name():
	return Gamestate.keys()[current_gamestate]
