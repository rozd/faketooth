//
//  FakeCharacteristic.h
//  Faketooth
//
//  Created by Max Rozdobudko on 6/17/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSData* _Nullable (^FaketoothPeripheralDataProducer)(void);

@interface FaketoothCharacteristic : CBCharacteristic

- (void)setService:(CBService*)service;

- (instancetype)init;
- (instancetype)initWithUUID:(CBUUID*)uuid dataProducer:(FaketoothPeripheralDataProducer)dataProducer properties:(CBCharacteristicProperties)properties isNotifying:(BOOL)isNotifying;
- (instancetype)initWithUUID:(CBUUID*)uuid dataProducer:(FaketoothPeripheralDataProducer)dataProducer properties:(CBCharacteristicProperties)properties isNotifying:(BOOL)isNotifying descriptors:(nullable NSArray<CBDescriptor*>*)descriptors;

@end

NS_ASSUME_NONNULL_END
