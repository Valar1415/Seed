extends Area2D



@export var max_health := 24
@export var health := 24

func act():
	position += Vector2.DOWN * 70

func take_damage(amount): 
	health -= amount
	%HealthBar.value = health
	%HealthLbl.text = str("health" + "/" + "max_health")
	if health <= 0:
		%DeathIcon.show()
