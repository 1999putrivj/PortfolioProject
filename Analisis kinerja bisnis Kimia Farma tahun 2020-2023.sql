SELECT 
    t.transaction_id, 
    t.date, 
    t.branch_id, 
    b.branch_name, 
    b.kota, 
    b.provinsi, 
    b.rating AS rating_cabang, 
    t.customer_name, 
    t.product_id, 
    p.product_name, 
    t.price AS actual_price, 
    t.discount_percentage, 
    CASE 
        WHEN t.price <= 50000 THEN 10 
        WHEN t.price > 50000 AND t.price <= 100000 THEN 15 
        WHEN t.price > 100000 AND t.price <= 300000 THEN 20 
        WHEN t.price > 300000 AND t.price <= 500000 THEN 25 
        ELSE 30 
    END AS persentase_gross_laba, 
    (t.price * (1 - (t.discount_percentage / 100))) AS nett_sales, 
    (t.price * (1 - (t.discount_percentage / 100))) * 
    CASE 
        WHEN t.price <= 50000 THEN 0.1 
        WHEN t.price > 50000 AND t.price <= 100000 THEN 0.15 
        WHEN t.price > 100000 AND t.price <= 300000 THEN 0.2 
        WHEN t.price > 300000 AND t.price <= 500000 THEN 0.25 
        ELSE 0.3 
    END AS nett_profit, 
    t.rating AS rating_transaksi 
FROM 
    kf_final_transaction.kf_final_transaction t 
INNER JOIN 
    kf_kantor_cabang.kf_kantor_cabang b ON t.branch_id = b.branch_id 
INNER JOIN 
    kf_product.kf_product p ON t.product_id = p.product_id;


--1.**SELECT:** Bagian kueri ini menentukan kolom dan bidang kalkulasi yang ingin diambil dari database. Klausa ini mencantumkan semua kolom yang akan disertakan dalam kumpulan hasil.

--2.**FROM:** Menunjukkan tabel utama (`kf_final_transaction t`) untuk mengambil data.

--3.**INNER JOIN:** ini menentukan penggabungan antara:
   -- `kf_final_transaksi` dan `kf_kantor_cabang` yang cocok dengan `id_cabang`.
   -- `kf_final_transaksi` dan `kf_produk` pada pencocokan `product_id`.
   
   --Join digunakan untuk menggabungkan baris dari dua tabel atau lebih berdasarkan kolom yang terkait di antara mereka.

--4.**Kolom dan Perhitungan:** Kolom dan Perhitungan
   -- Kolom-kolom dasar seperti `id_transaksi`, `tanggal`, `id_cabang`, `nama_cabang`, `kota`, `provinsi`, `nama_pelanggan`, dan `id_produk` dipilih dari tabel yang sesuai.
   -- `harga_asli` menunjukkan harga asli produk.
   -- `persentase_diskon` dipilih secara langsung.
   -- `persentase_gross_laba` adalah bidang kalkulasi yang menentukan tingkat diskon berdasarkan harga produk.
   -- `penjualan_bersih` menghitung harga jual setelah diskon.
   -- `laba_bersih` menghitung laba yang diperoleh, dengan asumsi tingkat margin yang berbeda berdasarkan harga produk.
   -- `rating_cabang` dan `rating_transaksi` masing-masing mewakili rating untuk cabang dan transaksi.



--Total Profit Masing-masing Provinsi

SELECT kc.provinsi, SUM((ft.price - (ft.price * ft.discount_percentage)) - (inv.opname_stock * p.price)) AS total_profit
FROM kimia_farma.kf_final_transaction ft
JOIN kimia_farma.kf_kantor_cabang kc ON ft.branch_id = kc.branch_id
JOIN kimia_farma.kf_inventory inv ON ft.product_id = inv.product_id AND ft.branch_id = inv.branch_id
JOIN kimia_farma.kf_product p ON ft.product_id = p.product_id
GROUP BY kc.provinsi


--1.**SELECT **: Ini memilih dua bidang:
   -- `kc.provinsi`: Kolom provinsi dari tabel kantor cabang (`kf_kantor_cabang`).
   -- Yang kedua adalah kolom kalkulasi bernama `total_laba`. Perhitungan ini mengurangi persentase diskon dari harga (`ft.price - (ft.price * (ft.discount_percentage / 100))`), mengalikannya dengan jumlah stok inventaris (`inv.opname_stock`), dan kemudian mengalikannya dengan harga produk (`p.price`) untuk mendapatkan keuntungan. Terakhir, menjumlahkan nilai-nilai ini untuk mendapatkan total keuntungan per provinsi.

