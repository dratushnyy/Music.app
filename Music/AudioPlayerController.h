//
//  AudioPlayerController.h
//  Music
//
//  Created by Dmitry Ratushnyy on 04/01/16.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayerController : NSObject

@property(nonatomic) bool playing;
@property(nonatomic) AVPlayer* player;
@property(nonatomic) id playerTimeObserver;

@property(nonatomic) bool playerReady;

+ (AudioPlayerController *)instance;
- (void) play:(bool) play;
- (void) initPlayerWith:(NSString*) url;
- (void) setAudioSession;
@end
