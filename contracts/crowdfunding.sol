// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding{
    string public name;
    string public description;
    uint256 public goal;
    uint256 public deadline;
    address public owner;

    enum CampaignState {Active, Successfull, Failed}
    CampaignState public state;

    struct Tier {
        string name;
        uint256 amount;
        uint256 backers;
    }

    Tier[] public tiers;

    modifier onlyOwner(){
        require(msg.sender == owner, "Only the owner Have Access");
        _;
    }
    modifier campaignOpen(){
        require(state == CampaignState.Active, "Campaign is not active");
        _;
    }
    
    constructor(
        string memory _name,
        string memory _description, 
        uint256 _goal,
        uint256 _durartionInDays
    )
        {
            name = _name;
            description = _description;
            goal = _goal;
            deadline = block.timestamp + (_durartionInDays * 1 days);
            owner = msg.sender;
            state = CampaignState.Active;
        }


    function checkAndUpdateCampaignState() internal {
        if(state == CampaignState.Active){
            if(block.timestamp >= deadline) {
                 state = address(this).balance <= goal ? CampaignState.Successfull : CampaignState.Failed ; 
            }
            else{
                state = address(this).balance <= goal ? CampaignState.Successfull : CampaignState.Active ; 
            }
        }
    }


    function fund(uint256 _tierIndex) public payable campaignOpen{
        require(_tierIndex < tiers.length, "Invalid Tier");
        require(msg.value == tiers[_tierIndex].amount, "Incorrect amount");

        tiers[_tierIndex].backers++;

        checkAndUpdateCampaignState();
    }

    function addTier(string memory _name,
        uint256 _amount) public onlyOwner {
        require(_amount > 0, "Amount must be greater than 0");
        tiers.push(Tier(_name, _amount, 0));
    }

    function removeTier(uint256 _index) public onlyOwner {
        require(_index < tiers.length, "Tiers does not exist");
        tiers[_index] = tiers[tiers.length - 1];
        tiers.pop();
    }
    function withdraw() public onlyOwner {
        checkAndUpdateCampaignState();
        require(state == CampaignState.Successfull,"Campaign not successfull yet");
    
        uint256 balance = address(this).balance;
        require(balance > 0,"No balance to withdraw");

        payable(owner).transfer(balance);
    }

    function getContractBalance() public view returns (uint256){
        return address(this).balance;
    }
}