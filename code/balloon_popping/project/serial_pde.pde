import processing.serial.*;
import java.lang.String.*;


  final String portname = "COM7"; // or "COM5"
  final int BAUD_RATE = 9600;
  
  Serial port;
  final int lf = 10;  // ASCII linefeed == 10

  static final int SERIAL_DATA_LEN = 11;
  double xAcc,yAcc,zAcc,xr,yr,fsr,magnitude,deg,zr,xOut,yOut;  
  String serialData = "";
  int counter = 0;
  
  void __setup(PApplet applet)
  {  
    port = new Serial(applet, portname, BAUD_RATE);
  }
      
      float calibrate_x()
{
  return ((float)xAcc+20) * (CANVAS_WIDTH / 40);
}

float calibrate_y()
{
  return (CANVAS_HEIGHT - ((float)yAcc+20) * (CANVAS_HEIGHT / 40));
}

final static int NUM_EVENTS = 4;

  void serialEvent(int serial) {
   // serial.clear();
    if(serial != lf) {
      serialData += char(serial);
      // println("serial: " + char(serial));
    }
    else {
      if((counter % NUM_EVENTS) == 0) {
         xAcc = Double.parseDouble(serialData);
         print("  x: " + xAcc);
      } else if ((counter % NUM_EVENTS) == 1){
        yAcc = Double.parseDouble(serialData);
        print("  y: " + yAcc);
      } else if ((counter % NUM_EVENTS) == 2){
        fsr = Double.parseDouble(serialData);
        print("  fsr: " + fsr);
      }
      else if ((counter % NUM_EVENTS) == 3){
        deg = Double.parseDouble(serialData);
        println("  deg: " + deg);
      }
       serialData = "";
       counter++;
     }
  }
