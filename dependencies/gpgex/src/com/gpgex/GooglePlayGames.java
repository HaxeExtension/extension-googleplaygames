package com.gpgex;

import android.content.Context;
import android.os.Bundle;
//import android.support.v4.app.Fragment;
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

	public static GooglePlayGames getInstance(){
		if(instance==null) instance=new GooglePlayGames();
		return instance;
	}

	public static void init(){
		if(mHelper!=null){
			if(!mHelper.isConnecting()) return;
			mHelper=null;
		}

		mainActivity.runOnUiThread(new Runnable() {
            public void run() { 
		        Log.i(TAG, "PlayGames: INIT CALL");
				mHelper = new GameHelper(mainActivity, GameHelper.CLIENT_GAMES);
				mHelper.enableDebugLog(true);
				mHelper.setup(GooglePlayGames.getInstance());
				mHelper.setMaxAutoSignInAttempts(3);
				mHelper.onStart(mainActivity);
				Log.i(TAG, "PlayGames: INIT COMPLETE");
            }
        });
	}	

	public static void connect(){
        Log.i(TAG, "PlayGames: CONNECT begin");
		if(mHelper.isSignedIn()){
	        Log.i(TAG, "PlayGames: - CONNECT - Doing nothing... Already SignedIn");
			return;
		}
		if(mHelper.isConnecting()){
	        Log.i(TAG, "PlayGames: - CONNECT - Doing nothing... Still connecting");
			return;
		}
	    mHelper.beginUserInitiatedSignIn();
        Log.i(TAG, "PlayGames: CONNECT complete");
     }

	public static void setScore(String id, Integer score){
		if(mHelper==null){
	        Log.i(TAG, "PlayGames: useLeaderBoard - YOU MUST CALL INIT FIRST!");
			return;
		}
		if(mHelper.isConnecting()){
	        Log.i(TAG, "PlayGames: useLeaderBoard - WAIT... Still connecting!");
			return;
		}
		if(!mHelper.isSignedIn()){
	        Log.i(TAG, "PlayGames: useLeaderBoard - Not signed in!");
	        connect();
			return;
		}
        Log.i(TAG, "PlayGames: useLeaderBoard begin!");
		Games.Leaderboards.submitScore(mHelper.mGoogleApiClient, id, score);
        Log.i(TAG, "PlayGames: useLeaderBoard complete");
	}

	public static void displayScoreBoard(String id){
		try {
			mainActivity.startActivityForResult(Games.Leaderboards.getLeaderboardIntent(mHelper.mGoogleApiClient, id), 0);
		} catch (Exception e) {
			// Try connecting again
			Log.i(TAG, "PlayGames: displayScoreBoard Exception");
			Log.i(TAG, e.toString());
			mHelper=null;
			init();
		}
	}

	@Override
    public void onSignInFailed() {
        Log.i(TAG, "PlayGames: onSignInFailed");
    }

    @Override
    public void onSignInSucceeded() {
        Log.i(TAG, "PlayGames: onSignInSucceeded");
    }

}
