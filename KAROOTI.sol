// SPDX-License-Identifier: MIT LICENSE

pragma solidity 0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract KAROOTI is ERC20, ERC20Burnable, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => bool) controllers;

    uint256 private _totalSupply;
    uint256 private MAXSUP;
    uint256 constant MAXIMUMSUPPLY = 117000000000 * 10**18;

    constructor() ERC20("KAROOTI", "WHY") {
        _mint(msg.sender, 17000000000 * 10**18);
    }

    function mint(address to, uint256 amount) external nonReentrant {
        require(controllers[msg.sender], "Only controllers can mint");
        require(
            (MAXSUP + amount) <= MAXIMUMSUPPLY,
            "Maximum supply has been reached"
        );
        _totalSupply = _totalSupply.add(amount);
        MAXSUP = MAXSUP.add(amount);
        _balances[to] = _balances[to].add(amount);
        _mint(to, amount);
    }

    function burnFrom(address account, uint256 amount)
        public
        override
        nonReentrant
    {
        if (controllers[msg.sender]) {
            _burn(account, amount);
        } else {
            super.burnFrom(account, amount);
        }
    }

    function transfer(address to, uint256 value)
        public
        override
        nonReentrant
        returns (bool)
    {
        require(balanceOf(msg.sender) >= value, "Insufficient balance");
        // Get the current balance of the sender
        uint256 senderBalance = _balances[msg.sender];
        // Subtract the value from the sender's balance
        senderBalance = senderBalance.sub(value);
        // Update the balance of the sender
        _balances[msg.sender] = senderBalance;
        // Add the value to the balance of the recipient
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function addController(address controller) external onlyOwner nonReentrant {
        controllers[controller] = true;
    }

    function removeController(address controller)
        external
        onlyOwner
        nonReentrant
    {
        controllers[controller] = false;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function maxSupply() public pure returns (uint256) {
        return MAXIMUMSUPPLY;
    }
}
