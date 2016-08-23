#include <GooglePlayGames.h>
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <GameKit/GameKit.h>
#define __STDC_FORMAT_MACROS // non needed in C, only in C++
#include <inttypes.h>
#import "gpg/GooglePlayGames.h"
#import <CommonCrypto/CommonDigest.h>

extern "C" void reportCallback2Haxe (const char* name, const char* data1, const char* data2);

void reportCallback (const char* name, const char* data1, const char* data2){
    if ([NSThread isMainThread]){
        reportCallback2Haxe(name, data1, data2);
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            reportCallback2Haxe(name, data1, data2);
        });
    }
}


@interface SnapshotInterface : NSObject<GPGSnapshotListLauncherDelegate>

	- (void) snapshotListLauncherDidCreateNewSnapshot;
	- (void) snapshotListLauncherDidTapSnapshotMetadata:(GPGSnapshotMetadata *)snapshot;


@end

@implementation SnapshotInterface

	//Called when the user selects the Create New button from the picker. 
	- (void)snapshotListLauncherDidCreateNewSnapshot {
	    NSLog(@"New snapshot selected");
	}

	// Called when the user picks a saved game. 
	- (void)snapshotListLauncherDidTapSnapshotMetadata:(GPGSnapshotMetadata *)snapshot {
	    NSLog(@"Selected snapshot metadata: %@", snapshot.snapshotDescription);

	    // Call example game code to load the given saved game. 
	    // [self.gameModel loadSnapshot: snapshot];
	}

@end

@interface StatusDelegate : NSObject<GPGStatusDelegate>

	- (void) didFinishGamesSignInWithError:(NSError *) error;
	- (void) didFinishGamesSignOutWithError:(NSError *)error;


@end

@implementation StatusDelegate

	//Called when the user selects the Create New button from the picker. 
	- (void)didFinishGamesSignInWithError:(NSError *)error {
	    NSLog(@"didFinishGamesSignInWithError: %@", [error localizedDescription]);
	}

	// Called when the user picks a saved game. 
	- (void)didFinishGamesSignOutWithError:(NSError *)error {
	    NSLog(@"didFinishGamesSignOutWithError: %@", [error localizedDescription]);

	    // Call example game code to load the given saved game. 
	    // [self.gameModel loadSnapshot: snapshot];
	}

@end


namespace GooglePlayGamesExtension {
	
	// static GooglePlayGames instance=null;
	// GameHelper mHelper=null;
	const char* TAG = "EXTENSION-GOOGLEPLAYGAMES";
	NSString *kClientID = NULL;
	bool userRequiresLogin=false;
	bool enableCloudStorage=false;
	SnapshotInterface *snapshotInterface;
	
	//---

	
	//USER

	void init(bool cloudStorage, const char* clientID){
		enableCloudStorage = cloudStorage;
		NSLog(@"init!!!");
		kClientID = [[NSString alloc] initWithUTF8String:clientID];
		snapshotInterface = [[SnapshotInterface alloc] init];
		[GPGManager sharedInstance].statusDelegate = [[StatusDelegate alloc] init];
		[GPGLauncherController sharedInstance].snapshotListLauncherDelegate = (id<GPGSnapshotListLauncherDelegate>) snapshotInterface;
		NSLog(@"antes del report callback");
		reportCallback("init", "data1", "data2");
	}

	void login(){
		NSLog(@"antes de signInWithClientID");
		[[GPGManager sharedInstance] signInWithClientID:kClientID silently:YES];
		NSLog(@"despues de signInWithClientID");
	}
	
