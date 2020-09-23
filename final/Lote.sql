-- PROCESOS EN LOTE

-- 1. Carga mensual de productos

create table producto_carga_table(
	id MEDIUMINT primary KEY AUTO_INCREMENT,
	id_categoria_producto numeric(1) references categoria_producto(id),
	nombre varchar(40),
	comentario varchar(100),
	fecha_ingreso date,
	fecha_salida date,
	imagen_referencial varchar(50)
);

--Llenar la tabla de productos a cargar
DROP PROCEDURE IF EXISTS llenarRegistrosProducto;
DELIMITER $$
CREATE PROCEDURE llenarRegistrosProducto()
BEGIN
	DECLARE i INT DEFAULT 0;
	WHILE i < 50 DO
		INSERT INTO producto_carga_table (id_categoria_producto, nombre, comentario, fecha_ingreso, fecha_salida, imagen_referencial)
		VALUES (MOD(i+1,4), 'Nombre de Prueba', 'Coment', '2019-01-01', NULL, NULL);
		SET i = i + 1;
	END WHILE;
END $$
delimiter ;

CALL llenarRegistrosProducto();

SELECT * FROM producto_carga_table;

DROP PROCEDURE IF EXISTS producto_carga_proc;
DELIMITER $$
CREATE PROCEDURE producto_carga_proc()
BEGIN
	INSERT INTO producto (id_categoria_producto, nombre, comentario, fecha_ingreso, fecha_salida, imagen_referencial) 
	SELECT id_categoria_producto, nombre, comentario, fecha_ingreso, fecha_salida, imagen_referencial 
	FROM producto_carga_table;
	DELETE FROM producto_carga_table;
END $$
delimiter ;

SHOW PROCESSLIST;

SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS producto_carga_event;
DELIMITER $$
CREATE EVENT producto_carga_event
ON SCHEDULE EVERY 60 MINUTE
STARTS CURRENT_TIMESTAMP + INTERVAL 10 SECOND
DO
	CALL producto_carga_proc();
$$
delimiter ;

SELECT COUNT(*) FROM producto_carga_table;
SELECT COUNT(*) FROM producto;

-- 2. Respaldo de la tabla contenedor, item y estado_item

create table item_backup(
	id MEDIUMINT primary key AUTO_INCREMENT,
	id_producto numeric(8) references producto(id),
	id_contenedor numeric(10) references contenedor(id),
	id_almacen numeric(2) references almacen(id),
	numero_serie numeric(11),
    cantidad_mano numeric(4)
);

create table contenedor_backup(
	id MEDIUMINT primary KEY AUTO_INCREMENT,
	id_tipo_contenedor numeric(2) references tipo_contenedor(id),
	id_almacen numeric(3) references almacen(id)
);

create table estado_item_backup(
	id MEDIUMINT primary KEY AUTO_INCREMENT,
    id_item numeric(10) references item(id),
    id_tipo_estado_item numeric(1) references tipo_estado_item(id),
    fecha_inicio timestamp,
    fecha_fin timestamp
);

create table i_a_back(
	id MEDIUMINT primary key
);

INSERT INTO contenedor (id, id_tipo_contenedor, id_almacen) VALUES (12, 1, 1);
SELECT * FROM contenedor;
INSERT INTO item (id, id_producto, id_contenedor, id_almacen) VALUES (17,1,12,2);
SELECT * FROM item;
INSERT INTO estado_item (id_item, id_tipo_estado_item, fecha_inicio) VALUES (17, 7,CURRENT_TIMESTAMP());
SELECT * FROM estado_item;

DROP PROCEDURE IF EXISTS item_backup_proc;
DELIMITER $$
CREATE PROCEDURE item_backup_proc()
BEGIN
	INSERT INTO i_a_back
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
	
	DELETE FROM i_a_back;
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
















-- PRUEBAS







delete item, estado_item 
from item i, estado_item ei, tipo_estado_item tei 
where i.id = ei.id_item and ei.id_tipo_estado_item = tei.id 
and tei.descripcion = 'Vendido';

create table detalle_pedido_respaldo(
	id numeric(10) primary key,
    id_pedido numeric(8),
    id_producto numeric(8),
    cantidad numeric(6)
);

insert into detalle_pedido_respaldo 
select detalle_pedido.* 
from detalle_pedido dp, pedido p, estado_pedido ep, tipo_estado_pedido tep 
where dp.id_pedido = p.id and p.id = ep.id_pedido 
and ep.id_tipo_estado_pedido = tep.id 
and tei.descripcion = 'Entregado';

delete detalle_pedido, estado_detalle_pedido 
from detalle_pedido dp, pedido p, estado_pedido ep, tipo_estado_pedido tep 
where dp.id_pedido = p.id and p.id = ep.id_pedido 
and ep.id_tipo_estado_pedido = tep.id 
and tei.descripcion = 'Entregado';

create table pedido_respaldo(
	id numeric(8) primary key,
    id_party_emisor numeric(8),
    id_party_receptor numeric(8),
    id_party_creador numeric(8),
    id_party_modificador numeric(8),
    fecha_hora_creacion date,
    fecha_hora_modificacion date,
    comision_vendedor numeric(6,2),
    monto_pedido numeric(6,2),
    cobro_logistico numeric(6,2),
    impuestos numeric(6,2),
    subtotal numeric(8,2)
);

insert into pedido_respaldo select pedido.* 
from pedido p, estado_pedido ep, tipo_estado_pedido tep 
where p.id = ep.id_pedido and ep.id_tipo_estado_pedido = tep.id 
and tei.descripcion = 'Entregado';

delete pedido, estado_pedido 
from pedido p, estado_pedido ep, tipo_estado_pedido tep 
where p.id = ep.id_pedido and ep.id_tipo_estado_pedido = tep.id 
and tei.descripcion = 'Entregado';

--Test eventos
SHOW PROCESSLIST;

SET GLOBAL event_scheduler = ON;

CREATE TABLE messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    message VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL
);

SELECT * FROM messages;

DELIMITER $$
CREATE EVENT IF NOT EXISTS test_event_01
ON SCHEDULE AT CURRENT_TIMESTAMP
DO
	INSERT INTO messages(message,created_at)
	VALUES('Test MySQL Event 1',NOW());
//
delimiter ;
  
  CREATE EVENT test_event_02
ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 MINUTE
ON COMPLETION PRESERVE
DO
   INSERT INTO messages(message,created_at)
   VALUES('Test MySQL Event 2',NOW());