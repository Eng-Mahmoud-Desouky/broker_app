# شرح تفصيلي لآلية استخراج بيانات المنتجات من المواقع الإلكترونية

## نظرة عامة على النظام

التطبيق يستخدم تقنية **Web Scraping** (استخراج البيانات من صفحات الويب) لسحب بيانات المنتجات من مواقع التسوق الإلكترونية المختلفة وإضافتها إلى سلة المشتريات (Cart) الخاصة بالمستخدم داخل التطبيق.

---

## المكونات الأساسية للنظام

### 1. **WebView Screen** (`webview_screen.dart`)
هذا هو الشاشة التي تعرض المواقع الإلكترونية داخل التطبيق باستخدام متصفح مدمج (WebView).

### 2. **Platform Selectors** (`platform_selectors.dart`)
ملف يحتوي على قواعد استخراج البيانات (CSS Selectors) الخاصة بكل منصة تسوق إلكترونية.

### 3. **Cart Bloc** (`cart_bloc.dart`)
هو المسؤول عن إدارة عمليات السلة (Cart) مثل إضافة المنتجات وحذفها.

---

## كيف يعمل النظام خطوة بخطوة؟

### **المرحلة 1: فتح الموقع في WebView**

1. **المستخدم يضغط على منصة تسوق معينة** (مثل AliExpress أو Amazon أو SHEIN)
2. **التطبيق يفتح WebView Screen** مع رابط الموقع المحدد
3. **WebView يبدأ بتحميل الصفحة** مع إعدادات خاصة:
   - تفعيل JavaScript
   - تفعيل Cookies
   - ضبط User-Agent ليظهر التطبيق وكأنه متصفح حقيقي
   - منع الإعلانات والتتبع

```dart
// من ملف webview_screen.dart - إعدادات WebView
initialSettings: InAppWebViewSettings(
  javaScriptEnabled: true,  // لتنفيذ JavaScript
  domStorageEnabled: true,  // لتخزين البيانات
  userAgent: _getEnhancedUserAgent(), // لمحاكاة متصفح حقيقي
  thirdPartyCookiesEnabled: true, // لدعم المواقع الصينية
)
```

---

### **المرحلة 2: حقن كود JavaScript في الصفحة**

بعد تحميل الصفحة بنجاح، يقوم التطبيق بحقن (Inject) كود JavaScript في صفحة الويب. هذا الكود يقوم بما يلي:

#### 2.1 إضافة زر "إضافة للسلة" العائم

```javascript
// زر عائم يظهر في أسفل يمين الصفحة
const button = document.createElement('div');
button.innerHTML = '🛒 إضافة للسلة';
button.style.cssText = `
  position: fixed;
  bottom: 20px;
  right: 20px;
  background: #color; // لون خاص بكل منصة
  ...
`;
document.body.appendChild(button);
```

#### 2.2 إنشاء وظيفة استخراج البيانات `extractProductData()`

هذه الوظيفة هي قلب النظام، وتعمل كالتالي:

**أ) انتظار تحميل العناصر المهمة:**
```javascript
function waitForElement(selectors, timeout = 5000) {
  // تنتظر حتى يظهر عنصر معين في الصفحة
  // مثل عنوان المنتج أو السعر
  // تستخدم MutationObserver لمراقبة التغييرات في DOM
}
```

**ب) محاولة استخراج البيانات من عدة عناصر (Fallback Strategy):**
```javascript
function trySelectors(selectors) {
  // تجرب قائمة من CSS Selectors
  // حتى تجد واحد يحتوي على البيانات المطلوبة
  for (const selector of selectors) {
    const element = document.querySelector(selector);
    if (element && element.innerText) {
      return element.innerText.trim();
    }
  }
  return null;
}
```

**ج) استخراج البيانات الفعلية:**
```javascript
const title = trySelectors(['#productTitle', '#title', 'h1[class*="title"]']);
const price = trySelectors(['.a-price .a-offscreen', '#priceblock_ourprice']);
const image = trySelectors(['#landingImage', '#main-image'], 'src');
const images = extractImages(['#altImages img', '.imageThumbnail img']);
```

---

### **المرحلة 3: CSS Selectors الخاصة بكل منصة**

كل موقع تسوق له بنية HTML مختلفة، لذلك نستخدم CSS Selectors مختلفة:

#### مثال: Amazon
```dart
'amazon': {
  'title': ['#productTitle', '#title', 'h1[id*="title"]'],
  'price': ['.a-price .a-offscreen', '#priceblock_ourprice'],
  'image': ['#landingImage', '#imgBlkFront'],
  'images': ['#altImages img', '.imageThumbnail img'],
  'rating': ['.a-icon-star .a-icon-alt'],
}
```

#### مثال: AliExpress
```dart
'aliexpress': {
  'title': ['h1[data-pl="product-title"]', '.product-title-text'],
  'price': ['span[class*="price-default--current"]', '.product-price-value'],
  'image': ['img[class*="magnifier-image"]', 'img[data-role="mainImage"]'],
  'images': ['div[class*="thumb-item"] img', 'ul[class*="images-view"] img'],
}
```

