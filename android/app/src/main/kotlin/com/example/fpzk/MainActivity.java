package com.example.fpzk;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.zkteco.android.biometric.core.device.ParameterHelper;
import com.zkteco.android.biometric.core.device.TransportType;
import com.zkteco.android.biometric.core.utils.LogHelper;
import com.zkteco.android.biometric.core.utils.ToolUtils;
import com.zkteco.android.biometric.module.fingerprintreader.FingerprintCaptureListener;
import com.zkteco.android.biometric.module.fingerprintreader.FingerprintSensor;
import com.zkteco.android.biometric.module.fingerprintreader.FingprintFactory;
import com.zkteco.android.biometric.module.fingerprintreader.ZKFingerService;
import com.zkteco.android.biometric.module.fingerprintreader.exception.FingerprintException;

import java.io.ByteArrayOutputStream;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterFragmentActivity{
    private static final String CHANNEL_EVENT_FINGERPRINT="com.example.fpzk/event_channel";
    private static final String CHANNEL_METHOD_FINGERPRINT="com.example.fpzk/method_channel";
    private static final int VID = 6997;
    private static final int PID = 292;
    private String helperMessage = null;
    private String sample1=null;
    private String sample2=null;
    private String sample3=null;
    private String sample4=null;
    private byte[] verifySample=new byte[2048];
    private byte[] verifySample2=new byte[2048];
    private byte[] verifySample3=new byte[2048];
    private byte[] verifySample4=new byte[2048];
    private HashMap<String, Object> sinkValue=new HashMap<String, Object>();
    private boolean bstart = false;
    private boolean isRegister = false;
    private int uid = 1;
    private final byte[][] regtemparray = new byte[3][2048];  //register template buffer array
    private int enrollidx = 0;
    private final byte[] lastRegTemp = new byte[2048];

    private FingerprintSensor fingerprintSensor = null;

    private final String ACTION_USB_PERMISSION = "com.zkteco.silkiddemo.USB_PERMISSION";

    private final BroadcastReceiver mUsbReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (ACTION_USB_PERMISSION.equals(action)) {
                synchronized (this) {
                    if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                        LogHelper.i("have permission!");
                    } else {
                        LogHelper.e("not permission!");
                    }
                }
            }
        }
    };

    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),CHANNEL_METHOD_FINGERPRINT).setMethodCallHandler(
                (call,result)->{
                    if(call.method.equals("initialize_fingerprint_zk"))
                    {
                        InitDevice();
                        result.success(startFingerprintSensor());
                    }
                    else if(call.method.equals("stop_fingerprint_zk"))
                    {

                        result.success(OnBnStop());
                    }else if(call.method.equals("enroll_fingerprint_zk"))
                    {

                        result.success(OnBnEnroll());
                    }else if(call.method.equals("verify_fingerprint_zk"))
                    {
                        sample1=call.argument("saveFp1");
                        sample2=call.argument("saveFp2");
                        sample3=call.argument("saveFp3");
                        sample4=call.argument("saveFp4");
                        result.success(OnBnVerify());
                    }
                    else
                    {
                        result.error("UNAVAILABLE","Not implemented","Try again");
                    }
                }
        );
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),CHANNEL_EVENT_FINGERPRINT).setStreamHandler(
               new EventChannel.StreamHandler(){
                   private EventChannel.EventSink fpeventsink;
                   @Override
                   public void onListen(Object arguments, EventChannel.EventSink events) {
                       fpeventsink=events;
                       try {
                           if (bstart) return;
                           fingerprintSensor.open(0);
                           final FingerprintCaptureListener listener = new FingerprintCaptureListener() {
                               @Override
                               public void captureOK(final byte[] fpImage) {
                                   final int width = fingerprintSensor.getImageWidth();
                                   final int height = fingerprintSensor.getImageHeight();
                                   runOnUiThread(() -> {
                                       if (null != fpImage) {
                                           ToolUtils.outputHexString(fpImage);
                                           LogHelper.i("width=" + width + "\nHeight=" + height);
                                           Bitmap bitmapFp = ToolUtils.renderCroppedGreyScaleBitmap(fpImage, width, height);
//                                           saveBitmap(bitmapFp);
                                           ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                                           bitmapFp.compress(Bitmap.CompressFormat.JPEG, 30, byteArrayOutputStream);
                                           byte[] byteArray = byteArrayOutputStream .toByteArray();
                                           String encoded = Base64.encodeToString(byteArray, Base64.NO_WRAP);
                                           sinkValue.put("image",encoded);
                                           sinkValue.put("message",helperMessage);
                                       }
                                   });
                               }

                               @Override
                               public void captureError(FingerprintException e) {
                                   final FingerprintException exp = e;
                                   runOnUiThread(() -> {
                                       LogHelper.d("captureError  errno=" + exp.getErrorCode() +
                                               ",Internal error code: " + exp.getInternalErrorCode() + ",message=" + exp.getMessage());
//                                       events.success(sinkValue);
                                   });
                               }

                               @Override
                               public void extractError(final int err) {
                                   runOnUiThread(() -> {
                                       helperMessage = "extract fail, errorcode:" + err;
                                       sinkValue.put("message",helperMessage);
//                                       events.success(sinkValue);
                                   });
                               }

                               @Override
                               public void extractOK(final byte[] fpTemplate) {
                                   runOnUiThread(() -> {
                                       if (isRegister) {
                                           byte[] bufids = new byte[256];
                                           int ret = ZKFingerService.identify(fpTemplate, bufids, 55, 1);
                                           if (ret > 0) {
                                               String[] strRes = new String(bufids).split("\t");
                                               helperMessage="the finger already enroll by " + strRes[0] + ",cancel enroll";
                                               isRegister = false;
                                               enrollidx = 0;
                                               sinkValue.put("message",helperMessage);

                                               return;
                                           }

                                           if (enrollidx > 0 && ZKFingerService.verify(regtemparray[enrollidx - 1], fpTemplate) <= 0) {
                                               helperMessage="Please scan the same finger 3 times for the enrollment";
                                               sinkValue.put("message",helperMessage);
//                                               events.success(sinkValue);
                                               return;
                                           }
                                           System.arraycopy(fpTemplate, 0, regtemparray[enrollidx], 0, 2048);
                                           enrollidx++;
                                           if (enrollidx == 3) {
                                               byte[] regTemp = new byte[2048];
                                               if (0 < (ret = ZKFingerService.merge(regtemparray[0], regtemparray[1], regtemparray[2], regTemp))) {
//
                                                   System.arraycopy(regTemp, 0, lastRegTemp, 0, ret);
                                                   //Base64 Template
                                                   String strBase64 = Base64.encodeToString(regTemp, 0, ret, Base64.NO_WRAP);

                                                   helperMessage="Enroll successful";
                                                   sinkValue.put("saveFp",strBase64);

                                                   sinkValue.put("message",helperMessage);
//                                                   events.success(sinkValue);
                                               } else {
                                                   helperMessage="Enroll failed";
                                                   sinkValue.put("message",helperMessage);
//                                                   events.success(sinkValue);
                                               }
                                               isRegister = false;
                                           } else {
                                               helperMessage="Please scan the same finger " + (3 - enrollidx) + " more time";
                                               sinkValue.put("message",helperMessage);
//                                               events.success(sinkValue);
                                           }
                                       } else {
                                           byte[] bufids = new byte[256];
                                           if(verifySample!=null&&verifySample2!=null)
                                           {
                                               verifySample=Base64.decode(sample1,Base64.NO_WRAP);
                                               ZKFingerService.save(verifySample, "test" + uid++);
                                               helperMessage="Enroll successful";
                                               sinkValue.put("message",helperMessage);
                                               verifySample2=Base64.decode(sample2,Base64.NO_WRAP);
                                               ZKFingerService.save(verifySample2, "test" + uid++);
                                               helperMessage="Enroll successful";
                                               sinkValue.put("message",helperMessage);
                                               verifySample3=Base64.decode(sample3,Base64.NO_WRAP);
                                               ZKFingerService.save(verifySample3, "test" + uid++);
                                               helperMessage="Enroll successful";
                                               sinkValue.put("message",helperMessage);
                                               verifySample4=Base64.decode(sample4,Base64.NO_WRAP);
                                               ZKFingerService.save(verifySample4, "test" + uid++);
                                               helperMessage="Enroll successful";
                                               sinkValue.put("message",helperMessage);
//

                                           }
                                           int ret = ZKFingerService.identify(fpTemplate, bufids, 55, 1);
                                           if (ret > 0) {
                                               String[] strRes = new String(bufids).split("\t");
                                               helperMessage="Identification successful\nscore:" + strRes[1];
                                               sinkValue.put("message",helperMessage);
//
                                           } else {
                                               helperMessage="identify fail";
                                               sinkValue.put("message",helperMessage);
//                                               events.success(sinkValue);
                                           }
                                           //Base64 Template
                                           //String strBase64 = Base64.encodeToString(tmpBuffer, 0, fingerprintSensor.getLastTempLen(), Base64.NO_WRAP);
                                       }
                                       sinkValue.put("message",helperMessage);
                                       events.success(sinkValue);
                                   });
                               }


                           };
                           fingerprintSensor.setFingerprintCaptureListener(0, listener);
                           fingerprintSensor.startCapture(0);
                           bstart = true;
                           helperMessage="start capture succ";

                       } catch (FingerprintException e) {
                           helperMessage="begin capture fail.errorcode:" + e.getErrorCode() + "err message:" + e.getMessage() + "inner code:" + e.getInternalErrorCode();
                       }
                   }

                   @Override
                   public void onCancel(Object arguments) {
                       fpeventsink=null;
                   }
               }
        );
    }
    private void InitDevice() {
        UsbManager musbManager = (UsbManager) this.getSystemService(Context.USB_SERVICE);
        IntentFilter filter = new IntentFilter();
        filter.addAction(ACTION_USB_PERMISSION);
        filter.addAction(UsbManager.ACTION_USB_ACCESSORY_ATTACHED);
        Context context = this.getApplicationContext();
        context.registerReceiver(mUsbReceiver, filter);

        for (UsbDevice device : musbManager.getDeviceList().values()) {

                if (!musbManager.hasPermission(device)) {
                    Intent intent = new Intent(ACTION_USB_PERMISSION);
                    PendingIntent pendingIntent = PendingIntent.getBroadcast(context, 0, intent, 0);
                    musbManager.requestPermission(device, pendingIntent);
                }

        }
    }
    private String startFingerprintSensor() {
        // Define output log level
        LogHelper.setLevel(Log.VERBOSE);
        // Start fingerprint sensor
        Map fingerprintParams = new HashMap();
        //set vid
        fingerprintParams.put(ParameterHelper.PARAM_KEY_VID, VID);
        //set pid
        fingerprintParams.put(ParameterHelper.PARAM_KEY_PID, PID);
        fingerprintSensor = FingprintFactory.createFingerprintSensor(this, TransportType.USB, fingerprintParams);
        return  helperMessage;
    }
    public String OnBnStop() {
        try {
            if (bstart) {
                //stop capture
                fingerprintSensor.stopCapture(0);
                bstart = false;
                fingerprintSensor.close(0);
                helperMessage="stop capture succ";
            } else {
                helperMessage="already stop";
            }
            return helperMessage;
        } catch (FingerprintException e) {
            helperMessage="stop fail, errno=" + e.getErrorCode() + "\nmessage=" + e.getMessage();
            return helperMessage;
        }
    }
    public String OnBnEnroll() {
        if (bstart) {
            isRegister = true;
            enrollidx = 0;
            helperMessage="You need to press the 3 time fingerprint";
        } else {
            helperMessage="please begin capture first";
        }
        return  helperMessage;
    }

    public String OnBnVerify() {
        if (bstart) {
            isRegister = false;
            enrollidx = 0;
        } else {
            helperMessage = "please begin capture first";
        }
        return helperMessage;
    }
    }
