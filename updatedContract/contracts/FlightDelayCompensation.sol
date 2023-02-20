//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract FlightDelayCompensation{

    event CompensationEvents(
        bytes passengerKey,
        string eventType,
        address performedBy,
        uint256 performedOn
    );

    enum compensationStatus {
        ISSUED,
        VERIFIED,
        CLAIMED
    }

    enum flightStatus{
        SCHEDULED,
        LANDED,
        ACTIVE,
        DELAYED,
        UPCOMING,
        DEPARTURED,
        TRANSIT,
        CANCELLED,
        DIVERTED,
        ONAIR
    }

    struct airlinePassenger {
        address passengerAddress;
        uint compAmt;
        uint flightNumber;
        string airlineTag;
        string passengerPnr;
        string depDate;
        string arrDate;
        string kycHash;
        compensationStatus compstatus;
        flightStatus flightstatus;
        bool isExist;
    }

    mapping(uint => mapping(bytes => airlinePassenger)) public passenger;

    //Passenger Utility
    function getPassengerKey(string memory _airlineTag,string memory _passengerPnr, string memory _depDate, string memory _arrDate) internal pure returns(bytes memory) {
        return abi.encodePacked('FDC-',_airlineTag,_passengerPnr,_depDate,_arrDate);
    }

    //Register Passenger
    //Error code: FDC
    function delayCompensation(
        address _passengerAddress,
        string memory _passengerPnr,
        string memory _airlineTag,
        string memory _depDate,
        string memory _arrDate,
        string memory _kycHash,
        uint _flightNumber,
        uint _passengerRegNumber,
        uint _compAmt,
        compensationStatus _cs,
        flightStatus _fs
    ) public {
        bytes memory passengerKey = getPassengerKey(_airlineTag,_passengerPnr,_depDate,_arrDate);
        require(passenger[_passengerRegNumber][passengerKey].isExist == false, "ERROR:FDC-01:TRIP_REGISTERED");
        passenger[_passengerRegNumber][passengerKey] = airlinePassenger(
            _passengerAddress,
            _compAmt,
            _flightNumber,
            _airlineTag,
            _passengerPnr,
            _depDate,
            _arrDate,
            _kycHash,
            compensationStatus(_cs),
            flightStatus(_fs),
            true
        );

        emit CompensationEvents(
            passengerKey,
            "Passenger Compensation Details Registered",
            msg.sender,
            block.timestamp
        );
    }

    //Update Compensation
    //Error code: FDC-UDC
    function delayCompensationUpdate(
        string memory _passengerPnr,
        string memory _airlineTag,
        string memory _depDate,
        string memory _arrDate,
        uint _passengerRegNumber,
        compensationStatus _cs
    ) public {
        bytes memory passengerKey = getPassengerKey(_airlineTag,_passengerPnr,_depDate,_arrDate);
        require(passenger[_passengerRegNumber][passengerKey].isExist == true, "ERROR:FDC-UDC-01:TRIP_UNREGISTERED");
        passenger[_passengerRegNumber][passengerKey].compstatus = _cs;

        emit CompensationEvents(
            passengerKey,
            "Passenger Compensation Details Updated",
            msg.sender,
            block.timestamp
        );
    }

    //Update Flight Status
    //Error code: FDC-UDF
    function delayCompensationFlightUpdate(
        string memory _passengerPnr,
        string memory _airlineTag,
        string memory _depDate,
        string memory _arrDate,
        uint _passengerRegNumber,
        flightStatus _fs
    ) public {
        bytes memory passengerKey = getPassengerKey(_airlineTag,_passengerPnr,_depDate,_arrDate);
        require(passenger[_passengerRegNumber][passengerKey].isExist == true, "ERROR:FDC-UDF-01:TRIP_UNREGISTERED");
        passenger[_passengerRegNumber][passengerKey].flightstatus = _fs;

        emit CompensationEvents(
            passengerKey,
            "Passenger Flight Status Details Updated",
            msg.sender,
            block.timestamp
        );
    }


}
