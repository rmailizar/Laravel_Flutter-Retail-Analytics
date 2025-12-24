<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\QueryException;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::with('category')
            ->when($request->search, function ($q) use ($request) {
                $q->where('name', 'like', "%{$request->search}%")
                    ->orWhere('sku', 'like', "%{$request->search}%")
                    ->orWhere('barcode', 'like', "%{$request->search}%");
            })
            ->when(
                $request->category_id,
                fn($q) =>
                $q->where('category_id', $request->category_id)
            );

        return response()->json($query->paginate(20));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string',
            'sku' => 'required|string|unique:products,sku',
            'barcode' => 'required|string|unique:products,barcode',
            'category_id' => 'nullable|exists:categories,id',
            'sell_price' => 'required|numeric|min:0',
            'cost_price' => 'nullable|numeric|min:0',
            'stock' => 'nullable|integer|min:0',
        ]);

        $product = Product::create($validated);

        return response()->json([
            'success' => true,
            'data' => $product
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $product = Product::findOrFail($id);

        // Allow updating SKU, barcode and stock while keeping validation for uniqueness
        $validated = $request->validate([
            'name' => 'required|string',
            'sku' => "required|string|unique:products,sku,{$id}",
            'barcode' => "required|string|unique:products,barcode,{$id}",
            'category_id' => 'nullable|exists:categories,id',
            'sell_price' => 'required|numeric|min:0',
            'cost_price' => 'nullable|numeric|min:0',
            'stock' => 'nullable|integer|min:0',
        ]);

        $product->update($validated);

        return response()->json([
            'success' => true,
            'data' => $product
        ]);
    }

    public function import(Request $request)
    {
        $request->validate([
            'file' => 'required|file|mimes:csv,txt'
        ]);

        $file = fopen($request->file('file')->getRealPath(), 'r');

        DB::beginTransaction();

        try {
            $header = fgetcsv($file);
            $created = 0;

            while (($row = fgetcsv($file)) !== false) {
                $data = array_combine($header, $row);

                // Validasi per baris
                if (
                    empty($data['name']) ||
                    empty($data['sku']) ||
                    empty($data['barcode']) ||
                    empty($data['sell_price'])
                ) {
                    continue;
                }

                // Skip jika SKU / barcode sudah ada
                if (
                    Product::where('sku', $data['sku'])->exists() ||
                    Product::where('barcode', $data['barcode'])->exists()
                ) {
                    continue;
                }

                Product::create([
                    'name' => $data['name'],
                    'sku' => $data['sku'],
                    'barcode' => $data['barcode'],
                    'category_id' => $data['category_id'] ?? null,
                    'sell_price' => $data['sell_price'],
                    'cost_price' => $data['cost_price'] ?? 0,
                    'stock' => $data['stock'] ?? 0,
                ]);

                $created++;
            }

            fclose($file);
            DB::commit();

            return response()->json([
                'success' => true,
                'created' => $created
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'message' => 'Import gagal',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id)
    {
        $product = Product::findOrFail($id);

        try {
            $product->delete();
            return response()->json(['success' => true]);
        } catch (QueryException $e) {
            // SQLSTATE[23000] integrity constraint violation (foreign key)
            if ($e->getCode() == '23000' || str_contains($e->getMessage(), 'Integrity constraint')) {
                return response()->json([
                    'message' => 'Produk tidak dapat dihapus karena sudah digunakan pada transaksi atau data terkait.',
                    'error' => $e->getMessage()
                ], 409);
            }

            // rethrow other DB exceptions
            throw $e;
        }
    }
    
}
