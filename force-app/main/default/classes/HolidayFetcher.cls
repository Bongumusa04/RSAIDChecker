public with sharing class HolidayFetcher {
    @AuraEnabled
    public static List<String> fetchHolidays(String year) {
        String endpoint = 'https://calendarific.com/api/v2/holidays';
        String apiKey = '24c5e86734eb44dc4a962826324a5546e74dc42f';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint + '?api_key=' + apiKey + '&country=ZA&year=' + year);
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> response = (Map<String, Object>) results.get('response');
            List<Map<String, Object>> holidays = (List<Map<String, Object>>) response.get('holidays');
            // Extract holiday names
            List<String> holidayNames = new List<String>();
            for (Map<String, Object> holiday : holidays) {
                holidayNames.add((String) holiday.get('name'));
            }
            return holidayNames;
        } else {
            throw new CalloutException('Failed to fetch holidays. HTTP Status: ' + res.getStatusCode());
        }
    }
}
