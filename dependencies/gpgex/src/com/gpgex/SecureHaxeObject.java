package com.gpgex;

import android.app.Activity;
import android.util.Log;
import java.lang.String;
import org.haxe.lime.HaxeObject;

public class SecureHaxeObject
{
   private HaxeObject haxeObject;
   private Activity mainActivity;
   private String TAG;

   public SecureHaxeObject(HaxeObject haxeObject, Activity mainActivity, String tag) {
      this.haxeObject = haxeObject;
      this.mainActivity = mainActivity;
      this.TAG = tag;
   }

   public void call0(final String function)
   {
      if(haxeObject==null || mainActivity==null) return;
      mainActivity.runOnUiThread(new Runnable() {
         public void run() {
            try{
               haxeObject.call0(function);
            }catch(Exception e) {
               Log.e(TAG, "SecureHaxeObject: call0 Exception");
               Log.e(TAG, e.toString());
            }
         }
      });
   }

   public void call1(final String function, final Object arg0)
   {
      if(haxeObject==null || mainActivity==null) return;
      mainActivity.runOnUiThread(new Runnable() {
         public void run() {
            try{
               haxeObject.call1(function, arg0);
            }catch(Exception e) {
               Log.e(TAG, "SecureHaxeObject: call1 Exception");
               Log.e(TAG, e.toString());
            }
         }
      });

   }

   public void call2(final String function, final Object arg0, final Object arg1)
   {
      if(haxeObject==null || mainActivity==null) return;
      mainActivity.runOnUiThread(new Runnable() {
         public void run() {
            try{
               haxeObject.call2(function, arg0, arg1);
            }catch(Exception e) {
               Log.e(TAG, "SecureHaxeObject: call3 Exception");
               Log.e(TAG, e.toString());
            }
         }
      });
   }

   public void call3(final String function, final Object arg0, final Object arg1, final Object arg2)
   {
      if(haxeObject==null || mainActivity==null) return;
      mainActivity.runOnUiThread(new Runnable() {
         public void run() {
            try{
               haxeObject.call3(function, arg0, arg1, arg2);
            }catch(Exception e) {
               Log.e(TAG, "SecureHaxeObject: call3 Exception");
               Log.e(TAG, e.toString());
            }
         }
      });
   }

   public void call4(final String function, final Object arg0, final Object arg1, final Object arg2, final Object arg3)
   {
      if(haxeObject==null || mainActivity==null) return;
      mainActivity.runOnUiThread(new Runnable() {
         public void run() {
            try{
               haxeObject.call4(function, arg0, arg1, arg2, arg3);
            }catch(Exception e) {
               Log.e(TAG, "SecureHaxeObject: call4 Exception");
               Log.e(TAG, e.toString());
            }
         }
      });
   }

   public void call(final String function, final Object[] args)
   {
      if(haxeObject==null || mainActivity==null) return;
      mainActivity.runOnUiThread(new Runnable() {
         public void run() {
            try{
               haxeObject.call(function,args);
            }catch(Exception e) {
               Log.e(TAG, "SecureHaxeObject: call Exception");
               Log.e(TAG, e.toString());
            }
         }
      });
   }

}