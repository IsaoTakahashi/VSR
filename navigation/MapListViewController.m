//
//  MapListViewController.m
//  Realation
//
//  Created by 高橋 勲 on 2012/10/14.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import "MapListViewController.h"
#import "Database.h"
#import "CreateMapViewController.h"
#import "ViewController.h"

@interface MapListViewController ()

@end

static int selectedCellNum;
static ViewController* vCtr;
@implementation MapListViewController

@synthesize mapList;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor brownColor];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    mapList = [[Database getInstance] getMapMasterList];
    
    int count = mapList.count;
    NSLog(@"count:%d",count);
    if( count > 0) {
        return count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    MapMasterEntity* mmEntity = [mapList objectAtIndex:indexPath.row];
    if(mmEntity != nil && mmEntity.title != nil) {
        cell.textLabel.text = mmEntity.title;
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"Map_%d",indexPath.row];
    }
    //NSLog(@"cell_%d",indexPath.row);
    cell.tag = indexPath.row;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
    selectedCellNum = indexPath.row;
}

- (IBAction)deleteMapDatas:(id)sender {
    return;
    [[Database getInstance] deleteAllRecord];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"%@",segue.identifier);
    if([segue.identifier isEqualToString:@"createMap"]) {
        CreateMapViewController* cmvCtr = segue.destinationViewController;
        cmvCtr.delegate = self;
        NSLog(@"prepare showing createMap");
    } else if([segue.identifier isEqualToString:@"showNavi"]) {
        vCtr = segue.destinationViewController;
        vCtr.mmEntity = [mapList objectAtIndex:((UITableViewCell*)sender).tag];
        NSLog(@"prepare showing Navi");
    }
}

#pragma mark -
#pragma mark delegate method
- (void) createdMap:(CreateMapViewController *)ctr {
    if(ctr.mmEntity != nil) {
        if([[Database getInstance] insertMapMaster:ctr.mmEntity]) {
            NSLog(@"Create Map: %@",ctr.mmEntity.title);
        }else {
            NSLog(@"Failed to create map");
        }
    } else {
        [[Database getInstance] deleteAnnotationWithMapNo:ctr.mapNumber];
        NSLog(@"canceled createMap");
    }
    
    
    [self dismissModalViewControllerAnimated:YES];
    
    [self.tableView reloadData];
}

@end
