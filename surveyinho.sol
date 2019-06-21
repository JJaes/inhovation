pragma solidity ^0.4.18;

contract SurveyInho {
    address client;
    address respondent;
    
    uint public price;
    uint public Totprice;
    uint public participants;
    uint public amount;
    
    bool public finished = false; 

    Survey public survey;
    mapping(uint=>Survey) public surveyList;
    
    Answer public answer;
    mapping(address=>Answer) public answerList;
    
    struct Survey {
        uint surId;
        bytes32 question;
        bytes32 example1;
        bytes32 example2;
        bytes32 example3;
    }
    
    struct Answer{
        address toAddr;
        uint select1;
        uint select2;
        uint select3;
    }
    
    function SurveyInho() public {
        client = msg.sender;
        for(uint i=1 ; i<4 ; i++) {
            survey.surId = i;
            survey.question = 0x2020202020202020202020202020202020202020202020202020202020202020;
            survey.example1 = 0x2020202020202020202020202020202020202020202020202020202020202020;
            survey.example2 = 0x2020202020202020202020202020202020202020202020202020202020202020;
            survey.example3 = 0x2020202020202020202020202020202020202020202020202020202020202020;
            surveyList[survey.surId] = survey;
        }
    }

    //설문 등록
    function addSurvey(uint _surId, bytes32 _question, bytes32 _example1, bytes32 _example2, bytes32 _example3) public {
        require(msg.sender   == client);
        require(price        >  0     );
        require(participants >  0     );
       
        survey.surId = _surId;
        survey.question = _question;
        survey.example1 = _example1;
        survey.example2 = _example2;
        survey.example3 = _example3;
        surveyList[_surId] = survey;
    }
    
    function getSurvey(uint _surId) constant public returns(string rs) {
        rs = byte32ToString(surveyList[_surId].question);
    }
    
    function getExample1(uint _surId) public view returns(string rs) {
        rs = byte32ToString(surveyList[_surId].example1);
    }
    function getExample2(uint _surId) public view returns(string rs) {
        rs = byte32ToString(surveyList[_surId].example2);
    }
    function getExample3(uint _surId) public view returns(string rs) {
        rs = byte32ToString(surveyList[_surId].example3);
    }
    
    //가격 책정
    function commission(uint _price, uint _participants) public payable{
       require(msg.sender   == client);
       require(_price        >  0    );
       require(_participants >  0    );
       
       price        = _price       ;
       Totprice     = _price       ;
       participants = _participants;
    }

    function byte32ToString(bytes32 x) constant private returns(string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for(uint j=0 ; j<32 ; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if(char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }

        bytes memory bytesStringTrimmed = new bytes(charCount);
        for(j=0 ; j<charCount ; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        
        return string(bytesStringTrimmed);
    }
    
    function addAnswer(address _respondent, uint _select1, uint _select2, uint _select3) public{
        
        require(_respondent != address(0));
        require (finished == false);
        require(price > 0 );    //wallet 확인
        
        respondent = _respondent;
        answer.toAddr = respondent;
        answer.select1 = _select1;
        answer.select2 = _select2;
        answer.select3 = _select3;
        answerList[respondent] = answer;
    }
    
    function getAnswer(address _respondent) public view returns(uint rs) {
        rs = 0;
        rs += answerList[_respondent].select1 * 100;
        rs += answerList[_respondent].select2 * 10;
        rs += answerList[_respondent].select3 * 1;
    }
    
    //설문완료
    function doneAnswer() public {
        
        require (finished == false);
        
        require(msg.sender == respondent);
        require(price > 0 );    //wallet 확인
        
        amount = Totprice / participants;
        price -= amount;
        
        respondent.transfer(amount * 10**18);
       
        finished = true;
    }
}