--Creacion de tablas 
--Conectase al user Ferre_owner para esto
CREATE TABLE categoria (
    id_categoria  NUMBER GENERATED ALWAYS AS IDENTITY,
    nombre        VARCHAR2(60)  NOT NULL,
    descripcion   VARCHAR2(200),
    CONSTRAINT pk_categoria        PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nombre UNIQUE (nombre)
);

CREATE TABLE producto (
    id_producto   NUMBER GENERATED ALWAYS AS IDENTITY,
    nombre        VARCHAR2(100) NOT NULL,
    descripcion   VARCHAR2(250),
    precio_venta  NUMBER(12,2)  NOT NULL,
    stock_actual  NUMBER(10)    DEFAULT 0 NOT NULL,
    stock_minimo  NUMBER(10)    DEFAULT 0 NOT NULL,
    id_categoria  NUMBER        NOT NULL,
    CONSTRAINT pk_producto        PRIMARY KEY (id_producto),
    CONSTRAINT fk_producto_cat    FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria),
    CONSTRAINT ck_producto_precio CHECK (precio_venta > 0),
    CONSTRAINT ck_producto_stock  CHECK (stock_actual >= 0),
    CONSTRAINT ck_producto_min    CHECK (stock_minimo >= 0)
);

CREATE TABLE proveedor (
    id_proveedor  NUMBER GENERATED ALWAYS AS IDENTITY,
    nombre        VARCHAR2(100) NOT NULL,
    telefono      VARCHAR2(20),
    correo        VARCHAR2(100),
    direccion     VARCHAR2(200),
    CONSTRAINT pk_proveedor PRIMARY KEY (id_proveedor)
);

CREATE TABLE cliente (
    id_cliente    NUMBER GENERATED ALWAYS AS IDENTITY,
    nombre        VARCHAR2(100) NOT NULL,
    telefono      VARCHAR2(20),
    correo        VARCHAR2(100),
    direccion     VARCHAR2(200),
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente)
);

CREATE TABLE usuario (
    id_usuario      NUMBER GENERATED ALWAYS AS IDENTITY,
    nombre          VARCHAR2(100) NOT NULL,
    nombre_usuario  VARCHAR2(30)  NOT NULL,
    contrasena      VARCHAR2(100) NOT NULL,   -- hash SHA-256, nunca texto plano
    rol             VARCHAR2(20)  DEFAULT 'VENDEDOR' NOT NULL,
    correo          VARCHAR2(100),
    estado          CHAR(1)       DEFAULT 'A' NOT NULL,
    CONSTRAINT pk_usuario         PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_login   UNIQUE (nombre_usuario),
    CONSTRAINT ck_usuario_rol     CHECK (rol IN ('ADMIN', 'VENDEDOR')),
    CONSTRAINT ck_usuario_estado  CHECK (estado IN ('A', 'I'))
);

CREATE TABLE compra (
    id_compra     NUMBER GENERATED ALWAYS AS IDENTITY,
    fecha_compra  DATE          DEFAULT SYSDATE NOT NULL,
    total_compra  NUMBER(14,2)  DEFAULT 0 NOT NULL,
    id_proveedor  NUMBER        NOT NULL,
    CONSTRAINT pk_compra       PRIMARY KEY (id_compra),
    CONSTRAINT fk_compra_prov  FOREIGN KEY (id_proveedor) REFERENCES proveedor (id_proveedor),
    CONSTRAINT ck_compra_total CHECK (total_compra >= 0)
);

CREATE TABLE detallecompra (
    id_detalle_compra NUMBER GENERATED ALWAYS AS IDENTITY,
    id_compra         NUMBER       NOT NULL,
    id_producto       NUMBER       NOT NULL,
    cantidad          NUMBER(10)   NOT NULL,
    precio_unitario   NUMBER(12,2) NOT NULL,
    CONSTRAINT pk_detallecompra  PRIMARY KEY (id_detalle_compra),
    CONSTRAINT fk_dcompra_compra FOREIGN KEY (id_compra)   REFERENCES compra (id_compra),
    CONSTRAINT fk_dcompra_prod   FOREIGN KEY (id_producto) REFERENCES producto (id_producto),
    CONSTRAINT ck_dcompra_cant   CHECK (cantidad > 0),
    CONSTRAINT ck_dcompra_precio CHECK (precio_unitario >= 0)
);


