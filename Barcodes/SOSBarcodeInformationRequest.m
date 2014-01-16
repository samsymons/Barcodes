//
//  SOSBarcodeInformationRequest.m
//  Barcodes
//
//  Created by Sam Symons on 1/14/2014.
//  Copyright (c) 2014 Sam Symons. All rights reserved.
//
//  The scanner uses http://upcdatabase.org/api for looking up products.

#error You need to provide your API key
NSString * const kUPCDatabaseAPIKey = @"";
NSString * const kUPCDatabaseAPIEndpoint = @"http://www.upcdatabase.org/api/json";

#import "SOSBarcodeInformationRequest.h"
#import "SOSBarcodeInformation.h"

@interface SOSBarcodeInformationRequest ()

+ (NSURLRequest *)requestWithCode:(NSString *)code;

@end

@implementation SOSBarcodeInformationRequest

+ (NSURLSessionDataTask *)informationForUPC:(NSString *)code completion:(SOSInformationCompletionBlock)completion
{
    NSParameterAssert(code);
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [SOSBarcodeInformationRequest requestWithCode:code];
    
    NSURLSessionDataTask *informationDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!completion)
        {
            return;
        }
        
        NSError *parsingError = nil;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parsingError];
        
        if (parsingError)
        {
            completion(nil, parsingError);
            return;
        }
        
        if ([[responseData valueForKey:@"valid"] boolValue])
        {
            SOSBarcodeInformation *barcodeInformation = [[SOSBarcodeInformation alloc] initWithJSON:responseData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(barcodeInformation, nil);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, [NSError errorWithDomain:kSOSErrorDomain code:kBarcodeInvalidError userInfo:nil]);
            });
        }
        
    }];
    
    [informationDataTask resume];
    
    return informationDataTask;
}

#pragma mark - Private

+ (NSURLRequest *)requestWithCode:(NSString *)code
{
    NSParameterAssert(code);
    
    NSString *URLString = [NSString stringWithFormat:@"%@/%@/%@", kUPCDatabaseAPIEndpoint, kUPCDatabaseAPIKey, code];
    NSURL *URL = [NSURL URLWithString:URLString];
    
    return [NSURLRequest requestWithURL:URL];
}

@end
