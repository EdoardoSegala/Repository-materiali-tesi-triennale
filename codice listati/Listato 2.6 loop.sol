function cycle(uint x,uint y) public view returns(uint){
    uint result=0;
    for(uint i = 0;i<x;i++){
        result+=y;
    }
    return result;
    }
}