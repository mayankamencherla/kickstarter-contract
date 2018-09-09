pragma solidity ^0.4.17;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint minAmount) public {
        address manager = msg.sender;
        address newCampaign = new Campaign(minAmount, manager);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[]) {
        return deployedCampaigns;
    }
}

contract Campaign {

    // Defines the instance of the request
    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        // Set of approvals for the request
        mapping(address => bool) approvals;
        // Number of yes votes
        uint approvalCount;
    }

    // List of requests by the manager
    Request[] public requests;
    // Initiator of crowdfunding campaign
    address public manager;
    // Manager defined min contribution for each investor
    uint public minimumContribution;
    // Investors in the campaign
    mapping(address => bool) public approvers;
    // Number of contributors
    uint public contributorsCount;

    // manager restriction
    modifier restricted() {
        require(msg.sender == manager,
            "Only the manager can access this method");
        _;
    }

    constructor(uint minimum, address sender) public {
        manager = sender;
        minimumContribution = minimum;
    }

    // Payable
    function contribute() public payable {
        require(msg.value > minimumContribution, 
        "Investment needs to be higher for this campaign");
    
        // Add a new investor to the approvers
        approvers[msg.sender] = true;
        contributorsCount++;
    }

    // Only manager can create a request
    function createRequest(string description, uint value, address recipient) 
        public restricted {
            // Request is a memory variable
            // storage variables are instance variables
            Request memory newRequest = Request({
                description: description,
                value: value,
                recipient: recipient,
                complete: false,
                approvalCount: 0
                // Not needed to instantiate reference 
                // type like mapping type: approvals
            });

            requests.push(newRequest);
    }

    // Called by each contributor to approve a spending request
    function approveRequest (uint index) public {
        // Same person can only vote once
        // Avoid for loops as they cost a lot of gas
        // Avoid arrays for the same reason
        require(approvers[msg.sender],
            "Only contributors can approve request");

        // We want to modify the storage variable
        Request storage request = requests[index];

        require(!request.approvals[msg.sender],
            "One can only approve a request once");
        
        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest (uint index) 
        public restricted {
            // Modifying request in storage
            Request storage request = requests[index];

            require(2 * request.approvalCount > contributorsCount, 
                "Needs >50% approvals");

            require(!request.complete, 
                "Cannot finalize a completed request");

            request.complete = true;

            request.recipient.transfer(request.value);
    }
}
