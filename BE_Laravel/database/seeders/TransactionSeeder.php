<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Transaction;
use App\Models\TransactionItem;
use App\Models\Product;
use App\Models\StockMovement;
use Carbon\Carbon;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;

class TransactionSeeder extends Seeder
{
    public function run(): void
    {
        DB::beginTransaction();

        try {
            $products = Product::whereBetween('id', [1, 9])->get();
            if ($products->count() < 3) {
                throw new \Exception('Minimal 3 produk dibutuhkan');
            }

            $startDate = Carbon::now()->subDays(7);

            for ($i = 0; $i < 14; $i++) {
                $date = $startDate->copy()->addDays($i)->setTime(12, 0);

                // Pilih produk random (beda tiap transaksi)
                $items = $products->shuffle()->take(rand(2, 4));

                $total = 0;

                $transaction = Transaction::create([
                    'invoice_number' => 'INV-' . $date->format('Ymd') . '-' . strtoupper(Str::random(6)),
                    'transaction_date' => $date,
                    'paid_at' => $date,
                    'total_amount' => 0, // update setelah item
                    'cash_paid' => 0,
                    'change_amount' => 0,
                    'cashier_id' => 1, // pastikan user ID 1 ada
                ]);

                foreach ($items as $product) {
                    $qty = rand(1, 3);
                    $subtotal = $qty * $product->sell_price;
                    $total += $subtotal;

                    TransactionItem::create([
                        'transaction_id' => $transaction->id,
                        'product_id' => $product->id,
                        'qty' => $qty,
                        'price' => $product->sell_price,
                        'subtotal' => $subtotal,
                    ]);

                    // Kurangi stok (opsional, bisa dihapus jika cuma dummy)
                    $product->decrement('stock', $qty);

                    StockMovement::create([
                        'product_id' => $product->id,
                        'type' => 'out',
                        'qty' => $qty,
                        'note' => 'Seeder ' . $transaction->invoice_number,
                    ]);
                }

                $transaction->update([
                    'total_amount' => $total,
                    'cash_paid' => $total + rand(0, 50000),
                    'change_amount' => rand(0, 50000),
                ]);
            }

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }
}
