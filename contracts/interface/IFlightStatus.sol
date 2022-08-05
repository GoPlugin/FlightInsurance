//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IFlightStatus {
    enum FlightStatus {
        DELAYED,
        UPCOMING,
        DEPARTURED,
        TRANSIT,
        CANCELLED,
        ONTIME
    }

    struct FlightMaster {
        uint256 flightId;
        //bytes32 carrierFlightNumber;
        string carrierFlightNumber;
        string serviceProviderName;
        address serviceProvider; //Should be metadata hash about the patients
        uint256 registeredOn;
        address registeredBy;
    }

    struct FlightInsurance {
        uint256 policyid;
        address passenger;
        //bytes32 carrierFlightNumber;
        string carrierFlightNumber;
        uint256 departureOn;
        uint256 arrivalOn;
        uint256 bookedOn;
        FlightStatus flightStatus;
        uint256 yearmonthdate;
        bool processed;
    }
}
