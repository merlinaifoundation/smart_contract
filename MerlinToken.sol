// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MerlinToken (MRN)
 * @dev Implementation of the Merlin Token
 * 
 * This token is minted exclusively as a reward for valuable contributions to the Merlin ecosystem.
 * There is NO pre-mined supply - all tokens are created through meritocratic value contribution.
 * 
 * The token initially has transfers disabled to ensure that tokens remain with their
 * rightful earners until the ecosystem matures. Only minting and burning operations
 * are allowed during this phase.
 * 
 * The contract includes ownership transfer functionality for continuity, including an
 * emergency recovery mechanism that can be set up for safety.
 * 
 * Future considerations:
 * - A controlled mechanism for limited sales might be implemented in the future
 *   to maintain liquidity, but this is not currently in scope.
 */
contract MerlinToken is ERC20, ERC20Burnable, Ownable {
    // Flag to control if transfers are enabled
    bool public transfersEnabled;
    
    // Emergency recovery address that can claim ownership if needed
    address public recoveryAddress;
    // Timestamp after which recovery can be initiated (0 means recovery is not set up)
    uint256 public recoveryAvailableAfter;
    // Cooldown period required before recovery can be executed (default 30 days)
    uint256 public constant RECOVERY_DELAY = 30 days;

    /**
     * @dev Constructor initializes the token with zero supply
     * @param initialOwner The address that will own and control the token
     */
    constructor(address initialOwner) ERC20("Merlin", "MRN") Ownable(initialOwner) {
        // Transfers are initially disabled
        transfersEnabled = false;
    }

    /**
     * @dev Creates new tokens and assigns them to the specified address
     * @param to Recipient of the minted tokens
     * @param amount Number of tokens to mint
     * 
     * This function is restricted to the foundation (owner) to ensure that tokens 
     * are only created as rewards for genuine contributions to the Merlin ecosystem.
     * There is no arbitrary creation of tokens for speculative purposes.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Enables token transfers permanently
     * 
     * This function can only be called by the owner (foundation).
     * Once enabled, transfers cannot be disabled again.
     */
    function enableTransfers() public onlyOwner {
        transfersEnabled = true;
    }
    
    /**
     * @dev Sets up an emergency recovery address that can claim ownership
     * @param _recoveryAddress The address that will be able to claim ownership
     * 
     * Setting up a recovery address creates a safety mechanism in case the original
     * owner loses access to their wallet. The recovery can only be executed after
     * a 30-day cooldown period to prevent unauthorized ownership changes.
     */
    function setupRecoveryAddress(address _recoveryAddress) public onlyOwner {
        require(_recoveryAddress != address(0), "MRN: invalid recovery address");
        recoveryAddress = _recoveryAddress;
        recoveryAvailableAfter = block.timestamp + RECOVERY_DELAY;
    }
    
    /**
     * @dev Cancels the recovery mechanism by resetting the recovery address
     * 
     * This function can only be called by the current owner.
     */
    function cancelRecovery() public onlyOwner {
        recoveryAddress = address(0);
        recoveryAvailableAfter = 0;
    }
    
    /**
     * @dev Allows the recovery address to claim ownership after the cooldown period
     * 
     * This function can only be executed by the designated recovery address and
     * only after the cooldown period has passed.
     */
    function executeRecovery() public {
        require(msg.sender == recoveryAddress, "MRN: not recovery address");
        require(recoveryAvailableAfter > 0, "MRN: recovery not set up");
        require(block.timestamp >= recoveryAvailableAfter, "MRN: recovery not yet available");
        
        address previousOwner = owner();
        _transferOwnership(recoveryAddress);
        
        // Reset recovery mechanism after successful transfer
        recoveryAddress = address(0);
        recoveryAvailableAfter = 0;
        
        emit OwnershipTransferred(previousOwner, recoveryAddress);
    }

    /**
     * @dev Override of the _beforeTokenTransfer hook to implement transfer restrictions
     * 
     * This implementation prevents transfers when transfersEnabled is false.
     * Minting and burning operations are always allowed.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        // Allow minting (from == address(0)) and burning (to == address(0)) regardless of transfersEnabled
        if (from != address(0) && to != address(0)) {
            // This is a regular transfer (not mint/burn)
            require(transfersEnabled, "MRN: transfers are currently disabled");
        }
        
        super._beforeTokenTransfer(from, to, amount);
    }
}