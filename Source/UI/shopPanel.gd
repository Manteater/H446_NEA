extends Panel

var upgrade: Upgrade
var upgrades = []


func _ready():
	
	upgrades = loadUpgrades()#fetches an array of upgrades from the file directory
	upgrade = getUpgrade()#gets a random upgrade from the array
	#print(upgrade)
	$cost.text = "Cost: " + str(upgrade.upgradeCost)#displays the cost of the upgrade
	$name.text= upgrade.upgradeName#displays the name of the upgrade
	$description.text = upgrade.upgradeDescription#displays the description of the upgrade

func _on_button_pressed():
	if Global.characterSave.money>= upgrade.upgradeCost:#if the player has enough money to be able to buy yhe upgrade
		Global.characterSave.money -= upgrade.upgradeCost#players money is reduced by the upgrades cost
		$button.disabled = true#the button is disabled so the player cant buy it twice
		match upgrade.upgradeType:#mathes the type of upgrade to an exceuted function
			"bulletAmount": Global.characterSave.bulletAmount+= upgrade.upgradeValue
		$name.text = "SOLD!"#displsy thay it has been sold
		$cost.text = ""
		$description.text = ""
	else:
		$button.text = "Too Poor!!!"#diplsyas that the player is too poor to be able to buy the upgrade
			
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
	randomize()#randmozises the current seed
	#print(upgrades)
	var result = load(upgrades[randi()%upgrades.size()])#chooses a random upgrade from the array
	#print(result)
	return result
