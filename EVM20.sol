//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Novice novice, thank you
// ERC20
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract EVM20 {
    string public p; // EVM20
    string public op; // deploy
    string public tick; // tick name
    uint256 public max; // max number
    uint256 public lim; // lim number
    uint256 public id; // id number

    // WETH WBNB...
    IERC20 public WETH;
    //mint user
    address[] userData;

    // address => lim number
    mapping(address => uint256) LIMbalance;
    // address => uint[] number
    mapping(address => uint256[]) IDblance;
    //用户集合
    mapping(address => bool) isUser;

    // mint event
    event EVMmint(string op, string tick, uint256 id, uint256 amt);
    // transfer event
    event EVMtransfer(string op, string tick, uint256 id, uint256 amt);

    // string memory _tick, // _tick name
    // uint256 _max, //_max number
    // uint256 _lim, //_lim number
    // address _WETH //_WETH address
    constructor() {
        // if (_max == 0) revert("_max cannot be 0");
        // if (_lim == 0) revert("_lim cannot be 0");
        // if ((_max % _lim) != 0) revert("The remainder must be 0");

        p = "EVM-20"; // default p
        op = "Deploy"; // default op
        tick = "T1";
        max = 21000000;
        lim = 1000;
        // matic 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270
        // goerli 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6
        WETH = IERC20(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);
    }

    // mint function
    function mint(address _to) external returns (bool) {
        if (id >= (max / lim)) revert("Mint has ended");
        if (_to != msg.sender) revert("Mint has User");

        bool success = WETH.transfer(_to, 0);

        id += 1; //Every casting will make id+1
        LIMbalance[msg.sender] += lim; //Increase holdings
        IDblance[msg.sender].push(id); //Increase the number of IDs held

        if (!isUser[msg.sender]) {
            isUser[msg.sender] = true;
            userData.push(msg.sender);
        }

        emit EVMmint("mint", tick, id, lim); //Trigger EVMmint Event
        return success;
    }

    // transfer function
    function transfer(address _to) external returns (bool) {
        // The transfer address cannot be empty
        if (_to == address(0)) revert("The address cannot be empty");
        // The quantity owned must meet the minimum quantity of lim
        if (LIMbalance[msg.sender] < lim) revert("The balance cannot be 0");

        bool success = WETH.transfer(_to, 0);

        LIMbalance[msg.sender] -= lim; //Reduced number of lims owned
        LIMbalance[_to] += lim; //Increase in number of recipients
        uint256 _toID = IDblance[msg.sender][IDblance[msg.sender].length - 1]; //First, take out the last one that owns the array
        IDblance[msg.sender].pop(); //Delete the last one in the array and give it to the receiver
        IDblance[_to].push(_toID); //Send the sent ID to the recipient

        emit EVMtransfer("transfer", tick, id, lim); //Trigger EVMtransfer Event
        return success;
    }

    //Query lim balance
    function LIMbalanceOf(address _address) external view returns (uint256) {
        return LIMbalance[_address];
    }

    // Query ID balance
    function IDblanceOf(
        address _address
    ) external view returns (uint256[] memory) {
        return IDblance[_address];
    }

    function userDataOf() external view returns (address[] memory) {
        return userData;
    }
}
