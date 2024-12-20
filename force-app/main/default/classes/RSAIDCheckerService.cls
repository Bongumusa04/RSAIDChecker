public with sharing class RSAIDCheckerService {
    @AuraEnabled
    public static Map<String, Object> validateID(String idNumber) {
        Map<String, Object> result = new Map<String, Object>();
        
        // Check if the ID is blank or not 13 digits
        if (String.isBlank(idNumber) || idNumber.length() != 13) {
            result.put('isValid', false);
            result.put('message', 'ID number must be a 13-digit numeric value.');
            return result;
        }
        
        // Decode and validate date of birth
        String birthDateString = idNumber.substring(0, 6);
        String year = birthDateString.substring(0, 2);
        String month = birthDateString.substring(2, 4);
        String day = birthDateString.substring(4, 6);
        
        if (!isValidDate(year, month, day)) {
            result.put('isValid', false);
            result.put('message', 'Invalid date of birth in ID number.');
            return result;
        }

        // Decode gender
        Integer genderDigit = Integer.valueOf(idNumber.substring(6, 7));
        String gender = genderDigit >= 5 ? 'Male' : 'Female';

        // Decode citizenship
        Integer citizenshipDigit = Integer.valueOf(idNumber.substring(10, 11));
        String citizenship = citizenshipDigit == 0 ? 'South African' : 'Permanent Resident';

        // If all validations pass
        result.put('isValid', true);
        result.put('birthDate', year + '-' + month + '-' + day);
        result.put('gender', gender);
        result.put('citizenship', citizenship);
        result.put('message', 'ID number is valid.');
        return result;
    }

    private static Boolean isValidDate(String year, String month, String day) {
        Integer intMonth = Integer.valueOf(month);
        Integer intDay = Integer.valueOf(day);
        
        // Validate month and day range
        if (intMonth < 1 || intMonth > 12) {
            return false;
        }
        
        if (intDay < 1 || intDay > 31) {
            return false;
        }
        
        // Additional checks for months with 30 days
        if ((intMonth == 4 || intMonth == 6 || intMonth == 9 || intMonth == 11) && intDay > 30) {
            return false;
        }
        
        // Additional check for February
        if (intMonth == 2 && intDay > 29) {
            return false;
        }

        return true;
    }
}
