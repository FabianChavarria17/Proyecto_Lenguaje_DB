<?php
require_once __DIR__ . '/includes/header.php';
$msg = $err = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        crear_cliente(trim($_POST['nombre']), trim($_POST['telefono']), trim($_POST['correo']), trim($_POST['direccion']));
        $msg = 'Cliente creado.';
    } catch (Exception $e) { $err = $e->getMessage(); }
}
?>
<h2>Clientes</h2>
<?php if ($msg): ?><div class="msg ok"><?= h($msg) ?></div><?php endif; ?>
<?php if ($err): ?><div class="msg err"><?= h($err) ?></div><?php endif; ?>

<div class="card">
    <form method="post" class="grid">
        <div><label>Nombre</label><input name="nombre" required></div>
        <div><label>Teléfono</label><input name="telefono"></div>
        <div><label>Correo</label><input type="email" name="correo"></div>
        <div><label>Dirección</label><input name="direccion"></div>
        <div><button>Agregar cliente</button></div>
    </form>
</div>

<div class="card">
    <table>
        <tr><th>ID</th><th>Nombre</th><th>Teléfono</th><th>Correo</th><th>Dirección</th></tr>
        <?php foreach (get_clientes() as $c): ?>
            <tr>
                <td><?= h($c['id_cliente']) ?></td><td><?= h($c['nombre']) ?></td>
                <td><?= h($c['telefono']) ?></td><td><?= h($c['correo']) ?></td><td><?= h($c['direccion']) ?></td>
            </tr>
        <?php endforeach; ?>
    </table>
</div>
<?php require_once __DIR__ . '/includes/footer.php'; ?>
