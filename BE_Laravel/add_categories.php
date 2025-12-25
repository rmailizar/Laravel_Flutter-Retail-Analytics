<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Category;

// Add categories
$categories = [
    'Makanan',
    'Minuman',
    'Elektronik',
    'Pakaian',
    'Peralatan Rumah Tangga',
];

foreach ($categories as $category) {
    $exists = Category::where('name', $category)->exists();
    if (!$exists) {
        Category::create(['name' => $category]);
        echo "✅ Kategori '$category' berhasil ditambahkan\n";
    } else {
        echo "⚠️  Kategori '$category' sudah ada\n";
    }
}

echo "\n✅ Selesai!\n";
