/***************
 N�mero de consulta: 1

 Descripci�n de la consulta: 
Listar el top 5 de las entidades con m�s casos confirmados por 
cada uno de los a�os registrados en la base de datos.

 Requisitos: N/A

 Significado de los valores de los cat�logos:
	CLASIFICACION_FINAL:
		- 1: CASO DE COVID-19 CONFIRMADO POR ASOCIACI�N CL�NICA EPIDEMIOL�GICA
		- 2: CASO DE COVID-19 CONFIRMADO POR COMIT� DE  DICTAMINACI�N
		- 3: CASO DE SARS-COV-2  CONFIRMADO
	ENTIDAD_UM:Identifica la entidad donde se ubica la unidad medica
	que brind� la atenci�n y el listado viene en el catalogo de entidades
	con una clave para su identificacion.
	FECHA_INGRESO:Identifica la fecha de ingreso del paciente a la unidad
	de atenci�n.

 Responsable de la consulta: Axel Ivan Rosssano Medina

 Comentarios:
	La sentencia 'ROW_NUMBER() OVER (PARTITION BY YEAR(FECHA_INGRESO) 
	ORDER BY COUNT(*) DESC) AS RowNum'
	agrega una columna con un identificador tipo entero que inserta a los 
	registros iguales mientras que si un registro es diferente al anterior
	reinicia el identificador a 1 siempre teniendo en cuenta que el orden 
	de la columna count(*) se hace de forma descendente.
	
***************/

SELECT * 
FROM cat_entidades E INNER JOIN 
(SELECT  ENTIDAD_UM,YEAR(FECHA_INGRESO) a�oIngreso,COUNT(*) casosEntidad,
ROW_NUMBER() OVER (PARTITION BY YEAR(FECHA_INGRESO) ORDER BY COUNT(*) DESC) AS RowNum
FROM datoscovid C
WHERE CLASIFICACION_FINAL in('1','2','3')
GROUP BY ENTIDAD_UM,YEAR(FECHA_INGRESO)
) casos
ON casos.ENTIDAD_UM = E.clave 
WHERE RowNum <= 5
ORDER BY casos.a�oIngreso, casos.RowNum



/***************
 N�mero de consulta: 4
 Descripci�n de la consulta:Listar los municipios que no tengan 
 casos confirmados en todas las morbilidades: hipertensi�n, obesidad, 
 diabetes, tabaquismo. 

 Requisitos: N/A

 Significado de los valores de los cat�logos:
	CLASIFICACION_FINAL:
		- 4: INV�LIDO POR LABORATORIO
		- 5: NO REALIZADO POR LABORATORIO
		- 6: CASO SOSPECHOSO
		- 7: NEGATIVO A SARS-COV-2

	MUNICIPIO_RES:Identifica el municipio de residencia del paciente los cuales
				  estan en el catalogo de MUNICIPIOS.
	MORBILIDADES:el listado esta en la tablas datoscovid en el catalogo SI_NO
	donde 1=si,2=no,97=no aplica,98=se ignora,99=no especificado
					
 Responsable de la consulta: Axel Ivan Rosssano Medina

 Comentarios:
	
***************/


 SELECT distinct entidad_res,MUNICIPIO_RES
								FROM datoscovid
								WHERE CLASIFICACION_FINAL not in ('1','2','3') 
								AND HIPERTENSION='1'
								AND OBESIDAD='1' 
								AND DIABETES='1' 
								AND TABAQUISMO='1'
GROUP BY  entidad_res,MUNICIPIO_RES


/***************
 N�mero de consulta: 7
 Descripci�n de la consulta:
 Para el a�o 2020 y 2021 cu�l fue el mes con m�s casos registrados, confirmados, 
sospechosos, por estado registrado en la base de datos. 

 

 Requisitos: N/A
 Significado de los valores de los cat�logos:
	CLASIFICACION_FINAL:
		- 1: CASO DE COVID-19 CONFIRMADO POR ASOCIACI�N CL�NICA EPIDEMIOL�GICA
		- 2: CASO DE COVID-19 CONFIRMADO POR COMIT� DE  DICTAMINACI�N
		- 3: CASO DE SARS-COV-2  CONFIRMADO
	FECHA_INGRESO:Identifica la fecha de ingreso del paciente a la unidad
	de atenci�n.
	MUNICIPIO_RES:Identifica el municipio de residencia del paciente los cuales
				  estan en el catalogo de MUNICIPIOS.

 Responsable de la consulta: Axel Ivan Rosssano Medina

 Comentarios:
	
***************/

