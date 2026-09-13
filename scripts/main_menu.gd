extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_textStart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
func _on_textQuit_pressed() -> void:
	get_tree().quit()
