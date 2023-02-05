#Se crea la base de datos de acuerdo a las reglas de negocio
 fijadas y la normalizacion de las identidades a utilizar

CREATE DATABASE if NOT EXISTS alkimiaViajes;

USE alkimiaViajes;
CREATE TABLE if NOT EXISTS usuarios (
 idUsuario INT(3) not NULL AUTO_INCREMENT PRIMARY KEY ,
 nombreUsuario VARCHAR(25) NOT null ,
 apellidoUsuario VARCHAR(25) not NULL ,
 telUsuario INT(12) NOT null ,
 mailUsuario VARCHAR(50) not NULL ,
 contrasenaUsuario VARCHAR(12) not NULL 
 );
 
CREATE TABLE if NOT EXISTS destino (
  idProvincia INT(2) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nombreProvincia VARCHAR(18) NOT NULL 
  );
 
 
CREATE TABLE if NOT EXISTS viajes (
  idViaje INT(2) NOT NULL AUTO_INCREMENT PRIMARY KEY ,
  nomViaje VARCHAR(35) NOT NULL ,
  precioViaje FLOAT(8,2) NOT NULL ,
  idProvincia INT(2) NOT NULL ,
  destinoViaje VARCHAR(50) NOT NULL ,
  descripcionViaje MEDIUMTEXT,
  FOREIGN KEY (idProvincia) REFERENCES destino (idProvincia)
  );
  
CREATE TABLE if NOT EXISTS tipoEmpresas (
	idEmpresaTipo INT(1) AUTO_INCREMENT NOT NULL PRIMARY KEY,
	servicioTipo VARCHAR(18) NOT null
	);
  
CREATE TABLE if NOT EXISTS empresas (
	idEmpresa INT(2) NOT NULL AUTO_INCREMENT PRIMARY KEY ,
	nomEmpresa VARCHAR(30) NOT NULL ,
	telEmpresa INT(12) NOT NULL ,
	idTipoEmpresa INT(1) NOT NULL ,
	FOREIGN KEY (idTipoEmpresa) REFERENCES tipoEmpresas (idEmpresaTipo)
	);
  
CREATE TABLE if NOT EXISTS viajeEmpresas (
	idPrestacion INT(3) NOT NULL AUTO_INCREMENT PRIMARY KEY ,
	idViaje INT(2) NOT NULL ,
	idEmpresa INT(2) NOT NULL ,
	FOREIGN KEY (idViaje) REFERENCES viajes (idViaje),
	FOREIGN KEY (idEmpresa) REFERENCES empresas (idEmpresa)
	);
	
CREATE TABLE if NOT EXISTS  metodoPagos (
	idMetodo INT(1) NOT NULL AUTO_INCREMENT PRIMARY KEY ,
	nomMetodoPago VARCHAR(18) NOT NULL 
	);

CREATE TABLE if NOT EXISTS compras (
	idCompra INT(4) NOT NULL AUTO_INCREMENT PRIMARY KEY,
	idUsuario INT(3) NOT NULL ,
	fechaCompra TIMESTAMP,
	idMetodoPago INT(1) NOT NULL,
	transaccion INT(16) NOT NULL,
	FOREIGN KEY (idUsuario) REFERENCES usuarios (idUsuario),
	FOREIGN KEY (idMetodoPago) REFERENCES metodoPagos (idMetodo)
	);

CREATE TABLE if NOT EXISTS compraPasajes (
	idCompraPasajes INT(4) NOT NULL AUTO_INCREMENT PRIMARY KEY ,
	idCompra INT(4) NOT NULL ,
	idViaje INT(2) NOT NULL ,
	cantCompra INT(1) NOT NULL,
	FOREIGN KEY (idCompra) REFERENCES compras (idCompra),
	FOREIGN KEY (idViaje) REFERENCES viajes (idViaje)
	);

ALTER TABLE viajes 
    ADD foto MEDIUMTEXT;
ALTER TABLE destino
    MODIFY nombreProvincia VARCHAR(31);

