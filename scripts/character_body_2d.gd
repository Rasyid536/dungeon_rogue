extends CharacterBody2D

# ==============================================================================
# --- VARIABEL PENGATURAN (Bisa diatur di Inspector) ---
# ==============================================================================
@export var tile_size: int = 16    # Ukuran 1 kotak/tile dalam piksel (misal 16x16)
@export var move_speed: float = 80.0 # Kecepatan animasi pergerakan antar ubin

# ==============================================================================
# --- VARIABEL STATUS & ANTREAN (QUEUE) ---
# ==============================================================================
var is_moving: bool = false         # Menandai apakah player SEDANG meluncur antar tile
var move_queue: Array[Vector2i] = [] # "Antrean": Menyimpan urutan arah tombol yang kamu tekan
var target_tile: Vector2i           # Koordinat grid (X, Y) yang sedang/akan dituju player

# Mengambil referensi ke node TileMapLayer yang sejajar dengan node Player
@onready var tilemap: TileMapLayer = $".."

# ==============================================================================
# --- FUNGSI INSIALISASI (Dipanggil saat game baru mulai) ---
# ==============================================================================
func _ready() -> void:
	# Tunggu 1 frame dulu agar TileMap selesai men-generate dungeon
	await get_tree().process_frame
	
	# Pindahkan posisi awal player ke dalam ruangan dungeon
	spawn_di_ruangan()

func spawn_di_ruangan() -> void:
	# Ambil semua daftar posisi ubin/tile yang sudah digambar di map
	var used_cells = tilemap.get_used_cells()
	
	# Cari satu per satu sampai ketemu ubin yang merupakan TILE_LANTAI (0, 0)
	for pos in used_cells:
		if tilemap.get_cell_atlas_coords(pos) == Vector2i(0, 0):
			target_tile = pos # Tetapkan koordinat grid tujuan awal
			
			# Konversi koordinat grid (misal: 5, 8) ke posisi piksel nyata di layar
			global_position = tilemap.map_to_local(pos)
			break # Hentikan pencarian setelah posisi spawn ditemukan

# ==============================================================================
# --- FUNGSI MEMBACA INPUT DARI KEYBOARD ---
# ==============================================================================
func _unhandled_input(event: InputEvent) -> void:
	var dir = Vector2i.ZERO # Menampung arah yang ditekan (default: diam)
	
	# Deteksi tombol arah mana yang ditekan pemain
	if event.is_action_pressed("ui_right"):
		dir = Vector2i.RIGHT # Berarti Vector2i(1, 0) -> Kanan
	elif event.is_action_pressed("ui_left"):
		dir = Vector2i.LEFT  # Berarti Vector2i(-1, 0) -> Kiri
	elif event.is_action_pressed("ui_down"):
		dir = Vector2i.DOWN  # Berarti Vector2i(0, 1) -> Bawah
	elif event.is_action_pressed("ui_up"):
		dir = Vector2i.UP    # Berarti Vector2i(0, -1) -> Atas

	# Jika ada tombol arah yang ditekan DAN isi antrean belum penuh (maksimal 3 input)
	if dir != Vector2i.ZERO and move_queue.size() < 3:
		move_queue.append(dir) # Masukkan perintah jalan ini ke BAGIAN BELAKANG antrean

# ==============================================================================
# --- FUNGSI UTAMA (Berjalan terus-menerus setiap frame game) ---
# ==============================================================================
func _process(delta: float) -> void:
	# --- TAHAP 1: MENGAMBIL PERINTAH DARI ANTREAN (QUEUE) ---
	# Jika player SEDANG DIAM dan ADA PERINTAH jalan di dalam antrean:
	if not is_moving and move_queue.size() > 0:
		# Ambil perintah paling depan/pertama dari antrean (Prinsip FIFO: First-In, First-Out)
		var next_dir = move_queue.pop_front() 
		
		# Hitung lokasi tile baru (lokasi sekarang + arah pergerakan)
		var next_tile = target_tile + next_dir
		
		# Cek apakah tile tujuan aman untuk diinjak (bukan tembok/area kosong)
		if bisa_jalan(next_tile):
			target_tile = next_tile # Tetapkan target baru
			is_moving = true        # Ubah status menjadi SEDANG BERGERAK

	# --- TAHAP 2: ANIMASI MELUNCUR (INTERPOLASI) ---
	# Jika status player SEDANG BERGERAK:
	if is_moving:
		# Cari posisi piksel nyata di layar dari target tile tujuan
		var target_pos = tilemap.map_to_local(target_tile)
		
		# Bikin gerakan meluncur mulus (lerp) dari posisi lama menuju target_pos
		global_position = global_position.lerp(target_pos, move_speed * delta)
		
		# Jika jarak player dengan titik tujuan sudah sangat dekat (kurang dari 0.5 piksel)
		if global_position.distance_to(target_pos) < 0.5:
			global_position = target_pos # Kunci posisinya tepat di tengah tile
			is_moving = false            # Ubah status kembali menjadi DIAM

# ==============================================================================
# --- FUNGSI PENGECEKAN TABRAKAN (DINDING / AREA KOSONG) ---
# ==============================================================================
func bisa_jalan(tile_pos: Vector2i) -> bool:
	# Ambil data ID ubin dan koordinat gambar di Atlas TileSet pada posisi yang ingin dituju
	var atlas_coords = tilemap.get_cell_atlas_coords(tile_pos)
	var tile_id = tilemap.get_cell_source_id(tile_pos)
	
	# Jika ID == -1, artinya area tersebut adalah luar dungeon / ubin kosong (TIDAK BISA DIINJAK)
	if tile_id == -1:
		return false
		
	# Jika gambarnya adalah TILE_TEMBOK yang ada di koordinat Vector2i(2, 0) di TileSet
	if atlas_coords == Vector2i(2, 0):
		return false # TIDAK BISA DIINJAK
		
	# Jika lolos dari semua cegatan di atas, berarti ubin ini aman (BISA DIINJAK)
	return true
