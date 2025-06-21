-- UNION GENERAL
SELECT TOP 200 *
FROM OPENQUERY([SERVER_MYSQL], 'SELECT * FROM covidHistorico.datoscovid_sureste')
UNION
SELECT TOP 200 *
FROM OPENQUERY([SERVER_MYSQL], 'SELECT * FROM covidHistorico.datoscovid_suroeste')
UNION
SELECT TOP 200 *
FROM OPENQUERY([SERVER_ALAN], 'SELECT * FROM covidHistorico.dbo.datoscovid_noreste')
UNION
SELECT TOP 200 *
FROM OPENQUERY([SERVER_ALAN], 'SELECT * FROM covidHistorico.dbo.datoscovid_noroeste')
UNION
SELECT TOP 200 *
FROM OPENQUERY([SERVER_AXEL], 'SELECT * FROM covidHistorico.dbo.datoscovid_centronorte')
UNION
SELECT TOP 200 *
FROM OPENQUERY([SERVER_AXEL], 'SELECT * FROM covidHistorico.dbo.datoscovid_centrosur')
UNION
SELECT TOP 200 *
FROM OPENQUERY([SERVER_ERIK], 'SELECT * FROM covidHistorico.dbo.datoscovid_occidente')
UNION
SELECT TOP 200 *
FROM OPENQUERY([SERVER_ERIK], 'SELECT * FROM covidHistorico.dbo.datoscovid_oriente');

-- 4
SELECT DISTINCT entidad_res, MUNICIPIO_RES
FROM (
    SELECT TOP 200 *
    FROM OPENQUERY([SERVER_MYSQL], 'SELECT * FROM covidHistorico.datoscovid_sureste')
    UNION
    SELECT TOP 200 *
    FROM OPENQUERY([SERVER_MYSQL], 'SELECT * FROM covidHistorico.datoscovid_suroeste')
    UNION
    SELECT TOP 200 *
    FROM OPENQUERY([SERVER_ALAN], 'SELECT * FROM covidHistorico.dbo.datoscovid_noreste')
    UNION
    SELECT TOP 200 *
    FROM OPENQUERY([SERVER_ALAN], 'SELECT * FROM covidHistorico.dbo.datoscovid_noroeste')
    UNION
    SELECT TOP 200 *
    FROM OPENQUERY([SERVER_AXEL], 'SELECT * FROM covidHistorico.dbo.datoscovid_centronorte')
    UNION
    SELECT TOP 200 *
    FROM OPENQUERY([SERVER_AXEL], 'SELECT * FROM covidHistorico.dbo.datoscovid_centrosur')
    UNION
    SELECT TOP 200 *
    FROM OPENQUERY([SERVER_ERIK], 'SELECT * FROM covidHistorico.dbo.datoscovid_occidente')
    UNION
    SELECT TOP 200 *
    FROM OPENQUERY([SERVER_ERIK], 'SELECT * FROM covidHistorico.dbo.datoscovid_oriente')
) AS datos
WHERE CLASIFICACION_FINAL NOT IN ('1', '2', '3')
  AND HIPERTENSION = '1'
  AND OBESIDAD = '1'
  AND DIABETES = '1'
  AND TABAQUISMO = '1'
GROUP BY entidad_res, MUNICIPIO_RES;

-- 7
SELECT año, mes, NUM_REGISTROS,ENTIDAD_RES
FROM (
    SELECT YEAR(FECHA_INGRESO) AS año, 
           MONTH(FECHA_INGRESO) AS mes, 
           COUNT(*) AS NUM_REGISTROS,
		   ENTIDAD_RES,
           ROW_NUMBER() OVER (PARTITION BY ENTIDAD_RES ORDER BY COUNT(*) DESC) AS RowNum
    FROM
	(
		    
			SELECT TOP 1000 *
			FROM OPENQUERY([SERVER_ALAN], 'SELECT * FROM covidHistorico.dbo.datoscovid_noroeste')
			
	)
	AS datos
    WHERE (YEAR(FECHA_INGRESO) = 2020 OR YEAR(FECHA_INGRESO) = 2021) 
      AND MONTH(FECHA_INGRESO) < 13 AND (CLASIFICACION_FINAL in ('1','2','3')
	  OR CLASIFICACION_FINAL in ('6')) 
    GROUP BY YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO),ENTIDAD_RES
) A
WHERE A.RowNum = 1 OR A.RowNum = 2
ORDER BY A.ENTIDAD_RES;

