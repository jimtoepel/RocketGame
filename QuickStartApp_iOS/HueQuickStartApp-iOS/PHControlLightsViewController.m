/*******************************************************************************
 Copyright (c) 2013 Koninklijke Philips N.V.
 All Rights Reserved.
 ********************************************************************************/

#import "PHControlLightsViewController.h"
#import "PHAppDelegate.h"
#import <AVFoundation/AVFoundation.h>

#import <HueSDK_iOS/HueSDK.h>
#define MAX_HUE 65535

@interface PHControlLightsViewController()

@property (nonatomic,weak) IBOutlet UILabel *bridgeIdLabel;
@property (nonatomic,weak) IBOutlet UILabel *bridgeIpLabel;
@property (nonatomic,weak) IBOutlet UILabel *bridgeLastHeartbeatLabel;
@property (nonatomic,weak) IBOutlet UIButton *randomLightsButton;
@property (weak, nonatomic) IBOutlet UIButton *LaunchLightsButton;
@property (weak, nonatomic) IBOutlet UIButton *LandingLightsButton;
@property (weak, nonatomic) IBOutlet UIButton *OpenWindowButton;
@property (weak, nonatomic) IBOutlet UIButton *CloseWindowButton;
@property (weak, nonatomic) IBOutlet UIButton *EmergencyButton;
@property (weak, nonatomic) IBOutlet UIButton *RepairButton;



@end


@implementation PHControlLightsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    // Register for the local heartbeat notifications
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Find bridge" style:UIBarButtonItemStylePlain target:self action:@selector(findNewBridgeButtonAction)];
    
    self.navigationItem.title = @"QuickStart";
    [self noLocalConnection];
    

    
}

- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)localConnection{
    
    [self loadConnectedBridgeValues];
    
}

- (void)noLocalConnection{
    self.bridgeLastHeartbeatLabel.text = @"Not connected";
    [self.bridgeLastHeartbeatLabel setEnabled:NO];
    self.bridgeIpLabel.text = @"Not connected";
    [self.bridgeIpLabel setEnabled:NO];
    self.bridgeIdLabel.text = @"Not connected";
    [self.bridgeIdLabel setEnabled:NO];
    
    [self.randomLightsButton setEnabled:NO];
}

- (void)loadConnectedBridgeValues{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    // Check if we have connected to a bridge before
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil){
        
        // Set the ip address of the bridge
        self.bridgeIpLabel.text = cache.bridgeConfiguration.ipaddress;
        
        // Set the identifier of the bridge
        self.bridgeIdLabel.text = cache.bridgeConfiguration.bridgeId;
        
        // Check if we are connected to the bridge right now
        if (UIAppDelegate.phHueSDK.localConnected) {
            
            // Show current time as last successful heartbeat time when we are connected to a bridge
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterNoStyle];
            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
            
            self.bridgeLastHeartbeatLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
            
            [self.randomLightsButton setEnabled:YES];
        } else {
            self.bridgeLastHeartbeatLabel.text = @"Waiting...";
            [self.randomLightsButton setEnabled:NO];
        }
    }
}

- (IBAction)selectOtherBridge:(id)sender{
    [UIAppDelegate searchForBridgeLocal];
}



- (void)findNewBridgeButtonAction{
    [UIAppDelegate searchForBridgeLocal];
}


- (IBAction)randomizeColoursOfConnectLights:(id)sender{
    [self.randomLightsButton setEnabled:NO];
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        
        PHLightState *lightState = [[PHLightState alloc] init];
        
        [lightState setHue:[NSNumber numberWithInt:arc4random() % MAX_HUE]];
        [lightState setBrightness:[NSNumber numberWithInt:254]];
        [lightState setSaturation:[NSNumber numberWithInt:254]];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            
            [self.randomLightsButton setEnabled:YES];
        }];
    }
}



- (void)launchColoursOfConnectLights{
    [self.LaunchLightsButton setEnabled:NO];

    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        
        PHLightState *lightState = [[PHLightState alloc] init];
        
        [lightState setHue:[NSNumber numberWithInt:(arc4random() % 10000)]];
        [lightState setBrightness:[NSNumber numberWithInt:(arc4random() % 254)]];
        [lightState setSaturation:[NSNumber numberWithInt:254]];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            
            [self.LaunchLightsButton setEnabled:YES];
        }];
    }
}


- (void)landingColoursOfConnectLights{
    [self.LandingLightsButton setEnabled:NO];

    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        
        PHLightState *lightState = [[PHLightState alloc] init];
        
        [lightState setHue:[NSNumber numberWithInt:(arc4random() % 1000 + 50000)]];
        [lightState setBrightness:[NSNumber numberWithInt:254]];
        [lightState setSaturation:[NSNumber numberWithInt:254]];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            
            [self.LandingLightsButton setEnabled:YES];
        }];
    }
}

