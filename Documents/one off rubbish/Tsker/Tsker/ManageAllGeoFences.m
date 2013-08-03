//
//  ManageAllGeoFences.m
//  Tsker
//
//  Created by Donal Hanna on 10/06/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

// if the delete is in here, it's not being removed from the actual clregion thing.

#import "ManageAllGeoFences.h"

@interface ManageAllGeoFences ()

@end

@implementation ManageAllGeoFences
@synthesize managedObjectContext;
@synthesize allFenceDataArray;
@synthesize geoFenceInstance;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    //[super viewWillAppear:TRUE];
    NSLog(@"Table Gubbins");
    //[self.tableView reloadData];
    managedObjectContext = [[DatabaseHelper sharedInstance] managedObjectContext];
    allFenceDataArray = [[NSArray alloc]init];
    NSFetchRequest *allFences = [[NSFetchRequest alloc] init];
    [allFences setEntity:[NSEntityDescription entityForName:@"GeoFence" inManagedObjectContext:managedObjectContext]];
    
    [allFences setIncludesPropertyValues:NO];
    NSError *error = nil;
    allFenceDataArray = [managedObjectContext executeFetchRequest:allFences error:&error];
    NSLog(@"geofenace data has %i records", [allFenceDataArray count]);

    NSLog(@"%@", allFenceDataArray);
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    // This distinction between returning 1 and 0 sections is to deal with either:
    // - presenting an empty table at the start or deleting the last item [return 0]
    // - normal operations
    if ([allFenceDataArray count] > 0)
    {
        NSLog(@"allFenceDataArray count]: %i", [allFenceDataArray count]);
        NSLog(@"numberOfSectionsInTableView: 1");
        return 1;
    }
    else
    {
        NSLog(@"allFenceDataArray count]: %i", [allFenceDataArray count]);
        NSLog(@"numberOfSectionsInTableView: 0");
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [allFenceDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    geoFenceInstance = allFenceDataArray[indexPath.row];
    static NSString *CellIdentifier = @"MyBasicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSLog(@"Before I throw a wobbler: %@", geoFenceInstance.name);
    
    NSString *subTitle = [[geoFenceInstance.latitude stringValue]stringByAppendingString:@" Lat, "];
    subTitle = [subTitle stringByAppendingString: [geoFenceInstance.longitude stringValue]];
    subTitle = [subTitle stringByAppendingString:@ " Long"];
    cell.detailTextLabel.text = subTitle;
    cell.textLabel.text = geoFenceInstance.name;
    // Configure the cell...
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSLog(@"delete from monitored region.");

        // delete from monitored region. Got a bit of messing to do to find it in the collection of regions
        // going to try it based on the name.
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        GeoFence *fenceToGo = allFenceDataArray[indexPath.row];
        NSString *regionName = fenceToGo.name;
        for (CLRegion *monitored in [locationManager monitoredRegions])
        {
            NSLog(@"Looping - CLRegion *monitored in [locationManager monitoredRegions");
            if ([monitored.identifier isEqualToString:regionName])
            {
                [locationManager stopMonitoringForRegion:monitored];
                NSLog(@"Just disable region %@", monitored.identifier);
            }
        }
        
        
        // Delete the row from the data source
        NSManagedObject *rowToGo = allFenceDataArray[indexPath.row ];
        [managedObjectContext deleteObject:rowToGo];
        // I think this persists between runs etc
        [managedObjectContext save:nil];
        
        NSFetchRequest *allFences = [[NSFetchRequest alloc] init];
        [allFences setEntity:[NSEntityDescription entityForName:@"GeoFence" inManagedObjectContext:managedObjectContext]];
        
        [allFences setIncludesPropertyValues:NO];
        NSError *error = nil;
        allFenceDataArray = [managedObjectContext executeFetchRequest:allFences error:&error];
        //[locationManager stopMonitoringForRegion:<#(CLRegion *)#>];
        NSLog(@"geofenace data has %i records", [allFenceDataArray count]);
        // I think that by this stage allfencdata array has already been reduced in size so:
        if (![allFenceDataArray count] == 0)
        {
            NSLog(@"*****>>> iffy: fence count is %i", [allFenceDataArray count]);
            //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            NSLog(@"*****>>> thenny: fence count is %i", [allFenceDataArray count]);
            // delete the section? Need to do this to deal with the deletion of the last row:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationBottom];
        }
    }
      
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
