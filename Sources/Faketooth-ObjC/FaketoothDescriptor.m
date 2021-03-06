//
//  FakeDescriptor.m
//  Faketooth
//
//  Created by Max Rozdobudko on 6/17/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

#import "FaketoothDescriptor.h"

@implementation FaketoothDescriptor {
    CBCharacteristic* _characteristic;
    CBUUID* _uuid;
    FaketoothDescriptorValueProducer _valueProducer;
    FaketoothDescriptorValueHandler _valueHandler;
    NSData* _value;
}

- (CBCharacteristic*)characteristic {
    return _characteristic;
}
- (void)setCharacteristic:(CBCharacteristic*)characteristic {
    _characteristic = characteristic;
}

- (CBUUID*)UUID {
    return _uuid;
}

- (id)value {
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
    if (_valueHandler) {
        _valueHandler(value);
    }
}

- (instancetype)init {
    return self;
}

- (instancetype)initWithUUID:(CBUUID*)uuid valueProducer:(nullable FaketoothDescriptorValueProducer)valueProducer valueHandler:(nullable FaketoothDescriptorValueHandler)valueHandler {
    _uuid           = uuid;
    _valueProducer  = valueProducer;
    _valueHandler   = valueHandler;
    return self;
}

@end
