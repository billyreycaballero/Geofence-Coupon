//
//  ViewController.m
//  GeoFenceCoupon
//
//  Created by Billy Rey Caballero on 30/4/17.
//  Copyright © 2017 alcoderithm. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>


@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL mapIsMoving;
@property (strong, nonatomic) MKPointAnnotation *currentAnno;
@property (strong, nonatomic) MKPointAnnotation *myBiz;
@property (strong, nonatomic) CLCircularRegion *geoRegion;

-(void) requestPermissionToNotify;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    self.mapIsMoving = NO;
    
    self.myBiz = [[MKPointAnnotation alloc] init];
    self.myBiz.coordinate = CLLocationCoordinate2DMake(1.303076, 103.834791);
    self.myBiz.title = @"My Business";
    [self.mapView addAnnotations: @[self.myBiz]];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.pausesLocationUpdatesAutomatically = YES;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 3;
    
    self.mapView.showsUserLocation = YES;
    [self.locationManager startUpdatingLocation];
    
    CLLocationCoordinate2D noLocation;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    
    [self addCurrentAnnotation];
    [self setUpGeoRegion];
    
    if([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]] == YES) {
        CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
        if((currentStatus == kCLAuthorizationStatusAuthorizedWhenInUse) || (currentStatus == kCLAuthorizationStatusAuthorizedAlways)) {
        } else {
            [self.locationManager requestAlwaysAuthorization];
        }
        
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings: mySettings];
    }
    [self.locationManager startMonitoringForRegion:self.geoRegion];
}


-(void) requestPermissionToNotify {
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}




- (void) locationManager: (CLLocationManager *) manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    //CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
}


- (void) mapView:(MKMapView *) mapView regionWillChangeAnimated:(BOOL)animated {
    self.mapIsMoving = YES;
}

- (void) mapView: (MKMapView *) mapView regionDidChangeAnimated:(BOOL)animated {
    self.mapIsMoving = NO;
}

- (void) setUpGeoRegion {
    self.geoRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(1.303076, 103.834791) radius:3 identifier:@"MyRegionIdentifier"];
}


- (void) addCurrentAnnotation {
    self.currentAnno = [[MKPointAnnotation alloc] init];
    self.currentAnno.coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
    self.currentAnno.title = @"My Location";
}

- (void) centerMap: (MKPointAnnotation *) centerPoint {
    [self.mapView setCenterCoordinate:centerPoint.coordinate animated:YES];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.currentAnno.coordinate = locations.lastObject.coordinate;
    if(self.mapIsMoving == NO) {
        [self centerMap: self.currentAnno];
    }
}

- (void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
   
    [self.locationManager requestStateForRegion:self.geoRegion];
    
    if(state == CLRegionStateUnknown) {
        NSLog(@"Region: Unknown");
    } else if (state == CLRegionStateInside) {
        NSLog(@"Region: Inside");
        [self requestPermissionToNotify];
    } else if (state == CLRegionStateOutside) {
        NSLog(@"Region: Outside");
    } else {
        NSLog(@"Region: Mystery");
    }
}

 
- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(nonnull CLRegion *)region {
    
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.fireDate = nil;
    note.repeatInterval = 0;
    note.alertTitle = @"PROMOTION!";
    note.alertBody = [NSString stringWithFormat:@"You got 10 Percent OFF! CODE: 1234"];
    [[UIApplication sharedApplication] scheduleLocalNotification: note];
}

/*
- (void) locationManager:(CLLocationManager *)manager didExitRegion:(nonnull CLRegion *)region {
    
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.fireDate = nil;
    note.repeatInterval = 0;
    note.alertTitle = @"GeoFence Alert";
    note.alertBody = [NSString stringWithFormat:@"You left the geofence"];
    [[UIApplication sharedApplication] scheduleLocalNotification: note];
}
*/


@end