--2.**FROM **: ini memberitahukan dari mana harus memulai, yaitu tabel `kf_final_transaction` dengan nama `ft`.

--3.**JOIN**: Kueri ini melibatkan tiga operasi JOIN:
   -- Menggabungkan `kf_final_transaksi` dengan tabel `kf_kantor_cabang` (`kc`) pada `branch_id` untuk menghubungkan transaksi ke kantor cabang masing-masing.
   -- Bergabung dengan tabel `kf_inventory` (`inv`) pada `product_id` dan `branch_id` untuk menampilkan detail inventaris untuk setiap produk di setiap cabang.
   -- Bergabung dengan tabel `kf_produk` (`p`) pada `product_id` untuk mendapatkan detail harga produk.

--4.**GROUP BY**: Ini mengelompokkan hasil berdasarkan kolom `provinsi` pada tabel `kf_kantor_cabang`, yang berarti total keuntungan akan dihitung dan ditampilkan untuk setiap provinsi, menggabungkan data dari beberapa transaksi di cabang yang berbeda di provinsi yang sama.


--Top 10 Nett sales cabang provinsi

SELECT kc.kota, kc.provinsi, SUM(ft.price - (ft.price * ft.discount_percentage)) AS nett_sales
FROM kimia_farma.kf_final_transaction ft
JOIN kimia_farma.kf_kantor_cabang kc ON ft.branch_id = kc.branch_id
GROUP BY kc.kota, kc.provinsi
ORDER BY nett_sales DESC
LIMIT 10;

--**`SELECT`**: Bagian ini menentukan kolom dan perhitungan yang ingin dikembalikan. Kolom ini mencakup kota (`kota`) dan provinsi (`provinsi`) dari tabel `kimia_farma_kantor_cabang` dan menghitung penjualan bersih (`nett_sales`) dengan mengurangkan hasil perkalian antara harga dan persentase_diskon dengan harga pada tabel `kimia_farma_final_transaction`.

--``FROM``: Menunjukkan tabel utama (`kimia_farma_final_transaction ft`) yang digunakan untuk mengambil data.

--**`JOIN`**: Menggabungkan baris-baris dari tabel `kimia_farma_final_transaction` dengan baris-baris dari tabel `kimia_farma_kantor_cabang` di mana field `branch_id` di kedua tabel tersebut sama.

--`GROUP BY`: Ini mengelompokkan hasil berdasarkan kota (`kota`) dan provinsi (`provinsi`) dari tabel `kimia_farma_kantor_cabang`. Hal ini diperlukan untuk menggunakan fungsi agregat seperti `SUM()`.

--``ORDER BY``: Klausa ini mengurutkan hasil berdasarkan `penjualan_bersih` yang telah dihitung dalam urutan menurun, memastikan angka penjualan tertinggi muncul terlebih dahulu.

--**`LIMIT`**: Membatasi hasil ke 10 catatan teratas berdasarkan `nett_sales`.



--Top 10 Total transaksi cabang provinsi

SELECT b.kota, b.provinsi, SUM(ft.price) AS total_transactions
FROM kimia_farma.kf_final_transaction ft
JOIN kimia_farma.kf_kantor_cabang b ON ft.branch_id = b.branch_id
GROUP BY b.kota, b.provinsi
ORDER BY total_transactions DESC
LIMIT 10;


--**SELECT**: Bagian dari kueri ini menentukan bidang yang akan dikembalikan. Bagian ini meminta kota (`kota`), provinsi (`provinsi`) dari tabel cabang (`kf_kantor_cabang`), dan jumlah kolom `harga` dari tabel transaksi (`kf_final_transaksi`) sebagai `total_transaksi`.

--**FROM**: Menunjukkan tabel `kimia_farma kf_final_transaksi` dengan nama `ft`, yang merupakan titik awal untuk mengambil data. Klausa ini mengidentifikasi tabel default di mana kueri akan mulai mencari data.

--**JOIN**: Menentukan jenis penggabungan antara dua tabel: `kimia_farma kf_final_transaksi ft` dan `kimia_farma kf_kantor_cabang b`. Ini menggabungkan tabel-tabel ini pada sebuah field yang sama, `id_cabang`, yang berarti menggabungkan baris-baris dari kedua tabel ini di mana `id_cabang` di `ft` sama dengan `id_cabang` di `b`.

