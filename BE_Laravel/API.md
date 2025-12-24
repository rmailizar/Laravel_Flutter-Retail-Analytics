# API Documentation

Base URL: `http://localhost:8000/api`

## Authentication

### Register
`POST /register`
Mendaftarkan user baru (Admin atau Cashier).

**Request Body:**
```json
{
  "name": "Nama User",      // required, string, max:255
  "email": "user@mail.com", // required, string, email, unique
  "password": "password",   // required, string, min:8, confirmed
  "password_confirmation": "password",
  "role": "cashier"         // required, in:admin,cashier
}
```

**Response (201 Created):**
```json
{
  "message": "User registered",
  "user": {
    "id": 1,
    "name": "Nama User",
    "email": "user@mail.com",
    "role": "cashier",
    "created_at": "...",
    "updated_at": "..."
  }
}
```

### Login
`POST /login`
Login untuk mendapatkan token akses.

**Request Body:**
```json
{
  "email": "user@mail.com", // required, email
  "password": "password"    // required
}
```

**Response (200 OK):**
```json
{
  "token": "1|laravel_sanctum_token_string...",
  "user": {
    "id": 1,
    "name": "Nama User",
    "email": "user@mail.com",
    "role": "cashier",
    ...
  }
}
```

**Error (401 Unauthorized):**
```json
{
  "message": "Invalid credentials"
}
```

### Logout
`POST /logout`
Batalkan token akses saat ini.

**Headers:**
`Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
  "message": "Logged out"
}
```

---

## Public Data (Read Only)

### List Categories
`GET /categories`
Mendapatkan semua kategori.

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    { "id": 1, "name": "Minuman", ... },
    { "id": 2, "name": "Makanan", ... }
  ]
}
```

### List Products
`GET /products`
Mendapatkan daftar produk dengan pagination dan fitur pencarian.

**Query Parameters:**
- `search`: (optional) Cari berdasarkan nama atau SKU.
- `category_id`: (optional) Filter berdasarkan kategori ID.
- `page`: (optional) Halaman ke-n (default 1).

**Response (200 OK):**
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "name": "Kopi Susu",
      "sku": "KOPI-001",
      "barcode": "899123456",
      "sell_price": 15000,
      "stock": 100,
      "category": { "id": 1, "name": "Minuman" },
      ...
    }
  ],
  "total": 10,
  ...
}
```

---

## Admin Only
**Headers:** `Authorization: Bearer <token>` (Role: admin)

### Create Category
`POST /categories`

**Request Body:**
```json
{
  "name": "Elektronik" // required, string, max:100, unique
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Category created",
  "data": { ... }
}
```

### Update Category
`PUT /categories/{id}`

**Request Body:**
```json
{
  "name": "Elektronik Baru" // required, string, unique
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Category updated",
  "data": { ... }
}
```

### Delete Category
`DELETE /categories/{id}`
**Note:** Gagal jika kategori masih digunakan oleh produk.

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Category deleted"
}
```
**Error (422 Unprocessable Entity):**
```json
{
  "success": false,
  "message": "Category masih digunakan oleh produk"
}
```

### Create Product
`POST /products`

**Request Body:**
```json
{
  "name": "Nama Produk",   // required
  "sku": "SKU-001",        // required, unique
  "barcode": "12345678",   // required, unique
  "category_id": 1,        // nullable, exists in categories
  "sell_price": 50000,     // required, numeric, min:0
  "cost_price": 40000,     // nullable, numeric, min:0
  "stock": 10              // nullable, integer, min:0
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": { ... }
}
```

### Update Product
`PUT /products/{id}`

**Request Body:** (Sama dengan Create, SKU & Barcode ignore ID sendiri)
```json
{ "name": "Update Nama", ... }
```

### Import Products
`POST /products/import`

**Request Body:** (Multipart Form Data)
- `file`: (required, file .csv / .txt)

**Format CSV:**
Header: `name,sku,barcode,category_id,sell_price,cost_price,stock`

**Response (200 OK):**
```json
{
  "success": true,
  "created": 5 // Jumlah produk berhasil diimport
}
```

### Delete Product
`DELETE /products/{id}`
Note: Gagal jika produk sudah ada data transaksi (Foreign Key Error).

**Response (200 OK):** `{"success": true}`

### Adjust Stock
`POST /products/{id}/adjust-stock`

**Request Body:**
```json
{
  "type": "in", // required, in:in,out,adjust
  "qty": 10,    // required, integer, min:1
  "note": "Restock mingguan" // nullable
}
```
- `in`: Menambah stok.
- `out`: Mengurangi stok (Gagal jika stok kurang).
- `adjust`: (Logic depends on implementation, currently placeholder in controller).

**Response:**
```json
{
  "success": true,
  "new_stock": 110
}
```

### Dashboard Summary
`GET /dashboard/summary`

**Response:**
```json
{
  "total_sales": 1500000,
  "total_transactions": 50,
  "today_sales": 200000,
  "best_selling_product": {
    "product_id": 5,
    "total": 20
  }
}
```

### Sales Chart
`GET /dashboard/sales-chart`
Data penjualan 7 hari terakhir.

**Response:**Array of objects `{ "date": "2023-12-01", "total": 50000 }`

---

## Transaction (Admin & Cashier)
**Headers:** `Authorization: Bearer <token>` (Role: admin, cashier)

### Create Cart
`POST /carts`
Membuat sesi keranjang belanja baru.

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "code": "CART-ABC12345",
    "status": "active",
    ...
  }
}
```

### Show Cart
`GET /carts/{code}`
Melihat detail cart beserta itemnya.

**Response:** Object Cart dengan relasi items dan items.product.

### Add Item to Cart
`POST /carts/{code}/items`
Scan barcode/SKU untuk tambah item.

**Request Body:**
```json
{
  "sku": "KOPI-001", // required
  "qty": 1           // nullable, default 1, min:1
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Produk ditambahkan ke cart"
}
```
**Error (422):** `{"message": "Stock tidak mencukupi"}`

### Update Item Qty
`PUT /carts/{code}/items/{itemId}`

**Request Body:**
```json
{
  "qty": 5 // required, integer, min:1
}
```

### Remove Item
`DELETE /carts/{code}/items/{itemId}`

### Checkout
`POST /carts/{code}/checkout`
Finalisasi transaksi.

**Request Body:**
```json
{
  "cash_paid": 100000 // required, numeric, min:0
}
```
**Validasi:** `cash_paid` harus >= `total_amount` cart.

**Response (200 OK):**
```json
{
  "success": true,
  "transaction": {
    "invoice_number": "INV-20231222-XYZ123",
    "total_amount": 50000,
    "cash_paid": 100000,
    "change_amount": 50000,
    ...
  }
}
```

### Download Receipt
`GET /transactions/{invoice}/receipt`
Download struk dalam format PDF.

**Response:** Binary file PDF.
