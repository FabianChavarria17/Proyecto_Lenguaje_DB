<?php
require_once __DIR__ . '/includes/header.php';
$msg = $err = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        crear_producto(trim($_POST['nombre']), trim($_POST['descripcion']), (float)$_POST['precio_venta'],
            (int)$_POST['stock_minimo'], (int)$_POST['id_categoria']);
        $msg = 'Producto creado.';
    } catch (Exception $e) { $err = $e->getMessage(); }
}
?>
<h2>Productos</h2>
<?php if ($msg): ?><div class="msg ok"><?= h($msg) ?></div><?php endif; ?>
<?php if ($err): ?><div class="msg err"><?= h($err) ?></div><?php endif; ?>

<div class="card">
    <form method="post" class="grid">
        <div><label>Nombre</label><input name="nombre" required></div>
        <div><label>Descripción</label><input name="descripcion"></div>
        <div><label>Precio venta</label><input type="number" step="0.01" min="0" name="precio_venta" required></div>
        <div><label>Stock mínimo</label><input type="number" min="0" name="stock_minimo" value="0" required></div>
        <div><label>Categoría</label>
            <select name="id_categoria">
                <?php foreach (get_categorias() as $c): ?>
                    <option value="<?= h($c['id_categoria']) ?>"><?= h($c['nombre']) ?></option>
                <?php endforeach; ?>
            </select>
        </div>
        <div><button>Agregar producto</button></div>
    </form>
</div>

<div class="card">
    <table>
        <tr><th>ID</th><th>Nombre</th><th>Categoría</th><th>Precio</th><th>Stock</th><th>Mínimo</th></tr>
        <?php foreach (get_productos() as $p): ?>
            <tr class="<?= $p['stock_actual'] <= $p['stock_minimo'] ? 'bajo' : '' ?>">
                <td><?= h($p['id_producto']) ?></td>
                <td><?= h($p['nombre']) ?></td>
                <td><?= h($p['categoria']) ?></td>
                <td><?= colones($p['precio_venta']) ?></td>
                <td><?= h($p['stock_actual']) ?></td>
                <td><?= h($p['stock_minimo']) ?></td>
            </tr>
        <?php endforeach; ?>
    </table>
    <p class="small">Las filas en rojo tienen stock igual o menor al mínimo.</p>
</div>
<?php require_once __DIR__ . '/includes/footer.php'; ?>
