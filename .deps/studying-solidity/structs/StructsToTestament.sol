contract StructsToTestament {
    struct Inheritor {
        address inheritorAddress;
        uint64 percentage;
    }

    struct Testament {
        Inheritor[] inheritors;
        bool exist;
        uint128 lastProofOfLife;
        uint256 balance;
        //salvar as moedas aqui
    }
}
