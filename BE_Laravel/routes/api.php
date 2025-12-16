<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| AUTH (Laravel Breeze API)
|--------------------------------------------------------------------------
*/

use App\Http\Controllers\Auth\AuthenticatedSessionController;
use App\Http\Controllers\Auth\RegisteredUserController;
use App\Http\Controllers\Auth\LogoutController;

/*
|--------------------------------------------------------------------------
| API CONTROLLERS (REAL)
|--------------------------------------------------------------------------
*/

use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\StockController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\ReceiptController;
use App\Http\Controllers\Api\DashboardController;

/*
|--------------------------------------------------------------------------
| AUTH ROUTES
|--------------------------------------------------------------------------
*/

Route::post('/register', [RegisteredUserController::class, 'store']);
Route::post('/login', [AuthenticatedSessionController::class, 'store']);
Route::middleware('auth:sanctum')->post('/logout', [AuthenticatedSessionController::class, 'destroy']);

/*
|--------------------------------------------------------------------------
| PUBLIC (READ ONLY)
|--------------------------------------------------------------------------
*/

Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/products', [ProductController::class, 'index']);

/*
|--------------------------------------------------------------------------
| AUTHENTICATED USER
|--------------------------------------------------------------------------
*/

Route::middleware('auth:sanctum')->group(function () {

    /*
    |--------------------------------------------------------------------------
    | ADMIN ONLY
    |--------------------------------------------------------------------------
    */
    Route::middleware('role:admin')->group(function () {

        // Category
        Route::post('/categories', [CategoryController::class, 'store']);
        Route::put('/categories/{id}', [CategoryController::class, 'update']);
        Route::delete('/categories/{id}', [CategoryController::class, 'destroy']);

        // Product
        Route::post('/products', [ProductController::class, 'store']);
        Route::post('/products/import', [ProductController::class, 'import']);
        Route::put('/products/{id}', [ProductController::class, 'update']);
        Route::delete('/products/{id}', [ProductController::class, 'destroy']);
        
        // Stock
        Route::post('/products/{id}/adjust-stock', [StockController::class, 'adjust']);

        // Dashboard
        Route::get('/dashboard/summary', [DashboardController::class, 'summary']);
        Route::get('/dashboard/sales-chart', [DashboardController::class, 'salesChart']);
    });

    /*
    |--------------------------------------------------------------------------
    | ADMIN & CASHIER (KASIR)
    |--------------------------------------------------------------------------
    */
    Route::middleware('role:admin,cashier')->group(function () {

        // Cart
        Route::post('/carts', [CartController::class, 'create']);
        Route::get('/carts/{code}', [CartController::class, 'show']);

        // Cart Items (scan barcode / SKU)
        Route::post('/carts/{code}/items', [CartController::class, 'addItem']);
        Route::put('/carts/{code}/items/{itemId}', [CartController::class, 'updateItem']);
        Route::delete('/carts/{code}/items/{itemId}', [CartController::class, 'removeItem']);

        // Checkout (cash only)
        Route::post('/carts/{code}/checkout', [TransactionController::class, 'checkout']);

        // Receipt PDF
        Route::get('/transactions/{invoice}/receipt', [ReceiptController::class, 'download']);
    });
});
