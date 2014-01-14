//
//  SOSBarcodeInformation.m
//  Barcodes
//
//  Created by Sam Symons on 1/14/2014.
//  Copyright (c) 2014 Sam Symons. All rights reserved.
//

#import "SOSBarcodeInformation.h"

@implementation SOSBarcodeInformation

- (instancetype)initWithJSON:(NSDictionary *)JSON
{
    if (self = [super init])
    {
        _itemName = JSON[@"itemname"];
        _itemDescription = JSON[@"description"];
        _barcodeNumber = JSON[@"number"];
        _price = JSON[@"price"];
        
        /*
        _ratingsDown = [[JSON valueForKey:@"ratingsdown"] unsignedIntegerValue];
        _ratingsUp = [[JSON valueForKey:@"ratingsup"] unsignedIntegerValue];
        _valid = [[JSON valueForKey:@"valid"] boolValue];
         */
    }
    
    return self;
}

- (NSString *)itemInformation
{
    if (self.itemName && [[self itemName] length] > 0)
    {
        return [[self itemName] capitalizedString];
    }
    
    if (self.itemDescription && [[self itemDescription] length] > 0)
    {
        return [[self itemDescription] capitalizedString];
    }
    
    return nil;
}

- (NSString *)description
{
    NSString *information = [self itemInformation];
    
    if (information)
    {
        return [NSString stringWithFormat:@"<%@: %p, barcode: %@, information: %@>", NSStringFromClass([self class]), self, self.barcodeNumber, information];
    }
    else
    {
        return [NSString stringWithFormat:@"<%@: %p, barcode: %@, no item information>", NSStringFromClass([self class]), self, self.barcodeNumber];
    }
}

@end
