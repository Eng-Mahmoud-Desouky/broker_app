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
      'weight': [
        // Product Overview table - most common location
        'tr.po-item_weight',
        'tr[class*="po-item_weight"]',
        '.po-item_weight',
        // Detail bullets
        '#productDetails_detailBullets_sections1',
        '#detailBullets_feature_div',
        // Tech specs table
        'table#productDetails_techSpec_section_1',
        '#productDetails_db_sections',
        '.prodDetTable',
      ],
      'dimensions': [
        // Product Overview table
        'tr.po-product_dimensions',
        'tr[class*="po-product_dimensions"]',
        'tr.po-item_dimensions',
        'tr[class*="po-item_dimensions"]',
        '.po-product_dimensions',
        '.po-item_dimensions',
        // Detail bullets
        '#productDetails_detailBullets_sections1',
        '#detailBullets_feature_div',
        // Tech specs table
        'table#productDetails_techSpec_section_1',
        '#productDetails_db_sections',
        '.prodDetTable',
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
      'weight': [
        '.product-intro__description',
        '.goods-desc__info',
        'div[class*="specification"]',
      ],
      'dimensions': [
        '.product-intro__description',
        '.goods-desc__info',
        'div[class*="specification"]',
      ],
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
      'weight': [
        'div[class*="specification"]',
        'div[class*="product-prop"]',
        '.product-specs',
        'div[class*="sku-property"]',
      ],
      'dimensions': [
        'div[class*="specification"]',
        'div[class*="product-prop"]',
        '.product-specs',
        'div[class*="sku-property"]',
      ],
      'buttonColor': '#E62E04',
    },
    'taobao': {
      'title': ['.tb-main-title', 'h1[class*="title"]'],
      'price': ['.tb-rmb-num', 'em[class*="price"]'],
      'image': ['#J_ImgBooth', 'img[id*="main"]'],
      'images': ['#J_UlThumb img', 'img[class*="thumb"]'],
      'rating': ['.tb-rate-score'],
      'weight': ['#J_AttrUL', '.tb-property-cont', 'div[class*="attributes"]'],
      'dimensions': [
        '#J_AttrUL',
        '.tb-property-cont',
        'div[class*="attributes"]',
      ],
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
      'weight': [
        'div[class*="specification"]',
        'table[class*="detail"]',
        '.product-property',
      ],
      'dimensions': [
        'div[class*="specification"]',
        'table[class*="detail"]',
        '.product-property',
      ],
      'buttonColor': '#FF6A00',
    },
    'generic': {
      'title': ['h1', '[class*="title"]', '[class*="product-name"]'],
      'price': ['[class*="price"]', '[id*="price"]'],
      'image': ['img[class*="main"]', 'img[class*="product"]'],
      'images': ['img[class*="thumb"]', 'img[class*="gallery"]'],
      'rating': ['[class*="rating"]', '[class*="star"]'],
      'weight': ['table', 'div[class*="spec"]', 'div[class*="detail"]'],
      'dimensions': ['table', 'div[class*="spec"]', 'div[class*="detail"]'],
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

        // Extract core data
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

        // Extract weight and dimensions (OPTIONAL - never block cart addition)
        let weight = null;
        let dimensions = null;
        let weightText = null;
        let dimensionText = null;
        
        try {
          // Collect raw specification text for weight
          // Special handling for table rows (Amazon product overview)
          let specText = null;
          const weightSelectors = ${_toJsArray(selectors['weight'] ?? [])};
          
          for (const selector of weightSelectors) {
            try {
              const element = document.querySelector(selector);
              if (element) {
                // If it's a table row, get text from the value cell (second td)
                if (element.tagName === 'TR') {
                  const valueCells = element.querySelectorAll('td.a-span9, td:nth-child(2)');
                  if (valueCells.length > 0) {
                    specText = valueCells[0].innerText || valueCells[0].textContent;
                    if (specText && specText.trim()) {
                      specText = specText.trim();
                      break;
                    }
                  }
                } else {
                  // For other elements, get text normally
                  specText = element.innerText || element.textContent;
                  if (specText && specText.trim()) {
                    specText = specText.trim();
                    break;
                  }
                }
              }
            } catch (e) {
              console.log('Weight selector failed:', selector, e);
            }
          }
          
          weightText = specText;
          
          // Try to parse weight from text
          if (specText) {
            const weightPatterns = [
              /(\\d+\\.?\\d*)\\s*(kg|kilogram|kilograms)/i,
              /(\\d+\\.?\\d*)\\s*(lb|lbs|pound|pounds)/i,
              /(\\d+\\.?\\d*)\\s*(g|gram|grams)(?!\\s*cm)/i,
              /(\\d+\\.?\\d*)\\s*(oz|ounce|ounces)/i,
            ];
            
            for (const pattern of weightPatterns) {
              const match = specText.match(pattern);
              if (match) {
                const value = parseFloat(match[1]);
                let unit = match[2].toLowerCase();
                
                if (unit.includes('kilogram')) unit = 'kg';
                else if (unit.includes('pound') || unit === 'lbs') unit = 'lb';
                else if (unit.includes('gram') && !unit.includes('kilogram')) unit = 'g';
                else if (unit.includes('ounce')) unit = 'oz';
                
                if (!isNaN(value) && value > 0) {
                  weight = { value, unit };
                  console.log('✅ Weight extracted:', weight, 'from text:', specText);
                  break;
                }
              }
            }
          }
        } catch (e) {
          console.log('⚠️ Weight extraction failed (non-critical):', e);
        }
        
        try {
          // Collect dimension text
          // Special handling for table rows (Amazon product overview)
          let dimText = null;
          const dimSelectors = ${_toJsArray(selectors['dimensions'] ?? [])};
          
          // First, try to find a row that specifically contains "Product Dimensions" or "Item Dimensions"
          const allRows = document.querySelectorAll('tr');
          for (const row of allRows) {
            const rowText = row.innerText || row.textContent || '';
            if (rowText.match(/Product Dimensions|Item Dimensions/i)) {
              // Found the dimensions row, extract from value cell
              const valueCells = row.querySelectorAll('td.a-span9, td:nth-child(2)');
              if (valueCells.length > 0) {
                dimText = valueCells[0].innerText || valueCells[0].textContent;
                if (dimText && dimText.trim()) {
                  dimText = dimText.trim();
                  console.log('📏 Found dimensions row by text search:', dimText);
                  break;
                }
              }
            }
          }
          
          // If not found by text search, try selectors
          if (!dimText) {
            for (const selector of dimSelectors) {
              try {
                const element = document.querySelector(selector);
                if (element) {
                  // If it's a table row, get text from the value cell (second td)
                  if (element.tagName === 'TR') {
                    const valueCells = element.querySelectorAll('td.a-span9, td:nth-child(2)');
                    if (valueCells.length > 0) {
                      dimText = valueCells[0].innerText || valueCells[0].textContent;
                      if (dimText && dimText.trim()) {
                        dimText = dimText.trim();
                        break;
                      }
                    }
                  } else {
                    // For other elements, get text normally
                    dimText = element.innerText || element.textContent;
                    if (dimText && dimText.trim()) {
                      dimText = dimText.trim();
                      break;
                    }
                  }
                }
              } catch (e) {
                console.log('Dimensions selector failed:', selector, e);
              }
            }
          }
          
          dimensionText = dimText;
          
          // Try to parse dimensions from text
          if (dimText) {
            const dimPatterns = [
              // Amazon format: 5.5"D x 5.5"W x 12"H (inches with D/W/H labels)
              /(\\d+\\.?\\d*)\\s*["'']\\s*[DdLl]?\\s*[x×]\\s*(\\d+\\.?\\d*)\\s*["'']\\s*[Ww]?\\s*[x×]\\s*(\\d+\\.?\\d*)\\s*["'']\\s*[Hh]?/i,
              // Standard format with unit at end: 30 x 20 x 10 cm
              /(\\d+\\.?\\d*)\\s*[x×]\\s*(\\d+\\.?\\d*)\\s*[x×]\\s*(\\d+\\.?\\d*)\\s*(cm|centimeter|centimeters|inch|inches|in|mm|millimeter|millimeters|m|meter|meters)/i,
              // Format with unit after each number: 30cm x 20cm x 10cm
              /(\\d+\\.?\\d*)\\s*(cm|in|mm|m)\\s*[x×]\\s*(\\d+\\.?\\d*)\\s*(cm|in|mm|m)\\s*[x×]\\s*(\\d+\\.?\\d*)\\s*(cm|in|mm|m)/i,
            ];
            
            for (const pattern of dimPatterns) {
              const match = dimText.match(pattern);
              if (match) {
                let length, width, height, unit;
                
                // Handle different match patterns
                if (match[0].includes('"') || match[0].includes("'")) {
                  // Amazon format with inches: 5.5"D x 5.5"W x 12"H
                  length = parseFloat(match[1]);
                  width = parseFloat(match[2]);
                  height = parseFloat(match[3]);
                  unit = 'in';
                } else if (match.length === 5) {
                  // Standard format: 30 x 20 x 10 cm
                  length = parseFloat(match[1]);
                  width = parseFloat(match[2]);
                  height = parseFloat(match[3]);
                  unit = match[4].toLowerCase();
                } else if (match.length === 7) {
                  // Format with unit after each: 30cm x 20cm x 10cm
                  length = parseFloat(match[1]);
                  width = parseFloat(match[3]);
                  height = parseFloat(match[5]);
                  unit = match[2].toLowerCase();
                }
                
                // Normalize unit names
                if (unit) {
                  if (unit.includes('centimeter')) unit = 'cm';
                  else if (unit.includes('inch')) unit = 'in';
                  else if (unit.includes('millimeter')) unit = 'mm';
                  else if (unit.includes('meter') && !unit.includes('centimeter') && !unit.includes('millimeter')) unit = 'm';
                  
                  if (!isNaN(length) && !isNaN(width) && !isNaN(height) && 
                      length > 0 && width > 0 && height > 0) {
                    dimensions = { length, width, height, unit };
                    console.log('✅ Dimensions extracted:', dimensions, 'from text:', dimText);
                    break;
                  }
                }
              }
            }
          }
        } catch (e) {
          console.log('⚠️ Dimensions extraction failed (non-critical):', e);
        }

        console.log('✅ Product data extracted:', { title, price, image, weight, dimensions });

        return {
          title: title || 'No title found',
          price: price || 'Price not available',
          image: image || (images.length > 0 ? images[0] : ''),
          images: images,
          rating: rating || '',
          description: description || '',
          currency: currency || 'USD',
          reviewCount: reviewCount || '',
          weight: weight,
          dimensions: dimensions,
          rawSpecs: {
            weightText: weightText,
            dimensionText: dimensionText
          },
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