--**GROUP BY**: Bagian ini mengelompokkan hasil berdasarkan kota (`kota`) dan provinsi (`provinsi`). Hal ini diperlukan untuk fungsi `SUM` untuk menghitung jumlah total transaksi untuk setiap kombinasi unik dari kota dan provinsi.

--**ORDER BY**: Mengurutkan hasil berdasarkan `total_transaksi` dalam urutan menurun (`DESC`). Ini berarti kombinasi kota-provinsi dengan total transaksi tertinggi akan muncul terlebih dahulu.

--**LIMIT **: Membatasi jumlah baris yang dikembalikan menjadi 10. Ini membatasi hasil ke 10 kombinasi kota-provinsi teratas dengan total transaksi tertinggi.


--Top 5 Cabang Dengan Rating Tertinggi, namun Rating Transaksi Terendah

SELECT b.branch_name, b.rating, t.total_transactions, t2.min_transactions
FROM kimia_farma.kf_kantor_cabang b
LEFT JOIN (SELECT branch_id, AVG(rating) AS avg_rating, COUNT(*) AS total_transactions
            FROM kimia_farma.kf_final_transaction
            GROUP BY branch_id) t ON b.branch_id = t.branch_id
LEFT JOIN (SELECT branch_id, MIN(rating) AS min_rating, COUNT(*) AS min_transactions
            FROM kimia_farma.kf_final_transaction
            GROUP BY branch_id) t2 ON b.branch_id = t2.branch_id
ORDER BY t.avg_rating DESC, t2.min_rating, t2.min_transactions
LIMIT 5;


--1.**FROM**: Kueri ini dimulai dengan memilih dari tabel `kimia_farma kf_kantor_cabang`, yang disebut sebagai `b`. Ini adalah tabel utama yang digunakan untuk meminta informasi cabang.

--2.*LEFT JOIN (Pertama)**: Klausa ini melakukan LEFT JOIN pada subkueri yang memilih `branch_id`, rating rata-rata (`AVG(rating) AS avg_rating`), dan jumlah transaksi (`COUNT(*) AS total_transaksi`) dari tabel `kimia_farma kf_final_transaction`. Subkueri ini diasosiasikan sebagai `t`. LEFT JOIN berarti bahwa kueri akan menyertakan semua cabang dari `kf_kantor_cabang`, meskipun tidak ada entri yang sesuai di tabel `kf_final_transaksi`.

--3.JOIN KIRI (Kedua)**: LEFT JOIN lainnya dilakukan pada subkueri yang berbeda. Subkueri kedua ini juga memilih dari `kimia_farma kf_final_transaksi`, menghitung rating minimum (`MIN(rating) AS min_rating`) dan jumlah transaksi (`COUNT(*) AS min_transaksi`) untuk setiap cabang. Subkueri ini diasosiasikan sebagai `t2`. Sekali lagi, LEFT JOIN ini memastikan semua cabang diikutsertakan, terlepas dari data transaksi yang terkait.

--4.**SELECT**: Kueri memilih nama cabang dari `b.branch_name`, dan kemudian empat bidang yang dihitung:
   --`avg_rating` sebagai `rating`: Peringkat rata-rata transaksi per cabang.
   --`total_transaksi`: Jumlah total transaksi per cabang dari subkueri pertama.
   --`min_rating`: Peringkat minimum per cabang dari subkueri kedua.
   --`min_transaksi`: Jumlah transaksi (yang mungkin hanya mengulangi total transaksi lagi tetapi berasal dari subkueri kedua pada peringkat minimum).

--5.**GROUP BY dalam Subkueri**: Kedua subkueri mengelompokkan hasil berdasarkan `branch_id`, memastikan agregasi (penghitungan rata-rata dan minimum, serta jumlah) dilakukan per cabang unik.

--6.**ORDER BY**: Hasilnya kemudian diurutkan pertama kali berdasarkan `avg_rating` dalam urutan menurun (tertinggi ke terendah), kemudian berdasarkan `min_rating`, dan terakhir berdasarkan `min_transaksi`. Hal ini menunjukkan sebuah hirarki kepentingan dalam pengurutan: memprioritaskan cabang-cabang berdasarkan rating rata-rata mereka, kemudian mempertimbangkan rating minimum dan jumlah transaksi untuk pengurutan lebih lanjut.

--7.**LIMIT**: Akhirnya, hanya 5 catatan teratas berdasarkan urutan yang ditentukan yang dikembalikan.