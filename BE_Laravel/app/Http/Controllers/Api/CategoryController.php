<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    /**
     * GET /api/categories
     * List semua kategori
     */
    public function index()
    {
        $categories = Category::orderBy('name')->get();

        return response()->json([
            'success' => true,
            'data' => $categories
        ]);
    }

    /**
     * POST /api/categories
     * Tambah kategori baru
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100|unique:categories,name'
        ]);

        $category = Category::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Category created',
            'data' => $category
        ], 201);
    }

    /**
     * PUT /api/categories/{id}
     * Update kategori
     */
    public function update(Request $request, $id)
    {
        $category = Category::findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string|max:100|unique:categories,name,' . $id
        ]);

        $category->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Category updated',
            'data' => $category
        ]);
    }

    /**
     * DELETE /api/categories/{id}
     * Hapus kategori
     */
    public function destroy($id)
    {
        $category = Category::findOrFail($id);

        // Optional safety check:
        if ($category->products()->count() > 0) {
            return response()->json([
                'success' => false,
                'message' => 'Category masih digunakan oleh produk'
            ], 422);
        }

        $category->delete();

        return response()->json([
            'success' => true,
            'message' => 'Category deleted'
        ]);
    }
}
