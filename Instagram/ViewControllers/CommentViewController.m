//
//  CommentViewController.m
//  Instagram
//
//  Created by Anna Thomas on 7/9/21.
//

#import "CommentViewController.h"
#import <UIKit/UIKit.h>
#import "Post.h"
#import <Parse/ParseUIConstants.h>
#import <Parse/PFInstallation.h>
#import <Parse/Parse.h>
#import <Parse/PFImageView.h>
#import "ProfileViewController.h"
#import "CommentCell.h"

@interface CommentViewController () <UITableViewDataSource, UITableViewDelegate> 
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *comments;

 
@end

@implementation CommentViewController

- (IBAction)didTapPost:(id)sender {
    
    Post *current = self.post;
    
    if(current[@"comments"] == nil) {
        NSMutableArray *arr = [NSMutableArray arrayWithObjects:self.commentTextField.text, nil];
        current[@"comments"] = arr;
    } else {
        NSMutableArray *commentArray = current[@"comments"];
        [commentArray insertObject:self.commentTextField.text atIndex:0];
    } 
    
    [current saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error!= nil) {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    [self.tableView reloadData];
}
    

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFUser *user = [PFUser currentUser];
    if(user[@"image"]) {
        PFFileObject *picFile =user[@"image"];
        [picFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if(error==nil) {
                self.profileImage.image = [UIImage imageWithData:data];
            }
        }];
    
    }
      
}
    
    
//gets the comment array 
- (void)getData {
     
        // construct PFQuery
        PFQuery *postQuery = [Post query];
        [postQuery orderByDescending:@"createdAt"];
        [postQuery includeKey:@"comments"];
        postQuery.limit = 10;

        // fetch data asynchronously
        [postQuery findObjectsInBackgroundWithBlock:^(NSArray<NSString *> * _Nullable comments, NSError * _Nullable error) {
            if (comments) {
                NSMutableArray* commentsMutableArray = [comments mutableCopy];
                self.comments = commentsMutableArray;
                [self.tableView reloadData];
            }
            else {
                NSLog(@"%@", error.localizedDescription);
                NSLog(@"%@", @"CANNOT GET STUFF");
            }
        }];
}

//set how many rows in timeline display
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

//enables custom cell displays
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSString *comment = self.comments[indexPath.row];
    
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    cell.commentLabel.text = comment;
    
    cell.profileImage.layer.cornerRadius = 20;
    cell.profileImage.clipsToBounds = YES;
    
    PFUser *user = [PFUser currentUser];
    if(user[@"image"]) {
        PFFileObject *picFile =user[@"image"];
        [picFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if(error==nil) {
                cell.profileImage.image = [UIImage imageWithData:data];
            }
        }];
    
    }
      
    return cell;
}

/*
#pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little prep
 @end
 aration before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
