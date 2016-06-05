//
//  AudioPlayerController.m
//  Music
//
//  Created by Dmitry Ratushnyy on 04/01/16.
//

#import "AudioPlayerController.h"

@implementation AudioPlayerController

+ (AudioPlayerController *) instance {
    static AudioPlayerController *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[AudioPlayerController alloc] init];
    });
    return instance;
}

- (id) init {
    self = [super init];
    self.playing = false;

    return self;
}

- (void) play:(bool)play {
    self.playing = play;
    if(!self.playing){
        [self.player pause];
    }else{
        [self.player play];
    }

}

- (void) setAudioSession {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)initPlayerWith:(NSString *)url
{
    NSURL* audioUrl = [NSURL URLWithString:url];
    if(self.player){
        [self.player removeObserver:self forKeyPath:@"status"];
        [self.player removeTimeObserver:self.playerTimeObserver];
        self.playerReady = false;
    }
    self.player = [[AVPlayer alloc] initWithURL:audioUrl];
    [self.player addObserver:self forKeyPath:@"status" options:0 context:nil];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if (object == self.player && [keyPath isEqualToString:@"status"]) {
        if (self.player.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
            self.playerReady = false;
            
        } else if (self.player.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            self.playerReady = true;

        } else if (self.player.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
            
        }
    }
}
@end
