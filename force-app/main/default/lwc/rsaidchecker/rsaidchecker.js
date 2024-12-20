import { LightningElement, track } from 'lwc';
import validateID from '@salesforce/apex/RSAIDCheckerService.validateID';
import fetchHolidays from '@salesforce/apex/HolidayFetcher.fetchHolidays';

export default class IdChecker extends LightningElement {
    @track idNumber = '';
    @track isButtonDisabled = true;
    @track errorMessage = '';
    @track result = null;

    handleInputChange(event) {
        this.idNumber = event.target.value;
        this.isButtonDisabled = !/^\d{13}$/.test(this.idNumber); // Enable button for valid input
    }

    async handleSearch() {
        try {
            const result = await validateID({ idNumber: this.idNumber });

            if (result.isValid) {
                this.errorMessage = '';

                // Extract year from the birth date
                const birthDate = new Date(result.birthDate);
                const birthYear = birthDate.getFullYear();

                // Fetch holidays for the birth year
                const holidays = await fetchHolidays({ year: birthYear.toString() });

                this.result = {
                    ...result,
                    birthYear,
                    holidays,
                };
            } else {
                this.errorMessage = result.message || 'Invalid ID number. Please check and try again.';
                this.result = null;
            }
        } catch (error) {
            console.error('Error validating ID or fetching holidays:', error);
            this.errorMessage = 'An error occurred while processing the request. Please try again later.';
            this.result = null;
        }
    }
}
