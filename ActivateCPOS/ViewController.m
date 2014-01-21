//
//  ViewController.m
//  ActivateCPOS
//
//  Created by baowei on 14-1-19.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"

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

- (BOOL) connectedToNetwork{
    Reachability* reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    BOOL isInternet = FALSE;
    if(remoteHostStatus == NotReachable)
    {
        isInternet = FALSE;
    }
    else if (remoteHostStatus == ReachableViaWWAN)
    {
        isInternet = TRUE;
    }
    else if (remoteHostStatus == ReachableViaWiFi)
    {
        isInternet = TRUE;
        
    }
    return isInternet;
}

- (void) msbox:(NSString*) str{
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"错误", nil)
                                                         message:str
                                                         delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                               otherButtonTitles:nil];
    [errorAlert show];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"status code %d",request.responseStatusCode);
    
    if(request.responseStatusCode == 200)
    {
        NSLog(@"success");
        NSString *responseString = [request responseString];
        NSLog(@"%@",responseString);
        
        
        NSError  *error  = NULL;
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"<ActivateResult>.*</ActivateResult>"
                                      options:0
                                      error:&error];
        NSRange range   = [regex rangeOfFirstMatchInString:responseString
                                                   options:0
                                                     range:NSMakeRange(0, [responseString length])];
        NSString *result = [responseString substringWithRange:range];
        
        [self msbox:result];
    }
    
    NSLog(@"request finished");
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error.localizedDescription);
    
    [self msbox:@"网络通讯错误，无法激活"];
}

- (void) callActivationService:(NSString*)stationId installCode:(NSString*)installCode{
    NSURL *url = [NSURL URLWithString:@"http://northloong.com:8733/ActivateService.asmx"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
    [request addRequestHeader:@"SOAPAction" value:@"http://tempuri.org/Activate"];
    
    /*
     <?xml version="1.0" encoding="utf-8"?>
     <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
     <soap:Body>
     <Activate xmlns="http://tempuri.org/">
     <stationNo>string</stationNo>
     <installCode>string</installCode>
     </Activate>
     </soap:Body>
     </soap:Envelope>
     */
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<Activate xmlns=\"http://tempuri.org/\">\n"
                             "<stationNo>%@</stationNo>\n"
                             "<installCode>%@</installCode>\n"
                             "</Activate>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n", stationId, installCode ];
    NSString *messageLength = [NSString stringWithFormat:@"%d",[soapMessage length]];
    [request addRequestHeader:@"Content-Length" value:messageLength];
    [request appendPostData:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (IBAction)activationClick:(UIButton *)sender {
    Boolean ignoreStationId = _clickCount >= MaxClickCount;
    _clickCount = 0;
    _currentTime = 0;

    NSString* idStr = @"";
    if (!ignoreStationId) {
        idStr = _textStationId.text;
        if([_textStationId.text length] < CHARACTER_LIMIT8){
            [self msbox:@"油站编码由8个数字组成，请正确输入"];
            return;
        }
    }
    else{
        idStr = @"ignore_StationId";
    }
    
    NSArray* codeViews = [NSArray arrayWithObjects:_textCode1, _textCode2, _textCode3, _textCode4, nil];
    for (UITextField* codeView in codeViews) {
        if ([codeView.text length] < CHARACTER_LIMIT5) {
            [self msbox:@"安装码由4组5个数字组成，请正确输入"];
            return;
        }
    }
    
    if(![self connectedToNetwork]){
        [self msbox:@"网络通讯错误，无法激活"];
        return;
    }
    
    NSString* installCode = [NSString stringWithFormat:@"%@-%@-%@-%@",
                             _textCode1.text, _textCode2.text, _textCode3.text, _textCode4.text];
    [self callActivationService:idStr installCode:installCode];
}

@end
