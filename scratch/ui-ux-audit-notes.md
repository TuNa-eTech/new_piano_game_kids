# Ghi chú kiểm tra UI/UX — tầng diorama/story (khu vực tôi tự soát)

Phạm vi: `game/diorama/`, `game/fx/`, `game/story/` — bốn agent khác soát
`game/ui/`, `game/hud/`, `game/piano/`, autoload.

## 1. Nút lật trang biến mất vĩnh viễn sau khi Chơi Tự Do (CONFIRMED)

`game/diorama/story_book.gd:275-278` (`set_freeplay_mode`) đặt
`_btn_prev.visible = not enabled` / `_btn_next.visible = not enabled`.
`game/diorama/story_book.gd:323-324` (`load_page`) lại đặt cùng hai cờ đó theo
số trang: `_btn_prev.visible = (_current_page > 0)`.

Hai nguồn cùng ghi một cờ `visible`, không ai giữ trạng thái "đang free play".
Hệ quả hai chiều:

- Bật Chơi Tự Do (ẩn nút) → có gì đó gọi `load_page` → nút **hiện lại** giữa
  lúc đang free play.
- `load_page` bật nút theo số trang → sau đó `set_freeplay_mode(false)` khi
  thoát free play đặt `visible = true` cho **cả hai** nút, kể cả ở trang đầu
  (`_current_page == 0`) hoặc trang cuối. Bé bấm nút "về trước" ở trang 1:
  `prev_page()` chặn ở `story_book.gd:385` (`_current_page <= 0`) → **nút sáng
  mà bấm không có gì xảy ra**, không kêu, không nhúc nhích.

Đường đi có thật: `screen_router.gd:229` `_on_level_selected` gọi
`GameState.set_page(page)` mà **không** tắt `GameState.free_play`. Không chỗ nào
trong router/main reset `free_play` khi điều hướng (đã grep: chỉ
`free_play_button.gd:92` và `game_state.gd:169` khi load save đặt cờ này).
`GameState.set_page` → `page_changed` → `diorama_stage.gd:571` → `load_page`.

Sửa: giữ một biến `_freeplay: bool` trong StoryBook, và tính visible ở **một**
hàm duy nhất `_refresh_page_buttons()` xét cả free play lẫn biên trang.

## 2. Lá nốt nhạc trên Cây Đậu Thần là phím đàn thứ hai không dạy được gì (CONFIRMED)

`game/diorama/musical_beanstalk.gd:106-141`: 7 lá là `Control` với
`mouse_filter = MOUSE_FILTER_STOP` và `gui_input` gọi thẳng
`AudioDirector.play_note(leaf_idx)` + `bloom_leaf(leaf_idx)`.

Nhưng vòng Gọi–Đáp chỉ nghe `_keyboard.note_played`
(`call_response.gd:63`, `call_response.gd:283`). Nên bé gõ lá:
- có tiếng, lá nở → **giống như đúng**
- mà `_step` không tiến, không được sao, cây không vươn theo chuỗi

Bé 3 tuổi thấy vật phát sáng ở giữa màn, gõ vào, nghe kêu, tưởng mình đang chơi
đúng — nhưng bài không bao giờ xong. Đây là "bế tắc mềm", trái nguyên tắc
Zero Dead Ends. `bloom_leaf` còn đặt `_leaf_states[i] = BLOOMED`
(`musical_beanstalk.gd:240`) làm lẫn với trạng thái nở thật do đáp đúng.

Sửa: hoặc phát tín hiệu để `CallResponse` xử lý như một nốt hợp lệ, hoặc bỏ
`gui_input` để lá thành trang trí (`MOUSE_FILTER_IGNORE`).

## 3. Vùng chạm nhỏ hơn chuẩn Apple Kids 88pt (CONFIRMED)

- Nút lật trang: `story_book.gd:182,197` `custom_minimum_size = Vector2(68,68)`,
  và `story_book.gd:261-266` ép `size = Vector2(68,68)` lúc layout. **68 < 88.**
  Nằm sát mép (`x = 12`), càng khó cho ngón tay trẻ.
- Lá nốt nhạc: `musical_beanstalk.gd:109` khai báo 42×42, layout còn thu xuống
  **40×40** (`musical_beanstalk.gd:191-193`). Đang là node nhận chạm (mục 2).

Đối chiếu: phần còn lại của dự án tôn trọng chuẩn này —
`hold_button.gd:25` = 88, `free_play_button.gd:12` / `auto_play_button.gd:15` = 96,
`instrument_switcher.gd:19,21` = 96/88. Nên hai chỗ trên là ngoại lệ bị bỏ sót,
không phải quy ước khác.

