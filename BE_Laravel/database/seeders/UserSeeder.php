<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database  dengan user default untuk login
     */
    public function run(): void
    {
        // Admin User
        User::firstOrCreate(
            ['email' => 'admin@example.com'],
            [
                'name' => 'Admin User',
                'password' => Hash::make('admin123'),
                'role' => 'admin',
                'email_verified_at' => now(),
            ]
        );

        // Cashier User 1
        User::firstOrCreate(
            ['email' => 'cashier1@example.com'],
            [
                'name' => 'Cashier 1',
                'password' => Hash::make('cashier123'),
                'role' => 'cashier',
                'email_verified_at' => now(),
            ]
        );

        // Cashier User 2
        User::firstOrCreate(
            ['email' => 'cashier2@example.com'],
            [
                'name' => 'Cashier 2',
                'password' => Hash::make('cashier123'),
                'role' => 'cashier',
                'email_verified_at' => now(),
            ]
        );

        // Test User
        User::firstOrCreate(
            ['email' => 'test@example.com'],
            [
                'name' => 'Test User',
                'password' => Hash::make('password'),
                'role' => 'cashier',
                'email_verified_at' => now(),
            ]
        );
    }
}
