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