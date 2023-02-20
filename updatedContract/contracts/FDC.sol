//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
import "@goplugin/contracts/src/v0.8/PluginClient.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract FDCStaking is PluginClient {
    using Counters for Counters.Counter;
    //Map the tokenIDCounter to counters
    Counters.Counter private policyIds;

    address public plugin;
    address public contractOwner;

    //Staker Details - Policy Buyers
    struct passenger {
        uint256 policyid;
        uint256 policyAmount;
        address signerAddress;
        string userId;
        string packageId;
    }

    constructor(address _pli)
    {
        setPluginToken(_pli);
        contractOwner = msg.sender;
        plugin = _pli;
        policyIds.increment();
    }

    mapping(uint256 => passenger) public passengerCompDetails;

    event CompensationPremiumPaid(
        string return_msg,
        uint256 policyId,
        string userId,
        uint256 premiumAmount
    );


    function delayCompensation(string memory _userId, string memory _packageId, address _signerAddress, uint256 _premiumAmount)
        public
        returns (uint256 _policyId, bool _response)
    {

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

}
