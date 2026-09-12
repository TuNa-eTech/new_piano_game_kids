extends Node

var _frames: int = 0
var _main_node: Node

func _ready() -> void:
	GameState.show_main_menu_on_launch = false
	GameState.free_play = true
	GameState.set_instrument_mode(0)

	var scene := load("res://game/main.tscn") as PackedScene
	_main_node = scene.instantiate()
	add_child(_main_node)


func _process(_delta: float) -> void:
	_frames += 1
	if _frames == 8:
		# Chụp ảnh viewport
		var img := get_viewport().get_texture().get_image()
		if img != null:
			img.save_png("res://docs/free_play_rendered.png")
			print("[OK] Đã chụp màn hình Free Play và lưu vào docs/free_play_rendered.png (Kích thước: %d x %d)" % [img.get_width(), img.get_height()])
		get_tree().quit(0)
