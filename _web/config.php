<?php
declare(strict_types=1);
$config = [
    'demo_base_url' => getenv('TECEXPRESS_DEMO_URL') ?: 'https://tecexpress.tekoserver.cloud',
];
if (is_file(__DIR__ . '/config.local.php')) {
    $config = array_replace($config, require __DIR__ . '/config.local.php');
}
return $config;
