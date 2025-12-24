<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     *
     * Adds a nullable, unique `barcode` column to `products`.
     * Making it nullable prevents migration failures on existing rows.
     * You can populate barcodes afterwards and make the column non-nullable
     * with another migration if needed.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('products', function (Blueprint $table) {
            if (!Schema::hasColumn('products', 'barcode')) {
                $table->string('barcode')->unique()->nullable()->after('sku');
            }
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('products', function (Blueprint $table) {
            if (Schema::hasColumn('products', 'barcode')) {
                $table->dropColumn('barcode');
            }
        });
    }
};
