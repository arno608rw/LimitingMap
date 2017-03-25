//
//  ViewController.m
//  LimitingMap
//
//  Created by Vladimir Kolbas on 18/01/14.
//  Copyright (c) 2014 Vladimir Kolbas. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface ViewController () <GMSMapViewDelegate> {
    CLLocationCoordinate2D center, topLeft, topRight, bottomLeft, bottomRight;
    double leftLong, rightLong, bottomLat, topLat;
    GMSMarker *currentPosition;
}

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // GMSMapview itself is wired in storyboard, just set delegate
    self.mapView.delegate = self;
    
    // Lat/long limits (bounding box)
    leftLong = 15.0;
    rightLong = 16.0;
    bottomLat  = 45.0;
    topLat  = 46.0;
    
    // center coordinate for map view and set it to mapview
    center = CLLocationCoordinate2DMake(45.895064, 15.858220);
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:center.latitude
                                                                    longitude:center.longitude
                                                                         zoom:10];
    self.mapView.camera = cameraPosition;

    // Current position, for displaying marker
    currentPosition = [GMSMarker markerWithPosition:center];
    currentPosition.map = self.mapView;

    // coordinates based on upper limits for bounding box for polyline
    topLeft     = CLLocationCoordinate2DMake(topLat, leftLong);
    topRight    = CLLocationCoordinate2DMake(topLat, rightLong);
    bottomLeft  = CLLocationCoordinate2DMake(bottomLat, leftLong);
    bottomRight = CLLocationCoordinate2DMake(bottomLat, rightLong);
    

    // Create visual bounding box with fat polyline
    GMSMutablePath *path = [[GMSMutablePath alloc] init];
    [path addCoordinate:topLeft];
    [path addCoordinate:topRight];
    [path addCoordinate:bottomRight];
    [path addCoordinate:bottomLeft];
    [path addCoordinate:topLeft];
    
    GMSPolyline *polyLine = [GMSPolyline polylineWithPath:path];
    polyLine.strokeWidth = 10.0;
    polyLine.map = self.mapView;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Google Maps iOS SDK delegate methods

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {

    
    // Reposition GMSMarker introduced in viewDidLoad to updated position
    currentPosition.position = position.target;

    // The interedting part - a non-elegant way to detect which limit was passed
    // If each of lat/long limits is passed, map will move or animate to limiting position
    
    if (position.target.latitude > topLat) { // If you scroll past upper latitude
        // Create new campera position AT upper latitude and current longitude (and zoom)
        GMSCameraPosition *goBackCamera = [GMSCameraPosition cameraWithLatitude:topLat
                                                                      longitude:position.target.longitude
                                                                           zoom:position.zoom];
        // Now, you can go back without animation,
        //self.mapView.camera = goBackCamera;

        // or with animation, as you see fit.
        [self.mapView animateToCameraPosition:goBackCamera];
    }
    
    if (position.target.latitude < bottomLat) {
        GMSCameraPosition *goBackCamera = [GMSCameraPosition cameraWithLatitude:bottomLat
                                                                      longitude:position.target.longitude
                                                                           zoom:position.zoom];
        //self.mapView.camera = goBackCamera;
        [self.mapView animateToCameraPosition:goBackCamera];
    }
    
    if (position.target.longitude > rightLong) {
        GMSCameraPosition *goBackCamera = [GMSCameraPosition cameraWithLatitude:position.target.latitude
                                                                      longitude:rightLong
                                                                           zoom:position.zoom];
        //self.mapView.camera = goBackCamera;
        [self.mapView animateToCameraPosition:goBackCamera];
    }
    
    if (position.target.longitude < leftLong) {
        GMSCameraPosition *goBackCamera = [GMSCameraPosition cameraWithLatitude:position.target.latitude
                                                                      longitude:leftLong
                                                                           zoom:position.zoom];
        //self.mapView.camera = goBackCamera;
        [self.mapView animateToCameraPosition:goBackCamera];
    }
    
    
}

@end
