uses Crt;
const Max=16;
type segment=array[1..65535]of byte;
const ste:string='';
name='13.bmp';
type bitmap=record
  Fname:string[1];
  FileSize:longint;
  Noname:longint;
  Shift:longint;
  Noname2:longint;
  SizeX:longint;
  SizeY:longint;
  Noname4:word;
  Bits:byte;
  s:array[1..24] of byte;
end;

var
 Buffer:^Segment;
 buff:Array[1..1000] of byte;
 z,xm:word;bm:bitmap;
 b1,b2:^segment;
 xs,ys, ob1,ob2,sb1,sb2:word;
 ran1,ran2,s,s2,s3,y2,si,adress:longint;
 xres,curbank,i,shift:word;
 cikl:longint;bank1:byte;
r,g,b,sum,rb,gb,bb,pos,k,num:byte;
alex:array[1..Max] of byte;
f1:file of byte; f:file;
count1,count2:word;
 x,y,c,pix:word; eee:word;data,data1:byte;
pal1:array[1..1024] of byte;
pal:array[1..768] of byte;
fpal:file;

procedure SetBank(bank:word);
var X,temp:word;tmp:longint;
begin
tmp:=bank*longint(64) div 64;
temp:=round(int(tmp));
asm
 mov ax,$4f05
 mov bx,0
 mov dx,temp
 push dx
 int $10
 mov ax,$4f05
 mov bx,1
 pop dx
 int $10
end;
curbank:=bank;
end;

procedure SetVesa(mode:word);assembler;
asm
 mov ax,4f02h
 mov bx,mode
 int 10h
end;

procedure Plot(x,y:longint;color:byte);
var addres:longint;Ver:Word;
begin
addres:=y*xres+x;
Ver:=Addres shr 16;
If not (Ver=CurBank) Then SetBank(Ver);
mem[$A000:word(addres)]:=color;
end;

function GetPixel(x,y:longint):byte;
var addres:longint;
begin
addres:=y*xres+x;
SetBank((addres shr 16));
GetPixel:=mem[$A000:word(addres and 65535)];
end;

procedure SetText;assembler;
asm
mov ax,03
int $10
end;

procedure write_char(charact:char;x,y:word;color:byte);
var m:word;
    a,b:byte;
begin
for m:=1 to 8 do begin
a:=mem[61440:64110+m-1+ord(charact)*8];
b:=(1 and a) ;
if b<>0 then plot (x+7,y,color);
b:=(2 and a);
if b<>0 then plot (x+6,y,color);
b:=(4 and a);
if b<>0 then plot (x+5,y,color);
b:=(8 and a);
if b<>0 then plot (x+4,y,color);
b:=(16 and a);
if b<>0 then plot (x+3,y,color);
b:=(32 and a);
if b<>0 then plot (x+2,y,color);
b:=(64 and a);
if b<>0 then plot (x+1,y,color);
b:=(128 and a);
if b<>0 then plot (x,y,color);
inc (y);
end;
end;

Procedure Write_String(x,y:word;color:byte;text:string);
var le:byte;
begin
for le:=1 to length (text) do begin
Write_Char(text[le],x,y,color);
x:=x+8;
end;
end;

begin
SetVesa($103);
Xres:=800;
write_string (260,3,1,'VESA SVGA MODE #103h : 800x600x256');
assign(f,name);
reset(f,1);

assign(fpal,'nautilus.pal');
reset(fpal);

blockread(fpal,pal,768);
{for eee:=1 to 768 do pal[eee]:=(pal[eee] shr 2);}
y:=seg(pal);
x:=ofs(pal);
asm
xor bx,bx
mov cx,256
mov ax,y
mov es,ax
mov dx,x                {Пpисваивание палитpы используя функции BIOS}
mov al,18                      { по адpесу ES:DX }
mov ah,16
int 10h
end;
{offset 0Ah 4 bytes - size of header}
seek(f,0);
blockread(f,bm,sizeof(bm));
xm:=trunc((filesize(f)-bm.shift)/bm.sizey);
seek(f,bm.shift);
adress:=longint(800)*longint(y2)+longint(0);
Xs:=trunc((800-xm)/2);
Ys:=trunc((600-bm.sizey)/2);
New(Buffer);
For Y:=Bm.SizeY+Ys DownTo 0+Ys Do
 Begin
    BlockRead(F,Buff,Xm);
    For X:=1 To Xm Do
       Begin
          Plot(X+Xs,Y,Buff[X]);
       End;
 End;
Dispose(Buffer);
repeat
until port[$60]=1;
textmode(3);
end.