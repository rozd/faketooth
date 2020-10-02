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

        NSArray* selectors = @[
            @[
                NSStringFromSelector(@selector(scanForPeripheralsWithServices:options:)),
                NSStringFromSelector(@selector(faketooth_scanForPeripheralsWithServices:options:))
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

#pragma mark - Overridden methods

- (CBManagerState)state {
    if (!CBCentralManager.simulatedPeripherals) {
        return [super state];
    }
    return CBManagerStatePoweredOn;
}

#pragma mark - Swizzled methods

- (void)faketooth_scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options {
    NSLog(@"[Faketooth] scanForPeripheralsWithServices:options:");
    if (!CBCentralManager.simulatedPeripherals) {
        [self faketooth_scanForPeripheralsWithServices:serviceUUIDs options:options];
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(centralManager:didDiscoverPeripheral:advertisementData:RSSI:)]) {
            for (FaketoothPeripheral* peripheral in CBCentralManager.simulatedPeripherals) {
                [self.delegate centralManager:self didDiscoverPeripheral:peripheral advertisementData:peripheral.advertisementData RSSI:[NSNumber numberWithInt:0]];
            }
        }
    });
}

- (NSArray<CBPeripheral*>*)faketooth_retrievePeripheralsWithIdentifiers:(NSArray<NSUUID *> *)identifiers {
    NSLog(@"[Faketooth] retrievePeripheralsWithIdentifiers:");
    if (!CBCentralManager.simulatedPeripherals) {
        return [self faketooth_retrievePeripheralsWithIdentifiers:identifiers];
    }

    return [CBCentralManager.simulatedPeripherals filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FaketoothPeripheral* peripheral, NSDictionary* bindings) {
        return [identifiers containsObject:peripheral.identifier];
    }]];
}

- (void)faketooth_connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *,id> *)options {
    NSLog(@"[Faketooth] connectPeripheral:options:");
    if (!CBCentralManager.simulatedPeripherals) {
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

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [faketoothPeripheral setState:CBPeripheralStateConnected];
        if (self.delegate && [self.delegate respondsToSelector:@selector(centralManager:didConnectPeripheral:)]) {
            [self.delegate centralManager:self didConnectPeripheral:peripheral];
        }
    });
}

- (void)faketooth_cancelPeripheralConnection:(CBPeripheral *)peripheral {
    NSLog(@"[Faketooth] cancelPeripheralConnection:");
    if (!CBCentralManager.simulatedPeripherals) {
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

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [faketoothPeripheral setState:CBPeripheralStateDisconnected];
        if (self.delegate && [self.delegate respondsToSelector:@selector(centralManager:didDisconnectPeripheral:error:)]) {
            [self.delegate centralManager:self didDisconnectPeripheral:peripheral error:nil];
        }
    });
}

@end
