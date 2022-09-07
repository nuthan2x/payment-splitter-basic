//SPDX-License-Identifier: MIT

pragma solidity >=0.8.16;

contract payment_splitter{
    address public owner = ""; // set initially to save constructor gas
    mapping(address => uint) public share_ofuser;

/*
    // currently accepting only ETH, for other erc20 tokens the contracts has to import the erc20 standard,
    // and initiate with token address of your liking.

    import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";

    // paste the above import => abovethe contact.

    IERC20 public immutable UDST = IERC20("0xdAC17F958D2ee523a2206206994597C13D831ec7");
    and use USDT. addon when transacting..., requesting that token balance inside this contract;

*/
    modifier onlyOwner(){
        require(msg.sender == owner,"you aint owner");
        _;
    }

    function transfer_Ownership(address _newowner) external onlyOwner {
        owner = _newowner;
    }

    receive() external payable {
        deposit_topool();
    }

    function deposit_topool() public payable{    
    }

    function get_poolBalance() public view returns(uint){
        return address(this).balance;
    }

//this suits if you are adding only users below 10 count and set different units/share of bool
//for large usercount better to define multiple mappings of( array of users => units/share), like different tier
//if you are splitting payments only to founders/devs better import the openzeppelin splitter ans customize
//still customizable by adding only users in one function and updating manually per user if usercount <5
//still reduce tx/gas fees of owner by only sending a signature of allowance function, and user can redeem within the deadline

    function add_users(address[] calldata _users,uint[] calldata units) external onlyOwner{

        for(uint i = 0; i < _users.length;i++){
            share_ofuser[_users[i]] = units[i];
        }
    }

    function update_shareofuser(address _user,uint _units) external onlyOwner{
        require(share_ofuser[_user] > 0,"this user doesnt share the pool amount");
        require(address(this).balance > _units,"insufficient pool balance,deposit and call this function");
        share_ofuser[_user] += _units;
    }

    function shareof_user(address _user) public view returns(uint){
        require(share_ofuser[_user] > 0,"this user doesnt share the pool amount");
        return share_ofuser[_user];
    }

    function withdraw() external {
        require(share_ofuser[msg.sender] > 0,"this user doesnt share the pool amount");

        uint _amount = share_ofuser[msg.sender];
        share_ofuser[msg.sender] =0;
        payable(msg.sender).transfer(_amount);

        // (bool sent,) = payable(msg.sender).call{value: _amount}("");
        // require(sent,"tx failed);
    }

    /*still can customize the contract with multiple token withdrawal options,if user wants to withdraw in BUSD,
     we have to do the swap from eth to busd on requested network so additional routing function*/
}
