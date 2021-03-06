set search_path to "20180125F";

create table categoria_producto(
	id numeric(1,0) primary key,
	descripcion varchar(9) check (descripcion in ('Collar','Pulsera','Arete','Anillo','Insumo'))
);

insert into categoria_producto values (1,'Collar');
insert into categoria_producto values (2,'Pulsera');
insert into categoria_producto values (3,'Arete');
insert into categoria_producto values (4,'Anillo');
insert into categoria_producto values (5,'Insumo');

select * from categoria_producto;

create table producto(
	id numeric(8) primary key,
	id_categoria_producto numeric(1) references categoria_producto(id),
	nombre varchar(40),
	comentario varchar(100),
	fecha_ingreso date,
	fecha_salida date,
	imagen_referencial varchar(50)
);

insert into producto values (1,2,'Pulsera PiAz PiNe AlCrPl','Pulsera de piedras azul y negra con alambre cromado plomo','2020-01-01','2020-02-01','url');
insert into producto values (2,5,'AlCrPl','Alambre cromado plomo','2020-01-01','2020-02-01','url');

select * from producto;

create table componente_producto(
	id numeric(8) primary key,
	id_insumo numeric(8) references producto(id),
	id_producto numeric(8) references producto(id),
	cantidad_uso numeric(6),
	comentario varchar(60)
);

insert into componente_producto values (1,2,1,1,'Estructura del producto');

select * from componente_producto;

create table tipo_caracteristica_producto(
	id numeric(6) primary key,
	descripcion varchar(50)
);

insert into tipo_caracteristica_producto values (1,'Color');
insert into tipo_caracteristica_producto values (2,'Tamaño');
insert into tipo_caracteristica_producto values (3,'Peso');
insert into tipo_caracteristica_producto values (4,'Alto');
insert into tipo_caracteristica_producto values (5,'Ancho');
insert into tipo_caracteristica_producto values (6,'Largo');

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

insert into tipo_componente_costo values (1,'Base');
insert into tipo_componente_costo values (2,'Transporte');

select * from tipo_componente_costo;

create table componente_costo(
	id numeric(6) primary key,
    id_producto numeric(8) references producto(id),
    id_tipo_componente_costo numeric(1) references tipo_componente_costo(id),
    fecha_inicio date,
    fecha_fin date,
    costo numeric(8,2)
);

create table tipo_componente_precio(
	id numeric(1) primary key,
    descripcion varchar(10)
);

insert into tipo_componente_precio values (1,'Base');
insert into tipo_componente_precio values (2,'Descuento');

select * from tipo_componente_precio;

create table componente_precio(
	id numeric(6) primary key,
    id_producto numeric(8) references producto(id),
    id_tipo_componente_precio numeric(1) references tipo_componente_precio(id),
    fecha_inicio date,
    fecha_fin date,
    precio numeric(8,2),
    descuento numeric(5,2)
);

create table tipo_documento(
	id numeric(1) primary key,
	descripcion varchar(3)
);

insert into tipo_documento values (1,'DNI');
insert into tipo_documento values (2,'RUC');
insert into tipo_documento values (3,'CdE');

select * from tipo_documento;

create table party(
	id numeric(8) primary key,
	id_tipo_documento numeric(1) references tipo_documento(id),
	numero_documento numeric(11),
	descripcion varchar(80)
);

create table persona(
	id numeric(6) primary key,
	id_party numeric(8) unique references party(id),
	nombre varchar(80),
	apellido_paterno varchar(80),
	apellido_materno varchar(80),
	genero varchar(1) check(genero in ('M','F')),
	fecha_nacimiento date
);