SELECT a�o, mes, NUM_REGISTROS,ENTIDAD_RES
FROM (
    SELECT YEAR(FECHA_INGRESO) AS a�o, 
           MONTH(FECHA_INGRESO) AS mes, 
           COUNT(*) AS NUM_REGISTROS,
		   ENTIDAD_RES,
           ROW_NUMBER() OVER (PARTITION BY ENTIDAD_RES ORDER BY COUNT(*) DESC) AS RowNum
    FROM datoscovid D
    WHERE (YEAR(FECHA_INGRESO) = 2020 OR YEAR(FECHA_INGRESO) = 2021) 
      AND MONTH(FECHA_INGRESO) < 13 AND (CLASIFICACION_FINAL in ('1','2','3')
	  OR CLASIFICACION_FINAL in ('6')) 
    GROUP BY YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO),ENTIDAD_RES
) A
WHERE A.RowNum = 1 OR A.RowNum = 2
ORDER BY A.ENTIDAD_RES;


/***************
 N�mero de consulta: 10
 Descripci�n de la consulta:
 Listar el porcentaje de casos confirmado por g�nero en los a�os 2020 y 2021. 
 
 Requisitos: N/A

 Significado de los valores de los cat�logos:
	CLASIFICACION_FINAL:
		- 1: CASO DE COVID-19 CONFIRMADO POR ASOCIACI�N CL�NICA EPIDEMIOL�GICA
		- 2: CASO DE COVID-19 CONFIRMADO POR COMIT� DE  DICTAMINACI�N
		- 3: CASO DE SARS-COV-2  CONFIRMADO
	FECHA_INGRESO:Identifica la fecha de ingreso del paciente a la unidad
	de atenci�n.
	SEXO: Identifica el sexo de una persona que se describe mas a fondo en
	el catalogo SEXO donde 1=mujer,2=hombre,99=no especificado 

 Responsable de la consulta: Axel Ivan Rosssano Medina

 Comentarios:
	
***************/

SELECT CCS.SEXO,(CCS.casos_confirmados * 100.0 / CCT.casos_confirmados) porcentaje,
	   CCS.a�o
FROM   (SELECT COUNT(*) casos_confirmados
		FROM datoscovid
		WHERE CLASIFICACION_FINAL IN ('1','2','3')
		AND  (YEAR(FECHA_INGRESO)=2020 OR YEAR(FECHA_INGRESO)=2021)) CCT

CROSS JOIN

		(SELECT SEXO,COUNT(*) casos_confirmados,YEAR(FECHA_INGRESO) a�o
		 FROM datoscovid
		 WHERE CLASIFICACION_FINAL IN ('1','2','3')
		 AND  (YEAR(FECHA_INGRESO)=2020 OR YEAR(FECHA_INGRESO)=2021)
		 GROUP BY SEXO,YEAR(FECHA_INGRESO)) CCS
		 ORDER BY CCS.a�o

/***************
 N�mero de consulta: 13
 Descripci�n de la consulta:
Listar porcentajes de casos confirmados por g�nero en el rango de 
edades de 20 a 30 a�os,de 31 a 40 a�os, de 41 a 50 a�os, 
de 51 a 60 a�os y mayores a 60 a�os a nivel nacional. 
 
 Requisitos: se cre� una vista que hace el promedio por rango de edades donde 
			 se toma como un total a todos los rangos de edades y se calculo 
			 el porcentajo de los rangos.

 Significado de los valores de los cat�logos:
	CLASIFICACION_FINAL:
		- 1: CASO DE COVID-19 CONFIRMADO POR ASOCIACI�N CL�NICA EPIDEMIOL�GICA
		- 2: CASO DE COVID-19 CONFIRMADO POR COMIT� DE  DICTAMINACI�N
		- 3: CASO DE SARS-COV-2  CONFIRMADO
	SEXO: Identifica el sexo de una persona que se describe mas a fondo en
	el catalogo SEXO donde 1=mujer,2=hombre,99=no especificado 
	EDAD: Identifica la edad de el caso.
    Responsable de la consulta: Axel Ivan Rosssano Medina

 Comentarios:
	
***************/


