//
//  FakeService.h
//  Faketooth
//
//  Created by Max Rozdobudko on 6/17/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface FaketoothService : CBService

- (void)setPeripheral:(CBPeripheral*)peripheral;

- (instancetype)init;
- (instancetype)initWithUUID:(CBUUID*)uuid characteristics:(NSArray<CBCharacteristic*>*)characteristics;
- (instancetype)initWithUUID:(CBUUID*)uuid characteristics:(NSArray<CBCharacteristic*>*)characteristics includedServices:(nullable NSArray<CBService*>*) includedServices;

@end

NS_ASSUME_NONNULL_END
