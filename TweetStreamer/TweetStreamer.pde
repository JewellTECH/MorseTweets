import java.util.List;

final int feedSize = 20;
int marginSize = 30;
int headerSize = 90;
int tweetHeight = 96;
int maxMediaSize = 200;
String searchTerm = "#jewellplc";
boolean showMedia = false;

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

int savedTime;
int lastY = 50;
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
    text("Twitter Feed:", 10, headerSize);
    textFont(contentFont, 18);
    
    int tweetNumber = 0;
    boolean lastDrawn = false;
    
    lastY = headerSize + marginSize;
    for(int i = 0; i < feedItems.size(); i++){
        lastDrawn = false;
        tweetNumber = i;
        FeedItem current = feedItems.get(i);
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
        if(current.getFeedItemHeight() + lastY < height){
            current.drawFeedItem(width/2 + marginSize);
            lastDrawn = true;
        }else{
          break;
        }
    }

    int passedTime = millis() - savedTime;

    if (passedTime > totalTime) {
        println( "Updating..." );
        savedTime = millis();
        pullTwitter();
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
            System.out.println(fi);
        }

    } catch(Exception e) {
        System.out.println("Step Exception");
        System.out.println(e.toString());
    }

    System.out.println("Finished Pulling Twitter Data");
}
