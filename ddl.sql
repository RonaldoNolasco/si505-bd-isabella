--Creacion de tablas
create database isabella;

use isabella;

create table categoria_producto(
	id numeric(1,0) primary key,
	descripcion VARCHAR(10) check (descripcion in ('Collar','Pulsera','Arete','Anillo','Insumo','Contenedor'))
);

insert into categoria_producto values (1,'Collar'), (2,'Pulsera'), (3,'Arete'), (4,'Anillo'), (5,'Insumo'), (6,'Contenedor');

select * from categoria_producto;

DROP TABLE IF EXISTS producto;
CREATE TABLE producto(
	id MEDIUMINT PRIMARY KEY AUTO_INCREMENT,
	id_categoria_producto numeric(1) references categoria_producto(id),
	nombre VARCHAR(150),
	fecha_ingreso date,
	fecha_salida date
);

insert into producto (id_categoria_producto, nombre, fecha_ingreso, fecha_salida)
VALUES (1, 'Collar de piedras negras con colgante azul y alambre cromado', '2019-10-30',NULL),
(2,'Pulsera de piedras azules con alambre cromado plomo','2020-01-01',NULL),
(3,'Arete de perlas rosadas','2020-12-01',NULL),
(4,'Anillo de mostacillas negras','2020-12-01',NULL),
(5,'Piedra de rio negra','2019-01-01',NULL),
(5,'Colgante azul','2019-01-01',NULL),
(5,'Perla de rio','2019-01-01',NULL),
(5,'Coral','2019-01-01',NULL),
(5,'Alambre cromado','2019-01-01',NULL),
(6,'Bolsa como contenedor','2020-01-01',NULL),
(6,'Caja como contenedor','2020-01-01',NULL);
select * from producto;

DROP TABLE IF EXISTS componente_producto;
create table componente_producto(
	id MEDIUMINT primary KEY AUTO_INCREMENT,
	id_producto numeric(8) references producto(id),
	id_insumo numeric(8) references producto(id),
	cantidad_uso numeric(6)/*,
	comentario varchar(60)*/
);
INSERT INTO componente_producto (id_producto, id_insumo, cantidad_uso) VALUES (1,5,6), (1,6,1), (1,9,2);
select * from componente_producto;

create table tipo_caracteristica_producto(
	id numeric(6) primary key,
	descripcion varchar(50)
);

insert into tipo_caracteristica_producto values (1,'Color'), (2,'Tamaño'), (3,'Peso'), (4,'Alto'), (5,'Ancho'), (6,'Largo');

select * from tipo_caracteristica_producto;

create table unidad_medida(
	id numeric(4) primary key,
    abreviacion varchar(4),
    descripcion varchar(20)
);

insert into unidad_medida values (1,'m','metro');
insert into unidad_medida values (2,'dm','decimetro');
insert into unidad_medida values (3,'cm','centimetro');
insert into unidad_medida values (4,'mm','milimetro');
insert into unidad_medida values (5,'g','gramo');
insert into unidad_medida values (6,'mg','miligramo');

select * from unidad_medida;

create table conversion_unidad_medida(
	id numeric(6) primary key,
    id_unidad_medida_origen numeric(4) references unidad_medida(id),
    id_unidad_medida_destino numeric(4) references unidad_medida(id),
    factor_conversion numeric(8,4)
);

insert into conversion_unidad_medida values (1,1,3,0.01);
insert into conversion_unidad_medida values (2,2,1,10);
insert into conversion_unidad_medida values (3,6,5,1000);

select * from conversion_unidad_medida;

create table caracteristica_producto(
	id numeric(6) primary key,
	id_tipo_caracteristica_producto numeric(6) references tipo_caracteristica_producto(id),
    id_unidad_medida numeric(4) references unidad_medida(id),
	descripcion varchar(50)
);

insert into caracteristica_producto values (1,1,null,'Azul');
insert into caracteristica_producto values (2,3,5,'50');
insert into caracteristica_producto values (3,5,3,'10');

select * from caracteristica_producto;

create table tipo_aplicabilidad_caracteristica_producto(
	id numeric(1) primary key,
    descripcion varchar(9)
);

insert into tipo_aplicabilidad_caracteristica_producto values (1,'Requerida');
insert into tipo_aplicabilidad_caracteristica_producto values (2,'Estándar');
insert into tipo_aplicabilidad_caracteristica_producto values (3,'Opcional');
insert into tipo_aplicabilidad_caracteristica_producto values (4,'Elegible');

select * from tipo_aplicabilidad_caracteristica_producto;

