# 📚 وثائق نظام استخراج بيانات المنتجات

هذا المجلد يحتوي على شرح تفصيلي لكيفية عمل نظام استخراج بيانات المنتجات من مواقع التسوق الإلكترونية في التطبيق.

---

## 📖 الوثائق المتاحة

### 1. **الملخص السريع** 📝
**الملف:** [`product_extraction_summary.md`](./product_extraction_summary.md)

ملخص مبسط وسريع لفهم الفكرة الأساسية في 5 دقائق:
- ✅ الخطوات الخمس الرئيسية
- ✅ المكونات الأساسية
- ✅ أمثلة CSS Selectors
- ✅ التقنيات المتقدمة

**متى تقرأه:** إذا كنت تريد فهم عام سريع للنظام

---

### 2. **الشرح التفصيلي الكامل** 📚
**الملف:** [`product_extraction_explanation.md`](./product_extraction_explanation.md)

شرح شامل ومفصل يغطي:
- 🔍 جميع المراحل بالتفاصيل
- 💻 كود JavaScript المحقون
- 🎯 Platform Selectors لكل موقع
- 🔗 JavaScript Channel والاتصال مع Flutter
- 🛡️ التحديات والحلول
- ⚡ التقنيات المتقدمة (MutationObserver, Fallback Strategy)

**متى تقرأه:** إذا كنت تريد فهم عميق للنظام بالكامل

---

### 3. **مثال عملي - Amazon** 🛒
**الملف:** [`practical_example_amazon.md`](./practical_example_amazon.md)

مثال عملي كامل يوضح:
- 📄 HTML الأصلي لصفحة المنتج
- 🎯 Platform Selectors لـ Amazon
- 💾 JavaScript الكامل المحقون
- 🔄 معالجة البيانات في Flutter
- ⏱️ التسلسل الزمني للعملية

**متى تقرأه:** إذا كنت تريد رؤية مثال حي وعملي

---

## 🎨 الرسومات التوضيحية

### 1. **مخطط التدفق الكامل**
![Product Extraction Flow](../../../.gemini/antigravity/brain/9a1aa2a2-e7a1-4bab-996d-7bd99dcd2001/product_extraction_flow_1768409618384.png)

يوضح:
- WebView و فتح الموقع
- حقن JavaScript
- استخراج البيانات من DOM
- JavaScript Channel
- Cart Bloc
- قاعدة البيانات

---

### 2. **كيف تعمل CSS Selectors**
![CSS Selectors Extraction](../../../.gemini/antigravity/brain/9a1aa2a2-e7a1-4bab-996d-7bd99dcd2001/css_selectors_extraction_1768409712194.png)

يوضح:
- كود HTML الأصلي
- CSS Selectors المستخدمة
- البيانات المستخرجة بصيغة JSON

---

## 🚀 البدء السريع

### خطوة 1: اقرأ الملخص
```bash
اقرأ product_extraction_summary.md
```

### خطوة 2: راجع المثال العملي
```bash
اقرأ practical_example_amazon.md
```

### خطوة 3: للتعمق أكثر
```bash
اقرأ product_extraction_explanation.md
```

---

## 🎯 الفكرة في سطر واحد

> **WebView يفتح الموقع → JavaScript يستخرج البيانات → JavaScript Channel ينقلها → Flutter يحفظها في Cart!**

---

## 🔧 الملفات الرئيسية في الكود

| الملف | المسار | الوظيفة |
|-------|--------|---------|
| **WebView Screen** | `lib/features/webview/presentation/pages/webview_screen.dart` | عرض المواقع وحقن JavaScript |
| **Platform Selectors** | `lib/features/cart/data/platform_selectors.dart` | قواعد استخراج البيانات لكل موقع |
| **Cart Bloc** | `lib/features/cart/presentation/bloc/cart_bloc.dart` | إدارة السلة |

---

## 🌍 المنصات المدعومة

| المنصة | الحالة | الملاحظات |
|--------|--------|-----------|
| **Amazon** | ✅ يعمل بكفاءة | دعم كامل للصور والتقييمات |
| **AliExpress** | ✅ يعمل بكفاءة | دعم متقدم للصور |
| **SHEIN** | ⚠️ يعمل مع تأخير | يحتاج delay إضافي للمحتوى الديناميكي |
| **Taobao** | ⚠️ يحتاج معالجة خاصة | معالجة redirects + لغة إنجليزية |
| **Alibaba** | ✅ يعمل بكفاءة | دعم كامل |
| **Temu** | ✅ يعمل بكفاءة | دعم أساسي |

---

## 💡 نصائح للمطورين

### لإضافة منصة جديدة:

1. **أضف CSS Selectors في `platform_selectors.dart`:**
```dart
'newplatform': {
  'title': ['h1.product-title', '.title'],
  'price': ['.price', 'span.price'],
  'image': ['img.main-image', '#product-image'],
  'buttonColor': '#FF0000',
}
```

2. **أضف User-Agent مخصص في `_getEnhancedUserAgent()`:**
```dart
else if (url.contains('newplatform.com')) {
  return 'Mozilla/5.0 (Windows NT 10.0) Chrome/121.0.0.0';
}
```

3. **اختبر الاستخراج:**
- افتح المنصة في WebView
- تحقق من ظهور زر "إضافة للسلة"
- اضغط على الزر
- تحقق من استخراج البيانات بنجاح

---

## 🐛 استكشاف الأخطاء

### المشكلة: "لم نتمكن من استخراج بيانات المنتج"

**الحلول:**
1. تحقق من CSS Selectors في Console:
```javascript
console.log(document.querySelector('#productTitle'));
```

2. أضف selectors احتياطية أكثر

3. زد زمن الانتظار:
```javascript
await waitForElement(selectors, 10000); // 10 ثواني
```

### المشكلة: الصور لا تظهر

**الحلول:**
1. تحقق من `data-src` و `srcset`:
```javascript
const src = img.src || img.getAttribute('data-src');
```

2. استخدم Open Graph meta tags كاحتياطي

### المشكلة: الموقع يحظر WebView

**الحلول:**
1. غير User-Agent
2. عطل `applicationNameForUserAgent`
3. فعل Cookies والـ third-party cookies

---

## 📞 للمساعدة

إذا واجهت أي مشكلة أو لديك استفسار:
1. راجع قسم "التحديات والحلول" في الوثيقة التفصيلية
2. تحقق من Console logs في WebView
3. راجع الأمثلة العملية

---

## 📅 آخر تحديث

**التاريخ:** 14 يناير 2024  
**الإصدار:** 1.0  
**الحالة:** نشط ويعمل بكفاءة

---

## 🙏 ملاحظة مهمة

هذا النظام يعتمد على **Web Scraping** وهو قانوني للاستخدام الشخصي. 
تأكد من:
- ✅ احترام شروط الخدمة لكل موقع
- ✅ عدم إثقال الخوادم بطلبات كثيرة
- ✅ استخدام النظام للأغراض المصرح بها

---

<div align="center">

**تم إنشاء هذه الوثائق بواسطة Antigravity AI** 🤖

</div>