## 4. Chữ và số dành cho bé chưa đọc được chữ (CONFIRMED)

- `story_book.gd:292`: `_title_label.text = "Trang %d/%d: %s %s"` — số trang
  dạng phân số cho trẻ 3–6 chưa biết đọc, font 18 (`story_book.gd:102`).
- `story_book.gd:305`: `"♪ %s · %s ♪" % [title, en_title]` — nhồi **tên tiếng
  Anh** vào khung thoại khi bài không có `phrases`.
- `musical_beanstalk.gd:124`: `lbl.text = "♪\n%s" % NOTE_LETTERS[i]` với
  `NOTE_LETTERS = ["C","D","E","G","A","C","D"]` (`musical_beanstalk.gd:52`) —
  đúng loại "tên nốt C4/D4" mà README tuyên bố đã loại bỏ hoàn toàn. Font 12
  (`musical_beanstalk.gd:127`), nhỏ đến mức người lớn cũng khó đọc.

## 4b. Chữ tiếng Anh "★PLAY!★" trong bong bóng thoại menu (CONFIRMED)

`game/ui/animated_menu_characters.gd:401`: `_bubble_label.text = "★PLAY!★"`,
font 28 (`animated_menu_characters.gd:184`). Đây là màn đầu tiên bé thấy.

Đáng chú ý vì **11 bong bóng còn lại trong cùng file đều đúng quy ước** — toàn
emoji và mặt chữ: `"🐾"` (`:312`), `"👉🎵"` (`:378`), `"🎶"` (`:440`),
`"🌟🎶✨"` (`:463`), `"(>o<)!"` (`:513`), `"O_O?!"` (`:523`), `"💖✨"` (`:531`),
`"Zzz..."` (`:568`), `"✨(^v^)!"` (`:631`). Chỉ một dòng lọt chữ tiếng Anh.
Thay bằng `"▶"` hoặc `"👉🎵"` là khớp lại với phần còn lại.

Ngoài ra `level_select.gd:289` `"Chương %d: %s"` cũng là số + chữ cho bé chưa
đọc được — cùng loại với mục 4, nhưng file này thuộc agent khác nên tôi chỉ ghi
lại để đối chiếu, không kết luận.

Các màn dành cho **người lớn** thì có chữ là đúng, không tính lỗi:
`parental_corner.gd:136,150,230` và `parental_gate.gd:152`.

## 5. Cờ chết chưa dọn (xác nhận lại điều docs đã ghi)

`screen_router.gd:35` `enable_chest_before_concert = false`, chỉ được đọc ở
`screen_router.gd:280`. `docs/architecture-refactor.md` đã ghi đây là câu hỏi
mở chưa trả lời — vẫn còn nguyên.

## 0. NGHIÊM TRỌNG NHẤT — Chương 3 khoá vĩnh viễn, không cách nào mở (CONFIRMED)

Đây là ngõ cụt thật sự, đúng thứ mà nguyên tắc Zero Dead Ends cấm. Số học:

- `game/songbook.gd`: `SONGS` có đúng **10** bài (đếm `"vietnamese_title"` = 10),
  dù `game/melodies.gd` có **15** giai điệu (`PackedInt32Array` = 15).
- `chapters.gd:35-36`: `total_pages()` trả `Songbook.count()` khi > 0 → **10**,
  chứ không phải `count() * pages_per_chapter()` = 15. Comment ở
  `chapters.gd:34` đã tự ghi "10 bài hát (2 chương x 5 bài)" — tức là người viết
  biết, nhưng `TABLE` ở `chapters.gd:16-19` vẫn khai **3** chương.
- `game_state.gd:129`: `set_page` kẹp `page_index` vào `[0, total_pages()-1]` =
  **[0, 9]**. Nên `max_page_reached` không bao giờ vượt **9**.
- `chapters.gd:39-40`: `first_page_of(2)` = `2 * 5` = **10**.
- `game_state.gd:142-143`: `chapter_unlocked(2)` là `max_page_reached >= 10`,
  mà trần của `max_page_reached` là 9 → **luôn luôn false, mãi mãi**.

Hệ quả bé nhìn thấy: `chapter_map.gd:121` vẽ đủ **3** thẻ chương (mảng
`card_rects` ở `chapter_map.gd:115-119` có 3 ô). Thẻ Chương 3 hiện diện, có ổ
khoá vẽ tay (`chapter_card.gd:143-145`), bé chơi hết mọi bài mà nó **không bao
giờ mở**. README lại quảng cáo "3 Chương Sách Nổi & 15 Bài Hát".

