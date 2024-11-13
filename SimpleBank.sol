// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

/**
 * @title SimpleBank
 * @dev Smart contract para gestionar un banco sencillo donde los usuarios pueden registrarse, depositar y retirar fondos.
 */
contract SimpleBank {
    struct User {
        string firstName;
        string lastName;
        uint256 balance;
        bool isRegistered;
    }

    mapping(address => User) public users;
    address public owner;
    address public treasury;
    uint256 public fee;
    uint256 public treasuryBalance;

    event UserRegistered(address indexed userAddress, string firstName, string lastName);
    event Deposit(address indexed userAddress, uint256 amount);
    event Withdrawal(address indexed userAddress, uint256 amount, uint256 fee);
    event TreasuryWithdrawal(address indexed owner, uint256 amount);

    modifier onlyRegistered() {
        require(users[msg.sender].isRegistered, "User is not registered");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /**
     * @dev Constructor del contrato
     * @param _fee El fee en puntos básicos (1% = 100 puntos básicos)
     * @param _treasury La dirección de la tesorería
     */
    constructor(uint256 _fee, address _treasury) {
        require(_treasury != address(0), "Treasury address cannot be zero");
        owner = msg.sender;
        fee = _fee;
        treasury = _treasury;
    }

    /**
     * @dev Función para registrar un nuevo usuario
     * @param _firstName El primer nombre del usuario
     * @param _lastName El apellido del usuario
     */
    function register(string calldata _firstName, string calldata _lastName) external {
        require(bytes(_firstName).length > 0 && bytes(_lastName).length > 0, "Name and lastname cannot be empty");
        require(!users[msg.sender].isRegistered, "User is already registered");

        users[msg.sender] = User(_firstName, _lastName, 0, true);
        emit UserRegistered(msg.sender, _firstName, _lastName);
    }


    function deposit(uint256 amount) external payable onlyRegistered {
        require(amount > 0, "Deposit amount must be greater than 0");
        users[msg.sender].balance += amount;
        emit Deposit(msg.sender, amount);
    }

    /**
     * @dev Función para verificar el saldo del usuario
     * @return El saldo del usuario
     */
    function getBalance() external view onlyRegistered returns (uint256) {
        return users[msg.sender].balance;
    }

    /**
     * @dev Función para retirar fondos de la cuenta del usuario
     * @param _amount La cantidad a retirar
     */
    function withdraw(uint256 _amount) external onlyRegistered {
        require(_amount > 0, "Withdrawal amount must be greater than 0");
        require(users[msg.sender].balance >= _amount, "Insufficient balance");

        uint256 feeAmount = (_amount * fee) / 10000;
        uint256 amountAfterFee = _amount - feeAmount;

        users[msg.sender].balance -= _amount;
        treasuryBalance += feeAmount;

        emit Withdrawal(msg.sender, amountAfterFee, feeAmount);
    }

    /**
     * @dev Función para que el propietario retire fondos de la cuenta de tesorería
     * @param _amount La cantidad a retirar de la tesorería
     */
    function withdrawTreasury(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Withdrawal amount must be greater than 0");
        require(treasuryBalance >= _amount, "Insufficient treasury balance");

        treasuryBalance -= _amount;
       
        emit TreasuryWithdrawal(msg.sender, _amount);
    }

    // Función para recibir Ether
    receive() external payable {
        require(users[msg.sender].isRegistered, "User is not registered");
        users[msg.sender].balance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    function getContractBalance() public view returns (uint256) {
    return address(this).balance;
    }

}