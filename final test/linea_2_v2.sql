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

DROP PROCEDURE IF EXISTS insertarPedido;
DELIMITER $$
CREATE PROCEDURE insertarPedido(tipoDocumento varchar(3), numeroDocumento varchar(11), tipoPedido VARCHAR(6))
BEGIN
	DECLARE idTipoDocumento NUMERIC(1) DEFAULT (select id from tipo_documento where descripcion = tipoDocumento);
	DECLARE idParty MEDIUMINT DEFAULT (select id from party where id_tipo_documento = idTipoDocumento and numero_documento = numeroDocumento);
	IF tipoPedido = "Compra" THEN 
		insert into pedido (id_party_emisor, id_party_receptor,fecha_hora_creacion, fecha_hora_modificacion, comision_vendedor, monto_pedido, cobro_logistico, impuestos, subtotal)
		values (idParty, getIdEmpresa(), current_timestamp(), null, null, null, null, null, null);
	ELSEIF tipoPedido = "Venta" THEN 
		insert into pedido (id_party_emisor, id_party_receptor,fecha_hora_creacion, fecha_hora_modificacion, comision_vendedor, monto_pedido, cobro_logistico, impuestos, subtotal)
		values (getIdEmpresa(), idParty, current_timestamp(), null, null, null, null, null, null);
	END IF;
END $$
DELIMITER ;

-- 2. Insertar detalle del pedido
DROP PROCEDURE IF EXISTS insertarDetallePedido;
DELIMITER $$
CREATE PROCEDURE insertarDetallePedido(idPedido MEDIUMINT, nombreProducto VARCHAR(150), cantidadP INT)
BEGIN
	DECLARE idProducto INT DEFAULT (select id from producto where nombre = nombreProducto);
	DECLARE idCategoria INT DEFAULT (SELECT id_categoria_producto FROM producto WHERE nombre = nombreProducto);
	DECLARE precioUnitario NUMERIC(8,2) DEFAULT 0;
	if idCategoria = 5 OR idCategoria = 6 THEN
		SET precioUnitario = (select sum(costo) from componente_costo where id_producto = idProducto and fecha_fin is NULL);
	ELSE
		SET precioUnitario = (select sum(precio) from componente_precio where id_producto = idProducto and fecha_fin is NULL);
	END IF;
	
	IF (select EXISTS (select * from detalle_pedido where id_pedido = idPedido and id_producto = idProducto)) = 1
		THEN update detalle_pedido set cantidad = cantidadP, precio_unitario = precioUnitario where id_pedido = idPedido and id_producto = idProducto;
	ELSE 
		insert into detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) values (idPedido, idProducto, cantidadP, precioUnitario);
		INSERT INTO estado_detalle_pedido (id_detalle_pedido, id_tipo_estado_detalle_pedido, fecha_hora_estado) VALUES 
		((SELECT MAX(id) FROM detalle_pedido), 1, NOW());
	END IF;
	update pedido set monto_pedido = (select sum(precio_unitario * cantidad) 
	from detalle_pedido where id_pedido = idPedido), comision_vendedor = monto_pedido * 0.2, 
	cobro_logistico = monto_pedido * 0.1, impuestos = monto_pedido * 0.18, 
	subtotal = monto_pedido + comision_vendedor + cobro_logistico + impuestos where id = idPedido;
END $$
DELIMITER ;

-- 3. Realizar pedido
DROP PROCEDURE IF EXISTS insertarEstadoPedido;
DELIMITER $$
CREATE PROCEDURE insertarEstadoPedido(idPedido MEDIUMINT, tipoEstadoPedido VARCHAR(12))
BEGIN
	DECLARE idTipoEstadoPedido NUMERIC(1) DEFAULT (select id from tipo_estado_pedido where descripcion = tipoEstadoPedido);
	INSERT INTO estado_pedido (id_pedido, id_tipo_estado_pedido, fecha_hora_estado) VALUES (idPedido, idTipoEstadoPedido, CURRENT_TIMESTAMP());