#Se cargan las provincias argentinas dentro de la tabla destino
INSERT INTO destino (nombreProvincia ) VALUES
('Buenos Aires'),
('Ciudad Autónoma de Buenos Aires'),
('Catamarca'),
('Chaco'),
('Chubut'),
('Córdoba'),
('Corrientes'),
('Entre Ríos'),
('Formosa'),
('Jujuy'),
('La Pampa'),
('La Rioja'),
('Mendoza'),
('Misiones'),
('Neuquén'),
('Río Negro'),
('Salta'),
('San Juan'),
('San Luis'),
('Santa Cruz'),
('Santa Fe'),
('Santiago del Estero'),
('Tierra del Fuego'),
('Tucumán');

#Se cargan los tipos de empresas con los que se trabajará, es decir el rubro de los prveedores
INSERT INTO tipoempresas (serviciotipo) VALUES
('Transporte'),
('Hoteleria'),
('Aereos'),
('Terrestres');

#Se cargan los metodos de pago
INSERT INTO metodopagos (nommetodopago) VALUES
('Transferencia'),
('Tarjeta de credito'),
('Tarjeta de debito');

# Creamos el store procedure para crear un viaje nuevo
alkimiaviajes
DELIMITER $$
DROP PROCEDURE IF EXISTS crearViaje;
CREATE PROCEDURE crearviaje(p_nombre VARCHAR(35), p_precio FLOAT(8,2), p_provincia INT(2), 
p_destino VARCHAR(50), p_descripcion MEDIUMTEXT, p_foto MEDIUMTEXT)
BEGIN
	INSERT INTO viajes(nomViaje, precioViaje, idProvincia, destinoViaje, descripcionViaje, foto)VALUES
	(p_nombre, p_precio, p_provincia, p_destino, p_descripcion, p_foto);
END;

# Creamos el store procedure para editar el viaje
DELIMITER $$
DROP PROCEDURE IF EXISTS editarViaje;
CREATE PROCEDURE editarViaje(p_nombre VARCHAR(35), p_precio FLOAT(8,2), p_provincia INT(2), 
p_destino VARCHAR(50), p_descripcion MEDIUMTEXT, p_foto MEDIUMTEXT)
BEGIN
	UPDATE viajes
	SET precioViaje = p_precio, idProvincia =  p_provincia, destinoViaje = p_destino, descripcionViaje = p_descripcion,	foto = p_foto
	WHERE nomViaje = p_nombre;
END;

# Creamos el store procedure para traer la informacion del viaje
DELIMITER $$
DROP PROCEDURE IF EXISTS seleccionarViaje;
CREATE PROCEDURE seleccionarViaje(p_nombre VARCHAR(35))
BEGIN
	SELECT viajes.nomViaje, viajes.precioViaje, destino.nombreProvincia, viajes.destinoViaje, viajes.descripcionViaje, viajes.foto
	FROM viajes INNER JOIN destino ON viajes.idProvincia = destino.idProvincia	WHERE viajes.nomViaje = p_nombre;
END;

# Creamos el store procedure para agregar un proveedor
DELIMITER $$
DROP PROCEDURE IF EXISTS agregarEmpresa;
CREATE PROCEDURE agregarEmpresa(p_nombre VARCHAR (30), p_telefono INT(12), p_idtipo INT(1))
BEGIN
	INSERT INTO empresas(nomEmpresa, telEmpresa, idTipoEmpresa) VALUES	(p_nombre, p_telefono, p_idtipo);
END;

# Creamos el store procedure para editar un proveedor
DELIMITER $$
DROP PROCEDURE IF EXISTS editarEmpresa;
CREATE PROCEDURE editarEmpresa(p_nombre VARCHAR(30), p_telefono INT(12), p_idtipo INT(1))
BEGIN
	UPDATE empresas
	SET telEmpresa = p_telefono, idTipoEmpresa =  p_idtipo
	WHERE nomEmpresa = p_nombre;
END;

# Creamos el store procedure para traer la informacion de un proveedor
DELIMITER $$
DROP PROCEDURE IF EXISTS seleccionarEmpresa;
CREATE PROCEDURE seleccionarEmpresa(p_nombre VARCHAR(30))
BEGIN
	SELECT empresas.nomEmpresa,empresas.telEmpresa, tipoempresas.servicioTipo
	FROM empresas INNER JOIN tipoempresas ON empresas.idTipoEmpresa = tipoempresas.idEmpresaTipo	WHERE empresas.nomEmpresa=p_nombre;
