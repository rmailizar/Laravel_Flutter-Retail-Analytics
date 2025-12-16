<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\Transaction;
use App\Models\TransactionItem;
use App\Models\StockMovement;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class TransactionController extends Controller
{
    /**
     * Checkout cart (cash only)
     */
    public function checkout(Request $request, $code)
    {
        $request->validate([
            'cash_paid' => 'required|numeric|min:0'
        ]);

        $cart = Cart::where('code', $code)
            ->where('status', 'active')
            ->with('items.product')
            ->firstOrFail();

        if ($cart->items->isEmpty()) {
            return response()->json([
                'message' => 'Cart kosong'
            ], 422);
        }

        DB::beginTransaction();

        try {
            $total = 0;

            foreach ($cart->items as $item) {
                if ($item->product->stock < $item->qty) {
                    throw new \Exception("Stock {$item->product->name} tidak mencukupi");
                }
                $total += $item->qty * $item->price;
            }

            if ($request->cash_paid < $total) {
                return response()->json([
                    'message' => 'Uang tidak mencukupi'
                ], 422);
            }

            $transaction = Transaction::create([
                'invoice_number' => 'INV-' . date('Ymd') . '-' . strtoupper(Str::random(6)),
                'total_amount' => $total,
                'cash_paid' => $request->cash_paid,
                'change_amount' => $request->cash_paid - $total,
                'paid_at' => now(),
                'transaction_date' => now()
            ]);

            foreach ($cart->items as $item) {
                TransactionItem::create([
                    'transaction_id' => $transaction->id,
                    'product_id' => $item->product_id,
                    'qty' => $item->qty,
                    'price' => $item->price,
                    'subtotal' => $item->qty * $item->price
                ]);

                // Kurangi stok
                $item->product->decrement('stock', $item->qty);

                StockMovement::create([
                    'product_id' => $item->product_id,
                    'type' => 'out',
                    'qty' => $item->qty,
                    'note' => 'Penjualan ' . $transaction->invoice_number
                ]);
            }

            $cart->update(['status' => 'checked_out']);

            DB::commit();

            return response()->json([
                'success' => true,
                'transaction' => $transaction->load('items.product')
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
