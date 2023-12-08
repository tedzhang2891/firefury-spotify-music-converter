//
//  HistoryWindowController.m
//  FireFury Audio DRM Removal
//
//  Created by ted zhang on 2018/1/23.
//  Copyright © 2018年 TedZhang. All rights reserved.
//

#import "HistoryWindowController.h"
#import "NSAlertSynchronousSheet.h"
#import "MTableView.h"
#import "MGuideView.h"

struct unknown {
    void* punknown;
    void* pself;
    int nsign;
    int nnum;
};

@interface HistoryWindowController ()

@end

@implementation HistoryWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)windowWillClose:(NSNotification *)notification {
    [NSApp stopModal];
}

- (id)windowNibName {
    return (id)@"HistoryWindow";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    NSWindow* window = [self window];
    [window setDelegate:self];
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSNib* nib = [[NSNib alloc] initWithNibNamed:@"HistoryItem" bundle:mainBundle];
    [self.historyOutlineView registerNib:nib forIdentifier:@"HistoryCell"];
}

- (id)init {
    if (self = [super initWithWindowNibName:@"HistoryWindow" owner:self]) {
    //if (self = [super init]) {
        [self loadHistoryRecordFile];
    }
    return self;
}

- (void)runModal {
    [self.historyOutlineView reloadData];
    [self.historyOutlineView expandItem:nil expandChildren:YES];
    NSUInteger count = [self.records count];
    [self showGuideView:(count == 0)];
    
    NSRect windowRect;
    NSRect mainWindowRect;
    NSRect finalWindowRect;
    
    NSWindow* window = [self window];
    if (window) {
        windowRect = [window frame];
    }
    else {
        windowRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    }
    
    NSWindow* mainWindow = [NSApp mainWindow];
    if (mainWindow) {
        mainWindowRect = [mainWindow frame];
        finalWindowRect = mainWindowRect;
    }
    else {
        mainWindowRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
        finalWindowRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    }
    
    
    
    [window setFrame:windowRect display:NO];
    [window orderFront:nil];
    [NSApp runModalForWindow:window];
}

- (BOOL)loadHistoryRecordFile { 
    NSString* recordPath = [self historyRecordFilePath];
    NSMutableDictionary* historyRecord = [NSMutableDictionary dictionaryWithContentsOfFile:recordPath];
    self.historyLibrary = historyRecord;
    if (!historyRecord) {
        NSMutableDictionary* audios = [NSMutableDictionary dictionary];
        NSMutableDictionary* records = [NSMutableDictionary dictionary];
        NSMutableDictionary* all = [NSMutableDictionary dictionaryWithObjectsAndKeys:audios, @"Audios", records, @"Records", nil];
        self.historyLibrary = all;
    }
    
    struct unknown oneblock = {0};
    oneblock.punknown = NULL;
    oneblock.pself = &oneblock.punknown;
    oneblock.nsign = 0x52000000;
    oneblock.nnum = 48;
    
    self.records = [historyRecord objectForKey:@"Records"];
    NSMutableDictionary* audios = [self.historyLibrary objectForKeyedSubscript:@"Audios"];
    NSDictionary* tmpAudios = [NSDictionary dictionaryWithDictionary:audios];
    [tmpAudios enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
        BOOL isDir;
        NSString* destination = [obj objectForKey:@"Destination"];
        NSFileManager* sharedFileManager = [NSFileManager defaultManager];
        BOOL bRet = [sharedFileManager fileExistsAtPath:destination isDirectory:&isDir];
        if (!bRet) {
            [self removeItemsFromFile:[NSArray arrayWithObject:obj]];
        }
    }];
    
    NSUInteger count = [self.records count];
    //[self showGuideView:(count == 0)];
    return YES;
}

