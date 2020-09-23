-- CONSULTAS CRITICAS

-- Top proveedores
SELECT o.nombre "Proveedor", SUM(subtotal) "Total compra"
FROM pedido p 
INNER JOIN estado_pedido ep ON (p.id = ep.id_pedido)
INNER JOIN party pa ON (p.id_party_emisor = pa.id)
INNER JOIN organizacion o ON (pa.id = o.id_party)
WHERE id_party_emisor <> getIdEmpresa() AND id_tipo_estado_pedido = 2 
AND fecha_hora_estado BETWEEN '2020-09-18 12:00:00' AND '2020-09-23 12:00:00'
GROUP BY id_party_emisor ORDER BY SUM(subtotal) DESC;


CREATE INDEX idx_estado_pedido_id_pedido ON estado_pedido (id_pedido);
CREATE INDEX idx_organizacion_id_party ON organizacion (id_party);

-- Top clientes
SELECT concat(pe.nombres, " ", pe.apellido_paterno, " ", pe.apellido_materno) "Cliente",SUM(subtotal) "Total compra"
FROM pedido p 
INNER JOIN estado_pedido ep ON (p.id = ep.id_pedido)
INNER JOIN party pa ON (p.id_party_receptor = pa.id)
INNER JOIN persona pe ON (pa.id = pe.id_party)
WHERE id_party_receptor <> getIdEmpresa() AND id_tipo_estado_pedido = 2 
AND fecha_hora_estado BETWEEN '2020-09-18 12:00:00' AND '2020-09-23 12:00:00'
GROUP BY id_party_receptor ORDER BY SUM(subtotal) DESC;


CREATE INDEX idx_persona_id_party ON persona (id_party);

-- Top productos

SELECT pr.nombre "Producto", SUM(cantidad) "Cantidad pedida" 
FROM pedido p
INNER JOIN detalle_pedido dp ON (p.id = dp.id_pedido)
INNER JOIN producto pr ON (dp.id_producto = pr.id)
WHERE id_categoria_producto NOT IN (5,6) 
GROUP BY id_producto ORDER BY SUM(cantidad) DESC;

CREATE idx_detalle_pedido_id_producto ON detalle_pedido (id_producto);


