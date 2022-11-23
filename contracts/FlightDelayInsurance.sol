//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//import "../CustomTokens/contracts/utils/Counters.sol";
import "@goplugin/contracts/src/v0.8/Plugin.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@goplugin/contracts/src/v0.8/PluginClient.sol";
//import "./PLI.sol";
import "./interface/IFlightStatus.sol";

contract FlightDelayInsurance is PluginClient, IFlightStatus {
    // using Counters for Counters.Counter;
    // Counters.Counter private _flightIds;
    // Counters.Counter private _insuranceIds;
    
    //uint256 public constant MIN_TIME_BEFORE_DEPARTURE = 5 * 24 hours;
    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;
    
    // Maximum time before departure for applying
    //uint256 public constant MAX_TIME_BEFORE_DEPARTURE = 60 * 24 hours;
    using Plugin for Plugin.Request;

    //Plugin token instance
    // PluginClient pluginToken; 

    uint256 private constant ORACLE_PAYMENT = 0.001 * 10**18;
     uint public fiveHourTimeStamp;
        uint public fiveDayTimeStamp;
    // address
    address public owner;
    mapping(bytes => mapping(address => FlightInsurance)) public insurances;
    mapping(uint256 => mapping(address => FlightMaster)) public flights;
    mapping(bytes32 => FlightInsurance) public claims;
    mapping(bytes => mapping(address => bytes32)) public claimRequest;
    mapping(bytes => PassengerDetails) public passenger;
    mapping(bytes => AirlineDetails) public airline;

    constructor(address _pli) {
        setPluginToken(_pli);
        //setPublicPluginToken(_pli);
        owner = msg.sender;
        // _flightIds.increment();
        // _insuranceIds.increment();
    }

    modifier only_owner() {
        require(owner == msg.sender);
        _;
    }

    // modifier onlyWhitelistedAirlines(address _airlineAddress) {
    //     require(airline);
    //     _;
    // }

    event FlightEvents(
        uint256 flightId,
        
        string eventType,
        
        uint256 performedOn
    );

    event PassengerEvents(
        bytes passengerKey,
        string eventType,
        address performedBy,
        uint256 performedOn
    );

    event airlineEvents(
        bytes airlineKey,
        string eventType,
        address performedBy,
        uint256 performedOn
    );

    event InsuranceEvents(
        bytes insuranceId,
        string eventType,
        address passenger,
        address performedBy,
        uint256 performedOn
    );

    //Initialize event requestCreated
    event requestCreated(
        address indexed requester,
        bytes32 indexed jobId,
        bytes32 indexed requestId
    );

    //Initialize event RequestPermissionFulfilled
    event RequestPermissionFulfilled(
        bytes32 indexed requestId,
        uint256 indexed otp
    );

    event submitMyClaimLog(
        bytes32 requestId

    );
    // event dayEvent(
    //     uint timstamp,
    //     uint fiveHours,
    //     uint fiveDays,
    //     uint registeredOn
    // );
    //daysFromDate calculates the epoch time
    function _daysFromDate(
        uint year, 
        uint month, 
        uint day) internal pure returns (uint _days) {
        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }
    //timestampDepartDateTime converts the given time to epoch format
    function _timestampDepartDateTime(uint timestamp) internal pure returns (uint fiveHoursB4Departure, uint fiveDaysB4Departure) {
        // Minimum time before departure for applying insurance is 5 hours
        fiveHoursB4Departure = (timestamp - 300 * 60);
        // Maximum time before departure for applying insurance is 5 days
        fiveDaysB4Departure = (timestamp - 7200 * 60);
        // emit dayEvent(
        //     timestamp,
        //     fiveHoursB4Departure,
        //     fiveDaysB4Departure,
        //     block.timestamp
        // );
    }

    //Register Passenger
    //Error code: PR
    function passengerRegister(
        address _passengerAddress,
        string memory _passengerPnr,
        bytes memory _airlineKey
    ) public returns(bytes memory){
        bytes memory passengerKey = getPassengerKey(_passengerAddress,_passengerPnr,_airlineKey);
        require(passenger[passengerKey].passengerAddress != _passengerAddress, "ERROR:FDI-PR-01:PASSENGER_REGISTERED");
        passenger[passengerKey] = PassengerDetails(
            _passengerAddress,
            _passengerPnr,
            _airlineKey
        );
        //passenger[passengerKey] = true;
        emit PassengerEvents(
            passengerKey,
            "Passenger Registered",
            msg.sender,
            block.timestamp
        );
        return passengerKey;

    }

    //Passenger Utility
    function getPassengerKey(address _passengerAddress,string memory _passengerPnr, bytes memory _airlineKey) pure internal returns(bytes memory) {
        return abi.encodePacked('FDI-PA-',_passengerAddress,_passengerPnr, _airlineKey);
    }

    //Register Airlines
    //Error code: ALR
    function airlineRegister(
        address _airlineAddress,
        string memory _iataSymbol,
        string memory _airlineName
    ) public returns(bytes memory){
        bytes memory airlineKey = getAirlineKey(_airlineAddress,_iataSymbol,_airlineName);
        //require(airline[airlineKey] != _airlineAddress, "Airline exists");
        require(airline[airlineKey].airlineAddress != _airlineAddress, "ERROR:FDI-ALR-01:AIRLINE_REGISTERED");
        airline[airlineKey] = AirlineDetails(
            _airlineAddress,
            airlineKey,
            _iataSymbol,
            _airlineName,
            false
        );
        emit airlineEvents(
            airlineKey,
            "Airline Registered",
            msg.sender,
            block.timestamp
        );
        return airlineKey;

    }

    //Airlines Utility
    function getAirlineKey(address _airlineAddress,string memory _iataSymbol, string memory _airlineName) pure internal returns(bytes memory) {
        return abi.encodePacked('FDI-AL-',_airlineAddress,_iataSymbol,_airlineName);
    }
    // Register Flight
    // function registerFlights(
    //     address _flightAddress,
    //     bytes32 _carrierFlightNumber,
    //     string memory _serviceProviderName
    // ) public returns (uint256) {
    //     uint256 _flightId = _flightIds.current();
    //     _flightIds.increment();

    //     flights[_flightId][_flightAddress] = FlightMaster(
    //         _flightId,
    //         _carrierFlightNumber,
    //         _serviceProviderName,
    //         _flightAddress,
    //         block.timestamp,
    //         msg.sender
    //     );
    //     emit FlightEvents(
    //         _flightId,
    //         "Flight Registered",
    //         msg.sender,
    //         msg.sender,
    //         block.timestamp
    //     );

    //     return _flightId;
    // }
    // Airline stake fund for Insurance 
    //ERROR code: SAS
    function setAirlineStake(uint256 _stakeFund, address _airlineAddress, bytes memory _airlineKey) public returns(bool) {

        require(airline[_airlineKey].airlineAddress == _airlineAddress, "ERROR:FDI-SAS-01:INVALID_AIRLINE");
        require(airline[_airlineKey].funded == false, "ERROR:FDI-SAS-02:AIRLINE_FUNDED");
        // PliTokenInterface pli = PliTokenInterface(pluginTokenAddress());
        // pli.transferFrom(msg.sender, address(this), _stakeFund);
        
        airline[_airlineKey].funded = true;
        emit airlineEvents(
            _airlineKey,
            "Airline Funded",
            msg.sender,
            block.timestamp
        );
        return true;
    }

    // Book Flight Delay Insurance
    // Error code: BIS
    function bookInsurance(
        string memory _flightIcao,
        bytes memory _passengerKey,
        bytes memory _airlineKey, //Only registered airlines are fetched from the map "airline"
        uint256 _departureTimeStamp,
        uint256 _arrivalTimeStamp

    ) public returns (bytes memory) {
        // uint256 _insuranceId = _insuranceIds.current();
        // _insuranceIds.increment();
        //require(insurances[_policyKey] == false, "Policy has already been issued");
        // uint departTimeStamp;
        // uint public fiveHourTimeStamp;
        // uint public fiveDayTimeStamp;
        
        // (departTimeStamp, 
        (fiveHourTimeStamp, fiveDayTimeStamp) = _timestampDepartDateTime(_departureTimeStamp);
        // uint arrivalDateTime = _timestampArrivalDateTime(_departureTime);

        require(_arrivalTimeStamp > _departureTimeStamp, "ERROR:FDI-BIS-01:ARRIVAL_BEFORE_DEPARTURE_TIME");
        require(block.timestamp < fiveHourTimeStamp, "ERROR:FDI-BIS-02:FLIGHT_DEPARTURE_LESS_THAN_5_HOURS");
        require(block.timestamp > fiveDayTimeStamp, "ERROR:FDI-BIS-02:FLIGHT_DEPARTURE_LESS_THAN_5_DAYS");
        
        bytes memory _policyKey = insuranceKeyGen(_passengerKey,_flightIcao,_airlineKey);
        
        insurances[_policyKey][passenger[_passengerKey].passengerAddress] = FlightInsurance(
        //insurances[_insuranceId][_passengerAddress] = FlightInsurance(
            _policyKey,
            _passengerKey,
            _flightIcao,
            _departureTimeStamp,
            _arrivalTimeStamp,
            block.timestamp,
            FlightStatus(1),
            false,
            false,
            PolicyStatus(0)
        );

        emit InsuranceEvents(
            _policyKey,
            "Insurance Booked",
            msg.sender,
            msg.sender,
            block.timestamp
        );

        return _policyKey;
    }

    //Insurance utility
    function insuranceKeyGen(bytes memory _passengerKey,string memory _flightIcao, bytes memory _airlineKey) pure internal returns(bytes memory) {
        return abi.encodePacked('FDI-POLICY-',_passengerKey,_flightIcao,_airlineKey);
    }

    //Claim Processing
    //Erro code: SMC
    function submitMyClaim(
        bytes memory _policyKey,
        bytes memory _passengerKey,
        address _oracleAddress,
        uint256 _arrivalTime, //Need to be queried with avaiatiostack api about the flight arrival status using flight_icao and departure dateTime
        string memory _jobid
    ) public {
        FlightInsurance memory fin = insurances[_policyKey][msg.sender];
        require(insurances[_policyKey][msg.sender].isExist == true, "ERROR:FDI-SMC-01:PPLICY_PASSENGER_KEY_NOT_FOUND");
        require(passenger[fin.passengerKey].passengerAddress != address(0),"ERROR:FDI-SMC-02:ZERO_ADDRESS");
        // require(insurances[_policyKey][passenger[_passengerKey].passengerAddress].passengerKey == _passengerKey,"ERROR:FDI-SMC-02:ADDRESS_MISMATCH");
        require(fin.processed == false, "ERROR:FDI-SMC-03:POLICY_PROCESSED");
        require(fin.policystatus == PolicyStatus(0), "ERROR:FDI-SMC-04:POLICY_CLAIMED");
        require(fin.arrivalOn != _arrivalTime, "ERROR:FDI-SMC-05:ON-TIME_ARRIVAL");

        Plugin.Request memory req = buildPluginRequest(
            stringToBytes32(_jobid),
            address(this),
            this.fulfillClaimInquiry.selector
        );
        req.addUint("until", fin.arrivalOn);
        bytes32 reqId = sendPluginRequestTo(
            _oracleAddress,
            req,
            ORACLE_PAYMENT
        );
        claims[reqId] = fin;
        claimRequest[_policyKey][msg.sender] = reqId;
        fin.policystatus = PolicyStatus(1);

        emit submitMyClaimLog(reqId);
    }

    //Flight Status
    //Error code: FDC
    function flightDetailsCheck(
        bytes memory _policyKey,
        bytes memory _passengerKey
    ) public view returns(string memory,uint256,uint256){
        FlightInsurance memory fin = insurances[_policyKey][msg.sender];
        // require(insurances[_policyKey][msg.sender].isExist == true, "ERROR:FDI-FDC-01:");
        require(insurances[_policyKey][passenger[_passengerKey].passengerAddress].flightStatus == FlightStatus(0), "ERROR:FDI-FDC-01:FLIGHT_UNSCHEDULED");
        return (fin.flightIcao,fin.departureOn,fin.arrivalOn);   
    }

    function fulfillClaimInquiry(bytes32 _requestId, FlightStatus _flightStatus)
        public
        recordPluginFulfillment(_requestId)
    {
        FlightInsurance memory fin = claims[_requestId];
        fin.processed = true;
        fin.flightStatus = FlightStatus(_flightStatus);
    }

    //String to bytes to convert jobid to bytest32
    function stringToBytes32(string memory source)
        private
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }
}