	/*static bool setScore(const char* leaderboardId, int high_score, int low_score){
		long score = (((long)high_score << 32) | ((long)low_score & 0xFFFFFFFF));
		GPGScore *newScore = [[GPGScore alloc] initWithLeaderboardId:[NSString stringWithUTF8String:leaderboardId]];
		newScore.value = score;

		[newScore submitScoreWithCompletionHandler: ^(GPGScoreReport *report, NSError *error) {
			if (error) {
			    NSLog(@"ERROR: Unable to post Leaderboard %@ score %ld due to: %@", leaderboardId, score, error.description);
			} else {
			    NSLog(@"Score submitted successfully. %lld", report.highScoreForLocalPlayerAllTime.value);
			}
		}];
		return true;
	}

	static bool displayScoreboard(const char* scoreboardId){
		[[GPGLauncherController sharedInstance] presentLeaderboardWithLeaderboardId:[NSString stringWithUTF8String:scoreboardId]];
		return true;
	}

	static bool displayAllScoreboards(){
		[[GPGLauncherController sharedInstance] presentLeaderboardList];
		return true;
	}

	static bool unlock(const char* id){
		GPGAchievement *achievement = [GPGAchievement achievementWithId:[NSString stringWithUTF8String:id]];
		[achievement unlockAchievementWithCompletionHandler:^(BOOL  newlyUnlocked, NSError *error){
			if (error != nil) {
      			NSLog(@"error unlocking achievement %@", [error localizedDescription]);
            } else if(newlyUnlocked){
            	 NSLog(@" Achievement unlocked!");
            } else {
            	NSLog(@" Achievement already unlocked!");
            } 
		}];
		return true;
	}
	
	static bool reveal(const char* id){
		GPGAchievement *achievement = [GPGAchievement achievementWithId:[NSString stringWithUTF8String:id]];
		[achievement revealAchievementWithCompletionHandler:^(GPGAchievementState  state, NSError *error){
			if (error != nil) {
      			NSLog(@"error revealing achievement %@", [error localizedDescription]);
            } else {
            	NSLog(@" Achievement revealed!");
            } 
		}];
		return true;
	}

	static bool increment(const char* id, int step){
		GPGAchievement *achievement = [GPGAchievement achievementWithId:[NSString stringWithUTF8String:id]];
		[achievement incrementAchievementNumSteps:step completionHandler:^(BOOL currentlyUnlocked, int currentSteps, NSError *error){
			if (error != nil) {
      			NSLog(@"error setting achievement steps %@", [error localizedDescription]);
            } else {
            	NSLog(@" Achievement steps set!");
            } 
		}];
		return true;
	}

	static bool setSteps(const char* id, int steps){
		GPGAchievement *achievement = [GPGAchievement achievementWithId:[NSString stringWithUTF8String:id]];
		[achievement setSteps:steps completionHandler:^(BOOL newlyUnlocked, int currentSteps, NSError *error){
			
            if (error) {
           		NSLog(@"error incrementing achievement %@", [error localizedDescription]);
          	} else if (newlyUnlocked) {
            	NSLog(@"Incremental achievement unlocked!");
          	} else {
            	NSLog(@"User has completed %i steps total", currentSteps);
          	} 
		}];
		return true;
	}

	static bool displayAchievements(){
		// UIWindow* window = [UIApplication sharedApplication].keyWindow;
		// GPGAchievementViewController* achievements = [[[GPGAchievementViewController alloc] init] autorelease]; 
		
		// if (achievements != nil) {
			
		// 	achievements.achievementDelegate = viewDelegate;
		// 	UIViewController *glView2 = [window rootViewController];
		// 	[glView2 presentModalViewController: achievements animated: YES];
		[[GPGLauncherController sharedInstance] presentAchievementList];	
		return true;
		// } else return false;

	}

	static bool getPlayerID(){
		[GPGPlayer localPlayerWithCompletionHandler:^(GPGPlayer *player, NSError *error){
			if(error!=nil){
				NSLog(@"error loading player: %@", [error localizedDescription]);
			} else {
				if(player!=nil){
					NSString *playerId = player.playerId;
					reportCallback("onPlayerID", [playerId UTF8String], nil);	
				}
				
			}
		}];
		return true;
	}

	static bool getPlayerDisplayName(){
		[GPGPlayer localPlayerWithCompletionHandler:^(GPGPlayer *player, NSError *error){
			if(error!=nil){
				NSLog(@"error loading player: %@", [error localizedDescription]);
			} else {
				if(player!=nil){
					NSString *name = player.displayName;
					reportCallback("onPlayerDisplayName", [name UTF8String], nil);	
				}
				
			}
		}];
		return true;
	}

	static void getPlayerImage(){
		dispatch_async(dispatch_get_main_queue(), ^{
			@autoreleasepool {
            	[GPGPlayer localPlayerWithCompletionHandler:^(GPGPlayer *player, NSError *error){
					if(error!=nil){
						NSLog(@"error loading player: %@", [error localizedDescription]);
					} else {
						if(player!=nil){

							NSURL *url = [player imageUrl];
							NSString *urlString = [[player imageUrl] absoluteString];
							char* fileName =  md5([urlString UTF8String]);
							UIImage *im = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
							NSData *photoData = UIImagePNGRepresentation(im);
	            			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
							NSString *cachesFolder = paths[0];
							NSString *file = [NSString stringWithFormat:@"%@.png",  [NSString stringWithUTF8String:fileName]];
							NSString *path = [cachesFolder stringByAppendingPathComponent:file];
	            			if([photoData writeToFile:path atomically:YES]){
	            				reportCallback("onImageLoaded", [[player playerId] UTF8String], [path UTF8String]);
	            			} else {
	            				NSLog(@"error writing to file");
	            				reportCallback("onImageLoadFail", [[player playerId] UTF8String], "");
	            			}
						}
					}
				}];
			} 
        });
	}

	static bool getPlayerScore(const char* scoreboardId){
		@autoreleasepool{
			GPGLeaderboard *leaderboard = [GPGLeaderboard leaderboardWithId:[NSString stringWithUTF8String:scoreboardId]];
			[leaderboard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
				if(error!=nil){
					NSLog(@"error writing to file");
				} else if ([leaderboard localPlayerScore]!=nil){
					NSLog(@"%@", [[leaderboard localPlayerScore] scoreString]);
					reportCallback("onLocalPlayerScore", [[[leaderboard localPlayerScore] scoreString] UTF8String], "");
				}
			}];
			return true;
		}
	}

	static bool loadInvitablePlayers(bool clearCache){
		return loadAllPlayers(false, clearCache, 0);
	}

	static bool loadConnectedPlayers(bool clearCache){
		return loadAllPlayers(true, clearCache, 0);
	}

	static bool loadAllPlayers(bool getConnectedPlayers, bool clearCache, int resultsCount){
		@try{
			const int friendsPerPage = 25;

			void(^GPGPlayersGetBlock)(NSArray *players, NSError *error) = ^(NSArray *players, NSError *error){
					
				NSLog(@"loadAllFriends: onResult... ");//got " + playerBuffer.getCount());

				if (!getConnectedPlayers && [players count] >= resultsCount+friendsPerPage) {
					NSLog(@"loadAllFriends: Maybe there're more players... calling loadMoreInvitablePlayers.");
					loadAllPlayers(false, false, [players count]);
					return;
				}

				NSMutableString *friends = [NSMutableString initWithString:@""];
				for (GPGPlayer *player in players) {
					[friends appendFormat:@"%@ \1 %@ \2", [player playerId], [player displayName]];
				}
				NSLog(@"loadAllFriends: Done! Now sending serialized friends to HAXE");
				reportCallback("onLoadPlayers", [friends UTF8String], [(getConnectedPlayers)?@"YES":@"NO" UTF8String]);
			};
			[GPGPlayer connectedPlayersWithCompletionHandler:GPGPlayersGetBlock];
    	} @catch (NSException *e) {
			// Try connecting again
			NSLog(@"PlayGames: loadAllFriends Exception");
			NSLog(@"%@", [e reason]);
			return false;
		}
		return true;
	}

	static bool getAchievementStatus(const char* achievementId){
		[GPGAchievementMetadata metadataForAchievementId:[NSString stringWithUTF8String:achievementId] completionHandler:^(GPGAchievementMetadata *metadata, NSError *error){
			if(error!=nil){
				NSLog(@"Error getting achievement status");
				return;
			}
			if(metadata!=nil){
				if([metadata state] == GPGAchievementStateUnlocked) reportCallback("onGetAchievementStatus", achievementId, "1");
				else reportCallback("onGetAchievementStatus", achievementId, "0");
			}
		}];
		return true;
	}

	static bool getCurrentAchievementSteps(const char* achievementId){
		[GPGAchievementMetadata metadataForAchievementId:[NSString stringWithUTF8String:achievementId] completionHandler:^(GPGAchievementMetadata *metadata, NSError *error){
			if(error!=nil){
				NSLog(@"Error getting achievement status");
				return;
			}
			if(metadata!=nil){
				int steps = [metadata completedSteps];
				reportCallback("onGetCurrentAchievementSteps", achievementId, [[NSString stringWithFormat:@"%@", steps] UTF8String]);
			}
		}];
		return true;
	}

	static void openGame(const char* name){

	}

	static void displaySavedGames(const char* title, bool allowAddButton, bool allowDelete, int maxNumberOfSavedGamesToShow){
		[[GPGLauncherController sharedInstance] presentSnapshotList];
	}

	static void loadSavedGame(const char* savedName){

	}

	static bool discardAndCloseGame(){
		return false;
	}

	static bool commitAndCloseGame(){
		return false;
	}

	static char* md5(char* input){
		unsigned char digest[16];
		CC_MD5( input, strlen(input), digest ); // This is the md5 call
		 
		NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
		 
		for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x", digest[i]];
 
 		return  (char *)[output UTF8String];
	} 
	
// UIImage *im = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
	
	*/
	
}