CREATE VIEW VEINTETRINTA AS
SELECT 
    SEXO,  
    (PGE.VEINTETREINTA * 100.0 / TOTAL.total) AS porcentaje, '20-30' AS RANGOS
	FROM
				(SELECT  
					 SEXO, 
					 COUNT(*) AS VEINTETREINTA
					 FROM datoscovid 
					 WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
					 AND EDAD BETWEEN 20 AND 30
					 GROUP BY SEXO ) PGE
				CROSS JOIN 
					(SELECT COUNT(*) AS total
					 FROM datoscovid 
					 WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
					AND (EDAD BETWEEN 20 AND 30 OR EDAD BETWEEN 31 AND 40
					OR EDAD BETWEEN 41 AND 50 OR EDAD BETWEEN 51 AND 60
					OR EDAD >60)) TOTAL;



CREATE VIEW TREINTAYUNOCUARENTA AS
SELECT 
    SEXO,  
    (PGE.TREINTAYUNOCUARENTA * 100.0 / TOTAL.total) AS porcentaje, '31-40' AS RANGOS
	FROM
				(SELECT  
					 SEXO, 
					 COUNT(*) AS TREINTAYUNOCUARENTA
					 FROM datoscovid 
					 WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
					 AND EDAD BETWEEN 31 AND 40
					 GROUP BY SEXO ) PGE
				CROSS JOIN 
					(SELECT COUNT(*) AS total
					 FROM datoscovid 
					 WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
					AND (EDAD BETWEEN 20 AND 30 OR EDAD BETWEEN 31 AND 40
					OR EDAD BETWEEN 41 AND 50 OR EDAD BETWEEN 51 AND 60
					OR EDAD >60)) TOTAL;



CREATE VIEW CUARENTAYUNOCINCUENTA AS
SELECT 
    SEXO,  
    (PGE.CUARENTAYUNOCINCUENTA * 100.0 / TOTAL.total) AS porcentaje, '41-50' AS RANGOS
	FROM
				(SELECT  
					 SEXO, 
					 COUNT(*) AS CUARENTAYUNOCINCUENTA
					 FROM datoscovid 
					 WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
					 AND EDAD BETWEEN 41 AND 50
					 GROUP BY SEXO ) PGE
				CROSS JOIN 
					(SELECT COUNT(*) AS total
					 FROM datoscovid 
					 WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
					AND (EDAD BETWEEN 20 AND 30 OR EDAD BETWEEN 31 AND 40
					OR EDAD BETWEEN 41 AND 50 OR EDAD BETWEEN 51 AND 60
					OR EDAD >60)) TOTAL;


CREATE VIEW CINCUENTAYUNOSESENTA AS
SELECT 
    SEXO,  
    (PGE.CINCUENTAYUNOSESENTA * 100.0 / TOTAL.total) AS porcentaje, '51-60' AS RANGOS
	FROM
				(SELECT  
					 SEXO, 
					 COUNT(*) AS CINCUENTAYUNOSESENTA
					 FROM datoscovid 
					 WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
					 AND EDAD BETWEEN 51 AND 60
					 GROUP BY SEXO ) PGE
				CROSS JOIN 
					(SELECT COUNT(*) AS total
					 FROM datoscovid 
					 WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
					AND (EDAD BETWEEN 20 AND 30 OR EDAD BETWEEN 31 AND 40
					OR EDAD BETWEEN 41 AND 50 OR EDAD BETWEEN 51 AND 60
					OR EDAD >60)) TOTAL;




CREATE VIEW MAYORSESENTA AS
SELECT 
    SEXO,  
    (PGE.MAYORSESENTA * 100.0 / TOTAL.total) AS porcentaje, 'mayor a 60' AS RANGOS
	FROM
				(SELECT  
					 SEXO, 
					 COUNT(*) AS MAYORSESENTA
					 FROM datoscovid 
					 WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
					 AND EDAD > 60
					 GROUP BY SEXO ) PGE
				CROSS JOIN 
					(SELECT COUNT(*) AS total
					 FROM datoscovid 
					 WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
					AND (EDAD BETWEEN 20 AND 30 OR EDAD BETWEEN 31 AND 40
					OR EDAD BETWEEN 41 AND 50 OR EDAD BETWEEN 51 AND 60
					OR EDAD >60)) TOTAL;




SELECT *
FROM VEINTETRINTA

UNION ALL

SELECT *
FROM TREINTAYUNOCUARENTA

UNION ALL

SELECT *
FROM CINCUENTAYUNOSESENTA

UNION ALL

SELECT *
FROM MAYORSESENTA