-- 5
SELECT ENTIDAD_RES AS entidad, COUNT(*) AS casos_recuperados_neumonia
FROM
(
	SELECT TOP 200 *
	FROM OPENQUERY([SERVER_MYSQL], 'SELECT * FROM covidHistorico.datoscovid_sureste')
	UNION
	SELECT TOP 200 *
	FROM OPENQUERY([SERVER_MYSQL], 'SELECT * FROM covidHistorico.datoscovid_suroeste')
	UNION
	SELECT TOP 200 *
	FROM OPENQUERY([SERVER_ALAN], 'SELECT * FROM covidHistorico.dbo.datoscovid_noreste')
	UNION
	SELECT TOP 200 *
	FROM OPENQUERY([SERVER_ALAN], 'SELECT * FROM covidHistorico.dbo.datoscovid_noroeste')
	UNION
	SELECT TOP 200 *
	FROM OPENQUERY([SERVER_AXEL], 'SELECT * FROM covidHistorico.dbo.datoscovid_centronorte')
	UNION
	SELECT TOP 200 *
	FROM OPENQUERY([SERVER_AXEL], 'SELECT * FROM covidHistorico.dbo.datoscovid_centrosur')
	UNION
	SELECT TOP 200 *
	FROM OPENQUERY([SERVER_ERIK], 'SELECT * FROM covidHistorico.dbo.datoscovid_occidente')
	UNION
	SELECT TOP 200 *
	FROM OPENQUERY([SERVER_ERIK], 'SELECT * FROM covidHistorico.dbo.datoscovid_oriente')
) AS datos
WHERE
	CLASIFICACION_FINAL IN ('1', '2', '3')
	AND
	FECHA_DEF = '9999-99-99'
	AND
	NEUMONIA = '1'
GROUP BY ENTIDAD_RES
ORDER BY casos_recuperados_neumonia DESC;

-- 3
SELECT 
    (CAST(
		SUM (
		 CASE 
			WHEN DIABETES = 1 THEN 1 ELSE 0 END
		 ) * 200.0 / COUNT(*) AS DECIMAL(4,2))
	) porcentajeDiabetes,
    (CAST(
		SUM (
		 CASE 
			WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END
		 ) * 200.0 / COUNT(*) AS DECIMAL(4,2))
	) porcentajeHiper,
    (CAST(
		SUM (
		 CASE 
			WHEN OBESIDAD = 1 THEN 1 ELSE 0 END
		 ) * 200.0 / COUNT(*) AS DECIMAL(4,2))
	) porcentajeObesidad
FROM
(
	SELECT TOP 200 *
	FROM OPENQUERY([SERVER_MYSQL], 'SELECT * FROM covidHistorico.datoscovid_sureste')
	UNION
	SELECT TOP 200 *
	FROM OPENQUERY([SERVER_MYSQL], 'SELECT * FROM covidHistorico.datoscovid_suroeste')
	UNION
	SELECT TOP 200 *
	FROM OPENQUERY([SERVER_ALAN], 'SELECT * FROM covidHistorico.dbo.datoscovid_noreste')
	UNION
	SELECT TOP 200 *
	FROM OPENQUERY([SERVER_ALAN], 'SELECT * FROM covidHistorico.dbo.datoscovid_noroeste')
	UNION
	SELECT TOP 200 *
	FROM OPENQUERY([SERVER_AXEL], 'SELECT * FROM covidHistorico.dbo.datoscovid_centronorte')
	UNION
	SELECT TOP 200 *
	FROM OPENQUERY([SERVER_AXEL], 'SELECT * FROM covidHistorico.dbo.datoscovid_centrosur')
	UNION
	SELECT TOP 200 *
	FROM OPENQUERY([SERVER_ERIK], 'SELECT * FROM covidHistorico.dbo.datoscovid_occidente')
	UNION
	SELECT TOP 200 *
	FROM OPENQUERY([SERVER_ERIK], 'SELECT * FROM covidHistorico.dbo.datoscovid_oriente')
) AS T
WHERE CLASIFICACION_FINAL IN (1, 2, 3)