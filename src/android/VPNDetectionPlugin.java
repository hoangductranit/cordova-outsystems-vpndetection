package com.outsystems.vpndetection;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.io.IOException;
import java.net.NetworkInterface;
import java.util.List;

/**
 * This class echoes a string called from JavaScript.
 */
public class VPNDetectionPlugin extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("detectVPN")) {
            this.detectVPN(callbackContext);
            return true;
        }
        return false;
    }

    private void detectVPN(CallbackContext callbackContext) {
        PluginResult result = new PluginResult(PluginResult.Status.OK,checkForVPNConnectivity());
        callbackContext.sendPluginResult(result);
    }

    private boolean checkForVPNConnectivity(){

        try{
                ConnectivityManager cm = (ConnectivityManager)cordova.getActivity().getSystemService(Context.CONNECTIVITY_SERVICE);
            Network[] networks = cm.getAllNetworks();

            for (Network network : networks) {
                NetworkCapabilities caps = cm.getNetworkCapabilities(network);
                if (caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN)) {
                    return true;
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    
        return isVPNFromInterface();
    }
    private boolean  isVPNFromInterface()
    {
        try {
            List<NetworkInterface> networkInterfaces = java.util.Collections.list( java.net.NetworkInterface.getNetworkInterfaces());
            for(NetworkInterface networkInterface: networkInterfaces)
            {
                var name = networkInterface.getName();
                if(name.equals("tun0") || name.equals("ppp0") || name.equals("utun") || name.equals("ipsec"))
                    return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false; 
    }
}
