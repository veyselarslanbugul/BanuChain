// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SurveyContract {
    // Anket yapısı
    struct Survey {
        string question;
        string[] options;
        mapping(string => uint256) votes;
        bool isActive;
    }

    // Kullanıcı yapısı
    struct User {
        address userAddress;  // Kullanıcının Ethereum cüzdan adresi
        bool isLoggedIn;
        uint256[] participatedSurveys;
        mapping(uint256 => string[]) surveyResponses;
        uint256 totalResponses;
    }

    mapping(address => User) public users; // Kullanıcıları saklayan harita
    Survey[] public surveys;                // Anketleri saklayan dinamik dizi

    address public admin; // Yönetici adresi

    // Yönetici olduğunu kontrol eden modifier
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    // Kontrat oluşturulduğunda yöneticiyi atayan constructor
    constructor() {
        admin = msg.sender;
    }

    // Yöneticinin anket oluşturmasına izin veren fonksiyon
    function createSurveyByAdmin(string memory _question, string[] memory _options) public onlyAdmin {
        Survey storage newSurvey = surveys.push();
        newSurvey.question = _question;
        newSurvey.options = _options;
        newSurvey.isActive = true;
    }

    // Yöneticinin bir kullanıcıyı oluşturmasına izin veren fonksiyon
    function createUserByAdmin(address _userAddress) public onlyAdmin {
        require(!users[_userAddress].isLoggedIn, "User is already logged in");

        User storage newUser = users[_userAddress];
        newUser.userAddress = _userAddress;
        newUser.isLoggedIn = true;
    }

    // Yöneticinin bir kullanıcıyı silebilmesine izin veren fonksiyon
    function deleteUserByAdmin(address _userAddress) public onlyAdmin {
        require(users[_userAddress].isLoggedIn, "User is not logged in");
        delete users[_userAddress];
    }

    // Yöneticinin bir anketi kapatmasına izin veren fonksiyon
    function closeSurveyByAdmin(uint256 _surveyIndex) public onlyAdmin {
        require(_surveyIndex < surveys.length, "Invalid survey index");
        surveys[_surveyIndex].isActive = false;
    }

    // Kullanıcının giriş yapmış olması gerektiğini kontrol eden modifier
    modifier onlyLoggedIn() {
        require(users[msg.sender].isLoggedIn, "User must be logged in");
        _;
    }

    // Verilen anket indeksinin geçerli olup olmadığını ve anketin aktif olup olmadığını kontrol eden modifier
    modifier surveyIsActive(uint256 _surveyIndex) {
        require(_surveyIndex < surveys.length, "Invalid survey index");
        require(surveys[_surveyIndex].isActive, "Survey is not active");
        _;
    }

    // Yeni bir kullanıcı oluşturan fonksiyon
    function createUser() public {
        require(!users[msg.sender].isLoggedIn, "User is already logged in");

        User storage newUser = users[msg.sender];
        newUser.userAddress = msg.sender;
        newUser.isLoggedIn = true;
    }

    // Kullanıcı girişini kontrol eden fonksiyon
    function loginUser() public {
        require(!users[msg.sender].isLoggedIn, "User is already logged in");
        users[msg.sender].isLoggedIn = true;
    }

    // Yeni bir anket oluşturan fonksiyon
    function createSurvey(string memory _question, string[] memory _options) public onlyLoggedIn {
        Survey storage newSurvey = surveys.push();
        newSurvey.question = _question;
        newSurvey.options = _options;
        newSurvey.isActive = true;
    }

    // Belirli bir ankete katılma ve cevapları kaydetme fonksiyonu
    function participateInSurvey(uint256 _surveyIndex, string[] memory _responses) public onlyLoggedIn surveyIsActive(_surveyIndex) {
        User storage currentUser = users[msg.sender];

        for (uint256 i = 0; i < _responses.length; i++) {
            currentUser.surveyResponses[_surveyIndex + i] = _responses;
            surveys[_surveyIndex].votes[_responses[i]] += 2;
        }

        currentUser.participatedSurveys.push(_surveyIndex);
        currentUser.totalResponses += _responses.length;
    }

    // Kullanıcının katıldığı anketlerin indekslerini döndüren fonksiyon
    function userParticipatedSurveys() public view onlyLoggedIn returns (uint256[] memory) {
        User storage currentUser = users[msg.sender];
        return currentUser.participatedSurveys;
    }

    // Kullanıcının verdiği cevapları döndüren fonksiyon
    function viewUserResponses() public view onlyLoggedIn returns (uint256, string[][] memory) {
        User storage currentUser = users[msg.sender];

        string[][] memory responses = new string[][](currentUser.totalResponses);
        uint256 responseCount = 0;

        for (uint256 i = 0; i < currentUser.participatedSurveys.length; i++) {
            uint256 surveyIndex = currentUser.participatedSurveys[i];
            string[] storage surveyResponses = currentUser.surveyResponses[surveyIndex];

            for (uint256 j = 0; j < surveyResponses.length; j++) {
                responses[responseCount] = surveyResponses;
                responseCount++;
            }
        }

        return (currentUser.totalResponses, responses);
    }

    // Belirli bir anketin sonuçlarını döndüren fonksiyon
    function viewSurveyResults(uint256 _surveyIndex) public view surveyIsActive(_surveyIndex) returns (string[] memory, uint256[] memory) {
        Survey storage survey = surveys[_surveyIndex];
        uint256 optionsCount = survey.options.length;

        string[] memory optionTexts = new string[](optionsCount);
        uint256[] memory optionVotes = new uint256[](optionsCount);

        for (uint256 i = 0; i < optionsCount; i++) {
            optionTexts[i] = survey.options[i];
            optionVotes[i] = survey.votes[survey.options[i]];
        }

        return (optionTexts, optionVotes);
    }
}
