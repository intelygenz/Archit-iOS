#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Cucumberish.h"
#import "CCIBlockDefinitions.h"
#import "CCIStepsManager.h"
#import "CCIArgument.h"
#import "CCIBackground.h"
#import "CCIExample.h"
#import "CCIFeature.h"
#import "CCILocation.h"
#import "CCIScenarioDefinition.h"
#import "CCIStep.h"

FOUNDATION_EXPORT double CucumberishVersionNumber;
FOUNDATION_EXPORT const unsigned char CucumberishVersionString[];

