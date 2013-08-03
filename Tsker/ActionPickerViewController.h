//
//  ActionPickerViewController.h
//  Tsker
//
//  Created by Donal Hanna on 04/07/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import <UIKit/UIKit.h>
// don't do this for p and d, it'll cause an error:
//#import "CreateGeoFenceViewController.h"
// p and d

// Don't forget the BobSeguer!!!!!!

@class ActionPickerViewController;

@protocol actionPickerDelegate
//- (void)theChoiceWasMade:(ActionPickerViewController *)controller chosenValue:(NSString *)value;
- (void)theChoiceWasMade:(ActionPickerViewController *)controller;
@end

@interface ActionPickerViewController : UIViewController <UIPickerViewDelegate>
{
    IBOutlet UIPickerView *pickerView;
    NSArray *pickerViewArray;

}

@property (nonatomic, retain) NSArray *pickerViewArray;
@property (nonatomic, retain) NSString *chosenAction;

@property (nonatomic, weak) id <actionPickerDelegate> delegate;

@property (nonatomic, weak) NSString *inPresetString;

@property int pickerPresetIndexVal;

@end




