extends TextureButton
class_name SkillNode

onready var label = $Label
onready var line = $Line2D
var active = false
export var upgrade: Resource

func _ready():
	var position = rect_global_position
	var size = rect_size
	if get_parent().is_in_group("skillNodes"):#if it has a skillNode parent
		line.add_point(position+size/2)#points at the centreof itself and it parent are added to the line which is automatically drawn
		line.add_point(get_parent().rect_global_position+size/2)
		line.set_as_toplevel(true)
		line.visible = false
	$Cost.text = "Cost: "+str(upgrade.upgradeCost)
	$Name.text = upgrade.upgradeName




func _on_TextureButton_pressed():
	if upgrade.upgradeCost <= Global.characterSave.xpPoints:
		active = true
	if active:
		$Panel.show_behind_parent = true#this will make the button change color
		line.default_color = Color(1,1,0.25)#this will make the line yellow
		var skills = get_children()
		for skill in skills:
			if skill.is_in_group("skillNodes") and active:
				#if a child is a skillNode and the button is active then the child will be clickable
				skill.disabled = false
			match upgrade.upgradeType:
				"speed": Global.characterSave.speed += upgrade.upgradeValue
				"maxHealth": Global.characterSave.maxHealth += upgrade.upgradeValue
				"bulletDamage": Global.characterSave.bulletDamage += upgrade.upgradeValue
				"bulletSpeed": Global.characterSave.bulletSpeed += upgrade.upgradeValue
				"bulletAmount": Global.characterSave.bulletAmount += upgrade.upgradeValue
				
