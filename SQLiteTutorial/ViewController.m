//
//  ViewController.m
//  SQLiteTutorial
//
//  Created by Jenn on 5/2/13.
//  Copyright (c) 2013 Jenn. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>

@interface ViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *myDatabase;
@property (strong, nonatomic) NSString *statusOfAddingToDB;

@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *courseTextField;
@property (strong, nonatomic) IBOutlet UITextField *yearTextField;

@end

@implementation ViewController

@synthesize firstNameTextField;
@synthesize lastNameTextField;
@synthesize courseTextField;
@synthesize yearTextField;
@synthesize databasePath;
@synthesize myDatabase;
@synthesize statusOfAddingToDB;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Add To DB";
    [self prepareDatabase];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addTextToDatabase:(id)sender
{
    sqlite3_stmt    *statement;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &myDatabase) == SQLITE_OK) {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO SAMPLETABLE (FirstName, LastName, Course, Year) VALUES (\"%@\", \"%@\", \"%@\", \"%@\")",
                               self.firstNameTextField.text, self.lastNameTextField.text, self.courseTextField.text, self.yearTextField.text];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(myDatabase, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            statusOfAddingToDB = [NSString stringWithFormat:@"Text added - %@ %@ %@ %@", self.firstNameTextField.text, self.lastNameTextField.text, self.courseTextField.text, self.yearTextField.text];
        } else {
            statusOfAddingToDB = @"Failed to add contact";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DB Status" message:statusOfAddingToDB delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        sqlite3_finalize(statement);
        sqlite3_close(myDatabase);
    }
}

- (void)prepareDatabase
{
    // Get the documents directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"sampleDatabase.db"]];
    NSLog(@"DB Path: %@", databasePath);
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO) {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &myDatabase) == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS SAMPLETABLE (ID INTEGER PRIMARY KEY AUTOINCREMENT, FirstName TEXT, LastName TEXT, Course TEXT, Year INT)";
            
            if (sqlite3_exec(myDatabase, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                statusOfAddingToDB = @"Failed to create table";
                
            } else {
                statusOfAddingToDB = @"Success in creating table";
                
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DB Status" message:statusOfAddingToDB delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            sqlite3_close(myDatabase);
        } else {
            statusOfAddingToDB = @"Failed to open/create database";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DB Status" message:statusOfAddingToDB delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textfield {
    [textfield resignFirstResponder];
    return NO;
}

@end
