//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

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
    string public p;
    string public op;
    string public tick;
    uint256 public max;
    uint256 public lim;
    uint256 public id;

    // address public user = msg.sender;
    IERC20 public WETH;

    event EVMmint(string op, string tick, uint id, uint amt);
    event EVMtransfer(string op, string tick, uint id, uint amt);

    // 一个地址拥有多个lim
    mapping(address => uint) LIMbalance;
    // 一个地址拥有的ID
    mapping(address => uint[]) IDblance;

    // matic 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6
    // string memory _tick, uint256 _max, uint256 _lim, IERC20 _WETH
    constructor() {
        // if (_max == 0) revert("_max cannot be 0");
        // if (_lim == 0) revert("_lim cannot be 0");
        // if ((_max % _lim) != 0) revert("The remainder must be 0");

        p = "EVM-20";
        op = "Deploy";
        tick = "T1";
        max = 100;
        lim = 10;
        WETH = IERC20(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6);
    }

    function mint(address _to) external returns (bool) {
        if (id >= (max / lim)) revert("Mint has ended");
        if (_to != msg.sender) revert("Mint has User");
        bool seccsc = WETH.transfer(_to, 0);
        id += 1;
        LIMbalance[msg.sender] += lim;
        IDblance[msg.sender].push(id);

        emit EVMmint("mint", tick, id, lim);

        return seccsc;
    }

    function transfer(address _to) external returns (bool) {
        if (_to == address(0)) revert("The address cannot be empty");
        if (LIMbalance[msg.sender] < lim) revert("The balance cannot be 0");

        bool seccsc = WETH.transfer(_to, 0);

        LIMbalance[msg.sender] -= lim;
        LIMbalance[_to] += lim;

        uint _toID = IDblance[msg.sender][0];
        delete IDblance[msg.sender][0];
        IDblance[_to].push(_toID);

        emit EVMtransfer("transfer", tick, id, lim);
        return seccsc;
    }

    function LIMbalanceOf(address _address) external view returns (uint) {
        return LIMbalance[_address];
    }

    function IDblanceOf(
        address _address
    ) external view returns (uint[] memory) {
        return IDblance[_address];
    }
}
