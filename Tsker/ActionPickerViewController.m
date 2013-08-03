//
//  ActionPickerViewController.m
//  Tsker
//
//  Created by Donal Hanna on 04/07/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import "ActionPickerViewController.h"

@interface ActionPickerViewController ()

@end

@implementation ActionPickerViewController

@synthesize pickerViewArray;
@synthesize chosenAction;
// p and d
@synthesize delegate;
@synthesize inPresetString;
@synthesize pickerPresetIndexVal;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    // I think this get loaded just after viewwillappear.
    // Either way it doesn't work in viewwillappear, and it does here:
    [pickerView selectRow:pickerPresetIndexVal inComponent:0 animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"I think you passed me in %@", self.chosenAction);
    pickerViewArray = [[NSArray alloc] initWithObjects:@"Local Notification", @"Email", @"Wake on LAN", nil];
    //chosenAction = pickerViewArray[0];
    NSLog(@"setting chosen action: %@", chosenAction);
    // I know: I could just pass in the index, but I might be able to make more sense of this if I ever come back to it:
    if ([chosenAction isEqualToString:@"Local Notification"])
    {
        pickerPresetIndexVal = 0;
        NSLog(@"&&&& 0");
    }
    else if ([chosenAction isEqualToString:@"Email"])
    {
        pickerPresetIndexVal = 1 ;
    }
    else
    {
        pickerPresetIndexVal = 2;
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    NSLog(@"numberOfRowsInComponent: %i", [pickerViewArray count]);
    return [pickerViewArray count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent: (NSInteger)component
{
    return [self.pickerViewArray objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    //NSString *realTMP = [allCats objectAtIndex:[pickerStatus selectedRowInComponent:0]];
    NSLog(@"selecting... %@", [pickerViewArray objectAtIndex:row]);
    chosenAction = [pickerViewArray objectAtIndex:row];
    //[self.delegate theChoiceWasMade:self chosenValue:chosenAction];
    [self.delegate theChoiceWasMade:self];
}


// act of half desperation. Just because the rowtemp example is set when an action is called:

@end
