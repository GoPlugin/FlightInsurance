// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@goplugin/contracts/src/v0.8/PluginClient.sol";

contract FDC is PluginClient {
    using Counters for Counters.Counter;
    //Map the tokenIDCounter to counters
    Counters.Counter private policyIds;

    address public plugin;
    address public owner;

    //Staker Details - Policy Buyers
    struct passenger {
        uint256 policyid;
        uint256 policyAmount;
        address signerAddress;
        string userId;
        string packageId;
    }

    constructor(address _pli){
        setPluginToken(_pli);
        owner = msg.sender;
        plugin = _pli;
        policyIds.increment();
    }

    mapping(uint256 => passenger) public passengerCompDetails;
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    event CompensationPremiumPaid(
        string return_msg,
        uint256 policyId,
        string userId,
        uint256 premiumAmount
    );

    event withdrawnPli(
        address indexed owner,
        uint256 indexed amount,
        uint256 timestamp
    );

    event OwnershipTransferred(
        address indexed previousOwner, 
        address indexed newOwner
    );


    function delayCompensation(
        string memory _userId,
        string memory _packageId,
        address _signerAddress,
        uint256 _premiumAmount
    ) public returns (uint256 _policyId, bool _response) {
        PliTokenInterface pli = PliTokenInterface(pluginTokenAddress());

        require(
            pli.balanceOf(msg.sender) > _premiumAmount,
            "No sufficient balance to Pay premium"
        );

        //Policy ID will be trackedin Blockchain;
        uint256 _policyId = policyIds.current();
        policyIds.increment();

        pli.transferFrom(msg.sender, address(this), _premiumAmount);

        passengerCompDetails[_policyId] = passenger(
            _policyId,
            _premiumAmount,
            _signerAddress,
            _userId,
            _packageId
        );

        emit CompensationPremiumPaid(
            "PLI staked for Compensation",
            _policyId,
            _userId,
            _premiumAmount
        );
        return (_policyId, true);
    }

    //Withdraw pli
   function withdrawPli() public onlyOwner {
        PliTokenInterface pli = PliTokenInterface(pluginTokenAddress());
        uint256 pliBalance =  pli.balanceOf(address(this));
        pli.transfer(msg.sender,pliBalance);
        emit withdrawnPli(msg.sender, pliBalance,block.timestamp);
  }

  //To Transfer the ownership of contract 
    function transferContractOwnership(address _newOwneraddress)
        public onlyOwner()
    {
        _transferOwner(_newOwneraddress);
    }

    //To Transfer the ownership of contract (Internal function)
    function _transferOwner(address _newOwneraddress) internal {
        require(_newOwneraddress != address(0));
        emit OwnershipTransferred(owner, _newOwneraddress);
        owner = _newOwneraddress;
    }

}