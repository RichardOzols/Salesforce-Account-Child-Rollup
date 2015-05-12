@isTest
private class AccountBatchTestClass {
	
	@isTest static void test_method_one() {
		// Prepare test Class Data
		Account acc=new Account(Name='testAcc');
		insert acc;

		Contact con=new Contact(LastName='testCon',AccountId=acc.Id);
		insert con;

		Case caseOpen=new Case(Status='New',Origin='Phone',AccountId=acc.Id);
		Case caseClosed=new Case(Status='Closed',Origin='Phone',AccountId=acc.Id);
		List<Case> caselist=new List<Case>();
		caselist.add(caseOpen);
		caselist.add(caseClosed);
		insert caselist;

		//Run Btach class
		Id batchInstanceId =Database.executeBatch(new AccountBatch());
	}
	
}