create table organizacion(
	id numeric(6) primary key,
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

insert into tipo_contenedor values (1,'Bolsa');
insert into tipo_contenedor values (2,'Caja');

select * from tipo_contenedor;

create table contenedor(
	id numeric(10) primary key,
	id_tipo_contenedor numeric(2) references tipo_contenedor(id),
	id_almacen numeric(3) references almacen(id),
	numero_serie numeric(8),
	cantidad_en_mano numeric(8)
);
	
insert into contenedor values (1,1,1,1234,null);
insert into contenedor values (2,2,3,1235,null);
insert into contenedor values (3,1,2,1236,null);

select * from contenedor;

create table item(
	id numeric(10) primary key,
	id_producto numeric(8) references producto(id),
	id_contenedor numeric(10) references contenedor(id),
	id_almacen numeric(2) references almacen(id),
	numero_serie numeric(11),
    cantidad_mano numeric(4)
);

create table tipo_estado_pedido(
	id numeric(1) primary key,
    descripcion varchar(10)
);

insert into tipo_estado_pedido values (1,'En almacén');
insert into tipo_estado_pedido values (2,'Despachado');
insert into tipo_estado_pedido values (3,'Entregado');

create table tipo_estado_item(
	id numeric(1) primary key,
    descripcion varchar(10)
);

insert into tipo_estado_item values (1,'Excelente');
insert into tipo_estado_item values (2,'Bueno');
insert into tipo_estado_item values (3,'Regular');
insert into tipo_estado_item values (4,'Malo');
insert into tipo_estado_item values (5,'Defectuoso');
insert into tipo_estado_item values (6,'Reparación');
insert into tipo_estado_item values (7,'Vendido');

select * from tipo_estado_item;

create table estado_item(
	id numeric(8) primary key,
    id_item numeric(10) references item(id),
    id_tipo_estado_item numeric(1) references tipo_estado_item(id),
    fecha_inicio date,
    fecha_fin date
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
    descripción varchar(20)
);

insert into tipo_contacto values (1,'Celular');
insert into tipo_contacto values (2,'Fijo');
insert into tipo_contacto values (3,'Correo');
insert into tipo_contacto values (4,'Telegram');

create table contacto(
	id numeric(8) primary key,
    id_tipo_contacto numeric(2) references tipo_contacto(id),
    valor varchar(50)
);

create table party_contacto(
	id numeric(8) primary key,
    id_party numeric(8) references party(id),
    id_contacto numeric(8) references contacto(id),
    id_tipo_rol numeric(3) references tipo_rol(id),
    fecha_inicio date,
    fecha_fin date,
    descripción varchar(50)
);

create table tipo_proposito_contacto(
	id numeric(1) primary key,
    descripcion varchar(20)
);

insert into tipo_proposito_contacto values (1,'Personal');
insert into tipo_proposito_contacto values (2,'Trabajo');

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

insert into tipo_evento_comunicacion values (1,'Compra');
insert into tipo_evento_comunicacion values (2,'Venta');
insert into tipo_evento_comunicacion values (3,'Coordinación');

select * from tipo_evento_comunicacion;

create table evento_comunicacion(
	id numeric(8) primary key,
    id_party_contacto_origen numeric(8) references party_contacto(id),
    id_party_contacto_destino numeric(8) references party_contacto(id),
    id_tipo_evento_comunicacion numeric(1) references tipo_evento_comunicacion(id),
    fecha_hora_inicio timestamp,
    fecha_hora_fin timestamp
);

create table pedido(
	id numeric(8) primary key,
    id_party_emisor numeric(8) references party(id),
    id_party_receptor numeric(8) references party(id),
    id_party_creador numeric(8) references party(id),
    id_party_modificador numeric(8) references party(id),
    fecha_hora_creacion date,
    fecha_hora_modificacion date,
    comision_vendedor numeric(6,2),
    monto_pedido numeric(6,2),
    cobro_logistico numeric(6,2),
    impuestos numeric(6,2),
    subtotal numeric(8,2)
);

create table estado_pedido(
	id numeric(10) primary key,
    id_tipo_estado_pedido numeric(1) references tipo_estado_pedido(id),
    id_pedido numeric(8) references pedido(id),
    fecha_hora_inicio timestamp,
    fecha_hora_fin timestamp
);

create table detalle_pedido(
	id numeric(10) primary key,
    id_pedido numeric(8) references pedido(id),
    id_producto numeric(8) references producto(id),
    cantidad numeric(6)
);

create table estado_detalle_pedido(
	id numeric(10) primary key,
    id_tipo_estado_item numeric(1) references tipo_estado_item(id),
    id_detalle_pedido numeric(10) references detalle_pedido(id),
    fecha_hora_estado timestamp
);