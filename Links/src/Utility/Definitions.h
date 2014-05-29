//
//  Definitions.h
//  Links
//
//  Created by Eoin Nolan on 26/01/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#ifndef Links_Definitions_h
#define Links_Definitions_h

#define SENTIMENT_DATASET @"SentiWordNet"

#define BG_GREY [UIColor colorWithRed:35.0/255 green:35.0/255 blue:35.0/255 alpha:1.0]
#define FG_GREY [UIColor colorWithRed:50.0/255 green:50.0/255 blue:50.0/255 alpha:1.0]
#define BG_TURQ [UIColor colorWithRed:160.0/255 green:65.0/255 blue:13.0/255 alpha:1.0]

#define FG_PEACH [UIColor colorWithRed:240.0/255 green:189.0/255 blue:139.0/255 alpha:1.0]

#define FG_PEACH [UIColor colorWithRed:240.0/255 green:189.0/255 blue:139.0/255 alpha:1.0]

#define STROKE_DARKGREEN [UIColor colorWithRed:23.0/255 green:55.0/255 blue:33.0/255 alpha:1.0]

#define STROKE_LIGHTGREEN [UIColor colorWithRed:35.0/255 green:148.0/255 blue:71.0/255 alpha:1.0]

#define STROKE_YELLOW [UIColor colorWithRed:236.0/255 green:239.0/255 blue:54.0/255 alpha:1.0]

#define STROKE_BLUE [UIColor colorWithRed:1.0/255 green:163.0/255 blue:239.0/255 alpha:1.0]


#define STROKE_RED [UIColor colorWithRed:205.0/255 green:36.0/255 blue:30.0/255 alpha:1.0]


#define UI_LIGHT_GREY [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0]
#define UI_STROKE_GREY [UIColor colorWithRed:199.0/255 green:199.0/255 blue:205.0/255 alpha:1.0]
#define UI_BLUE [UIColor colorWithRed:0/255 green:122.0/255 blue:255.0/255 alpha:1.0]
#define UI_HIGHLIGHT_BLUE [UIColor colorWithRed:191.1/255 green:234.0/255 blue:255.0/255 alpha:1.0]

#define MAXSIZE 4096
#define MAX_CIRCLE_WIDTH 400

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#endif
