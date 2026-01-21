# 📊 Pricing System and Workflow Documentation - Zaid Express

## 📋 Table of Contents
1. [Pricing System Overview](#pricing-system-overview)
2. [Final Price Components](#final-price-components)
3. [Price Calculation](#price-calculation)
4. [Promo Codes](#promo-codes)
5. [Complete Workflow](#complete-workflow)
6. [Stakeholders](#stakeholders)

---

## 🎯 Pricing System Overview

The pricing system is designed to calculate the final price for orders based on several factors:

### Key Factors Affecting Price:
1. **Product Prices** - Original prices from e-commerce platforms
2. **Product Weight** - Total weight in kilograms
3. **Shipping Method** - Air or Sea freight
4. **Broker Commission** - Percentage of total
5. **Promo Codes** - Optional discounts

### 📍 Data Source:
All pricing settings are stored in the `pricing_settings` table في Supabase:

```sql
CREATE TABLE public.pricing_settings (
    id uuid PRIMARY KEY,
    broker_commission_percent numeric NOT NULL DEFAULT 5.0,  -- Broker commission (%)
    air_freight_price_per_kg numeric NOT NULL DEFAULT 10.0,  -- Air shipping price (USD/kg)
    sea_freight_price_per_kg numeric NOT NULL DEFAULT 5.0,   -- Sea shipping price (USD/kg)
    updated_at timestamp with time zone DEFAULT now(),
    updated_by uuid REFERENCES auth.users(id)
);
```

---

## 💰 Final Price Components

### 1️⃣ **Products Subtotal**
```
Subtotal = Sum of (Product Price × Quantity) for each item
```

**Example:**
- Product A: $50 × 2 = $100
- Product B: $30 × 1 = $30
- **Total: $130**

### 2️⃣ **Shipping Cost**
```
Shipping Cost = Total Weight (kg) × Shipping Rate per kg
```

**Rates:**
- Air Freight: $10 per kg
- Sea Freight: $5 per kg

**Example (Air):**
- Product Weight: 8 kg
- Shipping Cost: 8 × $10 = **$80**

### 3️⃣ **Broker Commission**
```
Commission = (Subtotal + Shipping Cost) × Commission Rate%
```

**Default Rate:** 5%

**Example:**
- (130 + 80) × 5% = $210 × 0.05 = **$10.50**

### 4️⃣ **Final Price (Before Discount)**
```
Final Price = Subtotal + Shipping Cost + Commission
```

**Example:**
- $130 + $80 + $10.50 = **$220.50**

### 5️⃣ **Discount (If Applied)**
```
Discount Amount = Final Price × Discount Percentage%
Final Price After Discount = Final Price - Discount Amount
```

**Example (10% discount):**
- Discount Amount: $220.50 × 10% = $22.05
- **Final Price: $198.45**

---

## 🧮 Price Calculation

### Code Implementation:
Price calculation is done in the `PricingCubit`:

```dart
double calculateExpectedTotal({
  required List<CartItem> items,
  required PricingSettings settings,
  required ShippingMethod shippingMethod,
}) {
  double subtotal = 0;           // Products subtotal
  double totalWeight = 0;        // Total weight

  // 1. Calculate subtotal and weight
  for (final item in items) {
    final price = item.priceValue ?? 0;
    subtotal += price * item.quantity;
    totalWeight += (item.weightKg ?? 0) * item.quantity;
  }

  // 2. Select appropriate shipping rate
  final shippingRate = (shippingMethod == ShippingMethod.air)
      ? settings.airFreightPricePerKg
      : settings.seaFreightPricePerKg;

  // 3. Calculate shipping cost
  final shippingCost = totalWeight * shippingRate;

  // 4. Calculate commission
  final commission = (subtotal + shippingCost) * (settings.brokerCommissionPercent / 100);

  // 5. Final price
  return subtotal + shippingCost + commission;
}
```

### Complete Example:

**Cart Contains:**
- Smartphone: $400, Weight: 0.5 kg, Quantity: 1
- Headphones: $50, Weight: 0.3 kg, Quantity: 2

**Settings:**
- Shipping Method: Air ($10/kg)
- Broker Commission: 5%

**Calculation:**
1. Subtotal: ($400 × 1) + ($50 × 2) = **$500**
2. Total Weight: (0.5 × 1) + (0.3 × 2) = **1.1 kg**
3. Shipping Cost: 1.1 × $10 = **$11**
4. Commission: ($500 + $11) × 5% = **$25.55**
5. **Final Price: $536.55**

---

## 🎟️ Promo Codes

### Database Table:
```sql
CREATE TABLE public.promo_codes (
    id uuid PRIMARY KEY,
    code text NOT NULL UNIQUE,         -- Promo code (e.g., SUMMER2024)
    percentage numeric NOT NULL,       -- Discount percentage (e.g., 10 = 10%)
    is_active boolean DEFAULT true,    -- Is code active?
    expires_at timestamp               -- Expiration date
);
```

### How Promo Codes Work:

#### 1. Code Validation:
Calls the `validate_promo_code` function في Supabase:

```sql
SELECT * FROM validate_promo_code('SUMMER2024', 536.55);
```

**Response:**
```json
{
  "is_valid": true,
  "percentage": 10,
  "discount_amount": 53.66,
  "final_price": 482.89,
  "error_message": null
}
```

#### 2. Validation Requirements:
- ✅ Code exists in database
- ✅ Code is active (`is_active = true`)
- ✅ Code not expired (`expires_at > now()`)

#### 3. Error Messages:
| Condition | Message |
|-----------|---------|
| Code not found | "كود الخصم غير صالح أو منتهي الصلاحية" |
| Code expired | "كود الخصم غير صالح أو منتهي الصلاحية" |
| Code inactive | "كود الخصم غير صالح أو منتهي الصلاحية" |
| Empty field | "الرجاء إدخال كود الخصم" |

#### 4. Discount Preview in App:
When a valid code is entered, displays:
- ✅ Success message: "تم تطبيق الخصم بنجاح!"
- 💲 Original price (strikethrough)
- 🏷️ Discount percentage and amount
- 💚 Final price after discount (bold)

---

## 🔄 Complete Workflow

### Phase 1: End User - Mobile App 📱

#### **Step 1: Browse Products**
1. User opens the app
2. Browses offers from home page
3. Enters shopping page (WebView)
4. Chooses shopping platform:
   - Amazon
   - AliExpress
   - SHEIN
   - Taobao
   - Alibaba

#### **Step 2: Add Products to Cart**
1. User browses products in WebView
2. When clicking "Add to Cart" button:
   - Product data is automatically extracted:
     - Name
     - Price
     - Images
     - URL
     - Weight (if available)
     - Dimensions (if available)
   - Product is saved to `cart_items` table in Supabase
   - Confirmation message appears

**📊 Stored Data:**
```json
{
  "product_name": "iPhone 15 Pro",
  "price": "$999.00",
  "weight_kg": 0.187,
  "dimensions": {"length": 14.7, "width": 7.1, "height": 0.83, "unit": "cm"},
  "platform": "amazon",
  "quantity": 1,
  "product_url": "https://www.amazon.com/...",
  "image_url": "https://..."
}
```

#### **Step 3: Review Cart**
1. User opens cart page
2. Sees list of all products
3. Can:
   - Modify quantity
   - Remove products
   - Proceed to checkout

#### **Step 4: Create Order**
1. User clicks "Complete Order"
2. Navigates to `CreateOrderScreen`

**In This Screen:**

##### a) Choose/Add Address:
- If no address: Add new address
- If has addresses: Choose from list
- Required data:
  - Full name
  - Phone number
  - Country
  - City
  - State/Province
  - Street address
  - Building number
  - Apartment number
  - Postal code

##### b) Choose Shipping Method:
- 🚢 **Sea Freight**: Cheaper, slower ($5/kg)
- ✈️ **Air Freight**: More expensive, faster ($10/kg)

##### c) Calculate Estimated Price:
- Pricing settings fetched from Supabase
- Price calculated using `PricingCubit`
- Displays:
  - Products subtotal
  - Total weight
  - Shipping cost
  - Commission
  - **Expected final price**

##### d) Enter Promo Code (Optional):
1. User enters promo code
2. Clicks "Apply" button
3. Code verified via Supabase RPC
4. If valid:
   - ✅ Green box appears
   - Shows original price (strikethrough)
   - Shows discount amount and percentage
   - Shows final price after discount
5. If invalid:
   - ❌ Error message appears

##### e) Confirm Order:
1. User clicks "Confirm Order"
2. New record created in `orders` table
3. Products moved from `cart_items` to `order_items`
4. Order reference number generated (`reference_number`)
5. Initial order status: `under_review`
6. Cart is cleared
7. Success message appears

**📊 Saved Order Data:**
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "reference_number": "ORD-2024-0001",
  "shipping_address": {...},
  "shipping_method": "جوي",
  "total_weight_kg": 8.5,
  "total_price": 482.89,
  "currency": "USD",
  "status": "under_review",
  "discount_amount": 53.66,
  "promo_code_used": "SUMMER2024"
}
```

---

### Phase 2: Database (Supabase) ☁️

#### Supabase Role:

##### 1. Storage:
- **`cart_items`**: Shopping cart for each user
- **`orders`**: Confirmed orders
- **`order_items`**: Products for each order
- **`pricing_settings`**: Pricing settings
- **`promo_codes`**: Promo codes
- **`user_addresses`**: User addresses
- **`order_status_history`**: Order status update history

##### 2. Processing:
- **`validate_promo_code` function**: Promo code validation
- **Row Level Security (RLS)**: Permission control
  - Users: Read their data only
  - Admins: Read and modify all data

##### 3. Security:
- Authentication via phone + OTP
- Custom permissions per table
- Sensitive data encryption

---

### Phase 3: Admin Panel 💻

#### Access:
- URL: `https://admin.example.com`
- Login: Email + Password
- Roles:
  - **Super Admin**: Full permissions
  - **Admin**: Manage orders and users
  - **Support**: Technical support only

#### Pages and Features:

##### 1️⃣ **Dashboard**
- Today's orders count
- New orders
- User count
- Revenue

##### 2️⃣ **Orders Management**

**Features:**
- View all orders
- Search by reference number, customer name, or phone
- Filter by status
- View order details:
  - Products (name, image, link, price, quantity)
  - Customer information
  - Address
  - Total price
  - Shipping method
  - Promo code (if any)

**Update Order Status:**

Admin can change order status through these stages:

| # | Status | Description | Action |
|---|--------|-------------|--------|
| 1 | `under_review` | Under Review | Verify order and products |
| 2 | `purchasing` | Purchasing | Buy products from platforms |
| 3 | `purchased` | Purchased | Confirm successful purchase |
| 4 | `in_china_warehouse` | In China Warehouse | Products arrived at warehouse |
| 5 | `shipping_to_iraq` | Shipping to Iraq | Shipment in transit |
| 6 | `in_iraq_warehouse` | In Iraq Warehouse | Shipment arrived in Iraq |
| 7 | `ready_for_delivery` | Ready for Delivery | Coordinate with customer |
| 8 | `delivered` | Delivered | Order complete ✅ |
| 9 | `cancelled` | Cancelled | Order cancelled ❌ |

**Add Shipment Images:**
- Upload product photos at warehouse
- Package wrapping photos
- Purchase receipts

**Add Notes:**
- Internal notes
- Customer alerts

##### 3️⃣ **Users Management**
- View all users
- Search by name or phone
- View each user's order history
- Activate/deactivate accounts

##### 4️⃣ **Promo Codes Management**

**Features:**
- View all promo codes
- Add new code:
  - Code (e.g., SUMMER2024)
  - Discount percentage (%)
  - Expiration date
- Edit existing codes:
  - Change percentage
  - Extend expiration
  - Activate/deactivate
- Delete codes

**Example:**
```
Code: WELCOME10
Percentage: 10%
Expires: 2024-12-31
Status: Active ✅
```

##### 5️⃣ **Pricing Settings**

**Admin can modify:**
- Air freight prices (USD/kg)
- Sea freight prices (USD/kg)
- Broker commission percentage (%)

**Example:**
```
Air Freight: $10/kg
Sea Freight: $5/kg
Broker Commission: 5%
```

⚠️ **Important Note:**
- Any changes to settings affect new orders only
- Old orders retain prices from time of creation

##### 6️⃣ **Offers Management**
- Create promotional offers
- Set offer image
- Set start and end dates
- Link offer to URL or product

##### 7️⃣ **Content Management**
- Edit static pages:
  - About Us
  - Terms and Conditions
  - Privacy Policy
  - FAQ

##### 8️⃣ **Support Center**
- View support messages
- Reply to customer inquiries
- Assign tickets to agents

---

### Phase 4: User Notifications 🔔

#### When does user receive notifications?

| Event | Notification |
|-------|--------------|
| Order confirmed | "Your order #ORD-2024-0001 received" |
| Purchase started | "Purchasing your products" |
| Purchase completed | "Products purchased successfully" |
| Arrived at warehouse | "Products arrived at warehouse" |
| Shipped to Iraq | "Your order shipped to Iraq" |
| Ready for delivery | "Your order ready for delivery" |
| Delivered | "Order delivered successfully ✅" |

**Mechanism:**
1. Admin updates order status in Admin Panel
2. `orders` table updated in Supabase
3. Notification sent to user via Firebase Cloud Messaging (FCM)
4. Notification appears in app
5. Notification saved to `app_notifications` table

---

## 👥 Stakeholders

### 1. **End User**
- **Device**: Mobile app (iOS/Android)
- **Functions**:
  - Browse products
  - Add to cart
  - Create orders
  - Track shipments
  - Use promo codes
  - Contact support

### 2. **Admin**
- **Device**: Web admin panel
- **Functions**:
  - Manage orders
  - Update order statuses
  - Manage promo codes
  - Modify pricing settings
  - Manage offers
  - Manage users

### 3. **Supabase System**
- **Role**: Database and server
- **Functions**:
  - Data storage
  - Authentication and verification
  - Process requests
  - Manage permissions
  - Execute SQL functions

### 4. **Firebase**
- **Role**: Support services
- **Functions**:
  - Send push notifications (FCM)
  - Analytics

---

## 📊 Workflow Flowchart

```
┌─────────────────┐
│   End User      │
└────────┬────────┘
         │
         │ 1. Browse Products
         ▼
┌─────────────────┐
│    WebView      │
│  (Amazon, etc)  │
└────────┬────────┘
         │
         │ 2. Add to Cart
         ▼
┌─────────────────┐
│    Supabase     │
│  cart_items     │
└────────┬────────┘
         │
         │ 3. Review Cart
         ▼
┌─────────────────┐
│  CreateOrder    │
│    Screen       │
└────────┬────────┘
         │
         ├─► Choose Address
         │
         ├─► Choose Shipping Method
         │
         ├─► Fetch Pricing Settings
         ▼
┌─────────────────┐
│  PricingCubit   │
│  Calculate      │
└────────┬────────┘
         │
         ├─► Products Subtotal
         ├─► Shipping Cost
         ├─► Commission
         ▼
         Expected Price
         │
         │ 4. (Optional) Apply Promo Code
         ▼
┌─────────────────┐
│    Supabase     │
│ validate_promo  │
└────────┬────────┘
         │
         ├─► Valid ✅
         │   └─► Calculate Discount
         │
         └─► Invalid ❌
             └─► Error Message
         │
         │ 5. Confirm Order
         ▼
┌─────────────────┐
│    Supabase     │
│     orders      │
└────────┬────────┘
         │
         │ Notify User 🔔
         │
         ▼
┌─────────────────┐
│  Admin Panel    │
│  (Web)          │
└────────┬────────┘
         │
         │ 6. Admin Reviews Order
         │
         ├─► under_review
         ├─► purchasing
         ├─► purchased
         ├─► in_china_warehouse
         ├─► shipping_to_iraq
         ├─► in_iraq_warehouse
         ├─► ready_for_delivery
         └─► delivered ✅
         │
         │ 7. Auto Notifications
         ▼
┌─────────────────┐
│   Firebase      │
│      FCM        │
└────────┬────────┘
         │
         │ 8. Notify User
         ▼
┌─────────────────┐
│   End User      │
│ Receives Notif  │
└─────────────────┘
```

---

## 🎯 Quick Summary

### Final Price Calculation:
```
Final Price = [
    (Products Subtotal) 
    + (Weight × Shipping Rate)
    + ((Subtotal + Shipping) × Commission Rate)
] - Discount Amount (if any)
```

### Order Stages:
```
1. Review → 2. Purchasing → 3. Purchased → 4. China Warehouse 
→ 5. Shipping to Iraq → 6. Iraq Warehouse → 7. Ready for Delivery 
→ 8. Delivered ✅
```

### Stakeholders:
```
End User (Mobile App) 
    ↕️
Supabase (Database + API)
    ↕️
Admin Panel (Web Dashboard)
    ↕️
Firebase (Notifications)
```

---

**Last Updated:** January 21, 2026
**Version:** 1.0
