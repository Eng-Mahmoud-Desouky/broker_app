# 🚀 Quick Start Guide - Cart Feature

## ⏱️ 5-Minute Setup

Follow these steps to get the cart feature up and running:

### Step 1: Database Setup (2 minutes)

1. Open your **Supabase Dashboard**
2. Go to **SQL Editor**
3. Click **New Query**
4. Copy the entire contents of `supabase_cart_migration.sql`
5. Paste into the SQL Editor
6. Click **Run** (or press F5)
7. ✅ You should see "Success. No rows returned"

### Step 2: Add Navigation (1 minute)

Choose one of these options to add cart access:

#### Option A: Add to Home Screen App Bar (Recommended)

Open `lib/features/home/presentation/pages/home_page.dart` and add:

```dart
import '../../../cart/presentation/pages/cart_screen.dart';

// In the AppBar actions:
AppBar(
  actions: [
    IconButton(
      icon: const Icon(Icons.shopping_cart),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartScreen()),
        );
      },
    ),
  ],
)
```

#### Option B: Add to Main Navigation

If you have a bottom navigation bar, add:

```dart
BottomNavigationBarItem(
  icon: Icon(Icons.shopping_cart),
  label: 'السلة',
),
```

### Step 3: Test the Feature (2 minutes)

1. **Run the app**
   ```bash
   flutter run
   ```

2. **Test WebView Integration**
   - Navigate to a platform (e.g., Amazon, SHEIN)
   - Open any product page
   - Look for the floating "🛒 إضافة للسلة" button
   - Click it
   - You should see "تمت إضافة المنتج للسلة بنجاح"

3. **Test Cart Screen**
   - Navigate to the cart (using the icon you added)
   - Verify the product appears
   - Try updating quantity
   - Try removing the item

## ✅ Verification Checklist

- [ ] Database migration completed successfully
- [ ] Cart icon/button added to navigation
- [ ] App runs without errors
- [ ] Floating cart button appears on product pages
- [ ] Products can be added to cart
- [ ] Cart screen displays items correctly
- [ ] Quantity can be updated
- [ ] Items can be removed
- [ ] Cart persists after app restart

## 🎯 Quick Test Scenarios

### Test 1: Add Product from Amazon
1. Open WebView to Amazon product page
2. Wait for page to load
3. Click floating cart button
4. Verify success message
5. Open cart screen
6. Verify product is listed

### Test 2: Multiple Products
1. Add product from Amazon
2. Add product from SHEIN
3. Open cart screen
4. Verify both products are listed
5. Verify platform badges show correct colors

### Test 3: Quantity Management
1. Open cart screen
2. Click + button on any item
3. Verify quantity increases
4. Verify total updates
5. Click - button
6. Verify quantity decreases

### Test 4: Remove Item
1. Open cart screen
2. Click delete icon on any item
3. Verify item is removed
4. Verify total updates

### Test 5: Clear Cart
1. Add multiple items to cart
2. Open cart screen
3. Click delete icon in app bar
4. Confirm deletion
5. Verify cart is empty

## 🐛 Troubleshooting

### Issue: "Table does not exist" error
**Solution**: Run the database migration in Supabase SQL Editor

### Issue: Cart button not appearing
**Solution**: 
- Check if you're on a product page (not homepage)
- Wait for page to fully load
- Check browser console for JavaScript errors

### Issue: "User not authenticated" error
**Solution**: Make sure you're logged in to the app

### Issue: Images not loading
**Solution**: This is normal for some platforms due to CORS. The feature still works.

## 📱 Supported Platforms

The cart button will automatically appear on product pages from:

- ✅ **Amazon** (amazon.com)
- ✅ **SHEIN** (shein.com)
- ✅ **AliExpress** (aliexpress.com)
- ✅ **Taobao** (taobao.com)
- ✅ **Alibaba** (alibaba.com)
- ✅ **Generic** (other e-commerce sites)

## 🎨 Customization Quick Tips

### Change Cart Button Color

Edit `lib/features/cart/data/platform_selectors.dart`:

```dart
'amazon': {
  // ... other config
  'buttonColor': '#YOUR_COLOR_HERE',
},
```

### Change Button Position

Edit `lib/features/webview/presentation/pages/webview_screen.dart`:

```javascript
button.style.cssText = `
  position: fixed;
  bottom: 20px;    // Change this
  right: 20px;     // Change this
  // ...
`;
```

### Add New Platform

Edit `lib/features/cart/data/platform_selectors.dart`:

```dart
'yourplatform': {
  'title': ['.product-title'],
  'price': ['.price'],
  'image': ['img.main'],
  'images': ['img.thumb'],
  'rating': ['.rating'],
  'buttonColor': '#000000',
},
```

## 📊 Database Verification

Run this query in Supabase SQL Editor to verify setup:

```sql
-- Check if table exists
SELECT * FROM cart_items LIMIT 1;

-- Check RLS policies
SELECT policyname FROM pg_policies WHERE tablename = 'cart_items';

-- Should return 4 policies:
-- 1. Users can view own cart items
-- 2. Users can insert to own cart
-- 3. Users can update own cart items
-- 4. Users can delete own cart items
```

## 🎓 Next Steps

After basic setup works:

1. **Read Full Documentation**
   - `CART_FEATURE_README.md` - Complete feature documentation
   - `CART_IMPLEMENTATION_SUMMARY.md` - Implementation details

2. **Customize for Your Needs**
   - Add more platforms
   - Customize UI colors
   - Add cart badge with item count

3. **Extend Functionality**
   - Add checkout flow
   - Integrate with payment gateway
   - Add order history

## 💡 Pro Tips

1. **Test with Real Products**: Use actual product pages for testing
2. **Check Debug Console**: Look for helpful debug messages
3. **Update Selectors**: If extraction fails, update CSS selectors
4. **Use Fallbacks**: Add multiple selectors for reliability

## 📞 Need Help?

1. Check `CART_FEATURE_README.md` for detailed troubleshooting
2. Review error messages in debug console
3. Verify database migration was successful
4. Check Supabase logs for backend errors

## 🎉 Success!

If you can:
- ✅ See the cart button on product pages
- ✅ Add products to cart
- ✅ View cart screen
- ✅ Update quantities
- ✅ Remove items

**Congratulations! The cart feature is working perfectly! 🎊**

---

**Estimated Setup Time**: 5-10 minutes
**Difficulty**: Easy
**Prerequisites**: Supabase account, authenticated user

