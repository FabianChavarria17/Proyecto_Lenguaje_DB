<?php
require_once __DIR__ . '/includes/header.php';
$msg = $err = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        crear_proveedor(trim($_POST['nombre']), trim($_POST['telefono']), trim($_POST['correo']), trim($_POST['direccion']));
        $msg = 'Proveedor creado.';
    } catch (Exception $e) { $err = $e->getMessage(); }
}
?>
<h2>Proveedores</h2>
<?php if ($msg): ?><div class="msg ok"><?= h($msg) ?></div><?php endif; ?>
<?php if ($err): ?><div class="msg err"><?= h($err) ?></div><?php endif; ?>

<div class="card">
    <form method="post" class="grid">
        <div><label>Nombre</label><input name="nombre" required></div>
        <div><label>Teléfono</label><input name="telefono"></div>
        <div><label>Correo</label><input type="email" name="correo"></div>
        <div><label>Dirección</label><input name="direccion"></div>
        <div><button>Agregar proveedor</button></div>
    </form>
</div>

<div class="card">
    <table>
        <tr><th>ID</th><th>Nombre</th><th>Teléfono</th><th>Correo</th><th>Dirección</th></tr>
        <?php foreach (get_proveedores() as $p): ?>
            <tr>
                <td><?= h($p['id_proveedor']) ?></td><td><?= h($p['nombre']) ?></td>
                <td><?= h($p['telefono']) ?></td><td><?= h($p['correo']) ?></td><td><?= h($p['direccion']) ?></td>
            </tr>
        <?php endforeach; ?>
    </table>
</div>
<?php require_once __DIR__ . '/includes/footer.php'; ?>
