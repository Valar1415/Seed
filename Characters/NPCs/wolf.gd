extends Enemy

@rpc("any_peer", "call_local", "reliable")
func attack(target_enemy_path):
	var target_enemy = get_node(target_enemy_path)
	while rolls > 0:
		var rolled_ability = DiceRoll.roll("1d6")
		match rolled_ability:
			1,2,3:
				var skill = Skill.new()
				skill.dice_roll_dmg = "1d12"
				await roll_dice(skill)
				
				if target_enemy != null:
					target_enemy.take_damage.rpc(skill.dice_result_dmg)
			4,5:
				var skill = Skill.new()
				skill.dice_roll_dmg = "1d6 + 1d4"
				await roll_dice(skill)
				
				if target_enemy != null:
					target_enemy.take_damage.rpc(skill.dice_result_dmg)
			6:
				var skill = Skill.new()
				skill.dice_roll_dmg = "1d6 + 1d4"
				await roll_dice(skill)
				
				if target_enemy != null:
					target_enemy.take_damage.rpc(skill.dice_result_dmg)
		rolls -= 1
		atk_targets.clear()
		check_atk_targets_in_range()
		await get_tree().create_timer(0.5).timeout
	