Còn một hệ quả thứ hai: `game_state.gd:122` tính hết chương bằng
`page_in_chapter() == Melodies.PAGES_PER_CHAPTER - 1` (`melodies.gd:57` = 5),
tức `page_index % 5 == 4`. Với 10 trang thì `advance_page` ở trang 9 quay vòng
về `(9+1) % 10 = 0`, phát `chapter_completed(1)` — hợp lý. Nhưng
`chapters.gd:43-44` `of_page(page)` = `page / 5` kẹp trong `[0,2]`, nên chương 3
không bao giờ là chương "hiện tại" của bất kỳ trang nào trong 10 trang.

Sửa: chọn một trong hai — bổ sung 5 bài còn thiếu vào `Songbook.SONGS` cho khớp
15 giai điệu, hoặc hạ `Chapters.TABLE` xuống 2 chương cho khớp 10 bài. Đừng để
`total_pages()` lấy từ `Songbook` mà `first_page_of()` lấy từ hằng số 5 —
hai nguồn sự thật lệch nhau chính là gốc lỗi.

## 6. Hai vùng tương tác trên sân khấu đã chết hẳn (CONFIRMED)

`diorama_stage.gd:380-393` `_setup_interactions()` nối `gui_input` cho 5 hotspot.
Nhưng hai trong số đó không bao giờ nhận được chạm — Control ẩn không tham gia
bắt input trong Godot:

- **Nền sách** (`_book_spread`): `diorama_stage.gd:94` đặt `visible = false`, và
  `diorama_stage.gd:383` còn đặt `mouse_filter = MOUSE_FILTER_IGNORE`. Hai lý do
  độc lập khiến `_on_book_gui_input` (`diorama_stage.gd:420`) không bao giờ chạy.
  Chết theo là cả nhánh Chơi Tự Do trong `interact_book`
  (`diorama_stage.gd:504-517`): nổ bong bóng nốt nhạc, `play_ting`, hạt lấp lánh,
  `prop_interacted.emit("bubble")`. Đây chính là tính năng "chạm nổ bong bóng nốt
  nhạc ngũ sắc" mà README quảng cáo cho màn Chơi Tự Do. Người gọi duy nhất còn
  lại là `game/dev/interactive_diorama_test.gd:59` — nên **test dev vẫn xanh**
  trong khi bé không chạm được. Kiểu lỗi tệ nhất: có test bảo vệ một đường chết.

- **Phù thủy** (`_wizard`): `diorama_stage.gd:179` đặt `visible = false` (comment
  ghi rõ đã có phù thủy vẽ sẵn trong tranh nền), nhưng `diorama_stage.gd:384` vẫn
  đặt `mouse_filter = STOP` và `diorama_stage.gd:389` vẫn nối `gui_input`. Toàn bộ
  `interact_wizard` (`diorama_stage.gd:425-453`) là mã chết.

Bé chạm vào hình phù thủy đang thấy rõ trong tranh → không có gì xảy ra, vì đó
chỉ là pixel nền, còn node bắt chạm thì đã ẩn.

Sửa: nếu muốn giữ tương tác, đặt một hotspot **hiện** (alpha 0) trùng vị trí phù
thủy trong tranh; nếu không, xoá `mouse_filter`/`gui_input`/`interact_*` cho gọn.

## 7. Hotspot thạch anh hồng tím hẹp hơn chuẩn 88pt (CONFIRMED)

`diorama_stage.gd:253-255`: `mag_w = 1280 * 52/1024` = **65.0px** rộng
(cao 100.7px). Là node nhận chạm thật (`diorama_stage.gd:386`, `:391`).
Hai hotspot còn lại đạt chuẩn — thạch anh xanh 107×119
(`diorama_stage.gd:237-239`), rương cỏ 112×125 (`diorama_stage.gd:245-247`).
Nó lại nằm ngay cạnh rương (`diorama_stage.gd:256`, cách 28px), nên ngón tay bé
dễ bấm trúng rương thay vì thạch anh.

## 8. `Songbook.is_valid` không kiểm biên trên (CONFIRMED, mức độ thấp)

`songbook.gd:467-468`: `return SONGS.size() > 0 and index >= 0` — thiếu
`index < SONGS.size()`. Đối chiếu `notes.gd:53` và `chapters.gd:26` đều kiểm đủ
hai đầu, nên đây là sơ sót chứ không phải quy ước.

