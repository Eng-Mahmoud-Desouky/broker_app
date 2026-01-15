# مثال عملي: استخراج بيانات منتج من Amazon

## السيناريو
المستخدم يتصفح صفحة منتج على Amazon ويريد إضافته للسلة

---

## 1. HTML الأصلي لصفحة المنتج

```html
<!DOCTYPE html>
<html>
<head>
    <title>Amazon Product Page</title>
</head>
<body>
    <div id="dp-container">
        <!-- عنوان المنتج -->
        <h1 id="productTitle" class="a-size-large">
            Wireless Bluetooth Earbuds with Charging Case
        </h1>
        
        <!-- السعر -->
        <div id="price_feature_div">
            <span class="a-price">
                <span class="a-offscreen">$49.99</span>
                <span class="a-price-whole">49</span>
                <span class="a-price-decimal">.</span>
                <span class="a-price-fraction">99</span>
            </span>
        </div>
        
        <!-- الصورة الرئيسية -->
        <img id="landingImage" 
             src="https://m.media-amazon.com/images/I/61abc123.jpg"
             alt="Product Image">
        
        <!-- معرض الصور -->
        <div id="altImages">
            <img src="https://m.media-amazon.com/images/I/61abc124.jpg">
            <img src="https://m.media-amazon.com/images/I/61abc125.jpg">
            <img src="https://m.media-amazon.com/images/I/61abc126.jpg">
        </div>
        
        <!-- التقييم -->
        <div id="averageCustomerReviews">
            <span class="a-icon-star">
                <span class="a-icon-alt">4.5 out of 5 stars</span>
            </span>
        </div>
    </div>
</body>
</html>
```

---

## 2. Platform Selectors - قواعد Amazon

```dart
// من ملف platform_selectors.dart
'amazon': {
  'title': [
    '#productTitle',           // المحاولة الأولى
    '#title',                  // احتياطي 1
    'h1[id*="title"]',        // احتياطي 2
    '.product-title'          // احتياطي 3
  ],
  'price': [
    '.a-price .a-offscreen',  // المحاولة الأولى (القيمة الكاملة)
    '#priceblock_ourprice',   // احتياطي 1
    '.a-price-whole',         // احتياطي 2
  ],
  'image': [
    '#landingImage',          // المحاولة الأولى
    '#imgBlkFront',          // احتياطي 1
    '#main-image',           // احتياطي 2
  ],
  'images': [
    '#altImages img',        // صور معرض المنتج
    '.imageThumbnail img',   // احتياطي
  ],
  'rating': [
    '.a-icon-star .a-icon-alt',
    '#acrPopover',
  ],
  'buttonColor': '#FF9900',  // لون برتقالي Amazon
}
```

---

## 3. JavaScript المحقون - الكود الكامل

