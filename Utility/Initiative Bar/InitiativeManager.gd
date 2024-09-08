extends Resource
class_name InitiativeManager

var init_order = []

#var init_order : int:
	#get: return init_order
	#set(value):
		#turn = value
		#match turn:
			#ALLY_TURN: emit_signal("ally_turn_started")
			#ENEMY_TURN: emit_signal("enemy_turn_started")
			

func set_initiative_order(entries):
	for i in entries:
		i.append()
	
	init_order.sort()
