--Pruebas del user Dev 
--Conectar con Ferre_dev

SET SERVEROUTPUT ON
SET DEFINE OFF
ALTER SESSION SET CURRENT_SCHEMA = FERRE_OWNER;

--Test aumentar stock
DECLARE
    v_id_compra NUMBER;
    v_antes     NUMBER;
    v_despues   NUMBER;
BEGIN
    v_antes := fn_stock_disponible(1);
    sp_crear_compra(1, v_id_compra);
    sp_agregar_detalle_compra(v_id_compra, 1, 10, 4000);
    COMMIT;
    v_despues := fn_stock_disponible(1);
    DBMS_OUTPUT.PUT_LINE('PRUEBA 1 | Compra #' || v_id_compra || ' | stock antes: ' || v_antes ||
                         ' | después: ' || v_despues || ' | esperado: +10');
END;
/

--Test 2 venta - stock 
DECLARE
    v_id_venta NUMBER;
    v_antes    NUMBER;
    v_despues  NUMBER;
    v_total    NUMBER;
BEGIN
    v_antes := fn_stock_disponible(1);
    sp_crear_venta(1, 1, v_id_venta);
    sp_agregar_detalle_venta(v_id_venta, 1, 2);   -- 2 martillos a 6500
    COMMIT;
    v_despues := fn_stock_disponible(1);
    SELECT total_venta INTO v_total FROM venta WHERE id_venta = v_id_venta;
    DBMS_OUTPUT.PUT_LINE('PRUEBA 2 | Venta #' || v_id_venta || ' | stock antes: ' || v_antes ||
                         ' | después: ' || v_despues || ' | esperado: -2 | total: ' || v_total ||
                         ' | esperado: 13000');
END;
/


--Test 3 Con venta pide mas stock faltante 
DECLARE
    v_id_venta   NUMBER;
    v_stock1_ini NUMBER;
    v_stock1_fin NUMBER;
    v_ventas_ini NUMBER;
    v_ventas_fin NUMBER;
BEGIN
    v_stock1_ini := fn_stock_disponible(1);
    SELECT COUNT(*) INTO v_ventas_ini FROM venta;
    BEGIN
        sp_crear_venta(1, 1, v_id_venta);
        sp_agregar_detalle_venta(v_id_venta, 1, 1);     -- válida
        sp_agregar_detalle_venta(v_id_venta, 2, 999);   -- stock insuficiente -> ORA-20001
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('PRUEBA 3 | Error esperado capturado: ' || SQLERRM);
    END;
    v_stock1_fin := fn_stock_disponible(1);
    SELECT COUNT(*) INTO v_ventas_fin FROM venta;
    DBMS_OUTPUT.PUT_LINE('PRUEBA 3 | stock producto 1: ' || v_stock1_ini || ' -> ' || v_stock1_fin ||
                         ' | ventas: ' || v_ventas_ini || ' -> ' || v_ventas_fin ||
                         ' | esperado: sin cambios');
END;
/
--Tets 4 consistencia 
BEGIN
    UPDATE producto SET stock_actual = -5 WHERE id_producto = 1;
    DBMS_OUTPUT.PUT_LINE('PRUEBA 4 | ERROR: se permitió stock negativo');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('PRUEBA 4 | Rechazado correctamente: ' || SQLERRM);
END;
/


--Test 5 trigger que no deja eliminar ventas 
BEGIN
    DELETE FROM venta WHERE id_venta = 1;
    DBMS_OUTPUT.PUT_LINE('PRUEBA 5 | ERROR: se permitió eliminar una venta');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('PRUEBA 5 | Rechazado correctamente: ' || SQLERRM);
END;
/

--VerificacionFinal
SELECT id_producto, nombre, stock_actual, stock_minimo FROM producto ORDER BY id_producto;
SELECT * FROM v_ventas  ORDER BY id_venta;
SELECT * FROM v_compras ORDER BY id_compra;
