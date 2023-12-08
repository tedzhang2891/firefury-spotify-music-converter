# FireFury Spotify Music Converter

Spotify Music Converter is specially designed to convert Spotify music to DRM-free MP3, WAV, FLAC or AAC. Easily convert Spotify music at 5X faster speed with 100% original quality kept. Also, it can keep ID tags.

### How to use

**Spotify Music Converter** exposes a set of interfaces for client to use and all interations with Spotify are done internally, which are transparent to the client.

```objectivec
//FireFury Spotify Music Converter

@class NSArray, NSArrayController, NSButton, NSMutableArray, NSRegularExpression, NSString, NSTableView, NSTextField, NSTimer, NSView;

__attribute__((visibility("hidden")))
@interface SpotifyAddWindowController : NSWindowController <AddWindowControllerProtocol, DropViewDelegate>
{
    NSTableView *tracksTableView;
    NSTextField *spotifyURLField;
    NSButton *hiddenConvertedButton;
    NSRegularExpression *spotifyURLRegex;
    NSRegularExpression *spotifyURIRegex;
    long long pasteboardChangeCount;
    NSTimer *watchPasteboardTimer;
    CDUnknownBlockType sheetCompleteHandler;
    NSMutableArray *trackCheckStates;
    BOOL _isParsingURI;
    NSArray *_convertedTrackURLs;
    NSView *_guideView;
    NSArrayController *_tracksArrayController;
}

@property BOOL isParsingURI; // @synthesize isParsingURI=_isParsingURI;
@property(retain) NSArrayController *tracksArrayController; // @synthesize tracksArrayController=_tracksArrayController;
@property(retain) NSView *guideView; // @synthesize guideView=_guideView;
@property(retain) NSArray *convertedTrackURLs; // @synthesize convertedTrackURLs=_convertedTrackURLs;
- (BOOL)validateUserInterfaceItem:(id)arg1;
- (void)keyDown:(id)arg1;
- (void)closeSheetWithCode:(unsigned long long)arg1;
- (void)cancel:(id)arg1;
- (void)ok:(id)arg1;
- (void)uncheckSelectedTrack:(id)arg1;
- (void)checkSelectedTrack:(id)arg1;
- (void)updateTrackCheckState:(BOOL)arg1 withIndexSet:(id)arg2;
- (void)setAllTrackCheckState:(BOOL)arg1;
- (void)updateAllCheckState;
- (void)tableView:(id)arg1 didClickTableColumn:(id)arg2;
- (void)tableView:(id)arg1 setObjectValue:(id)arg2 forTableColumn:(id)arg3 row:(long long)arg4;
- (void)tableView:(id)arg1 willDisplayCell:(id)arg2 forTableColumn:(id)arg3 row:(long long)arg4;
- (id)tableView:(id)arg1 objectValueForTableColumn:(id)arg2 row:(long long)arg3;
- (long long)numberOfRowsInTableView:(id)arg1;
- (id)getTrackInfoForInfoString:(id)arg1;
- (id)getTrackInfoForJson:(id)arg1;
- (id)getTrackInfosFromHTML:(id)arg1;
- (void)querySpotifyURI:(id)arg1 completeHandler:(CDUnknownBlockType)arg2;
- (void)URIDidReceived:(id)arg1 forURL:(id)arg2;
- (void)btnHiddenConvert:(id)arg1;
- (void)btnParseURL:(id)arg1;
- (void)beginSheetWithCompleteHandler:(CDUnknownBlockType)arg1;
- (void)setTracks:(id)arg1;
- (void)watchPasteboardForSpotifyURL;
- (id)parseSpotifyContent:(id)arg1;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;
- (void)showGuideView:(BOOL)arg1;
- (void)awakeFromNib;
- (void)dealloc;
- (id)init;
- (id)windowNibName;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end


```

### How to contribute

**Gathering context**

Before doing anything, do a quick check to make sure your idea hasn’t been discussed elsewhere. Skim the project’s README, issues (open and closed), mailing list, and Stack Overflow. You don’t have to spend hours going through everything, but a quick search for a few key terms goes a long way.

If you can’t find your idea elsewhere, you’re ready to make a move. You’ll likely communicate by opening an issue or pull request:

* Issues are like starting a conversation or discussion
* Pull requests are for starting work on a solution
* For lightweight communication, such as a clarifying or how-to question, try asking on Stack Overflow, IRC, Slack, or other chat channels, if the project has one

Before you open an issue or pull request, check the project’s contributing docs (usually a file called CONTRIBUTING, or in the README), to see whether you need to include anything specific. For example, they may ask that you follow a template, or require that you use tests.

If you want to make a substantial contribution, open an issue to ask before working on it. It’s helpful to watch the project for a while, and get to know community members, before doing work that might not get accepted.

**Opening an issue**

You should usually open an issue in the following situations:

* Report an error you can’t solve yourself
* Discuss a high-level topic or idea (for example, community, vision or policies)
* Propose a new feature or other project idea

Tips for communicating on issues:

* If you see an open issue that you want to tackle, comment on the issue to let people know you’re on it. That way, people are less likely to duplicate your work.
* If an issue was opened a while ago, it’s possible that it’s being addressed somewhere else, or has already been resolved, so comment to ask for confirmation before starting work.
* If you opened an issue, but figured out the answer later on your own, comment on the issue to let people know, then close the issue. Even documenting that outcome is a contribution to the project.

**Opening a pull request**

You should usually open a pull request in the following situations:

* Submit trivial fixes (for example, a typo, a broken link or an obvious error)
* Start work on a contribution that was already asked for, or that you’ve already discussed, in an issue

A pull request doesn’t have to represent finished work. It’s usually better to open a pull request early on, so others can watch or give feedback on your progress. Just mark it as a “WIP” (Work in Progress) in the subject line. You can always add more commits later.

Here’s how to submit a pull request:

* Fork the repository and clone it locally. Connect your local to the original “upstream” repository by adding it as a remote. Pull in changes from “upstream” often so that you stay up to date so that when you submit your pull request, merge conflicts will be less likely. (See more detailed instructions here.)
* Create a branch for your edits.
* Reference any relevant issues or supporting documentation in your PR (for example, “Closes #37.”)
* Include screenshots of the before and after if your changes include differences in HTML/CSS. Drag and drop the images into the body of your pull request.
* Test your changes! Run your changes against any existing tests if they exist and create new ones when needed. Whether tests exist or not, make sure your changes don’t break the existing project.
* Contribute in the style of the project to the best of your abilities. This may mean using indents, semi-colons or comments differently than you would in your own repository, but makes it easier for the maintainer to merge, others to understand and maintain in the future.

### Support or Contact

Having trouble with Pages? Check out project [wiki](https://bitbucket.org/tedzhang2891/firefury-soptify-music-converter/wiki/Home) or contact me via email (tedzhang2891@gmail.com) and I’ll help you sort it out.