END $$
DELIMITER ;

-- 4. Fabricar productos
DROP PROCEDURE IF EXISTS fabricar;
DELIMITER $$
CREATE PROCEDURE fabricar(nombreProducto VARCHAR(150), cantidadFabricar INT)
BEGIN
	DECLARE idProducto INT DEFAULT (SELECT id FROM producto WHERE nombre = nombreProducto);
	DECLARE idInsumo INT DEFAULT 0;
	DECLARE idItem INT DEFAULT 0;
	DECLARE idContenedor INT DEFAULT 0;
	DECLARE i INT DEFAULT 0;
	DECLARE j INT DEFAULT 0;
	DECLARE n INT DEFAULT (SELECT COUNT(*) FROM componente_producto WHERE id_producto = idProducto);
	DECLARE m INT DEFAULT 0;
	DECLARE valid BOOLEAN DEFAULT TRUE;
	WHILE i < n DO
		SET idInsumo = (SELECT id_insumo FROM componente_producto WHERE id_producto = idProducto LIMIT i,1);
		SET m = (SELECT cantidad_uso*cantidadFabricar FROM componente_producto WHERE id_producto = idProducto LIMIT i,1);
		IF (SELECT COUNT(*) FROM item i inner join estado_item ei ON (i.id = ei.id_item) where id_producto = idInsumo 
		and id_tipo_estado_item = 1 and not EXISTS (SELECT * FROM estado_item WHERE id_item = i.id AND id_tipo_estado_item = 2)) < (m) THEN
			SET valid = FALSE;
		END IF;
		SET i = i + 1;
	END WHILE;
	SET i = 0;
	SET j = 0;
	IF valid = TRUE THEN
		WHILE i < n DO
			SET idInsumo = (SELECT id_insumo FROM componente_producto WHERE id_producto = idProducto LIMIT i,1);-- Cambiar de enfoque
			SET m = (SELECT cantidad_uso*cantidadFabricar FROM componente_producto WHERE id_producto = idProducto LIMIT i,1);
			WHILE j < m DO
				SET idItem = (SELECT i.id FROM item i inner join estado_item ei ON (i.id = ei.id_item) WHERE id_producto = idInsumo 
				AND id_tipo_estado_item = 1 and not EXISTS (SELECT * FROM estado_item WHERE id_item = i.id AND id_tipo_estado_item = 2) 
				ORDER BY fecha_hora_estado ASC LIMIT 1);
				INSERT INTO estado_item (id_item, id_tipo_estado_item, fecha_hora_estado) VALUES (idItem, 2, CURRENT_TIMESTAMP());-- Insertar estado vendido
				SET j = j + 1;
			END WHILE;
			SET i = i + 1;
			SET j = 0;
		END WHILE;
		SET i = 0;
		DROP TABLE if exists idsContenedor;
		CREATE TEMPORARY TABLE IF NOT EXISTS idsContenedor AS (SELECT id FROM contenedor 
		WHERE id NOT IN (SELECT id_contenedor FROM item WHERE id_contenedor IS NOT NULL GROUP BY id_contenedor) LIMIT cantidadFabricar);
		WHILE i < cantidadFabricar DO
			SET idContenedor = (SELECT id FROM idsContenedor LIMIT i,1);
			INSERT INTO item (id_producto, id_contenedor, id_almacen) VALUES (idProducto, idContenedor, 1);
			INSERT INTO estado_item (id_item, id_tipo_estado_item, fecha_hora_estado) VALUES ((SELECT MAX(id) FROM item), 1, NOW());
			SET i = i + 1;
		END WHILE;										
	END IF;
END $$
DELIMITER ;

-- PROCESOS
-- COMPRA
CALL insertarPedido("RUC", "12475215321", "Compra");
CALL insertarPedido("RUC", "18453254126", "Compra");
CALL insertarPedido("RUC", "14515785321", "Compra");
CALL insertarPedido("RUC", "12475542714", "Compra");
CALL insertarPedido("RUC", "12475215321", "Compra");

