package MyPkg;
    typedef logic[7:0] byte_t;
    typedef logic[15:0] byte2_t;
    typedef logic[31:0] byte4_t;
    typedef logic[39:0] byte5_t;
    typedef logic[55:0] byte7_t;
    typedef logic[63:0] byte8_t;
    typedef logic[87:0] byte11_t;

   struct packed 
   {
       logic draw;
       logic rdy;
       logic[3:0] cmd;
       logic[87:0] IR;
   } oled;
    
endpackage