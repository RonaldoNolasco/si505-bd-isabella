-- Proceso en línea

-- Realización de evento de comunicación
-- 1. Insertar Party, persona y organización
DROP PROCEDURE IF EXISTS insertarParty;
DELIMITER $$
CREATE PROCEDURE insertarParty(tipoDocumento varchar(3), numeroDocumento varchar(11))
BEGIN
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

-- 2. Insertar Roles
DROP PROCEDURE IF EXISTS insertarRol;
DELIMITER $$
CREATE PROCEDURE insertarRol(tipoDocumento varchar(3), numeroDocumento varchar(11), tipoRol VARCHAR(20), fechaInicio DATE, fechaFin date)
BEGIN
	DECLARE idTipoDocumento NUMERIC(1) DEFAULT (select id from tipo_documento where descripcion = tipoDocumento);
	DECLARE idParty MEDIUMINT DEFAULT (select id from party where id_tipo_documento = idTipoDocumento and numero_documento = numeroDocumento);
	DECLARE idTipoRol MEDIUMINT DEFAULT (select id from tipo_rol where descripcion = tipoRol);
	INSERT INTO rol (id_party, id_tipo_rol, fecha_inicio, fecha_fin) VALUES (idParty, idTipoRol, fechaInicio, fechaFin);
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS insertarRolAlmacen;
DELIMITER $$
CREATE PROCEDURE insertarRolAlmacen(numeroDocumento varchar(11), idAlmacen NUMERIC(1), tipoRolAlmacen VARCHAR(8), fechaInicio DATE, fechaFin date)
BEGIN
	DECLARE idPersona NUMERIC(1) DEFAULT (SELECT pe.id from persona pe INNER JOIN party pa ON (pa.id = pe.id_party) 
	WHERE id_tipo_documento = 1 AND numero_documento = "76146602");
	DECLARE idTipoRolAlmacen NUMERIC(1) DEFAULT (SELECT id FROM tipo_rol_almacen WHERE descripcion = tipoRolAlmacen);
	INSERT INTO rol_almacen (id_persona, id_almacen, id_tipo_rol_almacen, fecha_inicio, fecha_fin) 
	VALUES (idPersona, idAlmacen, idTipoRolAlmacen, fechaInicio, fechaFin);
	SELECT * FROM rol_almacen;
END $$
DELIMITER ;

-- 3. Insertar contacto
DROP PROCEDURE IF EXISTS insertarContacto;
DELIMITER $$
CREATE PROCEDURE insertarContacto(tipoContacto varchar(20), valor varchar(50))
BEGIN
	DECLARE idContacto INT DEFAULT (select id from tipo_contacto where descripcion = tipoContacto);
	insert into contacto (id_tipo_contacto, valor) values (idContacto, valor);
	select * from contacto;
END $$
DELIMITER ;

-- 4. Insertar Party-Contacto
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

-- 5. Insertar Party Contacto Propósito
DROP PROCEDURE IF EXISTS insertarPCP;
DELIMITER $$
CREATE PROCEDURE insertarPCP(tipoDocumento varchar(3), numeroDocumento numeric(11), tipoContacto varchar(20), valorCont varchar(50), 
tipoProposito VARCHAR(20), fechaInicio DATE, fechaFin date)
BEGIN
	DECLARE idTipoDocumento NUMERIC(1) DEFAULT (select id from tipo_documento where descripcion = tipoDocumento);
	DECLARE idTipoContacto NUMERIC(2) DEFAULT (select id from tipo_contacto where descripcion = tipoContacto);
	DECLARE idParty MEDIUMINT DEFAULT (select id from party where id_tipo_documento = idTipoDocumento and numero_documento = numeroDocumento);
	DECLARE idContacto MEDIUMINT DEFAULT (select id from contacto where id_tipo_contacto = idTipoContacto and valor = valorCont);
	DECLARE idPartyContacto MEDIUMINT DEFAULT (select id from party_contacto where id_party = idParty and id_contacto = idContacto);
	DECLARE idTipoPropCont MEDIUMINT DEFAULT (select id from tipo_proposito_contacto where descripcion = tipoProposito);
	INSERT INTO party_contacto_proposito (id_party_contacto, id_tipo_proposito_contacto, fecha_inicio, fecha_fin) 
	VALUES (idPartyContacto, idTipoPropCont, fechaInicio, fechaFin);
	select * from party_contacto_proposito;
