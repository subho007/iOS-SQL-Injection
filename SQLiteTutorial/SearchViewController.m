//
//  SearchViewController.m
//  SQLiteTutorial
//
//  Created by Jenn on 5/7/13.
//  Copyright (c) 2013 Jenn. All rights reserved.
//

#import "SearchViewController.h"
#import <sqlite3.h>

@interface SearchViewController () <UITextFieldDelegate>
@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *myDatabase;
@property (strong, nonatomic) NSMutableArray *searchResult;
@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *courseTextField;
@property (strong, nonatomic) IBOutlet UITextField *yearTextField;

@end

@implementation SearchViewController
@synthesize databasePath;
@synthesize myDatabase;
@synthesize searchResult;
@synthesize firstNameTextField;
@synthesize lastNameTextField;
@synthesize courseTextField;
@synthesize yearTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Search";
    }
    return self;
}

- (NSString *)whereClause {
    NSString *where = @"";
    BOOL withWhereClause = NO;
    
    if (self.firstNameTextField.text.length > 0) {
        where = [where stringByAppendingString:[NSString stringWithFormat:@"FirstName=\"%@\"", self.firstNameTextField.text]];
        withWhereClause = YES;
    }
    if (self.lastNameTextField.text.length > 0) {
        if (withWhereClause) {
            where = [where stringByAppendingString:@" and "];
        }
        where = [where stringByAppendingString:[NSString stringWithFormat:@"LastName=\"%@\"", self.lastNameTextField.text]];
        withWhereClause = YES;
    }
    if (self.courseTextField.text.length > 0) {
        if (withWhereClause) {
            where = [where stringByAppendingString:@" and "];
        }
        where = [where stringByAppendingString:[NSString stringWithFormat:@"Course=\"%@\"", self.courseTextField.text]];
        withWhereClause = YES;
    }
    if (self.yearTextField.text.length > 0) {
        if (withWhereClause) {
            where = [where stringByAppendingString:@" and "];
        }
        where = [where stringByAppendingString:[NSString stringWithFormat:@"Year=\"%@\"", self.yearTextField.text]];
    }
    
    NSLog(@"where clause: %@", where);
    return where;
}

- (IBAction)findStudent:(id)sender {
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc]
                    initWithString: [docsDir stringByAppendingPathComponent:
                                     @"sampleDatabase.db"]];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &myDatabase) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT * FROM SAMPLETABLE WHERE %@", [self whereClause]];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(myDatabase, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            [searchResult removeAllObjects];
            while (sqlite3_step(statement) == SQLITE_ROW) {
                //NSString *personID = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                NSString *firstName = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)];
                NSString *lastName = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)];
                NSString *course = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                NSString *year = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)];
                
                [searchResult addObject:[NSString stringWithFormat:@"%@ %@ %@-%@", firstName, lastName, course, year]];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(myDatabase);
    }
    _outputText.text = [searchResult componentsJoinedByString:@"\n"];
    
    //For Checking
    for (int i = 0; i < [searchResult count]; i++) {
        NSLog(@"Result: %@", [searchResult objectAtIndex:i]);
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    searchResult = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textfield {
    [textfield resignFirstResponder];
    return NO;
}

@end
