--pt
DROP TABLE IF EXISTS aux_prod_term;
CREATE TEMP TABLE
	aux_prod_term AS
SELECT
	'673'::CHARACTER(10) AS numero,
	'0591602366'::CHARACTER VARYING(50) AS referencia;

DROP TABLE IF EXISTS aux_sobrantesc;
CREATE TEMP TABLE aux_sobrantesc AS
SELECT
	foo1.id_talla,
	foo1.talla,
	cant-(ROUND(((foo1.cant/factorc)-0.5)::NUMERIC,0)*factorc) AS cants,
	ROUND((foo1.pcosto)::NUMERIC,2) AS pcosto,
	(cant-(ROUND(((foo1.cant/factorc)-0.5)::NUMERIC,0)*factorc))*ROUND((foo1.pcosto)::NUMERIC,2) AS tcosto,
	foo1.id_bodega
FROM
	(SELECT
		id_talla,
		talla,
		SUM(cant) AS cant,
		AVG(pcosto) AS pcosto,
		SUM(ctotal) AS ctotal,
		id_bodega,
		factorc
	FROM
		(SELECT
			ps.codigo,
			i3.ref_alterna AS referencia,
			i3.nombre AS descripcion,
			c.descripcion AS color,
			t.id_talla,
			t.talla,
			dp.cant,
			ROUND(ps.pcosto::NUMERIC,2) AS pcosto,
			ROUND((ps.pcosto*dp.cant)::NUMERIC,2) AS ctotal,
			ps.id_prod_serv,
			inv.id_bodega,
			it.factorc
		FROM 
			documentos d,
			documentos d2,
			info_documento i,
			datos_prod dp,
			prod_serv ps,
			items_tmp3 i3,
			tallas t,
			item it,
			colores c,
			aux_prod_term a,
			(SELECT DISTINCT i.ndocumento,i.id_bodega FROM inventarios i, documentos d WHERE i.ndocumento = d.ndocumento AND d.codigo_tipo = 'PT' AND d.estado) AS inv
		WHERE
			d.codigo_tipo = 'CS' AND
			d.numero = LPAD(a.numero,10,'0') AND
			d.ndocumento = i.rf_documento AND
			i.ndocumento = d2.ndocumento AND
			d2.ndocumento = inv.ndocumento AND
			d2.codigo_tipo = 'PT' AND
			d2.estado AND
			d.estado AND
			it.ref_proveedor = a.referencia AND
			d2.ndocumento = dp.ndocumento AND
			dp.id_prod_serv = ps.id_prod_serv AND
			ps.id_item = i3.referencia AND
			i3.marca = '715' AND
			ps.id_talla = t.id_talla AND
			ps.id_color = c.id_color
		ORDER BY
			t.talla,
			c.descripcion) AS foo
	GROUP BY
		id_talla,
		talla,
		id_bodega,
		factorc) AS foo1;

DROP TABLE IF EXISTS aux_prendas_total;
CREATE TEMP TABLE aux_prendas_total AS
SELECT
	ps.codigo,
	i3.ref_alterna AS referencia,
	i3.nombre AS descripcion,
	c.descripcion AS color,
	t.talla,
	t.id_talla,
	dp.cant,
	ROUND(ps.pcosto::NUMERIC,2) AS pcosto,
	0 AS ctotal,
	ps.id_prod_serv,
	inv.id_bodega
FROM 
	documentos d,
	documentos d2,
	info_documento i,
	aux_prod_term a,
	datos_prod dp,
	prod_serv ps,
	items_tmp3 i3,
	tallas t,
	colores c,
	(SELECT DISTINCT i.ndocumento,i.id_bodega FROM inventarios i, documentos d WHERE i.ndocumento = d.ndocumento AND d.codigo_tipo = 'PT' AND d.estado) AS inv
WHERE
	d.codigo_tipo = 'CS' AND
	d.numero = LPAD(a.numero,10,'0') AND
	d.ndocumento = i.rf_documento AND
	i.ndocumento = d2.ndocumento AND
	d2.ndocumento = inv.ndocumento AND
	d2.codigo_tipo = 'PT' AND
	d2.estado AND
	d.estado AND
	d2.ndocumento = dp.ndocumento AND
	dp.id_prod_serv = ps.id_prod_serv AND
	ps.id_item = i3.referencia AND
	i3.marca = '715' AND
	ps.id_talla = t.id_talla AND
	ps.id_color = c.id_color
ORDER BY
	t.talla,
	c.descripcion;
DROP TABLE IF EXISTS temporal_pt_rev;
CREATE TEMP TABLE temporal_pt_rev AS
SELECT
	a.codigo,
	a.referencia,
	a.descripcion,
	a.color,
	a.talla,
	CASE WHEN foo.cant IS NOT NULL THEN foo.cant ELSE a.cant END AS cant,
	a.pcosto,
	CASE WHEN foo.cant IS NOT NULL THEN foo.cant*a.pcosto ELSE a.cant*a.pcosto END AS ctotal,
	a.id_prod_serv,
	a.id_bodega,
	0
FROM
	aux_prendas_total a
LEFT OUTER JOIN
	(SELECT DISTINCT ON (a1.id_talla)
		id_prod_serv,
		cant-cants AS cant
	FROM
		aux_prendas_total a1,
		aux_sobrantesc a2
	WHERE
		a2.cants > 0 AND
		a1.id_talla = a2.id_talla AND
		a2.cants < a1.cant
	ORDER BY
		a1.id_talla) AS foo
ON
	a.id_prod_serv = foo.id_prod_serv;

SELECT
	SUM(ctotal)
FROM
	temporal_pt_rev;