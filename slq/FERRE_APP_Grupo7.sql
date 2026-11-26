--Tests user final
--Conectar con Ferre_app

SET SERVEROUTPUT ON
SET DEFINE OFF
ALTER SESSION SET CURRENT_SCHEMA = FERRE_OWNER;

--Consultar productos 
SELECT id_producto, nombre, stock_actual FROM producto;

--User final NO debe poder eliminar o editar tabalas 
DELETE FROM producto WHERE id_producto = 1;
UPDATE producto SET precio_venta = 1 WHERE id_producto = 1;

--User no puede ver passwords
SELECT * FROM usuario;

--No puede modificar estructura
DROP TABLE producto;

--Si puede operar a travez de procedimientos 
DECLARE
    v_id_venta NUMBER;
BEGIN
    sp_crear_venta(2, 1, v_id_venta);
    sp_agregar_detalle_venta(v_id_venta, 3, 5);   -- 5 metros de cable
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Venta #' || v_id_venta || ' registrada por FERRE_APP. Stock cable: ' ||
                         fn_stock_disponible(3));
END;
/


