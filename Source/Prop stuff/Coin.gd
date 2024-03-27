extends Area2D

onready var anim_player: AnimationPlayer = get_node("AnimationPlayer")

export var value:= 1#this is the value of the coin 

	
func picked() -> void:
	anim_player.play("fade_out")#plays the death animation
	Global.characterSave.money += value#increases the players money


func _on_Coin_body_entered(body):
	picked()
