DROP PROCEDURE IF EXISTS sp_deactivate_insurance;

DELIMITER //

CREATE PROCEDURE sp_deactivate_insurance(
    IN insurance_data JSON
)
BEGIN
    DECLARE insurance_norm VARCHAR(50);
    DECLARE insurance_number VARCHAR(50);

    -- Ekstrak data dari JSON
    SET insurance_norm = JSON_UNQUOTE(JSON_EXTRACT(insurance_data, '$.norm'));
    SET insurance_number = JSON_UNQUOTE(JSON_EXTRACT(insurance_data, '$.nomor'));

    -- Update status is_aktif menjadi 0 pada tabel master_asuransi
    UPDATE master_asuransi
    SET is_aktif = 0
    WHERE norm = insurance_norm AND nomor = insurance_number;

    -- Cek apakah update berhasil
    IF ROW_COUNT() = 0 THEN
        SELECT JSON_OBJECT('error', 'No matching insurance found for the given norm and number') AS result;
    ELSE
        SELECT JSON_OBJECT('success', 'Insurance deactivated successfully') AS result;
    END IF;

END //

DELIMITER ;