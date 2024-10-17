extends Player

func _ready() -> void:
	await get_tree().process_frame # Do not remove
	
	#if is_multiplayer_authority():
		#print("Player ID: ", player_id, " has authority.")
	#else:
		#print("Player ID: ", player_id, " does not have authority.")
	
	#%HealthLbl.max_value = max_health
	#%ArmorLbl.max_value = max_armor
	snap_to_nearest_tile()
	$Camera2D.position = global_position
	%lblPlayerName.text = name #set name to playerID
	
	
	if is_multiplayer_authority():
		combatants.local_player = self
		initiative = "1d99999"
		reveal_local_UI()
	


func execute_ability(ability: Abilities, target_pos: Vector2, target_enemy) -> void:
	print("Ability executed at position: ", target_pos)
	print("target enemy name: ", target_enemy)
	match ability:
		Abilities.A1:
			var damage = roll_dice("1d12 + 1d6")
			if target_enemy != null:
				target_enemy.take_damage(damage)
			rolls -= 1
		Abilities.A2:
			var damage = roll_dice("3d4")
			var armor_ = roll_dice("2d6")
			if target_enemy != null:
				target_enemy.take_damage(damage)
			gain_armor(armor_)
			rolls -= 1
		Abilities.A3:
			var shield_icon = debuffIcon.instantiate()
			%Buffs.add_child(shield_icon)
			shield_icon.texture = load("res://temp/Shield.png")
			rolls -= 1
		Abilities.A4:
			var damage = roll_dice("1d12 + 1d6")
			if target_enemy != null:
				target_enemy.take_damage(damage)
			rolls -= 1
		Abilities.A5:
			var armor_ = roll_dice("4d6")
			gain_armor(armor_)
			rolls -= 1
		Abilities.A6:
			var damage = roll_dice("2d8 + 1d10 + 1d4 + 1d999")
			if target_enemy != null:
				target_enemy.take_damage(damage)
			rolls -= 1


## ABILITIES

func _on_a_1_pressed() -> void:
	target_icon.visible = true
	targeting_active = true
	current_ability = Abilities.A1

func _on_a_2_pressed() -> void:
	target_icon.visible = true
	targeting_active = true
	current_ability = Abilities.A2

func _on_a_3_pressed() -> void:
	current_ability = Abilities.A3
	if rolls > 0 and turn:
		execute_ability(current_ability, Vector2(0,0), Vector2(0,0))
	pass

func _on_a_4_pressed() -> void:
	target_icon.visible = true
	targeting_active = true
	current_ability = Abilities.A4

func _on_a_5_pressed() -> void:
	current_ability = Abilities.A5
	if rolls > 0 and turn:
		execute_ability(current_ability, Vector2(0,0), Vector2(0,0))
	pass

func _on_a_6_pressed() -> void:
	current_ability = Abilities.A6
	target_icon.visible = true
	targeting_active = true
	pass


## SIGNALS



func _on_message_focus_entered() -> void:
	chat_inactive = false

func _on_message_focus_exited() -> void:
	chat_inactive = true
