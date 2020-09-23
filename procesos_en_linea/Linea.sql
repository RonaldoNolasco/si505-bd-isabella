-- PROCESO EN LÍNEA

-- 1. Realización de evento de comunicación
-- Insertar Party
DROP PROCEDURE IF EXISTS insertarParty;
DELIMITER $$
CREATE PROCEDURE insertarParty(tipoDocumento varchar(3), numeroDocumento varchar(11))
BEGIN
	/*DECLARE id_tipo_documento MEDIUMINT;
	set id_tipo_documento = (select id from tipo_documento where descripcion = tipoDocumento);*/
	DECLARE idTipoDocumento MEDIUMINT DEFAULT (select id from tipo_documento where descripcion = tipoDocumento);
	insert into party (id_tipo_documento, numero_documento) values (idTipoDocumento, numeroDocumento);
	select * from party;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS insertarPersona;
DELIMITER $$
CREATE PROCEDURE insertarPersona(idTipoDocumento numeric(1), numeroDocumento varchar(11), nombres varchar(50), ap varchar(50), am varchar(50), genero varchar(50), fn date)
BEGIN
	DECLARE id_party MEDIUMINT DEFAULT (select id from party where id_tipo_documento = idTipoDocumento and numero_documento = numeroDocumento);
	insert into persona (id_party, nombres, apellido_paterno, apellido_materno, genero, fecha_nacimiento) values (id_party, nombres, ap, am, genero, fn);
	select * from persona;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS insertarOrganizacion;
DELIMITER $$
CREATE PROCEDURE insertarOrganizacion(idTipoDocumento numeric(1), numeroDocumento varchar(11), nombre varchar(80), tipo_sociedad varchar(10), comentario varchar(80))
BEGIN
	DECLARE idParty MEDIUMINT DEFAULT (select id from party where id_tipo_documento = idTipoDocumento and numero_documento = numeroDocumento);
	insert into organizacion (id_party, nombre, tipo_sociedad, comentario) values (idParty, nombre, tipo_sociedad, comentario);
	select * from organizacion;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS insertarPPO;
DELIMITER $$
CREATE PROCEDURE insertarPPO(tipoDocumento varchar(3), numeroDocumento varchar(11), 
	nombres varchar(50), ap varchar(50), am varchar(50), genero varchar(50), fn date,
	nombre varchar(80), tipo_sociedad varchar(10), comentario varchar(80)
	)
BEGIN
	DECLARE idTipoDocumento MEDIUMINT DEFAULT (select id from tipo_documento where descripcion = tipoDocumento);
	call insertarParty(tipoDocumento, numeroDocumento);
	IF tipoDocumento <> "RUC" THEN CALL insertarPersona(idTipoDocumento, numeroDocumento, nombres, ap, am, genero, fn);
	ELSE call insertarOrganizacion(idTipoDocumento, numeroDocumento, nombre, tipo_sociedad, comentario);
	END IF;
END $$
DELIMITER ;

-- 2. Insertar contacto
DROP PROCEDURE IF EXISTS insertarContacto;
DELIMITER $$
CREATE PROCEDURE insertarContacto(tipoContacto varchar(20), valor varchar(50))
BEGIN
	set @id_contacto = (select id from tipo_contacto where descripcion = tipoContacto);
	insert into contacto (id_tipo_contacto, valor) values (@id_contacto, valor);
	select * from contacto;
END $$
DELIMITER ;

-- 3. Insertar Party-Contacto
DROP PROCEDURE IF EXISTS insertarPC;
DELIMITER $$
CREATE PROCEDURE insertarPC(tipoDocumento varchar(3), numeroDocumento numeric(11), tipoContacto varchar(20), valorCont varchar(50), fecha_inicio date, fecha_fin date, descrip varchar(50))
BEGIN
	DECLARE idTipoDocumento NUMERIC(1) DEFAULT (select id from tipo_documento where descripcion = tipoDocumento);
	DECLARE idTipoContacto NUMERIC(2) DEFAULT (select id from tipo_contacto where descripcion = tipoContacto);
	DECLARE idParty MEDIUMINT DEFAULT (select id from party where id_tipo_documento = idTipoDocumento and numero_documento = numeroDocumento);
	DECLARE idContacto MEDIUMINT DEFAULT (select id from contacto where id_tipo_contacto = idTipoContacto and valor = valorCont);
	insert into party_contacto (id_party, id_contacto, fecha_inicio, fecha_fin, descripcion) values (idParty, idContacto, fecha_inicio, fecha_fin, descrip);
	select * from party_contacto;
