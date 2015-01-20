//
//  ViewController.m
//  FiscalBus
//
//  Created by Cleber Henriques on 14/01/15.
//  Copyright (c) 2015 Cleber Henriques. All rights reserved.
//

#import "FABViewController.h"
#import "FABModalAlertViewController.h"
#import "FABRegistro.h"

@interface FABViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *labelVelocity;
@property (weak, nonatomic) IBOutlet UILabel *labelInfo;
@property (strong, nonatomic) FABRegistro *registro;
@property (strong, nonatomic) CLLocation *lastLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnAuthorizationDenied;

@end

@implementation FABViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.registro = [[FABRegistro alloc] init];
    
    for (int i = 1; i <= 4; i++) {
        id item = [self.view viewWithTag:i];
        [item setOn:NO animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.btnAuthorizationDenied.hidden = YES;
        self.labelVelocity.hidden = NO;
        self.labelInfo.hidden = NO;
    }else{
        self.btnAuthorizationDenied.hidden = NO;
        self.labelVelocity.hidden = YES;
        self.labelInfo.hidden = YES;
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    double speed = location.speed * 3.6;
    
    self.labelVelocity.text = [NSString stringWithFormat:@"%.0f km/h", speed];
    
    self.lastLocation = location;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.btnAuthorizationDenied.hidden = YES;
        self.labelVelocity.hidden = NO;
        self.labelInfo.hidden = NO;
    }else{
        self.btnAuthorizationDenied.hidden = NO;
        self.labelVelocity.hidden = YES;
        self.labelInfo.hidden = YES;
    }
}
- (IBAction)buttonReportTouched:(id)sender
{
    if (self.registro.noBelt || self.registro.badSanitized || self.registro.broke || self.registro.crowded || self.registro.fast) {
        FABModalAlertViewController *modalController = [self.storyboard instantiateViewControllerWithIdentifier:@"ModalAlertViewController"];
        
        modalController.lastLocation = self.lastLocation;
        modalController.registro = self.registro;
        
        [self presentViewController:modalController animated:YES completion:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ops!"
                                                        message:@"Você deve denunciar pelo menos um item."
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (IBAction)btnAuthorizationDenied:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (IBAction)switchTouched:(UISwitch *)sender
{
    switch (sender.tag) {
        case 1:
            self.registro.noBelt = sender.isOn;
            break;
        case 2:
            self.registro.crowded = sender.isOn;
            break;
        case 3:
            self.registro.badSanitized = sender.isOn;
            break;
        case 4:
            self.registro.broke = sender.isOn;
            break;
        default:
            break;
    }
}


@end
