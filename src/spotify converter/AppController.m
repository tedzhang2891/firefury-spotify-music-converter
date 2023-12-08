//
//  AppController.m
//  FireFury DRM Removal
//
//  Created by ted zhang on 1/11/18.
//  Copyright © 2018 TedZhang. All rights reserved.
//

#import "AppController.h"
#import "PreferenceWindowController.h"
#import "SpotifyAddWindowController.h"
#import "HistoryWindowController.h"
#import "ProgressWindowController.h"
#import "MTableView.h"
#import "MGuideView.h"
#import "INAppStoreWindow.h"

#import <ProductionAuthentication/Authentication.h>

@interface AppController ()

@end

@implementation AppController

@dynamic debugDescription;
@dynamic description;
@dynamic hash;
@dynamic superclass;

static PreferenceWindowController* preference = nil;
//static ProductController* productCtl = nil;

// BEGIN Delegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    id appWindow = [self window];
    [appWindow setTrafficLightButtonsLeftMargin:7.0];
    [appWindow setCenterTrafficLightButtons:0];
    [appWindow setTitleBarHeight:40.0];
    [appWindow setBottomBarHeight:50.0];
    [appWindow setCenterFullScreenButton:YES];
    [appWindow setCenterTrafficLightButtons:YES];
    [self.titleBarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bottomBarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[appWindow titleBarView] addSubview:self.titleBarView];
    [[appWindow bottomBarView] addSubview:self.bottomBarView];
    
    /*
    NSDictionary* viewsDictionary = @{ @"titleBarView": self.titleBarView, @"bottomBarView": self.bottomBarView };
    id layout = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[titleBarView]-0-|" options:0 metrics:nil views:viewsDictionary];
    [self.titleBarView addConstraint:layout];
    
    layout = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[titleBarView]-0-|" options:0 metrics:nil views:viewsDictionary];
    [self.titleBarView addConstraint:layout];
    
    layout = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bottomBarView]-0-|" options:0 metrics:nil views:viewsDictionary];
    [self.bottomBarView addConstraint:layout];
    
    layout = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[bottomBarView]-0-|" options:0 metrics:nil views:viewsDictionary];
    [self.bottomBarView addConstraint:layout];
    */
    
    [self showGuideView:YES];
    
    NSNotificationCenter* sharedNotificationCenter = [NSNotificationCenter defaultCenter];
    [sharedNotificationCenter addObserver:self selector:@selector(userDidFinishRegister:) name:@"userDidFinishRegistration" object:nil];
    
    [sharedNotificationCenter addObserver:self selector:@selector(injectDidFailure:) name:@"InjectDidFailureNotification" object:nil];
    
    [self.appTitleField setStringValue:@"FireFury Spotify Music Converter"];
    
    dispatch_time_t time = dispatch_time(0, 100000000);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [appWindow setCenterTrafficLightButtons:YES];
        [appWindow setCenterFullScreenButton:YES];
        [appWindow update];
    });
    
    [appWindow setDelegate:self];
    
    if( preference == nil ) {
        preference = [[PreferenceWindowController alloc] initWithWindowNibName:@"PreferenceWindow"];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    NSLog(@"exit\n");
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(id)sender {
    return YES;
}
// END Delegate

- (id)init {
    if (self = [super init]) {
        addWindowController = [[SpotifyAddWindowController alloc] init];
        progressWindowController = [[ProgressWindowController alloc] init];
        historyWindowController = [[HistoryWindowController alloc] init];
    }
    
    if (self->productController == nil) {
        self->productController = [[ProductController alloc] init];
    }
    
    return self;
}

- (void)awakeFromNib {
    if ([ProductController isRegister]) {
        [self.buyButton setHidden:YES];
        [self.unregisterButton setHidden:YES];
    }
    
    NSColor* selectionColor = [NSColor colorWithDeviceRed:(0.8784313725490196)
                                           green:(0.9450980392156862)
                                            blue:(0.7019607843137254)
                                           alpha:1.0];
    
    [self.convertTableView setSelectionColor:selectionColor];
    
    id columns = [self.convertTableView tableColumns];
    for (id obj in columns) {
        MTableHeaderCell* mtheaderCell = [MTableHeaderCell alloc];
        NSString* cellTitle = [[obj headerCell] stringValue];
        id cell = [mtheaderCell initTextCell:cellTitle];
        [obj setHeaderCell:cell];
        id headerCell = [obj headerCell];
        [headerCell setTextColor:[NSColor blackColor]];
        NSColor* textColor = nil;
        id dataCell = [obj dataCell];
        if ([dataCell isKindOfClass:[NSTextFieldCell class]]) {
            NSFont* font = [AppController fontForSize:12.0];
            [dataCell setFont:font];
            NSString* identifier = [obj identifier];
            if ([identifier isEqualToString:@"Total Time"] || [identifier isEqualToString:@"Genre"] ||
                [identifier isEqualToString:@"Album"]) {
                textColor = [NSColor colorWithDeviceRed:(0.9333333333333333)
                                                  green:(0.3568627450980392)
                                                   blue:(0.1607843137254902)
                                                  alpha:1.0];
            }
            else {
                textColor = [NSColor colorWithDeviceRed:(0.3372549019607843)
                                                  green:(0.3372549019607843)
                                                   blue:(0.3372549019607843)
                                                  alpha:1.0];
            }
            [dataCell setTextColor:textColor];
        }
    }
    
    //NSRect frame = self.convertTableView.headerView.frame;
    //frame.size.height = 26;
    //self.convertTableView.headerView.frame = frame;
    
    NSMutableAttributedString* attr = [[NSMutableAttributedString alloc] initWithAttributedString:[self.appTitleField attributedStringValue]];
    NSFont* font = [AppController fontForSize:12.0];
    [attr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [attr length])];
    NSColor *color = [NSColor colorWithDeviceRed:(0.3372549019607843)
                                           green:(0.3372549019607843)
                                            blue:(0.3372549019607843)
                                           alpha:1.0];
    [attr addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [attr length])];
    [self.appTitleField setAttributedStringValue:attr];
    
    NSMutableAttributedString* attr1 = [[NSMutableAttributedString alloc] initWithAttributedString:[self.unregisterButton attributedTitle]];
    NSColor *color1 = [NSColor colorWithDeviceRed:(0.9333333333333333)
                                           green:(0.3568627450980392)
                                            blue:(0.1607843137254902)
                                           alpha:1.0];
    [attr1 addAttribute:NSForegroundColorAttributeName value:color1 range:NSMakeRange(0, [attr1 length])];
    [attr1 addAttribute:NSFontAttributeName value:[AppController fontForSize:10.0] range:NSMakeRange(0, [attr1 length])];
    [attr1 addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(0, [attr1 length])];
    [self.unregisterButton setAttributedTitle:attr1];
    
    NSMutableAttributedString* attr2 = [[NSMutableAttributedString alloc] initWithAttributedString:[self.guideAddButton attributedTitle]];
    NSColor *color2 = [NSColor colorWithDeviceRed:(0.0)
                                            green:(0.4274509803921568)
                                             blue:(0.0)
                                            alpha:1.0];
    [attr2 addAttribute:NSForegroundColorAttributeName value:color2 range:NSMakeRange(0, [attr2 length])];
    [attr2 addAttribute:NSFontAttributeName value:[AppController fontForSize:15.0] range:NSMakeRange(0, [attr2 length])];
    [self.guideAddButton setAttributedTitle:attr2];
    
    NSMutableAttributedString* attr3 = [[NSMutableAttributedString alloc] initWithAttributedString:[self.convertButton attributedTitle]];
    NSColor *color3 = [NSColor whiteColor];
    [attr3 addAttribute:NSForegroundColorAttributeName value:color3 range:NSMakeRange(0, [attr3 length])];
    [attr3 addAttribute:NSFontAttributeName value:[AppController fontForSize:12.0] range:NSMakeRange(0, [attr3 length])];
    [self.convertButton setAttributedTitle:attr3];
    
    [self updateMediaInfo];
}