- (void)removeRecordFromList:(NSArray *)array {
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSAlert* anAlert = [[NSAlert alloc] init];
    anAlert.messageText = [mainBundle localizedStringForKey:@"Confirm Delete" value:nil table:nil];
    anAlert.informativeText = [mainBundle localizedStringForKey:@"Do you want to move the file to the Trash,or only remove it from list?" value:nil table:nil];
    [anAlert addButtonWithTitle:[mainBundle localizedStringForKey:@"Remove from list" value:nil table:nil]];
    [anAlert addButtonWithTitle:[mainBundle localizedStringForKey:@"Cancel" value:nil table:nil]];
    [anAlert addButtonWithTitle:[mainBundle localizedStringForKey:@"Move to Trash" value:nil table:nil]];
    NSUInteger action = [anAlert runModalSheet];
    // Response button event of the window
    switch (action) {
            // TODO: implement function
        case NSAlertFirstButtonReturn:
            [self removeItemsFromFile:array];
            [self.historyOutlineView reloadData];
            NSUInteger itemCount = [self.records count];
            [self showGuideView:(itemCount == 0)];
            break;
            
        case NSAlertSecondButtonReturn:
            // Do nothing
            break;
            
        case NSAlertThirdButtonReturn:
            for (id each in array) {
                NSAppleScript* appleScript = [NSAppleScript alloc];
                NSString* destination = [each objectForKeyedSubscript:@"Destination"];
                NSString* command = [NSString stringWithFormat:@"tell application \"Finder\" to move POSIX file \"%@\" to trash", destination];
                appleScript = [appleScript initWithSource:command];
                
                NSDictionary *dict = nil;
                if (![appleScript executeAndReturnError:&dict]) {
                    NSLog(@"move %@ to trash failure %@", destination, dict);
                }
            }
            
            [self removeItemsFromFile:array];
            [self.historyOutlineView reloadData];
            [self showGuideView:([self.records count] == 0)];
            break;
            
        default:
            break;
    }
}

- (void)removeItemsFromFile:(id)items {
    for (id each in items) {
        NSMutableDictionary* audios = [self.historyLibrary objectForKeyedSubscript:@"Audios"];
        NSString* trackID = [each objectForKeyedSubscript:@"Track ID"];
        NSDate* modifiedTime = [each objectForKeyedSubscript:@"ModifiedTime"];
        [audios removeObjectForKey:trackID];
        NSString* dateString = [self dateStringFromDateTime:modifiedTime];
        id recordsOnSameDay = [self.records objectForKeyedSubscript:dateString];
        [recordsOnSameDay removeObject:trackID];
        id recordsList = [self.records objectForKeyedSubscript:dateString];
        if (![recordsList count]) {
            [self.records removeObjectForKey:dateString];
        }
    }
    
    [self.historyLibrary writeToFile:[self historyRecordFilePath] atomically:YES];
}

- (NSString *)historyRecordFilePath {
    NSString* searchPath = nil;
    NSString* searchBundle = nil;
    
    id searchList = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* bundleName = [mainBundle objectForInfoDictionaryKey:(NSString*)kCFBundleNameKey];
    
    if ([searchList count]) {
        searchPath = [searchList objectAtIndex:0];
        searchBundle = [searchPath stringByAppendingPathComponent:bundleName];
    }
    else {
        searchBundle = NSTemporaryDirectory();
    }
    
    return [searchBundle stringByAppendingPathComponent:@"ConvertHistory.plist"];
}

- (id)convertedTrackURLs {
    NSMutableArray* sourceArray = [NSMutableArray array];
    NSMutableDictionary* audios = [self.historyLibrary objectForKeyedSubscript:@"Audios"];
    
    NSArray* allValues = [audios allValues];
    for (id each in allValues) {
        id value = [each objectForKeyedSubscript:@"Source"];
        [sourceArray addObject:value];
    }
    
    return sourceArray;
}

- (BOOL)addConvertedItem:(NSMutableDictionary *)record destinationPath:(NSString *)path {
    NSMutableDictionary* tmpdict = [NSMutableDictionary dictionary];
    NSUUID* uuid = [NSUUID UUID];
    NSString* uuidStr = [uuid UUIDString];
    [tmpdict setObject:uuidStr forKeyedSubscript:@"Track ID"];
    NSDate* date = [NSDate date];
    [tmpdict setObject:date forKeyedSubscript:@"ModifiedTime"];
    
    NSString* name = [record objectForKeyedSubscript:@"Name"];
    NSString* artist = [record objectForKeyedSubscript:@"Artist"];
    NSString* location = [record objectForKeyedSubscript:@"Location"];
    
    [tmpdict setObject:name forKeyedSubscript:@"Name"];
    [tmpdict setObject:artist forKeyedSubscript:@"Artist"];
    [tmpdict setObject:location forKeyedSubscript:@"Source"];
    [tmpdict setObject:path forKeyedSubscript:@"Destination"];
    
    NSNumber* fileSize;
    NSFileManager* sharedFileManager = [NSFileManager defaultManager];
    id attributes = [sharedFileManager attributesOfItemAtPath:path error:nil];
    if (attributes) {
        fileSize = [attributes objectForKeyedSubscript:NSFileSize];
    }
    else {
        fileSize = [NSNumber numberWithInt:0];
    }
    [tmpdict setObject:fileSize forKeyedSubscript:@"Size"];
    
    NSMutableDictionary* audios = [self.historyLibrary objectForKeyedSubscript:@"Audios"];
    [audios setObject:tmpdict forKey:uuidStr];
    NSString* dateString = [self dateStringFromDateTime:date];
    
    NSMutableDictionary* records = [self.historyLibrary objectForKeyedSubscript:@"Records"];
    id recordinfo = [records objectForKey:dateString];
    if (recordinfo) {
        [recordinfo insertObject:uuidStr atIndex:0];
    }
    else {
        NSMutableArray* tmpArray = [NSMutableArray array];
        [tmpArray addObject:uuidStr];
        [records setObject:tmpArray forKey:dateString];
    }
    
    NSString* recordFile = [self historyRecordFilePath];
    return [self.historyLibrary writeToFile:recordFile atomically:YES];
}

