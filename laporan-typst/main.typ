#import "@preview/charged-ieee:0.1.4": ieee

#set text(lang: "id")

#show: ieee.with(
  title: [Studi Ablasi RNN, LSTM, dan GRU dibandingkan ANN untuk Prediksi Trafik Seluler Kota Milan],
  abstract: [
    Prediksi trafik internet per jam membantu operator mengalokasikan sumber daya jaringan. Studi ini mengukur seberapa besar kinerja ANN, RNN, LSTM, dan GRU bergantung pada pilihan hyperparameter. Data berasal dari Telecom Italia Big Data Challenge, dengan kotak Duomo sebagai acuan dan Politecnico di Milano sebagai lokasi uji generalisasi. Lima faktor wajib (panjang jendela, ukuran hidden, jumlah lapisan, _learning rate_, kelompok fitur) dan dua faktor pilihan (dropout dan horizon) diubah satu per satu, masing-masing dengan tiga seed. Pada horizon 1 jam, GRU dan RNN konsisten terbaik. Setelah pemilihan konfigurasi dengan val MAE, GRU mencapai test MAE 220,3 ± 10,6 pada Duomo dan ANN membaik 19% (313,9 menjadi 253,9). Penggabungan semua nilai terbaik justru memperburuk RNN dan GRU, sehingga faktor-faktor saling memengaruhi. _Learning rate_ dan fitur call+sms paling berpengaruh, panjang jendela hampir tidak berpengaruh, dan dropout merugikan. Semua model menang dari baseline "minggu lalu" (467,6) pada horizon 1 jam, tetapi kalah pada horizon 24 jam dan pada minggu Natal di Politecnico.
  ],
  authors: (
    (name: "Noel Kevin Julian Simanjuntak", department: [NIM 124400094], organization: [Teknik Telekomunikasi, ITERA], email: "noel.124400094@student.itera.ac.id"),
  ),
  index-terms: ("prediksi trafik seluler", "RNN", "LSTM", "GRU", "studi ablasi"),
  bibliography: bibliography("references.bib", title: [Pustaka]),
  figure-supplement: [Gambar],
)

= Pendahuluan
Operator seluler perlu meramal trafik per sel agar kapasitas dan energi dapat diatur sebelum beban datang. Model sekuensial seperti RNN, LSTM @hochreiter1997lstm, dan GRU @cho2014gru memproses jendela data langkah demi langkah, sedangkan ANN memperlakukan jendela sebagai satu vektor. Pertanyaan studi ini: seberapa besar kinerja keempat model bergantung pada pilihan hyperparameter? Studi ablasi, yaitu mengubah satu faktor dalam satu waktu, dipakai agar pengaruh tiap faktor dapat dipisahkan.

Kontribusi laporan ini: (1) ablasi tujuh faktor pada empat model dengan tiga seed, (2) pemilihan konfigurasi terbaik dengan data validasi dan pengujian pada minggu test dan Natal, dan (3) uji generalisasi ke lokasi lain di Milan.

= Data dan Metode

== Dataset
Data berasal dari Telecom Italia Big Data Challenge @barlacchi2015milan dalam versi per jam @zhang2021fedda, dengan fitur aktivitas internet (net), panggilan (call), dan SMS (sms). Kotak acuan adalah Duomo (5060). Lokasi kelompok adalah kode 4, Politecnico di Milano (kotak 5772).

== Pembagian Data dan Praproses
Data dibagi menurut waktu, tidak diacak, karena pengacakan membuat model melihat masa depan saat latihan. Train: 11 Nov–8 Des (672 sampel per jam), validasi: 9–15 Des, test: 16–22 Des, dan Natal: 23–29 Des. Minggu 4–10 Nov hanya menjadi konteks jendela. Fitur distandarisasi dengan rata-rata dan simpangan baku sebelum 9 Des, sehingga tidak ada kebocoran dari validasi atau test. Jam dan hari dikodekan dengan sin dan cos. Input berupa jendela $W$ jam terakhir dan target adalah $H$ jam berikutnya.

