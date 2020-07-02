//
//  FakeCharacteristic.m
//  Faketooth
//
//  Created by Max Rozdobudko on 6/17/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

#import "FaketoothCharacteristic.h"
#import "FaketoothDescriptor.h"

@implementation FaketoothCharacteristic {
    CBService* _service;
    CBUUID* _uuid;
    CBCharacteristicProperties _properties;
    BOOL _isNotifying;
    NSArray<CBDescriptor*>* _descriptors;
    FaketoothPeripheralValueProducer _valueProducer;
    NSData* _value;
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

- (instancetype)initWithUUID:(CBUUID*)uuid dataProducer:(nullable FaketoothPeripheralValueProducer)valueProducer properties:(CBCharacteristicProperties)properties isNotifying:(BOOL)isNotifying {
    self = [self initWithUUID:uuid dataProducer:valueProducer properties:properties isNotifying:isNotifying descriptors:nil];
    return self;
}

- (instancetype)initWithUUID:(CBUUID*)uuid dataProducer:(nullable FaketoothPeripheralValueProducer)valueProducer properties:(CBCharacteristicProperties)properties isNotifying:(BOOL)isNotifying descriptors:(nullable NSArray<CBDescriptor*>*)descriptors {
    _uuid           = uuid;
    _properties     = properties;
    _isNotifying    = isNotifying;
    _descriptors    = descriptors;
    _valueProducer  = valueProducer;

    [_descriptors enumerateObjectsUsingBlock:^(CBDescriptor * _Nonnull descriptor, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([descriptor isKindOfClass:[FaketoothDescriptor class]]) {
            [((FaketoothDescriptor*)descriptor) setCharacteristic:self];
        }
    }];
    
    return self;
}


@end
