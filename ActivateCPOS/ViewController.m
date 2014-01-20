//
//  ViewController.m
//  ActivateCPOS
//
//  Created by baowei on 14-1-19.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "ViewController.h"

#define NUMBERS_ONLY @"1234567890"
#define CHARACTER_LIMIT8 8
#define CHARACTER_LIMIT5 5

#define MaxClickCount 3

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _textStationId.delegate = (id)self;
    _textCode1.delegate = (id)self;
    _textCode2.delegate = (id)self;
    _textCode3.delegate = (id)self;
    _textCode4.delegate = (id)self;
    
    //The setup code (in viewDidLoad in your view controller)
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS_ONLY] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];

    int limit = textField == _textStationId ? CHARACTER_LIMIT8 : CHARACTER_LIMIT5;
    return (([string isEqualToString:filtered])&&(newLength <= limit));
}

- (IBAction)textStationIdChanged:(UITextField *)sender {
    if ([_textStationId.text length] == CHARACTER_LIMIT8) {
        [_textCode1 becomeFirstResponder];
    }
}

- (IBAction)textCode1Changed:(UITextField *)sender {
    if ([_textCode1.text length] == CHARACTER_LIMIT5) {
        [_textCode2 becomeFirstResponder];
    }
}

- (IBAction)textCode2Changed:(UITextField *)sender {
    if ([_textCode2.text length] == CHARACTER_LIMIT5) {
        [_textCode3 becomeFirstResponder];
    }
}

- (IBAction)textCode3Changed:(UITextField *)sender {
    if ([_textCode3.text length] == CHARACTER_LIMIT5) {
        [_textCode4 becomeFirstResponder];
    }
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    long time = [[NSDate date] timeIntervalSince1970];
    if(_currentTime == 0 || time - _currentTime < 1000){
        _clickCount++;
    }
    else{
        _clickCount = 0;
    }
    _currentTime = time;
    
    if(_clickCount > MaxClickCount){
        _clickCount = 0;
        _currentTime = 0;
    }
}

- (IBAction)activationClick:(UIButton *)sender {
    Boolean ignoreStationId = _clickCount >= MaxClickCount;
    _clickCount = 0;
    _currentTime = 0;
    if (ignoreStationId) {
    }
    
//    NSURL *url = [NSURL URLWithString:@"http://northloong.com:8733/ActivateService.asmx"];
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//    [request setRequestMethod:@"POST"];
//    [request addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
//    [request addRequestHeader:@"SOAPAction" value:@"http://tempuri.org/HelloWorld"];
//    
//    
//    NSString *soapMessage = [NSString stringWithFormat:
//                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
//                             
//                             "<soap:Envelope
//                                                 xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
//                                                 xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"
//                                                 xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
//                             "<soap:Body>"
//                             "<Greet xmlns=\"http://tempuri.org/\">"
//                             "<deviceToken>some device token</deviceToken>"
//                             "<userName>azamsharp</userName>"
//                             "</Greet>"
//                             "</soap:Body>"
//                             "</soap:Envelope>"];
//    
//    NSString *messageLength = [NSString stringWithFormat:@"%d",[soapMessage length]];
//    
//    [request addRequestHeader:@"Content-Length" value:messageLength];
//    
//    [request appendPostData:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [request setDelegate:self]; 
//    [request startAsynchronous];
   
}

@end
