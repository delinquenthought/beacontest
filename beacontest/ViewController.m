//
//  ViewController.m
//  beacontest
//
//  Created by Eric Spencer on 10/6/13.
//  Copyright (c) 2013 Eric Spencer. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()

@property (nonatomic, retain) CLBeaconRegion *beaconRegion;
@property (nonatomic, retain) CBPeripheralManager *manager;
@property (nonatomic, retain) CLLocationManager *locationManager;

@end

@implementation ViewController

CBPeripheralManager* peripheralManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    /* Initialization */
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"2D341E70-A4F8-47BE-9D61-1B282356ECD0"];
    NSString *identifier = @"com.beacontest.MyBeacon";
    //Construct the region
    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:identifier];
    [_activityIndicator stopAnimating];
    _statusLabel.hidden = true;
}

- (IBAction)hitbutton:(id)sender {

    //Start broadcasting the beacon
    _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    

}


- (IBAction)locateBeacon:(id)sender {
    
    //Start monitoring
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    [_locationManager startMonitoringForRegion:self.beaconRegion];
    
    [_activityIndicator startAnimating];
    
    _statusLabel.text = @"Started looking for beacon.";
    _statusLabel.hidden = false;
    
    //force the region to change
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
}

//forcing region change
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}


#pragma mark - CBPeripheralManagerDelegate Methods

//CBPeripheralManager callback once the manager is ready to accept commands
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        _statusLabel.text = @"Bluetooth not powered on.";
        _statusLabel.hidden = false;
        return;
    }
    
    //Passing nil will use the device default power
    NSDictionary *payload = [_beaconRegion peripheralDataWithMeasuredPower:nil];
    
    //Start advertising
    [_manager startAdvertising:payload];
    
    [_activityIndicator startAnimating];
    _statusLabel.text = @"Broadcasting beacon";
    _statusLabel.hidden = false;
}

#pragma mark - CLLocationManagerDelegate Methods

//Callback when the iBeacon is in range
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        _statusLabel.text = @"Beacon is in range.";
        _statusLabel.hidden = false;
        [manager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

//Callback when the iBeacon has left range
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        _statusLabel.text = @"Beacon exited range.";
        _statusLabel.hidden = false;
        [manager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

//Callback when ranging is successful
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    //Check if we have moved closer or farther away from the iBeacon…
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons lastObject];
    
    switch (beacon.proximity) {
        case CLProximityImmediate:
            _statusLabel.text = @"Immediate!";
            break;
        case CLProximityNear:
            _statusLabel.text = @"Near!";
            break;
        case CLProximityFar:
            _statusLabel.text = @"Far!";
            break;
        case CLProximityUnknown:
            _statusLabel.text = @"Can't see anything yet!";
            break;
        default:
            _statusLabel.text = @"It's around here somewhere!";
            break;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

