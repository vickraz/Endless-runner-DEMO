extends CanvasLayer


func _ready():
	hide()


#Funktionen som antopas när spelaren dör, lyssnar på spelarens dead-signal
func _on_Player_dead(distance):
	show()
	$DistanceLabel.text = "you ran " + str(distance) + " m"

func _on_RestartButton_pressed() -> void:
	get_tree().reload_current_scene()




func _on_MainMenuButton_pressed() -> void:
	pass # Replace with function body.
	#Ska ändra scen till main meny senare
