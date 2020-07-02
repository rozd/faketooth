//
//  FakePeripheral.m
//  Faketooth
//
//  Created by Max Rozdobudko on 6/15/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

#import "FaketoothPeripheral.h"
#import "FaketoothService.h"
#import "FaketoothCharacteristic.h"
#import "FaketoothDescriptor.h"

@implementation FaketoothPeripheral {
    NSUUID* _identifier;
    NSString* _name;
    NSArray<CBService*>* _services;
    CBPeripheralState _state;
}

- (NSUUID*)identifier {
    return _identifier;
}

- (CBPeripheralState)state {
    NSLog(@"[Faketooth] Peripheral's state to return %li", (long)_state);
    return _state;
}
- (void)setState:(CBPeripheralState)state {
    _state = state;
}

- (NSString*)name {
    return _name;
}

- (NSArray<CBService*>*)services {
    NSLog(@"[Faketooth] Peripheral's services to return %@", _services);
    return _services;
}

- (instancetype)init {
    return self;
}

- (instancetype)initWithIdentifier:(NSUUID*)identifier name:(NSString*)name services:(NSArray<CBService*>*)services {
    _identifier = identifier;
    _name       = name;
    _services   = services;
    _state      = CBPeripheralStateDisconnected;

    [_services enumerateObjectsUsingBlock:^(CBService * _Nonnull service, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([service isKindOfClass:FaketoothService.class]) {
            [((FaketoothService*)service) setPeripheral:self];
        }
    }];

    return self;
}

- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"[Faketooth] readValueForCharacteristic");
    if (self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didUpdateValueForCharacteristic:error:)]) {
        [self.delegate peripheral:self didUpdateValueForCharacteristic:characteristic error:nil];
    }
}

- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type {
    NSLog(@"[Faketooth] writeValue:forCharacteristic:type:");
    FaketoothCharacteristic* faketoothCharacteristic = (FaketoothCharacteristic*)characteristic;
    if (!faketoothCharacteristic) {
        NSLog(@"[Faketooth] Warning: specified characteristic \"%@\" is not FaketoothCharacteristic subclass.", characteristic);
        [super writeValue:data forCharacteristic:characteristic type:type];
        return;
    }
    [faketoothCharacteristic setValue:data];
    if (type == CBCharacteristicWriteWithResponse) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didWriteValueForCharacteristic:error:)]) {
            [self.delegate peripheral:self didWriteValueForCharacteristic:characteristic error:nil];
        }
    }
}

- (NSUInteger)maximumWriteValueLengthForType:(CBCharacteristicWriteType)type {
    NSLog(@"[Faketooth] maximumWriteValueLengthForType:");
    return 20;
}

- (void)readValueForDescriptor:(CBDescriptor *)descriptor {
    NSLog(@"[Faketooth] readValueForDescriptor:");
    if (self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didUpdateValueForDescriptor:error:)]) {
        [self.delegate peripheral:self didUpdateValueForDescriptor:descriptor error:nil];
    }
}

- (void)writeValue:(NSData *)data forDescriptor:(CBDescriptor *)descriptor {
    NSLog(@"[Faketooth] writeValue:forDescriptor:");
    FaketoothDescriptor* faketoothDescriptor = (FaketoothDescriptor*)descriptor;
    if (!descriptor) {
        NSLog(@"[Faketooth] Warning: specified descriptor \"%@\" is not FaketoothDescriptor subclass.", descriptor);
        [super writeValue:data forDescriptor:descriptor];
        return;
    }
    [faketoothDescriptor setValue:data];
    if (self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didWriteValueForDescriptor:error:)]) {
        [self.delegate peripheral:self didWriteValueForDescriptor:descriptor error:nil];
    }
}

- (void)discoverServices:(NSArray<CBUUID *> *)serviceUUIDs {
    NSLog(@"[Faketooth] discoverServices");
    if (self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didDiscoverServices:)]) {
        [self.delegate peripheral:self didDiscoverServices:nil];
    }
}

- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service {
    NSLog(@"[Faketooth] discoverCharacteristics:forService:");
    if (self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didDiscoverCharacteristicsForService:error:)]) {
        [self.delegate peripheral:self didDiscoverCharacteristicsForService:service error:nil];
    }
}

- (void)discoverIncludedServices:(NSArray<CBUUID *> *)includedServiceUUIDs forService:(CBService *)service {
    NSLog(@"[Faketooth] includedServiceUUIDs:forService:");
    if (self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didDiscoverIncludedServicesForService:error:)]) {
        [self.delegate peripheral:self didDiscoverIncludedServicesForService:service error:nil];
    }
}

- (void)discoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"[Faketooth] discoverDescriptorsForCharacteristic:");
    if (self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didDiscoverDescriptorsForCharacteristic:error:)]) {
        [self.delegate peripheral:self didDiscoverDescriptorsForCharacteristic:characteristic error:nil];
    }
}

@end
