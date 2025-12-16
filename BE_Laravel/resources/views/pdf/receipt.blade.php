<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Struk Pembelian</title>

    <style>
        body {
            font-family: DejaVu Sans, sans-serif;
            font-size: 12px;
            color: #000;
        }

        .container {
            width: 100%;
            padding: 5px;
        }

        .center {
            text-align: center;
        }

        .bold {
            font-weight: bold;
        }

        .line {
            border-top: 1px dashed #000;
            margin: 8px 0;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        table th, table td {
            padding: 4px 0;
        }

        .right {
            text-align: right;
        }

        .small {
            font-size: 11px;
        }

        .footer {
            margin-top: 10px;
            text-align: center;
            font-size: 11px;
        }
    </style>
</head>
<body>

<div class="container">

    <!-- HEADER TOKO -->
    <div class="center">
        <div class="bold">TOKO SENJA & RONA</div>
        <div class="small">Jl. Contoh No. 123</div>
        <div class="small">Telp: 0812-3456-7890</div>
    </div>

    <div class="line"></div>

    <!-- INFO TRANSAKSI -->
    <table class="small">
        <tr>
            <td>Invoice</td>
            <td>: {{ $transaction->invoice_number }}</td>
        </tr>
        <tr>
            <td>Tanggal</td>
            <td>: {{ $transaction->transaction_date->format('d/m/Y H:i:s') }}</td>
        </tr>
        <tr>
            <td>Kasir</td>
            <td>: {{ $transaction->cashier->name ?? '-' }}</td>
        </tr>
        <tr>
            <td>No. Struk</td>
            <td>: {{ $transaction->receipt->receipt_number ?? '-' }}</td>
        </tr>
    </table>

    <div class="line"></div>

    <!-- ITEM LIST -->
    <table>
        <thead>
            <tr class="bold">
                <th align="left">Item</th>
                <th class="right">Qty</th>
                <th class="right">Harga</th>
                <th class="right">Subtotal</th>
            </tr>
        </thead>
        <tbody>
        @foreach ($transaction->items as $item)
            <tr>
                <td>{{ $item->product->name }}</td>
                <td class="right">{{ $item->qty }}</td>
                <td class="right">
                    {{ number_format($item->price, 0, ',', '.') }}
                </td>
                <td class="right">
                    {{ number_format($item->subtotal, 0, ',', '.') }}
                </td>
            </tr>
        @endforeach
        </tbody>
    </table>

    <div class="line"></div>

    <!-- TOTAL -->
    <table>
        <tr>
            <td>Total</td>
            <td class="right">
                {{ number_format($transaction->total_amount, 0, ',', '.') }}
            </td>
        </tr>
        <tr>
            <td>Bayar</td>
            <td class="right">
                {{ number_format($transaction->cash_paid, 0, ',', '.') }}
            </td>
        </tr>
        <tr class="bold">
            <td>Kembali</td>
            <td class="right">
                {{ number_format($transaction->change_amount, 0, ',', '.') }}
            </td>
        </tr>
    </table>

    <div class="line"></div>

    <!-- FOOTER -->
    <div class="footer">
        Terima kasih atas kunjungan Anda<br>
        Barang yang sudah dibeli tidak dapat dikembalikan
    </div>

</div>

</body>
</html>
