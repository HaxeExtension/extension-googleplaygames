package com.gpgex;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.app.Activity;
import org.haxe.extension.Extension;

import com.google.android.gms.games.Games;
import com.google.android.gms.games.Player;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.ConnectionResult;

public class GooglePlayGames extends Extension implements GameHelper.GameHelperListener {
	
	private static GooglePlayGames instance=null;
	private static GameHelper mHelper=null;
	public static final String TAG = "OPENFL-GPG";
	private static boolean userRequiresLogin=false;

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static void init(){
		if(mHelper!=null){
			if(!mHelper.isConnecting()) return;
			mHelper=null;
		}
		mainActivity.runOnUiThread(new Runnable() {
            public void run() { 
				mHelper = new GameHelper(mainActivity, GameHelper.CLIENT_GAMES);
				mHelper.enableDebugLog(true);
				mHelper.setup(GooglePlayGames.getInstance());
				mHelper.setMaxAutoSignInAttempts(userRequiresLogin?1:0);
				mHelper.onStart(mainActivity);
				userRequiresLogin=false;
				Log.i(TAG, "PlayGames: INIT COMPLETE");
            }
        });
	}	

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static void login(){
		Log.i(TAG, "PlayGames: Forcing Login");
		userRequiresLogin=true;
		mHelper=null;
		init();
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static boolean setScore(String id, int score){
		try {
			Games.Leaderboards.submitScore(mHelper.mGoogleApiClient, id, score);
        } catch (Exception e) {
			Log.i(TAG, "PlayGames: setScore Exception");
			Log.i(TAG, e.toString());
			return false;
		}
    	Log.i(TAG, "PlayGames: setScore complete");
    	return true;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static void displayScoreBoard(String id){
		try {
			mainActivity.startActivityForResult(Games.Leaderboards.getLeaderboardIntent(mHelper.mGoogleApiClient, id), 0);
		} catch (Exception e) {
			// Try connecting again
			Log.i(TAG, "PlayGames: displayScoreBoard Exception");
			Log.i(TAG, e.toString());
			login();
		}
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static GooglePlayGames getInstance(){
		if(instance==null) instance=new GooglePlayGames();
		return instance;
	}

	@Override
    public void onSignInFailed() {
        Log.i(TAG, "PlayGames: onSignInFailed");
    }

    @Override
    public void onSignInSucceeded() {
        Log.i(TAG, "PlayGames: onSignInSucceeded");
    }

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////
}
