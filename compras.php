<?php
require_once __DIR__ . '/includes/header.php';
$msg = $err = '';
$productos = get_productos();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $items = [];
    foreach ($_POST['producto'] as $i => $idp) {
        $cant = (int)($_POST['cantidad'][$i] ?? 0);
        $precio = (float)($_POST['precio'][$i] ?? 0);
        if ($idp !== '' && $cant > 0) {
            $items[] = ['id_producto' => (int)$idp, 'cantidad' => $cant, 'precio_unitario' => $precio];
        }
    }
    try {
        if (!$items) { throw new Exception('Agregue al menos un producto con cantidad mayor a 0.'); }
        $id = registrar_compra((int)$_POST['id_proveedor'], $items);
        $msg = "Compra #$id registrada correctamente.";
        $productos = get_productos();
    } catch (Exception $e) {
        $err = 'No se pudo registrar la compra (se hizo ROLLBACK): ' . $e->getMessage();
    }
}
?>
<h2>Compras a proveedores</h2>
<?php if ($msg): ?><div class="msg ok"><?= h($msg) ?></div><?php endif; ?>
<?php if ($err): ?><div class="msg err"><?= h($err) ?></div><?php endif; ?>

<div class="card">
    <h3>Nueva compra</h3>
    <form method="post">
        <label>Proveedor</label>
        <select name="id_proveedor" style="max-width:360px;margin-bottom:14px">
            <?php foreach (get_proveedores() as $p): ?>
                <option value="<?= h($p['id_proveedor']) ?>"><?= h($p['nombre']) ?></option>
            <?php endforeach; ?>
        </select>

        <?php for ($i = 0; $i < 3; $i++): ?>
            <div class="linea compra">
                <div><label>Producto</label>
                    <select name="producto[]">
                        <option value="">-- seleccione --</option>
                        <?php foreach ($productos as $p): ?>
                            <option value="<?= h($p['id_producto']) ?>"><?= h($p['nombre']) ?> (stock: <?= h($p['stock_actual']) ?>)</option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div><label>Cantidad</label><input type="number" name="cantidad[]" min="0" value="0"></div>
                <div><label>Precio unitario</label><input type="number" step="0.01" min="0" name="precio[]" value="0"></div>
                <div></div>
            </div>
        <?php endfor; ?>
        <button>Registrar compra</button>
    </form>
</div>

<div class="card">
    <h3>Historial</h3>
    <table>
        <tr><th>#</th><th>Fecha</th><th>Proveedor</th><th>Total</th></tr>
        <?php foreach (get_compras() as $c): ?>
            <tr>
                <td><?= h($c['id_compra']) ?></td><td><?= h($c['fecha_compra']) ?></td>
                <td><?= h($c['proveedor']) ?></td><td><?= colones($c['total_compra']) ?></td>
            </tr>
        <?php endforeach; ?>
    </table>
</div>
<?php require_once __DIR__ . '/includes/footer.php'; ?>
