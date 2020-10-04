//
//  FakeCharacteristic.m
//  Faketooth
//
//  Created by Max Rozdobudko on 6/17/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

#import "FaketoothCharacteristic.h"
#import "FaketoothDescriptor.h"
#import "FaketoothPeripheral.h"

@implementation FaketoothCharacteristic {
    CBService* _service;
    CBUUID* _uuid;
    CBCharacteristicProperties _properties;
    BOOL _isNotifying;
    NSArray<CBDescriptor*>* _descriptors;
    FaketoothPeripheralValueProducer _valueProducer;
    NSData* _value;
    NSTimer* _notifyTimer;
}

- (CBService*)service {
    return _service;
}
- (void)setService:(CBService*)service {
    _service = service;
}

- (CBUUID*)UUID {
    return _uuid;
}

- (CBCharacteristicProperties)properties {
    return _properties;
}

- (BOOL)isNotifying {
    return _isNotifying;
}

- (NSData *)value {
    if (_value) {
        return _value;
    }
    if (_valueProducer) {
        return _valueProducer();
    }
    return nil;
}
- (void)setValue:(nullable NSData*)value {
    _value = value;
}

- (nullable NSArray<CBDescriptor*>*)descriptors {
    return _descriptors;
}

- (instancetype)init {
    return self;
}

- (instancetype)initWithUUID:(CBUUID*)uuid dataProducer:(nullable FaketoothPeripheralValueProducer)valueProducer properties:(CBCharacteristicProperties)properties {
    self = [self initWithUUID:uuid dataProducer:valueProducer properties:properties descriptors:nil];
    return self;
}

- (instancetype)initWithUUID:(CBUUID*)uuid dataProducer:(nullable FaketoothPeripheralValueProducer)valueProducer properties:(CBCharacteristicProperties)properties descriptors:(nullable NSArray<CBDescriptor*>*)descriptors {
    _uuid           = uuid;
    _properties     = properties;
    _descriptors    = descriptors;
    _valueProducer  = valueProducer;

    [_descriptors enumerateObjectsUsingBlock:^(CBDescriptor * _Nonnull descriptor, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([descriptor isKindOfClass:[FaketoothDescriptor class]]) {
            [((FaketoothDescriptor*)descriptor) setCharacteristic:self];
        }
    }];

    return self;
}

- (void)setIsNotifying:(BOOL)value {
    _isNotifying = value;
    if (_isNotifying) {
        [self createNotifyTimerIfNeeded];
    } else {
        [self removeNotifyTimerIfExists];
    }
}

- (void)createNotifyTimerIfNeeded {
    NSLog(@"[Faketooth] createNotifyTimerIfNeeded");
    if (!self.isNotifying) {
        return;
    }
    _notifyTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 repeats:true block:^(NSTimer * _Nonnull timer) {
        FaketoothPeripheral* peripheral = (FaketoothPeripheral*)self.service.peripheral;
        NSLog(@"[Faketooth] notify timer for peripheral: %@", peripheral);
        if (peripheral) {
            NSLog(@"[Faketooth] before [peripheral notifyDidUpdateValueForCharacteristic:self];");
            [peripheral notifyDidUpdateValueForCharacteristic:self];
            NSLog(@"[Faketooth] after [peripheral notifyDidUpdateValueForCharacteristic:self];");
        }
    }];
}

- (void)removeNotifyTimerIfExists {
    NSLog(@"[Faketooth] removeNotifyTimerIfExists");
    if (!_notifyTimer) {
        return;
    }
    [_notifyTimer invalidate];
    _notifyTimer = nil;
}

@end
