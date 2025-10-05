# 🛒 Cart Feature with WebView Integration

## Overview

This implementation provides a complete **Cart Feature** with **WebView Integration** for your Flutter broker app. Users can browse e-commerce platforms (Amazon, SHEIN, AliExpress, Taobao, Alibaba) within the app and add products to their cart with a single click using an injected floating button.

## 🎯 Features

### ✅ Implemented Features

1. **WebView Integration**
   - JavaScript injection for product data extraction
   - Platform-specific CSS selectors for major e-commerce sites
   - Floating "Add to Cart" button injected into web pages
   - Real-time communication between WebView and Flutter

2. **Cart Management**
   - Add products from any supported platform
   - Update product quantities
   - Remove items from cart
   - Clear entire cart
   - Real-time cart updates using Supabase Realtime

3. **Product Data Extraction**
   - Automatic extraction of:
     - Product title
     - Price
     - Main image
     - Additional images
     - Rating (if available)
     - Product URL
     - Platform information

4. **UI Components**
   - Cart screen with list of items
   - Cart item cards with images and details
   - Empty cart state
   - Cart summary with total items and price
   - Platform badges with brand colors
   - Quantity controls

5. **State Management**
   - BLoC pattern for cart state
   - Loading, error, and success states
   - Optimistic updates

## 📁 Project Structure

```
lib/features/cart/
├── data/
│   ├── datasources/
│   │   └── cart_remote_data_source.dart
│   ├── models/
│   │   └── cart_item_model.dart
│   ├── repositories/
│   │   └── cart_repository_impl.dart
│   └── platform_selectors.dart
├── domain/
│   ├── entities/
│   │   └── cart_item.dart
│   ├── repositories/
│   │   └── cart_repository.dart
│   └── usecases/
│       ├── add_to_cart.dart
│       ├── get_cart_items.dart
│       ├── update_cart_quantity.dart
│       ├── remove_from_cart.dart
│       └── clear_cart.dart
└── presentation/
    ├── bloc/
    │   ├── cart_bloc.dart
    │   ├── cart_event.dart
    │   └── cart_state.dart
    ├── pages/
    │   └── cart_screen.dart
    └── widgets/
        ├── cart_item_card.dart
        ├── cart_empty_widget.dart
        └── cart_summary_widget.dart
```

## 🚀 Setup Instructions

### 1. Database Setup

Run the SQL migration in your Supabase SQL Editor:

```bash
# The migration file is located at: supabase_cart_migration.sql
```

This will create:
- `cart_items` table
- Indexes for performance
- Row Level Security (RLS) policies
- Automatic `updated_at` trigger

### 2. Install Dependencies

The required dependencies are already added to `pubspec.yaml`:

```bash
flutter pub get
```

### 3. Dependency Injection

The cart feature is already registered in `lib/core/di/injection_container.dart`.

### 4. Navigation Setup

Add the cart screen to your navigation/routing:

```dart
// Example with go_router
GoRoute(
  path: '/cart',
  builder: (context, state) => const CartScreen(),
),
```

## 📱 Usage

### Opening the Cart Screen

```dart
// Navigate to cart screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const CartScreen()),
);

// Or with go_router
context.push('/cart');
```

### WebView Integration

The cart button is automatically injected when users browse supported platforms:

1. User opens a product page on Amazon, SHEIN, etc.
2. A floating "🛒 إضافة للسلة" button appears
3. User clicks the button
4. Product data is extracted and added to cart
5. Success message is shown

### Supported Platforms

- ✅ Amazon
- ✅ SHEIN
- ✅ AliExpress
- ✅ Taobao
- ✅ Alibaba
- ✅ Generic (fallback for other sites)

## 🔧 Customization

### Adding New Platforms

Edit `lib/features/cart/data/platform_selectors.dart`:

```dart
'newplatform': {
  'title': ['.product-title', 'h1'],
  'price': ['.price', 'span[class*="price"]'],
  'image': ['img.main-image'],
  'images': ['img.thumbnail'],
  'rating': ['.rating'],
  'buttonColor': '#FF0000',
},
```

### Updating CSS Selectors

If a platform changes its HTML structure, update the selectors in `platform_selectors.dart`:

```dart
'amazon': {
  'title': [
    '#productTitle',           // Primary selector
    '#title',                  // Fallback 1
    'h1[id*="title"]',        // Fallback 2
  ],
  // ... other selectors
},
```

### Customizing the Cart Button

Edit the button style in `lib/features/webview/presentation/pages/webview_screen.dart`:

```javascript
button.style.cssText = `
  position: fixed;
  bottom: 20px;
  right: 20px;
  background: $buttonColor;
  color: white;
  padding: 15px 25px;
  border-radius: 50px;
  // ... customize here
`;
```

## 🐛 Troubleshooting

### Product Data Not Extracted

**Problem**: Button shows "No title found" or extraction fails

**Solutions**:
1. Check browser console for errors (use Chrome DevTools)
2. Inspect the page HTML structure
3. Update CSS selectors in `platform_selectors.dart`
4. Add multiple fallback selectors

### Cart Button Not Appearing

**Problem**: Floating button doesn't show on product pages

**Solutions**:
1. Check if the URL matches platform detection logic
2. Verify JavaScript injection is working (check debug logs)
3. Ensure the page has finished loading
4. Check for JavaScript errors in WebView console

### Images Not Loading

**Problem**: Product images show broken image icon

**Solutions**:
1. Check CORS policy of the image URL
2. Verify image URL is valid
3. Consider downloading and re-uploading images to Supabase Storage

### RLS Policy Errors

**Problem**: "Row level security policy violation" errors

**Solutions**:
1. Verify user is authenticated
2. Check RLS policies in Supabase dashboard
3. Ensure `user_id` matches `auth.uid()`

## 📊 Database Schema

```sql
cart_items (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  product_name TEXT NOT NULL,
  price TEXT NOT NULL,
  image_url TEXT,
  images JSONB,
  product_url TEXT NOT NULL,
  platform TEXT NOT NULL,
  quantity INTEGER DEFAULT 1,
  rating TEXT,
  metadata JSONB,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
```

## 🔐 Security

- ✅ Row Level Security (RLS) enabled
- ✅ Users can only access their own cart items
- ✅ Server-side validation via Supabase policies
- ✅ Secure authentication required

## 🎨 UI Screenshots

The cart feature includes:
- Modern card-based design
- Platform-specific brand colors
- Responsive layout
- Arabic RTL support
- Loading and error states
- Empty state with call-to-action

## 🚧 Future Enhancements

Potential improvements:
- [ ] Bulk operations (select multiple items)
- [ ] Share cart with others
- [ ] Price tracking and alerts
- [ ] Currency conversion
- [ ] Export cart to CSV/PDF
- [ ] Cart synchronization across devices
- [ ] Wishlist integration
- [ ] Product comparison

## 📝 Testing

### Manual Testing Checklist

- [ ] Add product from Amazon
- [ ] Add product from SHEIN
- [ ] Update quantity
- [ ] Remove item
- [ ] Clear cart
- [ ] View empty cart state
- [ ] Check cart persistence after app restart
- [ ] Test with multiple users

### Test Data

Use the sample data in `supabase_cart_migration.sql` for testing.

## 🤝 Contributing

When adding new features:
1. Follow Clean Architecture principles
2. Add appropriate tests
3. Update this README
4. Document any new platform selectors

## 📄 License

This feature is part of the Broker App project.

---

**Need Help?** Check the inline code comments or create an issue in the repository.

