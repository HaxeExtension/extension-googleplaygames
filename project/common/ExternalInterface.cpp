#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include <stdio.h>
#include <hxcpp.h>
#include "GooglePlayGames.h"


using namespace GooglePlayGamesExtension;


AutoGCRoot* callbackHandle = 0;


static value googleplaygames_init(value cloud_storage, value callback, value clientID)
{
	#ifdef IPHONE
	callbackHandle = new AutoGCRoot(callback);
	init(val_bool(cloud_storage),val_string(clientID));
	#endif
	return alloc_null();
}
DEFINE_PRIM(googleplaygames_init, 3);

static value googleplaygames_login()
{
	#ifdef IPHONE
	login();
	#endif
	return alloc_null();
}
DEFINE_PRIM(googleplaygames_login, 0);

/*
static value googleplaygames_set_score(value id, value high_score, value low_score) 
{
	#ifdef IPHONE
	return alloc_bool(setScore(val_string(id), val_int(high_score), val_int(low_score)));
	#else
	return alloc_bool(false);
	#endif
}
DEFINE_PRIM (googleplaygames_set_score, 3);


static value googleplaygames_display_scoreboard(value id) 
{
	#ifdef IPHONE
	return alloc_bool(displayScoreboard(val_string(id)));
	#else
	return alloc_bool(false);
	#endif
}
DEFINE_PRIM (googleplaygames_display_scoreboard, 1);


static value googleplaygames_display_all_scoreboards()
{
	#ifdef IPHONE
	return alloc_bool(displayAllScoreboards());
	#else
	return alloc_bool(false);
	#endif
}
DEFINE_PRIM(googleplaygames_display_all_scoreboards, 0);


static value googleplaygames_unlock(value id)
{
	#ifdef IPHONE
	return alloc_bool(unlock(val_string(id)));
	#else
	return alloc_bool(false);
	#endif
}
DEFINE_PRIM(googleplaygames_unlock, 1);


static value googleplaygames_reveal(value id)
{
	#ifdef IPHONE
	return alloc_bool(reveal(val_string(id)));
	#else
	return alloc_bool(false);
	#endif
}
DEFINE_PRIM(googleplaygames_reveal, 1);


static value googleplaygames_increment(value id, value step)
{
	#ifdef IPHONE
	return alloc_bool(increment(val_string(id), val_int(step)));
	#else
	return alloc_bool(false);
	#endif
}
DEFINE_PRIM(googleplaygames_increment, 2);

static value googleplaygames_set_steps(value id, value steps)
{
	#ifdef IPHONE
	return alloc_bool(setSteps(val_string(id), val_int(steps)));
	#endif
	return alloc_bool(false);
}
DEFINE_PRIM(googleplaygames_set_steps, 2);

static value googleplaygames_display_achievements()
{
	#ifdef IPHONE
	return alloc_bool(displayAchievements());
	#endif
	return alloc_bool(false);
}
DEFINE_PRIM(googleplaygames_display_achievements, 0);


static value googleplaygames_get_player_id()
{
	#ifdef IPHONE
	return alloc_bool(getPlayerID());
	#endif
	return alloc_bool(false);
}
DEFINE_PRIM(googleplaygames_get_player_id, 0);


static value googleplaygames_get_player_display_name()
{
	#ifdef IPHONE
	alloc_bool(getPlayerDisplayName());
	#endif
	return alloc_bool(false);
}
DEFINE_PRIM(googleplaygames_get_player_display_name, 0);


static value googleplaygames_get_player_image(value playerID)
{
	#ifdef IPHONE
	getPlayerImage(val_string(playerID));
	#endif
	return alloc_null();
}
DEFINE_PRIM(googleplaygames_get_player_image, 1);


static value googleplaygames_get_player_score(value scoreboardID)
{
	#ifdef IPHONE
	return alloc_bool(getPlayerScore(val_string(scoreboardID)));
	#endif
	return alloc_bool(false);
}
DEFINE_PRIM(googleplaygames_get_player_score, 1);


static value googleplaygames_load_invitable_players(value clearCache)
{
	#ifdef IPHONE
	return alloc_bool(loadInvitablePlayers(val_bool(clearCache)));
	#endif
	return alloc_bool(false);
}
DEFINE_PRIM(googleplaygames_load_invitable_players, 1);


static value googleplaygames_load_connected_players(value clearCache)
{
	#ifdef IPHONE
	return alloc_bool(loadConnectedPlayers(val_bool(clearCache)));
	#endif
	return alloc_bool(false);
}
DEFINE_PRIM(googleplaygames_load_connected_players, 1);


static value googleplaygames_load_all_players(value getConnectedPlayers, value clearCache, value resultsCount)
{
	#ifdef IPHONE
	return alloc_bool(loadAllPlayers(val_bool(getConnectedPlayers), val_bool(clearCache), val_int(resultsCount)));
	#endif
	return alloc_bool(false);
}
DEFINE_PRIM(googleplaygames_load_all_players, 3);

static value googleplaygames_get_achievement_status(value achievementID)
{
	#ifdef IPHONE
	return alloc_bool(getAchievementStatus(val_string(achievementID)));
	#endif
	return alloc_bool(false);
}
DEFINE_PRIM(googleplaygames_get_achievement_status, 1);


static value googleplaygames_get_current_achievement_steps(value achievementID)
{
	#ifdef IPHONE
	return alloc_bool(getCurrentAchievementSteps(val_string(achievementID)));
	#endif
	return alloc_bool(false);
}
DEFINE_PRIM(googleplaygames_get_current_achievement_steps, 1);


static value googleplaygames_open_game(value name)
{
	#ifdef IPHONE
	openGame(val_string(name));
	#endif
	return alloc_null();
}
DEFINE_PRIM(googleplaygames_open_game, 1);


static value googleplaygames_display_saved_games(value title, value allowAddButton, value allowDelete, value maxNumberOfSavedGamesToShow)
{
	#ifdef IPHONE
	displaySavedGames(val_string(title), val_bool(allowAddButton), val_bool(allowDelete), val_int(maxNumberOfSavedGamesToShow));
	#endif
	return alloc_null();
}
DEFINE_PRIM(googleplaygames_display_saved_games, 4);


static value googleplaygames_load_saved_game(value savedName)
{
	#ifdef IPHONE
	loadSavedGame(val_string(savedName));
	#endif
	return alloc_null();
}
DEFINE_PRIM(googleplaygames_load_saved_game, 1);


static value googleplaygames_discard_and_close_game()
{
	#ifdef IPHONE
	return alloc_bool(discardAndCloseGame());
	#endif
	return alloc_bool(false);
}
DEFINE_PRIM(googleplaygames_discard_and_close_game, 0);


static value googleplaygames_commit_and_close_game()
{
	#ifdef IPHONE
	return alloc_bool(commitAndCloseGame());
	#endif
	return alloc_bool(false);
}
DEFINE_PRIM(googleplaygames_commit_and_close_game, 0);*/


extern "C" void googleplaygames_main() 
{	
	val_int(0); // Fix Neko init
}
DEFINE_ENTRY_POINT(googleplaygames_main);



extern "C" int GooglePlayGamesExtension_register_prims() { return 0; }


extern "C" void reportCallback2Haxe(const char* name, const char* data1, const char* data2)
{
	if(callbackHandle == NULL) return;
    val_call3(callbackHandle->get(), alloc_string(name), alloc_string(data1), alloc_string(data2));
}
