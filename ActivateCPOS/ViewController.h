//
//  ViewController.h
//  ActivateCPOS
//
//  Created by baowei on 14-1-19.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UITableViewController{
    long _currentTime;  // unit: ms
    int _clickCount;
}

@property (weak, nonatomic) IBOutlet UITextField *textStationId;
@property (weak, nonatomic) IBOutlet UITextField *textCode1;
@property (weak, nonatomic) IBOutlet UITextField *textCode2;
@property (weak, nonatomic) IBOutlet UITextField *textCode3;
@property (weak, nonatomic) IBOutlet UITextField *textCode4;
@property (weak, nonatomic) IBOutlet UITextField *textActivationCode;
@property (weak, nonatomic) IBOutlet UIButton *buttonActivate;

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

- (IBAction)textStationIdChanged:(UITextField *)sender;

- (IBAction)textCode1Changed:(UITextField *)sender;
- (IBAction)textCode2Changed:(UITextField *)sender;
- (IBAction)textCode3Changed:(UITextField *)sender;

- (IBAction)activationClick:(UIButton *)sender;

- (BOOL) connectedToNetwork;
- (void) callActivationService:(NSString*)stationId installCode:(NSString*)installCode;

- (NSString*) getPatternString:(NSString*) pattern dealString:(NSString*) str;

- (void) msbox:(NSString*) title info:(NSString*)str;
- (void) msbox:(NSString*) str;

- (void) dismissKeyboard;

@end
