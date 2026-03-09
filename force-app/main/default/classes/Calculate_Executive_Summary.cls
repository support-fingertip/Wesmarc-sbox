global class Calculate_Executive_Summary implements Database.Batchable<Sobject>, Schedulable {
    global string query;
 global date dateAplicable;
    global Calculate_Executive_Summary(date dateApe) {
        this.dateAplicable =dateApe;
        query = 'SELECT Id, Name FROM User WHERE isActive = true AND Profile.Name = \'Sales Team\'';
    }

    Global Database.QueryLocator start(Database.BatchableContext bcontext) {
        return Database.getQueryLocator(query);
    }

    Global void execute(Database.BatchableContext bcontext, List<Sobject> recordToProcess) {
        Map<Id, Id> userSumMap = new Map<Id, Id>();
        List<User> users = (List<User>) recordToProcess;

        // Fetch Sales Funnel data where the status is 'Open' or 'Closed' for this month
        List<AggregateResult> salesFunnelData = [
            SELECT Status__c, Sales_Person_Name__c, COUNT(Number_of_Doors__c)
            FROM Sales_Funnel__c
            WHERE Order_Time_line_Time_Frame_Date__c = :dateAplicable
            GROUP BY Sales_Person_Name__c, Status__c
        ];

        // Prepare the summary for Sales Funnel
        Map<Id, integer> userclosedSales = new Map<Id, integer>();
         Map<Id, integer> userOpenSales = new Map<Id, integer>();
        for (AggregateResult record : salesFunnelData) {
            String status = (String) record.get('Status__c');
            String salesPersonName = (String) record.get('Sales_Person_Name__c');
            Integer count = (Integer) record.get('expr0');  // Assuming the count is stored as 'expr0'

            if (status == 'Open') {
                userOpenSales.put(salesPersonName, count);  // Open sales count
            } else if (status == 'Closed') {
                userclosedSales.put(salesPersonName, count);  // Closed sales count
            }
        }

        // Fetch existing Executive Summary records
        List<Executive_Summary__c> exeSummary = [SELECT Id, User__c FROM Executive_Summary__c where Date_Applicable__c=:dateAplicable LIMIT 4999];
        for (Executive_Summary__c exe : exeSummary) {
            userSumMap.put(exe.User__c, exe.Id);
        }

        // Create or update Executive Summary records
        List<Executive_Summary__c> exeSumUpdates = new List<Executive_Summary__c>();
        for (User u : users) { 
            Executive_Summary__c exsum = new Executive_Summary__c();

            if (userSumMap.containsKey(u.Id)) {
                exsum.Id = userSumMap.get(u.Id); // Update existing record
            } else {
                exsum.User__c = u.Id;  // Create new record
            }

            exsum.Name = u.Name;
            exsum.Number_of_Open_Sales__c = userOpenSales.containsKey(u.Id) ?userOpenSales.get(u.Id):0; // Open Sales
            exsum.Number_of_Closed_Sales__c = userclosedSales.containsKey(u.Id) ?userclosedSales.get(u.Id):0; // Closed Sales
            exsum.Date_Applicable__c = dateAplicable;//Date.today().toStartOfMonth();  // Date for this month 1st day

            exeSumUpdates.add(exsum);
        }

        // Upsert Executive Summary updates
        if (!exeSumUpdates.isEmpty()) {
            upsert exeSumUpdates;
        }
    }

    global void finish(Database.BatchableContext bcontext) {
        // Optional: Finish method if you need to handle post-batch operations
    }

    // Schedulable interface
    global void execute(SchedulableContext SC) {
      //  database.executeBatch(new Calculate_Executive_Summary(), 2); // Execute in batches of 2
    }

    
}