create table aplicabilidad_caracteristica_producto(
	id numeric(8) primary key,
    id_producto numeric(8) references producto(id),
    id_caracteristica_producto numeric(6) references caracteristica_producto(id),
    id_tipo_aplicabilidad_caracteristica_producto numeric(1) references tipo_aplicabilidad_caracteristica_producto(id),
    fecha_inicio date,
    fecha_fin date
);

create table tipo_componente_costo(
	id numeric(1) primary key,
    descripcion varchar(10)
);

insert into tipo_componente_costo values (1,'Base'), (2,'Transporte');

select * from tipo_componente_costo;

DROP TABLE if EXISTS componente_costo;
create table componente_costo(
	id MEDIUMINT PRIMARY KEY AUTO_INCREMENT,
    id_producto numeric(8) references producto(id),
    id_tipo_componente_costo numeric(1) references tipo_componente_costo(id),
    fecha_inicio date,
    fecha_fin date,
    costo numeric(8,2)
);
/*insert into componente_costo (id_producto, id_tipo_componente_costo, fecha_inicio, fecha_fin, costo)
VALUES (6,1,'2020-01-01',NULL,2.57), (6,2,'2020-01-01',NULL,1.11), (7,1,'2020-01-01',NULL,5.1),
(7,2,'2020-01-01',NULL,0.45), (8,1,'2020-01-01',NULL,6.45), (8,2,'2020-01-01',NULL,0.75);*/
insert into componente_costo (id_producto, id_tipo_componente_costo, fecha_inicio, fecha_fin, costo)
VALUES (5,1,'2020-01-01',NULL,1), (6,1,'2020-01-01',NULL,1), (9,1,'2020-01-01',NULL,1), (10,1,'2020-01-01',NULL,1);

SELECT * FROM componente_costo;
SELECT * FROM producto;

create table tipo_componente_precio(
	id numeric(1) primary key,
    descripcion varchar(10)
);

insert into tipo_componente_precio values (1,'Base'), (2,'Descuento');

select * from tipo_componente_precio;

DROP TABLE if EXISTS componente_precio;
create table componente_precio(
	id MEDIUMINT primary KEY AUTO_INCREMENT,
    id_producto numeric(8) references producto(id),
    id_tipo_componente_precio numeric(1) references tipo_componente_precio(id),
    fecha_inicio date,
    fecha_fin date,
    precio numeric(8,2)
);
insert into componente_precio (id_producto, id_tipo_componente_precio, fecha_inicio, fecha_fin, precio)
VALUES (1,1,'2020-01-01',NULL,10);

create table tipo_documento(
	id numeric(1) primary key,
	descripcion varchar(3)
);

insert into tipo_documento values (1,'DNI'), (2,'RUC'), (3,'CdE');

select * from tipo_documento;

drop table if exists party;
create table party(
	id MEDIUMINT primary key AUTO_INCREMENT,
	id_tipo_documento numeric(1) references tipo_documento(id),
	numero_documento numeric(11),
	unique(id_tipo_documento,numero_documento)
);

DROP TABLE if EXISTS persona;
create table persona(
	id MEDIUMINT primary key AUTO_INCREMENT,
	id_party MEDIUMINT unique references party(id),
	nombres varchar(80),
	apellido_paterno varchar(80),
	apellido_materno varchar(80),
	genero varchar(1) check(genero in ('M','F')),
	fecha_nacimiento date
);

DROP TABLE if EXISTS organizacion;
create table organizacion(
	id MEDIUMINT primary key AUTO_INCREMENT,
	id_party numeric(8) unique references party(id),
	nombre varchar(80),
	tipo_sociedad varchar(10),
	comentario varchar(80)
);

create table tipo_rol(
	id numeric(3) primary key,
	descripcion varchar(20)
);

insert into tipo_rol values (1,'Proveedor');
insert into tipo_rol values (2,'Empleado');
insert into tipo_rol values (3,'Cliente');

select * from tipo_rol;

create table rol(
	id numeric(8) primary key,
	id_party numeric(8) references party(id),
	id_tipo_rol numeric(3) references tipo_rol(id),
	fecha_inicio date,
	fecha_fin date
);

create table tipo_calificacion(
	id numeric(4) primary key,
	descripcion varchar(20)
);

insert into tipo_calificacion values (1,'Sobresaliente');
insert into tipo_calificacion values (2,'Bueno');
insert into tipo_calificacion values (3,'Regular');
insert into tipo_calificacion values (4,'Malo');

select * from tipo_calificacion;