CREATE TABLE venta (
    id_venta     NUMBER GENERATED ALWAYS AS IDENTITY,
    fecha_venta  DATE          DEFAULT SYSDATE NOT NULL,
    total_venta  NUMBER(14,2)  DEFAULT 0 NOT NULL,
    id_cliente   NUMBER        NOT NULL,
    id_usuario   NUMBER        NOT NULL,
    CONSTRAINT pk_venta        PRIMARY KEY (id_venta),
    CONSTRAINT fk_venta_cli    FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT fk_venta_usr    FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    CONSTRAINT ck_venta_total  CHECK (total_venta >= 0)
);

CREATE TABLE detalleventa (
    id_detalle_venta NUMBER GENERATED ALWAYS AS IDENTITY,
    id_venta         NUMBER       NOT NULL,
    id_producto      NUMBER       NOT NULL,
    cantidad         NUMBER(10)   NOT NULL,
    precio_unitario  NUMBER(12,2) NOT NULL,
    CONSTRAINT pk_detalleventa  PRIMARY KEY (id_detalle_venta),
    CONSTRAINT fk_dventa_venta  FOREIGN KEY (id_venta)    REFERENCES venta (id_venta),
    CONSTRAINT fk_dventa_prod   FOREIGN KEY (id_producto) REFERENCES producto (id_producto),
    CONSTRAINT ck_dventa_cant   CHECK (cantidad > 0),
    CONSTRAINT ck_dventa_precio CHECK (precio_unitario >= 0)
);

CREATE INDEX idx_producto_categoria ON producto (id_categoria);
CREATE INDEX idx_producto_nombre    ON producto (nombre);
CREATE INDEX idx_compra_proveedor   ON compra (id_proveedor);
CREATE INDEX idx_dcompra_compra     ON detallecompra (id_compra);
CREATE INDEX idx_dcompra_producto   ON detallecompra (id_producto);
CREATE INDEX idx_venta_cliente      ON venta (id_cliente);
CREATE INDEX idx_venta_usuario      ON venta (id_usuario);
CREATE INDEX idx_venta_fecha        ON venta (fecha_venta);
CREATE INDEX idx_dventa_venta       ON detalleventa (id_venta);
CREATE INDEX idx_dventa_producto    ON detalleventa (id_producto);

-- Verificación: deben aparecer 9 tablas
SELECT table_name FROM user_tables ORDER BY table_name;

--Inserts
SET DEFINE OFF

INSERT INTO categoria (nombre, descripcion) VALUES ('Herramientas manuales', 'Martillos, alicates, destornilladores');
INSERT INTO categoria (nombre, descripcion) VALUES ('Eléctricos', 'Cables, tomas, breakers');
INSERT INTO categoria (nombre, descripcion) VALUES ('Pinturas', 'Pinturas y accesorios');

INSERT INTO producto (nombre, descripcion, precio_venta, stock_actual, stock_minimo, id_categoria)
VALUES ('Martillo 16oz', 'Mango de fibra', 6500, 25, 5,
        (SELECT id_categoria FROM categoria WHERE nombre = 'Herramientas manuales'));
INSERT INTO producto (nombre, descripcion, precio_venta, stock_actual, stock_minimo, id_categoria)
VALUES ('Destornillador Phillips', 'Punta #2', 2200, 3, 8,
        (SELECT id_categoria FROM categoria WHERE nombre = 'Herramientas manuales'));
INSERT INTO producto (nombre, descripcion, precio_venta, stock_actual, stock_minimo, id_categoria)
VALUES ('Cable THHN #12 (m)', 'Cobre, por metro', 950, 120, 30,
        (SELECT id_categoria FROM categoria WHERE nombre = 'Eléctricos'));
INSERT INTO producto (nombre, descripcion, precio_venta, stock_actual, stock_minimo, id_categoria)
VALUES ('Pintura blanca 1 gal', 'Látex interior', 18500, 12, 4,
        (SELECT id_categoria FROM categoria WHERE nombre = 'Pinturas'));

INSERT INTO proveedor (nombre, telefono, correo, direccion) VALUES ('Distribuidora Tica S.A.', '2222-1111', 'ventas@distica.cr', 'San José');
INSERT INTO proveedor (nombre, telefono, correo, direccion) VALUES ('Eléctricos del Norte', '2444-3333', 'info@elecnorte.cr', 'Alajuela');

INSERT INTO cliente (nombre, telefono, correo, direccion) VALUES ('Cliente Mostrador', NULL, NULL, NULL);
INSERT INTO cliente (nombre, telefono, correo, direccion) VALUES ('Constructora Pérez', '8888-0000', 'compras@perez.cr', 'Heredia');

