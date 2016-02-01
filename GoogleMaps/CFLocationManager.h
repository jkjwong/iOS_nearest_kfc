//
//  CFLocationManager.h
//  Places
//
//  Created by Jon Wong on 03/07/2015.
//  Copyright (c) 2015 Jon Wong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol GFLocationManagerDelegate

- (void)locationManagerDidUpdateLocation:(CLLocation *)location;

@end

@interface GFLocationManager : NSObject<CLLocationManagerDelegate>

+ (GFLocationManager *)sharedInstance;
- (void) addLocationManagerDelegate:(id<GFLocationManagerDelegate>) delegate;
- (void) removeLocationManagerDelegate:(id<GFLocationManagerDelegate>) delegate;

@end
