<?php require_once __DIR__ . '/db.php'; ?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= h(APP_NAME) ?></title>
    <link rel="stylesheet" href="assets/style.css">
</head>
<body>
<header>
    <h1>🔧 Ferretería</h1>
    <nav>
        <a href="index.php">Inicio</a>
        <a href="productos.php">Productos</a>
        <a href="clientes.php">Clientes</a>
        <a href="proveedores.php">Proveedores</a>
        <a href="ventas.php">Ventas</a>
        <a href="compras.php">Compras</a>
    </nav>
    <?php if (DEMO_MODE): ?>
        <span class="badge demo">MODO DEMO</span>
    <?php else: ?>
        <span class="badge oracle">Oracle</span>
    <?php endif; ?>
</header>
<main>
