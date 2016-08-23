#ifndef GOOGLE_PLAY_GAMES_H
#define GOOGLE_PLAY_GAMES_H
#import <CoreFoundation/CoreFoundation.h>

namespace GooglePlayGamesExtension 
{	
    //User
    void init(bool cloudStorage, const char* clientID);
	void login();
    bool setScore(const char* id, int high_score, int low_score);
	bool displayScoreboard(const char* id);
    bool displayAllScoreboards();
    // static GooglePlayGames getInstance();
    
    void onSignInFailed();
    void onSignInSucceded();
    void onSignInStart();
    
    bool unlock(const char* id);
    bool reveal(const char* id);
    bool increment(const char* id, int step);
    bool setSteps(const char* id, int steps);
    bool displayAchievements();

    bool getPlayerID();
    bool getPlayerDisplayName();
    void getPlayerImage(const char* playerId);

    bool getPlayerScore(const char* scoreboardId);

    bool loadInvitablePlayers(bool clearCache);
    bool loadConnectedPlayers(bool clearCache);
    bool loadAllPlayers(bool getConnectedPlayers, bool clearCache, int resultsCount);
    bool getAchievementStatus(const char* achievementId);
    bool getCurrentAchievementSteps(const char* achievementId);

    void openGame(const char* name);
    void displaySavedGames(const char* title, bool allowAddButton, bool allowDelete, int maxNumberOfSavedGamesToShow);
    void loadSavedGame(const char* savedName);
    bool discardAndCloseGame();
    bool commitAndCloseGame();

    char* md5(const char* input);
    
    //Other
    // void registerForAuthenticationNotification();
}


#endif
