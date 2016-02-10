SELECT DISTINCT
	CASE WHEN
		r.imei IS NOT NULL
	THEN
		r.imei
	ELSE
		CASE WHEN
			r.serial IS NOT NULL
		THEN
			r.serial
		ELSE
			ps.codigo
		END
	END AS codigo,
	i.ref_proveedor||' '||it3.nombre||' '||m.descripcion||' '||t.talla||' '||c.descripcion||' Imei:'||COALESCE(r.imei,'0')||' Serial:'||COALESCE(r.serial,'') AS desc_base
FROM
	item i,
	items_tmp3 it3,
	marcas m,
	colores c,
	tallas t,
	prod_serv ps
LEFT OUTER JOIN
	registro_seriales r
ON
	ps.id_prod_serv = r.id_prod_serv
WHERE
	it3.referencia=i.id_item AND
	ps.id_item = i.id_item AND
	ps.id_talla = t.id_talla AND
	ps.id_color = c.id_color AND
	i.id_marca = m.id_marca AND
	(CAST(ps.codigo AS CHARACTER(13))= '?' OR
	i.ref_proveedor||' '||it3.nombre||' '||m.descripcion||' '||t.talla||' '||
	c.descripcion||' '||COALESCE(r.serial,'')||' '||COALESCE(r.imei,'') ILIKE '%?%');