trigger StopPartnerConnectionSharingTrigger on Case (after update) {
    
    Set<Id> caseIds = new Set<Id>();
    List<PartnerNetworkRecordConnection> sharedCases = new List<PartnerNetworkRecordConnection>();
    for(Case c :Trigger.New){
        if(c.isClosed && Datetime.now() >= c.ClosedDate.addDays(14)) {
            caseIds.add(c.id);
        }
    }
    
    List<PartnerNetworkRecordConnection> recordConns = new List<PartnerNetworkRecordConnection>(
    [Select Id, Status, ConnectionId, LocalRecordId from PartnerNetworkRecordConnection
        where LocalRecordId in :caseIds]
    );
    
    for(PartnerNetworkRecordConnection recordConn : recordConns) {
        //account is connected - outbound
        if(recordConn.Status.equalsignorecase('Sent')){ sharedCases.add(recordConn);}
    }
   
   if(!sharedCases.isEmpty()){ try {delete sharedCases;} catch(Exception e){ System.debug('Error' + e);} }
   
    
}