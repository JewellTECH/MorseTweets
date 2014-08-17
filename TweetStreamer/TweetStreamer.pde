/**
 * TweetStreamer
 * Author: @Bradley_Dice for @WJCTECH
 * Outputs tweet streams from a given search term to screen and via serial.
 */

import java.util.List;
import processing.serial.*;

final int feedSize = 20;
final int marginSize = 30;
final int headerSize = 90;
final float headerSpacing = 1.9;
final int tweetHeight = 96;
final int maxMediaSize = 200;
final String searchTerm = "@WJCTECH";
final boolean showMedia = true;
final boolean outputSerial = true;

TwitterFactory tf;
Twitter twitter;
ConfigurationBuilder cb = new ConfigurationBuilder();
ArrayList<FeedItem> feedItems = new ArrayList<FeedItem>();
ArrayList<Integer> rectYPos = new ArrayList();

PFont headerFont;
PFont contentFont;
PFont smallFont;
PImage bg;
String imageURL;
ResponseList<Status> result;
Serial myPort;

int savedTime;
int lastY = 50;
long lastSpokenId = 0;
long lastId = 0;
final int totalTime = 60000; //only 15 requests per 15 min (1 update per min)

void setup(){
    size(displayWidth, displayHeight);

    cb.setDebugEnabled(true)
    .setOAuthConsumerKey(consumerKey)
    .setOAuthConsumerSecret(consumerSecret)
    .setOAuthAccessToken(accessToken)
    .setOAuthAccessTokenSecret(accessTokenSecret);

    tf = new TwitterFactory(cb.build());
    twitter = tf.getInstance();
    pullTwitter();

    savedTime = millis();
    
    if(outputSerial == true){
        println(Serial.list());
        myPort = new Serial(this, Serial.list()[0], 9600);
    }
}



void draw(){
    background(0, 90, 180);
    stroke(255);
    line(width/2, marginSize, width/2, height - marginSize);
    fill(255);
    headerFont = loadFont("Raleway-Light-90.vlw");
    contentFont = loadFont("Raleway-SemiBold-18.vlw");
    smallFont = loadFont("Roboto-Medium-10.vlw");
    textFont(headerFont, headerSize);
    text("Twitter Stream:", 10, headerSize);
    text(searchTerm, 10, headerSpacing*headerSize);
    textFont(contentFont, 18);
    
    int tweetNumber = 0;
    boolean lastDrawn = false;
    
    lastY = (int) (headerSpacing*headerSize) + marginSize;
    for(int i = 0; i < feedItems.size(); i++){
        lastDrawn = false;
        tweetNumber = i;
        FeedItem current = feedItems.get(i);
        outputItem(current);
        if(current.getFeedItemHeight() + lastY < height){
            current.drawFeedItem(marginSize);
            lastDrawn = true;
        }else{
          break;
        }
    }
    
    if(lastDrawn == true){
        tweetNumber++;
    }
    
    lastY = marginSize;
    for(int i = tweetNumber; i < feedItems.size() && lastY < height; i++){
        lastDrawn = false;
        tweetNumber = i;
        FeedItem current = feedItems.get(i);
        outputItem(current);
        if(current.getFeedItemHeight() + lastY < height){
            current.drawFeedItem(width/2 + marginSize);
            lastDrawn = true;
        }else{
          break;
        }
    }
    
    lastSpokenId = lastId;
    int passedTime = millis() - savedTime;

    if (passedTime > totalTime) {
        println( "Updating..." );
        savedTime = millis();
        pullTwitter();
    }
    
    while (myPort.available() > 0) {
        char c = myPort.readChar();
        System.out.print(c);
    }
}

boolean sketchFullScreen() {
    return true;
}

void pullTwitter(){
    try {
        Paging paging = new Paging();
        paging.sinceId(150);
        Query query = new Query(searchTerm);
        QueryResult result = twitter.search(query);

        feedItems.clear();

        for (Status status : result.getTweets()) {
            if(feedItems.size() > feedSize){
                break;
            }
            FeedItem fi = new FeedItem(status);
            feedItems.add(fi);
            //System.out.println(fi);
            if(fi.getId() > lastId){
                lastId = fi.getId();
                System.out.println("Latest ID: " + lastId);
            }
        }

    } catch(Exception e) {
        System.out.println("Step Exception");
        System.out.println(e.toString());
    }

    System.out.println("Finished Pulling Twitter Data");
}

void outputItem(FeedItem fi){
    if(fi.getId() > lastSpokenId && outputSerial == true){
        System.out.println("Outputting to serial: " + fi.toString());
        myPort.write(fi.toString());
    }
}
