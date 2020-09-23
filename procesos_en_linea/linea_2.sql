-- PROCESO EN LÍNEA

-- Compra de Insumos
-- 1. Insertar Pedido
DROP FUNCTION IF EXISTS getIdEmpresa;
DELIMITER $$
CREATE FUNCTION getIdEmpresa()
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE idEmpresa INT DEFAULT (SELECT id FROM party WHERE id_tipo_documento = 2 AND numero_documento = "15441245752");
	RETURN idEmpresa;
END $$
DELIMITER ;

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
CREATE TRIGGER actualizarPedidoInsert AFTER INSERT, UPDATE ON detalle_pedido
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
	DECLARE tipo_pedido VARCHAR(6) DEFAULT "Compra";
	IF (tipo_pedido = "Compra") THEN
		WHILE i < n DO
			SET cantidadPedida = (SELECT cantidad FROM detalle_pedido LIMIT i,1);
			SET idProducto = (SELECT id_producto FROM detalle_pedido LIMIT i,1);
			SET categoriaProducto = (SELECT id_categoria_producto FROM producto WHERE id = idProducto);
			SET idAlmacen = 1;
			WHILE j < cantidadPedida DO
				IF categoriaProducto = 6 THEN
					INSERT INTO item (id_producto) VALUES (1);
				ELSE
					INSERT INTO item (id_producto) VALUES (1);
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

SELECT COUNT(*) FROM test;
CALL insertarEstadoPedido(1,"En almacen");
CALL insertarEstadoPedido(1,"Despachado");
CALL insertarEstadoPedido(1,"Entregado");
SELECT * FROM estado_pedido;

SELECT COUNT(*) FROM item;

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

call insertarDetallePedido(1, "Pulsera PiAz PiNe AlCrPl", 5);
select * from detalle_pedido;



SELECT * FROM item;
SELECT * FROM estado_item;
SELECT * FROM contenedor;


SELECT id_party_receptor FROM pedido WHERE id = 1;