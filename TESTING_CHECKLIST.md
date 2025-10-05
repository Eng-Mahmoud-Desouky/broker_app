# ✅ Cart Feature Testing Checklist

## Pre-Testing Setup

- [ ] Database migration completed successfully
- [ ] `flutter pub get` executed
- [ ] App builds without errors
- [ ] User is authenticated
- [ ] Cart navigation added to UI

## 1. Database Testing

### Supabase Setup
- [ ] `cart_items` table exists
- [ ] All columns are present (id, user_id, product_name, price, etc.)
- [ ] Indexes are created (user_id, platform, created_at)
- [ ] RLS is enabled on the table
- [ ] All 4 RLS policies exist:
  - [ ] Users can view own cart items
  - [ ] Users can insert to own cart
  - [ ] Users can update own cart items
  - [ ] Users can delete own cart items
- [ ] Trigger for `updated_at` is created

### Manual Database Test
```sql
-- Run in Supabase SQL Editor
SELECT * FROM cart_items WHERE user_id = auth.uid();
```
- [ ] Query executes without errors
- [ ] Returns empty result (if no items added yet)

## 2. WebView Integration Testing

### Amazon Testing
- [ ] Navigate to Amazon product page
- [ ] Floating cart button appears
- [ ] Button has Amazon orange color (#FF9900)
- [ ] Button text is "🛒 إضافة للسلة"
- [ ] Click button
- [ ] Success message appears
- [ ] Product data extracted correctly:
  - [ ] Product title
  - [ ] Price
  - [ ] Main image
  - [ ] Rating (if available)

### SHEIN Testing
- [ ] Navigate to SHEIN product page
- [ ] Floating cart button appears
- [ ] Button has SHEIN black color (#000000)
- [ ] Click button
- [ ] Success message appears
- [ ] Product data extracted correctly

### AliExpress Testing
- [ ] Navigate to AliExpress product page
- [ ] Floating cart button appears
- [ ] Button has AliExpress red color (#FF4747)
- [ ] Click button
- [ ] Success message appears
- [ ] Product data extracted correctly

### Taobao Testing
- [ ] Navigate to Taobao product page
- [ ] Floating cart button appears
- [ ] Button has Taobao orange color (#FF6600)
- [ ] Click button
- [ ] Success message appears
- [ ] Product data extracted correctly

### Alibaba Testing
- [ ] Navigate to Alibaba product page
- [ ] Floating cart button appears
- [ ] Button has Alibaba orange color (#FF6A00)
- [ ] Click button
- [ ] Success message appears
- [ ] Product data extracted correctly

### Generic Platform Testing
- [ ] Navigate to unknown e-commerce site
- [ ] Floating cart button appears
- [ ] Button has default blue color (#2196F3)
- [ ] Click button
- [ ] Generic extraction attempted

## 3. Cart Screen Testing

### Initial Load
- [ ] Navigate to cart screen
- [ ] Loading indicator appears briefly
- [ ] Cart items load successfully
- [ ] If empty, empty state widget appears
- [ ] If has items, items list appears

### Empty State
- [ ] Empty cart icon displays
- [ ] "سلة التسوق فارغة" message shows
- [ ] "ابدأ التسوق الآن" button appears
- [ ] Click button navigates correctly

### Cart Items Display
- [ ] All cart items are displayed
- [ ] Each item shows:
  - [ ] Product image (or placeholder if failed)
  - [ ] Product name
  - [ ] Price
  - [ ] Platform badge with correct color
  - [ ] Quantity controls
  - [ ] Delete button
  - [ ] "عرض المنتج" link

### Platform Badges
- [ ] Amazon badge is orange
- [ ] SHEIN badge is black
- [ ] AliExpress badge is red
- [ ] Taobao badge is orange
- [ ] Alibaba badge is orange
- [ ] Generic badge is blue

## 4. Cart Operations Testing

### Add to Cart
- [ ] Add product from WebView
- [ ] Success message appears
- [ ] Navigate to cart screen
- [ ] New item appears in list
- [ ] Item count updates
- [ ] Total price updates

### Update Quantity
- [ ] Click + button
- [ ] Quantity increases by 1
- [ ] Total price updates
- [ ] Click - button
- [ ] Quantity decreases by 1
- [ ] Total price updates
- [ ] Cannot decrease below 1
- [ ] Loading indicator during update

### Remove Item
- [ ] Click delete icon on item
- [ ] Item is removed from list
- [ ] Item count updates
- [ ] Total price updates
- [ ] If last item, empty state appears

### Clear Cart
- [ ] Add multiple items to cart
- [ ] Click delete icon in app bar
- [ ] Confirmation dialog appears
- [ ] Click "حذف"
- [ ] All items removed
- [ ] Empty state appears
- [ ] Click "إلغاء" in dialog
- [ ] Items remain in cart

### Pull to Refresh
- [ ] Pull down on cart screen
- [ ] Refresh indicator appears
- [ ] Cart items reload
- [ ] Indicator disappears

## 5. UI/UX Testing

### Layout
- [ ] RTL layout works correctly
- [ ] Text is right-aligned
- [ ] Icons are positioned correctly
- [ ] Spacing is consistent
- [ ] No overflow errors

### Images
- [ ] Product images load correctly
- [ ] Placeholder shows for failed images
- [ ] Images are cached (reload is instant)
- [ ] Images fit in container properly

### Colors
- [ ] Primary colors match app theme
- [ ] Platform badges have correct colors
- [ ] Text is readable on all backgrounds
- [ ] Buttons have proper contrast

### Animations
- [ ] Loading indicators animate smoothly
- [ ] List items animate when added/removed
- [ ] Button press animations work
- [ ] Refresh indicator animates

### Responsiveness
- [ ] Works on small screens
- [ ] Works on large screens
- [ ] Works on tablets
- [ ] Landscape orientation works

## 6. Error Handling Testing

### Network Errors
- [ ] Turn off internet
- [ ] Try to load cart
- [ ] Error message appears
- [ ] Turn on internet
- [ ] Pull to refresh
- [ ] Cart loads successfully

### Authentication Errors
- [ ] Log out user
- [ ] Try to add to cart
- [ ] Appropriate error handling
- [ ] Log in user
- [ ] Try again
- [ ] Works correctly

### Invalid Data
- [ ] Try to add product with no title
- [ ] Error message appears
- [ ] Cart not updated
- [ ] Try to add product with no price
- [ ] Handles gracefully

### Database Errors
- [ ] Temporarily disable RLS policy
- [ ] Try to load cart
- [ ] Error message appears
- [ ] Re-enable RLS policy
- [ ] Refresh
- [ ] Works correctly

## 7. Performance Testing

### Load Time
- [ ] Cart screen loads in < 2 seconds
- [ ] Images load progressively
- [ ] No janky animations
- [ ] Smooth scrolling

### Memory Usage
- [ ] No memory leaks
- [ ] Images are properly disposed
- [ ] BLoC is properly closed

### Database Queries
- [ ] Queries use indexes
- [ ] No N+1 query problems
- [ ] Real-time updates are efficient

## 8. Data Persistence Testing

### App Restart
- [ ] Add items to cart
- [ ] Close app completely
- [ ] Reopen app
- [ ] Navigate to cart
- [ ] Items are still there

### User Switch
- [ ] User A adds items to cart
- [ ] Log out
- [ ] Log in as User B
- [ ] User B's cart is empty
- [ ] User B cannot see User A's items

### Real-time Updates
- [ ] Open cart on Device A
- [ ] Add item on Device B (same user)
- [ ] Device A updates automatically
- [ ] Remove item on Device B
- [ ] Device A updates automatically

## 9. Edge Cases Testing

### Duplicate Products
- [ ] Add same product twice
- [ ] Two separate items created (expected behavior)
- [ ] Both can be managed independently

### Very Long Product Names
- [ ] Add product with very long name
- [ ] Name is truncated with ellipsis
- [ ] Full name visible on tap/expansion

### Very High Prices
- [ ] Add product with high price (e.g., $10,000)
- [ ] Price displays correctly
- [ ] Total calculates correctly

### Special Characters
- [ ] Add product with special characters in name
- [ ] Characters display correctly
- [ ] No encoding issues

### Multiple Currencies
- [ ] Add product with $ price
- [ ] Add product with € price
- [ ] Add product with ¥ price
- [ ] All display correctly
- [ ] Total shows "تقريبي" (approximate)

## 10. Security Testing

### RLS Policies
- [ ] User can only see own cart items
- [ ] User cannot see other users' items
- [ ] User cannot modify other users' items
- [ ] User cannot delete other users' items

### SQL Injection
- [ ] Try adding product with SQL in name
- [ ] No SQL injection occurs
- [ ] Data is properly escaped

### XSS Prevention
- [ ] Try adding product with HTML/JS in name
- [ ] No script execution
- [ ] Data is properly sanitized

## 11. Accessibility Testing

### Screen Reader
- [ ] All buttons have labels
- [ ] Images have alt text
- [ ] Semantic HTML used

### Keyboard Navigation
- [ ] Can navigate with keyboard
- [ ] Focus indicators visible
- [ ] Tab order is logical

### Color Contrast
- [ ] Text meets WCAG AA standards
- [ ] Buttons are distinguishable
- [ ] Error messages are clear

## 12. Localization Testing

### Arabic (RTL)
- [ ] All text is in Arabic
- [ ] Layout is right-to-left
- [ ] Numbers display correctly
- [ ] Dates format correctly

### Text Overflow
- [ ] Long Arabic text wraps correctly
- [ ] No text cutoff
- [ ] Ellipsis works properly

## Test Results Summary

### Pass/Fail Count
- Total Tests: ___
- Passed: ___
- Failed: ___
- Skipped: ___

### Critical Issues
1. _______________
2. _______________
3. _______________

### Minor Issues
1. _______________
2. _______________
3. _______________

### Recommendations
1. _______________
2. _______________
3. _______________

---

**Tested By**: _______________
**Date**: _______________
**App Version**: _______________
**Device**: _______________
**OS Version**: _______________

## Sign-off

- [ ] All critical tests passed
- [ ] All blockers resolved
- [ ] Feature ready for production

**Signature**: _______________
**Date**: _______________

