//
//  SettingViewController.m
//  IFlyFaceDemo
//
//  Created by 张剑 on 15/1/23.
//  Copyright (c) 2015年 iflytek. All rights reserved.
//

#import "FaceRequestSettingViewController.h"
#import <UIKit/UIKit.h>
#import "IFlyFaceResultKeys.h"

#define _SETTING_SECTION_COUNT   1
#define _SETTING_CELL_COUNT      1
#define _SETTING_CELL_IDENTIFIER @"SettingCell"

#define _SETTING_DATASOURCE_TITLE @"title"
#define _SETTING_DATASOURCE_VALUE @"value"

@interface FaceRequestSettingViewController ()

@property(nonatomic,strong) NSMutableArray* items;

@end


@implementation FaceRequestSettingViewController

-(instancetype)initWithStyle:(UITableViewStyle)style{
    
    //set TableView DataSource
    self.items=[self itemsWithDefaultvalues];
    
    return [super initWithStyle:style];
}

#pragma mark - View lifecycle
-(void)loadView{
    [super loadView];
    self.view.backgroundColor=[UIColor blackColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor=[UIColor blackColor];
    self.tableView.backgroundView = nil;
    self.title=@"设置";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self reloadData];
}

#pragma mark - table DataSource

-(void)setItems:(NSMutableArray*)arr defaultValue:(NSString*)value forTitle:(NSString*)title{
    if(!arr||!value||!title||[title length]<1){
        return ;
    }
    [arr removeAllObjects];
    NSMutableDictionary* dic=[NSMutableDictionary dictionaryWithCapacity:2];
    [dic setValue:title forKey:_SETTING_DATASOURCE_TITLE];
    [dic setValue:value forKey:_SETTING_DATASOURCE_VALUE];
    [arr addObject:dic];
}

-(NSMutableArray*)itemsWithDefaultvalues{
    NSMutableArray* items=[NSMutableArray arrayWithCapacity:_SETTING_CELL_COUNT];
    //人脸模型
    NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
    NSString* gid=[userDefaults objectForKey:KCIFlyFaceResultGID];
    if(!gid){
        gid=@"";
    }
    [self setItems:items defaultValue:gid forTitle:@"人脸模型(gid):"];
    return items;
}

-(void)reloadData{
    NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
    NSString* gid=[userDefaults objectForKey:KCIFlyFaceResultGID];
    [self setItems:self.items defaultValue:gid forTitle:@"人脸模型(gid):"];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _SETTING_SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _SETTING_CELL_COUNT;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = _SETTING_CELL_IDENTIFIER;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    if(self.items&&[self.items count]>indexPath.row){
        cell.textLabel.text = [[self.items objectAtIndex:indexPath.row] objectForKey:_SETTING_DATASOURCE_TITLE];
        cell.textLabel.font=[UIFont systemFontOfSize:17];
        cell.detailTextLabel.text=[[self.items objectAtIndex:indexPath.row] objectForKey:_SETTING_DATASOURCE_VALUE];
        cell.detailTextLabel.textColor=[UIColor colorWithRed:28/255.0f green:160/255.0f blue:170/255.0f alpha:1.0];
        cell.detailTextLabel.font=[UIFont systemFontOfSize:14];
        
        cell.backgroundColor=[UIColor blackColor];
        cell.textLabel.textColor=[UIColor whiteColor];
        cell.textLabel.backgroundColor=[UIColor blackColor];

    }
   
    return cell ;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            float version =[[[UIDevice currentDevice] systemVersion] floatValue];
            if(version>8.0){
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置"
                                                                                         message:@"请输入注册时返回的人脸模型gid值"
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
                    NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
                    NSString* gid=[userDefaults objectForKey:KCIFlyFaceResultGID];
                    if(!gid){
                        gid=@"请输入gid";
                    }
                    textField.font=[UIFont systemFontOfSize:9];
                    textField.text =gid;
                }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                                       style:UIAlertActionStyleCancel
                                                                     handler:^(UIAlertAction *action) {
                                                                         
                                                                     }];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *action) {
                                                                     UITextField * gidTextField = alertController.textFields.firstObject;
                                                                     NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
                                                                     [userDefaults setObject:gidTextField.text forKey:KCIFlyFaceResultGID];
                                                                     [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                                                 }];
                [alertController addAction:cancelAction];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];

            }else{
                UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"设置" message:@"请输入注册时返回的人脸模型gid值" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
                alertview.alertViewStyle=UIAlertViewStylePlainTextInput;
                UITextField* textField=[alertview textFieldAtIndex:0];
                NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
                NSString* gid=[userDefaults objectForKey:KCIFlyFaceResultGID];
                if(!gid){
                    gid=@"请输入gid";
                }
                textField.font=[UIFont systemFontOfSize:9];
                textField.text =gid;
                [alertview show];
                alertview=nil;
            }

            
        }
        default:{
            
        }
    }
}

#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
        switch (buttonIndex) {
            case 1:
            {
                UITextField* textField=[alertView textFieldAtIndex:0];
                NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
                [userDefaults setObject:textField.text forKey:KCIFlyFaceResultGID];
                [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            }
                break;
                
            default:
                break;
        }
    
}
@end
