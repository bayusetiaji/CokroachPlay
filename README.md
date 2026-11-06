# CokroachPlay 🪳

Sketch Processing yang mendemonstrasikan **kawanan kecoa** interaktif. Kecoa muncul di posisi mouse diklik, berkeliaran secara organik, menghindari tepi layar, dan bereaksi panik saat terkena sorotan cahaya di mode malam.

Sketch ini hanya menggunakan **Processing core** — tanpa library tambahan.

---

## Fitur

- **Kawanan sekali klik** — satu klik kiri memunculkan 14 kecoa di sekitar posisi kursor.
- **Gerakan organik** — arah berubah halus memakai Perlin noise, dengan gerakan menyambar sesekali.
- **Menghindari tepi layar** — kecoa berbelok sebelum menabrak batas kanvas.
- **Mode malam** — latar gelap dengan sorotan cahaya lembut yang mengikuti kursor.
- **Reaksi terhadap cahaya** — kecoa membeku sejenak saat masuk sorotan, lalu menyambar kabur.
- **Peredupan berbasis jarak** — kecoa makin samar saat jauh dari sumber cahaya.
- **Batas jumlah** — maksimum 400 kecoa agar performa tetap stabil.

---

## Kontrol

| Input | Aksi |
|---|---|
| **Klik kiri** | Memunculkan kawanan kecoa di posisi kursor |
| **Klik kanan** | Membersihkan seluruh kecoa |
| **N / n** | Menukar mode malam ↔ mode siang |

Mode malam aktif secara default saat sketch dijalankan.

---

## Cara Menjalankan

### Lewat Processing IDE

1. Buka **Processing 4** (diuji dengan versi 4.5.7).
2. Buka folder sketch `CokroachPlay`.
3. Tekan **Run** (▶).
4. Sketch akan tampil **fullscreen**.

### Lewat command line

```powershell
& "C:\Program Files\Processing\Processing.exe" cli `
  --sketch="D:\exps\sketchbook\CokroachPlay" `
  --run
```

### Kompilasi saja

```powershell
& "C:\Program Files\Processing\Processing.exe" cli `
  --sketch="D:\exps\sketchbook\CokroachPlay" `
  --output="$env:TEMP\cokroach-build" `
  --force --build
```

> Catatan: sketch memakai `fullScreen()`. Jika ingin ukuran tetap saat pengembangan, ganti dengan `size(800, 800)` pada `setup()`.

---

## Struktur File

```
CokroachPlay/
├── CokroachPlay.pde     # Sketch utama: setup, render, input, spawn
├── Cokroach.pde         # Class Cokroach: perilaku dan penggambaran
├── README.md            # Dokumentasi ini
└── data/
    └── kecoa.png        # Sprite kecoa (39 × 64 px, latar transparan)
```

---

## Arsitektur Kode

### `CokroachPlay.pde`

| Fungsi | Keterangan |
|---|---|
| `setup()` | Fullscreen, smoothing, 60 FPS, `imageMode(CENTER)`, memuat sprite |
| `draw()` | Update semua kecoa, render sesuai mode, gambar teks bantuan |
| `drawDay()` | Latar putih, menggambar semua kecoa |
| `drawNight()` | Latar gelap, glow kursor, menggambar semua kecoa |
| `drawLightGlow()` | Glow lembut dari 18 lapisan elips dengan `blendMode(ADD)` |
| `keyPressed()` | Toggle mode malam dengan tombol N |
| `mouseClicked()` | Spawn kawanan (kiri) atau bersihkan layar (kanan) |
| `spawnSwarm()` | Menambah `SWARM_SIZE` kecoa dan menjaga batas `MAX_ROACHES` |

### `Cokroach.pde`

| Bagian | Keterangan |
|---|---|
| Constructor | Posisi acak di sekitar klik, kecepatan, skala, fase, dan noise seed |
| `live()` | Update gerakan, reaksi cahaya, hindaran tepi, dan batas kecepatan |
| `updateReaction()` | State machine reaksi terhadap sorotan |
| `displayBody()` | Rotasi, goyangan badan, tint malam, lalu menggambar sprite |

---

## Cara Kerja Perilaku

### Gerakan dasar

- Kecepatan jelajah (`cruise`) acak antara **1,2–3,2 px/frame**.
- Arah berubah memakai noise: `noise(noiseSeed + frameCount * 0.01)`.
- Setiap frame ada peluang **0,4%** untuk menyambar ke arah baru dan mengubah kecepatan jelajah.
- Kecepatan selalu di-ease kembali menuju `cruise` agar gerakan tidak liar.
- Kecoa berbelok menjauhi tepi layar sejak berada **90 px** dari batas.

### Reaksi terhadap cahaya (khusus mode malam)

```
NORMAL ──masuk sorotan──▶ FROZEN ──timer habis──▶ PANIC ──timer habis──▶ ESCAPE
   ▲                                                                        │
   └──────────────────── keluar dari radius cahaya ─────────────────────────┘
