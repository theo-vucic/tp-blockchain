pragma solidity ^0.8.25;

// SPDX-License-Identifier: GPL-3.0

import "./Ownable.sol";
import "./SafeMath.sol";

contract Election is Ownable {

using SafeMath for uint256;

    // Model a Candidate
    struct Resolution {
        uint256 id;
        string name;
        string presidentSeance;
        string scrutateur;
        string secretaire;
        uint voteCount;
        uint nbrPour;
        uint nbrNeutre;
        uint nbrContre;
        string resultat;
    }
   
   struct Voteur{
    bool vote;
    uint typevote;//0 contre, 1 neutre, 2 pour
   }


    // Store accounts that have voted
    mapping(address => Voteur) public voters;
    // Store Candidates
    // Fetch Candidate
    mapping(uint => Resolution) public resolutions;
    // Store Candidates Count
    uint public resolutionsCount;
    bool public voteEnding = false;

    // voted event
    event votedEvent ( uint indexed _resolutionId);

    function addResolution (string memory _name) public onlyOwner{
        resolutionsCount ++;
        resolutions[resolutionsCount] = Resolution(resolutionsCount, _name, "","","",0,0,0,0,"");
    }

    function vote (uint _resolutionId) public {
        // require that they haven't voted before
        require(!voters[msg.sender].vote);

        // require a valid candidate
        require(_resolutionId > 0 && _resolutionId <= resolutionsCount);
        require(voters[msg.sender].typevote >= 0 && voters[msg.sender].typevote <= 2, "Invalid vote");
        
        require(resolutions[_resolutionId].voteCount <4);
        //register type of vote
        if(voters[msg.sender].typevote == 0){
            resolutions[_resolutionId].nbrContre ++;
        }
        else if(voters[msg.sender].typevote == 1){
            resolutions[_resolutionId].nbrNeutre ++;
        }
        else if(voters[msg.sender].typevote == 2){
            resolutions[_resolutionId].nbrNeutre ++;
        }
        

        // record that voter has voted
        voters[msg.sender].vote = true;

        // update candidate vote Count
        resolutions[_resolutionId].voteCount ++;
        if(resolutions[_resolutionId].voteCount == 4){
            endvote(_resolutionId);
            voteEnding = true;
        }

        // trigger voted event
        emit votedEvent (_resolutionId);
    }

    function endvote(uint _resolutionId) public {
        resolutions[_resolutionId].resultat = result(resolutions[_resolutionId].nbrPour, resolutions[_resolutionId].nbrNeutre, resolutions[_resolutionId].nbrContre);
    }

    function result(uint nbrPour, uint nbrNeutre, uint nbrContre) public pure returns (string memory){
        if (nbrPour >= nbrNeutre && nbrPour >= nbrContre) {
            return "Pour";
        } else if (nbrNeutre >= nbrPour && nbrNeutre >= nbrContre) {
            return "Neutre";
        } else {
            return "Contre";
        }
    }

}
