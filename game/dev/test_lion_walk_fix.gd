extends Node
## Canh lỗi wiring animation đi bộ của Sư Tử Con trong AnimatedMenuCharacters.
##
## Lỗi cũ: không có chuỗi frame đi bộ nào được nạp, nên khi _lion_state == WALK
## thì _set_lion_state() rơi vào nhánh ảnh tĩnh và _process() mượn luôn
## _lion_jump_frames — sư tử "đi bộ" bằng frame nhảy, sai nhịp hoàn toàn.
##
## Test này canh 3 điều:
##   1. Trạng thái WALK nạp texture đi bộ (lion_walk.png khi chưa có chuỗi frame).
##   2. Trạng thái WALK không bao giờ dùng texture của trạng thái JUMP.
##   3. Nếu có chuỗi frame walk trên đĩa thì _process() phải tiến qua nhiều frame.

class_name TestLionWalkFix

var _passed: int = 0
var _failed: int = 0


func _ready() -> void:
	print("\n=== Kiểm tra Wiring Animation Đi Bộ Của Sư Tử Con ===")

	var chars := AnimatedMenuCharacters.new()
	add_child(chars)
	await get_tree().process_frame

	# --- 1. Nạp texture tĩnh cho từng trạng thái ---
	chars._set_lion_state(AnimatedMenuCharacters.AnimState.IDLE)
	await get_tree().process_frame
	var idle_tex: Texture2D = chars._lion_rect.texture
	_check("Trạng thái IDLE có texture", idle_tex != null)

	chars._set_lion_state(AnimatedMenuCharacters.AnimState.WALK)
	await get_tree().process_frame
	var walk_tex: Texture2D = chars._lion_rect.texture
	_check("Trạng thái WALK có texture", walk_tex != null)

	chars._set_lion_state(AnimatedMenuCharacters.AnimState.JUMP)
	await get_tree().process_frame
	var jump_tex: Texture2D = chars._lion_rect.texture
	_check("Trạng thái JUMP có texture", jump_tex != null)

	# --- 2. WALK không được mượn texture của JUMP (lỗi cũ) ---
	_check("WALK KHÔNG dùng texture của JUMP (lỗi cũ đã được sửa)", walk_tex != jump_tex)
	_check("WALK khác IDLE (có dáng đi riêng)", walk_tex != idle_tex)

	# Đối chiếu trực tiếp với ảnh gốc trên đĩa để chắc chắn đúng file nào
	var lion_walk_src := _load_first_existing([
		"res://assets/characters/lion/lion_walk.png",
	])
	if lion_walk_src != null:
		_check("WALK trỏ đúng ảnh lion_walk.png", walk_tex == lion_walk_src)
	else:
		_check("Không tìm thấy lion_walk.png trên đĩa", false)

	# --- 3. Nếu có chuỗi frame walk thì _process() phải tiến frame ---
	chars._set_lion_state(AnimatedMenuCharacters.AnimState.WALK)
	await get_tree().process_frame
	var first_frame: Texture2D = chars._lion_rect.texture

	if not chars._lion_walk_frames.is_empty():
		print("  [GHI CHÚ] Có %d frame đi bộ trên đĩa — kiểm tra tiến frame."
			% chars._lion_walk_frames.size())
		var seen := {}
		for i in 60:
			chars._process(1.0 / 60.0)
			seen[chars._lion_rect.texture] = true
		_check("Chuỗi frame đi bộ tiến qua nhiều frame (>1)", seen.size() > 1)
		_check("Không frame nào lấy từ chuỗi nhảy",
			not _shares_any(chars._lion_rect.texture, chars._lion_jump_frames))
	else:
		print("  [GHI CHÚ] Chưa có frame đi bộ trên đĩa — kiểm tra nhánh lui về ảnh tĩnh.")
		var drifted := false
		for i in 60:
			chars._process(1.0 / 60.0)
			if chars._lion_rect.texture != first_frame:
				drifted = true
				break
		_check("Nhánh ảnh tĩnh giữ nguyên texture lion_walk.png suốt quá trình đi", not drifted)

	# --- 4. Nhảy vẫn phải dùng frame nhảy ---
	chars._set_lion_state(AnimatedMenuCharacters.AnimState.JUMP)
	await get_tree().process_frame
	if not chars._lion_jump_frames.is_empty():
		_check("JUMP vẫn dùng frame nhảy (không bị sửa hỏng)",
			_shares_any(chars._lion_rect.texture, chars._lion_jump_frames))

	print("\n=== KẾT QUẢ: %d ĐẠT, %d THẤT BẠI ===" % [_passed, _failed])
	get_tree().quit(0 if _failed == 0 else 1)


func _shares_any(tex: Texture2D, pool: Array[Texture2D]) -> bool:
	for t in pool:
		if t == tex:
			return true
	return false


func _load_first_existing(paths: Array) -> Texture2D:
	for p in paths:
		if ResourceLoader.exists(p):
			return load(p)
	return null


func _check(desc: String, condition: bool) -> void:
	if condition:
		_passed += 1
		print("  [OK ] %s" % desc)
	else:
		_failed += 1
		print("  [FAIL] %s" % desc)