END $$
DELIMITER ;

-- 4. Insertar Evento de Comunicación
DROP PROCEDURE IF EXISTS insertarEC;
DELIMITER $$
CREATE PROCEDURE insertarEC(tipoDocumento varchar(3), numeroDocumento numeric(11), tipoContacto varchar(20), valorCont varchar(50),
	tipoDocumento_2 varchar(3), numeroDocumento_2 numeric(11), tipoContacto_2 varchar(20), valorCont_2 varchar(50), 
	tipoEventoComunicacion varchar(20), fecha_hora_inicio timestamp, fecha_hora_fin timestamp)
BEGIN
	DECLARE idTipoDocumento NUMERIC(1) DEFAULT (select id from tipo_documento where descripcion = tipoDocumento);
	DECLARE idTipoContacto NUMERIC(2) DEFAULT (select id from tipo_contacto where descripcion = tipoContacto);
	DECLARE idParty MEDIUMINT DEFAULT (select id from party where id_tipo_documento = idTipoDocumento and numero_documento = numeroDocumento);
	DECLARE idContacto MEDIUMINT DEFAULT (select id from contacto where id_tipo_contacto = idTipoContacto and valor = valorCont);
	DECLARE idPartyContacto MEDIUMINT DEFAULT (select id from party_contacto where id_party = idParty and id_contacto = idContacto);
	
	DECLARE idTipoDocumento_2 NUMERIC(1) DEFAULT (select id from tipo_documento where descripcion = tipoDocumento_2);
	DECLARE idTipoContacto_2 NUMERIC(2) DEFAULT (select id from tipo_contacto where descripcion = tipoContacto_2);
	DECLARE idParty_2 MEDIUMINT DEFAULT (select id from party where id_tipo_documento = idTipoDocumento_2 and numero_documento = numeroDocumento_2);
	DECLARE idContacto_2 MEDIUMINT DEFAULT (select id from contacto where id_tipo_contacto = idTipoContacto_2 and valor = valorCont_2);
	DECLARE idPartyContacto_2 MEDIUMINT DEFAULT (select id from party_contacto where id_party = idParty_2 and id_contacto = idContacto_2);
	
	DECLARE idTipoEC NUMERIC(1) DEFAULT (select id from tipo_evento_comunicacion where descripcion = tipoEventoComunicacion);
	
	insert into evento_comunicacion (id_party_contacto_origen, id_party_contacto_destino, id_tipo_evento_comunicacion, fecha_hora_inicio, fecha_hora_fin) 
	values (idPartyContacto, idPartyContacto_2, idTipoEC, fecha_hora_inicio, fecha_hora_fin);
	select * from evento_comunicacion;
END $$
DELIMITER ;

-- Proceso
call insertarPPO ("DNI", "66146602", "Ronaldo","Nolasco","Chavez","M",'2020-12-06',null,null,null);
call insertarPPO ("RUC", "74547609", null,null,null,null,null,"Santa Catalina","SAC","Buen proveedor");
call insertarPPO ("RUC", "41245752", null,null,null,null,null,"Isabella","SAC","Empresa");
select * from party;
select * from persona;
select * from organizacion;

call insertarContacto ("Celular", "920796255");
call insertarContacto ("Fijo", "5687037");
select * from contacto;
select * from tipo_contacto;

call insertarPC ("DNI", "66146602", "Celular" ,"920796255",'2020-01-15',null,"Buen fono");
call insertarPC ("RUC", "74547609", "Fijo" ,"5687037",'2010-01-15',null,"Telefono de casa");
select * from party_contacto;

