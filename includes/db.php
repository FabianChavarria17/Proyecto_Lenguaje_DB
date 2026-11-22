<?php

require_once __DIR__ . '/../config/config.php';

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Conexión a base de daots 
function db_connect()
{
    static $conn = null;
    if ($conn) {
        return $conn;
    }
    if (!function_exists('oci_connect')) {
        die('La extensión oci8 no está habilitada en PHP. Active DEMO_MODE o instale oci8.');
    }
    $conn = @oci_connect(DB_USER, DB_PASS, DB_CONN, 'AL32UTF8');
    if (!$conn) {
        $e = oci_error();
        die('Error de conexión a Oracle: ' . htmlspecialchars($e['message']));
    }
    return $conn;
}
function db_select($sql, $params = [])
{
    $conn = db_connect();
    $st = oci_parse($conn, $sql);
    foreach ($params as $k => $v) {
        oci_bind_by_name($st, ':' . $k, $params[$k]);
    }
    if (!@oci_execute($st)) {
        $e = oci_error($st);
        throw new Exception($e['message']);
    }
    $rows = [];
    while ($r = oci_fetch_assoc($st)) {
        $rows[] = array_change_key_case($r, CASE_LOWER);
    }
    return $rows;
}

function demo_init()
{
    if (isset($_SESSION['demo'])) {
        return;
    }
    $_SESSION['demo'] = [
        'categorias' => [
            ['id_categoria' => 1, 'nombre' => 'Herramientas manuales', 'descripcion' => 'Martillos, alicates, destornilladores'],
            ['id_categoria' => 2, 'nombre' => 'Eléctricos', 'descripcion' => 'Cables, tomas, breakers'],
            ['id_categoria' => 3, 'nombre' => 'Pinturas', 'descripcion' => 'Pinturas y accesorios'],
        ],
        'productos' => [
            ['id_producto' => 1, 'nombre' => 'Martillo 16oz', 'descripcion' => 'Mango de fibra', 'precio_venta' => 6500, 'stock_actual' => 25, 'stock_minimo' => 5, 'id_categoria' => 1],
            ['id_producto' => 2, 'nombre' => 'Destornillador Phillips', 'descripcion' => 'Punta #2', 'precio_venta' => 2200, 'stock_actual' => 3, 'stock_minimo' => 8, 'id_categoria' => 1],
            ['id_producto' => 3, 'nombre' => 'Cable THHN #12 (m)', 'descripcion' => 'Cobre, por metro', 'precio_venta' => 950, 'stock_actual' => 120, 'stock_minimo' => 30, 'id_categoria' => 2],
            ['id_producto' => 4, 'nombre' => 'Pintura blanca 1 gal', 'descripcion' => 'Látex interior', 'precio_venta' => 18500, 'stock_actual' => 12, 'stock_minimo' => 4, 'id_categoria' => 3],
        ],
        'proveedores' => [
            ['id_proveedor' => 1, 'nombre' => 'Distribuidora Tica S.A.', 'telefono' => '2222-1111', 'correo' => 'ventas@distica.cr', 'direccion' => 'San José'],
            ['id_proveedor' => 2, 'nombre' => 'Eléctricos del Norte', 'telefono' => '2444-3333', 'correo' => 'info@elecnorte.cr', 'direccion' => 'Alajuela'],
        ],
        'clientes' => [
            ['id_cliente' => 1, 'nombre' => 'Cliente Mostrador', 'telefono' => '', 'correo' => '', 'direccion' => ''],
            ['id_cliente' => 2, 'nombre' => 'Constructora Pérez', 'telefono' => '8888-0000', 'correo' => 'compras@perez.cr', 'direccion' => 'Heredia'],
        ],
        'ventas' => [],
        'compras' => [],
        'sig_venta' => 1,
        'sig_compra' => 1,
    ];
}
function &demo()
{
    demo_init();
    return $_SESSION['demo'];
}

function nombre_por_id($lista, $campo, $id)
{
    foreach ($lista as $x) {
        if ($x[$campo] == $id) {
            return $x['nombre'];
        }
    }
    return '?';
}


function get_categorias()
{
    if (DEMO_MODE) { return demo()['categorias']; }
    return db_select('SELECT id_categoria, nombre, descripcion FROM categoria ORDER BY nombre');
}

