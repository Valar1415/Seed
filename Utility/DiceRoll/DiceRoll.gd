extends Node

# A dictionary to store the number of sides for each type of die
var dice_sides = {
	"d4": 4,
	"d6": 6,
	"d8": 8,
	"d10": 10,
	"d12": 12
}

# Helper function to check if a string represents a valid integer
func is_valid_integer(s: String) -> bool:
	# Use is_valid_float to check if it's a number, then check if it's a whole number
	return s.is_valid_float() and int(s) == float(s)

# Main function to handle all types of rolls, including multiple dice types and modifiers
func roll(roll_command: String) -> int:
	# Remove any whitespace and split by "+" and "-" to handle dice and modifiers
	var total = 0
	var current_sign = 1  # Used to track whether to add or subtract

	# Iterate through the characters of the roll command
	var i = 0
	while i < roll_command.length():
		# Check for "+" or "-" and update the sign accordingly
		if roll_command[i] == "+":
			current_sign = 1
			i += 1
			continue
		elif roll_command[i] == "-":
			current_sign = -1
			i += 1
			continue

		# Find the next dice roll or modifier
		var end_idx = i
		while end_idx < roll_command.length() and roll_command[end_idx] != "+" and roll_command[end_idx] != "-":
			end_idx += 1

		var part = roll_command.substr(i, end_idx - i).strip_edges()
		i = end_idx  # Move the iterator forward

		# Handle dice rolls (e.g., "2d6")
		if "d" in part:
			var matches = part.split("d")
			if matches.size() == 2:
				var count = 1
				if matches[0] != "":
					count = int(matches[0])  # How many dice to roll
				var sides = int(matches[1])  # Number of sides on the dice

				# Roll the dice and add to the total
				for j in range(count):
					total += current_sign * randi_range(1, sides)
		# Handle modifiers (e.g., "+3" or "-2")
		elif is_valid_integer(part):
			total += current_sign * int(part)

	return total

# Example usage
#func _ready():
	## Rolling a single d6
	#var result_single = roll("d6")
	#print("Single d6 roll result: ", result_single)

	## Rolling 3d6 dice
	#var result_multiple = roll("3d6")
	#print("Multiple d6 rolls result: ", result_multiple)

	## Custom roll command like "2d6+3"
	#var result_custom = roll("2d6+3")
	#print("Custom roll (2d6+3) result: ", result_custom)

	## Rolling two different dice types with a modifier
	#var result_multi_type = roll("2d4 + 3d6 - 2")
	#print("Result of 2d4 + 3d6 - 2: ", result_multi_type)
