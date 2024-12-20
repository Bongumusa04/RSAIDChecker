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
public class RSAIDCheckerServiceTest {
    
    
    @isTest
    static void testInvalidLength() {
        Map<String, Object> result = RSAIDCheckerService.validateID('123');
        System.assert(false, result.get('isValid'));
        System.assertEquals('ID number must be a 13-digit numeric value.', result.get('message'));
    }

    @isTest
    static void testInvalidCharacters() {
        Map<String, Object> result = RSAIDCheckerService.validateID('123ABC4567890');
        System.assert(false, result.get('isValid'));
        System.assertEquals('ID number must be a 13-digit numeric value.', result.get('message'));
    }

    @isTest
    static void testInvalidDate() {
        Map<String, Object> result = RSAIDCheckerService.validateID('0013325678901');
        System.assert(false, result.get('isValid'));
        System.assertEquals('Invalid date of birth in ID number.', result.get('message'));
    }

    @isTest
    static void testValidID() {
        Map<String, Object> result = RSAIDCheckerService.validateID('0001255248088');
        System.assert(true, result.get('isValid'));
        System.assertEquals('ID number is valid.', result.get('message'));
    }
}