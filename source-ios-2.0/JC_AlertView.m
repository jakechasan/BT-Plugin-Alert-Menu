/*
 *	Copyright 2013, Jake Chasan, jakechasan.com
 *
 *	All rights reserved.
 *
 *	Redistribution and use in source and binary forms, with or without modification, are
 *	permitted provided that the following conditions are met:
 *
 *	Redistributions of source code must retain the above copyright notice which includes the
 *	name(s) of the copyright holders. It must also retain this list of conditions and the
 *	following disclaimer.
 *
 *	Redistributions in binary form must reproduce the above copyright notice, this list
 *	of conditions and the following disclaimer in the documentation and/or other materials
 *	provided with the distribution.
 *
 *	Neither the name of Jake Chasan, jakechasan.com nor the names of its contributors
 *	may be used to endorse or promote products derived from this software without specific
 *	prior written permission.
 *
 *	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *	IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 *	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *	NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *	PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 *	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 *	OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JSON.h"
#import "BT_application.h"
#import "BT_strings.h"
#import "BT_viewUtilities.h"
#import "BT_appDelegate.h"
#import "BT_item.h"
#import "BT_debugger.h"
#import "BT_viewControllerManager.h"
#import "BT_fileManager.h"
#import "BT_color.h"
#import "BT_downloader.h"
#import "JC_AlertView.h"



@implementation JC_AlertView

//viewDidLoad
-(void)viewDidLoad {
	[BT_debugger showIt:self theMessage:@"viewDidLoad"];
	[super viewDidLoad];
    
	//show alert...
    [self performSelector:(@selector(launchAlert)) withObject:nil afterDelay:0.1];
    
}

//view will appear
-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[BT_debugger showIt:self theMessage:@"viewWillAppear"];
	
    
    //flag this as the current screen
	BT_appDelegate *appDelegate = (BT_appDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.rootApp.currentScreenData = self.screenData;
	
	//setup navigation bar and background
	[BT_viewUtilities configureBackgroundAndNavBar:self theScreenData:[self screenData]];
    
    
}


-(void)launchAlert{
	[BT_debugger showIt:self theMessage:@"launchAlert"];

    //Title - alertTitle
    self.alertTitle =  [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"alertTitle" defaultValue:@""];
    [BT_debugger showIt:self theMessage:self.alertTitle];
    
    
    //Message - alertMessage
    self.alertMessage =  [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"alertMessage" defaultValue:@""];
    [BT_debugger showIt:self theMessage:self.alertMessage];
    
    //Create an array of buttons for each button that has a title, plus a CANCEL button.
    NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
    
    //button 1
    self.button1Title =  [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button1Title" defaultValue:@""];
    if([self.button1Title length] > 0){
        [buttonsArray addObject:self.button1Title];
    }

    
    //button 2
    self.button2Title =  [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button2Title" defaultValue:@""];
    if([self.button2Title length] > 0){
        [buttonsArray addObject:self.button2Title];
    }
    
    //button 3
    self.button3Title =  [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button3Title" defaultValue:@""];
    if([self.button3Title length] > 0){
        [buttonsArray addObject:self.button3Title];
    }

    //button 4
    self.button4Title =  [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button4Title" defaultValue:@""];
    if([self.button4Title length] > 0){
        [buttonsArray addObject:self.button4Title];
    }
    
    //create action sheet with title and message...
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:self.alertTitle
                                                            message:self.alertMessage
                                                            delegate:self
                                                            cancelButtonTitle:nil
                                                            otherButtonTitles:nil];
    //add each button...
    for (int i = 0; i < [buttonsArray count]; i++){
        [alertView addButtonWithTitle:[buttonsArray objectAtIndex:i]];
    }
    
    [alertView addButtonWithTitle:@"Cancel"];
    alertView.cancelButtonIndex = [buttonsArray count];
    

    //show the alert...
    [alertView show];
    [buttonsArray release];
    
}




- (void)viewDidAppear:(BOOL)animated{
    [self.navigationController popViewControllerAnimated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"Button - Title: %@", title]];

    //remember that this showed already!!!
    [BT_strings setPrefString:@"alertDidShow" valueOfPref:@"yes"];
    
    
    //appDelegate
    BT_appDelegate *appDelegate = (BT_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //get possible itemId of the screen to load
    NSString *loadScreenItemId = @"";
    
    //get possible nickname of the screen to load
    NSString *loadScreenNickname = @"";
    
    //get possible transition type for screen to load
    NSString *transitionType = @"";
    
    //possible screen to load...
    BT_item *screenObjectToLoad = nil;
    
    //what button was selected...
    if([title isEqualToString:self.button1Title]){
    
        loadScreenItemId = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"button1Id" defaultValue:@""];
        loadScreenNickname = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"button1Nickname" defaultValue:@""];
        transitionType = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"button1TransitionType" defaultValue:@"fade"];
    
    }else if([title isEqualToString:self.button2Title]){
        
        loadScreenItemId = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"button2Id" defaultValue:@""];
        loadScreenNickname = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"button2Nickname" defaultValue:@""];
        transitionType = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"button2TransitionType" defaultValue:@"fade"];
        
    }else if([title isEqualToString:self.button3Title]){
        
        loadScreenItemId = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"button3Id" defaultValue:@""];
        loadScreenNickname = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"button3Nickname" defaultValue:@""];
        transitionType = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"button3TransitionType" defaultValue:@"fade"];

    }else if([title isEqualToString:self.button4Title]){
        
        loadScreenItemId = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"button4Id" defaultValue:@""];
        loadScreenNickname = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"button4Nickname" defaultValue:@""];
        transitionType = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"button4TransitionType" defaultValue:@"fade"];

    }
    
    //bail if load screen = "none"
    if([loadScreenItemId isEqualToString:@"none"]){
        return;
    }
    

    //did we find a load screen itemId?
    if([loadScreenItemId length] > 1){
        screenObjectToLoad = [appDelegate.rootApp getScreenDataByItemId:loadScreenItemId];
    }else{
        if([loadScreenNickname length] > 1){
            screenObjectToLoad = [appDelegate.rootApp getScreenDataByNickname:loadScreenNickname];
        }else{
        }
    }
    
    //load next screen if it's not nil
    if(screenObjectToLoad != nil){
        
        //build a temp menu-item to pass to screen load method. We need this because the transition type is in the menu-item
        BT_item *tmpMenuItem = [[BT_item alloc] init];
        
        //build an NSDictionary of values for the jsonVars for the menu item...
        NSDictionary *tmpDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"unused", @"itemId",
                                       transitionType, @"transitionType",
                                       nil];
        
        [tmpMenuItem setJsonVars:tmpDictionary];
        [tmpMenuItem setItemId:@"0"];
        
        //load the next screen
        [BT_viewControllerManager handleTapToLoadScreen:[self screenData] theMenuItemData:tmpMenuItem theScreenData:screenObjectToLoad];
        [tmpMenuItem release];
        
    }
    
    //should not ever get here unless a button didn't have a load screen...
    return;

}




//dealloc
-(void)dealloc {
    [super dealloc];
    
}

@end





