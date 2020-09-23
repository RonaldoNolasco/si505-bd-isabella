--Creacion de tablas
create database isabella;

use isabella;

DROP TABLE IF EXISTS categoria_producto;
create table categoria_producto(
	id numeric(1,0) primary key,
	descripcion VARCHAR(10) check (descripcion in ('Collar','Pulsera','Arete','Anillo','Insumo','Contenedor'))
);
insert into categoria_producto values (1,'Collar'), (2,'Pulsera'), (3,'Arete'), (4,'Anillo'), (5,'Insumo'), (6,'Contenedor');

DROP TABLE IF EXISTS producto;
CREATE TABLE producto(
	id MEDIUMINT PRIMARY KEY AUTO_INCREMENT,
	id_categoria_producto numeric(1) references categoria_producto(id),
	nombre VARCHAR(150),
	fecha_ingreso date,
	fecha_salida date
);

insert into producto (id_categoria_producto, nombre, fecha_ingreso, fecha_salida)
VALUES 
(1,'Collar de piedras negras con colgante azul y alambre cromado','2019-10-30',NULL),
(2,'Pulsera de piedras azules con hilo de pescar','2020-01-01',NULL),
(3,'Arete de perlas rosadas con cordon negro y colgante negro','2020-12-01',NULL),
(4,'Anillo de mostacillas negras','2020-12-01',NULL),
(5,'Piedra de rio negra','2019-01-01',NULL),
(5,'Colgante azul','2019-01-01',NULL),
(5,'Alambre cromado','2019-01-01',NULL),
(5,'Piedra sintética azul','2019-01-01',NULL),
(5,'Hilo de pescar','2019-01-01',NULL),
(5,'Perla de rio rosada','2019-01-01',NULL),
(5,'Cordon negro','2019-01-01',NULL),
(5,'Colgante negro','2019-01-01',NULL),
(5,'Argolla','2019-01-01',NULL),
(5,'Mostacilla negra','2019-01-01',NULL),
(6,'Bolsa como contenedor','2020-01-01',NULL),
(6,'Caja como contenedor','2020-01-01',NULL);

DROP TABLE IF EXISTS componente_producto;
create table componente_producto(
	id MEDIUMINT primary KEY AUTO_INCREMENT,
	id_producto numeric(8) references producto(id),
	id_insumo numeric(8) references producto(id),
	cantidad_uso numeric(6)
);
INSERT INTO componente_producto (id_producto, id_insumo, cantidad_uso) VALUES (1,5,6), (1,6,1), (1,7,2),
(2,8,8),(2,9,1),(3,10,5),(3,11,1),(3,12,1),(4,13,1),(4,14,4);

DROP TABLE if EXISTS tipo_caracteristica_producto;
create table tipo_caracteristica_producto(
	id numeric(6) primary key,
	descripcion varchar(50)
);
insert into tipo_caracteristica_producto values (1,'Color'), (2,'Tamaño'), (3,'Peso'), (4,'Alto'), (5,'Ancho'), (6,'Largo');

DROP TABLE if EXISTS unidad_medida;
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

DROP TABLE if EXISTS conversion_unidad_medida;
create table conversion_unidad_medida(
	id numeric(6) primary key,
    id_unidad_medida_origen numeric(4) references unidad_medida(id),
    id_unidad_medida_destino numeric(4) references unidad_medida(id),
    factor_conversion numeric(8,4)
);
insert into conversion_unidad_medida values (1,1,3,0.01);
insert into conversion_unidad_medida values (2,2,1,10);
insert into conversion_unidad_medida values (3,6,5,1000);

DROP TABLE if EXISTS caracteristica_producto;
create table caracteristica_producto(
	id numeric(6) primary key,
	id_tipo_caracteristica_producto numeric(6) references tipo_caracteristica_producto(id),
    id_unidad_medida numeric(4) references unidad_medida(id),
	descripcion varchar(50)
);
insert into caracteristica_producto values (1,1,null,'Azul'), (2,3,5,'50'), (3,5,3,'10');