```javascript
(function() {
  console.log('🚀 Starting cart button injection for platform: amazon');

  // === الجزء 1: دالة انتظار العناصر ===
  function waitForElement(selectors, timeout = 5000) {
    return new Promise((resolve) => {
      if (!Array.isArray(selectors)) selectors = [selectors];

      // تحقق من وجود العنصر مباشرة
      for (const selector of selectors) {
        const element = document.querySelector(selector);
        if (element) {
          console.log('✅ Found element immediately:', selector);
          resolve(true);
          return;
        }
      }

      // استخدم MutationObserver للانتظار
      const observer = new MutationObserver(() => {
        for (const selector of selectors) {
          const element = document.querySelector(selector);
          if (element) {
            console.log('✅ Found element after waiting:', selector);
            observer.disconnect();
            resolve(true);
            return;
          }
        }
      });

      observer.observe(document.body, {
        childList: true,
        subtree: true
      });

      // Timeout بعد 5 ثواني
      setTimeout(() => {
        observer.disconnect();
        resolve(false);
      }, timeout);
    });
  }

  // === الجزء 2: دالة تجربة عدة Selectors ===
  function trySelectors(selectors, getAttribute = null) {
    if (!Array.isArray(selectors)) selectors = [selectors];

    for (const selector of selectors) {
      try {
        const element = document.querySelector(selector);
        if (element) {
          if (getAttribute) {
            const value = element.getAttribute(getAttribute);
            if (value) {
              console.log(`✅ Found via selector "${selector}" [${getAttribute}]:`, value);
              return value;
            }
          }
          const text = element.innerText || element.textContent;
          if (text && text.trim()) {
            console.log(`✅ Found via selector "${selector}":`, text.trim());
            return text.trim();
          }
        }
      } catch (e) {
        console.log('⚠️ Selector failed:', selector, e);
      }
    }
    return null;
  }

  // === الجزء 3: دالة استخراج الصور ===
  function extractImages(selectors) {
    if (!Array.isArray(selectors)) selectors = [selectors];
    const images = new Set();
    
    for (const selector of selectors) {
      try {
        const elements = document.querySelectorAll(selector);
        elements.forEach(img => {
          const src = img.src || 
                     img.getAttribute('data-src') || 
                     img.getAttribute('data-lazy-src');
          
          if (src && !src.includes('data:image') && src.startsWith('http')) {
            images.add(src);
            console.log('📸 Found image:', src);
          }
        });
      } catch (e) {
        console.log('Image selector failed:', selector, e);
      }
    }
    
    return Array.from(images);
  }

  // === الجزء 4: دالة الاستخراج الرئيسية ===
  async function extractProductData() {
    console.log('⏳ Waiting for product data to load...');
    
    // انتظر ظهور عنوان المنتج
    await waitForElement(['#productTitle', '#title']);
    
    // delay صغير للتأكد من تحميل كل شيء
    await new Promise(resolve => setTimeout(resolve, 500));

    // استخرج البيانات
    const title = trySelectors(['#productTitle', '#title']);
    const price = trySelectors(['.a-price .a-offscreen', '#priceblock_ourprice']);
    const image = trySelectors(['#landingImage', '#imgBlkFront'], 'src');
    const images = extractImages(['#altImages img', '.imageThumbnail img']);
    const rating = trySelectors(['.a-icon-star .a-icon-alt']);

    console.log('✅ Product data extracted:', { title, price, image });

    return {
      title: title || 'No title found',
      price: price || 'Price not available',
      image: image || (images.length > 0 ? images[0] : ''),
      images: images,
      rating: rating || '',
      url: window.location.href,
      platform: 'amazon',
      timestamp: new Date().toISOString()
    };
  }

  // === الجزء 5: إنشاء زر السلة ===
  const button = document.createElement('div');
  button.id = 'flutter-cart-btn';
  button.innerHTML = '🛒 إضافة للسلة';
  button.style.cssText = `
    position: fixed;
    bottom: 20px;
    right: 20px;
    background: #FF9900;
    color: white;
    padding: 15px 25px;
    border-radius: 50px;
    cursor: pointer;
    z-index: 999999;
    font-weight: bold;
    box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    transition: transform 0.2s;
  `;

  // === الجزء 6: أحداث الزر ===
  button.addEventListener('click', async function() {
    try {
      button.innerHTML = '⏳ جاري الإضافة...';
      button.style.pointerEvents = 'none';

      // استخراج البيانات
      const productData = await extractProductData();

      // إرسال إلى Flutter
      window.flutter_inappwebview
        .callHandler('FlutterCartChannel', productData)
        .then(function(result) {
          button.innerHTML = '✅ تمت الإضافة';
          setTimeout(function() {
            button.innerHTML = '🛒 إضافة للسلة';
            button.style.pointerEvents = 'auto';
          }, 2000);
        })
        .catch(function(error) {
          console.error('❌ Error sending to Flutter:', error);
          button.innerHTML = '❌ فشل';
          setTimeout(function() {
            button.innerHTML = '🛒 إضافة للسلة';
            button.style.pointerEvents = 'auto';
          }, 2000);
        });
    } catch (error) {
      console.error('❌ Error extracting product data:', error);
      button.innerHTML = '❌ خطأ';
    }
  });

  // إضافة الزر للصفحة
  document.body.appendChild(button);
  console.log('✅ Cart button injected successfully');
})();
```

---

## 4. معالجة البيانات في Flutter

