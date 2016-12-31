//
//  SourceEditorCommand.m
//  GenerateModel
//
//  Created by Manh Pham on 12/31/16.
//  Copyright © 2016 Manh Pham. All rights reserved.
//

#import "SourceEditorCommand.h"
#import <AppKit/AppKit.h>
#import "NSString+MP.h"
@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    if ([invocation.commandIdentifier hasSuffix:@"SourceEditorCommand"])
    {
         [[self class] autoGenerateModel:invocation];
    }
   
    completionHandler(nil);
}
+ (void)autoGenerateModel:(XCSourceEditorCommandInvocation *)invocation
{
    NSMutableArray * selections = [NSMutableArray array];
    
    for ( XCSourceTextRange *range in invocation.buffer.selections )
    {
        for ( NSInteger i = range.start.line; i <= range.end.line ; i++)
        {
            [selections addObject:invocation.buffer.lines[i]];
        }
    }
    
    NSString * selectedString = [selections componentsJoinedByString:@""];
    //handle error;
    [invocation.buffer.lines addObject:[selectedString generateModel]];
    
}
@end
