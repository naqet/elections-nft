// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./NFT.sol";

contract ElectionsLogic is Ownable {
    struct Candidate {
        uint256 id;
        uint256 voteCount;
        string party;
        string name;
    }

    string[] public parties;
    Candidate[] public candidates;
    bool public isVotingEnabled;

    mapping(address => bool) private voted;
    address private nftAddress;

    constructor(address _nftAddress) Ownable(msg.sender) {
        nftAddress = _nftAddress;
        isVotingEnabled = true;
    }

    modifier onlyInVotingPhase() {
        require(
            !isVotingEnabled,
            "This function can be called only when voting is enabled"
        );
        _;
    }

    modifier onlyInConfigPhase() {
        require(
            isVotingEnabled,
            "This function can be called only when voting in disabled"
        );
        _;
    }

    function addParty(
        string memory _partyName
    ) public onlyOwner onlyInConfigPhase {
        require(
            !doesPartyExist(_partyName),
            "Party with this name already exists"
        );
        parties.push(_partyName);
    }

    function addCandidate(
        string memory _partyName,
        string memory _name
    ) public onlyOwner onlyInConfigPhase {
        require(doesPartyExist(_partyName), "Party does not exist");
        require(
            !doesCandidateExist(_name, _partyName),
            "Candidate with this name in that party already exists"
        );

        Candidate memory _newCandidate = Candidate(
            candidates.length,
            0,
            _partyName,
            _name
        );

        candidates.push(_newCandidate);
    }

    function doesCandidateExist(
        string memory _name,
        string memory _partyName
    ) private view returns (bool) {
        for (uint i = 0; i < candidates.length; i++) {
            if (
                Strings.equal(candidates[i].name, _name) &&
                Strings.equal(candidates[i].party, _partyName)
            ) {
                return true;
            }
        }
        return false;
    }

    function doesPartyExist(string memory _party) private view returns (bool) {
        for (uint i = 0; i < parties.length; i++) {
            if (Strings.equal(parties[i], _party)) {
                return true;
            }
        }
        return false;
    }

    function toggleVoting() public onlyOwner {
        isVotingEnabled = !isVotingEnabled;
    }

    function getAllCandidates() public view returns (Candidate[] memory) {
        return candidates;
    }

    function vote(
        string memory _partyName,
        string memory _candidateName
    ) public onlyInVotingPhase {
        require(doesPartyExist(_partyName), "Party does not exist");
        require(
            doesCandidateExist(_candidateName, _partyName),
            "Candidate does not exist"
        );
        require(!voted[msg.sender], "You have already voted");
        require(
            IERC721(nftAddress).balanceOf(msg.sender) > 0,
            "You do not have required NFT"
        );

        for (uint256 i = 0; i < candidates.length; i++) {
            Candidate memory _candidate = candidates[i];
            if (
                Strings.equal(_candidate.party, _partyName) &&
                Strings.equal(_candidate.name, _candidateName)
            ) {
                candidates[i].voteCount++;
                voted[msg.sender] = true;
            }
        }
    }
}