-- Contraseña guardada como hash SHA-256 (clave de prueba: admin123)
INSERT INTO usuario (nombre, nombre_usuario, contrasena, rol, correo, estado)
VALUES ('Administrador', 'admin', RAWTOHEX(STANDARD_HASH('admin123', 'SHA256')), 'ADMIN', 'admin@ferreteria.cr', 'A');

COMMIT;

-- Verificación
SELECT 'categoria' AS tabla, COUNT(*) AS filas FROM categoria
UNION ALL SELECT 'producto',  COUNT(*) FROM producto
UNION ALL SELECT 'proveedor', COUNT(*) FROM proveedor
UNION ALL SELECT 'cliente',   COUNT(*) FROM cliente
UNION ALL SELECT 'usuario',   COUNT(*) FROM usuario;


-->Vistas 

SET DEFINE OFF
CREATE OR REPLACE VIEW v_ventas AS
SELECT v.id_venta, v.fecha_venta, v.total_venta,
       c.nombre AS cliente, u.nombre AS usuario
  FROM venta v
  JOIN cliente c ON c.id_cliente = v.id_cliente
  JOIN usuario u ON u.id_usuario = v.id_usuario;

CREATE OR REPLACE VIEW v_compras AS
SELECT c.id_compra, c.fecha_compra, c.total_compra,
       p.nombre AS proveedor
  FROM compra c
  JOIN proveedor p ON p.id_proveedor = c.id_proveedor;

CREATE OR REPLACE VIEW v_stock_bajo AS
SELECT id_producto, nombre, stock_actual, stock_minimo
  FROM producto
 WHERE stock_actual <= stock_minimo;

--Funciones

-- Stock actual 
CREATE OR REPLACE FUNCTION fn_stock_disponible (p_id_producto IN NUMBER)
RETURN NUMBER
IS
    v_stock producto.stock_actual%TYPE;
BEGIN
    SELECT stock_actual INTO v_stock
      FROM producto
     WHERE id_producto = p_id_producto;
    RETURN v_stock;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END fn_stock_disponible;
/

-- Total de una venta 
CREATE OR REPLACE FUNCTION fn_total_venta (p_id_venta IN NUMBER)
RETURN NUMBER
IS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(cantidad * precio_unitario), 0)
      INTO v_total
      FROM detalleventa
     WHERE id_venta = p_id_venta;
    RETURN v_total;
END fn_total_venta;
/

-- Total de una compra 
CREATE OR REPLACE FUNCTION fn_total_compra (p_id_compra IN NUMBER)
RETURN NUMBER
IS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(cantidad * precio_unitario), 0)
      INTO v_total
      FROM detallecompra
     WHERE id_compra = p_id_compra;
    RETURN v_total;
END fn_total_compra;
/

-- Verificación 
SELECT fn_stock_disponible(1) AS stock_producto_1 FROM dual;
SELECT object_name, object_type, status FROM user_objects
 WHERE object_type IN ('VIEW', 'FUNCTION') ORDER BY object_type, object_name;

--Procedimientos almacenados 
CREATE OR REPLACE PROCEDURE sp_crear_producto (
    p_nombre       IN VARCHAR2,
    p_descripcion  IN VARCHAR2,
    p_precio_venta IN NUMBER,
    p_stock_minimo IN NUMBER,
    p_id_categoria IN NUMBER
)
IS
BEGIN
    IF p_precio_venta IS NULL OR p_precio_venta <= 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'El precio de venta debe ser mayor a 0.');
    END IF;

    -- El stock inicia en 0: solo cambia con compras y ventas (triggers)
    INSERT INTO producto (nombre, descripcion, precio_venta, stock_actual, stock_minimo, id_categoria)
    VALUES (p_nombre, p_descripcion, p_precio_venta, 0, NVL(p_stock_minimo, 0), p_id_categoria);
END sp_crear_producto;
/

CREATE OR REPLACE PROCEDURE sp_crear_cliente (
    p_nombre    IN VARCHAR2,
    p_telefono  IN VARCHAR2,
    p_correo    IN VARCHAR2,
    p_direccion IN VARCHAR2
)
IS
BEGIN
    INSERT INTO cliente (nombre, telefono, correo, direccion)
    VALUES (p_nombre, p_telefono, p_correo, p_direccion);
END sp_crear_cliente;
/

