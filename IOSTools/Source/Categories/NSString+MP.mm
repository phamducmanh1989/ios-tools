//
//  NSString+MP.m
//  IOSTools
//
//  Created by Manh Pham on 12/31/16.
//  Copyright © 2016 Manh Pham. All rights reserved.
//

#import "NSString+MP.h"
#include "json.hpp"
#include <sstream>
#define APPEND_NEWLINE(s) [NSString stringWithFormat:@"%@\n",s]
#define JSON_ERROR(e) [NSString stringWithFormat:@"#error [JSON_ERROR] %s",e.what()]
#define GENERATE_ERROR(e) [NSString stringWithFormat:@"#error [GENERATE_ERROR] %s",e.what()]
using json = nlohmann::json;
@implementation NSString (MP)
- (NSString*)generateModel{
    json j_stream;
    try {
         j_stream = json::parse([self UTF8String]);
    } catch (const std::exception& e) {
        return JSON_ERROR(e);
    }
   
    NSMutableString *ret =  [[NSMutableString alloc] initWithString:APPEND_NEWLINE(@"#import <JSONModel/JSONModel.h>")];

    try {
        
        [ret appendString:APPEND_NEWLINE(@"@interface <#class_name#> : JSONModel")];
        //properties
        for (json::iterator it = j_stream.begin(); it != j_stream.end(); ++it) {
            if (it->is_object()) {
                [ret appendString:@"@property (nonatomic, strong) <#class_name#>* "];
            }else if(it->is_boolean()){
                [ret appendString:@"@property (nonatomic) BOOL "];
            }else if(it->is_array()){
                [ret appendString:@"@property (nonatomic, strong) NSArray<__kindof <#class_name#>*> * "];
            }else if(it->is_number()){
                [ret appendString:@"@property (nonatomic, strong) NSNumber* "];
            }else {
                [ret appendString:@"@property (nonatomic, strong) NSString* "];
            }
            std::stringstream buffer;
            buffer << it.key() << ";" << std::endl;
            [ret appendString:[NSString stringWithCString:buffer.str().c_str() encoding:NSUTF8StringEncoding]];
        }
        [ret appendString:APPEND_NEWLINE(@"@end")];
        //implementation
        [ret appendString:APPEND_NEWLINE(@"@implementation <#class_name#>")];
        [ret appendString:APPEND_NEWLINE(@"@end")];
    }catch (const std::exception& e) {
         return GENERATE_ERROR(e);
    }
    return ret;
}
@end
