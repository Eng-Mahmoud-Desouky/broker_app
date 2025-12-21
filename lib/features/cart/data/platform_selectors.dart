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
        // Modern AliExpress selectors (2024+)
        'img[class*="magnifier-image"]',
        'img[class*="ImageGallery"]',
        'div[class*="gallery"] img[class*="index"]',
        'img[data-role="mainImage"]',
        'div[class*="mainPic"] img',
        'div[class*="main-image"] img',
        // Legacy fallbacks
        'img[class*="magnifier--image"]',
        '.magnifier-image img',
        'img[class*="main"]',
        'img[class*="Product"]',
      ],
      'images': [
        // Modern thumbnail selectors
        'div[class*="thumb-item"] img',
        'ul[class*="images-view"] img',
        'div[class*="slider"] img',
        'li[class*="thumb"] img',
        'div[class*="imageItem"] img',
        // Legacy selectors
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
      'title': [
        '.product-title-container h1',
        'div[data-module-name="module_title"] h1',
        '.product-title',
        'h1[class*="title"]',
        'h1[title]',
      ],
      'price': [
        'div[data-testid="fixed-price"] strong',
        'strong[class*="id-font-bold"]',
        '.price',
        'span[class*="price"]',
        'div[class*="price"] strong',
      ],
      'image': [
        // Modern Alibaba selectors
        'div[class*="imageView"] img[class*="mainPic"]',
        '.current-main-image img',
        'div[class*="current-main-image"] img',
        'div[class*="main-img"] img',
        'img[class*="main-image"]',
        // Legacy fallbacks
        '.main-image img',
        'img[class*="main"]',
        'div[class*="gallery"] img:first-child',
      ],
      'images': [
        // Thumbnail gallery selectors
        'div[class*="thumbItem"] img',
        'ul[class*="thumb-list"] img',
        'div[class*="thumb-image"] img',
        '.thumb-image img',
        'img[class*="thumb"]',
        '.image-gallery img',
        'li[class*="image-item"] img',
      ],
      'rating': [
        '.detail-review-item.detail-star',
        'span[class*="detail-star"]',
        '.star-rating',
        '[class*="rating"]',
      ],
      'reviewCount': [
        '.detail-review-item.detail-review',
        'span[class*="detail-review"]',
      ],
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
        
        // Helper function to extract all images with advanced fallbacks
        function extractImages(selectors) {
          if (!Array.isArray(selectors)) selectors = [selectors];
          const images = new Set();
          
          for (const selector of selectors) {
            try {
              const elements = document.querySelectorAll(selector);
              elements.forEach(img => {
                // Try multiple image source attributes
                const src = img.src || 
                           img.getAttribute('data-src') || 
                           img.getAttribute('data-lazy-src') ||
                           img.getAttribute('data-original') ||
                           img.getAttribute('data-img');
                
                // Also check srcset attribute
                const srcset = img.getAttribute('srcset');
                if (srcset) {
                  const srcsetUrls = srcset.split(',').map(s => s.trim().split(' ')[0]);
                  srcsetUrls.forEach(url => {
                    if (url && !url.includes('data:image') && url.startsWith('http')) {
                      images.add(url);
                    }
                  });
                }
                
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
        
        // Extract image from meta tags (fallback)
        function extractMetaImage() {
          const ogImage = document.querySelector('meta[property="og:image"]');
          if (ogImage) {
            const content = ogImage.getAttribute('content');
            if (content && content.startsWith('http')) return content;
          }
          
          const twitterImage = document.querySelector('meta[name="twitter:image"]');
          if (twitterImage) {
            const content = twitterImage.getAttribute('content');
            if (content && content.startsWith('http')) return content;
          }
          
          return null;
        }
        
        // Extract image from JSON-LD schema (fallback)
        function extractSchemaImage() {
          const scripts = document.querySelectorAll('script[type="application/ld+json"]');
          for (const script of scripts) {
            try {
              const data = JSON.parse(script.textContent);
              if (data.image) {
                const imageUrl = Array.isArray(data.image) ? data.image[0] : data.image;
                if (typeof imageUrl === 'string' && imageUrl.startsWith('http')) {
                  return imageUrl;
                } else if (typeof imageUrl === 'object' && imageUrl.url) {
                  return imageUrl.url;
                }
              }
            } catch (e) {
              // Skip invalid JSON
            }
          }
          return null;
        }
        
        // Wait for critical elements to load (especially for AliExpress)
        console.log('⏳ Waiting for product data to load...');
        await waitForElement(${_toJsArray(selectors['title'])});

        // Small delay to ensure all data is loaded
        await new Promise(resolve => setTimeout(resolve, 500));

        // Extract data
        const title = trySelectors(${_toJsArray(selectors['title'])});
        const price = trySelectors(${_toJsArray(selectors['price'])});
        
        // Try multiple methods to get main image
        let image = trySelectors(${_toJsArray(selectors['image'])}, 'src') ||
                    trySelectors(${_toJsArray(selectors['image'])}, 'data-src') ||
                    trySelectors(${_toJsArray(selectors['image'])}, 'data-original') ||
                    extractMetaImage() ||
                    extractSchemaImage();
        
        const images = extractImages(${_toJsArray(selectors['images'])});
        
        // If no main image found but we have gallery images, use first gallery image
        if (!image && images.length > 0) {
          image = images[0];
        }
        
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
