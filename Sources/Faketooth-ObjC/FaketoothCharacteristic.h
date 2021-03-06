//
//  FakeCharacteristic.h
//  Faketooth
//
//  Created by Max Rozdobudko on 6/17/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSData* _Nullable (^FaketoothCharacteristicValueProducer)(void);
typedef void (^FaketoothCharacteristicValueHandler)(NSData* _Nullable);

@interface FaketoothCharacteristic : CBCharacteristic

- (void)setService:(CBService*)service;
- (void)setValue:(nullable NSData*)value;

- (instancetype)init;
- (instancetype)initWithUUID:(CBUUID*)uuid properties:(CBCharacteristicProperties)properties valueProducer:(nullable FaketoothCharacteristicValueProducer)valueProducer valueHandler:(nullable FaketoothCharacteristicValueHandler)valueHandler;
- (instancetype)initWithUUID:(CBUUID*)uuid properties:(CBCharacteristicProperties)properties descriptors:(nullable NSArray<CBDescriptor*>*)descriptors valueProducer:(nullable FaketoothCharacteristicValueProducer)valueProducer valueHandler:(nullable FaketoothCharacteristicValueHandler)valueHandler;

- (void)setIsNotifying:(BOOL)value;

@end

NS_ASSUME_NONNULL_END
