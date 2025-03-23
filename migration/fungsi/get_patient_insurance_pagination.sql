DROP FUNCTION IF EXISTS fn_get_patient_insurance_pagination;

DELIMITER //

CREATE FUNCTION fn_get_patient_insurance_pagination(
    records_per_page INT,
    page_number INT,
    filter JSON
)
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE result JSON;
    DECLARE total_records INT;
    DECLARE total_pages INT;
    DECLARE offset_number INT;
    DECLARE patient_name VARCHAR(255);
    DECLARE patient_norm VARCHAR(15);

    -- Set default value for page_number if not provided
    IF page_number IS NULL THEN
        SET page_number = 1;
    END IF;

    -- Ekstrak filter dari JSON
    SET patient_name = JSON_UNQUOTE(JSON_EXTRACT(filter, '$.nama'));
    SET patient_norm = JSON_UNQUOTE(JSON_EXTRACT(filter, '$.norm'));

    -- Hitung total records untuk pagination dengan filter
    SELECT COUNT(*) INTO total_records
    FROM master_pasien
    WHERE (patient_name IS NULL OR patient_name = '' OR nama LIKE CONCAT('%', patient_name, '%'))
      AND (patient_norm IS NULL OR patient_norm = '' OR norm = patient_norm);

    -- Hitung total pages
    SET total_pages = CEIL(total_records / records_per_page);

    SET offset_number = (page_number - 1) * records_per_page;

    -- Ambil data pasien dengan pagination dan filter
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'norm', p.norm,
            'nama', p.nama,
            'jenis_kelamin', p.jenis_kelamin,
            'kode_pos', p.kode_pos,
            'alamat', p.alamat,
            'asuransi', (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'nomor', a.nomor,
                        'jenis', j.nama_asuransi,
                        'kode', j.kode_asuransi,
                        'is_aktif', a.is_aktif
                    )
                )
                FROM master_asuransi a
                INNER JOIN master_jenis_asuransi j ON a.jenis = j.id_jenis_asuransi
                WHERE a.norm = p.norm
            )
        )
    ) INTO result
    FROM master_pasien p
    WHERE (patient_name IS NULL OR patient_name = '' OR p.nama LIKE CONCAT('%', patient_name, '%'))
      AND (patient_norm IS NULL OR patient_norm = '' OR p.norm = patient_norm)
    LIMIT records_per_page OFFSET offset_number;

    -- Mengembalikan hasil dengan pagination
    RETURN JSON_OBJECT(
        'data', result,
        'total_records', total_records,
        'total_pages', total_pages,
        'current_page', page_number
    );
END //

DELIMITER ;