DROP TABLE if EXISTS tipo_aplicabilidad_caracteristica_producto;
create table tipo_aplicabilidad_caracteristica_producto(
	id numeric(1) primary key,
    descripcion varchar(9)
);

insert into tipo_aplicabilidad_caracteristica_producto values (1,'Requerida');
insert into tipo_aplicabilidad_caracteristica_producto values (2,'Estándar');
insert into tipo_aplicabilidad_caracteristica_producto values (3,'Opcional');
insert into tipo_aplicabilidad_caracteristica_producto values (4,'Elegible');

DROP TABLE if EXISTS aplicabilidad_caracteristica_producto;
create table aplicabilidad_caracteristica_producto(
	id numeric(8) primary key,
    id_producto numeric(8) references producto(id),
    id_caracteristica_producto numeric(6) references caracteristica_producto(id),
    id_tipo_aplicabilidad_caracteristica_producto numeric(1) references tipo_aplicabilidad_caracteristica_producto(id),
    fecha_inicio date,
    fecha_fin date
);

DROP TABLE if EXISTS tipo_componente_costo;
create table tipo_componente_costo(
	id numeric(1) primary key,
    descripcion varchar(10)
);
insert into tipo_componente_costo values (1,'Base'), (2,'Transporte');

DROP TABLE if EXISTS componente_costo;
create table componente_costo(
	id MEDIUMINT PRIMARY KEY AUTO_INCREMENT,
    id_producto numeric(8) references producto(id),
    id_tipo_componente_costo numeric(1) references tipo_componente_costo(id),
    fecha_inicio date,
    fecha_fin date,
    costo numeric(8,2)
);
insert into componente_costo (id_producto, id_tipo_componente_costo, fecha_inicio, fecha_fin, costo)
VALUES (5,1,'2020-01-01',NULL,1),(6,1,'2020-01-01',NULL,1),(7,1,'2020-01-01',NULL,1),(8,1,'2020-01-01',NULL,1),
(9,1,'2020-01-01',NULL,1),(10,1,'2020-01-01',NULL,1),(11,1,'2020-01-01',NULL,1),(12,1,'2020-01-01',NULL,1),
(13,1,'2020-01-01',NULL,1),(14,1,'2020-01-01',NULL,1),(15,1,'2020-01-01',NULL,1),(16,1,'2020-01-01',NULL,1);

DROP TABLE if EXISTS tipo_componente_precio;
create table tipo_componente_precio(
	id numeric(1) primary key,
    descripcion varchar(10)
);

insert into tipo_componente_precio values (1,'Base'), (2,'Descuento');

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
VALUES (1,1,'2020-01-01',NULL,11),(2,1,'2020-01-01',NULL,12),(3,1,'2020-01-01',NULL,9),(4,1,'2020-01-01',NULL,10);

DROP TABLE if EXISTS tipo_documento;
create table tipo_documento(
	id numeric(1) primary key,
	descripcion varchar(3)
);
insert into tipo_documento values (1,'DNI'), (2,'RUC'), (3,'CdE');

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

DROP TABLE if EXISTS tipo_rol;
create table tipo_rol(
	id numeric(3) primary key,
	descripcion varchar(20)
);

insert into tipo_rol values (1,'Empresa'), (2,'Empleado'), (3,'Proveedor'), (4,'Cliente');

DROP TABLE if EXISTS rol;
create table rol(
	id MEDIUMINT primary KEY AUTO_INCREMENT,
	id_party numeric(8) references party(id),
	id_tipo_rol numeric(3) references tipo_rol(id),
	fecha_inicio date,
	fecha_fin date
);

DROP TABLE if EXISTS almacen;
create table almacen(
	id numeric(2) primary key,
	descripcion varchar(10)
);
insert into almacen values (1,'Cuarto'), (2,'Tragaluz'), (3,'Escalera');