call insertarEC ("DNI", "66146602", "Celular" ,"920796255", "RUC", "74547609", "Fijo" ,"5687037", "Coordinación", '2020-09-09 18:30:12', '2020-09-09 18:35:17');
select * from evento_comunicacion;

-- Compra de Insumos
-- 1. Insertar Pedido
DROP PROCEDURE IF EXISTS insertarCompra;
DELIMITER $$
CREATE PROCEDURE insertarCompra(tipoDocumentoE varchar(3), numeroDocumentoE varchar(11))
BEGIN
	DECLARE idTipoDocumentoE NUMERIC(1) DEFAULT (select id from tipo_documento where descripcion = tipoDocumentoE);
	DECLARE idPartyE MEDIUMINT DEFAULT (select id from party where id_tipo_documento = idTipoDocumentoE and numero_documento = numeroDocumentoE);

	DECLARE idTipoDocumentoR NUMERIC(1) DEFAULT (select id from tipo_documento where descripcion = "RUC");	
	DECLARE idPartyR MEDIUMINT DEFAULT (select id from party where id_tipo_documento = idTipoDocumentoR and numero_documento = "41245752");
	
	insert into pedido (id_party_emisor, id_party_receptor,fecha_hora_creacion, fecha_hora_modificacion, comision_vendedor, monto_pedido, cobro_logistico, impuestos, subtotal)
	values (idPartyE, idPartyR, current_timestamp(), null, null, null, null, null, null);
	select * from pedido;
END $$
DELIMITER ;

-- 2. Insertar detalle de la compra
DROP PROCEDURE IF EXISTS insertarDetallePedido;
DELIMITER $$
CREATE PROCEDURE insertarDetallePedido(idPedido MEDIUMINT, nombreProducto varchar(40), cantidadP INT)
BEGIN
	DECLARE idProducto NUMERIC(8) DEFAULT (select id from producto where nombre = nombreProducto);
	DECLARE precioUnitario NUMERIC(8,2) DEFAULT (select sum(costo) from componente_costo where id_producto = idProducto and fecha_fin is null);-- Falta agregar las fechas
	IF (select EXISTS (select * from detalle_pedido where id_pedido = idPedido and id_producto = idProducto)) = 1
		THEN update detalle_pedido set cantidad = cantidadP, precio_unitario = precioUnitario where id_pedido = idPedido and id_producto = idProducto;
	ELSE insert into detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) values (idPedido, idProducto, cantidadP, precioUnitario);
	END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS actualizarPedidoInsert;
DELIMITER $$
CREATE TRIGGER actualizarPedidoInsert AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
	DECLARE idPedido INT DEFAULT NEW.id_pedido;
	update pedido set monto_pedido = (select sum(precio_unitario * cantidad) 
	from detalle_pedido where id_pedido = idPedido), comision_vendedor = monto_pedido * 0.2, 
	cobro_logistico = monto_pedido * 0.1, impuestos = monto_pedido * 0.18, 
	subtotal = monto_pedido + comision_vendedor + cobro_logistico + impuestos where id = idPedido;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS actualizarPedidoUpdate;
DELIMITER $$
CREATE TRIGGER actualizarPedidoUpdate AFTER UPDATE ON detalle_pedido
FOR EACH ROW
BEGIN
	DECLARE idPedido INT DEFAULT NEW.id_pedido;
	update pedido set monto_pedido = (select sum(precio_unitario * cantidad) 
	from detalle_pedido where id_pedido = idPedido), comision_vendedor = monto_pedido * 0.2, 
	cobro_logistico = monto_pedido * 0.1, impuestos = monto_pedido * 0.18, 
	subtotal = monto_pedido + comision_vendedor + cobro_logistico + impuestos where id = idPedido;
END $$
DELIMITER ;

