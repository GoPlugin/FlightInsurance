//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IFlightStatus {
    enum FlightStatus {
        SCHEDULED,
        ACTIVE,
        DELAYED,
        UPCOMING,
        DEPARTURED,
        TRANSIT,
        CANCELLED,
        DIVERTED,
        ONAIR
    }

    enum PolicyStatus {
        ISSUED,
        CLAIMED
    }

    struct FlightMaster {
        uint256 flightId;
        bytes32 carrierFlightNumber;
        string serviceProviderName;
        address serviceProvider; //Should be metadata hash about the patients
        uint256 registeredOn;
        address registeredBy;
    }

    struct FlightInsurance {
        bytes policyKey;
        bytes passengerKey;
        string flightIcao;
        uint256 departureOn;
        uint256 arrivalOn;
        uint256 bookedOn;
        FlightStatus flightStatus;
        bool processed;
        bool isExist;
        PolicyStatus policystatus;
    }

    struct AirlineDetails {
        address airlineAddress;
        bytes airlineKey;
        string iataSymbol;
        string airlineName;
        bool funded;
    }

    struct PassengerDetails {
        address passengerAddress;
        string passengerPnr;
        bytes airlineKey;
    }
}
