public class SendNotification {

    public static void sendNotification(string body,string title,string senderId,string notificationId,Id recId, Set<String> userIds ){
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setBody(body);
        notification.setTitle(title);
        notification.setSenderId(senderId);
        notification.setNotificationTypeId(notificationId);
        notification.setTargetId(recId); // target object id
        notification.send(userIds);    
    }
}