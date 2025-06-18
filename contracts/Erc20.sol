// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract Erc20 {
    string public tokenName;
    string public tokenSymbol;
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    address public owner;
    
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _totalSupply
    ) {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        totalSupply = _totalSupply * (10 ** decimals);
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(_to != address(0), "Transfer to zero address");
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        require(_spender != address(0), "Approve to zero address");
        require(_spender != msg.sender, "Approve to self");
        
        allowances[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool) {
        require(_from != address(0), "Transfer from zero address");
        require(_to != address(0), "Transfer to zero address");
        require(balances[_from] >= _amount, "Insufficient balance");
        require(allowances[msg.sender][_from] >= _amount, "Insufficient allowance");
        
        balances[_from] -= _amount;
        balances[_to] += _amount;
        allowances[msg.sender][_from]-= _amount;
        
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        require(_to != address(0), "Mint to zero address");
        
        totalSupply += _amount;
        balances[_to] += _amount;
        
        emit Transfer(address(0), _to, _amount);
    }

    function burn(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        balances[msg.sender] -= _amount;
        totalSupply -= _amount;
        
        emit Transfer(msg.sender, address(0), _amount);
    }
}