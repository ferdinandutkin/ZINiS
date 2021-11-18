class Polynom extends Array<Number>  {
    constructor(...args : Number[]) {
        super(...args);
    }


    divide(other : Polynom) : Polynom  {
        return new Polynom(1, 2, 4);
    }
 


    private findK(other : Polynom) : Number | undefined {

        return undefined;

    }
}