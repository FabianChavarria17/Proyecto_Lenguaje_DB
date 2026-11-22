<?php
require_once __DIR__ . '/includes/header.php';
$msg = $err = '';
$productos = get_productos();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $items = [];
    foreach ($_POST['producto'] as $i => $idp) {
        $cant = (int)($_POST['cantidad'][$i] ?? 0);
        if ($idp !== '' && $cant > 0) {
            $items[] = ['id_producto' => (int)$idp, 'cantidad' => $cant];
        }
    }
    try {
        if (!$items) { throw new Exception('Agregue al menos un producto con cantidad mayor a 0.'); }
        $id = registrar_venta((int)$_POST['id_cliente'], $items);
        $msg = "Venta #$id registrada correctamente.";
        $productos = get_productos();
    } catch (Exception $e) {
        $err = 'No se pudo registrar la venta (se hizo ROLLBACK): ' . $e->getMessage();
    }
}
?>
<h2>Ventas</h2>
<?php if ($msg): ?><div class="msg ok"><?= h($msg) ?></div><?php endif; ?>
<?php if ($err): ?><div class="msg err"><?= h($err) ?></div><?php endif; ?>

<div class="card">
    <h3>Nueva venta</h3>
    <form method="post">
        <label>Cliente</label>
        <select name="id_cliente" style="max-width:360px;margin-bottom:14px">
            <?php foreach (get_clientes() as $c): ?>
                <option value="<?= h($c['id_cliente']) ?>"><?= h($c['nombre']) ?></option>
            <?php endforeach; ?>
        </select>

        <?php for ($i = 0; $i < 3; $i++): ?>
            <div class="linea">
                <div><label>Producto</label>
                    <select name="producto[]">
                        <option value="">-- seleccione --</option>
                        <?php foreach ($productos as $p): ?>
                            <option value="<?= h($p['id_producto']) ?>">
                                <?= h($p['nombre']) ?> (stock: <?= h($p['stock_actual']) ?>)
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div><label>Cantidad</label><input type="number" name="cantidad[]" min="0" value="0"></div>
                <div></div><div></div>
            </div>
        <?php endfor; ?>
        <button>Registrar venta</button>
        <p class="small">Para probar atomicidad: pida más cantidad que el stock disponible y verifique que no cambia nada.</p>
    </form>
</div>

<div class="card">
    <h3>Historial</h3>
    <table>
        <tr><th>#</th><th>Fecha</th><th>Cliente</th><th>Usuario</th><th>Total</th></tr>
        <?php foreach (get_ventas() as $v): ?>
            <tr>
                <td><?= h($v['id_venta']) ?></td><td><?= h($v['fecha_venta']) ?></td>
                <td><?= h($v['cliente']) ?></td><td><?= h($v['usuario']) ?></td>
                <td><?= colones($v['total_venta']) ?></td>
            </tr>
        <?php endforeach; ?>
    </table>
</div>
<?php require_once __DIR__ . '/includes/footer.php'; ?>