#### مثال: SHEIN
```dart
'shein': {
  'title': ['.product-intro__head-name', 'h1[class*="title"]'],
  'price': ['.original', '.product-intro__price'],
  'image': ['.product-intro__main-img img', '.sui-img__img'],
}
```

---

### **المرحلة 4: استخراج البيانات عند الضغط على الزر**

عندما يضغط المستخدم على زر "إضافة للسلة":

```javascript
button.addEventListener('click', async function() {
  // 1. تغيير نص الزر إلى "جاري الإضافة..."
  button.innerHTML = '⏳ جاري الإضافة...';
  
  // 2. استخراج بيانات المنتج
  const productData = await extractProductData();
  
  // 3. إرسال البيانات لـ Flutter
  window.flutter_inappwebview.callHandler('FlutterCartChannel', productData)
    .then(function(result) {
      button.innerHTML = '✅ تمت الإضافة';
    });
});
```

البيانات المستخرجة تكون بهذا الشكل:
```json
{
  "title": "اسم المنتج",
  "price": "السعر",
  "image": "رابط الصورة الرئيسية",
  "images": ["صورة1", "صورة2", "صورة3"],
  "rating": "التقييم",
  "description": "الوصف",
  "currency": "USD",
  "reviewCount": "عدد المراجعات",
  "url": "رابط المنتج",
  "platform": "amazon",
  "timestamp": "2024-01-14T18:48:52Z"
}
```

---

### **المرحلة 5: قناة الاتصال بين JavaScript و Flutter**

يتم إنشاء **JavaScript Channel** لنقل البيانات من JavaScript إلى Flutter:

```dart
// في webview_screen.dart
controller.addJavaScriptHandler(
  handlerName: 'FlutterCartChannel',
  callback: (args) {
    if (args.isNotEmpty) {
      _handleCartData(args[0]); // معالجة البيانات
    }
  },
);
```

---

### **المرحلة 6: معالجة البيانات في Flutter**

```dart
void _handleCartData(dynamic data) {
  // 1. تحويل البيانات إلى Map
  Map<String, dynamic> productData;
  if (data is String) {
    productData = jsonDecode(data);
  } else if (data is Map) {
    productData = Map<String, dynamic>.from(data);
  }
  
  // 2. التحقق من صحة البيانات
  if (productData['title'] == null || 
      productData['title'].toString().isEmpty) {
    _showSnackBar('لم نتمكن من استخراج بيانات المنتج', isError: true);
    return;
  }
  
  // 3. إضافة المنتج للسلة عبر BLoC
  _cartBloc.add(
    CartAddItem(
      productName: productData['title'],
      price: productData['price'],
      imageUrl: productData['image'],
      images: List<String>.from(productData['images'] ?? []),
      productUrl: productData['url'],
      platform: productData['platform'],
      rating: productData['rating'],
      metadata: productData,
    ),
  );
  
  // 4. إظهار رسالة نجاح
  _showSnackBar('تمت إضافة المنتج للسلة بنجاح');
}
```

---

### **المرحلة 7: تخزين البيانات في Cart Bloc**

```dart
// في cart_bloc.dart
on<CartAddItem>((event, emit) async {
  // 1. الحصول على السلة الحالية
  final currentState = state;
  
  // 2. إضافة المنتج الجديد
  final updatedItems = List<CartItem>.from(currentState.items);
  updatedItems.add(CartItem(
    id: generateId(),
    productName: event.productName,
    price: event.price,
    imageUrl: event.imageUrl,
    images: event.images,
    productUrl: event.productUrl,
    platform: event.platform,
    // ... باقي البيانات
  ));
  
  // 3. حفظ البيانات في قاعدة البيانات
  await repository.addToCart(newItem);
  
  // 4. تحديث الحالة
  emit(CartLoaded(items: updatedItems));
});
```

---

## التقنيات المتقدمة المستخدمة

### 1. **استراتيجية Fallback (الاحتياطية)**
- إذا فشل CSS Selector الأول، يجرب الثاني، ثم الثالث، وهكذا.
- يستخرج الصور من مصادر متعددة:
  - `src` attribute
  - `data-src` attribute
  - `srcset` attribute
  - Open Graph meta tags
  - JSON-LD schema

### 2. **MutationObserver**
```javascript
// مراقبة التغييرات في DOM للمواقع الديناميكية
const observer = new MutationObserver(() => {
  // عندما يتغير المحتوى، تحقق من وجود العنصر المطلوب
  const element = document.querySelector(selector);
  if (element) {
    observer.disconnect();
    resolve(true);
  }
});
observer.observe(document.body, {
  childList: true,  // مراقبة إضافة/حذف عناصر
  subtree: true     // مراقبة جميع العناصر الفرعية
});
```

