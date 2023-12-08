//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// 新手小白 谢谢
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
    uint256 public id; // id number id最大不超过 max/lim

    // WETH WBNB...  主网原本币
    IERC20 public WETH;

    // mint event mint事件
    event EVMmint(string op, string tick, uint id, uint amt);
    // transfer event transfer事件
    event EVMtransfer(string op, string tick, uint id, uint amt);

    // address => lim number   一个地址拥有的lim数量
    mapping(address => uint) LIMbalance;
    // address => uint[] number  一个地址拥有的ID数量
    mapping(address => uint[]) IDblance;

    constructor(
        string memory _tick, // _tick name 铭文名字
        uint256 _max, //_max number 铭文的总量
        uint256 _lim, //_lim number 单次铸造的铭文数量
        address _WETH //_WETH address  主网币的合约地址
    ) {
        //_max不能为0
        if (_max == 0) revert("_max cannot be 0");
        // _lim不能为0
        if (_lim == 0) revert("_lim cannot be 0");
        // 最大数量/单次铸造数量必须等于0 可以被整除
        if ((_max % _lim) != 0) revert("The remainder must be 0");

        p = "EVM-20"; // default p
        op = "Deploy"; // default op
        tick = _tick;
        max = _max;
        lim = _lim;
        WETH = IERC20(_WETH);
    }

    // mint function  铸造方法
    function mint(address _to) external returns (bool) {
        // id 最大不超过 max / lim
        if (id >= (max / lim)) revert("Mint has ended");
        // _to需要是自己地址 自己给自己转账
        if (_to != msg.sender) revert("Mint has User");
        bool seccsc = WETH.transfer(_to, 0);
        id += 1; //Every casting will make id+1 每次铸造都会让id+1
        LIMbalance[msg.sender] += lim; //Increase holdings 增加持有量
        IDblance[msg.sender].push(id); //Increase the number of IDs held 增加持有的id数量

        emit EVMmint("mint", tick, id, lim); //Trigger EVMmint Event 触发事件

        return seccsc;
    }

    // transfer function 铭文转账方法
    function transfer(address _to) external returns (bool) {
        // The transfer address cannot be empty 转账的地址不能为空
        if (_to == address(0)) revert("The address cannot be empty");
        // The quantity owned must meet the minimum quantity of lim 拥有的数量必须满足lim最小数量
        if (LIMbalance[msg.sender] < lim) revert("The balance cannot be 0");

        bool seccsc = WETH.transfer(_to, 0);

        LIMbalance[msg.sender] -= lim; //Reduced number of lims owned 拥有lim数量减少
        LIMbalance[_to] += lim; //Increase in number of recipients 接受者增加数量
        uint _toID = IDblance[msg.sender][IDblance[msg.sender].length - 1]; //First, take out the last one that owns the array 先将拥有数组的最后一个取出来
        IDblance[msg.sender].pop(); //Delete the last one in the array and give it to the receiver 将数组最后一个给删除给到接受者
        IDblance[_to].push(_toID); //Send the sent ID to the recipient 将发送的ID给到接受者

        emit EVMtransfer("transfer", tick, id, lim); //Trigger EVMtransfer Event 触发事件
        return seccsc;
    }

    //Query lim balance 查询lim余额
    function LIMbalanceOf(address _address) external view returns (uint) {
        return LIMbalance[_address];
    }

    // Query ID balance  查询ID余额
    function IDblanceOf(
        address _address
    ) external view returns (uint[] memory) {
        return IDblance[_address];
    }
}
