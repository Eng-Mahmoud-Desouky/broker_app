# 🏗️ Cart Feature Architecture Diagram

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER INTERFACE                          │
│  ┌──────────────────┐              ┌──────────────────┐        │
│  │  WebView Screen  │              │   Cart Screen    │        │
│  │  (Product Page)  │              │  (Cart Items)    │        │
│  └────────┬─────────┘              └────────┬─────────┘        │
│           │                                  │                   │
│           │ Floating Button                  │ View/Manage       │
│           │ "🛒 إضافة للسلة"                │ Cart Items        │
└───────────┼──────────────────────────────────┼───────────────────┘
            │                                  │
            ▼                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER (BLoC)                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                      CartBloc                             │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐         │  │
│  │  │ CartEvent  │→ │ CartState  │→ │   Emit     │         │  │
│  │  └────────────┘  └────────────┘  └────────────┘         │  │
│  │                                                            │  │
│  │  Events:                    States:                       │  │
│  │  • CartAddItem             • CartLoading                  │  │
│  │  • CartLoadItems           • CartLoaded                   │  │
│  │  • CartUpdateQuantity      • CartEmpty                    │  │
│  │  • CartRemoveItem          • CartError                    │  │
│  │  • CartClear               • CartItemAdded                │  │
│  └──────────────────┬───────────────────────────────────────┘  │
└─────────────────────┼──────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER (Business Logic)              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                      Use Cases                            │  │
│  │  ┌────────────────┐  ┌────────────────┐                 │  │
│  │  │  AddToCart     │  │ GetCartItems   │                 │  │
│  │  └────────────────┘  └────────────────┘                 │  │
│  │  ┌────────────────┐  ┌────────────────┐                 │  │
│  │  │UpdateQuantity  │  │ RemoveFromCart │                 │  │
│  │  └────────────────┘  └────────────────┘                 │  │
│  │  ┌────────────────┐                                      │  │
│  │  │   ClearCart    │                                      │  │
│  │  └────────────────┘                                      │  │
│  └──────────────────┬───────────────────────────────────────┘  │
│                     │                                           │
│  ┌──────────────────▼───────────────────────────────────────┐  │
│  │              CartRepository (Interface)                   │  │
│  │  • addToCart()                                            │  │
│  │  • getCartItems()                                         │  │
│  │  • updateQuantity()                                       │  │
│  │  • removeFromCart()                                       │  │
│  │  • clearCart()                                            │  │
│  │  • watchCartItems() → Stream                             │  │
│  └──────────────────┬───────────────────────────────────────┘  │
└─────────────────────┼──────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATA LAYER                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         CartRepositoryImpl (Implementation)               │  │
│  │  • Implements CartRepository interface                    │  │
│  │  • Handles error mapping                                  │  │
│  │  • Validates user authentication                          │  │
│  └──────────────────┬───────────────────────────────────────┘  │
│                     │                                           │
│  ┌──────────────────▼───────────────────────────────────────┐  │
│  │           CartRemoteDataSource                            │  │
│  │  • Supabase client integration                            │  │
│  │  • CRUD operations                                        │  │
│  │  • Real-time subscriptions                                │  │
│  └──────────────────┬───────────────────────────────────────┘  │
│                     │                                           │
│  ┌──────────────────▼───────────────────────────────────────┐  │
│  │              CartItemModel                                │  │
│  │  • JSON serialization                                     │  │
│  │  • Entity conversion                                      │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────┼──────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    SUPABASE BACKEND                             │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   cart_items Table                        │  │
│  │  Columns:                                                 │  │
│  │  • id (UUID, PK)                                          │  │
│  │  • user_id (UUID, FK → auth.users)                       │  │
│  │  • product_name (TEXT)                                    │  │
│  │  • price (TEXT)                                           │  │
│  │  • image_url (TEXT)                                       │  │
│  │  • images (JSONB)                                         │  │
│  │  • product_url (TEXT)                                     │  │
│  │  • platform (TEXT)                                        │  │
│  │  • quantity (INTEGER)                                     │  │
│  │  • rating (TEXT)                                          │  │
│  │  • metadata (JSONB)                                       │  │
│  │  • created_at (TIMESTAMP)                                 │  │
│  │  • updated_at (TIMESTAMP)                                 │  │
│  │                                                            │  │
│  │  Indexes:                                                 │  │
│  │  • idx_cart_items_user_id                                │  │
│  │  • idx_cart_items_platform                               │  │
│  │  • idx_cart_items_created_at                             │  │
│  │                                                            │  │
│  │  RLS Policies:                                            │  │
│  │  • Users can view own cart items                         │  │
│  │  • Users can insert to own cart                          │  │
│  │  • Users can update own cart items                       │  │
│  │  • Users can delete own cart items                       │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## WebView Integration Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    E-COMMERCE WEBSITE                           │
│  (Amazon, SHEIN, AliExpress, Taobao, Alibaba)                  │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │              Product Page DOM                           │    │
│  │  • <h1 id="productTitle">Product Name</h1>            │    │
│  │  • <span class="price">$29.99</span>                  │    │
│  │  • <img id="mainImage" src="...">                     │    │
│  │  • <div class="rating">4.5 stars</div>                │    │
│  └────────────────────────────────────────────────────────┘    │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       │ Page Load Complete
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│              JAVASCRIPT INJECTION (Flutter)                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  1. Detect Platform (from URL)                           │  │
│  │     • amazon.com → Amazon selectors                      │  │
│  │     • shein.com → SHEIN selectors                        │  │
│  │     • etc.                                                │  │
│  │                                                            │  │
│  │  2. Inject Extraction Script                             │  │
│  │     • Platform-specific CSS selectors                    │  │
│  │     • Fallback selectors for reliability                 │  │
│  │     • Image extraction logic                             │  │
│  │                                                            │  │
│  │  3. Create Floating Button                               │  │
│  │     • Position: fixed, bottom-right                      │  │
│  │     • Platform-specific color                            │  │
│  │     • Click handler attached                             │  │
│  └──────────────────────────────────────────────────────────┘  │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       │ User Clicks Button
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│              JAVASCRIPT EXECUTION                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  function extractProductData() {                          │  │
│  │    const title = querySelector('#productTitle').text;    │  │
│  │    const price = querySelector('.price').text;           │  │
│  │    const image = querySelector('#mainImage').src;        │  │
│  │    const images = querySelectorAll('.thumbs').map(...);  │  │
│  │    const rating = querySelector('.rating').text;         │  │
│  │                                                            │  │
│  │    return {                                               │  │
│  │      title, price, image, images, rating,                │  │
│  │      url: window.location.href,                          │  │
│      platform: 'amazon'                                    │  │
│  │    };                                                     │  │
│  │  }                                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       │ Send via JavaScript Handler
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│              FLUTTER JAVASCRIPT BRIDGE                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  window.flutter_inappwebview.callHandler(                │  │
│  │    'FlutterCartChannel',                                 │  │
│  │    productData                                            │  │
│  │  )                                                        │  │
│  └──────────────────┬───────────────────────────────────────┘  │
└─────────────────────┼──────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│              FLUTTER HANDLER                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  void _handleCartData(dynamic data) {                    │  │
│  │    // Parse JSON                                          │  │
│  │    // Validate data                                       │  │
│  │    // Dispatch to CartBloc                               │  │
│  │                                                            │  │
│  │    _cartBloc.add(CartAddItem(                            │  │
│  │      productName: data['title'],                         │  │
│  │      price: data['price'],                               │  │
│  │      imageUrl: data['image'],                            │  │
│  │      // ...                                               │  │
│  │    ));                                                    │  │
│  │  }                                                        │  │
│  └──────────────────┬───────────────────────────────────────┘  │
└─────────────────────┼──────────────────────────────────────────┘
                      │
                      ▼
                 [CartBloc]
                      │
                      ▼
                 [Repository]
                      │
                      ▼
                 [Supabase]
                      │
                      ▼
              ✅ Success Message