- (BOOL)validateUserInterfaceItem:(id)sender {
    SEL selector = [sender action];
    if (selector != @selector(remove:)) {
        if (selector == @selector(convert:) && [self.convertTableView numberOfRows] <= 0) {
            return NO;
        }
        else {
            return YES;
        }
    }
    if ([[self.convertTableView selectedRowIndexes] count]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)updateMediaInfo {
    NSInteger totaltime = 0;
    if ([convertItems count]) {
        for (id obj in convertItems) {
            NSNumber* duration = [obj objectForKeyedSubscript:@"Total Time"];
            totaltime += [duration integerValue];
        }
        
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSInteger itemCount = [convertItems count];
        NSValueTransformer* identifier = [NSValueTransformer valueTransformerForName:@"DurationToStringTransformer"];
        id value = [identifier transformedValue:[NSNumber numberWithInteger:totaltime]];
        NSString* audioInfo = [NSString stringWithFormat:[mainBundle localizedStringForKey:@"%lu files, total duration %@" value:nil table:nil], itemCount, value];
        NSMutableAttributedString* attr = [[NSMutableAttributedString alloc] initWithString:audioInfo];
        NSFont* font = [AppController fontForSize:10.0];
        [attr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [attr length])];
        
        NSColor *color = [NSColor colorWithDeviceRed:(0.4745098039215686)
                                               green:(0.4745098039215686)
                                                blue:(0.4745098039215686)
                                               alpha:1.0];
        [attr addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [attr length])];
        [self.audioInfoField setAttributedStringValue:attr];
    }
    else {
        [self.audioInfoField setStringValue:@""];
    }
}

