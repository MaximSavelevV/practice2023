// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract Bibliotics {
    //базисные структуры


     struct lottery{
         string name;

         uint foundation;
         uint wieners_pie;
         uint ticketprice;

         uint wieners_part_of_all;

         string start_date;
         string extra_info;

     }

     mapping (uint => lottery)lottery_code;



     mapping (uint => mapping (address => uint)) approval;
   

     uint amount_of_loteries = 0;
     

    // полномочия админа
    address admin;
    constructor(){
        admin=msg.sender;
    }

    function change_admin(address _newadmin) public{
        require(admin==msg.sender,"only an admin can deligate administration status to other user");
        admin= _newadmin;
    }



    //формация лотереи

    function create_new_lotery( uint _start_found_in_wei, string calldata _name, uint _wieners_pie_in_percents, uint _ticketprice_in_wei, uint _wieners_part_of_all_in_percents,string calldata _start_date,string calldata _extra_info ) public payable returns(uint){
        require(admin==msg.sender,"only admin can start new lottery");
        require(msg.value== _start_found_in_wei,"please, match sending summ and starting foundation");


        lottery_code[amount_of_loteries]= lottery(_name,  _start_found_in_wei, _wieners_pie_in_percents, _ticketprice_in_wei, _wieners_part_of_all_in_percents, _start_date, _extra_info);
        amount_of_loteries++;

        return(amount_of_loteries-1);
            }

    //партисипация и данные о лотереe
    function view_lottery(uint _lottery_id) public view returns(lottery memory){
        return lottery_code[_lottery_id];
    }

    function buy_a_lottery_ticket(uint _lottery_id, uint _amount_of_tickets)public payable{
        require(0<_lottery_id && _lottery_id<(amount_of_loteries-1), "no such lottery exists");
        require(msg.value== lottery_code[_lottery_id].ticketprice * _amount_of_tickets,"please,match tickets' cost and transfering summ");
        approval[_lottery_id][msg.sender]+= _amount_of_tickets;
    
    }



    //инициация лотереи и ее отмена
    function initialise_a_lottery(uint _lottery_id) public{
        require(0<_lottery_id && _lottery_id<(amount_of_loteries-1), "no such lottery exists");
        require(admin==msg.sender,"only admin can initialise a lottery");
        



    }
}
