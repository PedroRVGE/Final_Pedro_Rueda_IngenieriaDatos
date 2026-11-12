-- Porcentaje de entregas exitosas por fecha y ciudad: 100 * entregados / total de intentos del grupo.
-- El denominador incluye todos los estados. 100.0 (decimal) evita la división entera;
-- el resultado se redondea y se presenta con exactamente dos decimales (DECIMAL(5,2)).
SELECT
    fecha,
    ciudad,
    CAST(
        ROUND(100.0 * SUM(CASE WHEN estado = 'entregado' THEN 1 ELSE 0 END) / COUNT(*), 2)
        AS DECIMAL(5, 2)
    ) AS porcentaje_exito
FROM final_entregas_db.entregas
GROUP BY fecha, ciudad
ORDER BY fecha ASC, ciudad ASC;
