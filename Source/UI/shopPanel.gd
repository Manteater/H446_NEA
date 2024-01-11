extends Panel

export var cost: int
export var upgradeName = ""
export var upgradeValue: int
export var upgradeDescription = ""
var upgrade: Upgrade

func _ready():
	$cost.text = "Cost: " + str(cost)
	$name.text= upgradeName
	$description.text = upgradeDescription

func _on_button_pressed():
	if Global.characterSave.money>= cost:
		Global.characterSave.money -= cost
		$button.disabled = true
		match upgradeName:
			"extra Bullets": Global.characterSave.bulletAmount+= upgradeValue
