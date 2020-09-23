-- PROCESOS EN LOTE

-- 1. Carga mensual de productos
DROP TABLE if EXISTS producto_carga;
create table producto_carga LIKE producto;

--Llenar la tabla de productos a cargar
DROP PROCEDURE IF EXISTS producto_carga_insertar;
DELIMITER $$
CREATE PROCEDURE producto_carga_insertar()
BEGIN
	DECLARE i INT DEFAULT 0;
	WHILE i < 50 DO
		INSERT INTO producto_carga (id_categoria_producto, nombre, fecha_ingreso, fecha_salida)
		VALUES (MOD(i,4)+1, 'Nombre de Prueba', '2019-01-01', NULL);
		SET i = i + 1;
	END WHILE;
END $$
delimiter ;

DROP PROCEDURE IF EXISTS producto_insertar;
DELIMITER $$
CREATE PROCEDURE producto_insertar()
BEGIN
	INSERT INTO producto (id_categoria_producto, nombre, fecha_ingreso, fecha_salida) 
	SELECT id_categoria_producto, nombre, fecha_ingreso, fecha_salida 
	FROM producto_carga;
	DELETE FROM producto_carga;
END $$
delimiter ;

DROP PROCEDURE IF EXISTS producto_cargar_proc;
DELIMITER $$
CREATE PROCEDURE producto_cargar_proc()
BEGIN
	CALL producto_carga_insertar();
	CALL producto_insertar();
END $$
delimiter ;
		
SHOW PROCESSLIST;

SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS producto_cargar_event;
DELIMITER $$
CREATE EVENT producto_cargar_event
ON SCHEDULE EVERY 60 MINUTE
STARTS CURRENT_TIMESTAMP + INTERVAL 10 SECOND
DO
	CALL producto_cargar_proc();
$$
delimiter ;

SELECT COUNT(*) FROM producto_carga;
SELECT COUNT(*) FROM producto;

-- 2. Respaldo de la tabla contenedor, item y estado_item

DROP TABLE if EXISTS item_backup;
create table item_backup LIKE item;

DROP TABLE if EXISTS contenedor_backup;
create table contenedor_backup LIKE contenedor;

DROP TABLE if EXISTS estado_item_backup;
create table estado_item_backup LIKE estado_item;

SELECT * FROM item;
SELECT * FROM contenedor;
SELECT * FROM estado_item;

DROP PROCEDURE IF EXISTS item_backup_proc;
DELIMITER $$
CREATE PROCEDURE item_backup_proc()
BEGIN
	CREATE TEMPORARY TABLE i_a_back
	SELECT i.id from item i, estado_item ei, tipo_estado_item tei 
	where i.id = ei.id_item and ei.id_tipo_estado_item = tei.id 
	and tei.descripcion = 'Vendido';
	SELECT * FROM i_a_back;
	
	insert into contenedor_backup 
	select c.* from item i, contenedor c, i_a_back iab
	WHERE i.id_contenedor = c.id AND i.id = iab.id;
	SELECT * FROM contenedor_backup;-- Inserta los contenedores en el backup
	
	DELETE c from item i, contenedor c, i_a_back iab
	WHERE i.id_contenedor = c.id AND i.id = iab.id;
	SELECT * FROM contenedor;-- Eliminar los contenedores del original
	
	insert into item_backup 
	select i.* from item i, i_a_back iab
	where i.id = iab.id;
	SELECT * FROM item_backup;
	
	DELETE i FROM item i, i_a_back iab where i.id = iab.id;
	SELECT * FROM item;
	
	insert into estado_item_backup 
	select ei.* from estado_item ei, i_a_back iab
	where ei.id_item = iab.id;
	SELECT * FROM estado_item_backup;
	
	DELETE ei FROM estado_item ei, i_a_back iab where ei.id_item = iab.id;
	SELECT * FROM estado_item;
	
	DROP TEMPORARY TABLE i_a_back;
END $$
delimiter ;

DROP EVENT IF EXISTS item_backup_event;
DELIMITER $$
CREATE EVENT item_backup_event
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP + INTERVAL 10 SECOND
DO
	CALL item_backup_proc();
$$
delimiter ;

-- 3. Respaldo de la tabla pedido, estado_pedido y detalle_pedido

DROP TABLE if EXISTS pedido;
create table pedido_backup LIKE pedido;

DROP TABLE if EXISTS estado_pedido;
create table estado_pedido_backup LIKE estado_pedido;

DROP TABLE if EXISTS detalle_pedido;
create table detalle_pedido_backup LIKE detalle_pedido;

SELECT * FROM pedido;
SELECT * FROM estado_pedido;
SELECT * FROM detalle_pedido;

DROP PROCEDURE IF EXISTS pedido_backup_proc;
DELIMITER $$
CREATE PROCEDURE pedido_backup_proc()
BEGIN
	CREATE TEMPORARY TABLE p_a_back
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
	
	DROP TEMPORARY TABLE p_a_back;
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
