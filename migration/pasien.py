import mysql.connector
import random
import faker

# Inisialisasi Faker untuk menghasilkan data dummy
fake = faker.Faker()

# Koneksi ke database MySQL
db = mysql.connector.connect(
    host="localhost",  # Ganti dengan host Anda
    user="root",       # Ganti dengan username Anda
    password="",  # Ganti dengan password Anda
    database="rsfatmawati"  # Ganti dengan nama database Anda
)

cursor = db.cursor()

# Drop table if exists
drop_table_query = "DROP TABLE IF EXISTS master_pasien;"
cursor.execute(drop_table_query)

# Create table
create_table_query = """
CREATE TABLE `master_pasien` (
    `norm` VARCHAR(8) NOT NULL COLLATE 'utf8mb4_unicode_ci',
    `nama` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci',
    `jenis_kelamin` INT(10) NULL DEFAULT NULL COMMENT '0: Perempuan, 1: Laki-laki',
    `kode_pos` INT(10) NULL DEFAULT NULL,
    `alamat` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci',
    PRIMARY KEY (`norm`) USING BTREE
)
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB;
"""
cursor.execute(create_table_query)

# Menyiapkan query untuk menyisipkan data
insert_query = """
INSERT INTO master_pasien (norm, nama, jenis_kelamin, kode_pos, alamat) 
VALUES (%s, %s, %s, %s, %s)
"""

# Menyisipkan 1000 baris data dummy
for _ in range(1000):
    norm = "RM" + str(random.randint(100000, 999999))  # Membuat norm acak dengan prefix "RM"
    nama = fake.name()  # Menghasilkan nama acak
    jenis_kelamin = random.randint(0, 1)  # 0 atau 1 untuk jenis kelamin
    kode_pos = random.randint(10000, 99999)  # Kode pos acak
    alamat = fake.address().replace("\n", ", ")  # Menghasilkan alamat acak dan mengganti newline dengan koma

    # Menjalankan query
    cursor.execute(insert_query, (norm, nama, jenis_kelamin, kode_pos, alamat))

# Menyimpan perubahan
db.commit()

# Menutup koneksi
cursor.close()
db.close()

print("1000 baris data dummy berhasil disisipkan ke dalam tabel master_pasien.")