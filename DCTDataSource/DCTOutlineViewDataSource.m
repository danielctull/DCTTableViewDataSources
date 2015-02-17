
//
//  DCTOutlineViewDataSource.m
//  DCTDataSource
//
//  Created by Daniel Tull on 17.02.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

#import "DCTOutlineViewDataSource.h"

@implementation DCTOutlineViewDataSource

#pragma mark - DCTOutlineViewDataSource

- (instancetype)initWithOutlineView:(NSOutlineView *)outlineView
						dataSources:(NSArray *)dataSources {

	self = [super init];
	if (!self) return nil;
	_dataSources = [dataSources copy];
	for (DCTDataSource *dataSource in _dataSources) {
		dataSource.parent = self;
	}

	_outlineView = outlineView;
	_outlineView.dataSource = self;
	return self;
}

#pragma mark - DCTParentDataSource

- (NSArray *)childDataSources {
	return self.dataSources;
}

#pragma mark - DCTDataSource

- (NSInteger)numberOfSections {
	return self.dataSources.count;
}

- (void)reloadData {
	[self.outlineView reloadData];
}

- (void)beginUpdates {}

- (void)endUpdates {}

- (void)performUpdate:(DCTDataSourceUpdate *)update {}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {

	if (!item) {
		return self.numberOfSections;
	}

	if ([item isKindOfClass:[DCTDataSource class]]) {
		DCTDataSource *dataSource = item;
		return [dataSource numberOfItemsInSection:0];
	}

	return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {

	if (!item) {
		return self.dataSources[index];
	}

	if ([item isKindOfClass:[DCTDataSource class]]) {
		DCTDataSource *dataSource = item;
		NSIndexPath *indexPath = [NSIndexPath dctDataSource_indexPathForRow:index inSection:0];
		return [dataSource objectAtIndexPath:indexPath];
	}

	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {

	if ([item isKindOfClass:[DCTDataSource class]]) {
		return YES;
	}

	return NO;
}

@end
