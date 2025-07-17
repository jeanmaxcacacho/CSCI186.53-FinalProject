// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

/*
    Campaign creation should provide the necessary constructs
    to support: (i) accepting donations, (ii) withdrawal requests.
    
    FactoryContract where ChildContracts are the campaigns and the
    factory itself is the 'platform.'
*/

contract CampaignFactory {

    address[] public deployedCampaigns;
    
    event CampaignCreated(address campaignAddress, address creator);

    function createCampaign(string memory _campaignName) public {
        Campaign newCampaign = new Campaign(msg.sender, _campaignName);
        deployedCampaigns.push(address(newCampaign));

        emit CampaignCreated(address(newCampaign), msg.sender);
    }

    function getDeployedCampaigns() public view returns (address[] memory) {
        return deployedCampaigns;
    }

}

contract Campaign {
    address public creator;
    string public campaignName;
    mapping(address => uint256) public donorContributions;
    address[] public approvers;
    uint256 totalDonations;

    event DonationReceived(address donor, uint256 amount);
    event NewApprover(address approver);

    uint256 constant APPROVER_THRESHOLD = 3e14; // if donor has given $500 in ETH, elevate privilege

    constructor(address _creator, string memory _campaignName) {
        creator = _creator;
        campaignName = _campaignName;
        approvers.push(_creator); // creator is automatically an approver
    }

    // donation
    receive() external payable {
        donate();
    }

    function donate() public payable {
        require(msg.value > 0, "Donation must contain some amount of ether");
        
        // update donor's total contributions
        donorContributions[msg.sender] += msg.value;
        totalDonations += msg.value;
        
        // check if donor qualifies as approver
        if (donorContributions[msg.sender] >= APPROVER_THRESHOLD && !isApprover(msg.sender)) {
            approvers.push(msg.sender);
            emit NewApprover(msg.sender);
        }
        
        emit DonationReceived(msg.sender, msg.value);
    }

    // check if address is already an approver
    function isApprover(address _address) public view returns (bool) {
        for (uint i = 0; i < approvers.length; i++) {
            if (approvers[i] == _address) {
                return true;
            }
        }
        return false;
    }

    // see current contract balance, total amt of donations ever, approver amount, creator address
    function getSummary() public view returns (
        uint256,
        uint256,
        uint256,
        address
    ) {
        return (
            address(this).balance,
            totalDonations,
            approvers.length,
            creator
        );
    }
}