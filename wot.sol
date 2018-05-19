pragma solidity ^0.4.21;


contract database{
    
    struct voter{
        bytes32 key;
        bool regst;
        bool voted;
        bool exist;
        bytes32 voto;
    }
    
    struct wot_voter{
        bytes32 key;   
        bool regst;
        uint time_span; //4 hours between member validations
        uint turn_span; //8 times before being valid
    }
    
    mapping(bytes32 => voter) public voters;
    mapping(bytes32 => wot_voter) public wot_voters;
}

contract wot_database is database{

    mapping(bytes32 => bytes32[]) self_to_valids;
    mapping(bytes32 => bytes32) valid_to_self;
    
    modifier in_preg(bytes32 indexed id){
        require (wot_voters[id].regst == false);
        _;
        require (wot_voters[id].regst == true);
    }
    
    modifier has_time(bytes32 key){
        require(block.timestamp >= (wot_voters[key].time_span + (6 * 1 hours)));
        _;
        require(block.timestamp <= (wot_voters[key].time_span + (6 * 1 hours)));
    }
}

contract wotregister is wot_database{

    //registration by sets
    function set_register(bytes32[] keys){
        
    }
    
    //solo registration
    function wot_register(bytes32 key) in_preg(key) returns (bytes32){
        wot_voters[key] = wot_voter(key, false, 4, 8);
        return key;
    }
    
    //validate a known person
    function wot_validate(bytes32 self, bytes32 who) has_time(self) public returns (bool){
        require(voters[self].exist == true); //require that validator exists, (properly registered and verified)
        require(voters[who].exist == false);
        
        wot_voters[who].turn_span -= 1; //validatee turns left to prove its existence
        wot_voters[self].time_span = now + (6 * 1 hours); //time to wait for validator to reevalidate someone
    }
}




