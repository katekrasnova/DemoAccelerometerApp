//
//  ViewController.m
//  AccelerometerDemo
//
//  Created by Ekaterina Krasnova on 29.04.16.
//  Copyright © 2016 Ekaterina Krasnova. All rights reserved.
//

@import CoreMotion;
#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *staticLabel;
@property (weak, nonatomic) IBOutlet UILabel *dynamicLabel;
@property (weak, nonatomic) IBOutlet UIButton *staticButton;
@property (weak, nonatomic) IBOutlet UIButton *dynamicStartButton;
@property (weak, nonatomic) IBOutlet UIButton *dynamicStopButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (assign, nonatomic) double x,y,z;

@property (strong, nonatomic) CMMotionManager *manager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.staticLabel.text = @"No Data";
    self.dynamicLabel.text = @"No Data";
    self.staticButton.enabled = NO;
    self.dynamicStartButton.enabled = NO;
    self.dynamicStopButton.enabled = NO;
    
    self.x = 0.0;
    self.y = 0.0;
    self.z = 0.0;
    
    self.imageView.image = [UIImage imageNamed:@"IMG_0580.JPG"];
    
    self.manager = [[CMMotionManager alloc]init];
    if (self.manager.accelerometerAvailable) {
        self.staticButton.enabled = YES;
        self.dynamicStartButton.enabled = YES;
        [self.manager startAccelerometerUpdates];
    }
    else {
        self.staticLabel.text = @"No Acceloromrter Available";
        self.dynamicLabel.text = @"No Acceloromrter Available";
    }
}

- (IBAction)staticRequest:(id)sender {
    CMAccelerometerData *aDate = self.manager.accelerometerData;
    if (aDate != nil) {
        CMAcceleration acceleration = aDate.acceleration;
        self.staticLabel.text = [NSString stringWithFormat:@"x: %f\ny: %f\n z: %f", acceleration.x, acceleration.y, acceleration.z];
    }
}

- (IBAction)dynamicStart:(id)sender {
    self.dynamicStartButton.enabled = NO;
    self.dynamicStopButton.enabled = YES;
    
    self.manager.accelerometerUpdateInterval = 0.01;
    
    ViewController * __weak weakSelf = self;
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [self.manager startAccelerometerUpdatesToQueue:queue withHandler: ^(CMAccelerometerData *data, NSError *error){
        double x = data.acceleration.x;
        double y = data.acceleration.y;
        double z = data.acceleration.z;
        
        self.x = .9 * self.x + .1 * x;
        self.y = .9 * self.y + .1 * y;
        self.z = .9 * self.z + .1 * z;
        
        double rotation = -atan2(self.x, -self.y);

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            weakSelf.imageView.transform = CGAffineTransformMakeRotation(rotation);
            weakSelf.dynamicLabel.text = [NSString stringWithFormat:@"x: %f\ny: %f\n z: %f", x, y, z];
        }];
    }];
}

- (IBAction)dynamicStop:(id)sender {
    [self.manager stopAccelerometerUpdates];
    self.dynamicStartButton.enabled = YES;
    self.dynamicStopButton.enabled = NO;
}


@end
