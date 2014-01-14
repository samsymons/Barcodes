//
//  SOSBarcodeInformationRequest.h
//  Barcodes
//
//  Created by Sam Symons on 1/14/2014.
//  Copyright (c) 2014 Sam Symons. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SOSBarcodeInformation;

typedef void(^SOSInformationCompletionBlock)(SOSBarcodeInformation *information, NSError *error);

@interface SOSBarcodeInformationRequest : NSObject

/**
 Gets information for a barcode with a given UPC.
 
 @param code The UPC to look up.
 @param completion The optional completion handler.
 */
+ (NSURLSessionDataTask *)informationForUPC:(NSString *)code completion:(SOSInformationCompletionBlock)completion;

@end
