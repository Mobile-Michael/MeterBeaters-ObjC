//
//  TableParkingView.m
//  Practice3
//
//  Created by Mike on 11/19/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "TableParkingView.h"
#import "ParkingPolygons.h"
#include "DetailsViewController.h"
#import "MapViewController.h"
#import "UIGlobals.h"
#import "meterbeater.pch"
#import "ParkingSearchFilters.h"
#import "font_changer.h"

@interface TableParkingView ()

@end

@implementation TableParkingView
@synthesize m_bReloadTable;

-(void) setParkingArray : (NSMutableArray *)pParkingArrayAnd : (NSInteger) nSpot : (BOOL) bReloadTable
{
    m_pParkingArray        = pParkingArrayAnd;
    self.m_bReloadTable    = m_nCurrentSelectedSpot!=nSpot||bReloadTable;
    m_nCurrentSelectedSpot = nSpot;
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

-(void) initColorScheme
{
    self.view.backgroundColor = [UIGlobals ourDarkGray];
}

-(void) viewDidLayoutSubviews
{
}

-(void) onViewDidLoadHelper
{
    [self.view setAllFonts:[UIFont fontWithName:@"AppleSDGothicNeo" size:36] bold: [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:36]];
    self.m_bReloadTable = false;
    
    //self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7)
        self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    
    self.tableView.backgroundColor = [UIColor blackColor];
    [self.tableView setSeparatorColor: [UIColor clearColor]];
}

-(void) onViewDidAppearHelper
{
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier: @"Cell"];
    NSString *pTitle = @"Parking Info";
    self.tabBarController.title = pTitle;
    self.title = pTitle;
    
    if(self.m_bReloadTable)
    {
        [self.tableView setAlwaysBounceVertical:YES];
        [self.tableView reloadData];
        self.m_bReloadTable = false;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initColorScheme];
    [self onViewDidLoadHelper];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self onViewDidAppearHelper];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(m_pParkingArray)
    {
        LogBeater(@"num in parking array: %lu", (unsigned long)m_pParkingArray.count);
        return m_pParkingArray.count + 1;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if( indexPath.row > 0)
    {
        static NSString *CellIdentifier = @"CellDetail";
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        NSInteger nSafeIndex = indexPath.row - 1;//becuase there is a header that I put in.
        ParkingPolygons *myParkingObject = [m_pParkingArray objectAtIndex: nSafeIndex];
        
        NSString *pTextLabel = [[NSString alloc] initWithFormat:@"%@ %@ %@",myParkingObject.streetNum,myParkingObject.streetDirection, myParkingObject.streetName];
        
        cell.textLabel.text = pTextLabel;
        
        UIImage *pOn  = [UIImage imageNamed:@"PinDropped.png"];
        UIImage *pOff = [UIImage imageNamed:@"PinOff.png"];
        
        cell.imageView.image = (indexPath.row == 1 && m_nCurrentSelectedSpot != -1) ? pOn : pOff;
        
        [[cell textLabel] setNumberOfLines:0];
        [[cell textLabel] setLineBreakMode:NSLineBreakByWordWrapping];
        [[cell textLabel] setFont:[UIFont systemFontOfSize:13.0f]];
        
        [[cell detailTextLabel] setNumberOfLines:0];
        [[cell detailTextLabel] setLineBreakMode:NSLineBreakByWordWrapping];
        [[cell detailTextLabel] setFont:[UIFont systemFontOfSize:10.0f]];
        
        
        if([[UIGlobals getSearchFilters] getParkType] == FREE)
        {
            NSString *pDetailTextLabel = [myParkingObject getParkingTypeStringWithDistance];
            cell.detailTextLabel.text=pDetailTextLabel;
        }
        
        cell.accessoryType   = UITableViewCellAccessoryDetailDisclosureButton;
        cell.backgroundColor = [UIGlobals ourLightGray];
        
        UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 0.5f)];
        separatorLineView.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:separatorLineView];
    }
    else//aka header
    {
        static NSString *headerCell = @"CellHeader";
        cell = [tableView dequeueReusableCellWithIdentifier: headerCell];
        if( !cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: headerCell];
        }
        
        UIView *backgroundView = [[UIView alloc] initWithFrame: cell.contentView.frame];
        backgroundView.backgroundColor = [UIColor blackColor];
        UILabel *title = [[UILabel alloc] initWithFrame: cell.contentView.frame];
        title.text = @"Parking Info";
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size : 18.0f];
        [backgroundView addSubview: title];
        
        [cell.contentView addSubview: backgroundView];
        
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
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

-(void) pushDetailsPage : (NSInteger) nRow
{
    ParkingPolygons *pCurrentParkSpot=[m_pParkingArray objectAtIndex:nRow];
    
    ParkTimeInfo *pEnd=[[UIGlobals getSearchFilters]getParkTimeEnd];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    DetailsViewController *pDeets = [storyboard instantiateViewControllerWithIdentifier:@"DetailsView"];
    [pDeets setCurrentParking:pCurrentParkSpot:pEnd];
    [pDeets setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:pDeets animated:YES completion:nil];
}

-(void) tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    self.m_bReloadTable = true;
    [self pushDetailsPage : indexPath.row];
}


-(void) transitionBackToMap : (NSInteger) row
{
    MapViewController *pUI = (MapViewController*)m_pMapViewPtr;
    [pUI setSelectedParkingSpot :[m_pParkingArray objectAtIndex:row]];
    
    [self.tabBarController.delegate tabBarController:self.tabBarController shouldSelectViewController:[[self.tabBarController viewControllers] objectAtIndex:MAP_INDEX]];
    
    [self.tabBarController setSelectedIndex:MAP_INDEX];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row > 0)
    {
        [self transitionBackToMap: indexPath.row - 1];
    }
}


-(void) setMapViewController : (MapViewController*)pMap
{
    self->m_pMapViewPtr = pMap;
}

-(UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
    {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
