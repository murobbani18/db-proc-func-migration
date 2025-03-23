DROP FUNCTION IF EXISTS fn_get_patient;

DELIMITER //

CREATE FUNCTION fn_get_patient(
    filter JSON
)
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE result JSON;
    DECLARE patient_norm VARCHAR(50);

    -- Ekstrak norm dari JSON
    SET patient_norm = JSON_UNQUOTE(JSON_EXTRACT(filter, '$.norm'));

    -- Ambil data pasien berdasarkan norm
    SELECT 
        JSON_OBJECT(
            'norm', p.norm,
            'nama', p.nama,
            'alamat', p.alamat,
            'kode_pos', p.kode_pos,
            'jenis_kelamin', p.jenis_kelamin,
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
    INTO result
    FROM master_pasien p
    WHERE p.norm = patient_norm;

    -- Mengembalikan hasil
    RETURN result;
END //

DELIMITER ;