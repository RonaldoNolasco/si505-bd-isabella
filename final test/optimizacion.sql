-- Consultas críticas
-- Top proveedores
DESCRIBE ANALYZE SELECT o.nombre "Proveedor", SUM(subtotal) "Total compra"
FROM pedido p 
INNER JOIN estado_pedido ep ON (p.id = ep.id_pedido)
INNER JOIN party pa ON (p.id_party_emisor = pa.id)
INNER JOIN organizacion o ON (pa.id = o.id_party)
WHERE id_party_emisor <> getIdEmpresa() AND id_tipo_estado_pedido = 2 
AND fecha_hora_estado BETWEEN DATE(DATE_SUB(NOW(),INTERVAL DAYOFWEEK(NOW())-2 DAY))
AND DATE(DATE_ADD(NOW(),INTERVAL 8-DAYOFWEEK(NOW()) DAY))
GROUP BY id_party_emisor ORDER BY SUM(subtotal) DESC;
-- El intervalo de tiempo es la semana actual

CREATE INDEX idx_estado_pedido_id_pedido USING BTREE ON estado_pedido (id_pedido);
CREATE INDEX idx_estado_pedido_id_pedido USING HASH ON estado_pedido (id_pedido);
DROP INDEX idx_estado_pedido_id_pedido ON estado_pedido;
CREATE INDEX idx_organizacion_id_party USING BTREE ON organizacion (id_party);
CREATE INDEX idx_organizacion_id_party USING HASH ON organizacion (id_party);
DROP INDEX idx_organizacion_id_party ON organizacion;

-- Top clientes
DESCRIBE ANALYZE SELECT concat(pe.nombres, " ", pe.apellido_paterno, " ", pe.apellido_materno) "Cliente",SUM(subtotal) "Total compra"
FROM pedido p 
INNER JOIN estado_pedido ep ON (p.id = ep.id_pedido)
INNER JOIN party pa ON (p.id_party_receptor = pa.id)
INNER JOIN persona pe ON (pa.id = pe.id_party)
WHERE id_party_receptor <> getIdEmpresa() AND id_tipo_estado_pedido = 2 
AND fecha_hora_estado BETWEEN DATE(DATE_SUB(NOW(),INTERVAL DAYOFWEEK(NOW())-2 DAY))
AND DATE(DATE_ADD(NOW(),INTERVAL 8-DAYOFWEEK(NOW()) DAY))
GROUP BY id_party_receptor ORDER BY SUM(subtotal) DESC;

CREATE INDEX idx_persona_id_party USING BTREE ON persona (id_party);
DROP INDEX idx_persona_id_party ON persona;


-- Top productos
DESCRIBE ANALYZE SELECT pr.nombre "Producto", SUM(cantidad) "Cantidad pedida" 
FROM pedido p
INNER JOIN detalle_pedido dp ON (p.id = dp.id_pedido)
INNER JOIN producto pr ON (dp.id_producto = pr.id)
WHERE id_categoria_producto NOT IN (5,6) 
GROUP BY id_producto ORDER BY SUM(cantidad) DESC;

CREATE INDEX idx_test USING BTREE ON detalle_pedido (id_producto);
DROP INDEX idx_test ON detalle_pedido;
CREATE INDEX idx_test2 USING BTREE ON detalle_pedido (id_pedido);

-- Hallar todos los productos y sus componentes
SELECT p.nombre "Producto", i.nombre "Insumo", cp.cantidad_uso "Cantidad" FROM componente_producto cp
INNER JOIN producto p ON (cp.id_producto = p.id)
INNER JOIN producto i ON (cp.id_insumo = i.id);


-- Top proveedores por calificacion y preferencia
SELECT o.nombre, i.nombre, tc.descripcion, tp.descripcion FROM proveedor_producto pp
INNER JOIN organizacion o ON (o.id = pp.id_organizacion)
INNER JOIN producto i ON (i.id = pp.id_insumo)
INNER JOIN tipo_calificacion tc ON (tc.id = pp.id_tipo_calificacion)
INNER JOIN tipo_preferencia tp ON (tp.id = pp.id_tipo_preferencia)
ORDER BY i.nombre DESC, tc.descripcion DESC, tp.descripcion DESC;


