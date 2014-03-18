package com.gcmex;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.app.Activity;

import com.google.android.gms.games.Games;
import com.google.android.gms.games.Player;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.ConnectionResult;

public class PlayGames implements GameHelper.GameHelperListener {
	
	private static PlayGames instance=null;
	private static Activity mActivity=null;
	private static GameHelper mHelper=null;

	public static PlayGames getInstance(){
		if(instance==null) instance=new PlayGames();
		return instance;
	}

	public void init(Activity mainActivity){
		if(mHelper!=null){
			if(!mHelper.isConnecting()) return;
			mHelper=null;
		}

		mActivity=mainActivity;
		mActivity.runOnUiThread(new Runnable() {
            public void run() { 
		        Log.i(GCM.TAG, "PlayGames: INIT CALL");
				mHelper = new GameHelper(mActivity, GameHelper.CLIENT_GAMES);
				mHelper.enableDebugLog(true);
				mHelper.setup(PlayGames.getInstance());
				mHelper.setMaxAutoSignInAttempts(3);
				mHelper.onStart(mActivity);
				Log.i(GCM.TAG, "PlayGames: INIT COMPLETE");
            }
        });
	}	

	public void connect(){
        Log.i(GCM.TAG, "PlayGames: CONNECT begin");
		if(mHelper.isSignedIn()){
	        Log.i(GCM.TAG, "PlayGames: - CONNECT - Doing nothing... Already SignedIn");
			return;
		}
		if(mHelper.isConnecting()){
	        Log.i(GCM.TAG, "PlayGames: - CONNECT - Doing nothing... Still connecting");
			return;
		}
	    mHelper.beginUserInitiatedSignIn();
        Log.i(GCM.TAG, "PlayGames: CONNECT complete");
     }

	public void useLeaderBoard(){
		if(mHelper==null){
	        Log.i(GCM.TAG, "PlayGames: useLeaderBoard - YOU MUST CALL INIT FIRST!");
			return;
		}
		if(mHelper.isConnecting()){
	        Log.i(GCM.TAG, "PlayGames: useLeaderBoard - WAIT... Still connecting!");
			return;
		}
		if(!mHelper.isSignedIn()){
	        Log.i(GCM.TAG, "PlayGames: useLeaderBoard - Not signed in!");
	        connect();
			return;
		}
        Log.i(GCM.TAG, "PlayGames: useLeaderBoard begin!");
//		Games.Leaderboards.submitScore(mHelper.mGoogleApiClient, "CgkIuqzAj8EdEAIQAQ", 12);
        displayLeaderBoard("CgkIuqzAj8EdEAIQAQ");
        Log.i(GCM.TAG, "PlayGames: useLeaderBoard complete");
	}

	public void displayLeaderBoard(String id){
		try {
			mActivity.startActivityForResult(Games.Leaderboards.getLeaderboardIntent(mHelper.mGoogleApiClient, id), 0);
		} catch (Exception e) {
			// Try connecting again
			Log.i(GCM.TAG, "PlayGames: displayLeaderBoard Exception ");
			Log.i(GCM.TAG, e.toString());//.getMessage());
			mHelper=null;
			this.init(mActivity);
		}
	}

	@Override
    public void onSignInFailed() {
        Log.i(GCM.TAG, "PlayGames: onSignInFailed");
    }

    @Override
    public void onSignInSucceeded() {
        Log.i(GCM.TAG, "PlayGames: onSignInSucceeded");
    }

}