--3. Insertar estado de la compra
DROP PROCEDURE IF EXISTS insertarEstadoPedido;
DELIMITER $$
CREATE PROCEDURE insertarEstadoPedido(idPedido MEDIUMINT, tipoEstadoPedido VARCHAR(10))
BEGIN
	DECLARE idTipoEstadoPedido NUMERIC(1) DEFAULT (select id from tipo_estado_pedido where descripcion = tipoEstadoPedido);
	INSERT INTO estado_pedido (id_pedido, id_tipo_estado_pedido) VALUES (idPedido , idTipoEstadoPedido);
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS compraItems;
DELIMITER $$
CREATE TRIGGER compraItems BEFORE INSERT ON estado_pedido
FOR EACH ROW
BEGIN
	DECLARE idPedido INT DEFAULT NEW.id_pedido;
	DECLARE n INT DEFAULT (SELECT COUNT(*) FROM detalle_pedido WHERE id_pedido = idPedido);
	DECLARE i INT DEFAULT 0;
	DECLARE j INT DEFAULT 0;
	DECLARE cantidadPedida NUMERIC(8) DEFAULT 0;
	DECLARE idProducto NUMERIC(8) DEFAULT 0;
	DECLARE categoriaProducto NUMERIC(1) DEFAULT 0;
	DECLARE idTipoContenedor NUMERIC(1) DEFAULT 0;
	DECLARE idAlmacen NUMERIC(1) DEFAULT 1;
		DECLARE tipo_pedido VARCHAR(6) DEFAULT "";
	IF ((SELECT id_party_emisor FROM pedido WHERE id = idPedido) = 3) THEN
		SET tipo_pedido = "Venta";
	ELSEIF ((SELECT id_party_receptor FROM pedido WHERE id = idPedido) = 3) THEN
		SET tipo_pedido = "Compra";
	END IF;
	IF (NEW.id_tipo_estado_pedido = 3 AND tipo_pedido = "Compra") THEN
		WHILE i < n DO
			SET cantidadPedida = (SELECT cantidad FROM detalle_pedido LIMIT i,1);
			SET idProducto = (SELECT id_producto FROM detalle_pedido LIMIT i,1);
			SET categoriaProducto = (SELECT id_categoria_producto FROM producto WHERE id = idProducto);
			SET idAlmacen = 1;
			WHILE j < cantidadPedida DO
				IF categoriaProducto = 6 THEN
					SET idTipoContenedor = IF((SELECT nombre FROM producto WHERE id = idProducto) = 'Bolsa', 1, 2);
					INSERT INTO contenedor (id_tipo_contenedor, id_almacen) VALUES (idTipoContenedor, idAlmacen);
				ELSE
					INSERT INTO item (id_producto, id_almacen) VALUES (idProducto, idAlmacen);
				END IF;
				SET j = j + 1;
			END WHILE;
			SET i = i + 1;
			SET j = 0;
		END WHILE;
	END IF;
END $$
DELIMITER ;
-- Ver que contenedor y almacen ponerle

DROP TRIGGER IF EXISTS insertarEstadoItem;
DELIMITER $$
CREATE TRIGGER insertarEstadoItem AFTER INSERT ON item
FOR EACH ROW
BEGIN
	INSERT INTO estado_item (id_item, id_tipo_estado_item, fecha_inicio, fecha_fin ) VALUES (NEW.id, 1, CURRENT_TIMESTAMP(), NULL);
END $$
DELIMITER ;

SELECT * FROM estado_pedido;
DELETE FROM estado_pedido WHERE id = 29;
SELECT COUNT(DISTINCT item.id) as item, COUNT(DISTINCT contenedor.id) as contenedor FROM item, contenedor;
INSERT INTO estado_pedido (id_pedido, id_tipo_estado_pedido) VALUES (1, 3);

select sum(costo) from componente_costo where id_producto = 2 and fecha_fin is null;

--PROCESO
call insertarCompra ("RUC", "74547609");
SELECT * FROM pedido;

call insertarDetallePedido(18, "Pulsera PiAz PiNe AlCrPl", 5);
select * from detalle_pedido;

CALL insertarEstadoPedido(18,"En almacen");
CALL insertarEstadoPedido(18,"Despachado");
CALL insertarEstadoPedido(18,"Entregado");
SELECT * FROM estado_pedido;

SELECT * FROM item;
SELECT * FROM estado_item;
SELECT * FROM contenedor;