DROP TABLE if EXISTS tipo_rol_almacen;
create table tipo_rol_almacen(
	id numeric(1) primary key,
    descripcion varchar(8)
);
insert into tipo_rol_almacen values (1,'Entrada'), (2,'Salida');

DROP TABLE if EXISTS rol_almacen;
create table rol_almacen(
	id MEDIUMINT primary KEY AUTO_INCREMENT,
    id_persona numeric(6) references persona(id),
    id_almacen numeric(2) references almacen(id),
    id_tipo_rol_almacen numeric(1) references tipo_rol_almacen(id),
    fecha_inicio date,
	fecha_fin date
);

DROP TABLE if EXISTS tipo_contacto;
create table tipo_contacto(
	id numeric(2) primary key,
    descripcion varchar(20)
);
insert into tipo_contacto values (1,'Celular'), (2,'Fijo'), (3,'Correo') ,(4,'Telegram'), (5,'Facebook'), (6,'Pagina Web');

drop table if exists contacto;
create table contacto(
	id MEDIUMINT primary key AUTO_INCREMENT,
    id_tipo_contacto numeric(2) references tipo_contacto(id),
    valor varchar(50),
	unique(id_tipo_contacto, valor)
);

drop table if exists party_contacto;
create table party_contacto(
	id MEDIUMINT primary key AUTO_INCREMENT,
    id_party MEDIUMINT not null references party(id),
    id_contacto MEDIUMINT not null references contacto(id),
    fecha_inicio date,
    fecha_fin date,
    descripcion varchar(50)
);

DROP TABLE if EXISTS tipo_proposito_contacto;
create table tipo_proposito_contacto(
	id numeric(1) primary key,
    descripcion varchar(20)
);
insert into tipo_proposito_contacto values (1,'Personal'), (2,'Trabajo');

DROP TABLE if EXISTS party_contacto_proposito;
create table party_contacto_proposito(
	id MEDIUMINT PRIMARY KEY AUTO_INCREMENT,
    id_party_contacto numeric(8) references party_contacto(id),
    id_tipo_proposito_contacto numeric(1) references tipo_proposito_contacto(id),
    fecha_inicio date,
    fecha_fin date
);

DROP TABLE if EXISTS tipo_evento_comunicacion;
create table tipo_evento_comunicacion(
	id numeric(1) primary key,
    descripcion varchar(20)
);
insert into tipo_evento_comunicacion values (1,'Compra'), (2,'Venta'), (3,'Coordinación');

DROP TABLE if EXISTS evento_comunicacion;
create table evento_comunicacion(
	id MEDIUMINT PRIMARY KEY AUTO_INCREMENT,
    id_party_contacto_origen numeric(8) references party_contacto(id),
    id_party_contacto_destino numeric(8) references party_contacto(id),
    id_tipo_evento_comunicacion numeric(1) references tipo_evento_comunicacion(id),
    fecha_hora_inicio timestamp,
    fecha_hora_fin timestamp
);

DROP TABLE if EXISTS diseño;
create table tipo_calificacion(
	id numeric(4) primary key,
	descripcion varchar(20)
);
insert into tipo_calificacion values (1,'Sobresaliente'), (2,'Bueno'), (3,'Regular'), (4,'Malo');

DROP TABLE if EXISTS tipo_preferencia;
create table tipo_preferencia(
	id numeric(4) primary key,
	descripcion varchar(20)
);
insert into tipo_preferencia values (1,'Primero'), (2,'Segundo'), (3,'Tercero'), (4,'Cuarto');