- (void)showGuideView:(BOOL)bflag {
    id closeView = [self.convertTableView enclosingScrollView];
    [closeView setHidden:bflag];
    id guideView = [[self window] contentView];
    // TODO: Implement guide view
    [guideView setIsShowGuideView:bflag];
}

- (void)keyDown:(id)sender {
    if ([sender keyCode] == 51 || [sender keyCode] == 117) {
        [self remove:self.convertTableView];
    }
}

- (IBAction)add:(id)sender {
    NSArray* convertedTrackURLs = [self->historyWindowController convertedTrackURLs];
    [self->addWindowController setConvertedTrackURLs:convertedTrackURLs];
    
    void(^completeHandle)(NSArray*) = ^(NSArray* selectedItems){
        if (convertItems == nil) {
            convertItems = [[NSMutableArray alloc] initWithArray:selectedItems];
        }
        else {
            NSMutableArray* convertTracks = [NSMutableArray array];
            for (id obj in convertItems) {
                NSString* location = [obj objectForKeyedSubscript:@"Location"];
                [convertTracks addObject:location];
            }
            NSMutableArray* selectTracks = [NSMutableArray array];
            for (id obj in selectedItems) {
                NSString* location = [obj objectForKeyedSubscript:@"Location"];
                if (![convertTracks containsObject:location]) {
                    [selectTracks addObject:obj];
                }
            }
            
            if ([selectTracks count]) {
                [convertItems addObjectsFromArray:selectTracks];
            }
        }
        [self.convertItemsController setContent:convertItems];
        NSInteger count = [convertItems count];
        [self showGuideView:count == 0];
        [self.convertTableView reloadData];
        [self updateMediaInfo];
    };
    [self->addWindowController beginSheetWithCompleteHandler:completeHandle];
}

