extends Player


@rpc("any_peer", "call_local", "reliable")
func execute_ability(ability: Abilities, target_pos: Vector2, target_enemy_path) -> void:
	var target_enemy = get_node(target_enemy_path)
	#print("Ability executed at position: ", target_pos)
	#print("target enemy name: ", target_enemy)
	match ability:
		Abilities.A1:
			var skill = Skill.new()
			skill.dice_roll_dmg = "1d6 + 1d8"
			await roll_dice(skill)
			
			if target_enemy != null:
				target_enemy.take_damage.rpc(skill.dice_result_dmg)
			skill.queue_free()
		Abilities.A2:
			var skill = Skill.new()
			skill.dice_roll_dmg = "1d6 + 1d8"
			await roll_dice(skill)
			
			if target_enemy != null:
				target_enemy.take_damage.rpc(skill.dice_result_dmg)
			skill.queue_free()
		Abilities.A3:
			var skill = Skill.new()
			skill.dice_roll_health = "3d6"
			await roll_dice(skill)
			
			gain_health.rpc(skill.dice_result_health)
			skill.queue_free()
		Abilities.A4:
			var skill = Skill.new()
			skill.dice_roll_dmg = "2d8"
			await roll_dice(skill)
			
			if target_enemy != null:
				target_enemy.take_damage.rpc(skill.dice_result_dmg)
			skill.queue_free()
		Abilities.A5:
			var skill = Skill.new()
			skill.dice_roll_armor = "4d6"
			await roll_dice(skill)
			
			gain_armor.rpc(skill.dice_result_armor)
			skill.queue_free()
		Abilities.A6:
			var skill = Skill.new()
			skill.dice_roll_dmg = "6d4"
			await roll_dice(skill)
			
			if target_enemy != null:
				target_enemy.take_damage.rpc(skill.dice_result_dmg)
			skill.queue_free()
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
		execute_ability.rpc(current_ability, Vector2(0,0), Vector2(0,0))
	pass

func _on_a_4_pressed() -> void:
	target_icon.visible = true
	targeting_active = true
	current_ability = Abilities.A4

func _on_a_5_pressed() -> void:
	current_ability = Abilities.A5
	if rolls > 0 and turn:
		execute_ability.rpc(current_ability, Vector2(0,0), Vector2(0,0))
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
