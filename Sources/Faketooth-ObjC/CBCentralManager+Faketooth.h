//
//  CBCentralManager+Faketooth.h
//  Faketooth
//
//  Created by Max Rozdobudko on 6/15/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "FaketoothPeripheral.h"

NS_ASSUME_NONNULL_BEGIN

@interface CBCentralManager (Faketooth)

@property (class, nullable, nonatomic) NSArray<FaketoothPeripheral*>* simulatedPeripherals;

@property (class, readonly) BOOL isSimulated;

@end

NS_ASSUME_NONNULL_END
