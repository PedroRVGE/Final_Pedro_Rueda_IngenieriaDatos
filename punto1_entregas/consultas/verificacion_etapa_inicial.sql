-- Verificación adicional de la etapa inicial: con solo los días 1 y 2 en S3 deben verse 12 registros,
-- aunque la proyección ya incluye 2026-10-03 (esa fecha no tiene objetos todavía).
-- -> resultados/inicial/verificacion_etapa_inicial.csv
SELECT
    COUNT(*) AS total_registros,
    COUNT(DISTINCT fecha) AS fechas_con_datos,
    SUM(CASE WHEN fecha = '2026-10-03' THEN 1 ELSE 0 END) AS registros_2026_10_03
FROM final_entregas_db.entregas;
