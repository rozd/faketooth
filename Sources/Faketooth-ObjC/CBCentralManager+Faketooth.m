//
//  CBCentralManager+Faketooth.m
//  Faketooth
//
//  Created by Max Rozdobudko on 6/15/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

#import <objc/runtime.h>

#import "CBCentralManager+Faketooth.h"
#import "FaketoothSettings.h"

static char isScanningWhenUseFaketoothKey;
static char stateWhenUseFaketoothKey;

@implementation CBCentralManager (Faketooth)

#pragma mark - Faketooth settings for CBCentralManager

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

        NSArray* selectors = @[
            @[
                NSStringFromSelector(@selector(scanForPeripheralsWithServices:options:)),
                NSStringFromSelector(@selector(faketooth_scanForPeripheralsWithServices:options:))
            ],
            @[
                NSStringFromSelector(@selector(stopScan)),
                NSStringFromSelector(@selector(faketooth_stopScan))
            ],
            @[
                NSStringFromSelector(@selector(retrievePeripheralsWithIdentifiers:)),
                NSStringFromSelector(@selector(faketooth_retrievePeripheralsWithIdentifiers:))
            ],
            @[
                NSStringFromSelector(@selector(connectPeripheral:options:)),
                NSStringFromSelector(@selector(faketooth_connectPeripheral:options:))
            ],
            @[
                NSStringFromSelector(@selector(cancelPeripheralConnection:)),
                NSStringFromSelector(@selector(faketooth_cancelPeripheralConnection:))
            ],
            @[
                NSStringFromSelector(@selector(isScanning)),
                NSStringFromSelector(@selector(faketooth_isScanning))
            ],
            @[
                NSStringFromSelector(@selector(state)),
                NSStringFromSelector(@selector(faketooth_state))
            ]
        ];

        for (NSArray* pair in selectors) {
            SEL originalSelector = NSSelectorFromString([pair objectAtIndex:0]);
            SEL swizzledSelector = NSSelectorFromString([pair objectAtIndex:1]);

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
        }
    });
}

#pragma mark - Faketooth properties

- (NSNumber*)isScanningWhenUseFaketooth {
    return objc_getAssociatedObject(self, &isScanningWhenUseFaketoothKey);
}
- (void)setIsScanningWhenUseFaketooth:(NSNumber*)value {
    objc_setAssociatedObject(self, &isScanningWhenUseFaketoothKey, value, OBJC_ASSOCIATION_RETAIN);
}

- (NSNumber*)stateWhenUseFaketooth {
    return objc_getAssociatedObject(self, &stateWhenUseFaketoothKey);
}
- (void)setStateWhenUseFaketooth:(NSNumber*)state {
    objc_setAssociatedObject(self, &stateWhenUseFaketoothKey, state, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - Swizzled properties

- (CBManagerState)faketooth_state {
    if (![self canContinueFaketoothSimulation]) {
        return [self faketooth_state];
    }
    NSNumber* number = [self stateWhenUseFaketooth];
    if (!number) {
        return CBManagerStatePoweredOn;
    }
    return (CBManagerState) [number integerValue];
}

- (BOOL)faketooth_isScanning {
    if (![self canContinueFaketoothSimulation]) {
        return [self faketooth_isScanning];
    }
    NSNumber* number = [self isScanningWhenUseFaketooth];
    return [number boolValue];
}

#pragma mark - Swizzled methods

- (void)faketooth_scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options {
    NSLog(@"[Faketooth] scanForPeripheralsWithServices:options:");
    if (![self canContinueFaketoothSimulation]) {
        [self faketooth_scanForPeripheralsWithServices:serviceUUIDs options:options];
        return;
    }

    [self setIsScanningWhenUseFaketooth:[NSNumber numberWithBool:YES]];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FaketoothSettings.delay.scanForPeripheralDelayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(centralManager:didDiscoverPeripheral:advertisementData:RSSI:)]) {
            for (FaketoothPeripheral* peripheral in CBCentralManager.simulatedPeripherals) {
                [self.delegate centralManager:self didDiscoverPeripheral:peripheral advertisementData:peripheral.advertisementData RSSI:[NSNumber numberWithInt:0]];
            }
        }
    });
}

- (void)faketooth_stopScan {
    NSLog(@"[Faketooth] stopScan");
    if (![self canContinueFaketoothSimulation]) {
        [self faketooth_stopScan];
        return;
    }
    [self setIsScanningWhenUseFaketooth:[NSNumber numberWithBool:NO]];
}

- (NSArray<CBPeripheral*>*)faketooth_retrievePeripheralsWithIdentifiers:(NSArray<NSUUID *> *)identifiers {
    NSLog(@"[Faketooth] retrievePeripheralsWithIdentifiers:");
    if (![self canContinueFaketoothSimulation]) {
        return [self faketooth_retrievePeripheralsWithIdentifiers:identifiers];
    }

    return [CBCentralManager.simulatedPeripherals filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FaketoothPeripheral* peripheral, NSDictionary* bindings) {
        return [identifiers containsObject:peripheral.identifier];
    }]];
}

- (void)faketooth_connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *,id> *)options {
    NSLog(@"[Faketooth] connectPeripheral:options:");
    if (![self canContinueFaketoothSimulation]) {
        [self faketooth_connectPeripheral:peripheral options:options];
        return;
    }

    FaketoothPeripheral* faketoothPeripheral = (FaketoothPeripheral*)peripheral;

    if (!faketoothPeripheral) {
        NSLog(@"[Faketooth] Warning: specified peripheral \"%@\" is not FaketoothPeripheral subclass.", peripheral);
        [self faketooth_connectPeripheral:peripheral options:options];
        return;
    }

    [faketoothPeripheral setState:CBPeripheralStateConnecting];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FaketoothSettings.delay.connectPeripheralDelayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [faketoothPeripheral setState:CBPeripheralStateConnected];
        if (self.delegate && [self.delegate respondsToSelector:@selector(centralManager:didConnectPeripheral:)]) {
            [self.delegate centralManager:self didConnectPeripheral:peripheral];
        }
    });
}

- (void)faketooth_cancelPeripheralConnection:(CBPeripheral *)peripheral {
    NSLog(@"[Faketooth] cancelPeripheralConnection:");
    if (![self canContinueFaketoothSimulation]) {
        [self faketooth_cancelPeripheralConnection:peripheral];
        return;
    }

    FaketoothPeripheral* faketoothPeripheral = (FaketoothPeripheral*)peripheral;

    if (!faketoothPeripheral) {
        NSLog(@"[Faketooth] Warning: specified peripheral \"%@\" is not FaketoothPeripheral subclass.", peripheral);
        [self faketooth_cancelPeripheralConnection:peripheral];
        return;
    }

    [faketoothPeripheral setState:CBPeripheralStateDisconnecting];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FaketoothSettings.delay.cancelPeripheralConnectionDelayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [faketoothPeripheral setState:CBPeripheralStateDisconnected];
        if (self.delegate && [self.delegate respondsToSelector:@selector(centralManager:didDisconnectPeripheral:error:)]) {
            [self.delegate centralManager:self didDisconnectPeripheral:peripheral error:nil];
        }
    });
}

#pragma mark - Faketooth utils

- (BOOL)canContinueFaketoothSimulation {
    if (!CBCentralManager.simulatedPeripherals) {
        NSLog(@"[Faketooth] Warning: Faketooth is enabled while no simulated peripheral are defined. Make sure you don't use Faketooth on producetion.");
        return NO;
    }
    return YES;
}

@end