== Model dan Konfigurasi Acuan
ANN meratakan jendela lalu melewati lapisan tersembunyi ReLU. RNN, LSTM, dan GRU memakai hidden state terakhir untuk prediksi. Dropout dipasang setelah lapisan tersembunyi ANN, antar lapisan rekuren, dan sebelum lapisan output. Ukuran hidden acuan dipilih agar jumlah parameter sekitar 5 ribu (ANN 6.497, RNN 5.305, LSTM 5.578, GRU 5.397). Konfigurasi acuan ada di @tab:acuan.

#figure(
  caption: [Konfigurasi acuan],
  placement: top,
  table(
    columns: 2,
    align: left,
    stroke: none,
    table.hline(),
    table.header([*Hyperparameter*], [*Nilai acuan*]),
    table.hline(stroke: 0.5pt),
    [Panjang jendela $W$], [24 jam],
    [Horizon], [1 jam],
    [Ukuran hidden], [ANN 32, RNN 68, LSTM 33, GRU 38],
    [Jumlah lapisan], [ANN 2, rekuren 1],
    [Fitur], [net, call, sms, jam, hari (7)],
    [Optimizer, _learning rate_], [Adam, $10^(-3)$],
    [_Batch size_], [64],
    [_Early stopping_], [_patience_ 30, maks. 300 epoch],
    table.hline(),
  ),
) <tab:acuan>

== Protokol Ablasi dan Evaluasi
Setiap eksperimen mengubah satu faktor dari acuan. Bagian A menguji $W$, ukuran hidden, jumlah lapisan, _learning rate_, dan kelompok fitur. Bagian B menguji dropout (juga pada 2 lapisan) dan horizon. Setiap konfigurasi dilatih dengan seed 0, 1, 2 dan dilaporkan sebagai rata-rata ± simpangan baku. Metrik adalah MAE, RMSE, dan MAPE pada skala asli; tabel memuat MAE. _Early stopping_ memakai val MSE agar adil antar fungsi loss. Konfigurasi terbaik dipilih dengan val MAE, sedangkan test dan Natal hanya untuk pelaporan. Konfigurasi yang identik dengan run sebelumnya disalin, tidak dilatih ulang. Seluruh run memakai CPU dengan total waktu training sekitar 181 menit.

= Hasil

== Baseline Naif dan Acuan
@tab:acuanhasil menunjukkan bahwa pada horizon 1 jam semua model acuan mengalahkan ketiga baseline naif pada minggu validasi dan test. Baseline terkuat pada test adalah "minggu lalu" (467,6). Pada minggu Natal, "nilai terakhir" (431,2) lebih baik daripada ANN, LSTM, dan GRU, dan hanya RNN yang setara.

#figure(
  caption: [Acuan dan baseline naif di Duomo, horizon 1 jam (MAE, 3 seed).],
  placement: top,
  text(size: 7pt, table(
    columns: 4,
    align: (left, center, center, center),
    stroke: none,
    table.hline(),
    table.header([*Metode*], [*Val*], [*Test*], [*Natal*]),
    table.hline(stroke: 0.5pt),
    [ANN], [250,1±8,6], [313,9±9,9], [675,7±44,6],
    [RNN], [206,1±7,4], [229,6±5,1], [421,2±2,4],
    [LSTM], [230,5±12,2], [273,6±25,4], [586,0±56,8],
    [GRU], [207,5±3,8], [237,2±9,3], [468,2±21,8],
    table.hline(stroke: 0.5pt),
    [Naif: kemarin], [595,3], [552,2], [921,5],
    [Naif: minggu lalu], [492,8], [467,6], [1426,2],
    [Naif: nilai terakhir], [662,6], [600,9], [431,2],
    table.hline(),
  )),
) <tab:acuanhasil>

== Ablasi Wajib
@tab:a merangkum test MAE untuk faktor A1–A5.

*A1 (panjang jendela).* Jendela lebih panjang tidak selalu lebih baik. Test MAE ANN naik dari 271,1 ($W$=6) menjadi 402,0 ($W$=168), sejalan dengan parameter ANN yang membengkak dari 2.465 menjadi 38.753 pada hanya 672 sampel train. RNN dan GRU hampir datar karena bobotnya dipakai ulang di tiap langkah, sehingga parameter tetap 5.305 dan 5.397. ANN paling sensitif. Hasil GRU pada $W$=48 dan 168 nyaris identik, yang menunjukkan bahwa masukan lebih tua dari sekitar 48 jam hampir tidak memengaruhi hidden state terakhir (dugaan, tidak diuji langsung).

