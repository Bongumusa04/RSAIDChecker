import { LightningElement, track } from 'lwc';
import validateID from '@salesforce/apex/RSAIDCheckerService.validateID';

export default class IdChecker extends LightningElement {
    @track idNumber = '';
    @track isButtonDisabled = true;
    @track errorMessage = '';

    handleInputChange(event) {
        this.idNumber = event.target.value;
        this.isButtonDisabled = !/^\d{13}$/.test(this.idNumber); // Enable button for valid input
    }

    async handleSearch() {
        try {
            const isValid = await validateID({ idNumber: this.idNumber });
            if (isValid) {
                this.errorMessage = '';
                console.log('ID is valid!');
            } else {
                this.errorMessage = 'Invalid ID number. Please check and try again.';
            }
        } catch (error) {
            console.error('Error validating ID:', error);
            this.errorMessage = 'An error occurred while validating the ID.';
        }
    }
}
