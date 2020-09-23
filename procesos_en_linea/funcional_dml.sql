DROP TABLE if EXISTS contenedor;
create table contenedor(
	id MEDIUMINT primary KEY AUTO_INCREMENT,
	id_tipo_contenedor numeric(2) references tipo_contenedor(id),
	id_almacen numeric(3) references almacen(id)
);

drop table if exists item;
create table item(
	id MEDIUMINT primary key AUTO_INCREMENT,
	id_producto numeric(8) references producto(id),
	id_contenedor numeric(10) references contenedor(id),
	id_almacen numeric(2) references almacen(id),
	numero_serie numeric(11),
    cantidad_mano numeric(4)
);

DROP TABLE IF EXISTS tipo_estado_item;
create table tipo_estado_item(
	id numeric(1) primary key,
    descripcion varchar(10)
);

insert into tipo_estado_item values (1,'Disponible'), (2,'Vendido');

DROP TABLE if EXISTS estado_item;
create table estado_item(
	id MEDIUMINT primary KEY AUTO_INCREMENT,
    id_item numeric(10) references item(id),
    id_tipo_estado_item numeric(1) references tipo_estado_item(id),
    fecha_inicio timestamp,
    fecha_fin timestamp
);

drop table if exists pedido;
create table pedido(
	id MEDIUMINT primary key AUTO_INCREMENT,
    id_party_emisor MEDIUMINT references party(id),
    id_party_receptor MEDIUMINT references party(id),
    /*id_party_creador numeric(8) references party(id),
    id_party_modificador numeric(8) references party(id),*/
    fecha_hora_creacion timestamp,
    fecha_hora_modificacion timestamp,
    monto_pedido numeric(6,2),
    comision_vendedor numeric(6,2),
    cobro_logistico numeric(6,2),
    impuestos numeric(6,2),
    subtotal numeric(8,2)
);

drop table if exists tipo_estado_pedido;
create table tipo_estado_pedido(
	id numeric(1) primary key,
    descripcion VARCHAR(12)
);

insert into tipo_estado_pedido values (1,'Por entregar'), (2,'Entregado');
SELECT * FROM tipo_estado_pedido;

drop table if exists estado_pedido;
create table estado_pedido(
	id MEDIUMINT primary key AUTO_INCREMENT,
    id_pedido MEDIUMINT references pedido(id),
    id_tipo_estado_pedido numeric(1) references tipo_estado_pedido(id),
    fecha_hora_estado timestamp
);

DROP TABLE if EXISTS detalle_pedido;
create table detalle_pedido(
	id INT UNSIGNED primary key AUTO_INCREMENT,
    id_pedido MEDIUMINT references pedido(id),
    id_producto numeric(8) references producto(id),
    cantidad numeric(6) CHECK (cantidad > 0) NOT NULL,
    precio_unitario numeric(8,2) CHECK (precio_unitario > 0) NOT NULL,
    unique (id_pedido, id_producto)
);