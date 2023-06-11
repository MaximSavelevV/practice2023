// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract Blockchain_lottery {
    //базисные структуры


     struct lottery{
         string name;

         uint foundation;
         uint wieners_pie;
         uint ticketprice;

         uint wieners_part_of_all;
         uint amount_of_participants;

         string start_date;
         string extra_info;

     }

     mapping (uint => lottery)lottery_code;



     mapping (uint => mapping (uint => uint)) partisipant_tickets;
     mapping (uint => mapping (uint => address)) partisipant;
   

     uint amount_of_loteries = 0;

    function random(int a) private view returns (int) {
    int randomHash =  int(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    return (randomHash%(a-1)+1);

    }
     

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


        lottery_code[amount_of_loteries]= lottery(_name,  _start_found_in_wei, _wieners_pie_in_percents, _ticketprice_in_wei, _wieners_part_of_all_in_percents,0, _start_date, _extra_info);
        amount_of_loteries++;

        return(amount_of_loteries-1);
    }

    //партисипация и данные о лотереe
    function view_lottery(uint _lottery_id) public view returns(lottery memory){
        require(_lottery_id<amount_of_loteries, "no such lottery exists");
        return lottery_code[_lottery_id];
    }

    function buy_a_lottery_ticket(uint _lottery_id, uint _amount_of_tickets)public payable{
        require(_lottery_id<amount_of_loteries, "no such lottery exists");
        require(msg.value== lottery_code[_lottery_id].ticketprice * _amount_of_tickets,"please,match tickets' cost and transfering summ");
        
        partisipant_tickets[_lottery_id][lottery_code[_lottery_id].amount_of_participants]= _amount_of_tickets;
        partisipant[_lottery_id][lottery_code[_lottery_id].amount_of_participants]=msg.sender;


        lottery_code[_lottery_id].amount_of_participants+=1;
        lottery_code[_lottery_id].foundation+= lottery_code[_lottery_id].ticketprice * _amount_of_tickets;
    
    }



    //инициация лотереи и ее отмена
    function initialise_a_lottery(uint _lottery_id) public {
        require (_lottery_id<amount_of_loteries, "no such lottery exists");
        require(admin==msg.sender,"only admin can initialise a lottery");

        //передача необеспеченной доли админу
        payable(admin).transfer(lottery_code[_lottery_id].foundation*(100-lottery_code[_lottery_id].wieners_pie)/100);
        //рассчет числа купленных билетов на данную лотерею
         uint line=0;

         for(uint i=0;i<=lottery_code[_lottery_id].amount_of_participants;i++){
             line+=partisipant_tickets[_lottery_id][i];
         }

         uint lineX=line;
        

         //цикл до числа раз= числу билетов * часть выигрышных билетов
         for(uint i=0; i< (lineX*lottery_code[_lottery_id].wieners_part_of_all/100)+1;i++){
            int k = random(int(line)); //случайное к от 1 до числа билетов
            uint b=0; //счетчик маркера

             while(k>0){
                 k=k -int(partisipant_tickets[_lottery_id][b]);//цикл последовательно идет от записи к записи, вычитая из к число билетов на записи, двигая счетчик по вооброжаемой "линии рулетки" с отрезками-долями участников
                 b++;
             }
    //обнаружена запись b на которой счетчик упал <0 - прошло число билетов = к
             partisipant_tickets[_lottery_id][b-1]--; //удаление победившего билета из записи
             line--;

            payable(partisipant[_lottery_id][b-1]).transfer(lottery_code[_lottery_id].foundation*(lottery_code[_lottery_id].wieners_pie)/100/(lineX*lottery_code[_lottery_id].wieners_part_of_all/100+1)); //перевод доли 1/число победителей от обеспечения победителю
            
        }


    }

}