CREATE OR REPLACE PROCEDURE sp_crear_proveedor (
    p_nombre    IN VARCHAR2,
    p_telefono  IN VARCHAR2,
    p_correo    IN VARCHAR2,
    p_direccion IN VARCHAR2
)
IS
BEGIN
    INSERT INTO proveedor (nombre, telefono, correo, direccion)
    VALUES (p_nombre, p_telefono, p_correo, p_direccion);
END sp_crear_proveedor;
/

--Ventas
CREATE OR REPLACE PROCEDURE sp_crear_venta (
    p_id_cliente IN  NUMBER,
    p_id_usuario IN  NUMBER,
    p_id_venta   OUT NUMBER
)
IS
BEGIN
    INSERT INTO venta (id_cliente, id_usuario)
    VALUES (p_id_cliente, p_id_usuario)
    RETURNING id_venta INTO p_id_venta;
END sp_crear_venta;
/

CREATE OR REPLACE PROCEDURE sp_agregar_detalle_venta (
    p_id_venta    IN NUMBER,
    p_id_producto IN NUMBER,
    p_cantidad    IN NUMBER
)
IS
    v_precio producto.precio_venta%TYPE;
BEGIN
    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        RAISE_APPLICATION_ERROR(-20020, 'La cantidad debe ser mayor a 0.');
    END IF;

    BEGIN
        SELECT precio_venta INTO v_precio
          FROM producto
         WHERE id_producto = p_id_producto;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20021, 'El producto ' || p_id_producto || ' no existe.');
    END;

    -- El trigger TRG_DETALLEVENTA_STOCK valida y descuenta el inventario
    INSERT INTO detalleventa (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (p_id_venta, p_id_producto, p_cantidad, v_precio);

    UPDATE venta
       SET total_venta = fn_total_venta(p_id_venta)
     WHERE id_venta = p_id_venta;
END sp_agregar_detalle_venta;
/

--Compras
CREATE OR REPLACE PROCEDURE sp_crear_compra (
    p_id_proveedor IN  NUMBER,
    p_id_compra    OUT NUMBER
)
IS
BEGIN
    INSERT INTO compra (id_proveedor)
    VALUES (p_id_proveedor)
    RETURNING id_compra INTO p_id_compra;
END sp_crear_compra;
/

CREATE OR REPLACE PROCEDURE sp_agregar_detalle_compra (
    p_id_compra       IN NUMBER,
    p_id_producto     IN NUMBER,
    p_cantidad        IN NUMBER,
    p_precio_unitario IN NUMBER
)
IS
BEGIN
    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        RAISE_APPLICATION_ERROR(-20030, 'La cantidad debe ser mayor a 0.');
    END IF;

    -- El trigger TRG_DETALLECOMPRA_STOCK suma las unidades al inventario
    INSERT INTO detallecompra (id_compra, id_producto, cantidad, precio_unitario)
    VALUES (p_id_compra, p_id_producto, p_cantidad, NVL(p_precio_unitario, 0));

    UPDATE compra
       SET total_compra = fn_total_compra(p_id_compra)
     WHERE id_compra = p_id_compra;
END sp_agregar_detalle_compra;

SELECT object_name, status FROM user_objects WHERE object_type = 'PROCEDURE' ORDER BY object_name;

--Triggerts 
CREATE OR REPLACE TRIGGER trg_detalleventa_stock
BEFORE INSERT ON detalleventa
FOR EACH ROW
DECLARE
    v_nombre producto.nombre%TYPE;
BEGIN
    UPDATE producto
       SET stock_actual = stock_actual - :NEW.cantidad
     WHERE id_producto = :NEW.id_producto
       AND stock_actual >= :NEW.cantidad;

    IF SQL%ROWCOUNT = 0 THEN
        BEGIN
            SELECT nombre INTO v_nombre
              FROM producto
             WHERE id_producto = :NEW.id_producto;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_nombre := 'ID ' || :NEW.id_producto;
        END;
        RAISE_APPLICATION_ERROR(-20001,
            'Stock insuficiente para: ' || v_nombre || ' (solicitado: ' || :NEW.cantidad || ')');
    END IF;
END trg_detalleventa_stock;
/
--Detalla compra
CREATE OR REPLACE TRIGGER trg_detallecompra_stock
AFTER INSERT ON detallecompra
FOR EACH ROW
BEGIN
    UPDATE producto
       SET stock_actual = stock_actual + :NEW.cantidad
     WHERE id_producto = :NEW.id_producto;
END trg_detallecompra_stock;
/
--Ventas registradas no se eliminan
CREATE OR REPLACE TRIGGER trg_venta_no_eliminar
BEFORE DELETE ON venta
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20003, 'Las ventas registradas no se pueden eliminar.');
END trg_venta_no_eliminar;
/
-- Verificacion
SELECT trigger_name, table_name, triggering_event, status FROM user_triggers ORDER BY trigger_name;

