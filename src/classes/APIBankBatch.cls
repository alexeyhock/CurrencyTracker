/**
 * Created by Alex on 1/4/2019.
 */

global class APIBankBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

	global static Database.QueryLocator start(Database.BatchableContext bc) {
		String bank = 'NBRB';
		String query = 'SELECT Id, Name, API_Name__c FROM Banks__c';
		return Database.getQueryLocator(query);
	}

	global static void execute(Database.BatchableContext bc, List<Banks__c> records) {
		System.debug(records);
		String setEndPointNBRB = records[1].API_Name__c;
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(setEndPointNBRB);
		request.setMethod('GET');
		request.setTimeout(120000);
		HttpResponse response = http.send(request);
		System.debug(response.getBody());
		Boolean xml = (CurrencyRateController.isXML(response)) ? true : false;
		System.debug(xml);


//		if (response.getStatusCode() == 200) {
//			System.debug('jsonrResult :' + response.getBody());
//			List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
//			List<Map<String,Object>> secondResult = new List<Map<String, Object>>();
//			for (Object obj : results) {
//				secondResult.add((Map<String,Object>) obj);
//			}
//			System.debug(secondResult[0].get('Cur_OfficialRate'));
//		}
	}

	global static void finish(Database.BatchableContext bc) {
		// execute any post-processing operations
	}
}



//https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_json_jsonparser.htm