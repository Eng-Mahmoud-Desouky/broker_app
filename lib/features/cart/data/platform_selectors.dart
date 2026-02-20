import 'dart:convert';

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
        // Priority 1: Product Information > Measurements / Tech Specs
        {
          'type': 'table_row',
          'container':
              '#prodDetails, #productDetails_techSpec_section_1, .prodDetTable',
          'rowSelector': 'tr',
          'keySelector': 'th, td:first-child',
          'valueSelector': 'td:nth-child(2), td:last-child',
          'keywords': ['Item Weight', 'Weight'],
        },
        // Priority 2: Additional details
        {
          'type': 'table_row',
          'container':
              '#productDetails_db_sections, #detailBullets_feature_div',
          'rowSelector': 'tr, li',
          'keySelector': 'th, span.a-text-bold',
          'valueSelector': 'td, span:not(.a-text-bold)',
          'keywords': ['Item Weight', 'Weight'],
        },
      ],
      'dimensions': [
        // Priority 1: Product Information > Measurements / Tech Specs
        {
          'type': 'table_row',
          'container':
              '#prodDetails, #productDetails_techSpec_section_1, .prodDetTable',
          'rowSelector': 'tr',
          'keySelector': 'th, td:first-child',
          'valueSelector': 'td:nth-child(2), td:last-child',
          'keywords': ['Item Dimensions', 'Dimensions', 'Product Dimensions'],
        },
        // Priority 2: Additional details
        {
          'type': 'table_row',
          'container':
              '#productDetails_db_sections, #detailBullets_feature_div',
          'rowSelector': 'tr, li',
          'keySelector': 'th, span.a-text-bold',
          'valueSelector': 'td, span:not(.a-text-bold)',
          'keywords': ['Item Dimensions', 'Dimensions', 'Product Dimensions'],
        },
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
        {
          'type': 'selector_text',
          'selector':
              '.product-intro__description, .goods-desc__info, div[class*="specification"]',
        },
      ],
      'dimensions': [
        {
          'type': 'selector_text',
          'selector':
              '.product-intro__description, .goods-desc__info, div[class*="specification"]',
        },
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
        // Priority 1: Specifications List which contains "Total Weight" or "Weight"
        {
          'type': 'list_item',
          'container': '.specification--list--GZuXzRX, .specification--wrap',
          'itemSelector': 'li',
          'keySelector': '.specification--title--SfH3sA8, span',
          'valueSelector':
              '.specification--desc--Dxx6W0W, .specification--desc',
          'keywords': ['Total Weight', 'Weight', 'Single gross weight'],
        },
        // Priority 2: Description text (fallback)
        {
          'type': 'selector_text',
          'selector':
              '#product-description, .product-description, .description--content',
        },
      ],
      'dimensions': [
        // Priority 1: Specifications List which contains "Overall Size" or similar
        {
          'type': 'list_item',
          'container': '.specification--list--GZuXzRX, .specification--wrap',
          'itemSelector': 'li',
          'keySelector': '.specification--title--SfH3sA8, span',
          'valueSelector':
              '.specification--desc--Dxx6W0W, .specification--desc',
          'keywords': [
            'Overall Size',
            'Dimensions',
            'Package Size',
            'Single package size',
          ],
        },
        // Priority 2: Description text (fallback)
        {
          'type': 'selector_text',
          'selector':
              '#product-description, .product-description, .description--content',
        },
      ],
      'buttonColor': '#E62E04',
    },
    'taobao': {
      'title': ['.tb-main-title', 'h1[class*="title"]'],
      'price': ['.tb-rmb-num', 'em[class*="price"]'],
      'image': ['#J_ImgBooth', 'img[id*="main"]'],
      'images': ['#J_UlThumb img', 'img[class*="thumb"]'],
      'rating': ['.tb-rate-score'],
      'weight': [
        {
          'type': 'list_item',
          'container': '#J_AttrUL, .tb-property-cont',
          'itemSelector': 'li',
          'keySelector': '', // Key is part of the text usually
          'valueSelector': '', // Value is part of the text usually
          'keywords': ['Weight', '重量'], // Chinese support
        },
      ],
      'dimensions': [
        {
          'type': 'list_item',
          'container': '#J_AttrUL, .tb-property-cont',
          'itemSelector': 'li',
          'keySelector': '',
          'valueSelector': '',
          'keywords': ['Size', 'Dimensions', '尺寸', '体积'],
        },
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
        'div[class*="imageView"] img[class*="mainPic"]',
        '.current-main-image img',
        'div[class*="current-main-image"] img',
        'div[class*="main-img"] img',
        'img[class*="main-image"]',
        '.main-image img',
        'img[class*="main"]',
        'div[class*="gallery"] img:first-child',
      ],
      'images': [
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
      // Weight: iterate Alibaba attribute rows using correct data-testid
      'weight': [
        {
          'type': 'list_item',
          'container': 'div[data-module-name="module_attribute"], body',
          'itemSelector': 'div[data-testid="module-attribute"]',
          'keySelector': 'div[data-testid="module-attribute-name"]',
          'valueSelector': 'div[data-testid="module-attribute-value"]',
          'keywords': ['weight'],
        },
        // Priority 2: Mobile layout uses different data-testid hierarchy
        {
          'type': 'list_item',
          'container': 'div[data-testid="key-attributes-table-group"], body',
          'itemSelector': 'div[data-testid="key-attributes-table-row"]',
          'keySelector': 'div[data-testid="key-attributes-table-name"]',
          'valueSelector': 'div[data-testid="key-attributes-table-value"]',
          'keywords': ['weight'],
        },
      ],
      // Dimensions: same structure, different keywords
      'dimensions': [
        {
          'type': 'list_item',
          'container': 'div[data-module-name="module_attribute"], body',
          'itemSelector': 'div[data-testid="module-attribute"]',
          'keySelector': 'div[data-testid="module-attribute-name"]',
          'valueSelector': 'div[data-testid="module-attribute-value"]',
          'keywords': ['dimension', 'size', 'product size', 'package size'],
        },
        // Priority 2: Mobile layout
        {
          'type': 'list_item',
          'container': 'div[data-testid="key-attributes-table-group"], body',
          'itemSelector': 'div[data-testid="key-attributes-table-row"]',
          'keySelector': 'div[data-testid="key-attributes-table-name"]',
          'valueSelector': 'div[data-testid="key-attributes-table-value"]',
          'keywords': [
            'single package size',
            'dimension',
            'size',
            'package size',
            'product size',
          ],
        },
      ],
      'buttonColor': '#FF6A00',
    },
    'generic': {
      'title': ['h1', '[class*="title"]', '[class*="product-name"]'],
      'price': ['[class*="price"]', '[id*="price"]'],
      'image': ['img[class*="main"]', 'img[class*="product"]'],
      'images': ['img[class*="thumb"]', 'img[class*="gallery"]'],
      'rating': ['[class*="rating"]', '[class*="star"]'],
      'weight': [
        {
          'type': 'selector_text',
          'selector': 'table, div[class*="spec"], div[class*="detail"]',
        },
      ],
      'dimensions': [
        {
          'type': 'selector_text',
          'selector': 'table, div[class*="spec"], div[class*="detail"]',
        },
      ],
      'buttonColor': '#213c86',
    },
  };

  /// Generate JavaScript code for extracting product data
  static String generateExtractionScript(String platform) {
    final selectors = getSelectors(platform);

    return '''
      async function extractProductData() {
        console.log("UA:", navigator.userAgent);
        console.log(
          "Has mobile spec rows:",
          document.querySelectorAll('[data-testid="key-attributes-table-row"]').length
        );
        console.log(
          "Has desktop spec rows:",
          document.querySelectorAll('[data-testid="module-attribute"]').length
        );
        console.log(
          "Has expandable arrow:",
          document.querySelectorAll('[data-testid="mobile-module-wrapper-arrow"]').length
        );
        console.log("Viewport width:", window.innerWidth);
        console.log(
           "Has key attributes table:",
           document.querySelectorAll('[data-testid="key-attributes-table"]').length
         );
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
        

        // Helper function to extract data based on structured strategies
        function extractByStrategies(strategies) {
          if (!strategies || !Array.isArray(strategies)) return null;
          
          for (const strategy of strategies) {
            try {
              let extractedText = null;
              
              if (strategy.type === 'selector_text') {
                 // Simple selector text extraction
                 const selectors = strategy.selector.split(',').map(s => s.trim());
                 for (const sel of selectors) {
                   const el = document.querySelector(sel);
                   if (el) {
                     extractedText = el.innerText || el.textContent;
                     if (extractedText) break;
                   }
                 }
              } else if (strategy.type === 'attribute') {
                 // Attribute extraction
                 const el = document.querySelector(strategy.selector);
                 if (el) {
                   extractedText = el.getAttribute(strategy.attribute);
                 }
              } else if (strategy.type === 'title_attribute') {
                 // ── title_attribute: query by native HTML title attribute ──
                 // Alibaba's attribute name cell has: title="Single gross weight"
                 // The value cell has:                title="0.100 kg"
                 // These are plain HTML attributes always accessible in WebView.
                 const nameSelectors = strategy.nameSelectors || [];
                 for (const nameSel of nameSelectors) {
                   try {
                     const nameEls = document.querySelectorAll(nameSel);
                     for (const nameEl of nameEls) {
                       // Walk up to find the row container
                       const row = nameEl.closest('[data-testid="module-attribute-row"]') ||
                                   nameEl.parentElement;
                       if (!row) continue;
                       // Get the value cell — prefer data-testid, fallback to sibling with title
                       const valueEl = row.querySelector('[data-testid="module-attribute-value"]') ||
                                       row.querySelector('[data-testid="module-attribute-value-text"]');
                       if (valueEl) {
                         // Prefer title attr (already clean text) over innerText
                         extractedText = valueEl.getAttribute('title') ||
                                         valueEl.innerText ||
                                         valueEl.textContent;
                         if (extractedText && extractedText.trim()) {
                           console.log('✅ title_attribute found:', extractedText.trim());
                           break;
                         }
                       }
                       // Fallback: second child's title attribute on the row
                       if (!extractedText && row.children.length >= 2) {
                         const secondChild = row.children[1];
                         extractedText = secondChild.getAttribute('title') ||
                                         secondChild.innerText ||
                                         secondChild.textContent;
                       }
                       if (extractedText && extractedText.trim()) break;
                     }
                     if (extractedText && extractedText.trim()) break;
                   } catch(e2) {
                     console.log('title_attribute error:', nameSel, e2);
                   }
                 }
               } else if (strategy.type === 'text_search') {
                 // \u2500\u2500 text_search: CSS-selector-independent TreeWalker \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
                 // Walks ALL text nodes in ALL frames. Works when CSS selectors
                 // fail in the WebView (e.g. data-testid not queryable on Android).
                 const keywords = strategy.keywords || [];
                 function searchTextInDoc(doc, kws) {
                   try {
                     const walker = doc.createTreeWalker(doc.body, NodeFilter.SHOW_TEXT, null, false);
                     while (walker.nextNode()) {
                       const node = walker.currentNode;
                       const txt = (node.textContent || '').trim();
                       if (!txt || txt.length > 80) continue;
                       const txtLow = txt.toLowerCase();
                       for (const kw of kws) {
                         if (txtLow === kw.toLowerCase() || txtLow.includes(kw.toLowerCase())) {
                           let el = node.parentElement;
                           for (let i = 0; i < 5 && el; i++) {
                             const parent = el.parentElement;
                             if (!parent) break;
                             const children = Array.from(parent.children);
                             const idx = children.indexOf(el);
                             for (let j = idx + 1; j < children.length; j++) {
                               const sib = children[j];
                               const sibTitle = sib.getAttribute ? sib.getAttribute('title') : null;
                               if (sibTitle && sibTitle.trim() && sibTitle.toLowerCase() !== txtLow) return sibTitle.trim();
                               const sibText = (sib.innerText || sib.textContent || '').trim();
                               if (sibText && sibText.toLowerCase() !== txtLow && sibText.length < 100) return sibText;
                             }
                             el = parent;
                           }
                         }
                       }
                     }
                   } catch(searchErr) { console.log('text_search err:', searchErr); }
                   return null;
                 }
                 extractedText = searchTextInDoc(document, keywords);
                 console.log('🔍 text_search result:', extractedText);
                 if (!extractedText) {
                   try {
                     const frames = document.querySelectorAll('iframe');
                     for (const frame of frames) {
                       try { const fd = frame.contentDocument || frame.contentWindow?.document; if (fd) { extractedText = searchTextInDoc(fd, keywords); if (extractedText) { console.log('🔍 text_search iframe:', extractedText); break; } } } catch(e) {}
                     }
                   } catch(e2) {}
                 }
              } else if (strategy.type === 'table_row' || strategy.type === 'list_item') {
                 // Structured extraction from tables or lists
                 const containerSelectors = strategy.container ? strategy.container.split(',') : [null];
                 
                 for (const containerSel of containerSelectors) {
                   // Use querySelectorAll to find ALL matching sections, not just the first one
                   const containers = containerSel ? document.querySelectorAll(containerSel.trim()) : [document.body];
                   if (!containers || containers.length === 0) continue;
                   
                   for (const container of containers) {
                     const rows = container.querySelectorAll(strategy.rowSelector || strategy.itemSelector);
                     for (const row of rows) {
                       // Check key
                       let keyFound = false;
                       // If keySelector is provided, check it. Otherwise check the whole row text.
                       if (strategy.keySelector) {
                         const keyEl = row.querySelector(strategy.keySelector);
                         if (keyEl) {
                           const keyText = (keyEl.innerText || keyEl.textContent || '').trim().toLowerCase();
                           if (strategy.keywords.some(k => keyText.includes(k.toLowerCase()))) {
                             keyFound = true;
                           }
                         }
                       } else {
                          const rowText = (row.innerText || row.textContent || '').trim().toLowerCase();
                          if (strategy.keywords.some(k => rowText.includes(k.toLowerCase()))) {
                             keyFound = true;
                          }
                       }
                       
                       if (keyFound) {
                         // Get value
                         if (strategy.valueSelector) {
                           const valEl = row.querySelector(strategy.valueSelector);
                           if (valEl) {
                             extractedText = valEl.innerText || valEl.textContent;
                           }
                         } else {
                           extractedText = row.innerText || row.textContent;
                         }
                         
                         if (extractedText) break;
                       }
                     }
                     if (extractedText) break;
                   }
                   if (extractedText) break;
                 }
              }
              
              if (extractedText && extractedText.trim()) {
                console.log('✅ Found match with strategy:', strategy.type, 'Values:', extractedText);
                return { text: extractedText.trim(), strategy: strategy };
              }
              
            } catch (e) {
              console.log('Strategy failed:', strategy, e);
            }
          }
          return null;
        }

        // Wait for critical elements to load
        console.log('⏳ Waiting for product data to load...');
        await waitForElement(${_toJsValue(selectors['title'])});

        // Small delay to ensure core data is loaded
        await new Promise(resolve => setTimeout(resolve, 1000));

        // Extract core data
        const title = trySelectors(${_toJsValue(selectors['title'])});
        const price = trySelectors(${_toJsValue(selectors['price'])});
        
        // Try multiple methods to get main image
        let image = trySelectors(${_toJsValue(selectors['image'])}, 'src') ||
                    trySelectors(${_toJsValue(selectors['image'])}, 'data-src') ||
                    trySelectors(${_toJsValue(selectors['image'])}, 'data-original') ||
                    extractMetaImage() ||
                    extractSchemaImage();
        
        const images = extractImages(${_toJsValue(selectors['images'])});
        
        // If no main image found but we have gallery images, use first gallery image
        if (!image && images.length > 0) {
          image = images[0];
        }
        
        const rating = trySelectors(${_toJsValue(selectors['rating'])});
        const description = trySelectors(${_toJsValue(selectors['description'] ?? [])});
        const currency = trySelectors(${_toJsValue(selectors['currency'] ?? [])});
        const reviewCount = trySelectors(${_toJsValue(selectors['reviewCount'] ?? [])});

        // ── Weight & Dimensions (OPTIONAL – never blocks cart addition) ──────
        // On SPAs (Alibaba, AliExpress) the specs section renders LAZILY after
        // the title/image. We poll for the actual row element for up to 8s.
        let weight = null;
        let dimensions = null;
        let weightText = null;
        let dimensionText = null;

        // Wait until spec rows appear OR timeout
        async function waitForSpecRows(selectors, timeoutMs) {
          const end = Date.now() + timeoutMs;
          while (Date.now() < end) {
            for (const sel of selectors) {
              try {
                const el = document.querySelector(sel);
                if (el) { console.log('✅ Spec rows found:', sel); return true; }
              } catch(_) {}
            }
            await new Promise(r => setTimeout(r, 600));
          }
          console.log('⚠️ Spec rows not found after timeout, attempting anyway...');
          return false;
        }

        // Selectors that indicate the spec section is rendered
        const specIndicators = [
          'div[data-testid="module-attribute-row"]',
          'div[data-testid="module-attribute-name"]',
          '.specification--list--GZuXzRX li',
          '#prodDetails tr',
          '#detailBullets_feature_div li',
          '.prodDetTable tr'
        ];
        await waitForSpecRows(specIndicators, 8000);

        try {
           const weightResult = extractByStrategies(${_toJsValue(selectors['weight'] ?? [])});
           if (weightResult) {
              weightText = weightResult.text;
              
             // Try to parse weight from text
             const weightPatterns = [
               /(\\d+\\.?\\d*)\\s*(kg|kilogram|kilograms)/i,
               /(\\d+\\.?\\d*)\\s*(lb|lbs|pound|pounds)/i,
               /(\\d+\\.?\\d*)\\s*(g|gram|grams)(?!\\s*cm)/i,
               /(\\d+\\.?\\d*)\\s*(oz|ounce|ounces)/i,
             ];
             
             for (const pattern of weightPatterns) {
               const match = weightText.match(pattern);
               if (match) {
                 const value = parseFloat(match[1]);
                 let unit = match[2].toLowerCase();
                 
                 if (unit.includes('kilogram')) unit = 'kg';
                 else if (unit.includes('pound') || unit === 'lbs') unit = 'lb';
                 else if (unit.includes('gram') && !unit.includes('kilogram')) unit = 'g';
                 else if (unit.includes('ounce')) unit = 'oz';
                 
                 if (!isNaN(value) && value > 0) {
                   weight = { value, unit };
                   console.log('✅ Weight extracted:', weight, 'from text:', weightText);
                   break;
                 }
               }
             }
           }
        } catch (e) {
          console.log('⚠️ Weight extraction failed (non-critical):', e);
        }
        
        try {
           const dimResult = extractByStrategies(${_toJsValue(selectors['dimensions'] ?? [])});
           if (dimResult) {
              dimensionText = dimResult.text;
              
              // Try to parse dimensions from text
              if (dimensionText) {
                // Normalize text: replace multiple spaces with single space, remove hidden characters
                dimensionText = dimensionText.replace(/\s+/g, ' ').trim();
              }

              const dimPatterns = [
                // Amazon format: 5.5"D x 5.5"W x 12"H (inches with D/W/H labels)
                /(\\d+\\.?\\d*)\\s*["'']\\s*[DdLl]?\\s*[xX×]\\s*(\\d+\\.?\\d*)\\s*["'']\\s*[Ww]?\\s*[xX×]\\s*(\\d+\\.?\\d*)\\s*["'']\\s*[Hh]?/i,
                // Standard format with unit at end: 30 x 20 x 10 cm
                /(\\d+\\.?\\d*)\\s*[xX×]\\s*(\\d+\\.?\\d*)\\s*[xX×]\\s*(\\d+\\.?\\d*)\\s*(cm|centimeter|centimeters|inch|inches|in|mm|millimeter|millimeters|m|meter|meters)/i,
                // Format with unit after each number: 30cm x 20cm x 10cm
                /(\\d+\\.?\\d*)\\s*(cm|in|mm|m)\\s*[xX×]\\s*(\\d+\\.?\\d*)\\s*(cm|in|mm|m)\\s*[xX×]\\s*(\\d+\\.?\\d*)\\s*(cm|in|mm|m)/i,
                // AliExpress/Alibaba format: 900*930*520mm or 35X30X1 cm
                /(\\d+\\.?\\d*)\\s*[\\*xX×]\\s*(\\d+\\.?\\d*)\\s*[\\*xX×]\\s*(\\d+\\.?\\d*)\\s*(mm|cm|m|kg)/i
              ];
              
              for (const pattern of dimPatterns) {
                const match = dimensionText.match(pattern);
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
                    // Standard format: 30 x 20 x 10 cm or 900*930*520mm
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
                      console.log('✅ Dimensions extracted:', dimensions, 'from text:', dimensionText);
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

  /// Convert Dart value to JSON-compatible string
  static String _toJsValue(dynamic value) {
    return jsonEncode(value);
  }
}
