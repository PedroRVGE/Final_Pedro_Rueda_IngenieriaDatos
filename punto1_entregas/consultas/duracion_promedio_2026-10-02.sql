-- Duración promedio (minutos) de las entregas EXITOSAS del 2026-10-02, todas las ciudades y transportadoras.
-- Solo estado 'entregado': los intentos fallidos tienen duración 0 y no deben bajar el promedio.
-- El filtro por fecha usa la clave de partición (Athena solo lee esa carpeta).
SELECT
    fecha,
    CAST(ROUND(AVG(duracion_minutos), 2) AS DECIMAL(10, 2)) AS duracion_promedio_minutos
FROM final_entregas_db.entregas
WHERE fecha = '2026-10-02'
  AND estado = 'entregado'
GROUP BY fecha;
