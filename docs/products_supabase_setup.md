# Products Feature - Supabase Setup

## Required Supabase Table Structure

### Products Table

Create the `products` table in your Supabase database with the following structure:

```sql
CREATE TABLE products (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'USD',
  original_price DECIMAL(10,2),
  rating DECIMAL(3,2),
  review_count INTEGER DEFAULT 0,
  category TEXT,
  is_in_stock BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Sample Data

Insert sample products to test the implementation:

```sql
INSERT INTO products (
  id, name, description, image_url, price, currency, original_price, 
  rating, review_count, category, is_in_stock
) VALUES 
(
  '1',
  'iPhone 15 Pro Max',
  'أحدث هاتف ذكي من آبل مع شاشة 6.7 بوصة وكاميرا احترافية ثلاثية العدسات',
  'https://via.placeholder.com/400x400/213c86/ffffff?text=iPhone+15+Pro',
  1199.99,
  'USD',
  1299.99,
  4.8,
  1250,
  'Electronics',
  true
),
(
  '2',
  'Samsung Galaxy S24 Ultra',
  'هاتف سامسونج الرائد مع قلم S Pen وكاميرا 200 ميجابكسل',
  'https://via.placeholder.com/400x400/213c86/ffffff?text=Galaxy+S24',
  1099.99,
  'USD',
  NULL,
  4.7,
  890,
  'Electronics',
  true
),
(
  '3',
  'MacBook Pro 16"',
  'لابتوب آبل الاحترافي مع معالج M3 Pro وشاشة Retina عالية الدقة',
  'https://via.placeholder.com/400x400/213c86/ffffff?text=MacBook+Pro',
  2499.99,
  'USD',
  2699.99,
  4.9,
  567,
  'Computers',
  true
),
(
  '4',
  'AirPods Pro 2',
  'سماعات آبل اللاسلكية مع إلغاء الضوضاء النشط',
  'https://via.placeholder.com/400x400/213c86/ffffff?text=AirPods+Pro',
  249.99,
  'USD',
  NULL,
  4.6,
  2340,
  'Audio',
  true
),
(
  '5',
  'Dell XPS 13',
  'لابتوب ديل الأنيق والخفيف مع شاشة InfinityEdge',
  'https://via.placeholder.com/400x400/213c86/ffffff?text=Dell+XPS',
  999.99,
  'USD',
  1199.99,
  4.5,
  423,
  'Computers',
  false
),
(
  '6',
  'Sony WH-1000XM5',
  'سماعات سوني اللاسلكية مع أفضل تقنية إلغاء الضوضاء',
  'https://via.placeholder.com/400x400/213c86/ffffff?text=Sony+WH1000XM5',
  399.99,
  'USD',
  NULL,
  4.8,
  1876,
  'Audio',
  true
);
```

### Enable Row Level Security (Optional)

If you want to add security policies:

```sql
-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Allow public read access" ON products
  FOR SELECT USING (true);

-- Allow authenticated users to insert/update (if needed)
CREATE POLICY "Allow authenticated insert" ON products
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated update" ON products
  FOR UPDATE USING (auth.role() = 'authenticated');
```

## Features Implemented

### 1. Product List Feature
- **Route**: `/products`
- **Data Source**: Supabase `products` table
- **Features**:
  - Grid layout with product cards
  - Shimmer loading animation
  - Pull-to-refresh functionality
  - Error handling with retry option
  - Empty state handling
  - Navigation to product details

### 2. Product Details Feature
- **Route**: `/product-details/:productId`
- **Data Source**: Supabase `products` table (single product by ID)
- **Features**:
  - Full product information display
  - Product image with error handling
  - Price display with discount calculation
  - Rating and review count
  - Stock status indicator
  - Category badge
  - Shimmer loading animation
  - Error handling with retry option

### 3. Integration Points
- **Home Page**: "View All Products" button navigates to product list
- **Search Results**: Product taps navigate to product details
- **Suggested Products**: Product taps navigate to product details

## Architecture

The implementation follows Clean Architecture principles:

### Domain Layer
- `Product` entity with business logic
- `ProductRepository` interface
- `GetProducts` and `GetProductDetails` use cases

### Data Layer
- `ProductModel` for JSON serialization
- `ProductRemoteDataSource` for Supabase integration
- `ProductRepositoryImpl` with network connectivity checks

### Presentation Layer
- `ProductListBloc` and `ProductDetailsBloc` for state management
- Shimmer loading widgets
- Responsive UI components
- Error and empty state handling

## Testing

To test the implementation:

1. **Create the products table** in your Supabase database
2. **Insert sample data** using the provided SQL
3. **Run the app** and navigate to the products section
4. **Test features**:
   - View product list
   - Tap on products to see details
   - Test loading states by throttling network
   - Test error states by disconnecting internet
   - Test empty states by clearing the table

## Next Steps

1. **Add real product images** by updating the `image_url` field
2. **Implement product search** functionality
3. **Add product categories** filtering
4. **Implement favorites** functionality
5. **Add shopping cart** features
6. **Implement product reviews** system
