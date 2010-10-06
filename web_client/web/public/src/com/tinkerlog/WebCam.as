// grabbed from
// http://www.adobe.com/devnet/air/flex/articles/uploading_air_app_to_server_06.html

package com.tinkerlog {

import flash.media.Video;
import flash.media.Camera;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.display.Bitmap;
import flash.system.Security;
import flash.system.SecurityPanel;

  public class WebCam extends Sprite {
    public static const DEFAULT_CAMERA_WIDTH : Number = 160;
    public static const DEFAULT_CAMERA_HEIGHT : Number = 120;
    public static const DEFAULT_CAMERA_FPS : Number = 30;
    public var video:Video;
    private var camera:Camera;
    private var _cameraWidth : Number;
    private var _cameraHeight : Number;
    public function WebCam(w:Number, h:Number) {
      camera = Camera.getCamera();
      _cameraWidth = w; // DEFAULT_CAMERA_WIDTH;
      _cameraHeight = h; // DEFAULT_CAMERA_HEIGHT;
      if (camera != null) {
        camera.setMode(380, _cameraHeight, DEFAULT_CAMERA_FPS)
        video = new Video(380, 270);
        video.attachCamera(camera);
        addChild(video); 
      }
      else {
        Security.showSettings(SecurityPanel.CAMERA)
      }
    }
    public function getSnapshotBitmapData():BitmapData {
      var snapshot:BitmapData = new BitmapData(_cameraWidth, _cameraHeight);
      snapshot.draw(video,new Matrix());
      return snapshot;
    }
    public function getSnapshot():Bitmap {
      var bitmap : Bitmap = new Bitmap(getSnapshotBitmapData());
      return bitmap;
    }    
    
  }
}
