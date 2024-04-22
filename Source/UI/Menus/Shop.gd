extends Control


func _ready():
	set_as_toplevel(true)#this means it processes above everything else meaning that the buttons can be clicked

func _physics_process(_delta):
	$MoneyLbl.text = "Money: "+str(Global.characterSave.money)#sets the money variable to the textbox

func _on_button_pressed():
	visible = false#makes itself invisible again
	get_tree().paused = false#unpauses the game
