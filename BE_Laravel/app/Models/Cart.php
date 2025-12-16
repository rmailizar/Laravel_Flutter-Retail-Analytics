<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Cart extends Model
{
    protected $fillable = ['code', 'status'];

    public function items()
    {
        return $this->hasMany(CartItem::class);
    }
}