```

| State | Perilaku | Durasi |
|---|---|---|
| `NORMAL` | Berkeliling seperti biasa | — |
| `FROZEN` | Hampir berhenti, badan bergetar halus | ±0,2–0,5 detik |
| `PANIC` | Menyambar menjauhi kursor, kecepatan hingga 4× normal | ±0,5–0,9 detik |
| `ESCAPE` | Tetap menjauh sampai keluar dari lingkaran cahaya | Selama masih di cahaya |

Reaksi hanya terpicu **sekali per masuk area cahaya**. Kecoa tidak akan membeku berulang-ulang selama masih di dalam sorotan.

### Mode siang vs malam

| Aspek | Siang | Malam |
|---|---|---|
| Latar | Putih (`255`) | Gelap (`8, 10, 16`) |
| Cahaya | — | Glow mengikuti kursor, radius 240 px |
| Warna kecoa | Asli | Tint kebiruan, alpha 110–240 berdasarkan jarak |
| Reaksi cahaya | Tidak aktif | Aktif |

### Penggambaran kecoa

- Sprite diputar dengan `heading + HALF_PI` agar orientasi gambar mengikuti arah gerak.
- Badan bergoyang halus: skala X berosilasi ±3%.
- Saat `FROZEN`, posisi digeser acak ±0,6 px untuk efek bergetar.

---

## Parameter yang Bisa Diatur

Semua parameter utama ada di bagian atas `CokroachPlay.pde`:

| Parameter | Default | Fungsi |
|---|---|---|
| `SWARM_SIZE` | `14` | Jumlah kecoa yang muncul per klik |
| `MAX_ROACHES` | `400` | Batas maksimum kecoa di layar |
| `LIGHT_RADIUS` | `240` | Radius sorotan dan area reaksi di mode malam |
| `nightMode` | `true` | Mode awal saat sketch dijalankan |

Contoh perubahan:

```java
// Kawanan lebih besar
final int SWARM_SIZE = 25;

// Senter lebih lebar
final float LIGHT_RADIUS = 320;

// Mulai dari mode siang
boolean nightMode = false;
```

### Tuning perilaku di `Cokroach.pde`

| Nilai | Lokasi | Efek |
|---|---|---|
| `random(1.2, 3.2)` | Constructor | Rentang kecepatan jelajah |
| `random(0.55, 1.05)` | Constructor | Rentang ukuran badan |
| `random(12, 30)` | `updateReaction()` | Durasi membeku (frame) |
| `random(30, 52)` | `updateReaction()` | Durasi panik (frame) |
| `LIGHT_RADIUS * 0.75` | `updateReaction()` | Ambang masuk sorotan |
| `FLEE_RADIUS = 110` | Konstanta class | Jarak waspada kursor di mode siang |
| `2.2` | `live()` | Kekuatan lompatan saat panik |
| `cruise * 4.0` | `live()` | Batas kecepatan maksimum saat panik |
| `0.004` | `live()` | Peluang menyambar tiap frame |

> Semua durasi memakai satuan **frame** pada 60 FPS. Contoh: 30 frame = 0,5 detik.

---

## Troubleshooting

| Masalah | Solusi |
|---|---|
| Sprite tidak muncul | Pastikan `kecoa.png` berada di folder `data/` |
| Layar tidak fullscreen | Ganti `fullScreen()` dengan `size(800, 800)` |
| Teks bantuan terpotong | Teks memakai `height - 24`; pastikan jendela cukup tinggi |
| Performa menurun | Turunkan `MAX_ROACHES` atau `SWARM_SIZE` |
| Mode malam terlalu gelap | Perbesar `LIGHT_RADIUS` atau naikkan alpha minimum pada `displayBody()` |

---

## Ide Pengembangan

- Spawn kecoa sambil drag mouse.
- Ukuran sorotan yang bisa diubah dengan scroll.
- Efek bayangan lembut di dalam area cahaya.
- Suara langkah yang makin cepat saat panik.
- Perilaku kawanan: satu kecoa panik memicu kecoa lain di sekitarnya.

---

## Lisensi & Aset

- Kode sketch: bebas digunakan dan dimodifikasi.
- Sprite `data/kecoa.png`: milik pembuat sketch. Pastikan hak penggunaan aset sebelum mendistribusikan ulang.
