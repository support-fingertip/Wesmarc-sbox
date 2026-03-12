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

        // Query the Org-Wide Email Address (Wesmark Support)
        Id orgWideEmailId = null;
        List<OrgWideEmailAddress> orgWideAddresses = [
            SELECT Id
            FROM OrgWideEmailAddress
            WHERE DisplayName = 'Wesmark Support'
            LIMIT 1
        ];
        if (!orgWideAddresses.isEmpty()) {
            orgWideEmailId = orgWideAddresses[0].Id;
        }

        String baseUrl = URL.getOrgDomainURL().toExternalForm();

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Case c : cases) {
            String caseUrl = baseUrl + '/lightning/r/Case/' + c.Id + '/view';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setSubject('Customer Complaint ' + c.CaseNumber + ' Assigned');
            mail.setHtmlBody(
                '<p>Case ' + String.escapeHtml4(c.CaseNumber) + ' has been assigned to you. '
                + 'Please check and resolve the issue ASAP.</p>'
                + '<p>Please click on the link below to view the record.</p>'
                + '<p><a href="' + String.escapeHtml4(caseUrl) + '">' + String.escapeHtml4(caseUrl) + '</a></p>'
            );
            mail.setSaveAsActivity(false);
            if (orgWideEmailId != null) {
                mail.setOrgWideEmailAddressId(orgWideEmailId);
            }
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