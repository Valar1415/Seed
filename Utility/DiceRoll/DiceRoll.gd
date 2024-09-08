extends Node

# A dictionary to store the number of sides for each type of die
var dice_sides = {
	"d4": 4,
	"d6": 6,
	"d8": 8,
	"d10": 10,
	"d12": 12
}

# Main function to handle all types of rolls
func roll(roll_command: String) -> int:
	# Split the roll command (e.g., "2d6+3" or "d6")
	var matches = roll_command.split("d")
	
	# Determine if it's a single die or multiple dice with modifiers
	if matches.size() == 2:
		var count = 1
		if matches[0] != "":
			count = int(matches[0])  # How many dice to roll

		var sides_and_modifier = matches[1].split("+")
		var sides = int(sides_and_modifier[0])  # Number of sides on the dice
		var modifier = 0
		
		if sides_and_modifier.size() > 1:
			modifier = int(sides_and_modifier[1])  # Modifier if present
		
		# Roll the dice and sum the results
		var total = 0
		for i in range(count):
			total += randi_range(1, sides)
		
		return total + modifier

	# If it's just a single die type without numbers (e.g., "d6")
	elif matches.size() == 1 and dice_sides.has(roll_command):
		var sides = dice_sides[roll_command]
		return randi_range(1, sides)

	else:
		print("Invalid roll command: ", roll_command)
		return 0

# Example usage
#func _ready():
	## Rolling a single d6
	#var result_single = roll("d6")
	#print("Single d6 roll result: ", result_single)
#
	## Rolling 3d6 dice
	#var result_multiple = roll("3d6")
	#print("Multiple d6 rolls result: ", result_multiple)
#
	## Custom roll command like "2d6+3"
	#var result_custom = roll("2d6+3")
	#print("Custom roll (2d6+3) result: ", result_custom)
