// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Bibliotics {
    uint amountofbooks=0;

    struct book{
       string name;
       string picture ;
       bool avaliability;
    }
    mapping (uint=> book) booknumber;

    //..........................Admin status functions

    address admin;
    constructor(){
        admin=msg.sender;
    }

    function cash_out_profit() public {

        require(admin==msg.sender, "this function is available only to admin");

        payable(admin).transfer(address(this).balance);

    }

    function change_admin(address newadmin) public{
        require(admin==msg.sender,"only an admin can deligate administration status to other user");
        admin=newadmin;
    }



    //..........................work with books
    function create_book(string calldata name, string calldata image) public returns(uint256){
        require(admin==msg.sender,"only admin can publish new books");
        booknumber[amountofbooks]= book(name,image,true);
         amountofbooks= amountofbooks+1;
        return amountofbooks-1;

    }

    function view_book(uint bookID) public view returns(book memory){
        require(bookID<amountofbooks,"book with such ID does not exist");
        return booknumber[bookID];
    }


        
    //..........................renting sistem
    uint public rent_price_per_month = 100000 gwei;
    mapping(uint=> address) rented_to;

    function rent_book(uint bookID, uint months) public payable{
        require(bookID<amountofbooks,"book with such ID does not exist");
        require(rent_price_per_month*months==msg.value,"not enought funds");
        require(booknumber[bookID].avaliability,"book is already rented");
       // require(rented_to[bookID]==0x0000000000000000000000000000000000000000,"book is already rented");
       rented_to[bookID] = msg.sender;
       booknumber[bookID].avaliability = false;
    }

    function view_renter(uint bookID) public view returns(address){
        require(bookID<amountofbooks,"book with such ID does not exist");
        return rented_to[bookID];
    }

    function return_book(uint bookID) public {
        require(msg.sender == rented_to[bookID]||msg.sender == admin, "you dont rent this book yet");
        booknumber[bookID].avaliability= true;
        delete rented_to[bookID];
    }



    








}