create table tipo_preferencia(
	id numeric(4) primary key,
	descripcion varchar(20)
);

insert into tipo_preferencia values (1,'Primero');
insert into tipo_preferencia values (2,'Segundo');
insert into tipo_preferencia values (3,'Tercero');

select * from tipo_preferencia;

create table proveedor_producto(
	id numeric(8) primary key,
	id_organizacion numeric(6) references organizacion(id),
	id_producto numeric(8) references producto(id),
	id_tipo_calificacion numeric(4) references tipo_calificacion(id),
	id_tipo_preferencia numeric(4) references tipo_preferencia(id),
	fecha_inicio date,
	fecha_fin date,
	tiempo_entrega_estandar time,
	comentario varchar(80)
);

create table almacen(
	id numeric(2) primary key,
	descripcion varchar(10)
);

insert into almacen values (1,'Cuarto');
insert into almacen values (2,'Tragaluz');
insert into almacen values (3,'Escalera');

select * from almacen;

create table tipo_contenedor(
	id numeric(2) primary key,
	descripcion varchar(10)
);

insert into tipo_contenedor values (1,'Bolsa'), (2,'Caja');

select * from tipo_contenedor;

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

create table tipo_rol_almacen(
	id numeric(1) primary key,
    descripcion varchar(8)
);

insert into tipo_rol_almacen values (1,'Entrada');
insert into tipo_rol_almacen values (2,'Salida');

select * from tipo_rol_almacen;

create table rol_almacen(
	id numeric(4) primary key,
    id_persona numeric(6) references persona(id),
    id_almacen numeric(2) references almacen(id),
    id_tipo_rol_almacen numeric(1) references tipo_rol_almacen(id),
    fecha_inicio date,
	fecha_fin date
);

create table diseño(
	id numeric(8) primary key,
    id_producto numeric(8) references producto(id),
    numero_paso numeric(3),
    descripcion varchar(80)
);

create table fabricacion(
	id numeric(10) primary key,
    id_diseño numeric(8) references diseño(id),
    id_insumo numeric(8) references producto(id),
    cantidad_uso numeric(3)
);

create table tipo_contacto(
	id numeric(2) primary key,
    descripcion varchar(20)
);

insert into tipo_contacto values (1,'Celular'), (2,'Fijo'), (3,'Correo') ,(4,'Telegram');

create table contacto(
	id MEDIUMINT primary key AUTO_INCREMENT,
    id_tipo_contacto numeric(2) references tipo_contacto(id),
    valor varchar(50),
	unique(id_tipo_contacto, valor)
);

drop table contacto;

create table party_contacto(
	id MEDIUMINT primary key AUTO_INCREMENT,
    id_party MEDIUMINT not null references party(id),
    id_contacto MEDIUMINT not null references contacto(id),
    fecha_inicio date,
    fecha_fin date,
    descripcion varchar(50)
);

drop table party_contacto;

create table tipo_proposito_contacto(
	id numeric(1) primary key,
    descripcion varchar(20)
);

insert into tipo_proposito_contacto values (1,'Personal'), (2,'Trabajo');

select * from tipo_proposito_contacto;

create table party_contacto_proposito(
	id numeric(8) primary key,
    id_party_contacto numeric(8) references party_contacto(id),
    id_tipo_proposito_contacto numeric(1) references tipo_proposito_contacto(id),
    fecha_inicio date,
    fecha_fin date
);

create table tipo_evento_comunicacion(
	id numeric(1) primary key,
    descripcion varchar(20)
);

insert into tipo_evento_comunicacion values (1,'Compra'), (2,'Venta'), (3,'Coordinación');

select * from tipo_evento_comunicacion;

create table evento_comunicacion(
	id numeric(8) primary key,
    id_party_contacto_origen numeric(8) references party_contacto(id),
    id_party_contacto_destino numeric(8) references party_contacto(id),
    id_tipo_evento_comunicacion numeric(1) references tipo_evento_comunicacion(id),
    fecha_hora_inicio timestamp,
    fecha_hora_fin timestamp
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

SELECT * FROM pedido WHERE id = 17;

call insertarDetalleCompra(17, "Pulsera PiAz PiNe AlCrPl", 10);

SELECT * FROM detalle_pedido;

UPDATE detalle_pedido SET cantidad = 4 WHERE id = 1;

create table estado_detalle_pedido(
	id numeric(10) primary key,
    id_tipo_estado_item numeric(1) references tipo_estado_item(id),
    id_detalle_pedido numeric(10) references detalle_pedido(id),
    fecha_hora_estado timestamp
);

show tables;