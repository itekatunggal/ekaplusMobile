# Ekaplus Backend API

Backend API untuk aplikasi Ekaplus Ekatunggal mobile app menggunakan PHP dan MySQL.

## 📁 Struktur Folder

```
database/api/
├── config.php              # Database configuration & helper functions
├── .htaccess              # Apache CORS & rewrite rules
├── branches/
│   ├── get_all.php        # GET all branches
│   └── get_by_id.php      # GET branch by ID
├── item_types/
│   ├── get_all.php        # GET all item types
│   └── get_by_id.php      # GET item type by ID
├── categories/
│   ├── get_all.php        # GET all categories (item_categories)
│   └── get_by_id.php      # GET category by ID
├── items/                  # Same as products (alternative naming)
│   ├── get_all.php        # GET all items/products with variants
│   └── get_by_id.php      # GET item/product by ID with variants
├── products/               # Same as items (preferred naming)
│   ├── get_all.php        # GET all products with variants
│   └── get_by_id.php      # GET product by ID with variants
├── item_variants/          # Same as variants (alternative naming)
│   ├── get_all.php        # GET all variants (optional: ?item_id=x)
│   └── get_by_id.php      # GET variant by ID
├── variants/               # Same as item_variants (preferred naming)
│   ├── get_all.php        # GET all variants (optional: ?item_id=x)
│   └── get_by_id.php      # GET variant by ID
└── users/
    ├── get_all.php        # GET all users
    └── get_by_id.php      # GET user by ID or user_id
```

## 🚀 Setup

### 1. Copy ke Server

Copy folder `database/api` ke dalam folder `ekaplus_backend` di web server:

```
C:\xampp\htdocs\ekaplus_backend\api\
```

atau

```
/var/www/html/ekaplus_backend/api/
```

### 2. Konfigurasi Database

Edit file `config.php` sesuai dengan konfigurasi database Anda:

```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'ekaplus_db');
define('DB_USER', 'root');
define('DB_PASS', '');
```

### 3. Import Database

Import file `database/schema.sql` dan `database/initial_data.sql` ke MySQL:

```bash
mysql -u root -p ekaplus_db < database/schema.sql
mysql -u root -p ekaplus_db < database/initial_data.sql
```

### 4. Test API

Buka browser dan akses:

```
http://localhost/ekaplus_backend/api/branches/get_all.php
```

Atau menggunakan IP komputer:

```
http://192.168.1.4/ekaplus_backend/api/branches/get_all.php
```

## 📡 API Endpoints

### Branches

- **GET** `/api/branches/get_all.php` - Get all branches
- **GET** `/api/branches/get_by_id.php?id=1` - Get branch by ID

### Item Types

- **GET** `/api/item_types/get_all.php` - Get all item types
- **GET** `/api/item_types/get_by_id.php?id=1` - Get item type by ID

### Categories

- **GET** `/api/categories/get_all.php` - Get all categories
- **GET** `/api/categories/get_by_id.php?id=1` - Get category by ID

### Items/Products

**Option 1: Using 'products' endpoint (recommended)**
- **GET** `/api/products/get_all.php` - Get all products with variants
- **GET** `/api/products/get_by_id.php?id=1` - Get product by ID with variants

**Option 2: Using 'items' endpoint (alternative)**
- **GET** `/api/items/get_all.php` - Get all items with variants
- **GET** `/api/items/get_by_id.php?id=1` - Get item by ID with variants

### Variants

**Option 1: Using 'variants' endpoint (recommended)**
- **GET** `/api/variants/get_all.php` - Get all variants
- **GET** `/api/variants/get_all.php?item_id=1` - Get variants for specific product
- **GET** `/api/variants/get_by_id.php?id=1` - Get variant by ID

**Option 2: Using 'item_variants' endpoint (alternative)**
- **GET** `/api/item_variants/get_all.php` - Get all variants
- **GET** `/api/item_variants/get_all.php?item_id=1` - Get variants for specific product
- **GET** `/api/item_variants/get_by_id.php?id=1` - Get variant by ID

### Users

- **GET** `/api/users/get_all.php` - Get all users
- **GET** `/api/users/get_by_id.php?id=1` - Get user by ID or user_id

## 📋 Response Format

### Success Response

```json
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": [...]
}
```

### Error Response

```json
{
  "success": false,
  "message": "Error message here",
  "data": null
}
```

## 🔧 Helper Functions

File `config.php` menyediakan helper functions:

```php
getDBConnection()           // Get PDO database connection
sendSuccess($data, $msg)   // Send success response
sendError($msg, $code)     // Send error response
sendNotFound($msg)         // Send 404 not found response
```

## 🔐 Security Notes

1. **CORS**: API sudah dikonfigurasi untuk allow CORS dari semua origin (`*`). Di production, ganti dengan domain spesifik.

2. **Password**: User password tidak pernah di-return di API responses.

3. **SQL Injection**: Semua queries menggunakan prepared statements dengan PDO.

4. **Error Handling**: Error messages di-catch dan di-return dalam format JSON yang konsisten.

## 📊 Database Tables

- `branches` - Cabang/branch data
- `item_types` - Tipe item (Material Springbed, Material Sofa, dll)
- `item_categories` - Kategori item (Busa, Kain, dll)
- `items` - Products/items master
- `item_variants` - Variant dari items (warna, ukuran, dll)
- `users` - User accounts

## 🐛 Debugging

Untuk melihat error messages, pastikan error reporting aktif di `config.php`:

```php
error_reporting(E_ALL);
ini_set('display_errors', 1);
```

**PENTING**: Disable error display di production!

## 📱 Testing dari Flutter

Update `lib/config/api_config.dart`:

```dart
static const String baseUrl = 'http://192.168.1.4/ekaplus_backend/api';
```

Ganti `192.168.1.4` dengan IP komputer yang menjalankan XAMPP/Apache.

## ⚙️ Requirements

- PHP 7.4 or higher
- MySQL 5.7 or higher
- Apache with mod_rewrite enabled
- PDO MySQL extension enabled

## 🎯 Example cURL Commands

```bash
# Get all branches
curl http://192.168.1.4/ekaplus_backend/api/branches/get_all.php

# Get branch by ID
curl http://192.168.1.4/ekaplus_backend/api/branches/get_by_id.php?id=1

# Get all categories
curl http://192.168.1.4/ekaplus_backend/api/categories/get_all.php

# Get items with variants
curl http://192.168.1.4/ekaplus_backend/api/items/get_all.php
```

---

**Created**: 2025-12-13
**Version**: 1.0.0
