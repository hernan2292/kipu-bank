// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title KipuBank
 * @dev A secure banking smart contract that allows users to deposit and withdraw ETH
 * @notice This contract implements a personal vault system with withdrawal limits and global deposit caps
 */
contract KipuBank {

    // ========== CONSTANTS & IMMUTABLES ==========

    /// @dev Maximum amount that can be withdrawn in a single transaction
    uint256 public immutable WITHDRAWAL_LIMIT;

    /// @dev Maximum total deposits allowed in the bank
    uint256 public immutable BANK_CAP;

    // ========== STATE VARIABLES ==========

    /// @dev Total amount of ETH deposited in the bank
    uint256 public totalDeposits;

    /// @dev Total number of deposits made
    uint256 public depositCount;

    /// @dev Total number of withdrawals made
    uint256 public withdrawalCount;

    /// @dev Mapping from user address to their vault balance
    mapping(address => uint256) public vaults;

    // ========== CUSTOM ERRORS ==========

    /// @dev Thrown when deposit amount is zero
    error ZeroDepositAmount();

    /// @dev Thrown when withdrawal amount is zero
    error ZeroWithdrawalAmount();

    /// @dev Thrown when user has insufficient balance for withdrawal
    error InsufficientBalance();

    /// @dev Thrown when withdrawal amount exceeds the limit
    error WithdrawalLimitExceeded();

    /// @dev Thrown when deposit would exceed the bank cap
    error BankCapExceeded();

    /// @dev Thrown when ETH transfer fails
    error TransferFailed();

    /// @dev Thrown when bank cap is invalid (zero or too small)
    error InvalidBankCap();

    /// @dev Thrown when withdrawal limit is invalid (zero or exceeds bank cap)
    error InvalidWithdrawalLimit();

    // ========== EVENTS ==========

    /**
     * @dev Emitted when a user makes a deposit
     * @param user The address of the user making the deposit
     * @param amount The amount deposited
     * @param newBalance The user's new vault balance
     */
    event Deposit(address indexed user, uint256 amount, uint256 newBalance);

    /**
     * @dev Emitted when a user makes a withdrawal
     * @param user The address of the user making the withdrawal
     * @param amount The amount withdrawn
     * @param newBalance The user's new vault balance
     */
    event Withdrawal(address indexed user, uint256 amount, uint256 newBalance);

    // ========== MODIFIERS ==========

    /**
     * @dev Modifier to check if the deposit amount is valid
     */
    modifier validDeposit() {
        if (msg.value == 0) revert ZeroDepositAmount();
        _;
    }

    /**
     * @dev Modifier to check if the withdrawal amount is valid
     * @param amount The amount to be withdrawn
     */
    modifier validWithdrawal(uint256 amount) {
        if (amount == 0) revert ZeroWithdrawalAmount();
        if (amount > WITHDRAWAL_LIMIT) revert WithdrawalLimitExceeded();
        if (vaults[msg.sender] < amount) revert InsufficientBalance();
        _;
    }

    // ========== CONSTRUCTOR ==========

    /**
     * @dev Contract constructor
     * @param _withdrawalLimit Maximum amount that can be withdrawn in a single transaction
     * @param _bankCap Maximum total deposits allowed in the bank
     */
    constructor(uint256 _withdrawalLimit, uint256 _bankCap) {
        if (_bankCap == 0) revert InvalidBankCap();
        if (_withdrawalLimit == 0) revert InvalidWithdrawalLimit();
        if (_withdrawalLimit > _bankCap) revert InvalidWithdrawalLimit();

        WITHDRAWAL_LIMIT = _withdrawalLimit;
        BANK_CAP = _bankCap;
    }

    // ========== EXTERNAL FUNCTIONS ==========

    /**
     * @dev Allows users to deposit ETH into their personal vault
     * @notice The deposit amount is sent as msg.value
     */
    function deposit() external payable validDeposit {
        if (totalDeposits + msg.value > BANK_CAP) revert BankCapExceeded();

        unchecked {
            uint256 newTotalDeposits = totalDeposits + msg.value;
            _updateDepositState(msg.sender, msg.value, newTotalDeposits);
        }
    }

    /**
     * @dev Allows users to withdraw ETH from their personal vault
     * @param amount The amount to withdraw (must be <= WITHDRAWAL_LIMIT)
     */
    function withdraw(uint256 amount) external validWithdrawal(amount) {
        uint256 currentBalance = vaults[msg.sender];
        uint256 newBalance;

        unchecked {
            // Safe: validWithdrawal modifier already checked currentBalance >= amount
            newBalance = currentBalance - amount;
        }

        vaults[msg.sender] = newBalance;

        unchecked {
            // Safe: totalDeposits >= amount (guaranteed by vault balance check)
            totalDeposits -= amount;
            // Safe: withdrawalCount will never realistically overflow
            withdrawalCount++;
        }

        _safeTransfer(msg.sender, amount);

        emit Withdrawal(msg.sender, amount, newBalance);
    }

    /**
     * @dev Returns the vault balance for a specific user
     * @param user The address to query
     * @return The vault balance of the user
     */
    function getVaultBalance(address user) external view returns (uint256) {
        return vaults[user];
    }

    // ========== PRIVATE FUNCTIONS ==========

    /**
     * @dev Internal function to update state variables during deposit
     * @param user The address of the depositing user
     * @param amount The deposit amount
     * @param newTotalDeposits The new total deposits amount
     */
    function _updateDepositState(address user, uint256 amount, uint256 newTotalDeposits) private {
        uint256 newBalance = vaults[user] + amount;
        vaults[user] = newBalance;
        totalDeposits = newTotalDeposits;

        unchecked {
            depositCount++;
        }

        emit Deposit(user, amount, newBalance);
    }

    /**
     * @dev Internal function to safely transfer ETH
     * @param to The recipient address
     * @param amount The amount to transfer
     */
    function _safeTransfer(address to, uint256 amount) private {
        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) revert TransferFailed();
    }
}