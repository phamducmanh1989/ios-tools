//
//  NSString+MP.h
//  IOSTools
//
//  Created by Manh Pham on 12/31/16.
//  Copyright © 2016 Manh Pham. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MP)

/**
 Auto generate model
 
 @return base string model define
 */
- (NSString*)generateModel;
- (NSString*)convertToCamelCase;
@end
