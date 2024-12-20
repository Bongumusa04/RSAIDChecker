/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class HolidayFetcherTest {
    @isTest
    static void testFetchHolidaysSuccess() {
        // Set up mock response
        String mockResponseBody = '{"response": {"holidays": [{"name": "New Year\'s Day"}, {"name": "Freedom Day"}]}}';
        Test.setMock(HttpCalloutMock.class, new HolidayFetcherMock(200, mockResponseBody));

        // Call the method and verify results
        List<String> holidays = HolidayFetcher.fetchHolidays('2023');
        System.assertEquals(2, holidays.size(), 'Should return 2 holidays');
        System.assertEquals('New Year\'s Day', holidays[0], 'First holiday should match');
        System.assertEquals('Freedom Day', holidays[1], 'Second holiday should match');
    }

    @isTest
    static void testFetchHolidaysError() {
        // Set up mock response with an error status
        Test.setMock(HttpCalloutMock.class, new HolidayFetcherMock(400, '{"error": "Invalid API key"}'));

        // Call the method and verify the exception
        try {
            HolidayFetcher.fetchHolidays('2023');
            System.assert(false, 'Expected a CalloutException to be thrown');
        } catch (CalloutException e) {
            System.assertEquals('Failed to fetch holidays.', e.getMessage(), 'Should throw the correct exception message');
        }
    }

    @isTest
    static void testFetchHolidaysNoResponse() {
        // Set up mock response with no holidays
        String mockResponseBody = '{"response": {"holidays": []}}';
        Test.setMock(HttpCalloutMock.class, new HolidayFetcherMock(200, mockResponseBody));

        // Call the method and verify empty results
        List<String> holidays = HolidayFetcher.fetchHolidays('2023');
        System.assertEquals(0, holidays.size(), 'Should return no holidays');
    }

    // Mock implementation of HttpCalloutMock
    private class HolidayFetcherMock implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        HolidayFetcherMock(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.statusCode);
            res.setBody(this.responseBody);
            return res;
        }
    }
}
