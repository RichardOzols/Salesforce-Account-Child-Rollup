global class AccountBatch implements Database.Batchable<sObject> {
	
	String query;

	Map<String,List<Contact>> mapContactAccount;
	Map<String,List<Case>> mapOpenCaseAccount;
	Map<String,List<Case>> mapClosedCaseAccount;

	global AccountBatch() {
		List<Contact> contactsList=new List<Contact>();
		List<Case> openCasesList=new List<Case>();
		List<Case> closedCasesList=new List<Case>();
		mapContactAccount=new Map<String,List<Contact>>();
		mapOpenCaseAccount=new Map<String,List<Case>>();
		mapClosedCaseAccount=new Map<String,List<Case>>();

		//preparing map of Account and Contacts, Account Id as Key and Contacts under particular account as value
		contactsList=[Select id,AccountId from Contact where AccountId != null];
		for(Contact cont:contactsList){
			if(mapContactAccount.containsKey(cont.AccountId)) {  
                        mapContactAccount.get(cont.AccountId).add(cont);  
                        }else{  
                                mapContactAccount.put(cont.AccountId, new List<Contact>{cont});   
                        }
		}

		
		//preparing map of Account and Open Cases, Account Id as Key and Open Cases under particular account as value
		openCasesList=[Select id,AccountId from Case where IsClosed =:false and AccountId != null];
		for(Case openCase:openCasesList){
			if(mapOpenCaseAccount.containsKey(openCase.AccountId)) {  
                        mapOpenCaseAccount.get(openCase.AccountId).add(openCase);  
                        }else{  
                                mapOpenCaseAccount.put(openCase.AccountId, new List<Case>{openCase});   
                        }
		}


		//preparing map of Account and Closed Cases, Account Id as Key and Closed Cases under particular account as value
		closedCasesList=[Select id,AccountId from Case where IsClosed =:true and AccountId != null];
		for(Case closedCase:closedCasesList){
			if(mapClosedCaseAccount.containsKey(closedCase.AccountId)) {  
                        mapClosedCaseAccount.get(closedCase.AccountId).add(closedCase);  
                        }else{  
                                mapClosedCaseAccount.put(closedCase.AccountId, new List<Case>{closedCase});   
                        }
			}

	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		//taking all the Accounts with OpenActivities and ClosedActivities in inner query of Account
		query='Select Id,Number_of_Contacts__c,Number_of_Closed_Cases__c,Number_of_Closed_Activities__c,Number_of_Open_Activities__c,Number_of_Open_Cases__c,(Select Id from ActivityHistories),(Select Id from OpenActivities) from Account';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) {
		//traversing Account List and checking number of Contacts,OpenActivities,ClosedActivities,Open Cases,Closed Cases
		for(Account accObj:scope){
			if(mapContactAccount.get(accObj.Id)!=null)
			accObj.Number_of_Contacts__c=mapContactAccount.get(accObj.Id).size();
			system.debug('...............'+mapClosedCaseAccount.get(accObj.Id));
			if(mapClosedCaseAccount.get(accObj.Id)!=null)
			accObj.Number_of_Closed_Cases__c=mapClosedCaseAccount.get(accObj.Id).size();
			//Checking size of OpenActivities and ClosedActivities from inner query
			if(accObj.ActivityHistories!=null)
			accObj.Number_of_Closed_Activities__c=accObj.ActivityHistories.size();
			if(accObj.OpenActivities!=null)
			accObj.Number_of_Open_Activities__c=accObj.OpenActivities.size();
			if(mapOpenCaseAccount.get(accObj.Id)!=null)
			accObj.Number_of_Open_Cases__c=mapOpenCaseAccount.get(accObj.Id).size();
		}
		
		List<Database.SaveResult> SR =  Database.update(scope);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}