//
//  MODCommand.h
//  modulo
//
//  Created by Brandon Sneed on 8/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDCommandLineParser.h"
#import "MODSpecModel.h"

@interface MODCommand : SDCommand

@property (nonatomic, readonly) BOOL verbose;
@property (nonatomic, readonly) BOOL silent;

@end
