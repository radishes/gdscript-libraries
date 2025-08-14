extends Node
## Helper for dealing with random numbers.
##
## Import as a global singleton. All random number generation in this class is done using  
## [member rng] as the source of randomness; set or modify [member rng] as needed.


var rng = RandomNumberGenerator.new()


func _init():
	rng.randomize()


func _ready():
	pass
	#test_randomness()


## Random choice helper for any object which supports `len()`.
func random_choice(iterable):
	var c = rng.randi_range(0, len(iterable) - 1)
	return iterable[c]


## Returns a random point between `(0,0)` and [param size].
func random_position(size:Vector2) -> Vector2:
	return Vector2(rng.randi_range(0, size.x), rng.randi_range(0, size.y))


## Returns a Color with each component of its RGB set to a random value between [param low]
## and [param high].
func random_color(low:=0.0, high:=1.0) -> Color:
	return Color(rng.randf_range(low, high), rng.randf_range(low, high), rng.randf_range(low, high))


## Helper method for parsing RPG-style "roll notation" into its individual values.
## Expected format of [param dice_notation]: `"<num_dice>d<sides>+<additive>"`[br]
## Returns a Dictionary with the parsed values.
func parse_rolln(dice_notation:String) -> Dictionary:
	var dice_n := dice_notation.split("d")
	var sides_add_split = dice_n[1].split("+")
	return {
		"dice_notation": dice_notation,
		"num_dice": int(dice_n[0]),  ## In 3d6+1, this is the 3.
		"sides": int(sides_add_split[0]),  ## In 3d6+1, this is the 6.
		"sides_additive": int(sides_add_split[1]) if sides_add_split else 0,  ## In 3d6+1, this is the 1
	}


## Roll dice using tabletop RPG-style "roll notation." Expected format of 
## [param dice_notation]: `"<num_dice>d<sides>+<additive>"`[br]
## Example: `5d6+1` will roll five 6-sided dice, add the rolls together and add 1 to the result.
func rolln(dice_notation:String) -> int:
	var dice_n = dice_notation.split("d")
	if len(dice_n) != 2:
		return 0
	var sides_additive = dice_n[1].split("+")
	var num_dice := int(dice_n[0])
	var sides := int(sides_additive[0])
	var additive := 0
	if len(sides_additive) == 2:
		additive = int(sides_additive[1])
	elif len(sides_additive) > 2:
		return 0
	var total := 0
	for die in num_dice:
		total += roll(sides)
	return total + additive


## Roll a die with [param die_sides] sides and add [param additive] to the result.
func roll(die_sides:int, additive:int=0) -> int:
	return rng.randi_range(1, die_sides) + additive


## [param table] format: `{object: odds}`
## Add up all the odds from [param table], roll equal to the total of all odds and return an object.
## This can be used for rolling random encounters, loot generation, etc.
## Example table: `{obj1: 5, obj2: 4, obj3: 20}`
## Calling this method with the example table will generate a random number `n` from 0-29.
## `0 <= n <= 5`: obj1 is returned. `5 < n <= 9`: obj2 is returned. `9 < n <= 29`: obj3 is returned.
func roll_table(table:Dictionary):
	var total_odds := 0.0
	for odds in table.values():
		total_odds += odds
	var n = rng.randf_range(0, total_odds)
	var running_odds := 0.0
	for object in table:
		running_odds += table[object]
		if n <= running_odds:
			return object
	return null


## Same as [method roll], with an additional `[param luck]/1.0` chance of receiving a second roll. 
## The larger result is returned.
## Each 0.1 luck increases the average roll by: ~1.40% (for d6), ~1.50% (for d10), ~1.65% (for d100+).
## Luck below 0 is the same as 0. Luck above 1.0 is the same as 1.0.
func luck_roll(die_sides:int, luck:float=0.0) -> int:
	var r = roll(die_sides)
	if rng.randf() < luck:
		r = max(r, roll(die_sides))
	return r


## Roll ([param low], [param high]) [param rerolls] times and return the result closest to [param weight] percent of the low-high range.
## Passing a float to [param rerolls] adds an additional element of randomness:
## `[param rerolls]=1.8` would get either 1 reroll (20% chance) and 2 rerolls (80% chance.)
func weighted_range(low:float, high:float, weight:float, rerolls:float=1.0) -> float:
	var target = (high - low) * weight + low
	var r = rng.randf_range(low, high)
	var rerolls_ = int(floor(rerolls) if rng.randf() > (rerolls - floor(rerolls)) else ceil(rerolls))
	while rerolls_ > 0:
		var r2 = rng.randf_range(low, high)
		r = r if abs(target - r) < abs(target - r2) else r2
		rerolls_ -= 1
	return r


## Run a test of some of the random number generation methods from this class and print a report.
func test_randomness() -> void:
	var SIDES = 100
	var ITERATIONS = 10000
	var LUCK = 1.0
	var WEIGHT = 0.2
	var REROLLS = .9
	##
	print("Test of randomness")
	var roll_results = {}
	var luck_roll_results = {}
	var weighted_range_results = {}
	for i in range(1, SIDES+1):
		roll_results[i] = 0
		luck_roll_results[i] = 0
		weighted_range_results[i] = 0
	print("Testing roll({0}).".format([SIDES]))
	for i in range(ITERATIONS):
		var r = roll(SIDES)
		roll_results[r] = roll_results[r] + 1
		var s = luck_roll(SIDES, LUCK)
		luck_roll_results[s] = luck_roll_results[s] + 1
		var w = int(weighted_range(50, SIDES, WEIGHT, REROLLS))
		weighted_range_results[w] = weighted_range_results[w] + 1
	print("RANDOM ROLL")
	_summarize_test(roll_results)
	print("LUCK ROLL")
	_summarize_test(luck_roll_results)
	print("WEIGHTED RANGE")
	_summarize_test(weighted_range_results)

func _summarize_test(results):
	print("Summary of test:")
	var num_rolls = 0
	var total_roll = 0
	var sides = 0
	for r in results:
		num_rolls += results[r]
		total_roll += r * results[r]
		sides = max(sides, r)
		#print(" >>  {0}  :  {1}".format([r, results[r]]))
	var average = float(total_roll) / float(num_rolls)
	var pct = (average / float(sides + 1)) * 100
	print("Rolled a {0}-sided die {1} times. The total was {2}. The average of all rolls was {3}, or {4}% of the range.".format([sides, num_rolls, total_roll, average, "%0.2f" % pct]))
