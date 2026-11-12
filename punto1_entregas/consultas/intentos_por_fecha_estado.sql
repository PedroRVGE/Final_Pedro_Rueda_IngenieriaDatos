-- Cantidad de intentos por fecha y estado (todos los intentos), ordenado por fecha y estado ascendente.
-- Sin filtro de fechas: cubre todas las fechas con datos dentro de la proyección (inicial: días 1-2; final: días 1-3).
SELECT
    fecha,
    estado,
    COUNT(*) AS total_intentos
FROM final_entregas_db.entregas
GROUP BY fecha, estado
ORDER BY fecha ASC, estado ASC;