- (void)openWindowsColoursOfConnectLights{
    [self.OpenWindowButton setEnabled:NO];
    
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        
        PHLightState *lightState = [[PHLightState alloc] init];
        
        [lightState setHue:[NSNumber numberWithInt:(arc4random() % 1000 + 37000)]];
        [lightState setBrightness:[NSNumber numberWithInt:(arc4random() % 50 + 200)]];
        [lightState setSaturation:[NSNumber numberWithInt:254]];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            
            [self.OpenWindowButton setEnabled:YES];
        }];
    }
}

- (void)closeWindowsColoursOfConnectLights{
    [self.CloseWindowButton setEnabled:NO];
    
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        
        PHLightState *lightState = [[PHLightState alloc] init];
        
        [lightState setHue:[NSNumber numberWithInt:1]];
        [lightState setBrightness:[NSNumber numberWithInt:1]];
        [lightState setSaturation:[NSNumber numberWithInt:1]];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            
            [self.CloseWindowButton setEnabled:YES];
        }];
    }
}

- (void)emergencyColoursOfConnectLights{
    [self.EmergencyButton setEnabled:NO];
    
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        
        PHLightState *lightState = [[PHLightState alloc] init];
        
        [lightState setHue:[NSNumber numberWithInt:(arc4random() % 1000)]];
        [lightState setBrightness:[NSNumber numberWithInt:arc4random() % 254]];
        [lightState setSaturation:[NSNumber numberWithInt:254]];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            
            [self.EmergencyButton setEnabled:YES];
        }];
    }
}


- (void)repairColoursOfConnectLights{
    [self.RepairButton setEnabled:NO];
    
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        
        PHLightState *lightState = [[PHLightState alloc] init];
        
        [lightState setHue:[NSNumber numberWithInt:12500]];
        [lightState setBrightness:[NSNumber numberWithInt:arc4random() % 254]];
        [lightState setSaturation:[NSNumber numberWithInt:254]];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            
            [self.RepairButton setEnabled:YES];
        }];
    }
}


-(IBAction)launchButtonPressed:(id)sender {
    
    NSLog(@"5, 4, 3, 2, 1, Liftoff!");
    
    for (int i = 1; i <= 30; i++)
    {
        NSLog(@"%d", i);
    
        NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                            target: self
                                                          selector: @selector(launchRocket:)
                                                          userInfo: nil
                                                           repeats: NO];
    }
}





-(IBAction)landingButtonPressed:(id)sender {
    NSLog(@"%d is MaxHue", MAX_HUE);
    NSLog(@"Incoming landing...");
    for (int i = 1; i <= 30; i++)
    {
        NSLog(@"%d", i);
        
        NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                            target: self
                                                          selector: @selector(landRocket:)
                                                          userInfo: nil
                                                           repeats: NO];
    }

}

-(IBAction)openWindowsButtonPressed:(id)sender {
    
    NSLog(@"Obervation Window Open");
    for (int i = 1; i <= 30; i++)
    {
        NSLog(@"%d", i);
        
        NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0
                                                            target: self
                                                          selector: @selector(openWindow:)
                                                          userInfo: nil
                                                           repeats: NO];
    }
}


-(IBAction)closeWindowsButtonPressed:(id)sender {
    
    NSLog(@"Closing Observation Window");
    [self closeWindowsColoursOfConnectLights];
}

-(IBAction)emergencyButtonPressed:(id)sender {
    
    NSLog(@"Emergency, Emergency, Emergency!");
    for (int i = 1; i <= 30; i++)
    {
        NSLog(@"%d", i);
        
        NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                            target: self
                                                          selector: @selector(emergencyRocket:)
                                                          userInfo: nil
                                                           repeats: NO];
    }
    
}

-(IBAction)repairButtonPressed:(id)sender {
    
    NSLog(@"Repair Button Pressed:");
    for (int i = 1; i <= 30; i++)
    {
        NSLog(@"%d", i);
        
        NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 2.0
                                                            target: self
                                                          selector: @selector(repairRocket:)
                                                          userInfo: nil
                                                           repeats: NO];
    }
}



-(void)launchRocket:(NSTimer *)myTimer {
    [self launchColoursOfConnectLights];

}

-(void)landRocket:(NSTimer *)myTimer {
    [self landingColoursOfConnectLights];
}

-(void)emergencyRocket:(NSTimer *)myTimer {
    [self emergencyColoursOfConnectLights];
}


-(void)repairRocket:(NSTimer *)myTimer {
    [self repairColoursOfConnectLights];
}

-(void)openWindow:(NSTimer *)myTimer {
    [self openWindowsColoursOfConnectLights];
}

@end


/*
 NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"RocketCountdown"
 ofType:@"mp3"];
 NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
 AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL
 error:nil];
 player.numberOfLoops = 0;
 [player play];
 */