//
//  SOSBarcodeInformation.h
//  Barcodes
//
//  Created by Sam Symons on 1/14/2014.
//  Copyright (c) 2014 Sam Symons. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSBarcodeInformation : NSObject

@property (nonatomic, copy) NSString *itemName;
@property (nonatomic, copy) NSString *itemDescription;
@property (nonatomic, copy) NSString *barcodeNumber;
@property (nonatomic, copy) NSString *price;

- (instancetype)initWithJSON:(NSDictionary *)JSON;

/**
 Some items only have a title, while others only have a description.
 This method will always return information about the item.
 */
- (NSString *)itemInformation;

@end
