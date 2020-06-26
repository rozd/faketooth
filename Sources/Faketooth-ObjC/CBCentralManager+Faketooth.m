//
//  CBCentralManager+Faketooth.m
//  Faketooth
//
//  Created by Max Rozdobudko on 6/15/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

#import <objc/runtime.h>

#import "CBCentralManager+Faketooth.h"

@implementation CBCentralManager (Goldtooth)

static NSArray<FaketoothPeripheral*>* _simulatedPeripherals = nil;
+ (NSArray<FaketoothPeripheral*>*)simulatedPeripherals {
    return _simulatedPeripherals;
}
+ (void)setSimulatedPeripherals:(NSArray<FaketoothPeripheral*>*)value {
    _simulatedPeripherals = value;
}

+ (BOOL)isSimulated {
    return !!CBCentralManager.simulatedPeripherals;
}

#pragma mark - Swizzling

+ (void)load {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        Class class = [self class];

        SEL originalSelector = @selector(scanForPeripheralsWithServices:options:);
        SEL swizzledSelector = @selector(goldtooth_scanForPeripheralsWithServices:options:);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        BOOL didAddMethod =
            class_addMethod(class,
                            originalSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Overridden methods

- (CBManagerState)state {
    if (!CBCentralManager.simulatedPeripherals) {
        return [super state];
    }
    return CBManagerStatePoweredOn;
}

#pragma mark - Swizzled methods

- (void)goldtooth_scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options {
    if (!CBCentralManager.simulatedPeripherals) {
        [self goldtooth_scanForPeripheralsWithServices:serviceUUIDs options:options];
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(centralManager:didDiscoverPeripheral:advertisementData:RSSI:)]) {
            for (FaketoothPeripheral* peripheral in CBCentralManager.simulatedPeripherals) {
                [self.delegate centralManager:self didDiscoverPeripheral:peripheral advertisementData:@{} RSSI:[NSNumber numberWithInt:0]];
            }
        }
    });
}

@end