```dart
// في ملف webview_screen.dart

// === الجزء 1: إنشاء JavaScript Channel ===
controller.addJavaScriptHandler(
  handlerName: 'FlutterCartChannel',
  callback: (args) {
    if (args.isNotEmpty) {
      _handleCartData(args[0]); 
    }
  },
);

// === الجزء 2: معالجة البيانات المستلمة ===
void _handleCartData(dynamic data) {
  try {
    // تحويل البيانات
    Map<String, dynamic> productData;
    if (data is String) {
      productData = jsonDecode(data);
    } else if (data is Map) {
      productData = Map<String, dynamic>.from(data);
    }
    
    debugPrint('📦 Received cart data: $productData');
    
    // التحقق من البيانات
    if (productData['title'] == null || 
        productData['title'].toString().isEmpty ||
        productData['title'] == 'No title found') {
      _showSnackBar('لم نتمكن من استخراج بيانات المنتج', isError: true);
      return;
    }
    
    // إضافة للسلة
    _cartBloc.add(
      CartAddItem(
        productName: productData['title'] ?? 'Unknown Product',
        price: productData['price'] ?? 'Price not available',
        imageUrl: productData['image'],
        images: productData['images'] != null 
            ? List<String>.from(productData['images']) 
            : null,
        productUrl: productData['url'] ?? '',
        platform: productData['platform'] ?? 'unknown',
        rating: productData['rating'],
        metadata: productData,
      ),
    );
    
    _showSnackBar('تمت إضافة المنتج للسلة بنجاح');
    
  } catch (e) {
    debugPrint('⚠️ Error handling cart data: $e');
    _showSnackBar('حدث خطأ أثناء إضافة المنتج', isError: true);
  }
}
```

---

## 5. البيانات النهائية المحفوظة

```json
{
  "id": "cart_item_12345",
  "productName": "Wireless Bluetooth Earbuds with Charging Case",
  "price": "$49.99",
  "imageUrl": "https://m.media-amazon.com/images/I/61abc123.jpg",
  "images": [
    "https://m.media-amazon.com/images/I/61abc123.jpg",
    "https://m.media-amazon.com/images/I/61abc124.jpg",
    "https://m.media-amazon.com/images/I/61abc125.jpg",
    "https://m.media-amazon.com/images/I/61abc126.jpg"
  ],
  "productUrl": "https://www.amazon.com/dp/B08XYZ123",
  "platform": "amazon",
  "rating": "4.5 out of 5 stars",
  "userId": "user_456",
  "createdAt": "2024-01-14T18:48:52Z",
  "metadata": {
    "title": "Wireless Bluetooth Earbuds with Charging Case",
    "price": "$49.99",
    "image": "https://m.media-amazon.com/images/I/61abc123.jpg",
    "images": [...],
    "rating": "4.5 out of 5 stars",
    "url": "https://www.amazon.com/dp/B08XYZ123",
    "platform": "amazon",
    "timestamp": "2024-01-14T18:48:52Z"
  }
}
```

---

## 6. العرض في التطبيق

المستخدم يرى المنتج في صفحة السلة مع:
- ✅ الصورة الرئيسية
- ✅ العنوان الكامل
- ✅ السعر
- ✅ التقييم
- ✅ رابط للرجوع للمنتج
- ✅ معرض الصور الإضافية

---

## التسلسل الزمني للعملية

```
0.0s  → المستخدم يفتح صفحة منتج على Amazon
0.5s  → WebView يبدأ تحميل الصفحة
2.0s  → الصفحة تنتهي من التحميل (onLoadStop)
2.5s  → التطبيق يحقن JavaScript في الصفحة
2.6s  → يظهر زر "إضافة للسلة" عائم
---
5.0s  → المستخدم يضغط على زر "إضافة للسلة"
5.1s  → JavaScript يبدأ استخراج البيانات
5.2s  → waitForElement() يتحقق من وجود #productTitle
5.2s  → trySelectors() يستخرج العنوان
5.3s  → trySelectors() يستخرج السعر
5.3s  → trySelectors() يستخرج الصورة الرئيسية
5.4s  → extractImages() يستخرج كل الصور
5.4s  → trySelectors() يستخرج التقييم
5.5s  → JavaScript يرسل البيانات عبر callHandler()
5.5s  → Flutter يستقبل البيانات في _handleCartData()
5.6s  → التحقق من صحة البيانات
5.7s  → Cart Bloc يضيف المنتج للسلة
5.8s  → حفظ البيانات في Supabase
5.9s  → عرض رسالة "تمت الإضافة بنجاح"
6.0s  → تحديث UI
```

---

## لماذا نستخدم قائمة من Selectors؟

لأن Amazon (وغيرها) قد تغير بنية HTML:

```javascript
// المحاولة 1: التصميم الجديد
const title = document.querySelector('#productTitle');

// المحاولة 2: التصميم القديم
if (!title) {
  title = document.querySelector('#title');
}

// المحاولة 3: أي h1 يحتوي "title" في id
if (!title) {
  title = document.querySelector('h1[id*="title"]');
}

// المحاولة 4: أي عنصر بـ class="product-title"
if (!title) {
  title = document.querySelector('.product-title');
}
```

هذا يضمن نجاح الاستخراج حتى لو غيرت Amazon تصميمها!
