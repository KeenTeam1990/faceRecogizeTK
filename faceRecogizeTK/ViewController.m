//
//  ViewController.m
//  faceRecogizeTK
//
//  Created by keenteam on 2018/3/21.
//  Copyright © 2018年 keenteam. All rights reserved.
//

#import "ViewController.h"
#import "ConfirmFaceViewController.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong)NSMutableArray * dataMArr;
@property (nonatomic ,strong)UITableView * tabV;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTableView];
    
}

/**创建数据表 */
- (void)createTableView{
    
     _dataMArr = [[NSMutableArray alloc]initWithObjects:@[@"人脸注册/验证/检测/关键点检测"], nil];
    [self.view addSubview:self.tabV];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row ==1 && indexPath.section ==1) {
        return 80;
    }
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *titles = @[@"人脸检测"];
    return titles[section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return  _dataMArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSArray * arr = _dataMArr[section];
    return arr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * cellID = @"CELL";
    UITableViewCell * cell = [tableView   dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = _dataMArr[indexPath.section][indexPath.row];
    
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
        ConfirmFaceViewController * registerFaceVC = [[ConfirmFaceViewController alloc]init];
        UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:registerFaceVC];
        [self presentViewController:nav animated:YES completion:nil];
        
}

/**懒加载 */
- (UITableView *)tabV{
    
    if (!_tabV) {
        _tabV = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    }
    _tabV.dataSource = self;
    _tabV.delegate = self;
    return _tabV;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
