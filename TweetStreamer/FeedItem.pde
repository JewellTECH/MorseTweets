import java.util.Date;
import java.util.List;

class FeedItem {
    private PImage profilePic;
    private PImage mediaPic;
    private Status status;
    private Date date;
    private boolean hasMedia = false;
    private long id;

    FeedItem(Status _status){
        String imageURL;
        String mediaURL;
        status = _status;
        id = status.getId();
        date = status.getCreatedAt();
        imageURL = status.getUser().getBiggerProfileImageURL();
        profilePic = loadImage(imageURL, "jpg");
        for (MediaEntity mediaEntity : status.getMediaEntities()) {
            mediaURL = mediaEntity.getMediaURL();
            System.out.println(mediaEntity.getType() + ": " + mediaEntity.getMediaURL());
            mediaPic = loadImage(mediaURL, "jpg");
            hasMedia = true;
        }           
    }

    PImage getProfilePic(){
        return profilePic;
    }

    PImage getMediaPic(){
        return mediaPic;
    }

    Status getStatus(){
        return status;
    }

    Boolean getHasMedia(){
        return hasMedia;
    }

    String toString(){
        return "@" + status.getUser().getScreenName() + ":" + status.getText();
    }

    Date getDate(){
        return date;
    }


    int getFeedItemHeight(){
        int itemHeight = tweetHeight;
        if(showMedia && getHasMedia()){
            PImage image = getMediaPic();
            float aspectRatio = ( (float) image.height )/( (float) image.width );
            float allowedWidth, allowedHeight;
            if(aspectRatio > 1){
                allowedHeight = maxMediaSize;
                allowedWidth = allowedHeight / aspectRatio;
            }else{
                allowedWidth = min(maxMediaSize, width/2 - (2 * marginSize));
                allowedHeight = allowedWidth * aspectRatio;
            }
            itemHeight += ceil(allowedHeight);
        }
        return itemHeight;
    }
    
    void drawFeedItem(float x){
        int y;
        int picHeight;

        y = lastY;

        textFont(contentFont, 18);
        text(toString(), x+100, y, (width/2) - 100 - (2 * marginSize), tweetHeight);
        image(getProfilePic(), x, y);
        textFont(smallFont, 10);
        String d = date.toString();
        text(d.substring(0,d.length()-12 ), x, y+85);

        if(showMedia && getHasMedia()){
            PImage image = getMediaPic();
            float aspectRatio = ( (float) image.height )/( (float) image.width );
            float allowedWidth, allowedHeight;
            if(aspectRatio > 1){
                allowedHeight = maxMediaSize;
                allowedWidth = allowedHeight / aspectRatio;
            }else{
                allowedWidth = min(maxMediaSize, width/2 - (2 * marginSize));
                allowedHeight = allowedWidth * aspectRatio;
            }
            y = y + tweetHeight;
            image(getMediaPic(), x+100, y, allowedWidth, allowedHeight);
            y =  y + (int) allowedHeight - 95;
        }
        lastY = y + tweetHeight;

    }
}
