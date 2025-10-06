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
      'title': ['#productTitle', '#title', 'h1[id*="title"]', '.product-title'],
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
      'price': ['.original', '.product-intro__price', 'span[class*="price"]'],
      'image': [
        '.product-intro__main-img img',
        '.sui-img__img',
        'img[class*="main"]',
      ],
      'images': ['.product-intro__thumbnail-img', '.crop-image-container img'],
      'rating': ['.product-intro__head-score', 'span[class*="rating"]'],
      'buttonColor': '#000000',
    },
    'aliexpress': {
      'title': [
        'h1[data-pl="product-title"]',
        'h1[data-tticheck="true"]',
        '.product-title-text',
        'h1[class*="title"]',
        'h1[class*="Product"]',
        '.product-name',
      ],
      'price': [
        'span[class*="price-default--current"]',
        'span[class*="price--currentPriceText"]',
        '.product-price-value',
        'span[class*="price"]',
        '.uniform-banner-box-price',
      ],
      'image': [
        'img[class*="magnifier--image"]',
        '.magnifier-image img',
        'img[class*="main"]',
        'img[class*="Product"]',
      ],
      'images': [
        'div[class*="slider--img"] img',
        '.slider--img--kD4mIg7 img',
        '.images-view-item img',
        'img[class*="thumb"]',
        '.slider-image img',
      ],
      'rating': [
        'a[class*="reviewer--rating"] strong',
        '.reviewer--rating--xrWWFzx strong',
        '.overview-rating-average',
        'span[class*="rating"]',
      ],
      'description': [
        '.product-description',
        'div[class*="description"]',
        '.product-specs',
      ],
      'currency': [
        'span[class*="currency"]',
        '.product-price-current span:first-child',
      ],
      'reviewCount': ['span[class*="review"]', 'a[class*="reviewer--reviews"]'],
      'buttonColor': '#E62E04',
    },
    'taobao': {
      'title': ['.tb-main-title', 'h1[class*="title"]'],
      'price': ['.tb-rmb-num', 'em[class*="price"]'],
      'image': ['#J_ImgBooth', 'img[id*="main"]'],
      'images': ['#J_UlThumb img', 'img[class*="thumb"]'],
      'rating': ['.tb-rate-score'],
      'buttonColor': '#FF6A00',
    },
    'alibaba': {
      'title': ['.product-title', 'h1[class*="title"]'],
      'price': ['.price', 'span[class*="price"]'],
      'image': ['.main-image img', 'img[class*="main"]'],
      'images': ['.thumb-image img'],
      'rating': [],
      'buttonColor': '#FF6A00',
    },
    'generic': {
      'title': ['h1', '[class*="title"]', '[class*="product-name"]'],
      'price': ['[class*="price"]', '[id*="price"]'],
      'image': ['img[class*="main"]', 'img[class*="product"]'],
      'images': ['img[class*="thumb"]', 'img[class*="gallery"]'],
      'rating': ['[class*="rating"]', '[class*="star"]'],
      'buttonColor': '#213c86',
    },
  };

  /// Generate JavaScript code for extracting product data
  static String generateExtractionScript(String platform) {
    final selectors = getSelectors(platform);

    return '''
      async function extractProductData() {
        // Wait for page to be fully loaded
        function waitForElement(selectors, timeout = 5000) {
          return new Promise((resolve) => {
            if (!Array.isArray(selectors)) selectors = [selectors];

            // Check if element already exists
            for (const selector of selectors) {
              const element = document.querySelector(selector);
              if (element) {
                resolve(true);
                return;
              }
            }

            // Wait for element to appear
            const observer = new MutationObserver(() => {
              for (const selector of selectors) {
                const element = document.querySelector(selector);
                if (element) {
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

            // Timeout after specified time
            setTimeout(() => {
              observer.disconnect();
              resolve(false);
            }, timeout);
          });
        }

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
        
        // Wait for critical elements to load (especially for AliExpress)
        console.log('⏳ Waiting for product data to load...');
        await waitForElement(${_toJsArray(selectors['title'])});

        // Small delay to ensure all data is loaded
        await new Promise(resolve => setTimeout(resolve, 500));

        // Extract data
        const title = trySelectors(${_toJsArray(selectors['title'])});
        const price = trySelectors(${_toJsArray(selectors['price'])});
        const image = trySelectors(${_toJsArray(selectors['image'])}, 'src') ||
                     trySelectors(${_toJsArray(selectors['image'])}, 'data-src');
        const images = extractImages(${_toJsArray(selectors['images'])});
        const rating = trySelectors(${_toJsArray(selectors['rating'])});
        const description = trySelectors(${_toJsArray(selectors['description'] ?? [])});
        const currency = trySelectors(${_toJsArray(selectors['currency'] ?? [])});
        const reviewCount = trySelectors(${_toJsArray(selectors['reviewCount'] ?? [])});

        console.log('✅ Product data extracted:', { title, price, image });

        return {
          title: title || 'No title found',
          price: price || 'Price not available',
          image: image || (images.length > 0 ? images[0] : ''),
          images: images,
          rating: rating || '',
          description: description || '',
          currency: currency || 'USD',
          reviewCount: reviewCount || '',
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
