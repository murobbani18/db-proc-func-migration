DROP PROCEDURE IF EXISTS sp_update_insurance_active_status;

DELIMITER //

CREATE PROCEDURE sp_update_insurance_active_status(
    IN insurance_data JSON
)
BEGIN
    DECLARE insurance_norm VARCHAR(50);
    DECLARE insurance_number VARCHAR(50);
    DECLARE is_active INT;

    -- Ekstrak data dari JSON
    SET insurance_norm = JSON_UNQUOTE(JSON_EXTRACT(insurance_data, '$.norm'));
    SET insurance_number = JSON_UNQUOTE(JSON_EXTRACT(insurance_data, '$.nomor'));
    SET is_active = JSON_UNQUOTE(JSON_EXTRACT(insurance_data, '$.is_aktif'));

    -- Update status is_aktif pada tabel master_asuransi
    UPDATE master_asuransi
    SET is_aktif = is_active
    WHERE norm = insurance_norm AND nomor = insurance_number;

    -- Cek apakah update berhasil
    IF ROW_COUNT() = 0 THEN
        SELECT JSON_OBJECT('error', 'No matching insurance found for the given norm and number') AS result;
    ELSE
        SELECT JSON_OBJECT('success', 'Insurance active status updated successfully') AS result;
    END IF;

END //

DELIMITER ;