- (NSString *)dateStringFromDateTime:(NSDate*)dateTime {
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYY-MM-dd"];
    return [df stringFromDate:dateTime];
}

- (void)showGuideView:(BOOL)bShow {
    [[self.historyOutlineView enclosingScrollView] setHidden:bShow];
    MGuideView* contentView = [[self window] contentView];
    [contentView setIsShowGuideView:bShow];
}

- (void)dealloc { 

}

- (void)btnDeleteFromList:(id)sender { 
    id superView = [sender superview];
    id value = [superView objectValue];
    NSArray *array = [NSArray arrayWithObject:value];
    [self removeRecordFromList:array];
}

- (void)btnShowInFinder:(id)sender { 
    id superView = [sender superview];
    id value = [superView objectValue];
    BOOL bIsDir;
    NSString* destination = [value objectForKeyedSubscript:@"Destination"];
    
    NSFileManager* sharedFileManager = [NSFileManager defaultManager];
    if ([sharedFileManager fileExistsAtPath:destination isDirectory:&bIsDir]) {
        NSWorkspace* sharedWorkspace = [NSWorkspace sharedWorkspace];
        NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
        NSString* outputFolder = [sharedUserDefaults stringForKey:@"PreferenceOutputFolderKey"];
        [sharedWorkspace selectFile:destination inFileViewerRootedAtPath:outputFolder];
    }
    else {
        NSLog(@"No such file:%@", destination);
    }
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item { 
    id cell = nil;
    if ([item isKindOfClass:[NSDictionary class]]) {
        cell = [self.historyOutlineView makeViewWithIdentifier:@"HistoryCell" owner:self];
        [cell setObjectValue:item];
        NSString* source = [item objectForKeyedSubscript:@"Source"];
        NSString* exts = [source pathExtension];
        NSWorkspace* sharedWorkspace = [NSWorkspace sharedWorkspace];
        NSImage* extImage = [sharedWorkspace iconForFileType:exts];
        [[cell imageView] setImage:extImage];
    }
    else {
        cell = [self.historyOutlineView makeViewWithIdentifier:@"TitleCell" owner:self];
        NSTextField* text = [cell textField];
        [text setStringValue:item];
        id subviews = [cell subviews];
        for (id view in subviews) {
            // TODO: implement badge string view.
        }
    }
    return cell;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item { 
    MTableRowView* tableRowView = [outlineView makeViewWithIdentifier:@"NSTableViewRowViewKey" owner:self];
    NSColor* selectionColor = [NSColor colorWithDeviceRed:(0.8784313725490196)
                                                    green:(0.9450980392156862)
                                                     blue:(0.7019607843137254)
                                                    alpha:1.0];
    [tableRowView setSelectionColor:selectionColor];
    return tableRowView;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item { 
    return [item isKindOfClass:[NSString class]] != NO;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item { 
    BOOL bString = [item isKindOfClass:[NSString class]];
    return bString ? 20.0f : 50.0f;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item { 
    if (item == nil) {
        return [self.records count];
    }
    
    id object = [self.records objectForKeyedSubscript:item];
    return [object count];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item { 
    if (item) {
        id object = [self.records objectForKeyedSubscript:item];
        id element = [object objectAtIndex:index];
        NSMutableDictionary* audios = [self.historyLibrary objectForKeyedSubscript:@"Audios"];
        return [audios objectForKey:element];
    }
    else {
        NSArray* allKeys = [self.records allKeys];
        NSArray* sortedKeys = [allKeys sortedArrayUsingSelector:@selector(compare:)];
        id enumerator = [sortedKeys reverseObjectEnumerator];
        id reverseKeys = [enumerator allObjects];
        return [reverseKeys objectAtIndex:index];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item { 
    return [item isKindOfClass:[NSString class]] == NO;
}

@end
