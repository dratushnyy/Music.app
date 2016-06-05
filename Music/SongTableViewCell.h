//
//  SongTableViewCell.h
//  Music
//
//  Created by Dmitry Ratushnyy on 26/11/15.
//
#import <UIKit/UIKit.h>
#import <VKSdk/VKSdk.h>

@class VkSongsViewController;

@interface SongTableViewCell : UITableViewCell
    @property(weak, nonatomic)  IBOutlet UILabel *duration;
    @property(weak, nonatomic)  IBOutlet UILabel *title;
    @property(weak, nonatomic)  IBOutlet UILabel *subTitle;
@end