Ghép với `songbook.gd:472-475` `get_song` dùng `posmod(index, SONGS.size())`:
một trang ngoài phạm vi **không báo lỗi** mà âm thầm quay vòng sang bài khác.
Năm chỗ gọi trong `call_response.gd` (`:86,:100,:109,:244,:306`) vì thế luôn
thấy "hợp lệ". Hiện tại `set_page` đã kẹp `page_index` vào `[0,9]` nên chưa lộ
ra, nhưng nếu sửa mục 0 bằng cách nâng số chương/bài thì đây là chỗ lỗi sẽ ẩn
mình thay vì kêu lên. Sửa: thêm `and index < SONGS.size()`.

## 9. Cây làm việc đang thiếu 20 file `assets/placeholder/` — hai màn sẽ mất phông nền (CONFIRMED)

Không phải lỗi trong mã, mà là trạng thái cây làm việc — nhưng hậu quả là lỗi UI
thật, nên ghi vào đây. **Chưa sửa, chờ bạn quyết** (có thể bạn đang cố ý xoá).

`git status` báo 20 file tracked bị xoá (chưa commit), trong đó:
- `assets/placeholder/art/placeholder_bg_chapter_map.jpg`
- `assets/placeholder/art/placeholder_bg_chest_reward.jpg`
- 7 file `assets/placeholder/notes/note_*.wav` + `music/pad_c_am_f_g.wav`

Cả thư mục `assets/placeholder/` giờ **không còn trên đĩa** (`test -d` → absent).

Vấn đề: hai tấm .jpg đó là **mắt cuối** của chuỗi dự phòng cho hai màn:
- `chapter_map.gd:67-70`: thử `tex_bg_chapter_forest.png` → không có
  (đã kiểm: absent), rồi thử placeholder → cũng không còn.
- `chest_reward.gd:95-98`: y hệt với `tex_bg_chest_forest_diorama.png`.

Cả hai nhánh trượt thì `_bg_texture` giữ `null`, và `chapter_map.gd:75-76` chỉ gán
texture khi `!= null` → `TextureRect` rỗng. Hai màn Bản Đồ Chương và Rương Báu
mất sạch phông nền, chỉ còn các thẻ/nhân vật trôi trên nền trống.

`docs/architecture-refactor.md` ghi "Đã đo trực tiếp: cả hai màn vẫn có
`_bg_texture` 1376×768" — phép đo đó giờ **không còn đúng**. Nó vẫn có thể trông
đúng khi bạn mở editor lúc này, vì `.godot/imported/` còn cache
`placeholder_bg_chapter_map.jpg-*.ctex` và `placeholder_bg_chest_reward.jpg-*.ctex`
(đã kiểm: còn 4 file cache). Nhưng `.gitignore` loại `.godot/`, nên máy khác
clone về hoặc CI build sạch sẽ **không có** cache đó, và cả hai file `.import`
cũng đã bị xoá theo — tức là bản build sạch sẽ hiện lỗi này ra.

Phục hồi nếu là xoá ngoài ý muốn: `git checkout -- assets/placeholder`.
Nếu cố ý xoá thì phải dựng asset thật (`tex_bg_chapter_forest.png`,
`tex_bg_chest_forest_diorama.png`) trước, vì hiện không còn gì đỡ.

Ghi chú thêm: `audio_director.gd:39,141` xác nhận đường dẫn `placeholder/music/`
và `placeholder/notes/` **đã được gỡ khỏi mã** — nên 8 file .wav bị xoá không gây
lỗi tiếng. Chỉ hai file .jpg là còn người dùng.

## Sạch (đã kiểm, không có lỗi)

- `await` treo trên node đã giải phóng: không có `await` nào trong
  `game/diorama/`, `game/fx/`, `game/story/`, `game/melodies.gd` (đã grep).
  `chest_reward.gd` có 1 `await` nhưng 7 lần bảo vệ hợp lệ — thuộc agent khác.
- `_flip_to_page` (`story_book.gd:390-410`) dùng `create_tween().bind_node(self)`
  cho cả hai chặng, nên tween chết theo node; cờ `_is_flipping` được nhả ở
  `story_book.gd:408`. Có chặn tái nhập ở `story_book.gd:378,385`. Không kẹt.
- Không có TODO/FIXME/HACK nào trong mã phát hành (đã grep toàn `game/` trừ `dev/`).
