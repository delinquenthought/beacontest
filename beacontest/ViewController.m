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

@end

@implementation ViewController

CBPeripheralManager* peripheralManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)hitbutton:(id)sender {
    
    
    NSUUID *proximityUUID = [[NSUUID alloc]
                             initWithUUIDString:@"1CB7CA53-5A56-4555-BA0E-788CB984BF33"];
    
    // Create the beacon region.
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc]
                                    initWithProximityUUID:proximityUUID
                                    identifier:@"com.getsignedin.home"];
    
    // Create a dictionary of advertisement data.
    NSDictionary *beaconPeripheralData =
    [beaconRegion peripheralDataWithMeasuredPower:nil];
    
    // Create the peripheral manager.
    peripheralManager = [[CBPeripheralManager alloc]
                                              initWithDelegate:self queue:nil];
    
    
    if (peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        // Start advertising your beacon's data.
        [peripheralManager startAdvertising:beaconPeripheralData];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iBeacon is running"
                                                        message:@"Your device is broadcasting an iBeacon"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iBeacon is not running"
                                                        message:@"Your device can not broadcast an iBeacon.  Check that bluetooth is powered on"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

