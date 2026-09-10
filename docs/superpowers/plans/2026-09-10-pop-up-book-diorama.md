# Kế Hoạch Triển Khai Chi Tiết: Pop-up Book Diorama (Sách Tranh Nổi Kỳ Ảo 3D)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Chuyển đổi toàn diện giao diện game Rừng Nhạc từ 2D phẳng sang **Sân khấu Pop-up Book Diorama 3D** chân thực như [mock-game-play.jpeg](file:///Users/anhtu/MySpace/new-piano/docs/mock-game-play.jpeg), kết hợp phím đàn cơ học lún vật lý, phù thủy nhỏ chơi đàn mini, dải ruy băng nhạc sáng 3D nối lên cây thần, và 5 màn hình liền mạch.

**Architecture:** Kiến trúc 2.5D CanvasItem Layered Diorama tối ưu native Retina, zero-overhead VRAM:
1. `DioramaStage`: Hậu cảnh rừng cổ tích 3 tầng thị sai + Cuốn sách mở mạ vàng + Chú phù thủy nhỏ cử động ngón tay + Cụm thạch anh xanh/hồng thở nhịp chậm + Rương báu trên thảm rêu.
2. `MagicRibbon`: Dải ruy băng ánh sáng huỳnh quang Bezier mang nốt nhạc phát quang uốn lượn từ phím đàn bay vút lên lá cây thần.
3. `AnimalKey` & `PianoKeyboard`: Phím đàn cơ học 3D có mặt vát trước (chamfer), bóng đổ, lún sâu Z/Y, nhún `SQUASH & STRETCH` và nảy đàn hồi.
4. `HUD` & `Overlays`: Lọ hạt sao thủy tinh 3D, nút Menu gỗ mạ vàng, bản đồ mục lục sách nổi và sân khấu bế mạc rương báu mở nắp.

**Tech Stack:** Godot Engine 4.7.2 Forward Mobile (Metal 4.0), GDScript 2.0, Tween API, Custom CanvasItem `_draw()` shaders.

## Global Constraints
- **Bảo toàn tuyệt đối 100% logic**: Đảm bảo 68/68 tiêu chí trong `game/dev/loop_test.tscn` và 23/23 tiêu chí trong `game/dev/save_test.tscn` luôn PASS.
- **Ngân sách bộ nhớ**: Steady-state memory drift phải duy trì `≤ 0.008 KB/chạm` trong `game/dev/soak_test.tscn -- --nologic`.
- **Độ trễ cảm ứng**: < 15ms phản hồi từ lúc ngón tay chạm phím tới khi âm thanh và vệt sáng phát ra.
- **Mouse Filter Rule**: Mọi Control lớp diễn hoạt (`DioramaStage`, `MagicTree`, `MagicRibbon`) BẮT BUỘC đặt `mouse_filter = Control.MOUSE_FILTER_IGNORE` (2) để không nuốt sự kiện chạm của `PianoKeyboard`.

---

### Task 1: Tích Hợp DioramaStage & MagicRibbon Vào Main Scene & Nối Luồng Dải Sáng

**Files:**
- Modify: `game/piano/piano_keyboard.gd:200-221`
- Modify: `game/main.tscn:18-38`
- Modify: `game/main.gd:15-60`
- Test: `game/dev/loop_test.tscn`

**Interfaces:**
- Consumes: `PianoKeyboard.note_played(key: int)`, `MagicTree.get_leaf_position(key: int) -> Vector2`, `Notes.color_of(key: int) -> Color`
- Produces: `PianoKeyboard.get_key_global_position(index: int) -> Vector2`, `MagicRibbon.emit_ribbon(from: Vector2, to: Vector2, color: Color)`

- [ ] **Step 1: Thêm API toạ độ toàn cục của phím trong PianoKeyboard**