```

## Data Flow Diagram

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│   User   │────▶│   UI     │────▶│   BLoC   │────▶│ Use Case │
│  Action  │     │  Event   │     │  Event   │     │  Execute │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
                                                          │
                                                          ▼
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│   UI     │◀────│   BLoC   │◀────│Repository│◀────│   Data   │
│  Update  │     │  State   │     │  Result  │     │  Source  │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
                                                          │
                                                          ▼
                                                    ┌──────────┐
                                                    │ Supabase │
                                                    │ Database │
                                                    └──────────┘
```

## Component Interaction

```
WebViewScreen                CartScreen
     │                           │
     │ Add Item                  │ Load Items
     ▼                           ▼
  CartBloc ◀──────────────────▶ CartBloc
     │                           │
     │ CartAddItem               │ CartLoadItems
     ▼                           ▼
  AddToCart                   GetCartItems
     │                           │
     ▼                           ▼
CartRepository ◀──────────────▶ CartRepository
     │                           │
     ▼                           ▼
CartRemoteDataSource ◀────────▶ CartRemoteDataSource
     │                           │
     ▼                           ▼
  Supabase ◀──────────────────▶ Supabase
```

## State Management Flow

```
Initial State: CartInitial
       │
       │ CartLoadItems event
       ▼
   CartLoading
       │
       ├─── Success ──▶ CartLoaded (with items)
       │                    │
       │                    ├─── CartUpdateQuantity ──▶ CartUpdatingQuantity ──▶ CartLoaded
       │                    │
       │                    ├─── CartRemoveItem ──▶ CartRemovingItem ──▶ CartLoaded/CartEmpty
       │                    │
       │                    └─── CartClear ──▶ CartClearing ──▶ CartEmpty
       │
       ├─── Empty ──▶ CartEmpty
       │
       └─── Error ──▶ CartError
```

---

**Legend:**
- `│` `▼` `◀` `▶` : Data flow direction
- `┌─┐` : Component boundary
- `→` : Synchronous call
- `⇒` : Asynchronous operation

