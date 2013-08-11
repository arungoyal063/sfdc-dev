global class inboundEmailHandler implements Messaging.InboundEmailHandler {
    
        static testMethod void taskInbound() {
            Messaging.Inboundemail email = new Messaging.InboundEmail();
            email.plainTextBody = 'x|x|x|x|x|x|x|x|x|x|x|x|x|x|x|x|x|';
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            inboundEmailHandler handler = new inboundEmailHandler();
            Messaging.InboundEmailResult result = handler.handleInboundEmail(email, envelope);
        }
        
        global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
                Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
                
                String emailtext = '';
               if (email.plainTextBody != null)              
                    emailtext = email.plainTextBody;
                else
                    emailtext = email.htmlBody;
               
               String[] parsed = emailtext.split('\\|',0);
               
               Sales_Lead__c l = new Sales_Lead__C();
               //Not in Production
               //l.Date_Submitted__c = parsed.get(0);
               
               l.Department__c= parsed.get(1);
               
               //Different in PRoduction
               l.Lead_Submitted_By__c= parsed.get(2);
               
               
               l.Sales_Lead_Status__c = parsed[3];
               
               
               l.Type_Of_Lead__c= parsed[4];
               l.Other_Lead_Type__c= parsed[5];
               
               //Not in Sandbox
               l.Project_Address__c= parsed[6]; 
               
               l.Cross_Street__c = parsed[7];
               l.Landmarks__c= parsed[8];
               l.County__c= parsed[9];
               l.Notes_Description__c = parsed[10];

        
               l.Lead_Source__c = 'Sales Lead - Intranet';

               insert l;

               return result;
            }
        }