DROP TABLE if EXISTS proveedor_producto;
create table proveedor_producto(
	id INT PRIMARY KEY AUTO_INCREMENT,
	id_organizacion numeric(6) references organizacion(id),
	id_insumo numeric(8) references producto(id),
	id_tipo_calificacion numeric(4) references tipo_calificacion(id),
	id_tipo_preferencia numeric(4) references tipo_preferencia(id),
	fecha_inicio date,
	fecha_fin date,
	tiempo_entrega_estandar time,
	comentario varchar(80)
);
INSERT INTO proveedor_producto (id_organizacion, id_insumo, id_tipo_calificacion, id_tipo_preferencia, fecha_inicio) VALUES 
(2,5,1,1,CURDATE()),(2,6,2,1,CURDATE()),(2,7,1,2,CURDATE()),(2,8,2,3,CURDATE()),
(3,5,3,2,CURDATE()),(3,6,2,2,CURDATE()),(3,7,1,1,CURDATE()),(3,8,4,1,CURDATE()),
(4,5,2,1,CURDATE()),(4,6,1,1,CURDATE()),(4,7,2,4,CURDATE()),(4,8,3,1,CURDATE()),
(5,5,2,2,CURDATE()),(5,6,4,3,CURDATE()),(5,7,2,3,CURDATE()),(5,8,1,1,CURDATE());

DROP TABLE if EXISTS tipo_contenedor;
create table tipo_contenedor(
	id numeric(2) primary key,
	descripcion varchar(10)
);
insert into tipo_contenedor values (1,'Bolsa'), (2,'Caja');

DROP TABLE if EXISTS contenedor;
create table contenedor(
	id MEDIUMINT primary KEY AUTO_INCREMENT,
	id_tipo_contenedor numeric(2) references tipo_contenedor(id),
	id_almacen numeric(3) references almacen(id)
);

drop table if EXISTS item;
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
    fecha_hora_estado timestamp
);

drop table if exists pedido;
create table pedido(
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

drop table if exists tipo_estado_pedido;
create table tipo_estado_pedido(
	id numeric(1) primary key,
    descripcion VARCHAR(12)
);
insert into tipo_estado_pedido values (1,'Por entregar'), (2,'Entregado');

drop table if exists estado_pedido;
create table estado_pedido(
	id MEDIUMINT primary key AUTO_INCREMENT,
    id_pedido MEDIUMINT references pedido(id),
    id_tipo_estado_pedido numeric(1) references tipo_estado_pedido(id),
    fecha_hora_estado TIMESTAMP,
    UNIQUE(id_pedido, id_tipo_estado_pedido)
);

DROP TABLE if EXISTS detalle_pedido;
create table detalle_pedido(
	id INT UNSIGNED primary key AUTO_INCREMENT,
    id_pedido MEDIUMINT references pedido(id),
    id_producto numeric(8) references producto(id),
    cantidad numeric(6) CHECK (cantidad > 0) NOT NULL,
    precio_unitario numeric(8,2) CHECK (precio_unitario > 0) NOT NULL,
    UNIQUE (id_pedido, id_producto)
);

drop table if exists tipo_estado_detalle_pedido;
create table tipo_estado_detalle_pedido(
	id numeric(1) primary key,
    descripcion VARCHAR(12)
);
INSERT INTO tipo_estado_detalle_pedido VALUES (1, "Bueno"), (2, "Regular"), (3, "Malo");

DROP TABLE if EXISTS estado_detalle_pedido;
create table estado_detalle_pedido(
	id MEDIUMINT primary KEY AUTO_INCREMENT,
	id_detalle_pedido numeric(10) references detalle_pedido(id),
    id_tipo_estado_detalle_pedido numeric(1) references tipo_estado_detalle_pedido(id),
    fecha_hora_estado timestamp
);

DROP TABLE if EXISTS diseño;
create table diseño(
	id numeric(8) primary key,
    id_producto numeric(8) references producto(id),
    numero_paso numeric(3),
    descripcion varchar(80)
);

DROP TABLE if EXISTS fabricacion;
create table fabricacion(
	id numeric(10) primary key,
    id_diseño numeric(8) references diseño(id),
    id_insumo numeric(8) references producto(id),
    cantidad_uso numeric(3)
);

show TABLES;