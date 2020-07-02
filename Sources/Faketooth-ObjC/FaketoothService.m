//
//  FakeService.m
//  Faketooth
//
//  Created by Max Rozdobudko on 6/17/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

#import "FaketoothService.h"
#import "FaketoothCharacteristic.h"

@implementation FaketoothService {
    CBUUID* _uuid;
    NSArray<CBCharacteristic*>* _characteristics;
    NSArray<CBService*>* _includedServices;
    CBPeripheral* _peripheral;
    BOOL _isPrimary;
}

- (CBPeripheral*)peripheral {
    return _peripheral;
}
- (void)setPeripheral:(CBPeripheral*)peripheral {
    _peripheral = peripheral;
}

- (CBUUID*)UUID {
    return _uuid;
}

- (BOOL)isPrimary {
    return _isPrimary;
}

- (NSArray<CBCharacteristic*>*)characteristics {
    return _characteristics;
}

- (NSArray<CBService*>*)includedServices {
    return _includedServices;
}

- (instancetype)init {
    return self;
}

- (instancetype)initWithUUID:(CBUUID*)uuid isPrimary:(BOOL)isPrimary characteristics:(NSArray<CBCharacteristic*>*)characteristics {
    self = [self initWithUUID:uuid isPrimary:isPrimary characteristics:characteristics includedServices:nil];
    return self;
}

- (instancetype)initWithUUID:(CBUUID*)uuid isPrimary:(BOOL)isPrimary characteristics:(NSArray<CBCharacteristic*>*)characteristics includedServices:(nullable NSArray<CBService*>*) includedServices {
    _uuid             = uuid;
    _isPrimary        = isPrimary;
    _characteristics  = characteristics;
    _includedServices = includedServices;

    [_characteristics enumerateObjectsUsingBlock:^(CBCharacteristic * _Nonnull characteristic, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([characteristic isKindOfClass:[FaketoothCharacteristic class]]) {
            [((FaketoothCharacteristic*)characteristic) setService:self];
        }
    }];

    return self;
}

@end
