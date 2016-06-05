//
//  MusicTableViewController.m
//  Music
//
//  Created by Dmitry Ratushnyy on 25/11/15.
//
#import <VKSdk/VKSdk.h>
#import "VkSongsViewController.h"
#import "SongTableViewCell.h"
#import "LoadingViewController.h"
#import "AudioPlayerController.h"
#import "VkAppData.h"


@interface VkSongsViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, VKSdkUIDelegate>
@end

@implementation VkSongsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AudioPlayerController instance] setAudioSession];
    self.imgPause = [UIImage imageNamed:@"btnPauseBlue.png"];
    self.imgPlay = [UIImage imageNamed:@"btnPlayBlue.png"];
    self.imgPlayModeNormal = [UIImage imageNamed:@"btnNormalPlay.png"];
    self.imgPlayModeShuffle = [UIImage imageNamed:@"btnShuffle.png"];
    self.imgPlayModeRepeat = [UIImage imageNamed:@"btnRepeat.png"];
    self.nowPlayingSongLabel.text = @"";
    self.nowPlayingArtistLabel.text = @"";
    self.nowPlayingTimeLabel.text = @"";
    self.playbackMode = PlaybackModeNormal;
    APP_SCOPE = @[VK_PER_AUDIO];
    self.songsList = [[NSMutableArray alloc] init];
    self.playSequence = [[NSMutableArray alloc] init];
    self.lastPlayedSong = nil;
    self.songsTableView.delegate = self;
    self.songsTableView.dataSource = self;
    [self showActivityIndicator];
    [[VKSdk initializeWithAppId:APP_ID] registerDelegate:self];
    [[VKSdk instance] setUiDelegate:self];
    [VKSdk wakeUpSession:APP_SCOPE completeBlock:^(VKAuthorizationState state, NSError *error) {
        if (state == VKAuthorizationAuthorized) {
            [self runApp];
        }else if (state == VKAuthorizationInitialized){
            [self authorize:self];
        }else if (error) {
        [[[UIAlertView alloc] initWithTitle:nil message:[error description] delegate:self
                          cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)runApp {
    [self getCurrentUser];
    [self getUserAudio:self.appUser.id];
}

#pragma mark Loading indicator

- (void) showActivityIndicator {
    if (self.overlayController == nil) {
        CGRect rect = CGRectMake(160, 280, 0, 40);
        self.overlayController = [[LoadingViewController alloc] initWithFrame:rect];
    }
    [self.view insertSubview:self.overlayController.view aboveSubview:self.view];
}

- (void)hideActivityIndicator {
    [self.overlayController.view removeFromSuperview];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.songsList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songsList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongCell"];
    if(!cell){
        NSArray *nibArray =  [[NSBundle mainBundle] loadNibNamed:@"SongViewCell" owner:self options:nil];
        cell = nibArray[0];
    }

    UIView *selectedCellView = [[UIView alloc] initWithFrame:cell.frame];
    selectedCellView.backgroundColor = [UIColor colorWithRed:210.0/255.0
                                                       green:230.0/255.0
                                                        blue:255.0/255.0
                                                        alpha:0.8];
    cell.selectedBackgroundView = selectedCellView;

    VKAudio *song = self.songsList[indexPath.row];
    cell.title.text = song.title;
    cell.subTitle.text = song.artist;
    cell.duration.text = [VkSongsViewController formatTime:song.duration.intValue];

    if(indexPath.row == 0){ //TODO remember last played item
        self.lastPlayedSong = song;
        [self.songsTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self prepareForPlayback:song];
        [self setNowPlayingLabelsValue:song];
    }
    [self hideActivityIndicator];
    return cell;
}

- (void) setNowPlayingLabelsValue:(VKAudio*) song {
    self.nowPlayingArtistLabel.text = [NSString stringWithFormat:@"%@ -", song.artist];
    self.nowPlayingSongLabel.text = song.title;
    self.nowPlayingTimeLabel.text = [VkSongsViewController formatTime:song.duration.intValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    VKAudio *song = self.songsList[indexPath.row];
    [self setNowPlayingLabelsValue:song];
    [self prepareForPlayback:song];
    if (self.tapCount == 1 && self.tapTimer != nil && self.tappedRow == indexPath) {
        [self.tapTimer invalidate];
        self.tapTimer = nil;
        self.tapCount = 0;
        self.tappedRow = nil;
        [self.btnPlayPause setImage:self.imgPause forState:UIControlStateNormal];
        self.lastPlayedSong = song;
        [[AudioPlayerController instance] play:true];
    }else if (self.tapCount == 0) {
        self.tapCount = 1;
        self.tappedRow = indexPath;
        self.tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(tapTimerFired:)
                                                       userInfo:nil repeats:NO];
    }else if (self.tappedRow != indexPath) {
        self.tapCount = 0;
        if (self.tapTimer != nil){
            [self.tapTimer invalidate];
            self.tapTimer = nil;
        }
    }
}

- (void)prepareForPlayback:(VKAudio *)song {
    // TODO seems this can be called just once on init
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[[AudioPlayerController instance] player]];
 
    [[AudioPlayerController instance] initPlayerWith:song.url];
    self.playerTimeObserver = [[[AudioPlayerController instance] player]
            addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC)
                                         queue:NULL usingBlock:^(CMTime time) {[self updatePlayingTimeLabels];}];
}

- (void)tapTimerFired:(NSTimer *) timer {

    if (self.tapTimer != nil){
        self.tapCount = 0;
        self.tappedRow = nil;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setCellTimeLabelWith:0];
    return  indexPath;
}

#pragma mark Vk API

- (IBAction)authorize:(id)sender {
    [VKSdk authorize:APP_SCOPE];
}

-(void) vkSdkReceivedNewToken:(VKAccessToken*) newToken {
     [self runApp];
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self.navigationController.topViewController];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [self authorize:nil];
}

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {
    if (result.token) {
        [self runApp];
    } else if (result.error) {
        [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Access denied\n%@", result.error]
                                   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

- (void)vkSdkUserAuthorizationFailed {
    [[[UIAlertView alloc] initWithTitle:nil message:@"Access denied" delegate:self
                      cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self.navigationController.topViewController presentViewController:controller animated:YES completion:nil];
    
}

- (void)getCurrentUser {
    VKRequest *request = [[VKApi users] get];
    request.waitUntilDone = YES;
    [request executeWithResultBlock:^(VKResponse *response) {
        self.appUser = response.parsedModel[0];
    }                    errorBlock:nil];
}

- (void)getUserAudio:(NSNumber *)owner_id{
    VKRequest *request = [VKRequest requestWithMethod:@"audio.get" andParameters:@{@"owner_id": self.appUser.id}
                                           modelClass:[VKAudios class]];
    [request executeWithResultBlock:^(VKResponse *response) {
        [self hideActivityIndicator];
        for (VKAudio *song in response.parsedModel) {
            [self.songsList addObject:song];
            [self.playSequence addObject:song];
            [self.songsTableView reloadData];
        }
    } errorBlock:nil];

}

#pragma mark Playback control
// TODO move play ctrl buttons to AudioPlayerController (IBOutlet and IBAction)

- (IBAction)btnPlayPauseTap:(id)sender {
    bool playing = [[AudioPlayerController instance] playing];
    if(playing){
        [self.btnPlayPause setImage:self.imgPlay forState:UIControlStateNormal];
    }else{
        [self.btnPlayPause setImage:self.imgPause forState:UIControlStateNormal];
    }
    [[AudioPlayerController instance] play:!playing];
}

- (IBAction)btnFfTap:(id)sender {
    [self setCellTimeLabelWith:0];
    [self playNextSong:1];
}

- (IBAction)btnBackTap:(id)sender {
    [self setCellTimeLabelWith:0];
    [self playNextSong:-1];
}

- (IBAction)btnPlayModeTap:(id)sender {

    switch (self.playbackMode){
        case PlaybackModeNormal:
            self.playbackMode = PlaybackModeShuffle;
            self.playSequence = [[NSMutableArray alloc] init];
            for(NSInteger i=0; i < self.songsList.count; ++i){
                int rnd = arc4random_uniform(self.songsList.count);
                [self.playSequence addObject:self.songsList[rnd]];
            }
            [self.btnPlayMode setImage:self.imgPlayModeShuffle forState:UIControlStateNormal];
            break;
        case PlaybackModeShuffle:
            self.playbackMode = PlaybackModeRepeatOne;
            int idx = [self.songsList indexOfObject:self.lastPlayedSong];
            self.playSequence = [[NSMutableArray alloc] init];
            for(NSInteger i=0; i < self.songsList.count; ++i){
                [self.playSequence addObject:self.songsList[idx]];
            }
            [self.btnPlayMode setImage:self.imgPlayModeRepeat forState:UIControlStateNormal];
            break;
        case PlaybackModeRepeatOne:
            self.playbackMode = PlaybackModeNormal;
            self.playSequence = [[NSMutableArray alloc] init];
            for(NSInteger i=0; i < self.songsList.count; ++i){
                [self.playSequence addObject:self.songsList[i]];
            }
            [self.btnPlayMode setImage:self.imgPlayModeNormal forState:UIControlStateNormal];
            break;
    }
}


- (void)playerItemDidReachEnd:(NSNotification *)notification  {
    [self setCellTimeLabelWith:0];
    [self playNextSong:1];
}

- (void)updatePlayingTimeLabels {
     NSInteger playedTime = (NSInteger)CMTimeGetSeconds([[[AudioPlayerController instance] player] currentTime]);
    [self setCellTimeLabelWith:playedTime];

}

- (void)setCellTimeLabelWith:(NSInteger) playedTime {
    NSIndexPath* indexPath = [self.songsTableView indexPathForSelectedRow];
    SongTableViewCell *cell = [self.songsTableView cellForRowAtIndexPath:indexPath];
    VKAudio* song = self.playSequence[(NSUInteger) indexPath.row];
    NSString * timeText = [VkSongsViewController formatTime:(song.duration.intValue - playedTime)];
    cell.duration.text = timeText;
    self.nowPlayingTimeLabel.text = timeText;
}

- (void)playNextSong:(NSInteger) offset {
    NSInteger nextSongIdx = [self getNextSongIdx:offset];
    VKAudio* song = self.playSequence[nextSongIdx];
    NSInteger tmp = [self.songsList indexOfObject:song];
    NSIndexPath *indexPath= [NSIndexPath indexPathForItem:tmp inSection:0];
    [self.songsTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [self setNowPlayingLabelsValue:song];
    [self prepareForPlayback:song];
    [[AudioPlayerController instance] play:true];
    self.lastPlayedSong = song;
    [self.btnPlayPause setImage:self.imgPause forState:UIControlStateNormal];
}

- (NSInteger)getNextSongIdx:(NSInteger) offset {
    NSInteger lastPlayedIdx = [self.playSequence indexOfObject:self.lastPlayedSong];
    if((lastPlayedIdx + offset) == [self.playSequence count] || (lastPlayedIdx + offset) < 0){
        return 0;
    }else{
        return lastPlayedIdx + offset;
    }
}

#pragma mark utilities

+ (NSString*)formatTime:(NSInteger)time {
    return [NSString stringWithFormat:@"%u:%02u", (time / 60) % 60, time % 60];
}
@end
