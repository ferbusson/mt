INSERT INTO
	libro_auxiliar_niifs
SELECT
	l.*
FROM
	documentos d,
	libro_auxiliar l
WHERE
	d.ndocumento = l.ndocumento AND
	d.numero = '0000000513' AND
	d.codigo_tipo = 'NT';

--

DROP TABLE IF EXISTS aux_argumentos_s;
CREATE TEMP TABLE aux_argumentos_s AS
SELECT
	'2015-02-03'::DATE AS fecha,
	ndocumento
FROM
	documentos
WHERE
	codigo_tipo IN ('NT') AND
	numero = '0000000513';

BEGIN;
UPDATE
	libro_auxiliar
SET
	fecha = s.fecha
FROM
	aux_argumentos_s s
WHERE
	libro_auxiliar.ndocumento = s.ndocumento;

UPDATE
	libro_auxiliar_niifs
SET
	fecha = s.fecha
FROM
	aux_argumentos_s s
WHERE
	libro_auxiliar_niifs.ndocumento = s.ndocumento;


UPDATE
	documentos
SET
	fecha = s.fecha
FROM
	aux_argumentos_s s
WHERE
	documentos.ndocumento = s.ndocumento;

COMMIT;


	