*A2 (ukuran hidden).* Model rekuren yang lebih besar membaik tanpa tanda overfit sampai hidden 128, kemungkinan karena _early stopping_ ikut meregularisasi. LSTM paling sensitif (295,3 menjadi 245,6) dan GRU turun dari 246,9 menjadi 220,3. ANN praktis datar dengan simpangan baku besar. Ongkosnya tinggi: GRU dengan hidden 128 memiliki 52.737 parameter dibanding 3.969 pada hidden 32, untuk selisih test MAE sekitar 12 yang berada di sekitar satu simpangan baku.

*A3 (jumlah lapisan).* Menumpuk lapisan tidak membantu. RNN dan GRU setara pada 1 dan 2 lapis lalu memburuk pada 3 lapis, sedangkan LSTM memburuk terus (273,6; 308,9; 412,6). Epoch rata-rata turun seiring kedalaman pada RNN (164 menjadi 96), sehingga _early stopping_ terpicu lebih cepat pada model yang lebih dalam.

*A4 (_learning rate_).* Pada $10^(-4)$ semua 12 run berhenti tepat di epoch 300, jadi training belum konvergen dan angkanya mencerminkan batas epoch, bukan kemampuan model. LSTM dan GRU paling sensitif (LSTM 373,5; 273,6; 225,8) dan terbaik pada $10^(-2)$. RNN terbaik pada $10^(-3)$. Pada $10^(-2)$ hanya ANN yang tidak stabil antar seed (simpangan baku 53,2); RNN, LSTM, dan GRU tetap stabil.

*A5 (kelompok fitur).* Trafik call dan SMS paling berguna bagi model rekuren: RNN turun dari 254,1 (net saja) menjadi 227,6 ± 2,2. Fitur waktu tidak konsisten: RNN dan GRU membaik pada validasi tetapi tidak jelas pada test, dan ANN justru memburuk karena setiap kolom fitur menambah 768 parameter. Fitur waktu juga memperburuk MAE Natal pada tiga dari empat model (dugaan: model mempelajari pola hari biasa).

#figure(
  caption: [Test MAE Duomo untuk ablasi A1–A5 (rata-rata ± simpangan baku, 3 seed). Acuan: $W$=24, hidden acuan, 1 lapis rekuren, $10^(-3)$, fitur semua.],
  placement: top,
  text(size: 7pt, table(
    columns: 5,
    align: (left, center, center, center, center),
    stroke: none,
    table.hline(),
    table.header([*Setelan*], [*ANN*], [*RNN*], [*LSTM*], [*GRU*]),
    table.hline(stroke: 0.5pt),
    table.cell(colspan: 5)[_A1: panjang jendela $W$ (jam)_],
    [6], [271,1±13,9], [228,6±5,4], [276,3±14,7], [249,8±1,4],
    [12], [308,8±11,6], [233,2±11,2], [302,7±17,4], [246,1±13,5],
    [24], [313,9±9,9], [229,6±5,1], [273,6±25,4], [237,2±9,3],
    [48], [333,1±20,3], [224,5±11,7], [304,4±27,1], [237,1±10,6],
    [168], [402,0±12,5], [233,5±4,8], [292,8±20,0], [237,2±10,6],
    table.cell(colspan: 5)[_A2: ukuran hidden_],
    [16], [312,1±19,3], [253,3±9,3], [295,3±13,1], [246,9±10,4],
    [32], [313,9±9,9], [245,2±3,7], [290,8±20,9], [232,7±5,1],
    [64], [316,0±24,1], [240,9±15,0], [269,2±12,7], [225,0±12,7],
    [128], [296,4±32,0], [234,6±18,6], [245,6±6,7], [220,3±10,6],
    table.cell(colspan: 5)[_A3: jumlah lapisan_],
    [1], [311,8±11,0], [229,6±5,1], [273,6±25,4], [237,2±9,3],
    [2], [313,9±9,9], [228,4±8,2], [308,9±20,6], [239,2±6,4],
    [3], [299,8±25,1], [245,5±19,1], [412,6±54,2], [264,2±11,4],
    table.cell(colspan: 5)[_A4: learning rate_],
    [$10^(-4)$], [339,5±22,3], [287,9±7,3], [373,5±14,3], [356,3±7,9],
    [$10^(-3)$], [313,9±9,9], [229,6±5,1], [273,6±25,4], [237,2±9,3],
    [$10^(-2)$], [309,4±53,2], [240,4±6,3], [225,8±4,2], [215,7±10,9],
    table.cell(colspan: 5)[_A5: kelompok fitur_],
    [net], [271,7±13,9], [254,1±1,7], [284,1±19,3], [270,5±10,9],
    [net+call+sms], [317,2±10,1], [227,6±2,2], [262,7±10,9], [250,7±9,3],
    [net+waktu], [296,0±9,5], [244,9±22,1], [292,6±25,1], [239,7±25,4],
    [semua], [313,9±9,9], [229,6±5,1], [273,6±25,4], [237,2±9,3],
    table.hline(),
  )),
) <tab:a>

