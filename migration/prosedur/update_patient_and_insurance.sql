DROP PROCEDURE IF EXISTS sp_update_patient_and_insurance;

DELIMITER //

CREATE PROCEDURE sp_update_patient_and_insurance(
    IN patient_data JSON
)
proc_label:BEGIN
    DECLARE patient_norm VARCHAR(50);
    DECLARE patient_name VARCHAR(255);
    DECLARE patient_address TEXT;
    DECLARE patient_postcode INT;
    DECLARE patient_gender INT;
    DECLARE insurance_data JSON;
    DECLARE insurance_item JSON;
    DECLARE insurance_count INT;
    DECLARE i INT DEFAULT 0;
    DECLARE patient_exists INT DEFAULT 0;

    -- Ekstrak data pasien dari JSON
    SET patient_norm = JSON_UNQUOTE(JSON_EXTRACT(patient_data, '$.norm'));
    SET patient_name = JSON_UNQUOTE(JSON_EXTRACT(patient_data, '$.nama'));
    SET patient_address = JSON_UNQUOTE(JSON_EXTRACT(patient_data, '$.alamat'));
    SET patient_postcode = JSON_UNQUOTE(JSON_EXTRACT(patient_data, '$.kode_pos'));
    SET patient_gender = JSON_UNQUOTE(JSON_EXTRACT(patient_data, '$.jenis_kelamin'));
    SET insurance_data = JSON_EXTRACT(patient_data, '$.asuransi');

    -- Cek apakah pasien ada
    SELECT COUNT(*) INTO patient_exists
    FROM master_pasien
    WHERE norm = patient_norm;

    -- Jika pasien tidak ada, kembalikan pesan
    IF patient_exists = 0 THEN
        SELECT JSON_OBJECT('error', 'Patient not found') AS result;
        LEAVE proc_label; -- Keluar dari prosedur
    END IF;

    -- Update data pasien
    UPDATE master_pasien
    SET 
        nama = patient_name,
        alamat = patient_address,
        kode_pos = patient_postcode,
        jenis_kelamin = patient_gender
    WHERE norm = patient_norm;

    -- Hitung jumlah asuransi
    SET insurance_count = JSON_LENGTH(insurance_data);
    SET i = 0;

    -- Loop untuk memproses setiap item asuransi
    WHILE i < insurance_count DO
        SET insurance_item = JSON_EXTRACT(insurance_data, CONCAT('$[', i, ']'));

        -- Update data asuransi jika ditemukan
        UPDATE master_asuransi
        SET 
            jenis = JSON_UNQUOTE(JSON_EXTRACT(insurance_item, '$.jenis')),
            is_aktif = JSON_UNQUOTE(JSON_EXTRACT(insurance_item, '$.is_aktif'))
        WHERE 
            norm = patient_norm AND 
            nomor = JSON_UNQUOTE(JSON_EXTRACT(insurance_item, '$.nomor'));

        -- Cek apakah update berhasil
        IF ROW_COUNT() = 0 THEN
            -- Jika tidak ada baris yang terpengaruh, insert data asuransi baru
            INSERT INTO master_asuransi (norm, jenis, nomor, is_aktif)
            VALUES (
                patient_norm,
                JSON_UNQUOTE(JSON_EXTRACT(insurance_item, '$.jenis')),
                JSON_UNQUOTE(JSON_EXTRACT(insurance_item, '$.nomor')),
                JSON_UNQUOTE(JSON_EXTRACT(insurance_item, '$.is_aktif'))
            );
        END IF;

        SET i = i + 1;
    END WHILE;

    -- Kembalikan pesan sukses
    SELECT JSON_OBJECT('success', 'Patient and insurance data updated successfully') AS result;

END //

DELIMITER ;