/***************
 N�mero de consulta: 2
 Descripci�n de la consulta: Listar el municipio con m�s casos confirmados recuperados por estado y por a�o.
 Requisitos: N/A
 Significado de los valores de los cat�logos:
	CLASIFICACION_FINAL:
		- 1: CASO DE COVID-19 CONFIRMADO POR ASOCIACI�N CL�NICA EPIDEMIOL�GICA
		- 2: CASO DE COVID-19 CONFIRMADO POR COMIT� DE  DICTAMINACI�N
		- 3: CASO DE SARS-COV-2  CONFIRMADO
 Responsable de la consulta: Alan Gonz�lez
 Comentarios:
	La sentencia 'WITH' asigna un nombre a una consulta, haciendo m�s legible la l�gica ejecutada. 
***************/
WITH CasosEntidadMunicipioA�o
AS (
	SELECT ENTIDAD_RES AS entidad, MUNICIPIO_RES AS municipio, YEAR(FECHA_INGRESO) AS a�o, COUNT(*) AS casos_recuperados
	FROM datoscovid--_M
	WHERE
		CLASIFICACION_FINAL IN ('1', '2', '3')
		AND
		FECHA_DEF = '9999-99-99'
	GROUP BY ENTIDAD_RES, MUNICIPIO_RES, YEAR(FECHA_INGRESO)
)
SELECT *
FROM CasosEntidadMunicipioA�o AS T1
WHERE casos_recuperados = (
    SELECT MAX(casos_recuperados)
    FROM CasosEntidadMunicipioA�o AS T2
    WHERE T1.entidad = T2.entidad AND T1.a�o = T2.a�o
)
ORDER BY a�o, entidad, municipio;

/***************
 N�mero de consulta: 5
 Descripci�n de la consulta: Listar los estados con m�s casos recuperados con neumon�a.
 Requisitos: N/A
 Significado de los valores de los cat�logos:
	NEUMON�A:
		- 1: SI
 Responsable de la consulta: Alan Gonz�lez
 Comentarios:
***************/
SELECT ENTIDAD_RES AS entidad, COUNT(*) AS casos_recuperados_neumonia
FROM datoscovid--_M
WHERE
	CLASIFICACION_FINAL IN ('1', '2', '3')
	AND
	FECHA_DEF = '9999-99-99'
	AND
	NEUMONIA = '1'
GROUP BY ENTIDAD_RES
ORDER BY casos_recuperados_neumonia DESC;

/***************
 N�mero de consulta: 8
 Descripci�n de la consulta: Listar el municipio con menos defunciones en el mes con m�s casos confirmados con neumon�a en los a�os 2020 y 2021.
 Requisitos: N/A
 Significado de los valores de los cat�logos:
 	CLASIFICACION_FINAL:
		- 1: CASO DE COVID-19 CONFIRMADO POR ASOCIACI�N CL�NICA EPIDEMIOL�GICA
		- 2: CASO DE COVID-19 CONFIRMADO POR COMIT� DE  DICTAMINACI�N
		- 3: CASO DE SARS-COV-2  CONFIRMADO

	NEUMON�A:
		- 1: SI
 Responsable de la consulta: Alan Gonz�lez
 Comentarios: CROSS JOIN se usa para combinar todas las filas de una tabla con otra, en este caso 1 fila de mes con todas las filas de municipios
***************/
WITH MesConMasCasosConfirmadosNeumonia
AS (
	SELECT TOP 1 MONTH(FECHA_INGRESO) AS mes
	FROM datoscovid--_M
	WHERE
		CLASIFICACION_FINAL IN ('1', '2', '3')
		AND
		NEUMONIA = '1'
		AND
		YEAR(FECHA_INGRESO) IN ('2020', '2021')
	GROUP BY MONTH(FECHA_INGRESO)--, YEAR(FECHA_INGRESO) -- mes y a�o o solo mes?
	ORDER BY COUNT(*) DESC
),
DefuncionesPorMunicipioEnMes
AS (
	SELECT MUNICIPIO_RES AS municipio, COUNT(*) AS defunciones
	FROM datoscovid--_M
	WHERE  
		FECHA_DEF != '9999-99-99'
		AND
		MONTH(FECHA_DEF) = (
			SELECT mes
			FROM MesConMasCasosConfirmadosNeumonia
		)
	GROUP BY MUNICIPIO_RES
)
SELECT *
FROM DefuncionesPorMunicipioEnMes
CROSS JOIN
MesConMasCasosConfirmadosNeumonia
WHERE defunciones = (
  SELECT MIN(defunciones)
  FROM DefuncionesPorMunicipioEnMes
);

