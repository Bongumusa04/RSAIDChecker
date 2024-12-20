public with sharing class RSAIDCheckerService {
    @AuraEnabled
    public static Map<String, Object> validateID(String idNumber) {
        Map<String, Object> result = new Map<String, Object>();

        // Validate ID structure
        if (String.isBlank(idNumber) || idNumber.length() != 13) {
            result.put('isValid', false);
            result.put('message', 'ID number must be a 13-digit value.');
            return result;
        }

        // Decode and validate date of birth
        String birthDateString = idNumber.substring(0, 6);
        String yearPrefix = Integer.valueOf(birthDateString.substring(0, 2)) < 50 ? '20' : '19';
        String year = yearPrefix + birthDateString.substring(0, 2);
        String month = birthDateString.substring(2, 4);
        String day = birthDateString.substring(4, 6);

        if (!isValidDate(year, month, day)) {
            result.put('isValid', false);
            result.put('message', 'Invalid date of birth in ID number.');
            return result;
        }

        Date birthDate = Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
        String gender = Integer.valueOf(idNumber.substring(6, 7)) >= 5 ? 'Male' : 'Female';
        Boolean isCitizen = idNumber.substring(10, 11) == '0';

        // Process ID in the database
        try {
            String dbMessage = processIDRecord(idNumber, birthDate, gender, isCitizen);
            result.put('isValid', true);
            result.put('birthDate', birthDate);
            result.put('gender', gender);
            result.put('isCitizen', isCitizen);
            result.put('message', dbMessage);
        } catch (Exception e) {
            result.put('isValid', false);
            result.put('message', 'An error occurred while processing the ID record: ' + e.getMessage());
        }

        return result;
    }

    // Validate if the given year, month, and day form a valid date
    private static Boolean isValidDate(String year, String month, String day) {
        try {
            Integer intYear = Integer.valueOf(year);
            Integer intMonth = Integer.valueOf(month);
            Integer intDay = Integer.valueOf(day);

            if (intMonth < 1 || intMonth > 12 || intDay < 1 || intDay > 31) {
                return false;
            }

            if ((intMonth == 4 || intMonth == 6 || intMonth == 9 || intMonth == 11) && intDay > 30) {
                return false;
            }

            if (intMonth == 2) {
                Boolean isLeapYear = Math.mod(intYear, 4) == 0 && 
                                     (Math.mod(intYear, 100) != 0 || Math.mod(intYear, 400) == 0);
                return isLeapYear ? intDay <= 29 : intDay <= 28;
            }

            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public class CustomException extends Exception {}

    // Insert or update ID information in the database
    private static String processIDRecord(String idNumber, Date birthDate, String gender, Boolean isCitizen) {
        try {
            Identity_Information__c existingRecord = [
                SELECT Id, Search_Count__c 
                FROM Identity_Information__c 
                WHERE ID_Number__c = :idNumber 
                LIMIT 1
            ];

            if (existingRecord != null) {
                existingRecord.Search_Count__c++;
                update existingRecord;
                return 'Existing record updated successfully.';
            }

            Identity_Information__c newRecord = new Identity_Information__c(
                ID_Number__c = idNumber,
                Date_of_Birth__c = birthDate,
                Gender__c = gender,
                Is_Citizen__c = isCitizen,
                Search_Count__c = 1
            );

            insert newRecord;
            return 'New record created successfully.';
        } catch (Exception e) {
            throw new CustomException('Unexpected error occurred: ' + e.getMessage());
        }
    }
}