//
//  Logger.h
//  Links
//
//  Created by Eoin Nolan on 17/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOGI
#define LOGD

#ifdef LOGI
#define LOG_i(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define LOG_i(fmt, ...)
#endif