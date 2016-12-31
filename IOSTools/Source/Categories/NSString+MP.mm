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
#define string(...) [NSString stringWithFormat:__VA_ARGS__]
#define CLASS_NAME @"#name"
#define GENERATE_TYPE @"#type"
using json = nlohmann::json;

enum GenerateType{
    GenerateTypeCamelCase,
    GenerateTypeUnderscoredCase
};
@implementation NSString (MP)
- (NSString*)generateModel{
    enum GenerateType type = [self getGenerateType];
    NSString *className = [self getClassName];
    
    json j_stream;
    try {
         j_stream = json::parse([[self getJSONValue] UTF8String]);
    } catch (const std::exception& e) {
        return JSON_ERROR(e);
    }
   
    NSMutableString *ret =  [[NSMutableString alloc] initWithString:APPEND_NEWLINE(@"#import <JSONModel/JSONModel.h>")];

    try {
        [ret appendString:[NSString stringWithFormat:@"@interface %@ : JSONModel\n",className]];
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
            [ret appendString:[[NSString stringWithCString:buffer.str().c_str() encoding:NSUTF8StringEncoding] convertToCamelCase]];
        }
        [ret appendString:APPEND_NEWLINE(@"@end\n")];
        //implementation
        
        [ret appendString:[NSString stringWithFormat:@"#import \"%@.h\"\n",className]];
        [ret appendString:[NSString stringWithFormat:@"@implementation %@\n",className]];
        if (type == GenerateTypeCamelCase) {
            [ret appendString:APPEND_NEWLINE(@"+(JSONKeyMapper *)keyMapper{")];
            [ret appendString:APPEND_NEWLINE(@"\treturn [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{")];
            NSString *__token;
             for (json::iterator it = j_stream.begin(); it != j_stream.end(); ++it) {
                 std::stringstream buffer;
                 buffer << it.key();
                 NSString *origin = [NSString stringWithCString:buffer.str().c_str() encoding:NSUTF8StringEncoding];
                 
                 if ([origin rangeOfString:@"_"].location != NSNotFound) {
                     NSString *camelCase = [origin convertToCamelCase];
                     NSString *mapping = [NSString stringWithFormat:@"\t\t\t@\"%@\":@\"%@\",",origin,camelCase];
                     __token = mapping;
                     [ret appendString:APPEND_NEWLINE(mapping)];
                 }
            }
            if (__token) {
                [ret setString:[ret stringByReplacingOccurrencesOfString:__token withString:[__token substringToIndex:__token.length - 1]]];
            }
            [ret appendString:APPEND_NEWLINE(@"\t\t}];")];
            [ret appendString:APPEND_NEWLINE(@"}")];
        }
        [ret appendString:APPEND_NEWLINE(@"+ (BOOL)propertyIsOptional:(NSString *)propertyName {")];
        [ret appendString:APPEND_NEWLINE(@"\treturn YES;")];
        [ret appendString:APPEND_NEWLINE(@"}")];
        [ret appendString:APPEND_NEWLINE(@"@end")];
    }catch (const std::exception& e) {
         return GENERATE_ERROR(e);
    }
    return ret;
}
- (NSString*)getClassName{
    NSRange nameRange = [self rangeOfString:CLASS_NAME];
    if (nameRange.location != NSNotFound){
        NSRange sharpRange = [self rangeOfString:@"#" options:NSCaseInsensitiveSearch range:NSMakeRange(nameRange.location + nameRange.length, self.length - nameRange.location - nameRange.length - 1)];
        if (sharpRange.location != NSNotFound) {
            NSString *__nameValue = [self substringWithRange:NSMakeRange(nameRange.location + nameRange.length + 1, sharpRange.location - nameRange.location - nameRange.length - 2)];
            return [__nameValue stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        }
        
        NSRange openBracketRange = [self rangeOfString:@"{"];
        if (openBracketRange.location != NSNotFound) {
            NSString *__nameValue = [self substringWithRange:NSMakeRange(nameRange.location + nameRange.length + 1, openBracketRange.location - nameRange.location - nameRange.length - 2)];
            return [__nameValue stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        }

    }
    return @"<#class_name#>";
}
- (NSString*)getJSONValue{
    NSRange openBracketRange = [self rangeOfString:@"{"];
    if (openBracketRange.location != NSNotFound) {
        return [self substringFromIndex:openBracketRange.location];
    }
    return self;
}
- (enum GenerateType)getGenerateType{
    NSRange typeRange = [self rangeOfString:GENERATE_TYPE];
    if (typeRange.location != NSNotFound){
        NSRange openBracketRange = [self rangeOfString:@"{"];
        if (openBracketRange.location != NSNotFound) {
            NSString *__typeValue = [self substringWithRange:NSMakeRange(typeRange.location + typeRange.length + 1, openBracketRange.location - typeRange.location - typeRange.length - 1)];
            __typeValue = [__typeValue stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
            if ([[__typeValue lowercaseString] rangeOfString:@"camel"].location != NSNotFound) {
                return GenerateTypeCamelCase;
            }else if ([[__typeValue lowercaseString] rangeOfString:@"underscored"].location != NSNotFound) {
                return GenerateTypeUnderscoredCase;
            }
        }
    }
    return GenerateTypeCamelCase;
}
- (NSString*)convertToCamelCase{
    NSString *retVal = self.capitalizedString;
    retVal = string(@"%@%@",[[retVal substringToIndex:1] lowercaseString],[retVal substringFromIndex:1]);
    retVal = [retVal stringByReplacingOccurrencesOfString:@"_" withString:@""];
    return retVal;
}
@end