- (IBAction)convert:(id)sender {
    void(^completeHandle)(id, id) = ^(id track, id outfile){
        [historyWindowController addConvertedItem:track destinationPath:outfile];
        dispatch_async(dispatch_get_main_queue(), ^{
            // TODO: implement badge button
            NSInteger index = [convertItems indexOfObject:track];
            if (index != NSNotFound) {
                [convertItems removeObject:track];
                [self.convertItemsController setContent:convertItems];
                [self.convertTableView reloadData];
                if ([convertItems count] == 0) {
                    [self showGuideView:YES];
                }
            }
            return [self updateMediaInfo];
        });
    };
    
    if ([convertItems count] == 0) {
        return;
    }
    
    if ([ProductController isRegister]) {
        [progressWindowController convertWithTracks:convertItems completeHandler:completeHandle];
    }
    else { // if not register
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSString* bundleName = [mainBundle objectForInfoDictionaryKey:(NSString*)kCFBundleNameKey];
        
        NSAlert* anAlert = [[NSAlert alloc] init];
        anAlert.messageText = [mainBundle localizedStringForKey:@"Trial version limits" value:nil table:nil];
        NSString* information = [mainBundle localizedStringForKey:@"%@ is currently in trial mode and only convert 3 minutes for each music file.\n\nTo unlock the limitation, please purchase a license." value:nil table:nil];
        anAlert.informativeText = [NSString stringWithFormat:information, bundleName];
        [anAlert addButtonWithTitle:[mainBundle localizedStringForKey:@"OK" value:nil table:nil]];
        [anAlert addButtonWithTitle:[mainBundle localizedStringForKey:@"Cancel" value:nil table:nil]];
        [anAlert addButtonWithTitle:[mainBundle localizedStringForKey:@"Buy Online" value:nil table:nil]];

        NSUInteger action = [anAlert runModal];
        // Response button event of the window
        if (action == NSAlertFirstButtonReturn) {
            [progressWindowController convertWithTracks:convertItems completeHandler:completeHandle];
        }
        else if (action == NSAlertThirdButtonReturn){
            NSBundle* mainBundle = [NSBundle mainBundle];
            NSDictionary* plist = [mainBundle infoDictionary];
            [self->productController openOrderURL:plist[@"OrderURL"]];
        }
    }
    
}

- (IBAction)history:(id)sender {
    [historyWindowController runModal];
}

- (IBAction)settings:(id)sender {
    [preference showWindow:sender];
}

- (IBAction)buyOnline:(id)sender {
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSDictionary* plist = [mainBundle infoDictionary];
    [self->productController openOrderURL:plist[@"OrderURL"]];
}

- (IBAction)registerApp:(id)sender {
    [self->productController openRegister:sender];
}

- (IBAction)openLogFolder:(id)sender {
    NSString* logPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"PreferenceLogFolderKey"];
    [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:logPath];
}

- (void)remove:(id)sender {
    NSIndexSet *selectedRowIndexes = [self.convertTableView selectedRowIndexes];
    [convertItems removeObjectsAtIndexes:selectedRowIndexes];
    [self.convertItemsController setContent:convertItems];
    [self.convertTableView reloadData];
    [self.convertTableView deselectAll:self];
    NSInteger count = [convertItems count];
    [self showGuideView:count == 0];
    [self updateMediaInfo];
}

- (struct CGRect)window:(id)sender willPositionSheet:(id)sheet usingRect:(struct CGRect)rect {
    NSRect frameRect;
    if ([self window]) {
        frameRect = [[self window] frame];
    }
    CGFloat titleBarHeight = [sender titleBarHeight];
    CGFloat toolbarHeight = [sender toolbarHeight];
    rect.origin.y = frameRect.size.height - titleBarHeight - toolbarHeight;
    return rect;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    MTableRowView *rowView = [tableView makeViewWithIdentifier:@"rowView" owner:self];
    if (!rowView) {
        
        rowView = [[MTableRowView alloc] init];
        rowView.identifier = @"rowView";
    }
    return rowView;
}

