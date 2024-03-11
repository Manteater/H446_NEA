extends Panel

export var cost: int
export var upgradeName = ""
export var upgradeValue: int
export var upgradeDescription = ""
var upgrade: Upgrade
var upgrades = []

func _ready():
	$cost.text = "Cost: " + str(cost)
	$name.text= upgradeName
	$description.text = upgradeDescription
	upgrades = loadUpgrades()
	upgrade = getUpgrade()

func _on_button_pressed():
	if Global.characterSave.money>= upgrade.upgradeCost:
		Global.characterSave.money -= cost
		$button.disabled = true
		match upgrade.upgradeType:
			"bulletAmount": Global.characterSave.bulletAmount+= upgrade.upgradeValue
			
func loadUpgrades():#fetches all tres files in a folder
	var result = []#array to store the upgrades
	var path = "res://Assets/Upgrades/shopUprades/"
	var dir = Directory.new()#creates a new directory
	if dir.open(path) == OK:#checks if the file directory exists
		dir.list_dir_begin()
		var fileName = dir.get_next()#goes to the next file in the directory
		while fileName != "":#if the file has a name
			if "import" in fileName:#skip the file if it is an import file
				continue
			if ".tres" in fileName: result.append(path+fileName)#if it is a resource file then it is appened to the array
			fileName = dir.get_next()
	return result

func getUpgrade():
	randomize()
	var upgrade = upgrades[rand_range(0,upgrades.size())]
