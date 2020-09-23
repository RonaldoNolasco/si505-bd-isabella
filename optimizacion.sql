-- CONSULTAS CRITICAS

-- Top proveedores
SELECT * FROM pedido;
DELETE FROM pedido;

INSERT INTO pedido (id, id_party_emisor, id_party_receptor, subtotal) 
VALUES (14, 7, 3, 231.2);

SELECT * FROM estado_pedido;
DELETE FROM estado_pedido;

INSERT INTO estado_pedido (id_pedido, id_tipo_estado_pedido) 
VALUES (14, 3);

SELECT * FROM party;

DESCRIBE ANALYZE SELECT o.nombre Proveedor, SUM(subtotal) "Total compra"
FROM pedido p 
INNER JOIN estado_pedido ep ON (p.id = ep.id_pedido)
INNER JOIN party pa ON (p.id_party_emisor = pa.id)
INNER JOIN organizacion o ON (pa.id = o.id_party)
WHERE id_party_emisor <> 1 GROUP BY id_party_emisor ORDER BY "Total compra";

CREATE INDEX idx_estado_pedido_id_pedido ON estado_pedido (id_pedido);
CREATE INDEX idx_organizacion_id_party ON organizacion (id_party);

-- Top clientes

DESCRIBE ANALYZE SELECT concat(pe.nombres, pe.apellido_paterno, pe.apellido_materno) "Cliente",SUM(subtotal) "Total compra"
FROM pedido p 
INNER JOIN estado_pedido ep ON (p.id = ep.id_pedido)
INNER JOIN party pa ON (p.id_party_emisor = pa.id)
INNER JOIN persona pe ON (pa.id = pe.id_party)
WHERE id_party_receptor <> 1 GROUP BY id_party_receptor ORDER BY "Total compra";


SELECT *
FROM pedido p 
INNER JOIN estado_pedido ep ON (p.id = ep.id_pedido)
WHERE ep.id_tipo_estado_pedido = 3;

SELECT * FROM pedido;
INNER JOIN party pa ON (p.id_party_emisor = pa.id)
INNER JOIN persona pe ON (pa.id = pe.id_party)
WHERE id_party_receptor <> 3 AND 
GROUP BY id_party_receptor ORDER BY "Total compra";

SELECT * FROM estado_pedido;

CREATE INDEX idx_persona_id_party ON persona (id_party);

-- Top productos

describe analyze SELECT pr.nombre "Producto", SUM(cantidad) "Cantidad pedida" FROM pedido p
INNER JOIN detalle_pedido dp ON (p.id = dp.id_pedido)
INNER JOIN producto pr ON (dp.id_producto = p.id)
GROUP BY id_producto;

CREATE idx_detalle_pedido_id_producto ON detalle_pedido (id_producto);








-- Top clientes