== Ablasi Pilihan
*B2 (dropout).* Alasan memilih: masalah utama Bagian A adalah overfit pada 672 sampel dan variansi antar seed, dan dropout adalah regularisasi paling langsung untuk itu. Hipotesis yang dirumuskan sebelum run: (H1) ANN paling diuntungkan, (H2) LSTM kedua paling diuntungkan, (H3) RNN dan GRU hampir tidak berubah, (H4) pada 1 lapis efek dropout pada model rekuren mendekati nol, dan (H5) keuntungan keseluruhan kecil. Hasilnya, H1 ditolak: ANN paling dirugikan (313,9 menjadi 411,6 pada dropout 0,5). H2 hanya sebagian: simpangan baku LSTM mengecil (25,4 menjadi 16,6) tetapi rata-rata tidak berubah nyata. H3 salah untuk RNN (+31 pada 0,2). H4 ditolak karena dropout juga dipasang sebelum lapisan output sehingga aktif pada 1 lapis. H5 benar dalam arah, tetapi keuntungannya nol. Pada 2 lapis, dropout bahkan lebih merugikan (RNN +30 pada 0,2 dan LSTM +46). Dugaan: model hanya 5–15 ribu parameter dan _early stopping_ sudah meregularisasi, sehingga dropout menyebabkan underfit.

*B6 (horizon).* Horizon dipilih karena menghubungkan model dengan baseline "minggu lalu". Hipotesis ini dirumuskan setelah run, jadi diperlakukan sebagai ekspektasi umum: galat naik seiring horizon. Ekspektasi itu terpenuhi dan kenaikan paling tajam terjadi dari 1 ke 6 jam (RNN 229,6 menjadi 427,6). Model memprediksi seluruh $H$ jam sekaligus, sehingga MAE adalah rata-rata galat langkah 1 sampai $H$ dan dihitung dengan cara yang sama untuk baseline. Peringkat berubah per horizon: pada 6 jam ANN terbaik (395,7), dan pada 24 jam ANN terburuk. Pada 24 jam semua model (486,4–526,8) kalah dari baseline "minggu lalu" (466,1), karena jendela 24 jam tidak mencakup siklus mingguan. Baseline untuk 6 jam tidak dihitung, sehingga titik silang hanya dapat dipastikan berada antara 6 dan 24 jam.

