DROP TRIGGER IF EXISTS realizarPedido;
DELIMITER $$
CREATE TRIGGER realizarPedido AFTER INSERT ON estado_pedido
FOR EACH ROW
BEGIN
	DECLARE tipoPedido VARCHAR(6) DEFAULT "";
	DECLARE idPedido INT DEFAULT NEW.id_pedido;
	DECLARE idProducto INT DEFAULT 0;
	DECLARE idItem INT DEFAULT 0;
	DECLARE idCategoriaProducto INT DEFAULT 0;
	DECLARE i INT DEFAULT 0;
	DECLARE j INT DEFAULT 0;
	DECLARE n INT DEFAULT (SELECT COUNT(*) FROM detalle_pedido WHERE id_pedido = idPedido);
	DECLARE m INT DEFAULT 0;
	DECLARE valid BOOLEAN DEFAULT TRUE;
	IF NEW.id_tipo_estado_pedido = 2 THEN
		IF (SELECT id_party_receptor FROM pedido WHERE id = idPedido) = getIdEmpresa() THEN 
			SET tipoPedido = "Compra";
		ELSEIF (SELECT id_party_emisor FROM pedido WHERE id = idPedido) = getIdEmpresa() THEN 
			SET tipoPedido = "Venta";
		END IF;-- Bien
		IF tipoPedido = "Compra" THEN 
			WHILE i < n DO
				SET m = (SELECT cantidad FROM detalle_pedido WHERE id_pedido = idPedido LIMIT i,1);
				SET idProducto = (SELECT id_producto FROM detalle_pedido WHERE id_pedido = idPedido LIMIT i,1);
				SET idCategoriaProducto = (SELECT id_categoria_producto FROM producto WHERE id = idProducto);
				WHILE j < m DO
					if idCategoriaProducto = 5 THEN
						INSERT INTO item (id_producto, id_almacen) VALUES (idProducto, 1);
						INSERT INTO estado_item (id_item, id_tipo_estado_item, fecha_hora_estado) VALUES ((SELECT MAX(id) FROM item), 1, NOW());
					ELSEIF idCategoriaProducto = 6 THEN
						if (SELECT nombre FROM producto WHERE id = idProducto) = "Bolsa como contenedor" THEN
							INSERT INTO contenedor (id_tipo_contenedor, id_almacen) VALUES (1, 1);
						ELSE
							INSERT INTO contenedor (id_tipo_contenedor, id_almacen) VALUES (2, 1);
						END IF;
					END IF;
					SET j = j + 1;
				END WHILE;
				SET i = i + 1;
				SET j = 0;
			END WHILE;
		END IF;
		IF tipoPedido = "Venta" THEN 
			WHILE i < n DO
				SET idProducto = (SELECT id_producto FROM detalle_pedido WHERE id_pedido = idPedido LIMIT i,1);
				SET m = (SELECT cantidad FROM detalle_pedido WHERE id_pedido = idPedido LIMIT i,1);
				IF (SELECT COUNT(*) FROM item i inner join estado_item ei ON (i.id = ei.id_item) WHERE id_producto = idProducto
				AND id_tipo_estado_item = 1 and not EXISTS (SELECT * FROM estado_item WHERE id_item = i.id 
				AND id_tipo_estado_item = 2)) < (m) THEN
					SET valid = FALSE;
				END IF;
				SET i = i + 1;
			END WHILE;
			SET i = 0;
			SET j = 0;
			IF valid = TRUE THEN 
				WHILE i < n DO
					SET idProducto = (SELECT id_producto FROM detalle_pedido WHERE id_pedido = idPedido LIMIT i,1);
					SET m = (SELECT cantidad FROM detalle_pedido WHERE id_pedido = idPedido LIMIT i,1);
					WHILE j < m DO
						SET idItem = (SELECT i.id FROM item i inner join estado_item ei ON (i.id = ei.id_item) WHERE id_producto = idProducto 
						AND id_tipo_estado_item = 1 and not EXISTS (SELECT * FROM estado_item WHERE id_item = i.id AND id_tipo_estado_item = 2) 
						ORDER BY fecha_hora_estado ASC LIMIT 1);
						INSERT INTO estado_item (id_item, id_tipo_estado_item, fecha_hora_estado) 
						VALUES (idItem, 2, CURRENT_TIMESTAMP());-- Insertar estado vendido
						SET j = j + 1;
					END WHILE;
					SET i = i + 1;
					SET j = 0;
				END WHILE;
			END IF;
		END IF;
	END IF;
END $$
DELIMITER ;