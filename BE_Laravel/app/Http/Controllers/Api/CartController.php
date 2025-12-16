<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class CartController extends Controller
{
    /**
     * Create cart baru
     */
    public function create()
    {
        $cart = Cart::create([
            'code' => 'CART-' . strtoupper(Str::random(8)),
            'status' => 'active'
        ]);

        return response()->json([
            'success' => true,
            'data' => $cart
        ], 201);
    }

    /**
     * Lihat isi cart
     */
    public function show($code)
    {
        $cart = Cart::where('code', $code)
            ->with('items.product')
            ->firstOrFail();

        return response()->json($cart);
    }

    /**
     * Tambah item (hasil scan barcode / SKU)
     */
    public function addItem(Request $request, $code)
    {
        $request->validate([
            'sku' => 'required',
            'qty' => 'nullable|integer|min:1'
        ]);

        $cart = Cart::where('code', $code)
            ->where('status', 'active')
            ->firstOrFail();

        $product = Product::where('sku', $request->sku)->firstOrFail();

        $qty = $request->qty ?? 1;

        if ($product->stock < $qty) {
            return response()->json([
                'message' => 'Stock tidak mencukupi'
            ], 422);
        }

        $item = CartItem::where('cart_id', $cart->id)
            ->where('product_id', $product->id)
            ->first();

        if ($item) {
            $item->update([
                'qty' => $item->qty + $qty
            ]);
        } else {
            CartItem::create([
                'cart_id' => $cart->id,
                'product_id' => $product->id,
                'qty' => $qty,
                'price' => $product->sell_price
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Produk ditambahkan ke cart'
        ]);
    }

    /**
     * Update qty item
     */
    public function updateItem(Request $request, $code, $itemId)
    {
        $request->validate([
            'qty' => 'required|integer|min:1'
        ]);

        $cart = Cart::where('code', $code)
            ->where('status', 'active')
            ->firstOrFail();

        $item = CartItem::where('id', $itemId)
            ->where('cart_id', $cart->id)
            ->firstOrFail();

        if ($item->product->stock < $request->qty) {
            return response()->json([
                'message' => 'Stock tidak mencukupi'
            ], 422);
        }

        $item->update(['qty' => $request->qty]);

        return response()->json(['success' => true]);
    }

    /**
     * Hapus item dari cart
     */
    public function removeItem($code, $itemId)
    {
        $cart = Cart::where('code', $code)
            ->where('status', 'active')
            ->firstOrFail();

        CartItem::where('id', $itemId)
            ->where('cart_id', $cart->id)
            ->delete();

        return response()->json(['success' => true]);
    }
}
