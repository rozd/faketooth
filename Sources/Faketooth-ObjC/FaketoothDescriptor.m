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
    return _valueProducer();
}

- (instancetype)init {
    return self;
}

- (instancetype)initWithUUID:(CBUUID*)uuid valueProducer:(FaketoothDescriptorValueProducer)valueProducer {
    _uuid           = uuid;
    _valueProducer  = valueProducer;
    return self;
}

@end