--Privilegios de usuario 
--Dev sobre tablas
GRANT SELECT, INSERT, UPDATE, DELETE ON categoria     TO ROL_DESARROLLADOR;
GRANT SELECT, INSERT, UPDATE, DELETE ON producto      TO ROL_DESARROLLADOR;
GRANT SELECT, INSERT, UPDATE, DELETE ON proveedor     TO ROL_DESARROLLADOR;
GRANT SELECT, INSERT, UPDATE, DELETE ON cliente       TO ROL_DESARROLLADOR;
GRANT SELECT, INSERT, UPDATE, DELETE ON usuario       TO ROL_DESARROLLADOR;
GRANT SELECT, INSERT, UPDATE, DELETE ON compra        TO ROL_DESARROLLADOR;
GRANT SELECT, INSERT, UPDATE, DELETE ON detallecompra TO ROL_DESARROLLADOR;
GRANT SELECT, INSERT, UPDATE, DELETE ON venta         TO ROL_DESARROLLADOR;
GRANT SELECT, INSERT, UPDATE, DELETE ON detalleventa  TO ROL_DESARROLLADOR;

GRANT SELECT ON v_ventas     TO ROL_DESARROLLADOR;
GRANT SELECT ON v_compras    TO ROL_DESARROLLADOR;
GRANT SELECT ON v_stock_bajo TO ROL_DESARROLLADOR;

GRANT EXECUTE ON sp_crear_producto         TO ROL_DESARROLLADOR;
GRANT EXECUTE ON sp_crear_cliente          TO ROL_DESARROLLADOR;
GRANT EXECUTE ON sp_crear_proveedor        TO ROL_DESARROLLADOR;
GRANT EXECUTE ON sp_crear_venta            TO ROL_DESARROLLADOR;
GRANT EXECUTE ON sp_agregar_detalle_venta  TO ROL_DESARROLLADOR;
GRANT EXECUTE ON sp_crear_compra           TO ROL_DESARROLLADOR;
GRANT EXECUTE ON sp_agregar_detalle_compra TO ROL_DESARROLLADOR;
GRANT EXECUTE ON fn_stock_disponible       TO ROL_DESARROLLADOR;
GRANT EXECUTE ON fn_total_venta            TO ROL_DESARROLLADOR;
GRANT EXECUTE ON fn_total_compra           TO ROL_DESARROLLADOR;


--Usuaruio final = Consultas
GRANT SELECT ON categoria    TO ROL_USUARIO_FINAL;
GRANT SELECT ON producto     TO ROL_USUARIO_FINAL;
GRANT SELECT ON proveedor    TO ROL_USUARIO_FINAL;
GRANT SELECT ON cliente      TO ROL_USUARIO_FINAL;
GRANT SELECT ON v_ventas     TO ROL_USUARIO_FINAL;
GRANT SELECT ON v_compras    TO ROL_USUARIO_FINAL;
GRANT SELECT ON v_stock_bajo TO ROL_USUARIO_FINAL;

GRANT EXECUTE ON sp_crear_producto         TO ROL_USUARIO_FINAL;
GRANT EXECUTE ON sp_crear_cliente          TO ROL_USUARIO_FINAL;
GRANT EXECUTE ON sp_crear_proveedor        TO ROL_USUARIO_FINAL;
GRANT EXECUTE ON sp_crear_venta            TO ROL_USUARIO_FINAL;
GRANT EXECUTE ON sp_agregar_detalle_venta  TO ROL_USUARIO_FINAL;
GRANT EXECUTE ON sp_crear_compra           TO ROL_USUARIO_FINAL;
GRANT EXECUTE ON sp_agregar_detalle_compra TO ROL_USUARIO_FINAL;
GRANT EXECUTE ON fn_stock_disponible       TO ROL_USUARIO_FINAL;

--Verificacion
SELECT grantee, table_name, privilege
  FROM user_tab_privs_made
 WHERE grantee IN ('ROL_DESARROLLADOR', 'ROL_USUARIO_FINAL')
 ORDER BY grantee, table_name, privilege;
 
 