//
//  MusicTableViewController.h
//  Music
//
//  Created by Dmitry Ratushnyy on 26/11/15.
//
#import <UIKit/UIKit.h>
#import <VKSdk/VKsdk.h>
#import "LoadingViewController.h"

typedef NS_ENUM(NSInteger, PlaybackMode){
    PlaybackModeNormal,
    PlaybackModeShuffle,
    PlaybackModeRepeatOne
};

@interface VkSongsViewController : UIViewController

@property (nonatomic) VKUser* appUser;
@property (nonatomic) NSMutableArray *songsList;

@property (nonatomic) LoadingViewController *overlayController;
@property (weak, nonatomic) IBOutlet UIView *topControlPlane;
@property (weak, nonatomic) IBOutlet UITableView *songsTableView;
@property (weak, nonatomic) IBOutlet UIView *bottomControlPlane;

@property (weak, nonatomic) IBOutlet UILabel *nowPlayingSongLabel;
@property (weak, nonatomic) IBOutlet UILabel *nowPlayingArtistLabel;
@property (weak, nonatomic) IBOutlet UILabel *nowPlayingTimeLabel;

@property (weak, nonatomic) IBOutlet UIButton *btnPlayPause;
@property (weak, nonatomic) IBOutlet UIButton *btnFF;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayMode;
@property (nonatomic) UIImage* imgPlay;
@property (nonatomic) UIImage* imgPlayModeNormal;
@property (nonatomic) UIImage* imgPlayModeShuffle;
@property (nonatomic) UIImage* imgPlayModeRepeat;
@property (nonatomic) UIImage* imgPause;
@property (nonatomic) id playerTimeObserver;

@property (nonatomic) int tapCount;
@property (nonatomic) NSIndexPath *tappedRow;
@property (nonatomic) NSTimer *tapTimer;

@property (nonatomic) PlaybackMode playbackMode;
@property (nonatomic) NSMutableArray *playSequence;
@property (nonatomic) VKAudio *lastPlayedSong;

- (IBAction)btnPlayPauseTap:(id)sender;
- (IBAction)btnFfTap:(id)sender;
- (IBAction)btnBackTap:(id)sender;
- (IBAction)btnPlayModeTap:(id)sender;

- (NSInteger)getNextSongIdx:(NSInteger)currentIdx;
- (void)playNextSong:(NSInteger) offset;
- (void)updatePlayingTimeLabels;

- (void)setCellTimeLabelWith:(NSInteger)playedTime;
+ (NSString*)formatTime:(NSInteger) time;

- (void)setNowPlayingLabelsValue:(VKAudio *)song;

- (void)tapTimerFired:(NSTimer *) timer;

@end
