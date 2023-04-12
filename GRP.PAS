unit Grp;
Interface
uses crt;
type ScreenType=array [1..64000] of byte;

var
Screen:^ScreenType;
VS_segment,VS_offset,VS_end:word;
procedure SPlot(x,y:word;color,scolor:byte);
procedure Error(name:string);
procedure GraphInit;
procedure GraphClose;
procedure Show;
procedure Plot(x,y:word;color:byte);
Function GetPixel(x,y:word):byte;
procedure DirectPlot(x,y:word;color:byte);
Function DirectGetPixel(x,y:word):byte;
procedure SWriteSpriteArray(x,y,x2,y2:word;sprite:array of byte;scolor:byte);
procedure WriteSpriteArray(x,y,x2,y2:word;sprite:array of byte);
implementation


procedure Error(name:string);
begin
asm
push ax
push sp
push bp
push si
push di
mov ax,03
int $10
pop di
pop si
pop bp
pop sp
pop ax
end;
writeln (name);
halt (1);
end;

procedure GraphInit;
var curmode:byte;
begin
asm
push ax
push sp
push bp
push si
push di
mov ax,$13
int $10
pop di
pop si
pop bp
pop sp
pop ax
end;
New (Screen);
VS_segment:=seg(Screen^);
VS_offset:=ofs(Screen^);
VS_END:=VS_offset+63999;
asm
push ax
push sp
push bp
push si
push di
mov ah,$0F
int $10
mov curmode,al
pop di
pop si
pop bp
pop sp
pop ax

end;
if curmode<>$13 then error ('Graph mode 320x200x256 not support.');
end;

procedure GraphClose;
begin
asm
push ax
push sp
push bp
push si
push di
mov ax,03
int $10
pop di
pop si
pop bp
pop sp
pop ax
end;
Dispose (Screen);
end;


procedure Show; assembler;
    asm
      push ds
      push es
      xor  si,si
      xor  di,di
      cld
      mov  ax,word(Screen+2)
      mov  ds,ax
      mov  ax,0A000h
      mov  es,ax
      mov  cx,32000
      rep  movsw
      pop  es
      pop  ds
    end;

procedure Plot(x,y:word;color:byte);assembler;
asm
push ds                            {14 clock}
mov ax,320                         {4 clock}
mov bx,y                           {12 clock}
mul bx                             {143 clock}
mov di,ax                          {2 clock}
add di,x                           {13 clock}
add di,VS_offset                   {13 clock}
mov ax,VS_segment                  {12 clock}
mov ds,ax                          {2 clock}
mov al,color                       {2 clock}
mov ds:[di],al                     {13 clock}
pop ds                             {12 clock}
end;                               {total 242 clock}

procedure SPlot(x,y:word;color,scolor:byte);assembler;
asm
push ds                            {14 clock}
mov al,scolor
mov bl,color
cmp al,bl
jz @@end
mov ax,320                         {4 clock}
mov bx,y                           {12 clock}
mul bx                             {143 clock}
mov di,ax                          {2 clock}
add di,x                           {13 clock}
add di,VS_offset                   {13 clock}
mov ax,VS_segment                  {12 clock}
mov ds,ax                          {2 clock}
mov al,color                       {2 clock}
mov ds:[di],al                     {13 clock}
@@end:
pop ds                             {12 clock}
end;                               {total 242 clock}

Function GetPixel(x,y:word):byte;assembler;
asm
push ds                            {14 clock}
mov ax,320                         {4 clock}
mov bx,y                           {12 clock}
mul bx                             {143 clock}
mov di,ax                          {2 clock}
add di,x                           {13 clock}
add di,VS_offset                   {13 clock}
mov ax,VS_segment                  {12 clock}
mov ds,ax                          {2 clock}
mov al,ds:[di]                     {13 clock}
pop ds                             {12 clock}
end;                               {total 242 clock}

Function DirectGetPixel(x,y:word):byte;assembler;
asm
push ds                            {14 clock}
mov ax,320                         {4 clock}
mov bx,y                           {12 clock}
mul bx                             {143 clock}
mov di,ax                          {2 clock}
add di,x                           {13 clock}
mov ax,$A000                       {12 clock}
mov ds,ax                          {2 clock}
mov al,ds:[di]                     {13 clock}
pop ds                             {12 clock}
end;                               {total 242 clock}

procedure DirectPlot(x,y:word;color:byte);assembler;
asm
push ds
mov ax,320
mov bx,y
mul bx
mov di,ax
add di,x
mov ax,$A000
mov ds,ax
mov al,color
mov ds:[di],al
pop ds
end;

procedure SWriteSpriteArray(x,y,x2,y2:word;sprite:array of byte;scolor:byte);
var Sprite_segment,Sprite_offset:word;
begin
Sprite_Segment:=seg(sprite);
Sprite_Offset:=ofs(sprite);
asm
push ds                            {14 clock}
push es
mov ax,320                         {4 clock}
mov bx,y                           {12 clock}
mul bx                             {143 clock}
mov di,ax                          {2 clock}
add di,x                           {13 clock}
add di,VS_offset                   {13 clock}
mov ax,VS_segment                  {12 clock}
mov ds,ax                          {2 clock}
mov ax,Sprite_segment
mov es,ax
mov si,Sprite_offset

mov dx,y2
@@3:
push di
push si
mov cx,x2
@@1:
mov al,es:[si]
cmp al,scolor
jz @@obhod
mov ds:[di],al                     {13 clock}
@@obhod:
inc di
add si,y2
loopnz @@1
pop si
inc si
pop di
add di,320
dec dx
jnz @@3

pop es
pop ds                             {12 clock}
end;
end;


procedure WriteSpriteArray(x,y,x2,y2:word;sprite:array of byte);
var Sprite_segment,Sprite_offset:word;
begin
Sprite_Segment:=seg(sprite);
Sprite_Offset:=ofs(sprite);
asm
push ds                            {14 clock}
push es
mov ax,320                         {4 clock}
mov bx,y                           {12 clock}
mul bx                             {143 clock}
mov di,ax                          {2 clock}
add di,x                           {13 clock}
add di,VS_offset                   {13 clock}
mov ax,VS_segment                  {12 clock}
mov ds,ax                          {2 clock}
mov ax,Sprite_segment
mov es,ax
mov si,Sprite_offset

mov dx,y2
@@a3:
push di
push si
mov cx,x2
@@a1:
mov al,es:[si]
mov ds:[di],al                     {13 clock}
inc di
add si,y2
loopnz @@a1
pop si
inc si
pop di
add di,320
dec dx
jnz @@a3

pop es
pop ds                             {12 clock}
end;
end;





begin
end.