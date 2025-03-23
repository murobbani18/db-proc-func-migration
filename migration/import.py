import subprocess
import os
import mysql.connector

# Koneksi ke database MySQL
db = mysql.connector.connect(
    host="localhost",  # Ganti dengan host Anda
    user="root",       # Ganti dengan username Anda
    password="",       # Ganti dengan password Anda
    database="rsfatmawati"  # Ganti dengan nama database Anda
)

# Daftar direktori yang berisi file SQL
directories = ['./fungsi', './prosedur', './view']

# Loop melalui semua direktori
for directory in directories:
    # Pastikan direktori ada
    if os.path.exists(directory):
        # Loop melalui semua file dalam direktori
        for filename in os.listdir(directory):
            if filename.endswith('.sql'):
                file_path = os.path.join(directory, filename)
                print(f"Menjalankan skrip: {file_path}")
                
                # Menjalankan perintah bash untuk mengeksekusi file SQL
                command = f"mysql -u root rsfatmawati < {file_path}"
                
                try:
                    # Eksekusi perintah bash
                    subprocess.run(command, shell=True, check=True)
                    print(f"Skrip {filename} berhasil dijalankan.")
                except subprocess.CalledProcessError as e:
                    print(f"Error saat menjalankan {filename}: {e}")
    else:
        print(f"Direktori tidak ditemukan: {directory}")

print("Semua skrip SQL telah dijalankan.")