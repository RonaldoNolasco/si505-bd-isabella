-- PROCESO EN LÍNEA

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