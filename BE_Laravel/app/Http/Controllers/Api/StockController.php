<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\StockMovement;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class StockController extends Controller
{
    public function adjust(Request $request, $productId)
    {
        $product = Product::findOrFail($productId);

        $validated = $request->validate([
            'type' => 'required|in:in,out,adjust',
            'qty' => 'required|integer|min:1',
            'note' => 'nullable|string'
        ]);

        // Update product stock
        if ($validated['type'] === 'in') {
            $product->stock += $validated['qty'];
        } elseif ($validated['type'] === 'out') {
            if ($product->stock < $validated['qty']) {
                return response()->json(['error' => 'Stock tidak cukup'], 422);
            }
            $product->stock -= $validated['qty'];
        } else {
            // adjust → langsung set stok?
            // disini asumsi "adjust" = + atau - tergantung qty
        }

        $product->save();

        // record movement
        StockMovement::create([
            'product_id' => $product->id,
            'type' => $validated['type'],
            'qty' => $validated['qty'],
            'note' => $validated['note'] ?? null,
            'created_by' => Auth::user()?->id,
        ]);

        return response()->json([
            'success' => true,
            'new_stock' => $product->stock
        ]);
    }
}