#figure(
  caption: [Test MAE Duomo untuk ablasi pilihan B2 dan B6 (3 seed). Pada 2 lapis, nilai ANN sama dengan 1 lapis karena acuan ANN sudah 2 lapis.],
  placement: top,
  text(size: 7pt, table(
    columns: 5,
    align: (left, center, center, center, center),
    stroke: none,
    table.hline(),
    table.header([*Setelan*], [*ANN*], [*RNN*], [*LSTM*], [*GRU*]),
    table.hline(stroke: 0.5pt),
    table.cell(colspan: 5)[_B2: dropout, rekuren 1 lapis_],
    [0,0], [313,9±9,9], [229,6±5,1], [273,6±25,4], [237,2±9,3],
    [0,2], [330,3±46,9], [260,3±13,1], [264,6±16,6], [225,0±12,8],
    [0,5], [411,6±8,0], [260,2±6,4], [289,1±10,3], [273,6±20,5],
    table.cell(colspan: 5)[_B2: dropout, rekuren 2 lapis_],
    [0,0], [313,9±9,9], [228,4±8,2], [308,9±20,6], [239,2±6,4],
    [0,2], [330,3±46,9], [258,9±11,2], [354,6±52,5], [255,7±21,5],
    [0,5], [411,6±8,0], [271,6±2,2], [395,4±49,5], [296,8±33,1],
    table.cell(colspan: 5)[_B6: horizon (jam)_],
    [1], [313,9±9,9], [229,6±5,1], [273,6±25,4], [237,2±9,3],
    [6], [395,7±9,1], [427,6±12,2], [408,3±28,6], [433,4±26,4],
    [24], [526,8±16,1], [486,4±8,1], [496,1±10,9], [503,3±6,5],
    table.hline(stroke: 0.5pt),
    [Naif minggu lalu, 1 jam], table.cell(colspan: 4)[467,6],
    [Naif minggu lalu, 24 jam], table.cell(colspan: 4)[466,1],
    table.hline(),
  )),
) <tab:b>

== Konfigurasi Terbaik
Konfigurasi terbaik dipilih per model dengan val MAE dan hanya nilai yang menang lebih dari satu simpangan baku yang dipertahankan: ANN ($W$=6, hidden 128), RNN ($W$=48), LSTM (hidden 128, $10^(-2)$), dan GRU (hidden 128). Percobaan pertama menggabungkan semua nilai terbaik, termasuk 2 lapis untuk RNN dan GRU serta _learning rate_ dan dropout untuk GRU. Hasilnya lebih buruk dari acuan pada validasi (RNN 225,9 vs 206,1; GRU 235,1 vs 207,5), karena faktor-faktor saling memengaruhi dan model menjadi terlalu besar (GRU 151.809 parameter). Konfigurasi kemudian dipersempit menjadi faktor yang menang sendiri-sendiri. Percobaan gabungan penuh tetap dilaporkan dan tersimpan di `hasil/ablasi.csv`.

@tab:c dan @fig:c menunjukkan hasil akhir. Pada validasi, ANN (turun 45) dan GRU (turun 19) membaik jelas, sedangkan RNN dan LSTM setara acuan (selisih di dalam simpangan baku). Pada test, ANN, LSTM, dan GRU lebih baik, tetapi hanya perbaikan ANN yang konsisten dengan validasi, dan pemilihan tidak boleh didasarkan pada test. GRU memberi test MAE terendah (220,3 ± 10,6), sekitar 53% di bawah baseline "minggu lalu". RNN nyaris setara GRU dengan parameter sekitar sepuluh kali lebih sedikit (5.305 vs 52.737). Pada Natal, hanya RNN yang setara baseline "nilai terakhir" (404,5 vs 431,2).

#figure(
  caption: [Acuan dan konfigurasi terbaik di Duomo (MAE, rata-rata ± simpangan baku, 3 seed).],
  placement: top,
  text(size: 7pt, table(
    columns: 6,
    align: (left, left, center, center, center, center),
    stroke: none,
    table.hline(),
    table.header([*Model*], [*Konfig.*], [*Param*], [*Val*], [*Test*], [*Natal*]),
    table.hline(stroke: 0.5pt),
    [ANN], [acuan], [6.497], [250,1±8,6], [313,9±9,9], [675,7±44,6],
    [], [terbaik], [22.145], [204,9±7,4], [253,9±3,2], [534,1±29,8],
    [RNN], [acuan], [5.305], [206,1±7,4], [229,6±5,1], [421,2±2,4],
    [], [terbaik], [5.305], [200,1±5,3], [224,5±11,7], [404,5±9,9],
    [LSTM], [acuan], [5.578], [230,5±12,2], [273,6±25,4], [586,0±56,8],
    [], [terbaik], [70.273], [227,4±17,2], [235,3±6,7], [465,5±27,9],
    [GRU], [acuan], [5.397], [207,5±3,8], [237,2±9,3], [468,2±21,8],
    [], [terbaik], [52.737], [188,7±4,2], [220,3±10,6], [435,2±7,5],
    table.hline(),
  )),
) <tab:c>