### 3. **User-Agent Spoofing**
```dart
// لكل منصة User-Agent مختلف لتجنب الحظر
String _getEnhancedUserAgent() {
  if (url.contains('shein.com')) {
    return 'Mozilla/5.0 (Linux; Android 14) Chrome/121.0.0.0';
  } else if (url.contains('amazon.com')) {
    return 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_2_1) Safari/604.1';
  }
  // ... المزيد
}
```

### 4. **Cookie Management**
```dart
// ضبط Cookies للمواقع التي تحتاج تسجيل دخول أو لغة معينة
await cookieManager.setCookie(
  url: WebUri('https://world.taobao.com'),
  name: 'thw',
  value: 'en', // لغة إنجليزية
  domain: '.taobao.com',
);
```

### 5. **Ad Blocking**
```dart
// حظر الإعلانات والتتبع لأداء أفضل
final blockedDomains = [
  'google-analytics.com',
  'googletagmanager.com',
  'doubleclick.net',
  'facebook.com/tr',
];

if (blockedDomains.any((domain) => url.contains(domain))) {
  return WebResourceResponse(
    contentType: 'text/plain',
    data: Uint8List(0), // رد فارغ
  );
}
```

---

## التحديات والحلول

### التحدي 1: المواقع الديناميكية (مثل SHEIN)
**المشكلة:** المحتوى يتم تحميله بعد تحميل الصفحة (AJAX/React)

**الحل:**
- استخدام `waitForElement()` للانتظار حتى يظهر المحتوى
- استخدام `MutationObserver` لمراقبة التغييرات
- delay إضافي للمواقع البطيئة:
```dart
if (url.contains('shein.com')) {
  await Future.delayed(const Duration(seconds: 3));
}
```

### التحدي 2: CSS Selectors تتغير باستمرار
**المشكلة:** المواقع تغير class names وids

**الحل:**
- قائمة احتياطية طويلة من Selectors
- استخدام patterns عامة:
```dart
'title': [
  'h1',                      // العنصر الأساسي
  '[class*="title"]',        // أي class يحتوي كلمة title
  '[class*="product-name"]', // أي class يحتوي product-name
]
```

### التحدي 3: حظر WebView من المواقع
**المشكلة:** بعض المواقع تكتشف WebView وتمنع الوصول

**الحل:**
```dart
applicationNameForUserAgent: '', // إزالة علامة "wv"
userAgent: _getEnhancedUserAgent(), // User-Agent مخصص
```

### التحدي 4: المواقع الصينية (Taobao)
**المشكلة:** تحويل تلقائي لصفحة تسجيل الدخول

**الحل:**
```dart
// اعتراض URL قبل التحميل
if (urlString.contains('login.taobao.com')) {
  await controller.stopLoading();
  await controller.loadUrl(
    urlRequest: URLRequest(url: WebUri('https://world.taobao.com'))
  );
}
```

---

## مميزات النظام

✅ **دعم منصات متعددة**: Amazon, AliExpress, SHEIN, Taobao, Alibaba

✅ **استخراج تلقائي**: لا يحتاج المستخدم نسخ ولصق أي شيء

✅ **بيانات شاملة**: العنوان، السعر، الصور، التقييم، الوصف

✅ **استراتيجية احتياطية قوية**: إذا فشلت طريقة، تجرب أخرى

✅ **أداء محسّن**: حظر الإعلانات والتتبع

✅ **تجربة مستخدم ممتازة**: زر عائم سهل الاستخدام + رسائل واضحة

---

## رسم توضيحي للتدفق

```
1. المستخدم يفتح منصة تسوق (مثل Amazon)
   ↓
2. WebView يحمل الصفحة
   ↓
3. التطبيق يحقن JavaScript في الصفحة
   ↓
4. يظهر زر "إضافة للسلة" عائم
   ↓
5. المستخدم يتصفح ويختار منتج
   ↓
6. المستخدم يضغط زر "إضافة للسلة"
   ↓
7. JavaScript يستخرج بيانات المنتج من DOM
   - العنوان من <h1 id="productTitle">
   - السعر من <span class="a-price">
   - الصورة من <img id="landingImage">
   ↓
8. JavaScript يرسل البيانات لـ Flutter عبر JavaScript Channel
   ↓
9. Flutter يستقبل البيانات ويتحقق منها
   ↓
10. Cart Bloc يضيف المنتج للسلة
    ↓
11. حفظ البيانات في قاعدة البيانات (Supabase)
    ↓
12. تحديث UI وإظهار رسالة نجاح
    ↓
13. المستخدم يمكنه رؤية المنتج في صفحة السلة
```

---

## الخلاصة

النظام يعمل كـ "مساعد تسوق ذكي" يقوم بما يلي:

1. **يفتح المتجر الإلكتروني** داخل التطبيق
2. **يضيف زر خاص** للإضافة السريعة للسلة
3. **يستخرج البيانات تلقائياً** باستخدام CSS Selectors مخصصة
4. **يرسل البيانات** من JavaScript إلى Flutter
5. **يحفظ المنتج** في سلة المشتريات

كل هذا يحدث بشكل سلس وسريع دون أن يحتاج المستخدم للقيام بأي نسخ/لصق يدوي!
