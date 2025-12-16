<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Receipt;
use Illuminate\Support\Str;
use Barryvdh\DomPDF\Facade\Pdf;

class ReceiptController extends Controller
{
    public function download($invoice)
    {
        $transaction = Transaction::with([
            'items.product',
            'cashier',
            'receipt'
        ])->where('invoice_number', $invoice)->firstOrFail();

        if (!$transaction->receipt) {
            Receipt::create([
                'transaction_id' => $transaction->id,
                'receipt_number' => 'RCPT-' . strtoupper(Str::random(8)),
            ]);
        }

        $pdf = Pdf::loadView('pdf.receipt', [
            'transaction' => $transaction,
        ]);

        return $pdf->download("struk-{$transaction->invoice_number}.pdf");
    }
}
