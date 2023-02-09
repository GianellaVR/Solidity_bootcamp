// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

//Smart Contract para crear un sistema de votación.
contract election {
    //Mapping para comprobar las direcciones de los votantes
    mapping(address=>bool) public voters;
    //Estructura de la elección.
    struct Choice {
        uint id;
        string name;
        uint votes;
    }

    //Estructura de la campaña de votación.
    struct Ballot{
        uint id;
        string name;
        Choice[] choices;
        uint end;
    }
    //Mapping de las elecciones.
    mapping(uint => Ballot) private ballots;

    //Variable para proxima votación.
    uint private nextBallotId;

     // Número total de votantes.
    uint public totalVoters;

    //Dirección del admin del sistema de votación.
    address public admin;

    //Mapping para comprobar si ya se ha votado.
    mapping(address => mapping(uint => bool)) private votes;

    //Número de votos límite
    uint  limite_votos;
    uint cant_votos = 1;

    //El admin es el que crea el smart contract y habrá una cantidad limite de votos
    constructor()  {
        admin = msg.sender;
        limite_votos = cant_votos;
    }

    //Función para añadir votantes (solo lo puede hacer el admin).
    function addVoters(address[] calldata _voters) external onlyAdmin(){
        //Añadiendo a los votantes en bucle.
        for(uint i = 0; i<_voters.length ;i++){
            //Definir los votantes y pasar el boleano a true.
            voters[_voters[i]]=true;
        }
    }
    

    //Función para crear la campaña de votación.
     function createBallot(string memory name, string[] memory choices, uint duration) public onlyAdmin {
        // Definir variable de id
        uint id = nextBallotId++;
        // Definir variable del nombre de la campaña de votación
        ballots[id].name = name;
        // Definir la variable del tiempo que dura la campaña
        ballots[id].end = block.timestamp + duration;
        // Loop para añadir la campaña de votación
        for (uint i = 0; i < choices.length; i++) {
            ballots[id].choices.push(Choice(i, choices[i], 0));
        }
    }


    //Crear un modifier para que solo el admin pueda añadir votantes y crear campañas.
    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }
    //Función de votar
    function vote(uint ballotId, uint choiceId)external{
        //Require de que solo los votantes pueden votar
        require(voters[msg.sender] == true);
        //Require de que solo se puede votar una vez.
        require(votes[msg.sender][ballotId] == false);
        //Require que solo se puede votar antes de finalizar la campaña.
        require(block.timestamp < ballots[ballotId].end);
        //Cambiar el bolleano de los votos a true.
        votes[msg.sender][ballotId] =true;
        //Añadir los votos a la campaña de votación.
        ballots[ballotId].choices[choiceId].votes++;
    }

    //Función para comprobar el resultado
    function results( uint ballotId) public view returns(Choice[]memory){
        //Require solo se puede comprobar una vez finalizada la campaña.
        require(block.timestamp> ballots[ballotId].end, "La votacion todavia no ha finalizado");
        //Retornar la elección de la votación.
        return ballots[ballotId].choices;
         
    
    }


}
