DROP DATABASE IF EXISTS clinica_villaro;
CREATE DATABASE clinica_villaro;
USE clinica_villaro;

-- TABLAS EN PLURAL (REQUISITO UNIFICACIÓN)
CREATE TABLE tipos_usuarios (
    id_tipo_usuario INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(50) NOT NULL
);

CREATE TABLE usuarios_sistema (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(255),
    id_tipo_usuario INT,
    FOREIGN KEY (id_tipo_usuario) REFERENCES tipos_usuarios(id_tipo_usuario)
);

CREATE TABLE obras_sociales (
    id_obra_social INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    plan VARCHAR(50)
);

CREATE TABLE especialidades (
    id_especialidad INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE medicos (
    id_medico INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    matricula VARCHAR(20) UNIQUE,
    id_especialidad INT,
    FOREIGN KEY (id_especialidad) REFERENCES especialidades(id_especialidad)
);

CREATE TABLE pacientes (
    id_paciente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    dni VARCHAR(15) UNIQUE,
    fecha_nacimiento DATE,
    id_obra_social INT,
    FOREIGN KEY (id_obra_social) REFERENCES obras_sociales(id_obra_social)
);

CREATE TABLE consultorios (
    id_consultorio INT PRIMARY KEY AUTO_INCREMENT,
    numero_sala VARCHAR(10),
    piso VARCHAR(5)
);

CREATE TABLE proveedores (
    id_proveedor INT PRIMARY KEY AUTO_INCREMENT,
    razon_social VARCHAR(100),
    telefono VARCHAR(20)
);

CREATE TABLE insumos (
    id_insumo INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    stock INT DEFAULT 0,
    id_proveedor INT,
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);

CREATE TABLE turnos (
    id_turno INT PRIMARY KEY AUTO_INCREMENT,
    fecha_turno DATETIME,
    estado VARCHAR(20),
    id_paciente INT,
    id_medico INT,
    id_consultorio INT,
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    FOREIGN KEY (id_medico) REFERENCES medicos(id_medico),
    FOREIGN KEY (id_consultorio) REFERENCES consultorios(id_consultorio)
);

CREATE TABLE historias_clinicas (
    id_historia INT PRIMARY KEY AUTO_INCREMENT,
    diagnostico TEXT,
    tratamiento TEXT,
    fecha_registro DATE,
    id_paciente INT,
    id_medico INT,
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    FOREIGN KEY (id_medico) REFERENCES medicos(id_medico)
);

CREATE TABLE estudios_medicos (
    id_estudio INT PRIMARY KEY AUTO_INCREMENT,
    tipo_estudio VARCHAR(100),
    resultado TEXT,
    id_paciente INT,
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente)
);

CREATE TABLE facturas_cabecera (
    id_factura INT PRIMARY KEY AUTO_INCREMENT,
    fecha_factura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    monto_total DECIMAL(10,2),
    id_paciente INT,
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente)
);

CREATE TABLE facturas_detalle (
    id_detalle INT PRIMARY KEY AUTO_INCREMENT,
    id_factura INT,
    id_insumo INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    FOREIGN KEY (id_factura) REFERENCES facturas_cabecera(id_factura),
    FOREIGN KEY (id_insumo) REFERENCES insumos(id_insumo)
);

CREATE TABLE log_auditoria (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    nombre_tabla VARCHAR(50),
    tipo_accion VARCHAR(10),
    fecha_accion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_accion VARCHAR(50)
);
