//
//  ViewController.m
//  demoCarrier
//
//  Created by Axel Kee on 15/11/2016.
//  Copyright © 2016 Sweatshop. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"
#import<CoreTelephony/CTCallCenter.h>
#import<CoreTelephony/CTCall.h>
#import<CoreTelephony/CTCarrier.h>
#import<CoreTelephony/CTTelephonyNetworkInfo.h>
#import <ifaddrs.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)checkCarrierTapped:(id)sender {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    
    UIAlertController *noInternetAlert = [UIAlertController alertControllerWithTitle:@"Notice" message:@"No internet connection, please enable mobile data" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertController *wifiAlert = [UIAlertController alertControllerWithTitle:@"Notice" message:@"Please turn off wifi and use mobile data" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertController *noCellularCapabilityAlert = [UIAlertController alertControllerWithTitle:@"Notice" message:@"This device has no cellular capabilities" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             //Do some thing here
                             [noInternetAlert dismissViewControllerAnimated:YES completion:nil];
                             [wifiAlert dismissViewControllerAnimated:YES completion:nil];
                             [noCellularCapabilityAlert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [noInternetAlert addAction:ok];
    [wifiAlert addAction:ok];
    [noCellularCapabilityAlert addAction:ok];
    
    if(![self hasCellularCapabilities]){
        NSLog(@"No cellular capabilities");
        [self presentViewController:noCellularCapabilityAlert animated:YES completion:nil];
    }
    else if(status == NotReachable)
    {
        //No internet
        NSLog(@"No internet connection");
        [self presentViewController:noInternetAlert animated:YES completion:nil];
    }
    else if (status == ReachableViaWiFi)
    {
        //WiFi
        NSLog(@"Please turn off wifi and use mobile data");
        [self presentViewController:wifiAlert animated:YES completion:nil];
    }
    else if (status == ReachableViaWWAN)
    {
        //3G
        CTTelephonyNetworkInfo *myNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *myCarrier = [myNetworkInfo subscriberCellularProvider];
        
        NSLog(@"Carrier carrierName is %@", myCarrier.carrierName);
        NSLog(@"Carrier isoCountryCode is %@", myCarrier.isoCountryCode);
        NSLog(@"Carrier mobileCountryCode is %@", myCarrier.mobileCountryCode);
        NSLog(@"Carrier mobileNetworkCode is %@", myCarrier.mobileNetworkCode);
        
        self.carrierNameLabel.text = myCarrier.carrierName;
        self.isoCountryCodeLabel.text = myCarrier.isoCountryCode;
        self.mobileCountryCodeLabel.text = myCarrier.mobileCountryCode;
        self.mobileNetworkCodeLabel.text = myCarrier.mobileNetworkCode;
    }
    
}

//http://stackoverflow.com/questions/7101206/know-if-ios-device-has-cellular-data-capabilities
- (BOOL) hasCellularCapabilities {
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    bool found = false;
    if (getifaddrs(&addrs) == 0) {
        cursor = addrs;
        while (cursor != NULL) {
            NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
            if ([name isEqualToString:@"pdp_ip0"]) {
                found = true;
                break;
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return found;
}

@end
