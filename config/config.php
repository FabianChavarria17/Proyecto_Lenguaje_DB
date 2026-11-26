<?php
// true  = NO se conecta a Oracle, usa datos de ejemplo (para ver la interfaz)
// false = se conecta a Oracle con los datos de abajo
define('DEMO_MODE', false);

// Credenciales del usuario de aplicación (usuario final, NO el dueño de tablas)
define('DB_USER', 'FERRE_APP');
define('DB_PASS', 'App_Ferre2026');

// Formato: host:puerto/servicio  (en Oracle XE normalmente XEPDB1)
define('DB_CONN', 'localhost:1521/XEPDB1');

define('DB_SCHEMA', 'FERRE_OWNER');

// Usuario del sistema que registra las ventas/compras (luego se reemplaza por login)
define('ID_USUARIO_ACTUAL', 1);

define('APP_NAME', 'Ferretería - Sistema Transaccional');
