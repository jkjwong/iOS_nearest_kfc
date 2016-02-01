//
//  ViewController.h
//  GoogleMaps
//
//  Created by Jon Wong on 29/07/2015.
//  Copyright (c) 2015 Jon Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CFLocationManager.h"
#import <GoogleMaps/GoogleMaps.h>

@interface ViewController : UIViewController <GFLocationManagerDelegate, GMSMapViewDelegate>
{
    CLLocation * currentLocation;
    CLLocationManager * locationManager;
}

@end

