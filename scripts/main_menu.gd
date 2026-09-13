extends Control

# Panggil 2 node AudioStreamPlayer khusus UI
@onready var sfx_start: AudioStreamPlayer = $VBoxContainer/AudioStreamPlayer2D
@onready var sfx_quit: AudioStreamPlayer = $VBoxContainer/AudioStreamPlayer2D2

func _on_start_pressed() -> void:
	sfx_start.play()
	await sfx_start.finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_textStart_pressed() -> void:
	sfx_start.play()
	await sfx_start.finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed() -> void:
	sfx_quit.play()
	await sfx_quit.finished
	get_tree().quit()

func _on_textQuit_pressed() -> void:
	sfx_quit.play()
	await sfx_quit.finished
	get_tree().quit()
