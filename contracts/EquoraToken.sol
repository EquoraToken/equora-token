// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; // Import Ownable

contract EquoraToken is ERC20, Ownable { // Inherit Ownable
    address public charityWallet; // Wallet for charity funds
    address public adminWallet; // Wallet for admin/project funds

    uint256 public charityFee = 400; // 4% (scaled to 10000 for precision)
    uint256 public adminFee = 100; // 1% (scaled to 10000 for precision)
    uint256 public feeDivisor = 10000; // Precision divisor for percentages

    mapping(address => bool) private isExcludedFromFee; // Excluded wallets (e.g., charity, admin)

    constructor(address _charityWallet, address _adminWallet) 
        ERC20("Equora", "EQR") 
        Ownable(msg.sender) // Pass deployer's address to Ownable
    {
        uint256 totalSupply = 8025000000 * 10 ** decimals(); // 8.025 billion tokens
        _mint(msg.sender, totalSupply); // Mint all tokens to deployer
        charityWallet = _charityWallet;
        adminWallet = _adminWallet;
    }

    // Override the transfer function to include transaction fees
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if (isExcludedFromFee[msg.sender] || isExcludedFromFee[recipient]) {
            // If sender or recipient is excluded, skip the fees
            return super.transfer(recipient, amount);
        } else {
            // Calculate fees
            uint256 charityAmount = (amount * charityFee) / feeDivisor;
            uint256 adminAmount = (amount * adminFee) / feeDivisor;
            uint256 totalFee = charityAmount + adminAmount;
            uint256 amountAfterFee = amount - totalFee;

            // Transfer fees
            super.transfer(charityWallet, charityAmount); // Send 4% to charity
            super.transfer(adminWallet, adminAmount); // Send 1% to admin/project wallet

            // Transfer remaining tokens to recipient
            return super.transfer(recipient, amountAfterFee);
        }
    }

    // Exclude or include an account from fees
    function excludeFromFee(address account, bool excluded) external onlyOwner {
        isExcludedFromFee[account] = excluded;
    }

    // Update the charity wallet
    function updateCharityWallet(address newCharityWallet) external onlyOwner {
        charityWallet = newCharityWallet;
    }

    // Update the admin wallet
    function updateAdminWallet(address newAdminWallet) external onlyOwner {
        adminWallet = newAdminWallet;
    }

    // Update the charity fee (max 10%)
    function updateCharityFee(uint256 newCharityFee) external onlyOwner {
        require(newCharityFee + adminFee <= feeDivisor / 10, "Total fee too high"); // Max 10%
        charityFee = newCharityFee;
    }

    // Update the admin fee (max 10%)
    function updateAdminFee(uint256 newAdminFee) external onlyOwner {
        require(charityFee + newAdminFee <= feeDivisor / 10, "Total fee too high"); // Max 10%
        adminFee = newAdminFee;
    }

    // Check if an account is excluded from fees
    function isAccountExcluded(address account) external view returns (bool) {
        return isExcludedFromFee[account];
    }
}
