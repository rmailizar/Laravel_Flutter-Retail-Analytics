<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function summary()
    {
        return response()->json([
            'total_sales' => Transaction::sum('total_amount'),
            'total_transactions' => Transaction::count(),
            'today_sales' => Transaction::whereDate('transaction_date', today())
                ->sum('total_amount'),

            'best_selling_product' => DB::table('transaction_items')
                ->select('product_id', DB::raw('SUM(qty) as total'))
                ->groupBy('product_id')
                ->orderByDesc('total')
                ->first(),
        ]);
    }

    public function salesChart()
    {
        $data = Transaction::selectRaw('DATE(transaction_date) as date, SUM(total_amount) as total')
            ->where('transaction_date', '>=', now()->subDays(6))
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        return response()->json($data);
    }
}