-- Venta de Productos
-- 1. Insertar Venta
DROP PROCEDURE IF EXISTS insertarVenta;
DELIMITER $$
CREATE PROCEDURE insertarVenta(tipoDocumentoR varchar(3), numeroDocumentoR varchar(11))
BEGIN
	DECLARE idTipoDocumentoE NUMERIC(1) DEFAULT (select id from tipo_documento where descripcion = "RUC");	
	DECLARE idPartyE MEDIUMINT DEFAULT (select id from party where id_tipo_documento = idTipoDocumentoE and numero_documento = "41245752");
	DECLARE idTipoDocumentoR NUMERIC(1) DEFAULT (select id from tipo_documento where descripcion = tipoDocumentoR);
	DECLARE idPartyR MEDIUMINT DEFAULT (select id from party where id_tipo_documento = idTipoDocumentoR and numero_documento = numeroDocumentoR);

	insert into pedido (id_party_emisor, id_party_receptor,fecha_hora_creacion, fecha_hora_modificacion, comision_vendedor, monto_pedido, cobro_logistico, impuestos, subtotal)
	values (idPartyE, idPartyR, current_timestamp(), null, null, null, null, null, null);
	select * from pedido;
END $$
DELIMITER ;

SELECT * FROM pedido;
SELECT * FROM detalle_pedido;
SELECT * FROM estado_pedido;

DROP TRIGGER IF EXISTS ventaItems;
DELIMITER $$
CREATE TRIGGER ventaItems BEFORE INSERT ON estado_pedido
FOR EACH ROW
BEGIN
	DECLARE idPedido INT DEFAULT (NEW.id_pedido);
	DECLARE i INT DEFAULT 0;
	DECLARE j INT DEFAULT 0;
	DECLARE n INT DEFAULT (SELECT COUNT(*) FROM detalle_pedido WHERE id_pedido = idPedido);
	DECLARE valid BOOLEAN DEFAULT TRUE;
	DECLARE prod_temp INT DEFAULT 0;
	DECLARE cant_temp INT DEFAULT 0;
	DECLARE item_temp INT DEFAULT 0;
	DECLARE tipo_pedido VARCHAR(6) DEFAULT "";
	IF (SELECT id_party_emisor FROM pedido WHERE id = idPedido) = 3 THEN
		SET tipo_pedido = "Venta";
	ELSEIF (SELECT id_party_receptor FROM pedido WHERE id = idPedido) = 3 THEN
		SET tipo_pedido = "Compra";
	END IF;
	WHILE i < n DO
		SET prod_temp = (SELECT id_producto FROM (SELECT * FROM detalle_pedido WHERE id_pedido = idPedido) AS T LIMIT i,1);
		IF (SELECT COUNT(*) FROM item WHERE id_producto = prod_temp GROUP BY id_producto) 
		< (SELECT cantidad FROM (SELECT * FROM detalle_pedido WHERE id_pedido = idPedido) AS S WHERE id_producto = prod_temp) 		
		THEN SET valid = FALSE;
		END IF;
		SET i = i + 1;
	END WHILE;
	SET i = 0;
	IF (valid = TRUE AND NEW.id_tipo_estado_pedido = 3 AND tipo_pedido = "Venta") THEN 
		WHILE i < n DO
			SET prod_temp = (SELECT id_producto FROM (SELECT * FROM detalle_pedido WHERE id_pedido = idPedido) AS T LIMIT i,1);
			SET cant_temp = (SELECT cantidad FROM (SELECT * FROM detalle_pedido WHERE id_pedido = idPedido) AS T LIMIT i,1);
			WHILE j < cant_temp DO
				SET item_temp = (SELECT i.id FROM item i inner join estado_item ei ON (i.id = ei.id_item) 
				WHERE id_producto = prod_temp AND id_tipo_estado_item <> 7 
				ORDER BY fecha_inicio ASC LIMIT j,1);
				INSERT INTO estado_item (id_item, id_tipo_estado_item, fecha_inicio) VALUES (item_temp, 7, CURRENT_TIMESTAMP());
				UPDATE estado_item SET fecha_fin = CURRENT_TIMESTAMP() WHERE id_item = item_temp AND id_tipo_estado_item <> 7;
				SET j = j + 1;
			END WHILE;
			SET i = i + 1;
			SET j = 0;
		END WHILE;
	END IF;
