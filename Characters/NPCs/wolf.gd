extends Enemy


func attack(target_enemy):
	while rolls > 0:
		var rolled_ability = DiceRoll.roll("1d6")
		match rolled_ability:
			1,2,3:
				var damage = DiceRoll.roll("1d12")
				if target_enemy != null:
					target_enemy.take_damage(damage)
			4,5:
				var damage = DiceRoll.roll("1d6 + 1d4")
				if target_enemy != null:
					target_enemy.take_damage(damage)
			6:
				var damage = DiceRoll.roll("3d6")
				if target_enemy != null:
					target_enemy.take_damage(damage)
		rolls -= 1
		atk_targets.clear()
		check_atk_targets_in_range()
		await get_tree().create_timer(0.5).timeout
	
