-- PROCESO EN LOTE

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