- (void)tableView:(id)tableView willDisplayCell:(id)cell forTableColumn:(id)tableColumn row:(NSInteger)row {
    NSWorkspace* sharedWorkspace = [NSWorkspace sharedWorkspace];
    NSImage* image;
    if ([[tableColumn identifier] isEqualToString:@"image"]) {
        id obj = [convertItems objectAtIndex:row];
        NSString* location = [obj valueForKey:@"Location"];
        NSRange range = [location rangeOfString:@"file:///"];
        if (range.location == NSNotFound) {
            image = [sharedWorkspace iconForFileType:@"public.mp3"];
        }
        else {
            NSURL* fileurl = [[NSURL URLWithString:location] filePathURL];
            image = [sharedWorkspace iconForFile:[fileurl path]];
        }
        
        [cell setImage:image];
    }
    else {
        NSTextFieldCell * _cell = cell;
        _cell.textColor = [NSColor darkGrayColor];
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return NO;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    id obj = [convertItems objectAtIndex:row];
    NSString* identifier = [tableColumn identifier];
    id objvalue = [obj valueForKey:identifier];
    if ([[tableColumn identifier] isEqualToString:@"Total Time"]) {
        NSValueTransformer* identifier = [NSValueTransformer valueTransformerForName:@"DurationToStringTransformer"];
        id newvalue = [identifier transformedValue:objvalue];
        return newvalue;
    }
    return objvalue;
}

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    [[NSColor highlightColor] set];
    NSRectFill(dirtyRect);
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    /*
    NSTableColumn *column = [[tableView tableColumns] objectAtIndex:0];
    NSCell *dycell = [tableView preparedCellAtColumn:0 row:row];
    NSRect cellBounds = NSZeroRect;
    cellBounds.size.width = [column width];
    cellBounds.size.height = FLT_MAX;
    NSSize cellSize = [dycell cellSizeForBounds:cellBounds];
    return cellSize.height;
     */
    return 40.0;
}

// View Base
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    // Bold the text in the selected items, and unbold non-selected items
    [self.convertTableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        // Enumerate all the views, and find the NSTableCellViews.
        // This demo could hard-code things, as it knows that the first cell is always an
        // NSTableCellView, but it is better to have more abstract code that works
        // in more locations.
        //
        NSLog(@"row view %ld", (long)row);
        for (NSInteger column = 0; column < rowView.numberOfColumns; column++) {
            NSCell *cellView = [rowView viewAtColumn:column];
            // Is this an NSTableCellView?
            if ([cellView isKindOfClass:[NSTextFieldCell class]]) {
                NSTextFieldCell *tableCellView = (NSTextFieldCell *)cellView;
                // It is -- grab the text field and bold the font if selected
                //NSTextField *textField = tableCellView.textField;
                NSInteger fontSize = [tableCellView.font pointSize];
                if (rowView.selected) {
                    tableCellView.font = [NSFont boldSystemFontOfSize:fontSize];
                } else {
                    tableCellView.font = [NSFont systemFontOfSize:fontSize];
                }
            }
        }
    }];
}

- (long long)numberOfRowsInTableView:(id)sender {
    return [convertItems count];
}

- (void)injectDidFailure:(id)sender {
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSAlert* anAlert = [[NSAlert alloc] init];
    anAlert.messageText = [mainBundle localizedStringForKey:@"Read how to turn SIP off" value:nil table:nil];
    anAlert.informativeText = [mainBundle localizedStringForKey:@"OS X 10.11 (El Capitan) introduced new security measures.\n%@ cannot be launched with System Integrity Protection turned on.\n\nThere is a workaround. Read my website for more information." value:nil table:nil];
    [anAlert addButtonWithTitle:[mainBundle localizedStringForKey:@"OK" value:nil table:nil]];
    [anAlert addButtonWithTitle:[mainBundle localizedStringForKey:@"Visit WebSite" value:nil table:nil]];
    NSUInteger action = [anAlert runModal];
    // Response button event of the window
    if (action == NSAlertSecondButtonReturn) {
        [self->productController openWebsiteURL:self];
    }
    else {
        NSString* turnoffSIPUrl = [self->productController valueFromBundleInfoWithKey:@"TurnoffSIPURL"];
        if (turnoffSIPUrl) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:turnoffSIPUrl]];
        }
    }
    [NSApp terminate:self];
}

- (void)userDidFinishRegister:(id)sender {
    [self.unregisterButton setHidden:YES];
    [self.buyButton setHidden:YES];
}

- (IBAction)openPerferences:(id)sender {
    [preference showWindow:sender];
}

+ (NSFont*)fontForSize:(double)fontSize {
    NSFont* font = [NSFont fontWithName:@"Verdana" size:fontSize];
    if (!font) {
        font = [NSFont systemFontOfSize:12.0];
    }
    return font;
}

+ (void)initialize { 
    [ProductController setEncryptTemplate:@"{1889495B-5789-4EB1-8A39-7BB79AB995BF}"];
}

@end
