unit mouse;
interface
uses crt,dos;
  const mess='Mouse module. Written by Alexander.';
  var registered:string;
function m_init(var n:byte):byte;
procedure m_setpage(n:word);
procedure m_show;
procedure m_hide;
procedure m_xy(x,y,x1,y1:integer);
procedure m_info(var x,y:word;var l,m,r:boolean);
procedure m_go(x,y:word);
procedure m_dblspeed(d:word);
procedure m_speed(x,y:integer);
function m_getpage:word;
implementation
const filename='key.dat';
function m_init(var n:byte):byte;
  var l,n1:integer;
  begin
   asm
     mov ax,00
     int 33h
     cmp ax,0ffffh
     je @@yes
     mov l,1
     mov n1,0
     jmp @@ex
@@yes:
     mov n1,bx
     mov l,0
@@ex:
   end;
   m_init:=l;
   n:=n1;
  end;
procedure m_show; assembler;
asm
mov ax,01h
int 33h
end;
procedure m_hide; assembler;
asm
mov ax,02h
int 33h
end;
procedure m_setpage(n:word);assembler;
asm
mov ax,1dh
mov bx,n
int 33h
end;
function m_getpage:word;
var j:word;
begin
asm
mov ax,1eh
mov j,bx
end;
m_getpage:=j;
end;
procedure m_info(var x,y:word;var l,m,r:boolean);
var b1,x1,y1:word;
begin
asm
mov ax,03h
int 33h
mov x1,cx
mov y1,dx
mov b1,bx
end;
x:=x1;y:=y1;
l:=false;r:=false;m:=false;
if (b1 and 1 )=1 then l:=true;
if (b1 and 2 )=2 then r:=true;
if (b1 and 4 )=4 then m:=true;
end;
procedure m_go(x,y:word);assembler;
asm
mov cx,x
mov dx,y
mov ax,04h
int 33h
end;
procedure M_XY(x,y,x1,y1:integer);assembler;
asm
mov ax ,07h
mov cx,x
mov dx,x1
int 33h
mov ax,08h
mov cx,y
mov dx,y1
int 33h
end;
procedure m_speed(x,y:integer); assembler;
asm
mov ax,0fh
mov cx,x
mov dx,y
int 33h
end;
 procedure m_dblspeed(d:word);assembler;
 asm
 mov ax,13h
 mov dx,d
 int 33h
 end;












end.