// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Bibliotics is ERC1155 {
    uint amountofbooks=0;



   
    mapping (uint=> string) booknumber;

    //..........................Admin status functions

    address admin;
    constructor() ERC1155(""){
        admin=msg.sender;
    }

    function cash_out_profit() public {

        require(admin==msg.sender, "this function is available only to admin");

        payable(admin).transfer(address(this).balance);

    }

    function change_admin(address newadmin) public{
        require(admin==msg.sender,"only an admin can deligate administration status to other user");
        //uint[] memory tokens;
        //uint[] memory amount;
        //for(uint i=0; i<amountofbooks; i++) {
            //if (balanceOf(admin, i)!=0){
                //tokens[i]=i;
                //amount[i]=1;
           // }
            //else{
               // tokens[i]=i;
               // amount[i]=0;
           // }

        //}

        //safeBatchTransferFrom(admin, newadmin, tokens, amount, "");

        admin=newadmin;

    }



    //..........................work with books
    function create_book(string calldata _url) public returns(uint256){
        require(admin==msg.sender,"only admin can publish new books");
        booknumber[amountofbooks]= _url;
         
         _mint(admin, amountofbooks, 1, "");
        amountofbooks= amountofbooks+1;
        return amountofbooks-1;

    }

    function url(uint bookID) public view returns(string memory){
        require(bookID<amountofbooks,"book with such ID does not exist");
        return booknumber[bookID];
    }


        
    //..........................renting sistem
    uint public rent_price_per_month = 100000 gwei;
    mapping(uint=> address) rented_to;

    function rent_book(uint bookID, uint months) public payable{
        require(bookID<amountofbooks,"book with such ID does not exist");
        require(rent_price_per_month*months==msg.value,"not enought funds");
        require(balanceOf(admin, bookID)!=0,"book is already rented");
       // require(rented_to[bookID]==0x0000000000000000000000000000000000000000,"book is already rented");
       rented_to[bookID] = msg.sender;
       _setApprovalForAll(admin, msg.sender, true);
       safeTransferFrom(admin, msg.sender, bookID, 1, "");
       _setApprovalForAll(admin, msg.sender, false);

    }

    function view_renter(uint bookID) public view returns(address){
        require(bookID<amountofbooks,"book with such ID does not exist");
        return rented_to[bookID];

    }

    function return_book(uint bookID) public {
        require(msg.sender == rented_to[bookID]||msg.sender == admin, "you dont rent this book yet");
        safeTransferFrom(msg.sender, admin, bookID, 1, "");
        delete rented_to[bookID];
    }

    



    








}
