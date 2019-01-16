/**
 * Created by Alex on 1/3/2019.
 */

public with sharing class CurrencyRateController {

	public static Boolean isXML(HttpResponse response) {
		System.debug(response);
		try {
			Dom.Document document = new Dom.Document();
			document.load(response.getBody());
			Dom.XMLNode body = document.getRootElement();
		} catch (XmlException ex) {
			System.debug(ex.getMessage() + 'XML failed');
			return false;
		}
		return true;
	}

	public static void parseJSON (HttpResponse response) {
		JSONParser parser = JSON.createParser(response.getBody());
		while (parser.nextToken() != null) {
			// Start at the array of invoices.
			if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
				while (parser.nextToken() != null) {


					}
				}
			}
		if (response.getStatusCode() == 200) {
			System.debug('jsonrResult :' + response.getBody());
			List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
			List<Map<String,Object>> secondResult = new List<Map<String, Object>>();
			for (Object obj : results) {
				secondResult.add((Map<String,Object>) obj);
			}
			System.debug(secondResult[0].get('Cur_OfficialRate'));
		}
	}

	public static void parseBelAgroPromBankResponseVIANodes() {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		String endPoint = 'https://belapb.by/CashExRatesDaily.php';
		request.setEndpoint(endPoint);
		request.setMethod('GET');
		request.setTimeout(120000);
		HttpResponse response = http.send(request);
		Dom.Document document = new Dom.Document();
		document.load(response.getBody());
		Dom.XMLNode body = document.getRootElement();
		List<Dom.XmlNode> elements = body.getChildElements();
		List<String> Abbreviations = new List<String>();
		for (Currency__c record : Currency__c.getAll().values()){
			Abbreviations.add(record.Abbreviation__c);
		}
		Integer counter = 0;
		for (Dom.XmlNode element : elements) {
			if (Abbreviations.contains(element.getChildElement('CharCode',null).getText())) {
				System.debug('-------' + element.getChildElement('CharCode',null).getText() + '--------');
				for (Dom.XmlNode tag : element.getChildElements()) {
					System.debug(tag.getName() + ' = ' + tag.getText());
				}
				counter++;
			}
			if (counter == Abbreviations.size()) {
				break;
			}
		}
	}
    public static void parseXMLResponseVIAStream() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endPointMoscowMinskBank = 'https://www.mmbank.by/export_courses.php';
		String endPointBelAgroPromBank = 'https://belapb.by/CashExRatesDaily.php';
		String endPointCBR = 'http://www.cbr.ru/scripts/XML_daily.asp';
        request.setEndpoint(endPointMoscowMinskBank);
        request.setMethod('GET');
        request.setTimeout(120000);
        HttpResponse response = http.send(request);
		List<String> Abbreviations = new List<String>();
		for (Currency__c record : Currency__c.getAll().values()){
			Abbreviations.add(record.Abbreviation__c);
		}
		String rateKey = 'buy';
		Map<String,String> result = CurrencyRateController.getRate(response, Abbreviations, rateKey);
		System.debug(result);
    }

	static Map<String,String> getRate(HttpResponse response, List<String> Abbreviations, String rateKey) {
		XmlStreamReader xsr = new XmlStreamReader(response.getBody());
		Boolean isSafeToGo = true;
		Boolean isRate = false;
		integer counter = 0;
		String tempMapKey = '';
		Map<String,String> result = new Map<String, String>();
		while (isSafeToGo) {
			if (xsr.getEventType() == XmlTag.START_ELEMENT && xsr.getAttributeCount() != 0) {
				for (integer i = 0; i < xsr.getAttributeCount(); i++) {
					if (Abbreviations.contains(xsr.getAttributeValueAt(i))) {
						result.put(xsr.getAttributeValueAt(i), xsr.getAttributeValue(null,rateKey));
						Abbreviations.remove(Abbreviations.indexOf(xsr.getAttributeValueAt(i)));
						counter++;
					}
				}
			}
			if (xsr.getEventType() == XmlTag.CHARACTERS && Abbreviations.contains(xsr.getText())) {
				tempMapKey = xsr.getText();
				isRate = true;
			}
			if (xsr.getEventType() == XmlTag.START_ELEMENT && xsr.getLocalName() == rateKey && isRate) {
				xsr.next();
				result.put(tempMapKey,xsr.getText());
				Abbreviations.remove(Abbreviations.indexOf(tempMapKey));
				counter++;
				tempMapKey = '';
				isRate = false;
			}
			if (xsr.hasNext()) {
				xsr.next();
			}
			else {
				isSafeToGo = false;
				break;
			}
			if (counter == Abbreviations.size()) {
				break;
			}
		}
		return result;
	}
	static void parseXMLViaRecursion(Dom.XMLNode node, List<String> Abbreviations, String key) {
		for (Dom.XmlNode child : node.getChildElements()) {
			if (Abbreviations.contains(child.getText())) {
				continue;
			}
			if (child.getName() == key) {

			}
		}
		if (node.getName() == key) {
			System.debug(node.getText());
		}

	}

}



//settings