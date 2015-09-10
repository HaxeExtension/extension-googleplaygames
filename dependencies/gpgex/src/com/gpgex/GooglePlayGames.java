package com.gpgex;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.app.Activity;
import org.haxe.extension.Extension;
import org.haxe.lime.HaxeObject;
import android.os.AsyncTask;
import java.io.IOException;

import com.google.android.gms.games.Games;
import com.google.android.gms.games.Player;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.appstate.AppStateManager;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.appstate.AppStateManager.StateResult;

import com.google.android.gms.games.leaderboard.Leaderboards;
import com.google.android.gms.games.leaderboard.LeaderboardVariant;
import com.google.android.gms.games.leaderboard.LeaderboardScore;
import com.google.android.gms.games.GamesStatusCodes;
import com.google.android.gms.games.achievement.Achievements;
import com.google.android.gms.games.achievement.Achievement;
import com.google.android.gms.games.snapshot.Snapshot;
import com.google.android.gms.games.snapshot.Snapshots;
import com.google.android.gms.games.snapshot.SnapshotMetadataChange;
import com.google.android.gms.games.snapshot.SnapshotMetadataChange.Builder;

public class GooglePlayGames extends Extension implements GameHelper.GameHelperListener
{

	private static GooglePlayGames instance = null;
	private static GameHelper mHelper = null;
	public static final String TAG = "OPENFL-GPG";
	private static boolean userRequiresLogin = false;
	private static HaxeObject callbackObject = null;
	private static boolean enableCloudStorage = false;

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static void init(boolean cloudStorage, HaxeObject callbackObj)
	{
		if (callbackObj != null) GooglePlayGames.callbackObject = callbackObj;
		if (mHelper != null)
		{
			if (!mHelper.isConnecting()) return;
			mHelper = null;
		}
		enableCloudStorage = cloudStorage;
		mainActivity.runOnUiThread(new Runnable()
		{
			public void run()
			{
				mHelper = new GameHelper(mainActivity, GameHelper.CLIENT_GAMES | (enableCloudStorage ? GameHelper.CLIENT_APPSTATE : 0));
				mHelper.enableDebugLog(true);
				mHelper.setup(GooglePlayGames.getInstance());
				mHelper.setMaxAutoSignInAttempts(userRequiresLogin ? 1 : 0);
				mHelper.onStart(mainActivity);
				userRequiresLogin = false;
				Log.i(TAG, "PlayGames: INIT COMPLETE");
			}
		});
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static void login()
	{
		Log.i(TAG, "PlayGames: Forcing Login");
		userRequiresLogin = true;
		mHelper = null;
		init(enableCloudStorage, null);
	}

	public static void logout()
	{
		Log.i(TAG, "PlayGames: Forcing Logout");
		if (mHelper != null) mHelper.signOut();
	}

	public static boolean isSignedIn()
	{
		if (mHelper != null) return mHelper.isSignedIn();
		return false;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static boolean setScore(String id, int high_score, int low_score)
	{
		try
		{
			long score = (((long) high_score << 32) | ((long) low_score & 0xFFFFFFFF));
			Games.Leaderboards.submitScore(mHelper.mGoogleApiClient, id, score);
		}
		catch (Exception e)
		{
			Log.i(TAG, "PlayGames: setScore Exception");
			Log.i(TAG, e.toString());
			return false;
		}
		Log.i(TAG, "PlayGames: setScore complete");
		return true;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static boolean displayScoreboard(String id)
	{
		try
		{
			mainActivity.startActivityForResult(Games.Leaderboards.getLeaderboardIntent(mHelper.mGoogleApiClient, id), 0);
		}
		catch (Exception e)
		{
			// Try connecting again
			Log.i(TAG, "PlayGames: displayScoreboard Exception");
			Log.i(TAG, e.toString());
			login();
			return false;
		}
		return true;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static boolean displayAllScoreboards()
	{
		try
		{
			mainActivity.startActivityForResult(Games.Leaderboards.getAllLeaderboardsIntent(mHelper.mGoogleApiClient), 0);
		}
		catch (Exception e)
		{
			// Try connecting again
			Log.i(TAG, "PlayGames: displayAllScoreboards Exception");
			Log.i(TAG, e.toString());
			login();
			return false;
		}
		return true;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static GooglePlayGames getInstance()
	{
		if (instance == null) instance = new GooglePlayGames();
		return instance;
	}

	@Override
	public void onSignInFailed()
	{
		callbackObject.call1("loginResultCallback", -1);
		Log.i(TAG, "PlayGames: onSignInFailed");
	}

	@Override
	public void onSignInSucceeded()
	{
		callbackObject.call1("loginResultCallback", 1);
		Log.i(TAG, "PlayGames: onSignInSucceeded");
	}

	@Override
	public void onSignInStart()
	{
		callbackObject.call1("loginResultCallback", 0);
		Log.i(TAG, "PlayGames: onSignInStart");
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static boolean cloudSet(int key, String value)
	{
		try
		{
			AppStateManager.update(mHelper.mGoogleApiClient, key, value.getBytes());
		}
		catch (Exception e)
		{
			Log.i(TAG, "PlayGames: cloudSet Exception");
			Log.i(TAG, e.toString());
			return false;
		}
		return true;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static boolean cloudGet(int key)
	{
		try
		{
			AppStateManager.load(mHelper.mGoogleApiClient, key).setResultCallback(new ResultCallback<StateResult>()
			{
				@Override
				public void onResult(StateResult result)
				{
					try
					{
						AppStateManager.StateConflictResult conflictResult = result.getConflictResult();
						AppStateManager.StateLoadedResult loadedResult = result.getLoadedResult();
						if (loadedResult != null)
						{
							String res = (loadedResult.getStatus().getStatusCode() == 0 ? new String(loadedResult.getLocalData()) : null);
							callbackObject.call2("cloudGetCallback", loadedResult.getStateKey(), res);
						}
						else if (conflictResult != null)
						{
							String server = new String(conflictResult.getServerData());
							String local = new String(conflictResult.getLocalData());
							AppStateManager.resolve(mHelper.mGoogleApiClient, conflictResult.getStateKey(), conflictResult.getResolvedVersion(), conflictResult.getServerData());
							callbackObject.call3("cloudGetConflictCallback", conflictResult.getStateKey(), local, server);
						}
					}
					catch (Exception e)
					{
						Log.i(TAG, "PlayGames: cloudGet CRITICAL Exception");
						Log.i(TAG, e.toString());
					}
				}
			});
		}
		catch (Exception e)
		{
			Log.i(TAG, "PlayGames: cloudGet Exception");
			Log.i(TAG, e.toString());
			return false;
		}
		return true;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static boolean unlock(String id)
	{
		try
		{
			Games.Achievements.unlock(mHelper.mGoogleApiClient, id);
		}
		catch (Exception e)
		{
			Log.i(TAG, "PlayGames: unlock Exception");
			Log.i(TAG, e.toString());
			return false;
		}
		return true;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static boolean reveal(String id)
	{
		try
		{
			Games.Achievements.reveal(mHelper.mGoogleApiClient, id);
		}
		catch (Exception e)
		{
			Log.i(TAG, "PlayGames: reveal Exception");
			Log.i(TAG, e.toString());
			return false;
		}
		return true;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static boolean increment(String id, int step)
	{
		try
		{
			Games.Achievements.increment(mHelper.mGoogleApiClient, id, step);
		}
		catch (Exception e)
		{
			Log.i(TAG, "PlayGames: increment Exception");
			Log.i(TAG, e.toString());
			return false;
		}
		return true;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static boolean setSteps(String id, int steps)
	{
		try
		{
			Games.Achievements.setSteps(mHelper.mGoogleApiClient, id, steps);
		}
		catch (Exception e)
		{
			Log.i(TAG, "PlayGames: setSteps Exception");
			Log.i(TAG, e.toString());
			return false;
		}
		return true;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static boolean displayAchievements()
	{
		try
		{
			mainActivity.startActivityForResult(Games.Achievements.getAchievementsIntent(mHelper.mGoogleApiClient), 0);
		}
		catch (Exception e)
		{
			// Try connecting again
			Log.i(TAG, "PlayGames: displayAchievements Exception");
			Log.i(TAG, e.toString());
			login();
			return false;
		}
		return true;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static boolean getPlayerScore(final String idScoreboard)
	{
		try
		{
			Games.Leaderboards.loadCurrentPlayerLeaderboardScore(mHelper.mGoogleApiClient, idScoreboard, LeaderboardVariant.TIME_SPAN_ALL_TIME, LeaderboardVariant.COLLECTION_PUBLIC).setResultCallback(new ResultCallback<Leaderboards.LoadPlayerScoreResult>()
			{
				@Override
				public void onResult(final Leaderboards.LoadPlayerScoreResult playerScore)
				{
					if ((playerScore != null) && (playerScore.getStatus().getStatusCode() == GamesStatusCodes.STATUS_OK) && (playerScore.getScore() != null))
					{
						long score = playerScore.getScore().getRawScore();
						int high_score = (int) (score >>> 32);
						int low_score = (int) (score & 0xFFFFFFFF);
						callbackObject.call3("onGetScoreboard", idScoreboard, high_score, low_score);
					}
				}
			});
		}
		catch (Exception e)
		{
			// Try connecting again
			Log.i(TAG, "PlayGames: displayPlayerScore Exception");
			Log.i(TAG, e.toString());
			login();
			return false;
		}
		return true;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static boolean getAchievementStatus(final String idAchievement)
	{
		try
		{
			Games.Achievements.load(mHelper.mGoogleApiClient, false).setResultCallback(new ResultCallback<Achievements.LoadAchievementsResult>()
			{
				@Override
				public void onResult(Achievements.LoadAchievementsResult loadAchievementsResult)
				{
					for (Achievement ach : loadAchievementsResult.getAchievements())
					{
						if (ach.getAchievementId().equals(idAchievement))
						{
							if (ach.getState() == Achievement.STATE_UNLOCKED) callbackObject.call2("onGetAchievementStatus", idAchievement, 1);
							else
								callbackObject.call2("onGetAchievementStatus", idAchievement, 0);
						}
					}
				}
			});
		}
		catch (Exception e)
		{
			// Try connecting again
			Log.i(TAG, "PlayGames: displayPlayerScore Exception");
			Log.i(TAG, e.toString());
			login();
			return false;
		}
		return true;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static boolean getCurrentAchievementSteps(final String idAchievement)
	{
		try
		{
			Games.Achievements.load(mHelper.mGoogleApiClient, false).setResultCallback(new ResultCallback<Achievements.LoadAchievementsResult>()
			{
				@Override
				public void onResult(Achievements.LoadAchievementsResult loadAchievementsResult)
				{
					for (Achievement ach : loadAchievementsResult.getAchievements())
					{
						if (ach.getAchievementId().equals(idAchievement))
						{
							if (ach.getType() == Achievement.TYPE_INCREMENTAL) callbackObject.call2("onGetAchievementSteps", idAchievement, ach.getCurrentSteps());
						}
					}
				}
			});
		}
		catch (Exception e)
		{
			// Try connecting again
			Log.i(TAG, "PlayGames: displayPlayerScore Exception");
			Log.i(TAG, e.toString());
			login();
			return false;
		}
		return true;
	}

	public static void openGame(String name)
	{

	}

	private static final int RC_SAVED_GAMES = 9009;

	public static void displaySavedGames(String title, boolean allowAddButton, boolean allowDelete, int maxNumberOfSavedGamesToShow)
	{
		try
		{
			if (title == null || title.compareTo("") == 0) title = " ";
			mainActivity.startActivityForResult(Games.Snapshots.getSelectSnapshotIntent(mHelper.mGoogleApiClient, title, allowAddButton, allowDelete, maxNumberOfSavedGamesToShow), RC_SAVED_GAMES);
		}
		catch (Exception e)
		{
			// Try connecting again
			Log.i(TAG, "PlayGames: displaySavedGames Exception");
			Log.i(TAG, e.toString());
			login();
		}
	}

	private static Snapshot snapshot = null;
	private static boolean savedGamesWorking = false;

	public static void loadSavedGame(final String savedName)
	{
		if (savedGamesWorking)
		{
			Log.i(TAG, "PlayGames: loadSavedGame (still opening game... won't do anything).");
			return;
		}
		if (snapshot != null) discardAndCloseGame();

		AsyncTask<Void, Void, Integer> task = new AsyncTask<Void, Void, Integer>()
		{
			@Override
			protected Integer doInBackground(Void... params)
			{
				int statusCode = 0;
				try
				{
					String name = new String(savedName);
					byte[] mSaveGameData = null;
					byte[] mConfictSaveGameData = null;
					Snapshot conflictSnapshot = null;
					// Open the saved game using its name.
					Snapshots.OpenSnapshotResult result = Games.Snapshots.open(mHelper.mGoogleApiClient, name, true).await();

					statusCode = result.getStatus().getStatusCode();
					boolean hadConflict = false;

					if (statusCode == GamesStatusCodes.STATUS_SNAPSHOT_CONFLICT)
					{
						hadConflict = true;
						while (statusCode == GamesStatusCodes.STATUS_SNAPSHOT_CONFLICT)
						{
							conflictSnapshot = result.getConflictingSnapshot();
							Games.Snapshots.resolveConflict(mHelper.mGoogleApiClient, result.getConflictId(), result.getSnapshot()).await();
							result = Games.Snapshots.open(mHelper.mGoogleApiClient, name, true).await();
							statusCode = result.getStatus().getStatusCode();
						}
					}

					// Check the result of the open operation
					if (result.getStatus().isSuccess())
					{
						snapshot = result.getSnapshot();
						// Read the byte content of the saved game.
						try
						{
							mSaveGameData = snapshot.getSnapshotContents().readFully();
						}
						catch (IOException e)
						{
							Log.e(TAG, "Error while reading Snapshot.", e);
						}
					}
					else
					{
						Log.e(TAG, "Error while loading: " + result.getStatus().getStatusCode());
					}

					savedGamesWorking = false;
					if (hadConflict)
					{
						try
						{
							mConfictSaveGameData = conflictSnapshot.getSnapshotContents().readFully();
						}
						catch (IOException e)
						{
							Log.e(TAG, "Error while reading Snapshot.", e);
						}
						callbackObject.call3("onLoadSavedGameConflict", name, mSaveGameData == null ? null : new String(mSaveGameData), mConfictSaveGameData == null ? null : new String(mConfictSaveGameData));
					}
					else
					{
						callbackObject.call3("onLoadSavedGameComplete", name, result.getStatus().getStatusCode(), mSaveGameData == null ? null : new String(mSaveGameData));
					}

				}
				catch (Exception e)
				{
					// Try connecting again
					Log.i(TAG, "PlayGames: loadSavedGame / doInBackground Exception");
					Log.i(TAG, e.toString());
					login();
					savedGamesWorking = false;
				}
				return statusCode;
			}
		};
		savedGamesWorking = true;
		task.execute();
	}

	public static boolean discardAndCloseGame()
	{
		if (savedGamesWorking)
		{
			Log.i(TAG, "PlayGames: discardAndCloseGame (still opening game... won't do anything).");
			return false;
		}
		try
		{
			if (snapshot == null) return true;
			Games.Snapshots.discardAndClose(mHelper.mGoogleApiClient, snapshot);
			snapshot = null;
		}
		catch (Exception e)
		{
			// Try connecting again
			Log.i(TAG, "PlayGames: discardAndCloseGame Exception");
			Log.i(TAG, e.toString());
			login();
			return false;
		}
		return true;
	}

	public static boolean commitAndCloseGame(String data, String description)
	{
		if (savedGamesWorking)
		{
			Log.i(TAG, "PlayGames: commitAndCloseGame (still opening game... won't do anything).");
			return false;
		}
		try
		{
			if (snapshot == null)
			{
				Log.i(TAG, "PlayGames: commitAndCloseGame (trying to save unopened game!)");
				return true;
			}
			snapshot.getSnapshotContents().writeBytes(data.getBytes());
			// Create the change operation
			SnapshotMetadataChange metadataChange = new SnapshotMetadataChange.Builder()
			//.setCoverImage(coverImage)
					.setDescription(description).build();

			Games.Snapshots.commitAndClose(mHelper.mGoogleApiClient, snapshot, metadataChange);
			snapshot = null;
		}
		catch (Exception e)
		{
			// Try connecting again
			Log.i(TAG, "PlayGames: commitAndCloseGame Exception");
			Log.i(TAG, e.toString());
			login();
			return false;
		}
		return true;
	}

}
