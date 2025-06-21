SELECT * INTO datosCovid_occidente
FROM covidHistorico.dbo.datoscovid
where ENTIDAD_RES in (18, 14, 06, 16);

SELECT * INTO datosCovid_oriente
FROM covidHistorico.dbo.datoscovid
where ENTIDAD_RES in (30, 21, 29);