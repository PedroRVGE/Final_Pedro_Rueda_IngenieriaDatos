-- Verificación del tercer día (2026-10-03), cargado solo subiendo el archivo: sin crawler, sin MSCK REPAIR,
-- sin ALTER TABLE ADD PARTITION y sin cambiar la tabla. Tres consultas, una por resultado:

-- 1) Los seis registros de 2026-10-03  ->  resultados/final/verificacion_tercer_dia.csv
SELECT
    fecha,
    id_envio,
    ciudad,
    transportadora,
    estado,
    duracion_minutos
FROM final_entregas_db.entregas
WHERE fecha = '2026-10-03'
ORDER BY id_envio ASC;

-- 2) Conteos por estado de 2026-10-03  ->  resultados/final/verificacion_tercer_dia_conteo_estado.csv
SELECT
    fecha,
    estado,
    COUNT(*) AS total_intentos
FROM final_entregas_db.entregas
WHERE fecha = '2026-10-03'
GROUP BY fecha, estado
ORDER BY estado ASC;

-- 3) Total de la tabla y registros por fecha (18 = 6 + 6 + 6)  ->  resultados/final/verificacion_tercer_dia_total.csv
SELECT
    COUNT(*) AS total_registros,
    COUNT(DISTINCT fecha) AS fechas_con_datos,
    SUM(CASE WHEN fecha = '2026-10-03' THEN 1 ELSE 0 END) AS registros_2026_10_03,
    COUNT(DISTINCT id_envio) AS envios_distintos
FROM final_entregas_db.entregas;