function get_productos()
{
    if (DEMO_MODE) {
        $d = demo();
        foreach ($d['productos'] as &$p) {
            $p['categoria'] = nombre_por_id($d['categorias'], 'id_categoria', $p['id_categoria']);
        }
        return $d['productos'];
    }
    return db_select('SELECT p.id_producto, p.nombre, p.descripcion, p.precio_venta, p.stock_actual,
                             p.stock_minimo, p.id_categoria, c.nombre AS categoria
                        FROM producto p JOIN categoria c ON c.id_categoria = p.id_categoria
                       ORDER BY p.nombre');
}

function get_proveedores()
{
    if (DEMO_MODE) { return demo()['proveedores']; }
    return db_select('SELECT id_proveedor, nombre, telefono, correo, direccion FROM proveedor ORDER BY nombre');
}

function get_clientes()
{
    if (DEMO_MODE) { return demo()['clientes']; }
    return db_select('SELECT id_cliente, nombre, telefono, correo, direccion FROM cliente ORDER BY nombre');
}

function get_ventas()
{
    if (DEMO_MODE) { return array_reverse(demo()['ventas']); }
    return db_select("SELECT v.id_venta, TO_CHAR(v.fecha_venta,'YYYY-MM-DD HH24:MI') AS fecha_venta,
                             v.total_venta, c.nombre AS cliente, u.nombre AS usuario
                        FROM venta v
                        JOIN cliente c ON c.id_cliente = v.id_cliente
                        JOIN usuario u ON u.id_usuario = v.id_usuario
                       ORDER BY v.id_venta DESC");
}

function get_compras()
{
    if (DEMO_MODE) { return array_reverse(demo()['compras']); }
    return db_select("SELECT c.id_compra, TO_CHAR(c.fecha_compra,'YYYY-MM-DD HH24:MI') AS fecha_compra,
                             c.total_compra, p.nombre AS proveedor
                        FROM compra c JOIN proveedor p ON p.id_proveedor = c.id_proveedor
                       ORDER BY c.id_compra DESC");
}


function crear_producto($nombre, $desc, $precio, $stock_min, $id_categoria)
{
    if (DEMO_MODE) {
        $d = &demo();
        $d['productos'][] = ['id_producto' => count($d['productos']) + 1, 'nombre' => $nombre,
            'descripcion' => $desc, 'precio_venta' => $precio, 'stock_actual' => 0,
            'stock_minimo' => $stock_min, 'id_categoria' => $id_categoria];
        return;
    }
    
    $conn = db_connect();
    $st = oci_parse($conn, 'BEGIN SP_CREAR_PRODUCTO(:n, :d, :p, :m, :c); END;');
    oci_bind_by_name($st, ':n', $nombre);
    oci_bind_by_name($st, ':d', $desc);
    oci_bind_by_name($st, ':p', $precio);
    oci_bind_by_name($st, ':m', $stock_min);
    oci_bind_by_name($st, ':c', $id_categoria);
    if (!@oci_execute($st)) { $e = oci_error($st); throw new Exception($e['message']); }
}

function crear_cliente($nombre, $tel, $correo, $dir)
{
    if (DEMO_MODE) {
        $d = &demo();
        $d['clientes'][] = ['id_cliente' => count($d['clientes']) + 1, 'nombre' => $nombre,
            'telefono' => $tel, 'correo' => $correo, 'direccion' => $dir];
        return;
    }
    // TODO-SQL
    $conn = db_connect();
    $st = oci_parse($conn, 'BEGIN SP_CREAR_CLIENTE(:n, :t, :c, :d); END;');
    oci_bind_by_name($st, ':n', $nombre);
    oci_bind_by_name($st, ':t', $tel);
    oci_bind_by_name($st, ':c', $correo);
    oci_bind_by_name($st, ':d', $dir);
    if (!@oci_execute($st)) { $e = oci_error($st); throw new Exception($e['message']); }
}

function crear_proveedor($nombre, $tel, $correo, $dir)
{
    if (DEMO_MODE) {
        $d = &demo();
        $d['proveedores'][] = ['id_proveedor' => count($d['proveedores']) + 1, 'nombre' => $nombre,
            'telefono' => $tel, 'correo' => $correo, 'direccion' => $dir];
        return;
    }
    // TODO-SQL
    $conn = db_connect();
    $st = oci_parse($conn, 'BEGIN SP_CREAR_PROVEEDOR(:n, :t, :c, :d); END;');
    oci_bind_by_name($st, ':n', $nombre);
    oci_bind_by_name($st, ':t', $tel);
    oci_bind_by_name($st, ':c', $correo);
    oci_bind_by_name($st, ':d', $dir);
    if (!@oci_execute($st)) { $e = oci_error($st); throw new Exception($e['message']); }
}


function registrar_venta($id_cliente, $items)
{
    if (DEMO_MODE) {
        $d = &demo();
        $total = 0;
        $detalle = [];
        foreach ($items as $it) {
            foreach ($d['productos'] as $p) {
                if ($p['id_producto'] == $it['id_producto']) {
                    if ($p['stock_actual'] < $it['cantidad']) {
                        throw new Exception('Stock insuficiente para: ' . $p['nombre']);
                    }
                    $total += $p['precio_venta'] * $it['cantidad'];
                    $detalle[] = [$p['id_producto'], $it['cantidad'], $p['precio_venta']];
                }
            }
        }
        foreach ($detalle as $x) {
            foreach ($d['productos'] as &$p) {
                if ($p['id_producto'] == $x[0]) { $p['stock_actual'] -= $x[1]; }
            }
            unset($p);
        }
        $id = $d['sig_venta']++;
        $d['ventas'][] = ['id_venta' => $id, 'fecha_venta' => date('Y-m-d H:i'), 'total_venta' => $total,
            'cliente' => nombre_por_id($d['clientes'], 'id_cliente', $id_cliente), 'usuario' => 'Admin'];
        return $id;
    }

    $conn = db_connect();
    try {
       
        $st = oci_parse($conn, 'BEGIN SP_CREAR_VENTA(:cli, :usr, :idv); END;');
        $usr = ID_USUARIO_ACTUAL;
        $idv = 0;
        oci_bind_by_name($st, ':cli', $id_cliente);
        oci_bind_by_name($st, ':usr', $usr);
        oci_bind_by_name($st, ':idv', $idv, 32);
        if (!@oci_execute($st, OCI_NO_AUTO_COMMIT)) { $e = oci_error($st); throw new Exception($e['message']); }

        foreach ($items as $it) {
            $st = oci_parse($conn, 'BEGIN SP_AGREGAR_DETALLE_VENTA(:idv, :prod, :cant); END;');
            oci_bind_by_name($st, ':idv', $idv);
            oci_bind_by_name($st, ':prod', $it['id_producto']);
            oci_bind_by_name($st, ':cant', $it['cantidad']);
            if (!@oci_execute($st, OCI_NO_AUTO_COMMIT)) { $e = oci_error($st); throw new Exception($e['message']); }
        }
        oci_commit($conn);
        return $idv;
    } catch (Exception $ex) {
        oci_rollback($conn);
        throw $ex;
    }
}

function registrar_compra($id_proveedor, $items)
{
    if (DEMO_MODE) {
        $d = &demo();
        $total = 0;
        foreach ($items as $it) {
            foreach ($d['productos'] as &$p) {
                if ($p['id_producto'] == $it['id_producto']) {
                    $p['stock_actual'] += $it['cantidad'];
                    $total += $it['precio_unitario'] * $it['cantidad'];
                }
            }
            unset($p);
        }
        $id = $d['sig_compra']++;
        $d['compras'][] = ['id_compra' => $id, 'fecha_compra' => date('Y-m-d H:i'), 'total_compra' => $total,
            'proveedor' => nombre_por_id($d['proveedores'], 'id_proveedor', $id_proveedor)];
        return $id;
    }

    $conn = db_connect();
    try {
        $st = oci_parse($conn, 'BEGIN SP_CREAR_COMPRA(:prov, :idc); END;');
        $idc = 0;
        oci_bind_by_name($st, ':prov', $id_proveedor);
        oci_bind_by_name($st, ':idc', $idc, 32);
        if (!@oci_execute($st, OCI_NO_AUTO_COMMIT)) { $e = oci_error($st); throw new Exception($e['message']); }

        foreach ($items as $it) {
            $st = oci_parse($conn, 'BEGIN SP_AGREGAR_DETALLE_COMPRA(:idc, :prod, :cant, :precio); END;');
            oci_bind_by_name($st, ':idc', $idc);
            oci_bind_by_name($st, ':prod', $it['id_producto']);
            oci_bind_by_name($st, ':cant', $it['cantidad']);
            oci_bind_by_name($st, ':precio', $it['precio_unitario']);
            if (!@oci_execute($st, OCI_NO_AUTO_COMMIT)) { $e = oci_error($st); throw new Exception($e['message']); }
        }
        oci_commit($conn);
        return $idc;
    } catch (Exception $ex) {
        oci_rollback($conn);
        throw $ex;
    }
}

function h($s)
{
    return htmlspecialchars((string)$s, ENT_QUOTES, 'UTF-8');
}
function colones($n)
{
    return '₡' . number_format((float)$n, 0, ',', '.');
}
