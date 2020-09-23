-- PROCESO EN LOTE

-- 3. Respaldo de la tabla pedido, estado_pedido y detalle_pedido
create table pedido_backup(
	id MEDIUMINT primary key AUTO_INCREMENT,
    id_party_emisor MEDIUMINT references party(id),
    id_party_receptor MEDIUMINT references party(id),
    fecha_hora_creacion timestamp,
    fecha_hora_modificacion timestamp,
    monto_pedido numeric(6,2),
    comision_vendedor numeric(6,2),
    cobro_logistico numeric(6,2),
    impuestos numeric(6,2),
    subtotal numeric(8,2)
);

create table estado_pedido_backup(
	id MEDIUMINT primary key AUTO_INCREMENT,
    id_pedido MEDIUMINT references pedido(id),
    id_tipo_estado_pedido numeric(1) references tipo_estado_pedido(id),
    fecha_hora_inicio timestamp,
    fecha_hora_fin TIMESTAMP,
    UNIQUE(id_tipo_estado_pedido,id_pedido)
);

create table detalle_pedido_backup(
	id MEDIUMINT primary key AUTO_INCREMENT,
    id_pedido MEDIUMINT references pedido(id),
    id_producto numeric(8) references producto(id),
    cantidad numeric(6),
    precio_unitario numeric(8,2),
    unique (id_pedido, id_producto)
);

create table p_a_back(
	id MEDIUMINT primary key
);

SELECT * FROM pedido;
INSERT INTO pedido (id, id_party_emisor, id_party_receptor) VALUES (3, 1, 2);
SELECT * FROM estado_pedido;
INSERT INTO estado_pedido (id_pedido, id_tipo_estado_pedido) VALUES (3, 3);
SELECT * FROM estado_pedido;
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES (3, 1, 5, 5.60);
SELECT * FROM detalle_pedido;

DROP PROCEDURE IF EXISTS pedido_backup_proc;
DELIMITER $$
CREATE PROCEDURE pedido_backup_proc()
BEGIN
	INSERT INTO p_a_back
	SELECT p.id from pedido p, estado_pedido ep, tipo_estado_pedido tep 
	where p.id = ep.id_pedido and ep.id_tipo_estado_pedido = tep.id 
	and tep.descripcion = 'Entregado';
	SELECT * FROM p_a_back;
	
	insert into pedido_backup
	select p.* from pedido p, p_a_back pab
	WHERE p.id = pab.id;
	SELECT * FROM pedido_backup;-- Inserta los pedidos en el backup
	
	delete p from pedido p, p_a_back pab WHERE p.id = pab.id;
	SELECT * FROM pedido; -- Eliminar los pedidos del original
	
	insert into estado_pedido_backup 
	select ep.* from estado_pedido ep, p_a_back pab
	where ep.id_pedido = pab.id;
	SELECT * FROM estado_pedido_backup;
	
	DELETE ep from estado_pedido ep, p_a_back pab where ep.id_pedido = pab.id;
	SELECT * FROM estado_pedido;
	
	insert into detalle_pedido_backup 
	select dp.* from detalle_pedido dp, p_a_back pab
	where dp.id_pedido = pab.id;
	SELECT * FROM detalle_pedido_backup;
	
	DELETE dp from detalle_pedido dp, p_a_back pab where dp.id_pedido = pab.id;
	SELECT * FROM detalle_pedido;
	
	DELETE FROM p_a_back;
END $$
delimiter ;

DROP EVENT IF EXISTS pedido_backup_event;
DELIMITER $$
CREATE EVENT pedido_backup_event
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP + INTERVAL 10 SECOND
DO
	CALL pedido_backup_proc();
$$
delimiter ;