Trong [piano_keyboard.gd](file:///Users/anhtu/MySpace/new-piano/game/piano/piano_keyboard.gd), bổ sung phương thức trả về tâm phím đàn theo toạ độ màn hình:
```gdscript
## Trả về toạ độ toàn cục tâm của phím đàn (để bắn dải ruy băng ma thuật từ phím)
func get_key_global_position(index: int) -> Vector2:
	if index >= 0 and index < _key_rects.size():
		return global_position + _key_rects[index].get_center()
	return global_position
```

- [ ] **Step 2: Cập nhật main.tscn thay thế StoryPanel bằng DioramaStage và thêm MagicRibbon**

Trong [main.tscn](file:///Users/anhtu/MySpace/new-piano/game/main.tscn):
1. Thay thế node `StoryPanel: ColorRect` bằng node `DioramaStage` (instance từ `res://game/diorama/diorama_stage.tscn`).
2. Thêm node `MagicRibbon` (script `res://game/diorama/magic_ribbon.gd`) đặt dưới `UI` trước `PianoKeyboard` hoặc trên `MagicTree` với `mouse_filter = 2`.

- [ ] **Step 3: Đấu nối sự kiện gõ phím trong main.gd để bắn ruy băng ánh sáng**

Trong [main.gd](file:///Users/anhtu/MySpace/new-piano/game/main.gd):
```gdscript
@onready var _diorama: DioramaStage = $UI/DioramaStage
@onready var _ribbon: MagicRibbon = $UI/MagicRibbon

func _ready() -> void:
	# ... các kết nối sẵn có ...
	_keyboard.note_played.connect(_on_key_note_played)

func _on_key_note_played(key: int) -> void:
	if _ribbon != null and _tree != null:
		var from_pos := _keyboard.get_key_global_position(key)
		var to_pos := _tree.global_position + _tree.get_leaf_position(key)
		_ribbon.emit_ribbon(from_pos, to_pos, Notes.color_of(key))
	if _diorama != null:
		_diorama.on_note_played(key)
```

- [ ] **Step 4: Chạy loop_test.tscn để kiểm tra không bị lỗi layout hay gián đoạn input**

Run: `/Users/anhtu/Desktop/Godot.app/Contents/MacOS/Godot --path . game/dev/loop_test.tscn`
Expected: Output có `=== ĐẠT ===`, toàn bộ 10 phần game loop đều [OK].

- [ ] **Step 5: Commit**

```bash
git add game/piano/piano_keyboard.gd game/main.tscn game/main.gd
git commit -m "feat(diorama): integrate DioramaStage and MagicRibbon into main scene"
```

---

### Task 2: Lời Thoại Thần Tiên & Tương Tác Phù Thủy Nhỏ (Dynamic Story Prompts)

**Files:**
- Modify: `game/diorama/diorama_stage.gd:100-145`
- Modify: `game/call_response.gd:80-120`
- Modify: `game/main.gd:70-110`
- Test: `game/dev/loop_test.tscn`

**Interfaces:**
- Consumes: `CallResponse.state_changed`, `CallResponse.prompt_note`
- Produces: `DioramaStage.set_speech_text(text: String)`, `DioramaStage.on_note_played(key: int)`

- [ ] **Step 1: Cập nhật DioramaStage với phương thức cập nhật lời thoại và nảy nhún**

Trong [diorama_stage.gd](file:///Users/anhtu/MySpace/new-piano/game/diorama/diorama_stage.gd):
```gdscript
func set_speech_text(text: String) -> void:
	if _speech_label:
		_speech_label.text = text

func on_note_played(_note_idx: int) -> void:
	if _wizard:
		var tw := create_tween().bind_node(self)
		tw.tween_property(_wizard, "position:y", _wizard.position.y - 10.0, 0.08) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(_wizard, "position:y", _wizard.position.y, 0.12) \
			.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
```

- [ ] **Step 2: Nối trạng thái gọi-đáp từ CallResponse sang bong bóng thoại**

Trong [main.gd](file:///Users/anhtu/MySpace/new-piano/game/main.gd), hiển thị lời dẫn truyện thân thiện cho bé:
- Khi cây đang hát câu gọi: `"Lắng nghe giai điệu nhé! ♫"`
- Khi đến lượt bé chạm phím: `"Bé chạm nốt %s cùng bạn %s nào!" % [Notes.name_of(note), Notes.animal_of(note)]`
- Khi bé hoàn thành trang: `"Cây thần nở hoa rồi! ★"`
- Khi bé chơi tự do: `"Thỏa thích sáng tác nhạc nào! ♬"`

- [ ] **Step 3: Chạy loop_test.tscn xác nhận lời thoại cập nhật mượt mà**

Run: `/Users/anhtu/Desktop/Godot.app/Contents/MacOS/Godot --path . game/dev/loop_test.tscn`
Expected: Output có `=== ĐẠT ===`.

- [ ] **Step 4: Commit**

```bash
git add game/diorama/diorama_stage.gd game/call_response.gd game/main.gd
git commit -m "feat(diorama): add dynamic wizard speech bubble and bounce reactions"
```

---

### Task 3: Nâng Cấp Thẩm Mỹ HUD (Lọ Hạt Sao 3D, Nút Menu Gỗ & Thanh Tiến Độ Dải Ruy Băng)

**Files:**
- Modify: `game/hud/star_jar.gd:1-80`
- Modify: `game/hud/chapter_progress.gd:1-80`
- Modify: `game/ui/hold_button.gd:1-90`
- Test: `game/dev/loop_test.tscn`

**Interfaces:**
- Consumes: `GameState.stars`, `GameState.current_page`
- Produces: Visual HUD elements matching mock aesthetics.

- [ ] **Step 1: Cập nhật StarJar vẽ lọ thủy tinh 3D với nắp bần và các hạt sao phát sáng**

Trong [star_jar.gd](file:///Users/anhtu/MySpace/new-piano/game/hud/star_jar.gd):
- Sử dụng asset `res://assets/art/batch_star_jar_*.png` hoặc dựng lọ thủy tinh cong bóng đổ trong suốt.
- Vẽ các hạt sao ngũ sắc chuyển động nhẹ bên trong lọ, kèm nhãn số lượng vàng óng.

- [ ] **Step 2: Cập nhật HoldButton (Nút Menu) với phong cách nẹp gỗ chạm trổ và vòng nạp tròn**

Trong [hold_button.gd](file:///Users/anhtu/MySpace/new-piano/game/ui/hold_button.gd):
- Vẽ nền nút bằng gỗ sồi tròn có viền mạ đồng.
- Vòng tròn giữ 2.0s phát sáng màu vàng ngọc khi ngón tay bé giữ nút.

- [ ] **Step 3: Cập nhật ChapterProgress thành thanh nẹp nhạc cụ mạ vàng**

Trong [chapter_progress.gd](file:///Users/anhtu/MySpace/new-piano/game/hud/chapter_progress.gd):
- Sử dụng biểu tượng nhạc cụ của chương (`res://assets/art/icon_flute.png` cho chương 1).
- Hiển thị các chấm ngọc tròn tương ứng từng trang của chương.

- [ ] **Step 4: Chạy loop_test.tscn xác nhận logic đếm sao, giữ menu 2s và tiến độ chương đạt chuẩn**

Run: `/Users/anhtu/Desktop/Godot.app/Contents/MacOS/Godot --path . game/dev/loop_test.tscn`
Expected: Sections 6, 7 pass, output `=== ĐẠT ===`.

- [ ] **Step 5: Commit**

```bash
git add game/hud/star_jar.gd game/hud/chapter_progress.gd game/ui/hold_button.gd
git commit -m "feat(hud): upgrade StarJar, Menu hold button and ChapterProgress to 3D diorama aesthetic"
```

---

### Task 4: Hoàn Thiện Thẩm Mỹ Màn 3 (Bản Đồ Chương Mục Lục Sách) & Màn 4 (Sân Khấu Bế Mạc Rương Báu)

**Files:**
- Modify: `game/ui/chapter_map.gd:1-120`
- Modify: `game/ui/chapter_end.gd:1-130`
- Test: `game/dev/loop_test.tscn`

**Interfaces:**
- Consumes: `GameState.chapter_unlocked(ch: int) -> bool`, `GameState.stars_for_chapter(ch: int) -> int`
- Produces: Gilded Book Index Map Overlay & Grand Celebration Pop-up Theater.

- [ ] **Step 1: Cập nhật ChapterMap dạng trang mục lục sách cổ viền mạ vàng**

Trong [chapter_map.gd](file:///Users/anhtu/MySpace/new-piano/game/ui/chapter_map.gd):
- Khung sách mở 2 trang với 3 thẻ chương 3D bằng gỗ: Chương 1 (Sáo Trúc Rừng Xanh), Chương 2 (Hồ Nước Kalimba), Chương 3 (Lâu Đài Chuông Gió).
- Các chương chưa mở có ổ khoá đồng cổ điển và dây xích nhẹ.

- [ ] **Step 2: Cập nhật ChapterEnd thành Sân Khấu Hòa Tấu Rừng Xanh**

Trong [chapter_end.gd](file:///Users/anhtu/MySpace/new-piano/game/ui/chapter_end.gd):
- Nền màn nhung đỏ mở ra, rương báu trên ngọn cây bung nắp tỏa ra luồng hào quang vàng (God Rays).
- 7 con vật và chú phù thủy nhỏ cùng đứng trên bục vinh quang nhún nhảy hòa tấu bài hát chương.

- [ ] **Step 3: Chạy loop_test.tscn xác nhận các assertion mở/đóng bản đồ và biểu diễn bế mạc**

Run: `/Users/anhtu/Desktop/Godot.app/Contents/MacOS/Godot --path . game/dev/loop_test.tscn`
Expected: Sections 7, 8, 10 pass, output `=== ĐẠT ===`.

- [ ] **Step 4: Commit**

```bash
git add game/ui/chapter_map.gd game/ui/chapter_end.gd
git commit -m "feat(ui): elevate ChapterMap and ChapterEnd to Pop-up diorama theater style"
```

---

### Task 5: Kiểm Thử Toàn Diện (Zero Regression & Soak Test) & Nghiệm Thu Trực Quan

**Files:**
- Test: `game/dev/loop_test.tscn`
- Test: `game/dev/save_test.tscn`
- Test: `game/dev/soak_test.tscn`
- Capture: `game/dev/screen_capture.tscn`

**Interfaces:**
- Consumes: Toàn bộ scene và hệ thống runtime
- Produces: Báo cáo kiểm chuẩn kỹ thuật và ảnh chụp nghiệm thu thị giác.

- [ ] **Step 1: Chạy loop_test.tscn kiểm tra toàn bộ 68 tiêu chí**

Run: `/Users/anhtu/Desktop/Godot.app/Contents/MacOS/Godot --path . game/dev/loop_test.tscn`
Expected: 68/68 tiêu chí [OK], output `=== ĐẠT ===`.

- [ ] **Step 2: Chạy save_test.tscn kiểm tra toàn bộ 23 tiêu chí lưu trữ**

Run: `/Users/anhtu/Desktop/Godot.app/Contents/MacOS/Godot --path . game/dev/save_test.tscn`
Expected: 23/23 tiêu chí [OK], output `=== ĐẠT ===`.

- [ ] **Step 3: Chạy soak_test.tscn đo lường 900 cú đập đa chạm**

Run: `/Users/anhtu/Desktop/Godot.app/Contents/MacOS/Godot --path . game/dev/soak_test.tscn -- --nologic`
Expected: Memory drift ≤ 0.008 KB/chạm (kỳ vọng ~0.006 KB), 0 ngón kẹt, 0 giọng còn kêu.

- [ ] **Step 4: Chạy screen_capture.tscn và nghiệm thu thị giác**

Run: `/Users/anhtu/Desktop/Godot.app/Contents/MacOS/Godot --path . game/dev/screen_capture.tscn`
Action: Sử dụng `view_file` xem file ảnh sinh ra, đối chiếu trực quan 1:1 với [mock-game-play.jpeg](file:///Users/anhtu/MySpace/new-piano/docs/mock-game-play.jpeg).

- [ ] **Step 5: Cập nhật walkthrough.md với đầy đủ bằng chứng kiểm thử và hình ảnh**

Cập nhật tài liệu nghiệm thu kỹ thuật và nghệ thuật.
Commit:
```bash
git add docs/
git commit -m "docs: complete Pop-up Book Diorama implementation and test verification"
```
