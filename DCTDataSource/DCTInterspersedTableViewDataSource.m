//
//  DCTInterspersedTableViewDataSource.m
//  Tweetville
//
//  Created by Daniel Tull on 23.05.2012.
//  Copyright (c) 2012 Daniel Tull Limited. All rights reserved.
//

#import "DCTInterspersedTableViewDataSource.h"
#import "DCTObjectDataSource.h"

@implementation DCTInterspersedTableViewDataSource {
	__strong DCTObjectDataSource *_interspersedDataSource;
	NSUInteger _interspersedDataSourceCount;
	NSUInteger _childRowCount;
}

- (id)init {
	if (!(self = [super init])) return nil;
	_interspersedDataSource = [DCTObjectDataSource new];
	_interspersedDataSourceCount = 0;
	_childRowCount = 0;
	return self;
}
 
- (void)setChildTableViewDataSource:(DCTDataSource *)childTableViewDataSource {
	_childTableViewDataSource = childTableViewDataSource;
	_childTableViewDataSource.parent = self;
}

- (void)setInterspersedCellReuseIdentifier:(NSString *)interspersedCellReuseIdentifier {
	_interspersedDataSource.cellReuseIdentifierHandler = ^(NSIndexPath *indexPath, id object) {
		return interspersedCellReuseIdentifier;
	};
}
- (NSString *)interspersedCellReuseIdentifier {
	
	if (_interspersedDataSource.cellReuseIdentifierHandler == NULL) return nil;
	
	return _interspersedDataSource.cellReuseIdentifierHandler(nil, nil);
}

- (void)reloadData {
	[super reloadData];
	_childRowCount = [self.childTableViewDataSource tableView:self.tableView numberOfRowsInSection:0];
	_interspersedDataSourceCount = 0;
}

- (void)performRowUpdate:(DCTDataSourceUpdateType)update
			   indexPath:(NSIndexPath *)indexPath
			   animation:(UITableViewRowAnimation)animation {
	
	if (update == DCTDataSourceUpdateTypeItemDelete)
		[self performDeleteWithIndexPath:indexPath animation:animation];
		
	else if (update == DCTDataSourceUpdateTypeItemInsert)
		[self performInsertWithIndexPath:indexPath animation:animation];
	
	else
		[super performRowUpdate:update indexPath:indexPath animation:animation];
}

- (void)performDeleteWithIndexPath:(NSIndexPath *)indexPath animation:(UITableViewRowAnimation)animation {
	
	_childRowCount--;
	[super performRowUpdate:DCTDataSourceUpdateTypeItemDelete indexPath:indexPath animation:animation];
	
	if (_childRowCount == 0) return;
	
	NSIndexPath *childIndexPath = [self convertIndexPath:indexPath toChildTableViewDataSource:self.childTableViewDataSource];
	NSInteger interspersedRowToDelete = indexPath.row + 1;
	if (childIndexPath.row == _childRowCount) interspersedRowToDelete = indexPath.row - 1;
	
	_interspersedDataSourceCount--;
	[super performRowUpdate:DCTDataSourceUpdateTypeItemDelete indexPath:[NSIndexPath indexPathForRow:interspersedRowToDelete inSection:0] animation:animation];
}

- (void)performInsertWithIndexPath:(NSIndexPath *)indexPath animation:(UITableViewRowAnimation)animation {
	
	_childRowCount++;
	[super performRowUpdate:DCTDataSourceUpdateTypeItemInsert indexPath:indexPath animation:animation];
	
	if (_childRowCount == 1) return;
	
	NSIndexPath *childIndexPath = [self convertIndexPath:indexPath toChildTableViewDataSource:self.childTableViewDataSource];
	NSInteger interspersedRowToInsert = indexPath.row - 1;
	if (childIndexPath.row == 0) interspersedRowToInsert = indexPath.row + 1;
	
	_interspersedDataSourceCount++;
	[super performRowUpdate:DCTDataSourceUpdateTypeItemInsert indexPath:[NSIndexPath indexPathForRow:interspersedRowToInsert inSection:0] animation:animation];
}

#pragma mark - DCTParentTableViewDataSource

- (NSArray *)childTableViewDataSources {
	return [NSArray arrayWithObjects:self.childTableViewDataSource, _interspersedDataSource, nil];
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath fromChildTableViewDataSource:(DCTDataSource *)dataSource {
	
	if ([dataSource isEqual:_interspersedDataSource])
		return [NSIndexPath indexPathForRow:1 inSection:indexPath.section];
	
	NSInteger row = 2*indexPath.row;
	
	return [NSIndexPath indexPathForRow:row inSection:indexPath.section];	
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toChildTableViewDataSource:(DCTDataSource *)dataSource {
	
	if ([dataSource isEqual:_interspersedDataSource])
		return [NSIndexPath indexPathForRow:0 inSection:0];
	
	NSInteger row = indexPath.row;
		
	row = row/2;
	
	return [NSIndexPath indexPathForRow:row inSection:indexPath.section];
}

- (DCTDataSource *)childTableViewDataSourceForSection:(NSInteger)section {
	return self.childTableViewDataSource;
}

- (DCTDataSource *)childTableViewDataSourceForIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row % 2 == 0) return self.childTableViewDataSource;
		
	return _interspersedDataSource;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	_childRowCount = [self.childTableViewDataSource tableView:tableView numberOfRowsInSection:section];
	if (_childRowCount < 2) return _childRowCount;
	return 2*_childRowCount - 1;
}

@end