import mysql.connector
import random
import string

# Koneksi ke database MySQL
db = mysql.connector.connect(
    host="localhost",  # Ganti dengan host Anda
    user="root",       # Ganti dengan username Anda
    password="",       # Ganti dengan password Anda
    database="rsfatmawati"  # Ganti dengan nama database Anda
)

cursor = db.cursor()

# Drop table if exists
drop_table_query = "DROP TABLE IF EXISTS master_asuransi;"
cursor.execute(drop_table_query)

# Create table
create_table_query = """
CREATE TABLE `master_asuransi` (
    `nomor` VARCHAR(19) NOT NULL COLLATE 'utf8mb4_unicode_ci',
    `norm` VARCHAR(8) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci',
    `jenis` INT(10) NULL DEFAULT NULL,
    `is_aktif` SMALLINT(5) NULL DEFAULT NULL,
    PRIMARY KEY (`nomor`) USING BTREE,
    INDEX `FK_master_asuransi_master_pasien` (`norm`) USING BTREE,
    CONSTRAINT `FK_master_asuransi_master_pasien` FOREIGN KEY (`norm`) REFERENCES `master_pasien` (`norm`) ON UPDATE NO ACTION ON DELETE NO ACTION
)
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB;
"""
cursor.execute(create_table_query)

# Ambil semua norm dari master_pasien
cursor.execute("SELECT norm FROM master_pasien;")
norms = [row[0] for row in cursor.fetchall()]

# Ambil semua kode_asuransi dari master_jenis_asuransi
cursor.execute("SELECT kode_asuransi FROM master_jenis_asuransi;")
kode_asuransi_list = [row[0] for row in cursor.fetchall()]

# Menyiapkan query untuk menyisipkan data
insert_query = """
INSERT INTO master_asuransi (nomor, norm, jenis, is_aktif) 
VALUES (%s, %s, %s, %s)
"""

# Menyisipkan 500 baris data
for _ in range(500):
    # 50% kemungkinan pasien tidak memiliki asuransi
    norm = random.choice(norms) if random.random() > 0.5 else None
    
    # Jika norm tidak None, pilih jenis asuransi
    if norm:
        # Pilih antara 1 hingga 3 jenis asuransi
        jenis_asuransi_count = random.randint(1, 3)
        jenis_asuransi = random.sample(range(1, 6), jenis_asuransi_count)  # Asumsi id_jenis_asuransi dari 1 hingga 5
    else:
        jenis_asuransi = []
    
    # Menyisipkan data untuk setiap jenis asuransi yang dipilih
    for j in jenis_asuransi:
        # Generate nomor asuransi dengan prefix dari kode_asuransi
        kode_asuransi = random.choice(kode_asuransi_list)
        nomor = f"{kode_asuransi}{''.join(random.choices(string.digits, k=15))}"  # 17 digit total
        
        # Asuransi aktif
        is_aktif = 1
        
        # Menjalankan query
        cursor.execute(insert_query, (nomor, norm, j, is_aktif))

# Menyimpan perubahan
db.commit()

# Menutup koneksi
cursor.close()
db.close()

print("500 baris data berhasil disisipkan ke dalam tabel master_asuransi.")