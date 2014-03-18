package com.gcmex;
import java.util.Date;
import java.util.Queue;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Window;
import android.view.WindowManager;
import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;
import android.media.audiofx.AudioEffect.OnControlStatusChangeListener;
import android.widget.RelativeLayout;
import android.view.ViewGroup;
import android.view.View;
import android.util.Log;

import android.content.pm.PackageManager.NameNotFoundException;
import java.io.IOException;
import java.util.concurrent.atomic.AtomicInteger;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.os.AsyncTask;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.gcm.GoogleCloudMessaging;
import org.haxe.extension.Extension;
import com.google.gson.Gson;
import java.util.HashMap;
import org.haxe.lime.HaxeObject;
import com.google.gson.reflect.TypeToken;

public class GCM extends Extension {
	public static final String EXTRA_MESSAGE = "message";
	public static final String PROPERTY_REG_ID = "registration_id";
	private static final String PROPERTY_APP_VERSION = "appVersion";
	private final static int PLAY_SERVICES_RESOLUTION_REQUEST = 9000;
	public static final String TAG = "OPENFL-GCS";
	private static String SENDER_ID = "MUST CALL INIT TO SET SENDER ID!";
	private static HaxeObject callbackObject=null;

	private static GoogleCloudMessaging gcm = null;
	private static AtomicInteger msgId = new AtomicInteger();
	private static SharedPreferences prefs;
	private static String regid;
	private static int currentAppVersion=0;
	private static Boolean successfulInit=false;

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	public static boolean checkPlayServices() {
		Log.i(TAG, "CHECK PLAY SERVICES.");
		try{
			int resultCode = GooglePlayServicesUtil.isGooglePlayServicesAvailable(mainActivity);
			if (resultCode == ConnectionResult.SUCCESS) return true;
			if (GooglePlayServicesUtil.isUserRecoverableError(resultCode)) {
				GooglePlayServicesUtil.getErrorDialog(resultCode, mainActivity, PLAY_SERVICES_RESOLUTION_REQUEST).show();
			} else {
				Log.i(TAG, "This device is not supported.");
			}
			return false;
		}catch(Exception e){
			return false;
		}
	}

	public static void init(String senderId, HaxeObject callback){
		try{
			SENDER_ID=senderId;
			if(gcm==null){
				callbackObject=callback;
				getAppVersion(mainContext);
				Log.i(TAG, "CREATE GCM INSTANCE.");
				gcm = GoogleCloudMessaging.getInstance(mainActivity);
				regid = getRegistrationId();
				if (regid.isEmpty()) {
					registerInBackground();
				}
				successfulInit = checkPlayServices();
			}
	    }catch(Exception e){
	        Log.i(TAG, "ERROR: init - "+e.getMessage());
	    }
		PlayGames.getInstance().init(mainActivity);
	}

	public static void sendMessage(String json){
		PlayGames.getInstance().useLeaderBoard();
		if(!successfulInit){
			if(!SENDER_ID.equals("MUST CALL INIT TO SET SENDER ID!")) Log.i(TAG, "sendMessage: can't send message. Init FAILED!");
			else Log.i(TAG, "sendMessage: can't send message. Call init first!");
			return;
		}
		try{
			Bundle data = new Bundle();
			HashMap<String,String> h=(new Gson()).fromJson(json,new TypeToken<HashMap<String, String>>() {}.getType());
			for(String key : h.keySet()){
				data.putString(key, h.get(key));
			}
			new AsyncTask<Bundle,Integer,String>() {
	            @Override
	            protected String doInBackground(Bundle... params) {
	                String msg = "";
	                try {
                        String id = Integer.toString(msgId.incrementAndGet());
                        gcm.send(SENDER_ID + "@gcm.googleapis.com", id, params[0]);
                        msg = "Sent message";
	                } catch (IOException ex) {
	                    msg = "Error :" + ex.getMessage();
	                }
	                return msg;
	            }

	            @Override
	            protected void onPostExecute(String msg) {
		            Log.i(TAG, "MSGSEND - POSTEXEC: "+msg);
	            }
	        }.execute(data);
	    }catch(Exception e){
	        Log.i(TAG, "ERROR: sendMessage - "+e.getMessage());	    	
	    }
	}

	public static void receiveMessage(String type,Bundle data){
		try{
			HashMap<String,String> h=new HashMap<String,String>();
			for(String key : data.keySet()){
				h.put(key,data.getString(key));
			}
			String json = (new Gson()).toJson(h);
	        callbackObject.call2("receiveCallback", type, json);
	    }catch(Exception e){
	        Log.i(TAG, "ERROR: receiveMessage - "+e.getMessage());	    	
	    }
	}

	public static String getRegistrationId() {
	    final SharedPreferences prefs = getGCMPreferences(mainContext);
	    String registrationId = prefs.getString(PROPERTY_REG_ID, "");
	    if (registrationId.isEmpty()) {
	        Log.i(TAG, "Registration not found.");
	        return "";
	    }
		// Check if app was updated; if so, it must clear the registration ID
		// since the existing regID is not guaranteed to work with the new
		// app version.
	    int registeredVersion = prefs.getInt(PROPERTY_APP_VERSION, Integer.MIN_VALUE);
	    if (registeredVersion != currentAppVersion) {
	        Log.i(TAG, "App version changed. Current: "+currentAppVersion+" - registeredVersion: "+registeredVersion);
	        return "";
	    }
	    return registrationId;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	private static void registerInBackground() {
		Log.i(TAG, "registerInBackground. SenderID: "+SENDER_ID);
	    new AsyncTask<String,String,String>() {
			@Override
	        protected String doInBackground(String... args) {
				Log.i(TAG, "AsyncTask.doInBackground");
	            String msg = "";
	            try {
	                if (gcm == null) {
	                    gcm = GoogleCloudMessaging.getInstance(mainContext);
	                }
	                regid = gcm.register(SENDER_ID);
	                msg = "Device registered, registration ID=" + regid;
					// Persist the regID - no need to register again.
	                storeRegistrationId(mainContext, regid);
	            } catch (IOException ex) {
					msg = "Error :" + ex.getMessage();
	            }
	            return msg;
	        }

			@Override
	        protected void onPostExecute(String msg) {
				Log.i(TAG, "POSTEXEC: "+msg);
	        }
	    }.execute(null, null, null);
	}

	private static SharedPreferences getGCMPreferences(Context context) {
	    return mainContext.getSharedPreferences("OPENFL-GCMEX", Context.MODE_PRIVATE);
	}

	private static void storeRegistrationId(Context context, String regId) {
	    Log.i(TAG, "1 Saving regId: " + regId);
	    final SharedPreferences prefs = getGCMPreferences(context);
	    Log.i(TAG, "2 Saving regId on app version " + currentAppVersion);
	    SharedPreferences.Editor editor = prefs.edit();
	    editor.putString(PROPERTY_REG_ID, regId);
	    editor.putInt(PROPERTY_APP_VERSION, currentAppVersion);
	    editor.commit();
	}

	private static void getAppVersion(Context context) {
		try {
		    PackageInfo packageInfo = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
			currentAppVersion = packageInfo.versionCode;
		} catch (Exception e) {
			Log.i(TAG, "Could not get package version: " + e);
		}
	}

}
