DROP DATABASE IF EXISTS clinica_villaro;
CREATE DATABASE clinica_villaro;
USE clinica_villaro;

-- 1. Tipos de Usuario
CREATE TABLE tipo_usuario (
    id_tipo_usuario INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(50) NOT NULL
);

-- 2. Usuarios del Sistema
CREATE TABLE usuario_sistema (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(255),
    id_tipo_usuario INT,
    FOREIGN KEY (id_tipo_usuario) REFERENCES tipo_usuario(id_tipo_usuario)
);

-- 3. Obras Sociales
CREATE TABLE obra_social (
    id_obra_social INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    plan VARCHAR(50)
);

-- 4. Especialidades Médicas
CREATE TABLE especialidad (
    id_especialidad INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL
);

-- 5. Médicos
CREATE TABLE medico (
    id_medico INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    matricula VARCHAR(20) UNIQUE,
    id_especialidad INT,
    FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad)
);

-- 6. Pacientes
CREATE TABLE paciente (
    id_paciente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    dni VARCHAR(15) UNIQUE,
    fecha_nacimiento DATE,
    id_obra_social INT,
    FOREIGN KEY (id_obra_social) REFERENCES obra_social(id_obra_social)
);

-- 7. Consultorios
CREATE TABLE consultorio (
    id_consultorio INT PRIMARY KEY AUTO_INCREMENT,
    numero_sala VARCHAR(10),
    piso VARCHAR(5)
);

-- 8. Proveedores
CREATE TABLE proveedor (
    id_proveedor INT PRIMARY KEY AUTO_INCREMENT,
    razon_social VARCHAR(100),
    telefono VARCHAR(20)
);

-- 9. Insumos/Medicamentos 
CREATE TABLE insumo (
    id_insumo INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    stock INT DEFAULT 0,
    id_proveedor INT,
    FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor)
);

-- 10. Turnos 
CREATE TABLE turno (
    id_turno INT PRIMARY KEY AUTO_INCREMENT,
    fecha_turno DATETIME,
    estado VARCHAR(20), -- 'Pendiente', 'Realizado', 'Cancelado'
    id_paciente INT,
    id_medico INT,
    id_consultorio INT,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico),
    FOREIGN KEY (id_consultorio) REFERENCES consultorio(id_consultorio)
);

-- 11. Historias Clínicas
CREATE TABLE historia_clinica (
    id_historia INT PRIMARY KEY AUTO_INCREMENT,
    diagnostico TEXT,
    tratamiento TEXT,
    fecha_registro DATE,
    id_paciente INT,
    id_medico INT,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
);

-- 12. Estudios Médicos
CREATE TABLE estudio_medico (
    id_estudio INT PRIMARY KEY AUTO_INCREMENT,
    tipo_estudio VARCHAR(100),
    resultado TEXT,
    id_paciente INT,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente)
);

-- 13. Facturas Cabecera 
CREATE TABLE factura_cabecera (
    id_factura INT PRIMARY KEY AUTO_INCREMENT,
    fecha_factura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    monto_total DECIMAL(10,2),
    id_paciente INT,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente)
);

-- 14. Facturación Detalle 
CREATE TABLE factura_detalle (
    id_detalle INT PRIMARY KEY AUTO_INCREMENT,
    id_factura INT,
    id_insumo INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    FOREIGN KEY (id_factura) REFERENCES factura_cabecera(id_factura),
    FOREIGN KEY (id_insumo) REFERENCES insumo(id_insumo)
);

-- 15. Auditoría
CREATE TABLE log_auditoria (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    nombre_tabla VARCHAR(50),
    tipo_accion VARCHAR(10), -- INSERT, UPDATE, DELETE
    fecha_accion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_accion VARCHAR(50)
);