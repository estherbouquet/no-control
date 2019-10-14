# (no)control
creating a variable cloud of points with a potentiometer connected to an arduino uno and a kinect v2. <br>
Part of my graduation project, *data haven*, made during my master's at ESADSE, Saint-Étienne Higher School of Art and Design, June 2019


## Context
Considering the web and the Internet as free spaces where our private life can still be preserved, is also forgeting that there are strong economical implications and political conflicts linked to our personal data and more precisely regarding the data known as metadata that we generate while we are surfing on all those services.
As they are collected, indexed, stored, copied, combined, forwarded, copied again, repeated, agregated and recombined with each other, those tracks raise control and surveillance questions that go beyong the urban or city space in order to spread out in the digital one.
Hidden, diffuse and even insidious, this design of control is developed by and for technological organisations and states. It thus shapes a society focused towards an extreme rationalisation, a society that advocates for transparency while maintaining opacity regarding their infrastructures and a society that plays with, shapes humans' affects and desires.

*(no)control* tries to unveil and reveil the mechanisms of control and more importantly their asymmetry on the web by physicaly materialising them. 
The kinect captures the face of the person standing/walking in front of the mirror structure. The person can only go back and forth or slightly move in front of it and see their face reflecting in the mirror. Despite them noticing the kinect and camera, they can not interact directly with the feedback. They are the web user.<br>
What the kinect sees is then projected on a wall but as the mirror structure is behind that wall, the person standing/moving *aka the web user* can not see what the kinect captures neither how it is displayed.
<br>It is only another person *aka the corporation* that can see, interact with and thus control what the kinect captures. A potentiometer connected to the computer where the processing program runs enables the corporation person to have control over the portrait, the identity of the web user.
By turning in one direction or another, the corporation person can manipulate as they wish the reprensentation of the identity of the person standing in front of the mirror. They can display a very detailed face as well as a triangular shape.

This installation tries to illustrate how corporations or data based companies deal with, process, control and manipulate our data without our consent, awareness or involvement.
The web user person can never see what the corporation person decides to render and on the contrary, the corporation person has a complete takeover on the way they want to display the face of the web user person. They can also give them orders such as "move forward" and "take a step back" to see the projection changing with some moiré effects.

Without glorifying or sacralising data, the idea here is to develop a critic of excess entropy where companies, because they *might* have a potential futur political, economical, financial, regulation interest, let themselves scan and save all our minor actions.

## Installation and use
The code is stored in the folder ``/kinect_microsoft_potentiometer``. <br>
You need to download and install Processing 3, the Arduino IDE, [Kinect for Windows SDK](https://www.microsoft.com/en-in/download/details.aspx?id=44561) and have at least a Windows 8 version. (Tested on a Windows 10)

First you need to connect the potentiometer to the Arduino Uno as it is shown in the documenation pdf. <br>
Then you can connect the arduino to the computer via the usb port. <br>
You need to check you have selected the right model and the right serial port in Tools.<br>
You can then televerse your code to the arduino.<br>
Then you can open the processing sketch.<br>
You might need to change the name of the serial port "COM7" in the processing sketch. Put the name you have selected in your arduino IDE.<br>
You need to connect the kinect (model xbox one also known as kinect V2), to your computer through a USB3 port.<br>
Then you can run the sketch.<br>
Turn the potentiometer to detail or on the opposite triangulate what captures the kinect.
