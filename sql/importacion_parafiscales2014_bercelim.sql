COMMIT;
BEGIN;
DELETE FROM 
	libro_auxiliar
USING 
	(SELECT
		l.orden
	FROM
		documentos d,
		libro_auxiliar l,
		parafiscales2014 p,
		cuentas cu
	WHERE
		d.ndocumento = l.ndocumento AND
		l.id_cta = cu.id_cta AND
		cu.char_cta = p.char_cta AND
		d.codigo_tipo = 'SI') AS foo
WHERE
	libro_auxiliar.orden = foo.orden;

	
INSERT INTO
	libro_auxiliar(
		id_cta,
		fecha,
		id_tercero,
		detalle,
		ndocumento,
		debe,
		haber,
		saldo
		)
SELECT
	cu.id_cta,
	'2014-12-31 23:59:59' AS fecha,
	g.id,
	'Insercion a saldos iniciales de parafiscales 2014' AS detalle,
	711067,
	0.0,
	p.valor,
	0.0 AS saldo
FROM
	parafiscales2014 p,
	cuentas cu,
	general g
WHERE
	p.char_cta = cu.char_cta AND
	g.id_char = p.id_char;

DELETE FROM
	libro_auxiliar
WHERE
	detalle = 'Insercion a saldos iniciales de parafiscales 2014'


SELECT
	sum(debe),
	sum(haber),
	ROUND(sum(debe)::NUMERIC,2)-ROUND(sum(haber)::NUMERIC,2),
	546967332.11- ROUND(sum(debe)::NUMERIC,2)-ROUND(sum(haber)::NUMERIC,2)
FROM
	libro_auxiliar l,
	cuentas cu
WHERE
	l.id_cta = cu.id_cta AND
-- 	(cu.char_cta LIKE '1%' OR
-- 	cu.char_cta LIKE '2%') AND
	l.fecha::DATE <= '2014-12-31'


SELECT
	l.*
FROM
	documentos d,
	libro_auxiliar l,
	cuentas cu
WHERE
	d.ndocumento = l.ndocumento AND
	l.id_cta = cu.id_cta AND
	cu.char_cta LIKE '3%' AND
	d.codigo_tipo = 'SI';
commit;
begin;
UPDATE
	libro_auxiliar
SET
	haber = haber - 7118064
WHERE
	orden = 359576;