END $$
delimiter ;

-- PROCESO

CALL insertarVenta("DNI", "66146602");
SELECT * FROM party;

call insertarDetallePedido(19, "Pulsera PiAz PiNe AlCrPl", 3);
SELECT * FROM detalle_pedido;

CALL insertarEstadoPedido(19,"En almacen");
CALL insertarEstadoPedido(19,"Despachado");
CALL insertarEstadoPedido(19,"Entregado");

DELETE FROM item;
DELETE FROM estado_item;

SELECT * FROM item;
SELECT * FROM estado_item;
SELECT * FROM tipo_estado_item;
SELECT * FROM estado_pedido;

INSERT INTO estado_pedido (id_pedido, id_tipo_estado_pedido, fecha_hora_inicio) VALUES (17, 3, CURRENT_TIMESTAMP());
SELECT * FROM estado_item;
DELETE FROM estado_pedido WHERE id = 35;


SELECT * FROM item where;

SELECT * FROM detalle_pedido;
SELECT * FROM item i INNER JOIN estado_item ei ON (i.id = ei.id_item) WHERE id_producto = 1 AND id_tipo_estado_item <> 7;

CALL insertarDetalleCompra(17, "Pulsera PiAz PiNe AlCrPl", 5);

SELECT * FROM test;

sele

INSERT INTO estado_pedido (id_pedido, id_tipo_estado_pedido) VALUES (22,1);
SELECT * FROM estado_pedido;



INSERT INTO pedido (id_party_emisor, id_party_receptor) VALUES (3, 1);
SELECT * FROM pedido;
SET @id_pedido = 15;

--INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad) VALUES (15, 2, 3);
SELECT * FROM detalle_pedido;


SELECT * FROM estado_pedido;

SELECT * FROM pedido;

-- PROCESO


SELECT * FROM item;

SELECT * FROM estado_item;
SELECT * FROM estado_pedido;

DELETE FROM estado_pedido WHERE id = 44;
DELETE FROM estado_item WHERE id > 60;
DELETE FROM item;
DELETE FROM contenedor;


SELECT * FROM item;
SELECT * FROM contenedor;
DELETE FROM contenedor;

select * from componente_costo;

drop table pedido;
drop table detalle_pedido;

-- Cuando el estado del pedido pasa a entregado, se tienen que agregar los items a la tabla
-- Un pedido siempre está solo una vez en cada estado pedido, primero en almacen, luego en despachado, luego en entregado
SELECT * FROM 
SELECT * FROM tipo_estado_pedido;



SET @valid = TRUE;
SET @i = 0;
SET @n = (SELECT COUNT(*) FROM detalle_pedido WHERE id_pedido = @id_pedido);
SELECT * FROM detalle_pedido;
UPDATE detalle_pedido SET cantidad = 5 WHERE id = 5;
SET @id_pedidox = 15;

--USAR QUERIES ANIDADOS
DROP PROCEDURE if EXISTS test;
DELIMITER $$
CREATE PROCEDURE test()
BEGIN
	DECLARE idPedido INT DEFAULT 15;
	DECLARE i INT DEFAULT 0;
	DECLARE n INT DEFAULT (SELECT COUNT(*) FROM detalle_pedido WHERE id_pedido = idPedido);
	DECLARE valid BOOLEAN DEFAULT TRUE;
	DECLARE prod_temp INT DEFAULT 0;
	WHILE i<n DO
		SET prod_temp = (SELECT id_producto FROM (SELECT * FROM detalle_pedido WHERE id_pedido = idPedido) AS T LIMIT i,1);
		IF (SELECT COUNT(*) FROM item WHERE id_producto = prod_temp GROUP BY id_producto) 
		< (SELECT cantidad FROM (SELECT * FROM detalle_pedido WHERE id_pedido = idPedido) AS S WHERE id_producto = prod_temp) 		
		THEN SET valid = FALSE;
		END IF;
		SET i = i + 1;
	END WHILE;
	SELECT valid;
END $$
delimiter ;

