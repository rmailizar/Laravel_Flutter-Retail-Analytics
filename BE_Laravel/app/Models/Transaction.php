<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    protected $fillable = [
        'invoice_number',
        'transaction_date',
        'total_amount',
        'cash_paid',
        'change_amount',
        'paid_at',
        'cashier_id'
    ];

    protected $casts = [
        'transaction_date' => 'datetime'
    ];

    public function items()
    {
        return $this->hasMany(TransactionItem::class);
    }

    public function cashier()
    {
        return $this->belongsTo(User::class, 'cashier_id');
    }

    public function receipt()
    {
        return $this->hasOne(Receipt::class);
    }
}
