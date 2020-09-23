-- PROCESO EN LOTE

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