END $$
DELIMITER ;

-- 6. Insertar Evento de Comunicación
DROP PROCEDURE IF EXISTS insertarEC;
DELIMITER $$
CREATE PROCEDURE insertarEC(tipoDocumentoE varchar(3), numeroDocumentoE numeric(11), tipoContactoE varchar(20), valorContE varchar(50),
	tipoDocumentoR varchar(3), numeroDocumentoR numeric(11), tipoContactoR varchar(20), valorContR varchar(50), 
	tipoEventoComunicacion varchar(20), fecha_hora_inicio timestamp, fecha_hora_fin timestamp)
BEGIN
	DECLARE idTipoDocumentoE NUMERIC(1) DEFAULT (select id from tipo_documento where descripcion = tipoDocumentoE);
	DECLARE idTipoContactoE NUMERIC(2) DEFAULT (select id from tipo_contacto where descripcion = tipoContactoE);
	DECLARE idPartyE MEDIUMINT DEFAULT (select id from party where id_tipo_documento = idTipoDocumentoE and numero_documento = numeroDocumentoE);
	DECLARE idContactoE MEDIUMINT DEFAULT (select id from contacto where id_tipo_contacto = idTipoContactoE and valor = valorContE);
	DECLARE idPartyContactoE MEDIUMINT DEFAULT (select id from party_contacto where id_party = idPartyE and id_contacto = idContactoE);
	
	DECLARE idTipoDocumentoR NUMERIC(1) DEFAULT (select id from tipo_documento where descripcion = tipoDocumentoR);
	DECLARE idTipoContactoR NUMERIC(2) DEFAULT (select id from tipo_contacto where descripcion = tipoContactoR);
	DECLARE idPartyR MEDIUMINT DEFAULT (select id from party where id_tipo_documento = idTipoDocumentoR and numero_documento = numeroDocumentoR);
	DECLARE idContactoR MEDIUMINT DEFAULT (select id from contacto where id_tipo_contacto = idTipoContactoR and valor = valorContR);
	DECLARE idPartyContactoR MEDIUMINT DEFAULT (select id from party_contacto where id_party = idPartyR and id_contacto = idContactoR);
	
	DECLARE idTipoEC NUMERIC(1) DEFAULT (select id from tipo_evento_comunicacion where descripcion = tipoEventoComunicacion);
	
	insert into evento_comunicacion (id_party_contacto_origen, id_party_contacto_destino, id_tipo_evento_comunicacion, 
	fecha_hora_inicio, fecha_hora_fin) values (idPartyContactoE, idPartyContactoR, idTipoEC, fecha_hora_inicio, fecha_hora_fin);
	select * from evento_comunicacion;
END $$
DELIMITER ;

