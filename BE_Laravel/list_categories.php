<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Category;

$categories = Category::all();

echo "\n════════════════════════════════════\n";
echo "  DAFTAR KATEGORI\n";
echo "════════════════════════════════════\n\n";

foreach ($categories as $cat) {
    echo "ID: {$cat->id} | Nama: {$cat->name}\n";
}

echo "\n════════════════════════════════════\n";
echo "Total: {$categories->count()} kategori\n";
echo "════════════════════════════════════\n\n";
