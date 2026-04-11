DROP DATABASE IF EXISTS clinica_villaro;
CREATE DATABASE clinica_villaro;
USE clinica_villaro;

-- ==========================================
-- 1. TABLAS 
-- ==========================================

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
    estado VARCHAR(20), -- 'Pendiente', 'Realizado', 'Cancelado'
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

-- ==========================================
-- 2. VISTAS (MÍNIMO 5) 
-- ==========================================

-- 1. Turnos Pendientes
CREATE OR REPLACE VIEW v_turnos_pendientes AS
SELECT t.id_turno, t.fecha_turno, p.apellido AS paciente, m.apellido AS medico
FROM turnos t
JOIN pacientes p ON t.id_paciente = p.id_paciente
JOIN medicos m ON t.id_medico = m.id_medico
WHERE t.estado = 'Pendiente';

-- 2. Demanda por Especialidad (Corregido 'nombre')
CREATE OR REPLACE VIEW v_demanda_especialidades AS
SELECT e.nombre AS especialidad, COUNT(t.id_turno) AS total_turnos
FROM especialidades e
LEFT JOIN medicos m ON e.id_especialidad = m.id_especialidad
LEFT JOIN turnos t ON m.id_medico = t.id_medico
GROUP BY e.nombre;

-- 3. Insumos Críticos
CREATE OR REPLACE VIEW v_stock_insumos_criticos AS
SELECT nombre, stock FROM insumos WHERE stock < 10;

-- 4. Facturación por Obra Social
CREATE OR REPLACE VIEW v_facturacion_por_os AS
SELECT os.nombre, SUM(fc.monto_total) AS total_recaudado
FROM obras_sociales os
JOIN pacientes p ON os.id_obra_social = p.id_obra_social
JOIN facturas_cabecera fc ON p.id_paciente = fc.id_paciente
GROUP BY os.nombre;

-- 5. Listado de Profesionales y Salas
CREATE OR REPLACE VIEW v_profesionales_salas AS
SELECT DISTINCT m.apellido, e.nombre AS especialidad, c.numero_sala
FROM medicos m
JOIN especialidades e ON m.id_especialidad = e.id_especialidad
JOIN turnos t ON m.id_medico = t.id_medico
JOIN consultorios c ON t.id_consultorio = c.id_consultorio;

-- ==========================================
-- 3. FUNCIONES 
-- ==========================================

DELIMITER //
-- Calcular edad
CREATE FUNCTION fn_calcular_edad(fecha_nac DATE) RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, fecha_nac, CURDATE());
END //

-- Obtener nombre de obra social por ID
CREATE FUNCTION fn_get_os_nombre(id_os INT) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE v_nombre VARCHAR(100);
    SELECT nombre INTO v_nombre FROM obras_sociales WHERE id_obra_social = id_os;
    RETURN v_nombre;
END //
DELIMITER ;

-- ==========================================
-- 4. STORED PROCEDURES 
-- ==========================================

DELIMITER //
-- Registro rápido de paciente
CREATE PROCEDURE sp_nuevo_paciente(
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_dni VARCHAR(15),
    IN p_fecha_nac DATE,
    IN p_id_os INT
)
BEGIN
    INSERT INTO pacientes (nombre, apellido, dni, fecha_nacimiento, id_obra_social)
    VALUES (p_nombre, p_apellido, p_dni, p_fecha_nac, p_id_os);
END //

-- Reposición de Stock
CREATE PROCEDURE sp_reponer_stock(
    IN p_id_insumo INT,
    IN p_cantidad INT
)
BEGIN
    UPDATE insumos SET stock = stock + p_cantidad WHERE id_insumo = p_id_insumo;
END //
DELIMITER ;

-- ==========================================
-- 5. TRIGGERS 
-- ==========================================

DELIMITER //
-- Auditoría de Pacientes (Apunta a log_auditoria)
CREATE TRIGGER tr_audit_pacientes_insert
AFTER INSERT ON pacientes
FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (nombre_tabla, tipo_accion, usuario_accion)
    VALUES ('pacientes', 'INSERT', USER());
END //

-- Auditoría de Seguridad en Usuarios (Cierre de brecha que pidió Leonel)
CREATE TRIGGER tr_audit_usuarios_pass_update
BEFORE UPDATE ON usuarios_sistema
FOR EACH ROW
BEGIN
    IF OLD.password <> NEW.password THEN
        INSERT INTO log_auditoria (nombre_tabla, tipo_accion, usuario_accion)
        VALUES ('usuarios_sistema', 'UPDATE_PASS', USER());
    END IF;
END //
DELIMITER ;