/***************
 N�mero de consulta: 11
 Descripci�n de la consulta: Listar el porcentaje de casos hospitalizados por estado en el a�o 2020.
 Requisitos: N/A
 Significado de los valores de los cat�logos:
 	TIPO_PACIENTE:
		- 2: HOSPITALIZADO
 Responsable de la consulta: Alan Gonz�lez
 Comentarios: 
***************/
WITH CasosPorEntidad
AS (
	SELECT ENTIDAD_RES AS estado, COUNT(*) as casos
	FROM datoscovid--_M
	WHERE YEAR(FECHA_INGRESO) = '2020'
	GROUP BY ENTIDAD_RES
),
CasosHospitalizadosPorEntidad
AS (
	SELECT ENTIDAD_RES AS estado, COUNT(*) as casos_hospitalizados
	FROM datoscovid--_M
	WHERE
		YEAR(FECHA_INGRESO) = '2020'
		AND
		TIPO_PACIENTE = '2'
	GROUP BY ENTIDAD_RES
)
SELECT 
    T1.estado,
    T1.casos,
    T2.casos_hospitalizados,
    (T2.casos_hospitalizados * 100.0 / T1.casos) AS porcentaje_hospitalizados
FROM CasosPorEntidad AS T1
LEFT JOIN CasosHospitalizadosPorEntidad AS T2 ON T1.estado = T2.estado
ORDER BY porcentaje_hospitalizados DESC;

/***************
 N�mero de consulta: 14
 Descripci�n de la consulta: Listar el rango de edad con m�s casos confirmados y que fallecieron en los a�os 2020 y 2021.
 Requisitos: N/A
 Significado de los valores de los cat�logos:
 Responsable de la consulta: Alan Gonz�lez
 Comentarios: La sentencia CASE establece condiciones en las que los registros ser�n evaluados para agruparse con el GROUP BY
***************/
SELECT
    CASE 
        WHEN EDAD < 20 THEN '0-19'
        WHEN EDAD BETWEEN 20 AND 30 THEN '20-30'
        WHEN EDAD BETWEEN 31 AND 40 THEN '31-40'
        WHEN EDAD BETWEEN 41 AND 50 THEN '41-50'
        WHEN EDAD BETWEEN 51 AND 60 THEN '51-60'
        ELSE '60+' 
    END AS rango_edad,
    COUNT(*) AS defunciones
FROM datoscovid--_M
WHERE 
    FECHA_DEF != '9999-99-99'
    AND
	YEAR(FECHA_DEF) IN ('2020', '2021')
GROUP BY 
    CASE 
        WHEN EDAD < 20 THEN '0-19'
        WHEN EDAD BETWEEN 20 AND 30 THEN '20-30'
        WHEN EDAD BETWEEN 31 AND 40 THEN '31-40'
        WHEN EDAD BETWEEN 41 AND 50 THEN '41-50'
        WHEN EDAD BETWEEN 51 AND 60 THEN '51-60'
        ELSE '60+' 
    END
ORDER BY rango_edad DESC;

/*
	Responsable de la consulta: Erik Bravo
	3. Listar el porcentaje de casos confirmados en cada una de las siguientes morbilidades a nivel nacional: diabetes, obesidad e hipertensi�n. 
	CLASIFICACION_FINAL:
		- 1: CASO DE COVID-19 CONFIRMADO POR ASOCIACI�N CL�NICA EPIDEMIOL�GICA
		- 2: CASO DE COVID-19 CONFIRMADO POR COMIT� DE  DICTAMINACI�N
		- 3: CASO DE SARS-COV-2  CONFIRMADO
	DIABETES, HIPERTENSION, OBESIDAD
		- 1: SI
	SUM: calcula la suma de los valores de una columna num�rica en un conjunto de registros. 
	CASE: estructura condicional que permite evaluar diferentes condiciones y devolver un valor seg�n el resultado. 
*/
SELECT 
    (CAST(
		SUM (
		 CASE 
			WHEN DIABETES = 1 THEN 1 ELSE 0 END
		 ) * 100.0 / COUNT(*) AS DECIMAL(4,2))
	) porcentajeDiabetes,
    (CAST(
		SUM (
		 CASE 
			WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END
		 ) * 100.0 / COUNT(*) AS DECIMAL(4,2))
	) porcentajeHiper,
    (CAST(
		SUM (
		 CASE 
			WHEN OBESIDAD = 1 THEN 1 ELSE 0 END
		 ) * 100.0 / COUNT(*) AS DECIMAL(4,2))
	) porcentajeObesidad