END;

# Creamos el store procedure para ver las compras realizadas, pudiendo filtrar por viaje o entre que fechas se realizó la compra
DELIMITER $$
DROP PROCEDURE IF EXISTS verCompras;
CREATE PROCEDURE verCompras(p_nombre VARCHAR(35),p_desdeFecha TIMESTAMP, p_hastaFecha TIMESTAMP)
BEGIN
	SELECT v.nomViaje,c.fechaCompra, cp.cantCompra, u.mailUsuario
	FROM comprapasajes AS cp INNER JOIN viajes AS v ON v.idViaje = cp.idViaje
	INNER JOIN compras AS c ON c.idCompra = cp.idCompra 
	INNER JOIN usuarios AS u ON c.idUsuario = u.idUsuario
	WHERE v.nomViaje = p_nombre AND c.fechaCompra >= p_desdeFecha AND c.fechaCompra <= p_hastaFecha;
END;

# Creamos el store procedure para asignar proveedores a un viaje
DELIMITER $$
DROP PROCEDURE IF EXISTS contratacionViajeEmpresa;
CREATE PROCEDURE contratacionViajeEmpresa(p_viaje INT(2), p_empresa INT(2))
BEGIN
	INSERT INTO viajeempresas(idViaje, idEmpresa) VALUES	(p_viaje, p_empresa);
END;

# Creamos el store procedure para ver los proveedores asignados a un viaje
DELIMITER $$
DROP PROCEDURE IF EXISTS verContrataciones;
CREATE PROCEDURE verContrataciones(p_viaje INT(2))
BEGIN
	SELECT v.nomViaje, e.nomEmpresa
	FROM viajeempresa AS ve INNER JOIN viajes AS v ON ve.idviaje = v.idViaje
	INNER JOIN empresas AS e ON ve.idempresa = e.idEmpresa
	WHERE v.nomviaje = p_viaje;
END;

# Creamos el store procedure para eliminar la asignacion de un proveedor a un viaje
DELIMITER $$
DROP PROCEDURE IF EXISTS eliminarContratacion;
CREATE PROCEDURE eliminarContratacion(p_viaje INT(2), p_empresa INT(2))
BEGIN
	DELETE FROM viajeempresas WHERE idViaje = p_viaje AND idEmpresa = p_empresa;
END;

# Creamos el store procedure para registrarse como usuario
DELIMITER $$
DROP PROCEDURE IF EXISTS registrarse;
CREATE PROCEDURE registrarse (p_nombre VARCHAR(25), p_apellido VARCHAR(25), p_telefono INT(12), p_mail VARCHAR(50), p_contrasena VARCHAR(12))
BEGIN
	INSERT INTO usuarios (nombreUsuario, apellidoUsuario, telUsuario, mailUsuario, contrasenaUsuario)
	VALUES (p_nombre, p_apellido, p_telefono, p_mail, p_contrasena);
END;

# Creamos el store procedure para editar datos buscando por el mail de la sesion
DELIMITER $$
DROP PROCEDURE IF EXISTS editarDatos;
CREATE PROCEDURE editarDatos(p_nombre VARCHAR(25), p_apellido VARCHAR(25), p_telefono INT(12), p_mail VARCHAR(50))
BEGIN
	UPDATE usuarios
	SET telUsuario = p_telefono, nombreUsuario = p_nombre, apellidoUsuario = p_apellido
	WHERE  mailUsuario =  p_mail;
END;

# Creamos el store procedure para editar contraseña buscando por el mail de la sesion
DELIMITER $$
DROP PROCEDURE IF EXISTS editarContrasena;
CREATE PROCEDURE editarContrasena (p_mail VARCHAR(50), p_contrasena VARCHAR(12))
BEGIN
	UPDATE usuarios
	SET contrasenaUsuario = p_contrasena
	WHERE mailUsuario = p_mail;
END;
