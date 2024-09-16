// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EscrowManager {
    address public owner;
    uint256 public escrowId;
    mapping(uint256 => Escrow) public escrows;

    struct Escrow {
        address buyer;
        address seller;
        address arbiter;
        uint256 amount;
        bool buyerOk;
        bool sellerOk;
        escrowStatus status;
    }

    enum escrowStatus {
        ONGOING,
        COMPLETED
    }

    event EscrowCreated(
        uint256 escrowId,
        address buyer,
        address seller,
        address arbiter,
        uint256 amount
    );
    event BuyerOk(uint256 escrowId);
    event SellerOk(uint256 escrowId);
    event Withdraw(uint256 escrowId, address recipient);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createEscrow(address _seller, address _arbiter) external payable {
        require(msg.value > 0, "Amount should be greater than 0");
        escrows[escrowId] = Escrow(
            msg.sender,
            _seller,
            _arbiter,
            msg.value,
            false,
            false,
            escrowStatus.ONGOING
        );
        emit EscrowCreated(escrowId, msg.sender, _seller, _arbiter, msg.value);
        escrowId++;
    }

    function updateBuyerApproval(uint256 _escrowId) external {
        Escrow storage escrow = escrows[_escrowId];
        require(
            msg.sender == escrow.buyer,
            "Only buyer can call this function"
        );
        escrow.buyerOk = true;
        emit BuyerOk(_escrowId);
    }

    function updateSellerApproval(uint256 _escrowId) external {
        Escrow storage escrow = escrows[_escrowId];
        require(
            msg.sender == escrow.seller,
            "Only seller can call this function"
        );
        escrow.sellerOk = true;
        emit SellerOk(_escrowId);
    }

    function withdrawToSellerByArbiter(uint256 _escrowId) external {
        Escrow storage escrow = escrows[_escrowId];
        require(escrow.status != escrowStatus.COMPLETED, "Escrow is completed");
        require(
            escrow.buyerOk && escrow.sellerOk,
            "Both buyer and seller must agree"
        );
        require(
            msg.sender == escrow.arbiter,
            "Only arbiter can call this function"
        );
        address payable recipient = payable(escrow.seller);
        recipient.transfer(escrow.amount);
        escrow.status = escrowStatus.COMPLETED;
        emit Withdraw(_escrowId, recipient);
    }

    function withdrawToSellerByEscrowManager(
        uint256 _escrowId
    ) external onlyOwner {
        Escrow storage escrow = escrows[_escrowId];
        require(escrow.status != escrowStatus.COMPLETED, "Escrow is completed");
        require(
            escrow.buyerOk && escrow.sellerOk,
            "Both buyer and seller must agree"
        );
        address payable recipient = payable(escrow.seller);
        recipient.transfer(escrow.amount);
        escrow.status = escrowStatus.COMPLETED;
        emit Withdraw(_escrowId, recipient);
    }

    function viewEscrow(
        uint256 _escrowId
    ) external view returns (Escrow memory) {
        return escrows[_escrowId];
    }

    function viewBalance() external view onlyOwner returns (uint256) {
        return address(this).balance;
    }
}