#figure(
  image("gambar/C_terbaik_vs_acuan.png", width: 100%),
  caption: [Test MAE acuan dan konfigurasi terbaik di Duomo dengan tiga baseline naif.],
  placement: top,
) <fig:c>

== Uji Generalisasi
Acuan dan konfigurasi terbaik dari Duomo dilatih ulang tanpa perubahan di Politecnico di Milano (kode 4). @fig:d memperlihatkan perbedaan polanya: Duomo memiliki siklus harian setiap hari, sedangkan Politecnico (kampus) hanya ramai pada hari kerja, datar pada akhir pekan, dan setelah sekitar 20 Des trafiknya jatuh dan datar karena libur kampus.

Urutan model secara garis besar sama dengan Duomo. Pada validasi GRU terbaik (137,3), RNN dan LSTM sekitar 145, dan ANN terburuk (150,3). Pada test RNN dan GRU terbaik (sekitar 171–174, selisih di dalam simpangan baku), LSTM di tengah, dan ANN terburuk (223,5). Konfigurasi terbaik Duomo membantu sebagian: pada validasi ANN dan GRU membaik, tetapi pada test hanya ANN dan LSTM turun, dan keduanya dengan simpangan baku besar (LSTM acuan 239,5 ± 61,9 karena satu seed meledak). RNN tidak berubah dan GRU tidak membaik pada test, sehingga hasil tuning Duomo belum terbukti berpindah ke lokasi lain.

Seluruh model mengalahkan baseline test terbaik di lokasi ini (nilai terakhir, 427,8). Pada minggu Natal semua model kalah jauh dari baseline "nilai terakhir" (57,2) dan "kemarin" (137,8); model (662–1.235) hanya mengalahkan "minggu lalu" (1.846,8). Penyebabnya adalah trafik yang datar saat libur, sedangkan model dilatih pada pola hari kerja dan masih memprediksi puncak harian. Perbandingan MAE antar lokasi tidak setara karena skala berbeda, sehingga model dibandingkan dengan baseline di lokasi yang sama.

#figure(
  caption: [Kinerja acuan dan terbaik di Politecnico di Milano (MAE, 3 seed). Baseline: test, nilai terakhir 427,8; Natal, nilai terakhir 57,2.],
  placement: top,
  text(size: 7pt, table(
    columns: 6,
    align: (left, left, center, center, center, center),
    stroke: none,
    table.hline(),
    table.header([*Model*], [*Konfig.*], [*Val*], [*Test*], [*MAPE test (%)*], [*Natal*]),
    table.hline(stroke: 0.5pt),
    [ANN], [acuan], [170,6±7,8], [244,5±14,2], [13,2±0,7], [1.234,9±38,3],
    [], [terbaik], [150,3±5,3], [223,5±15,6], [14,4±1,4], [1.063,6±72,3],
    [RNN], [acuan], [145,1±10,2], [171,5±13,1], [9,8±0,8], [713,3±38,8],
    [], [terbaik], [145,1±10,1], [172,0±13,2], [9,9±0,8], [714,6±38,3],
    [LSTM], [acuan], [151,2±12,6], [239,5±61,9], [14,2±4,1], [939,8±205,6],
    [], [terbaik], [145,4±3,0], [187,4±22,1], [11,6±2,2], [841,6±44,6],
    [GRU], [acuan], [152,7±11,4], [170,5±7,8], [9,9±0,2], [880,7±130,6],
    [], [terbaik], [137,3±7,1], [173,8±14,3], [8,9±0,7], [662,3±64,0],
    table.hline(),
  )),
) <tab:d>

#figure(
  image("gambar/D_pola_lokasi.png", width: 100%),
  caption: [Aktivitas internet per jam di Duomo dan Politecnico di Milano.],
  placement: top,
) <fig:d>

