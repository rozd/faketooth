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
#import "FaketoothSettings.h"

@implementation FaketoothPeripheral {
    NSUUID* _identifier;
    NSString* _name;
    NSArray<CBService*>* _services;
    CBPeripheralState _state;
    NSDictionary<NSString*, id>* _advertisementData;
}

- (NSDictionary<NSString*, id>*)advertisementData {
    if (!_advertisementData) {
        return @{};
    }
    return _advertisementData;
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

- (instancetype)initWithIdentifier:(NSUUID*)identifier name:(NSString*)name services:(nullable NSArray<CBService*>*)services advertisementData:(nullable NSDictionary<NSString*, id>*)advertisementData {
    _identifier = identifier;
    _name       = name;
    _services   = services;
    _state      = CBPeripheralStateDisconnected;

    if (_services) {
        [_services enumerateObjectsUsingBlock:^(CBService * _Nonnull service, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([service isKindOfClass:FaketoothService.class]) {
                [((FaketoothService*)service) setPeripheral:self];
            }
        }];
    }

    if (!advertisementData) {
        NSMutableArray* serviceUUIDs = [NSMutableArray array];
        if (_services) {
            [_services enumerateObjectsUsingBlock:^(CBService * _Nonnull service, NSUInteger idx, BOOL * _Nonnull stop) {
                [serviceUUIDs addObject:service.UUID];
            }];
        }
        _advertisementData = @{
            CBAdvertisementDataLocalNameKey: name,
            CBAdvertisementDataServiceUUIDsKey: serviceUUIDs,
        };
    } else {
        _advertisementData = advertisementData;
    }

    return self;
}

- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"[Faketooth] readValueForCharacteristic");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FaketoothSettings.delay.readValueForCharacteristicDelayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self notifyDidUpdateValueForCharacteristic:characteristic];
    });
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FaketoothSettings.delay.writeValueForCharacteristicDelayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.delegate peripheral:self didWriteValueForCharacteristic:characteristic error:nil];
            });
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FaketoothSettings.delay.readValueForDescriptorDelayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate peripheral:self didUpdateValueForDescriptor:descriptor error:nil];
        });
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FaketoothSettings.delay.writeValueForDescriptorDelayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate peripheral:self didWriteValueForDescriptor:descriptor error:nil];
        });
    }
}

- (void)discoverServices:(NSArray<CBUUID *> *)serviceUUIDs {
    NSLog(@"[Faketooth] discoverServices");
    if (self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didDiscoverServices:)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FaketoothSettings.delay.discoverServicesDelayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate peripheral:self didDiscoverServices:nil];
        });
    }
}

- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service {
    NSLog(@"[Faketooth] discoverCharacteristics:forService:");
    if (self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didDiscoverCharacteristicsForService:error:)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FaketoothSettings.delay.discoverCharacteristicsDelayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate peripheral:self didDiscoverCharacteristicsForService:service error:nil];
        });
    }
}

- (void)discoverIncludedServices:(NSArray<CBUUID *> *)includedServiceUUIDs forService:(CBService *)service {
    NSLog(@"[Faketooth] includedServiceUUIDs:forService:");
    if (self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didDiscoverIncludedServicesForService:error:)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FaketoothSettings.delay.discoverIncludedServicesDelayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate peripheral:self didDiscoverIncludedServicesForService:service error:nil];
        });
    }
}

- (void)discoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"[Faketooth] discoverDescriptorsForCharacteristic:");
    if (self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didDiscoverDescriptorsForCharacteristic:error:)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FaketoothSettings.delay.discoverDescriptorsForCharacteristicDelayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate peripheral:self didDiscoverDescriptorsForCharacteristic:characteristic error:nil];
        });
    }
}

- (void)notifyDidUpdateValueForCharacteristic:(CBCharacteristic*)characteristic {
    NSLog(@"[Faketooth] notifyDidUpdateValueForCharacteristic:");
    if (self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didUpdateValueForCharacteristic:error:)]) {
        [self.delegate peripheral:self didUpdateValueForCharacteristic:characteristic error:nil];
    }
}

@end
