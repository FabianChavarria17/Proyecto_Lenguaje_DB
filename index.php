<?php
require_once __DIR__ . '/includes/header.php';
$productos = get_productos();
$bajos = array_filter($productos, function ($p) { return $p['stock_actual'] <= $p['stock_minimo']; });
?>
<h2>Panel principal</h2>
<div class="tiles">
    <a class="tile" href="productos.php"><b><?= count($productos) ?></b>Productos</a>
    <a class="tile" href="clientes.php"><b><?= count(get_clientes()) ?></b>Clientes</a>
    <a class="tile" href="proveedores.php"><b><?= count(get_proveedores()) ?></b>Proveedores</a>
    <a class="tile" href="productos.php"><b><?= count($bajos) ?></b>Productos con stock bajo</a>
    <a class="tile" href="ventas.php"><b><?= count(get_ventas()) ?></b>Ventas</a>
    <a class="tile" href="compras.php"><b><?= count(get_compras()) ?></b>Compras</a>
</div>
<?php require_once __DIR__ . '/includes/footer.php'; ?>
