import mysql.connector

# Koneksi ke database MySQL
db = mysql.connector.connect(
    host="localhost",  # Ganti dengan host Anda
    user="root",       # Ganti dengan username Anda
    password="",  # Ganti dengan password Anda
    database="rsfatmawati"  # Ganti dengan nama database Anda
)

cursor = db.cursor()

# Drop table if exists
drop_table_query = "DROP TABLE IF EXISTS master_jenis_asuransi;"
cursor.execute(drop_table_query)

# Create table
create_table_query = """
CREATE TABLE master_jenis_asuransi (
    `id_jenis_asuransi` BIGINT PRIMARY KEY,
    `nama_asuransi` VARCHAR(255),
    `kode_asuransi` VARCHAR(2) UNIQUE NOT NULL
);
"""
cursor.execute(create_table_query)

# Menyiapkan query untuk menyisipkan data
insert_query = """
INSERT INTO master_jenis_asuransi (id_jenis_asuransi, nama_asuransi, kode_asuransi) 
VALUES (%s, %s, %s)
"""

# Data yang akan disisipkan
data_asuransi = [
    (1, "BPJS", "BP"),
    (2, "PRUDENTIAL", "PR"),
    (3, "AIA", "AI"),
    (4, "MANDIRI INHEALTH", "MI"),
    (5, "ADMEDIKA", "AD")
]

# Menyisipkan data
cursor.executemany(insert_query, data_asuransi)

# Menyimpan perubahan
db.commit()

# Menutup koneksi
cursor.close()
db.close()

print("Data berhasil disisipkan ke dalam tabel master_jenis_asuransi.")