CALL insertarDetallePedido(1, "Piedra de rio negra", 27);
CALL insertarDetallePedido(1, "Colgante azul", 6);
CALL insertarDetallePedido(1, "Alambre cromado", 13);

CALL insertarDetallePedido(2, "Piedra sintética azul", 19);
CALL insertarDetallePedido(2, "Hilo de pescar", 3);

CALL insertarDetallePedido(3, "Perla de rio rosada", 21);
CALL insertarDetallePedido(3, "Cordon negro", 5);
CALL insertarDetallePedido(3, "Colgante negro", 6);

CALL insertarDetallePedido(4, "Argolla", 5);
CALL insertarDetallePedido(4, "Mostacilla negra", 5);

CALL insertarDetallePedido(5, "Bolsa como contenedor", 20);

CALL insertarEstadoPedido(1, "Por entregar");
CALL insertarEstadoPedido(1, "Entregado");
CALL insertarEstadoPedido(2, "Por entregar");
CALL insertarEstadoPedido(2, "Entregado");
CALL insertarEstadoPedido(3, "Por entregar");
CALL insertarEstadoPedido(3, "Entregado");
CALL insertarEstadoPedido(4, "Por entregar");
CALL insertarEstadoPedido(4, "Entregado");
CALL insertarEstadoPedido(5, "Por entregar");
CALL insertarEstadoPedido(5, "Entregado");

-- FABRICACION
CALL fabricar("Collar de piedras negras con colgante azul y alambre cromado", 3);
CALL fabricar("Pulsera de piedras azules con hilo de pescar", 2);
CALL fabricar("Arete de perlas rosadas con cordon negro y colgante negro", 4);
CALL fabricar("Anillo de mostacillas negras", 1);

-- VENTA
CALL insertarPedido("DNI", "57482485", "Venta");
CALL insertarPedido("DNI", "75412548", "Venta");
CALL insertarPedido("DNI", "85421573", "Venta");
CALL insertarPedido("DNI", "09475825", "Venta");
CALL insertarPedido("DNI", "57482485", "Venta");

CALL insertarDetallePedido(6, "Collar de piedras negras con colgante azul y alambre cromado",1);
CALL insertarDetallePedido(6, "Arete de perlas rosadas con cordon negro y colgante negro",1);

CALL insertarDetallePedido(7, "Pulsera de piedras azules con hilo de pescar",1);
CALL insertarDetallePedido(7, "Arete de perlas rosadas con cordon negro y colgante negro",1);

CALL insertarDetallePedido(8, "Arete de perlas rosadas con cordon negro y colgante negro",1);

CALL insertarDetallePedido(9, "Anillo de mostacillas negras",1);

CALL insertarDetallePedido(10, "Collar de piedras negras con colgante azul y alambre cromado",1);

CALL insertarEstadoPedido(6, "Por entregar");
CALL insertarEstadoPedido(6, "Entregado");
CALL insertarEstadoPedido(7, "Por entregar");
CALL insertarEstadoPedido(7, "Entregado");
CALL insertarEstadoPedido(8, "Por entregar");
CALL insertarEstadoPedido(8, "Entregado");
CALL insertarEstadoPedido(9, "Por entregar");
CALL insertarEstadoPedido(9, "Entregado");
CALL insertarEstadoPedido(10, "Por entregar");
CALL insertarEstadoPedido(10, "Entregado");

SELECT * FROM pedido;
SELECT * FROM estado_pedido;
SELECT * FROM detalle_pedido;
SELECT * FROM estado_detalle_pedido;
SELECT * FROM contenedor;
SELECT * FROM item;
SELECT * FROM estado_item;
SELECT * FROM producto;

SELECT COUNT(*) FROM pedido UNION SELECT COUNT(*) FROM estado_pedido UNION SELECT COUNT(*) FROM detalle_pedido 
UNION SELECT COUNT(*) FROM contenedor UNION SELECT COUNT(*) FROM item UNION SELECT COUNT(*) FROM estado_item;
