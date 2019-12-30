public without sharing class ContentDocumentController {
    
    // Call below method from Case process builder    
    @InvocableMethod    
    public static void changeFileOwners (List<ID> caseIds){        
        callFutureMethod(caseIds);        
    }
    
    @future    
    public static void callFutureMethod(List<ID> caseIds) {        
        Id caseOwnerId;        
        List<Case> lstCase = new List<Case>();        
        try{            
            // Fetch all Cases with EmailMessages (Incoming and Outgoing)            
            lstCase = [SELECT OwnerId,(SELECT id FROM EmailMessages) FROM Case WHERE Id IN :caseIds];            
            Set<Id> sharedId = new Set<Id>();            
            sharedId.addAll(caseIds);            
            for(Case objcase:lstCase){                
                caseOwnerId = objcase.OwnerId;                
                for(EmailMessage em: objcase.EmailMessages)                    
                    sharedId.add(em.id);                
            }
            List<ContentDocumentLink> lstContentDocumentLink = new List<ContentDocumentLink>();
            
            // Fetch ContentDocumentLink for Case and EmailMessages            
            lstContentDocumentLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:sharedId];    
            
            // Check if Case and EmailMessage have files as an Attachment            
            if(!lstContentDocumentLink.isEmpty()){                
                Set<Id> setContentDocument = new Set<Id>();                
                List<ContentDocument> lstContentDocument = new List<ContentDocument>();
                for(ContentDocumentLink objCDL: lstContentDocumentLink)                    
                    setContentDocument.add(objCDL.ContentDocumentId);

                lstContentDocument = [SELECT ID, OwnerId FROM ContentDocument WHERE ID IN :setContentDocument];
                
                // Sync Case Owner with File Owner                
                if(!lstContentDocument.isEmpty()){                    
                    for(ContentDocument objCD: lstContentDocument)                        
                        objCD.OwnerId = caseOwnerId ;                    
                    UPDATE lstContentDocument;
                }
            }
        }
        catch(Exception ex){
            // If any exception occures send exception email to Administrator.
            sendErrorEmail(caseIds,lstCase[0].OwnerId,ex.getMessage());
        }
    }
    public static void sendErrorEmail(List<Id> caseId, Id caseOwnerId, String errMsg){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String subject = 'Error while changing File Owner, Case Id- '+caseId+', New Owner- '+caseOwnerId;
        email.setSubject( subject );
        email.setToAddresses( new String[] {'nitish.talekar@testabc.com'} );
        email.setPlainTextBody( errMsg );
        
        // Sending email        
        if(!Test.isRunningTest())
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}
