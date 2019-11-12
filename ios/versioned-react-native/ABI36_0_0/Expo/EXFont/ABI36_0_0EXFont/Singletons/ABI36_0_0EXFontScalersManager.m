// Copyright 2018-present 650 Industries. All rights reserved.

#import <ABI36_0_0EXFont/ABI36_0_0EXFontScalersManager.h>

#import <ABI36_0_0UMCore/ABI36_0_0UMDefines.h>
#import <ABI36_0_0EXFont/ABI36_0_0EXFont.h>

#import <objc/runtime.h>

static NSPointerArray *currentFontScalers;

@implementation UIFont (ABI36_0_0EXFontLoader)

- (UIFont *)ABI36_0_0EXFontWithSize:(CGFloat)fontSize
{
  for (id<ABI36_0_0UMFontScalerInterface> fontScaler in currentFontScalers) {
    UIFont *scaledFont = [fontScaler scaledFont:self toSize:fontSize];
    if (scaledFont) {
      return scaledFont;
    }
  }

  return [self ABI36_0_0EXFontWithSize:fontSize];
}

@end

/**
 * A singleton module responsible for overriding UIFont's
 * fontWithSize: method which is used for scaling fonts.
 * We need this one, central place to store the scalers
 * as for now to get rid of timing problems when backgrounding/
 * foregrounding apps.
 */

@implementation ABI36_0_0EXFontScalersManager

ABI36_0_0UM_REGISTER_SINGLETON_MODULE(FontScalersManager);

+ (void)initialize
{
  static dispatch_once_t initializeCurrentFontScalersOnce;
  dispatch_once(&initializeCurrentFontScalersOnce, ^{
    currentFontScalers = [NSPointerArray weakObjectsPointerArray];

    Class uiFont = [UIFont class];
    SEL uiUpdate = @selector(fontWithSize:);
    SEL exUpdate = @selector(ABI36_0_0EXFontWithSize:);

    method_exchangeImplementations(class_getInstanceMethod(uiFont, uiUpdate),
                                   class_getInstanceMethod(uiFont, exUpdate));
  });
}

- (void)registerFontScaler:(id<ABI36_0_0UMFontScalerInterface>)fontScaler
{
  [currentFontScalers compact];
  [currentFontScalers addPointer:(__bridge void * _Nullable)(fontScaler)];
}

@end