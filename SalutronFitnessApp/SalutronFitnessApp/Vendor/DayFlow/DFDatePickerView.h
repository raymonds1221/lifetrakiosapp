#import <UIKit/UIKit.h>

@interface DFDatePickerView : UIView

- (instancetype) initWithCalendar:(NSCalendar *)calendar;

@property (nonatomic, readwrite, strong) NSDate *selectedDate;

/** Added property for selected index path -- JB */
@property (nonatomic, readwrite, strong) NSIndexPath *selectedIndexPath;

/** Added data container property -- JB */
@property (nonatomic, readwrite, strong) NSArray *datesWithData;

- (void) reload;
- (void) centerCollectionView;
- (void) scrollCollectionViewToSelectedDate;

@end
