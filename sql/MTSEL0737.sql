DROP TABLE IF EXISTS aux_args_sentencia;
CREATE TEMP TABLE aux_args_sentencia AS
SELECT
	'?'::CHARACTER(20) AS codigo_in;

SELECT
	ps.codigo
FROM
	aux_args_sentencia a,
	prod_serv ps
LEFT OUTER JOIN
	registro_seriales rs
ON
	ps.id_prod_SERV = rs.id_prod_serv
WHERE
	COALESCE(rs.serial,'0000000000000') = a.codigo_in OR
	COALESCE(rs.imei,'0000000000000') = a.codigo_in OR
	ps.codigo = codigo_in;