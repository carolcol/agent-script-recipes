public with sharing class UpdateHotelReservation {

    public class Request {
        @InvocableVariable(label='Reservation Id' description='The Salesforce Id of the hotel reservation to update.' required=true)
        public String reservationId;

        @InvocableVariable(label='Expected Arrival Time' description='New expected arrival time at the hotel after a flight delay.')
        public DateTime expectedArrivalTime;

        @InvocableVariable(label='Modification Reason' description='Reason for the reservation modification, recorded by the agent.')
        public String modificationReason;

        @InvocableVariable(label='Late Arrival Flag' description='Set to true when the customer will arrive later than originally planned.')
        public Boolean lateArrivalFlag;
    }

    public class Response {
        @InvocableVariable(label='Success' description='True if the reservation was updated successfully.')
        public Boolean success;

        @InvocableVariable(label='Message' description='Confirmation or error message.')
        public String message;
    }

    @InvocableMethod(
        label='Update Hotel Reservation'
        description='Updates a hotel reservation with a new expected arrival time and modification details after a flight delay.'
    )
    public static List<Response> updateReservation(List<Request> requests) {
        List<Response> results = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();

            try {
                Hotel_Reservation__c record = new Hotel_Reservation__c(Id = req.reservationId);
                record.Status__c = 'Modified';

                if (req.expectedArrivalTime != null) {
                    record.Expected_Arrival_Time__c = req.expectedArrivalTime;
                }
                if (req.modificationReason != null) {
                    record.Modification_Reason__c = req.modificationReason;
                }
                if (req.lateArrivalFlag != null) {
                    record.Late_Arrival_Flag__c = req.lateArrivalFlag;
                }

                update record;

                res.success = true;
                res.message = 'Hotel reservation updated successfully.';
            } catch (Exception e) {
                res.success = false;
                res.message = 'Failed to update reservation: ' + e.getMessage();
            }

            results.add(res);
        }

        return results;
    }
}
