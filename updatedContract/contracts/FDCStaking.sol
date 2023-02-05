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
    struct Stakers {
        uint256 policyid;
        address buyer;
        uint256 policyAmount;
        string userId;
        bool isPaid;
        bool isActive;
        bool isClaimed;
    }

    constructor(address _pli)
    {
        setPluginToken(_pli);
        contractOwner = msg.sender;
        plugin = _pli;
        policyIds.increment();
    }

    mapping(uint256 => Stakers) public policyDetails;
    mapping(uint256 => bool) public policyClaimStatus;
    mapping(address => Stakers[]) public purchaseDetails;

    event PolicyPremiumPaid(
        string return_msg,
        uint256 policyId,
        string userId,
        uint256 premiumAmount
    );

    event WithdrawPLI(string return_msg, address _address, uint256 _tokens);
    event StatusChecker(uint256 _policyId, bool status);

    function _onlyAuthorized() internal view {
        require(
            msg.sender == contractOwner,
            "Only FractionalNFT can perform this operation"
        );
    }

    modifier onlyAuthorized() {
        _onlyAuthorized();
        _;
    }

    function withdrawPLIFromStakingFarm(uint256 _amount) public onlyAuthorized {
        PliTokenInterface pli = PliTokenInterface(pluginTokenAddress());
        pli.transfer(msg.sender, _amount);
        emit WithdrawPLI(
            "PLI tokens withdrawn from Contract",
            msg.sender,
            _amount
        );
    }

    function buyPolicy(string memory _userId, uint256 _premiumAmount)
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

        policyDetails[_policyId] = Stakers(
            _policyId,
            msg.sender,
            _premiumAmount,
            _userId,
            true,
            true,
            false
        );

        purchaseDetails[msg.sender].push(policyDetails[_policyId]);

        emit PolicyPremiumPaid(
            "Premium paid for Policy",
            _policyId,
            _userId,
            _premiumAmount
        );
        return (_policyId, true);
    }

    function getbalanceOfUser() public view returns (uint256 _temp) {
        PliTokenInterface pli = PliTokenInterface(pluginTokenAddress());
        return pli.balanceOf(msg.sender);
    }

    function checkContractPLIBalance() public view returns (uint256 _balance) {
        PliTokenInterface pli = PliTokenInterface(pluginTokenAddress());
        return pli.balanceOf(address(this));
    }

    function updateClaim(uint256 _policyId)
        external
        returns (bool)
    {
        policyClaimStatus[_policyId] = true;
        return true;
    }

    function checkClaim(uint256 _policyId)
        public view
        returns (bool)
    {
        return policyClaimStatus[_policyId];
    }

    function getMyPolicies() public returns (Stakers[] memory) {
        return purchaseDetails[msg.sender];
    }
}
