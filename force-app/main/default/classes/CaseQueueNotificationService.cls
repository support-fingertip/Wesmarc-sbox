/*  Class Name: CaseQueueNotificationService  * Date: 12/03/2026  @author: Nanma  
*  @description: Sends email notifications to active members of a Case queue
*  @parameters: Set of Case Ids, Set of queue member User Ids */
public without sharing class CaseQueueNotificationService {

    public static void sendEmailToQueueMembers(Set<Id> caseIds, Set<Id> queueMemberIds) {
        if (caseIds.isEmpty() || queueMemberIds.isEmpty()) {
            return;
        }

        List<User> activeUsers = [
            SELECT Id, Email
            FROM User
            WHERE Id IN :queueMemberIds
            AND IsActive = true
            AND Email != null
        ];

        if (activeUsers.isEmpty()) {
            return;
        }

        List<Case> cases = [
            SELECT Id, CaseNumber, Subject, Status
            FROM Case
            WHERE Id IN :caseIds
        ];

        List<String> toAddresses = new List<String>();
        for (User u : activeUsers) {
            toAddresses.add(u.Email);
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Case c : cases) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setSubject('Case ' + c.CaseNumber + ' in your queue (' + c.Status + ')');
            mail.setPlainTextBody(
                'A case assigned to your queue has changed.\n\n' +
                'Case Number: ' + c.CaseNumber + '\n' +
                'Subject: ' + (c.Subject != null ? c.Subject : '') + '\n' +
                'Status: ' + c.Status + '\n\n' +
                'Please log into Salesforce for more details.'
            );
            mail.setSaveAsActivity(false);
            emails.add(mail);
        }

        if (!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails);
            } catch (Exception e) {
                System.debug('Email sending failed: ' + e.getMessage());
            }
        }
    }
}