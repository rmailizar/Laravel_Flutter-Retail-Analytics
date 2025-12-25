<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Category;

// Cek ID 1-3
$categories = Category::whereIn('id', [1, 2, 3])->get();

echo "\n════════════════════════════════════\n";
echo "  CEK ID 1-3\n";
echo "════════════════════════════════════\n\n";

if ($categories->isEmpty()) {
    echo "❌ ID 1-3 tidak ditemukan di database\n";
} else {
    foreach ($categories as $cat) {
        echo "ID: {$cat->id} | Nama: {$cat->name}\n";
    }
}

echo "\n(Mungkin sudah dihapus atau belum pernah dibuat)\n\n";