= Pembahasan
*Faktor paling berpengaruh.* Untuk model terbaik, _learning rate_ memberi rentang terbesar (GRU 356,3 menjadi 215,7), diikuti kelompok fitur, lalu ukuran hidden dan jumlah lapisan. Panjang jendela paling kecil pengaruhnya pada model rekuren. Rentang _learning rate_ sebagian merupakan artefak, karena pada $10^(-4)$ training berhenti di batas 300 epoch. Karena itu angka acuan $10^(-3)$ kemungkinan bukan optimum untuk LSTM dan GRU, dan kesimpulan A1–A3 bahwa LSTM "lebih buruk" sebagian mungkin disebabkan _learning rate_ yang kurang cocok, bukan arsitekturnya.

*Mengapa ANN paling sensitif.* ANN memberi bobot terpisah untuk setiap posisi dan fitur dalam jendela, sehingga parameternya tumbuh dengan $W$ dan jumlah fitur, sementara data train hanya 672 sampel. Model rekuren berbagi bobot antar langkah waktu, sehingga lebih tahan terhadap perubahan masukan. Setelah penyetelan, jarak ANN ke LSTM mengecil, sehingga ANN tidak selalu yang terburuk.

*Model versus seed.* Selisih antar model (misalnya ANN 313,9 vs RNN 229,6 pada acuan) jauh lebih besar daripada simpangan baku antar seed (sekitar 5–25). Sebaliknya, banyak selisih akibat penyetelan (RNN $W$=48 vs 24, GRU hidden 64 vs 128) berada di dalam satu simpangan baku dan tidak boleh diklaim sebagai perbedaan nyata.

*Interaksi faktor.* Menggabungkan nilai terbaik per faktor memperburuk RNN dan GRU, sehingga pengaruh faktor tidak aditif dan model yang membesar di data kecil cenderung kalah.

*Keterbatasan.* Studi ini memakai satu kota, empat minggu data train, satu kali pembagian waktu, dan hanya tiga seed (simpangan baku dari tiga nilai kasar). Faktor diuji satu per satu dengan faktor lain tetap di acuan. Pada $10^(-4)$ training tidak konvergen. Baseline horizon 6 jam tidak dihitung, hipotesis B6 dirumuskan setelah run, dan faktor B lain (batch, optimizer, loss, patience, clip) tidak diuji. Dugaan penjelasan (misalnya memori efektif yang pendek dan efek fitur waktu pada Natal) belum diuji langsung. Lokasi uji generalisasi hanya satu, dengan pola kampus yang ekstrem pada minggu Natal.

= Kesimpulan
Kinerja model sangat dipengaruhi pilihan hyperparameter, terutama _learning rate_ dan fitur, sedangkan panjang jendela hampir tidak berpengaruh pada model rekuren. Pada horizon 1 jam, GRU dan RNN konsisten terbaik di Duomo (GRU 220,3 ± 10,6 pada test setelah penyetelan, sekitar 53% di bawah baseline "minggu lalu"). Penyetelan paling berhasil pada ANN (313,9 menjadi 253,9), tetapi menggabungkan semua nilai terbaik memperburuk RNN dan GRU. Dropout tidak membantu. Model kalah dari baseline "minggu lalu" pada horizon 24 jam, dan pada minggu Natal di Politecnico semua model kalah dari baseline "nilai terakhir". Hasil tuning Duomo hanya sebagian berlaku di lokasi lain, tetapi urutan model antar lokasi secara garis besar sama.

#heading(numbering: none)[Kontribusi Anggota]
#table(
  columns: (auto, 1fr),
  stroke: none,
  [Noel Kevin Julian Simanjuntak], [Seluruh bagian: eksperimen, analisis, dan penulisan laporan.],
)

#heading(numbering: none)[Pernyataan Penggunaan AI]
Claude (Anthropic) digunakan untuk membantu memperbaiki dan men-debug kode notebook, menafsirkan tabel hasil, serta menyusun dan merapikan draf laporan. Seluruh angka berasal dari run penulis sendiri dan tercatat di `hasil/ablasi.csv`.

#heading(numbering: none)[Kode dan Data]
Kode, notebook beserta output, dan seluruh hasil run tersedia di #link("https://github.com/noel124400094-svg/dlw-tugas-rb-124400094").