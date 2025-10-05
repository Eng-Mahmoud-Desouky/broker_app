/// Platform-specific CSS selectors for extracting product data
class PlatformSelectors {
  /// Get selectors for a specific platform
  static Map<String, dynamic> getSelectors(String platform) {
    final platformLower = platform.toLowerCase();
    return _selectors[platformLower] ?? _selectors['generic']!;
  }

  /// All platform selectors
  static const Map<String, Map<String, dynamic>> _selectors = {
    'amazon': {
      'title': [
        '#productTitle',
        '#title',
        'h1[id*="title"]',
        '.product-title',
      ],
      'price': [
        '.a-price .a-offscreen',
        '#priceblock_ourprice',
        '#priceblock_dealprice',
        '.a-price-whole',
        'span[class*="price"]',
      ],
      'image': [
        '#landingImage',
        '#imgBlkFront',
        '#main-image',
        'img[data-old-hires]',
      ],
      'images': [
        '#altImages img',
        '.imageThumbnail img',
        'img[data-a-dynamic-image]',
      ],
      'rating': [
        '.a-icon-star .a-icon-alt',
        '#acrPopover',
        'span[data-hook="rating-out-of-text"]',
      ],
      'buttonColor': '#FF9900',
    },
    'shein': {
      'title': [
        '.product-intro__head-name',
        'h1[class*="title"]',
        '.goods-title',
      ],
      'price': [
        '.original',
        '.product-intro__price',
        'span[class*="price"]',
      ],
      'image': [
        '.product-intro__main-img img',
        '.sui-img__img',
        'img[class*="main"]',
      ],
      'images': [
        '.product-intro__thumbnail-img',
        '.crop-image-container img',
      ],
      'rating': [
        '.product-intro__head-score',
        'span[class*="rating"]',
      ],
      'buttonColor': '#000000',
    },
    'aliexpress': {
      'title': [
        '.product-title-text',
        'h1[class*="title"]',
        '.product-name',
      ],
      'price': [
        '.product-price-value',
        'span[class*="price"]',
        '.uniform-banner-box-price',
      ],
      'image': [
        '.magnifier-image img',
        'img[class*="main"]',
      ],
      'images': [
        '.images-view-item img',
        'img[class*="thumb"]',
      ],
      'rating': [
        '.overview-rating-average',
        'span[class*="rating"]',
      ],
      'buttonColor': '#E62E04',
    },
    'taobao': {
      'title': [
        '.tb-main-title',
        'h1[class*="title"]',
      ],
      'price': [
        '.tb-rmb-num',
        'em[class*="price"]',
      ],
      'image': [
        '#J_ImgBooth',
        'img[id*="main"]',
      ],
      'images': [
        '#J_UlThumb img',
        'img[class*="thumb"]',
      ],
      'rating': [
        '.tb-rate-score',
      ],
      'buttonColor': '#FF6A00',
    },
    'alibaba': {
      'title': [
        '.product-title',
        'h1[class*="title"]',
      ],
      'price': [
        '.price',
        'span[class*="price"]',
      ],
      'image': [
        '.main-image img',
        'img[class*="main"]',
      ],
      'images': [
        '.thumb-image img',
      ],
      'rating': [],
      'buttonColor': '#FF6A00',
    },
    'generic': {
      'title': [
        'h1',
        '[class*="title"]',
        '[class*="product-name"]',
      ],
      'price': [
        '[class*="price"]',
        '[id*="price"]',
      ],
      'image': [
        'img[class*="main"]',
        'img[class*="product"]',
      ],
      'images': [
        'img[class*="thumb"]',
        'img[class*="gallery"]',
      ],
      'rating': [
        '[class*="rating"]',
        '[class*="star"]',
      ],
      'buttonColor': '#213c86',
    },
  };

  /// Generate JavaScript code for extracting product data
  static String generateExtractionScript(String platform) {
    final selectors = getSelectors(platform);
    
    return '''
      function extractProductData() {
        // Helper function to try multiple selectors
        function trySelectors(selectors, getAttribute = null) {
          if (!Array.isArray(selectors)) selectors = [selectors];
          
          for (const selector of selectors) {
            try {
              const element = document.querySelector(selector);
              if (element) {
                if (getAttribute) {
                  const value = element.getAttribute(getAttribute);
                  if (value) return value;
                }
                const text = element.innerText || element.textContent;
                if (text && text.trim()) return text.trim();
              }
            } catch (e) {
              console.log('Selector failed:', selector, e);
            }
          }
          return null;
        }
        
        // Helper function to extract all images
        function extractImages(selectors) {
          if (!Array.isArray(selectors)) selectors = [selectors];
          const images = new Set();
          
          for (const selector of selectors) {
            try {
              const elements = document.querySelectorAll(selector);
              elements.forEach(img => {
                const src = img.src || img.getAttribute('data-src') || img.getAttribute('data-lazy-src');
                if (src && !src.includes('data:image') && src.startsWith('http')) {
                  images.add(src);
                }
              });
            } catch (e) {
              console.log('Image selector failed:', selector, e);
            }
          }
          
          return Array.from(images);
        }
        
        // Extract data
        const title = trySelectors(${_toJsArray(selectors['title'])});
        const price = trySelectors(${_toJsArray(selectors['price'])});
        const image = trySelectors(${_toJsArray(selectors['image'])}, 'src') || 
                     trySelectors(${_toJsArray(selectors['image'])}, 'data-src');
        const images = extractImages(${_toJsArray(selectors['images'])});
        const rating = trySelectors(${_toJsArray(selectors['rating'])});
        
        return {
          title: title || 'No title found',
          price: price || 'Price not available',
          image: image || (images.length > 0 ? images[0] : ''),
          images: images,
          rating: rating || '',
          url: window.location.href,
          platform: '$platform',
          timestamp: new Date().toISOString()
        };
      }
    ''';
  }

  /// Convert Dart list to JavaScript array string
  static String _toJsArray(dynamic value) {
    if (value is List) {
      final items = value.map((e) => "'$e'").join(', ');
      return '[$items]';
    }
    return "['$value']";
  }
}

