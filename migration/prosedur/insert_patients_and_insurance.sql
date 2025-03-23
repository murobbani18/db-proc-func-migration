DROP PROCEDURE IF EXISTS sp_insert_patients_and_insurance;

DELIMITER //

CREATE PROCEDURE sp_insert_patients_and_insurance(
    IN patients_data JSON
)
BEGIN
    DECLARE patient_count INT;
    DECLARE i INT DEFAULT 0;
    DECLARE patient_norm VARCHAR(8);
    DECLARE patient_name VARCHAR(255);
    DECLARE patient_address TEXT;
    DECLARE patient_postcode INT;
    DECLARE patient_gender INT;
    DECLARE insurance_data JSON;
    DECLARE insurance_item JSON;
    DECLARE insurance_count INT;
    DECLARE j INT;
    DECLARE last_norm VARCHAR(8);
    DECLARE new_norm INT;

    -- Hitung jumlah pasien
    SET patient_count = JSON_LENGTH(patients_data);

    -- Ambil norm terakhir dari tabel master_pasien
    SELECT norm INTO last_norm
    FROM master_pasien
    ORDER BY norm DESC
    LIMIT 1;

    -- Jika norm terakhir ada, ambil angka dan increment
    IF last_norm IS NOT NULL THEN
        SET new_norm = CAST(SUBSTRING(last_norm, 3) AS UNSIGNED) + 1; -- Mengambil angka setelah 'RM'
        SET patient_norm = CONCAT('RM', LPAD(new_norm, 6, '0')); -- Membuat norm baru
    ELSE
        SET new_norm = 1; -- Jika tidak ada data, mulai dari RM000001
        SET patient_norm = CONCAT('RM', LPAD(new_norm, 6, '0')); -- Membuat norm baru
    END IF;

    -- Loop untuk setiap pasien
    WHILE i < patient_count DO

        IF i > 0 THEN
            SET new_norm = new_norm + 1;
            SET patient_norm = CONCAT('RM', LPAD(new_norm, 6, '0'));
        END IF;

        -- Ekstrak data pasien dari JSON
        SET patient_name = JSON_UNQUOTE(JSON_EXTRACT(patients_data, CONCAT('$[', i, '].nama')));
        SET patient_address = JSON_UNQUOTE(JSON_EXTRACT(patients_data, CONCAT('$[', i, '].alamat')));
        SET patient_postcode = JSON_UNQUOTE(JSON_EXTRACT(patients_data, CONCAT('$[', i, '].kode_pos')));
        SET patient_gender = JSON_UNQUOTE(JSON_EXTRACT(patients_data, CONCAT('$[', i, '].jenis_kelamin')));
        SET insurance_data = JSON_EXTRACT(patients_data, CONCAT('$[', i, '].asuransi'));

        -- Insert data pasien
        INSERT INTO master_pasien (norm, nama, alamat, kode_pos, jenis_kelamin)
        VALUES (patient_norm, patient_name, patient_address, patient_postcode, patient_gender);

        -- Hitung jumlah asuransi
        SET insurance_count = JSON_LENGTH(insurance_data);
        SET j = 0;

        -- Loop untuk insert data asuransi
        WHILE j < insurance_count DO
            SET insurance_item = JSON_EXTRACT(insurance_data, CONCAT('$[', j, ']'));

            INSERT INTO master_asuransi (norm, jenis, nomor, is_aktif)
            VALUES (
                patient_norm,
                JSON_UNQUOTE(JSON_EXTRACT(insurance_item, '$.jenis')),
                JSON_UNQUOTE(JSON_EXTRACT(insurance_item, '$.nomor')),
                JSON_UNQUOTE(JSON_EXTRACT(insurance_item, '$.is_aktif'))
            );

            SET j = j + 1;
        END WHILE;

        SET i = i + 1;
    END WHILE;

    -- Mengembalikan pesan bahwa data berhasil disimpan
    SELECT JSON_OBJECT('success', 'Patient and insurance data created successfully') AS result;
END //

DELIMITER ;