//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@goplugin/contracts/src/v0.8/PluginClient.sol";

contract flightDelayCompensationPayment is PluginClient {
    //Operator

    string public name;
    address public plugin;
    address public contractOwner;

    string[] public users;
    mapping(address => mapping(uint256 => uint256)) private userToPayment;

    constructor(address _pluginToken) {
        name = "Flight Delay Compensation";
        setPluginToken(_pluginToken);
        //pluginToken = _pluginToken;
        contractOwner = msg.sender;
        //_initializeOwner();
        //_initializeOperator();
    }

    event OwnershipTransferred(address _owner, address _newOwner);

    event PaymentToUser(
        string return_msg,
        address _to,
        uint256 _tokens,
        uint256 _date
    );

    modifier isOwner(address _address) {
        require(_address == contractOwner, "Sender is not the owner");
        _;
    }

    //function to accept PLI by Contract
    function depositPLI(uint256 _amount) public {
        require(_amount > 0, "Deposit Amount must be greater than 0");
        //Transfer PLI token from msg.sender to this contract
        PliTokenInterface pli = PliTokenInterface(pluginTokenAddress());
        pli.transferFrom(msg.sender, address(this), _amount);
    }

    //To Transfer the ownership of contract
    function transferContractOwnership(address _newOwneraddress)
        public
        isOwner(msg.sender)
    {
        _transferOwner(_newOwneraddress);
    }

    //To Transfer the ownership of contract (Internal function)
    function _transferOwner(address _newOwneraddress) internal {
        require(_newOwneraddress != address(0));
        emit OwnershipTransferred(contractOwner, _newOwneraddress);
        contractOwner = _newOwneraddress;
    }

    //Send PLI token reward to beneficiary -
    //Bulk Transfer it can handle 255 Txn at a time
    function bulksendPLIReward(
        address[] memory _to,
        uint256[] memory _values,
        uint256[] memory _dateno
    ) public isOwner(msg.sender) returns (bool) {
        require(_to.length == _values.length);
        require(_to.length <= 255);
        PliTokenInterface pli = PliTokenInterface(pluginTokenAddress());
        uint256 _totalAmount = pli.balanceOf(address(this));
        for (uint256 i = 0; i < _to.length; i++) {
            if (_totalAmount >= _values[i]) {
                //PliTokenInterface pli = PliTokenInterface(pluginTokenAddress());
                pli.transfer(_to[i], _values[i]);
                userToPayment[_to[i]][_dateno[i]] = _values[i];
                emit PaymentToUser(
                    "Payment made to user",
                    _to[i],
                    _values[i],
                    _dateno[i]
                );
                //_totalAmount = _totalAmount.sub(_values[i]);
            } else {
                return false;
            }
        }
        return true;
    }

    //Send PLI token reward to beneficiary
    function sendPLIReward(
        address _to,
        uint256 _values,
        uint256 _dateno
    ) public {
        require(_values > 0, "Reward must be greater than 0");
        PliTokenInterface pli = PliTokenInterface(pluginTokenAddress());
        pli.transfer(_to, _values);
        userToPayment[_to][_dateno] = _values;
    }

    //Function to return total PLI balance available in the contract
    function getContractPLIBalance()
        public
        view
        returns (uint256 _pliInContract)
    {
        PliTokenInterface pli = PliTokenInterface(pluginTokenAddress());
        return pli.balanceOf(address(this));
    }

    //Function to get total PLI sent to an user
    function getUserPaymentDetails(address _userAddress, uint256 _date)
        public
        view
        returns (uint256 _tokens)
    {
        return userToPayment[_userAddress][_date];
    }
}
