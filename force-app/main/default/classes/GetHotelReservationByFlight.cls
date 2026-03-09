public with sharing class GetHotelReservationByFlight {

    public class Request {
        @InvocableVariable(label='Contact Id' description='The Salesforce Contact Id of the verified customer.' required=true)
        public String contactId;
    }

    public class Response {
        @InvocableVariable(label='Reservation Found' description='True if an active hotel reservation was found for this customer.')
        public Boolean reservationFound;

        @InvocableVariable(label='Reservation Id' description='The Salesforce Id of the hotel reservation record.')
        public String reservationId;

        @InvocableVariable(label='Hotel Name' description='Name of the hotel.')
        public String hotelName;

        @InvocableVariable(label='City' description='City where the hotel is located.')
        public String city;

        @InvocableVariable(label='Room Type' description='Type of room booked.')
        public String roomType;

        @InvocableVariable(label='Status' description='Current status of the reservation.')
        public String status;

        @InvocableVariable(label='Check In Date' description='Scheduled check-in date.')
        public Date checkInDate;

        @InvocableVariable(label='Check Out Date' description='Scheduled check-out date.')
        public Date checkOutDate;

        @InvocableVariable(label='Confirmation Code' description='Hotel confirmation code.')
        public String confirmationCode;

        @InvocableVariable(label='Expected Arrival Time' description='Current expected arrival time at the hotel.')
        public DateTime expectedArrivalTime;
    }

    @InvocableMethod(
        label='Get Hotel Reservation By Contact'
        description='Looks up the active hotel reservation for the verified customer using their Contact Id.'
    )
    public static List<Response> getReservation(List<Request> requests) {
        List<Response> results = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();

            List<Hotel_Reservation__c> reservations = [
                SELECT Id, Hotel_Name__c, City__c, Room_Type__c, Status__c,
                       Check_In_Date__c, Check_Out_Date__c, Confirmation_Code__c,
                       Expected_Arrival_Time__c
                FROM Hotel_Reservation__c
                WHERE Contact__c = :req.contactId
                  AND Status__c NOT IN ('Cancelled', 'Completed')
                ORDER BY Check_In_Date__c ASC
                LIMIT 1
            ];

            if (!reservations.isEmpty()) {
                Hotel_Reservation__c record = reservations[0];
                res.reservationFound = true;
                res.reservationId = record.Id;
                res.hotelName = record.Hotel_Name__c;
                res.city = record.City__c;
                res.roomType = record.Room_Type__c;
                res.status = record.Status__c;
                res.checkInDate = record.Check_In_Date__c;
                res.checkOutDate = record.Check_Out_Date__c;
                res.confirmationCode = record.Confirmation_Code__c;
                res.expectedArrivalTime = record.Expected_Arrival_Time__c;
            } else {
                res.reservationFound = false;
            }

            results.add(res);
        }

        return results;
    }
}