-- Proceso
CALL insertarPPO ("RUC", "15441245752", null,null,null,null,null,"Isabella","SAC","Empresa");
CALL insertarPPO ("DNI", "76146602", "Ronaldo Farid","Nolasco","Chavez","M",'2020-01-01',null,null,NULL);
CALL insertarPPO ("DNI", "08521411", "Moises Aldo","Nolasco","Rivas","M",'2020-01-01',null,null,null);
CALL insertarPPO ("DNI", "08681484", "Miriam Isabel","Chavez","Tueros","F",'2020-01-01',null,null,null);
CALL insertarPPO ("RUC", "12475215321", null,null,null,null,null,"Santa Catalina","SAA","Buen proveedor");
CALL insertarPPO ("DNI", "57482485", "Fernanda Alicia","Flores","Quispe","F",'2020-01-01',null,null,NULL);
CALL insertarPPO ("RUC", "18453254126", null,null,null,null,null,"Hermanos Lopez","SCS","Buen proveedor");
CALL insertarPPO ("DNI", "75412548", "Carla Andrea","Rodriguez","Salas","F",'2020-01-01',null,null,NULL);
CALL insertarPPO ("RUC", "14515785321", null,null,null,null,null,"Huallpa","SAC","Buen proveedor");
CALL insertarPPO ("DNI", "85421573", "Ariana","Sanchez","Garcia","F",'2020-01-01',null,null,NULL);
CALL insertarPPO ("RUC", "12475542714", null,null,null,null,null,"Angélica","SAA","Buen proveedor");
CALL insertarPPO ("DNI", "09475825", "Maria Carmen","Diaz","Torres","F",'2020-01-01',null,null,NULL);

CALL insertarRol ("RUC", "15441245752", "Empresa", CURDATE(), NULL);
CALL insertarRol ("DNI", "76146602", "Empleado", CURDATE(), NULL);
CALL insertarRol ("DNI", "08521411", "Empleado", CURDATE(), NULL);
CALL insertarRol ("DNI", "08681484", "Empleado", CURDATE(), NULL);
CALL insertarRol ("RUC", "12475215321", "Proveedor", CURDATE(), NULL);
CALL insertarRol ("DNI", "57482485", "Cliente", CURDATE(), NULL);
CALL insertarRol ("RUC", "18453254126", "Proveedor", CURDATE(), NULL);
CALL insertarRol ("DNI", "75412548", "Cliente", CURDATE(), NULL);
CALL insertarRol ("RUC", "14515785321", "Proveedor", CURDATE(), NULL);
CALL insertarRol ("DNI", "85421573", "Cliente", CURDATE(), NULL);
CALL insertarRol ("RUC", "12475542714", "Proveedor", CURDATE(), NULL);
CALL insertarRol ("DNI", "09475825", "Cliente", CURDATE(), NULL);

CALL insertarRolAlmacen ("76146602", 1, "Entrada", CURDATE(), NULL);
CALL insertarRolAlmacen ("76146602", 2, "Salida", CURDATE(), NULL);
CALL insertarRolAlmacen ("08521411", 2, "Entrada", CURDATE(), NULL);
CALL insertarRolAlmacen ("08681484", 3, "Entrada", CURDATE(), NULL);
CALL insertarRolAlmacen ("08681484", 1, "Salida", CURDATE(), NULL);
CALL insertarRolAlmacen ("08681484", 3, "Salida", CURDATE(), NULL);

CALL insertarContacto ("Celular", "920796255");
CALL insertarContacto ("Fijo", "5687037");
CALL insertarContacto ("Correo", "rnolascoc@uni.pe");
CALL insertarContacto ("Telegram", "shooterSama");
CALL insertarContacto ("Pagina web", "www.prueba.com");

CALL insertarPC ("DNI", "76146602", "Celular" ,"920796255",'2020-01-15',null,"Telefono celular");
CALL insertarPC ("RUC", "12475215321", "Fijo" ,"5687037",'2010-01-15',null,"Telefono de casa");

CALL insertarPCP ("DNI", "76146602", "Celular" ,"920796255", "Personal", CURDATE(), NULL);
CALL insertarPCP ("RUC", "12475215321", "Fijo" ,"5687037", "Trabajo", CURDATE(), NULL);

CALL insertarEC ("DNI","76146602","Celular","920796255","RUC","12475215321","Fijo","5687037","Coordinación",'2020-09-09 18:30:12','2020-09-09 18:35:17');

select * from party ORDER BY id asc;
select * from persona;
select * from organizacion;
select * from rol;
select * from rol_almacen;
select * from contacto;
select * from tipo_contacto;
select * from party_contacto;
select * from party_contacto_proposito;
select * from evento_comunicacion;