FROM datoscovid
WHERE CLASIFICACION_FINAL IN (1, 2, 3)


/* 
	Responsable de la consulta: Erik Bravo
	6. Listar el total de casos confirmados/sospechosos por estado en cada uno de los a�os registrados en la base de datos 
	CLASIFICACION_FINAL: 
		- 1: CASO DE COVID-19 CONFIRMADO POR ASOCIACI�N CL�NICA EPIDEMIOL�GICA 
		- 2: CASO DE COVID-19 CONFIRMADO POR COMIT� DE DICTAMINACI�N 
		- 3: CASO DE SARS-COV-2 CONFIRMADO 
		- 6: SOSPECHOSO
	ENTIDADES: 
		Cada clave de 01 a 32 est� asociada a una entidad de M�xico 
		36: ESTADOS UNIDOS
		97: NO APLICA 
		98: SE IGNORA 
		99: NO ESPECIFICADO 
	DATEPART: Devuelve una parte espec�fica de una fecha, como el a�o, mes, d�a, hora, minuto, etc. 
*/ 
SELECT 
    D.entidad, 
    YEAR(B.FECHA_INGRESO) AS a�o, 
    COUNT(B.ID_REGISTRO) AS total_casos,
    SUM(CASE WHEN B.CLASIFICACION_FINAL IN (1, 2, 3) THEN 1 ELSE 0 END) AS casos_confirmados,
    SUM(CASE WHEN B.CLASIFICACION_FINAL = 6 THEN 1 ELSE 0 END) AS casos_sospechosos
FROM datoscovid B
JOIN cat_entidades D 
    ON B.ENTIDAD_UM = D.clave
WHERE B.CLASIFICACION_FINAL IN (1, 2, 3, 6)
GROUP BY D.entidad, YEAR(B.FECHA_INGRESO)
ORDER BY D.entidad, a�o;


/*
	Responsable de la consulta: Erik Bravo
	9. Listar el top 3 de municipios con menos casos recuperados en el a�o 2021 
	FECHA_DEF = �9999-99-99' 
		Es el valor que se le da a las personas que fueron confirmadas, pero se recuperaron 
	ENTIDADES: 
		Cada clave de municipio est� asociada a un municipio de una entidad de M�xico 
		999: NO ESPECIFICADO 
	DATEPART: Devuelve una parte espec�fica de una fecha, como el a�o, mes, d�a, hora, minuto, etc. 
*/
SELECT TOP 3 ENTIDAD_RES, MUNICIPIO_RES, COUNT(ID_REGISTRO) AS cantPorMunicipio, DATEPART(YEAR, FECHA_INGRESO) AS a�o
FROM datoscovid
WHERE FECHA_DEF = '9999-99-99' AND DATEPART(YEAR, FECHA_INGRESO) = '2021'
GROUP BY ENTIDAD_RES, MUNICIPIO_RES, DATEPART(YEAR, FECHA_INGRESO)
ORDER BY cantPorMunicipio ASC;


/*
	Responsable de la consulta: Erik Bravo
	12. Listar el total de casos negativos por estado en los a�os 2020 y 2021
	CLASIFICACION_FINAL = 7 
		Es el valor que se le da a las personas que su clasificaci�n fue negativa 
	ENTIDADES: 
		Cada clave de 01 a 32 est� asociada a una entidad de M�xico 
		36: ESTADOS UNIDOS 
		97: NO APLICA 
		98: SE IGNORA 
		99: NO ESPECIFICADO 
	DATEPART: Devuelve una parte espec�fica de una fecha, como el a�o, mes, d�a, hora, minuto, etc. 
*/
SELECT D.entidad, SUM(C.cantPorEstado) AS casosNegativos
FROM cat_entidades D
JOIN (
    SELECT B.ENTIDAD_UM, COUNT(B.ID_REGISTRO) AS cantPorEstado
    FROM datoscovid B
    JOIN (
        SELECT ENTIDAD_UM, ID_REGISTRO 
        FROM datoscovid
        WHERE CLASIFICACION_FINAL = 7
        AND DATEPART(YEAR, FECHA_INGRESO) IN ('2020', '2021')
    ) AS A
    ON A.ID_REGISTRO = B.ID_REGISTRO
    GROUP BY B.ENTIDAD_UM
) AS C
ON D.clave = C.ENTIDAD_UM
GROUP BY D.entidad
ORDER BY D.entidad ASC;