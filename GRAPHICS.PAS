unit Graphics_Engine;
Interface
uses crt;
type ScreenType=array [1..64000] of byte;
     BackgroundType=array [1..64000] of byte;
     PaletteType=array [1..768] of byte;
var
shadows:array [1..18,1..2] of byte;
Palette:^PaletteType;
Screen:^ScreenType;
BackGround:^BackGroundType;
VS_segment,VS_offset,VS_end:word;
BK_segment,BK_offset,BK_end:word;
Pal_segment,Pal_offset:word;
procedure SPlot(x,y:word;color,scolor:byte);
procedure Error(name:string);
procedure GraphInit;
procedure GraphClose;
procedure Show;
procedure Plot(x,y:word;color:byte);
Function GetPixel(x,y:word):byte;
procedure DirectPlot(x,y:word;color:byte);
Function DirectGetPixel(x,y:word):byte;
procedure CPlot(x,y:word;color:byte);
procedure SWriteSprite(x,y,x2,y2:word;sprite:pointer;scolor:byte);
procedure WriteSprite(x,y,x2,y2:word;sprite:pointer);
Procedure Synchronization;
Procedure ClearScreen(color:byte);
Procedure SetBackground(name:string);
Procedure RestoreBackground;
procedure SetPalette;
Procedure LoadPalette(name:string);
procedure ParalSFX1(x,y,x2,y2:word;sprite:pointer);
procedure ParalSFX2(x,y,x2,y2:word;sprite:pointer);
procedure SetShadowsTable(name:string);
procedure IParalSFX1(x,y,xlen,ylen:word;p:pointer);
procedure IParalSFX2(x,y,xlen,ylen:word;p:pointer);

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
New (BackGround);
New (Palette);
pal_segment:=seg(Palette^);
pal_offset:=ofs(Palette^);

VS_segment:=seg(Screen^);
VS_offset:=ofs(Screen^);
VS_END:=VS_offset+63999;
BK_segment:=seg(BackGround^);
BK_offset:=ofs(BackGround^);
BK_END:=BK_offset+63999;

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
Dispose (Palette);
Dispose (BackGround);
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
ADD DI,VS_OFFSET                   {13 clock}
mov ax,VS_segment                  {12 clock}
mov ds,ax                          {2 clock}
mov al,color                       {2 clock}
mov ds:[di],al                     {13 clock}
pop ds                             {12 clock}
end;                               {total 242 clock}

procedure CPlot(x,y:word;color:byte);
begin
if x>=320 then exit;
if y>=200 then exit;
asm
push ds                            {14 clock}
mov ax,320                         {4 clock}
mov bx,y                           {12 clock}
mul bx                             {143 clock}
mov di,ax                          {2 clock}
add di,x                           {13 clock}
ADD DI,VS_OFFSET                   {13 clock}
mov ax,VS_segment                  {12 clock}
mov ds,ax                          {2 clock}
mov al,color                       {2 clock}
mov ds:[di],al                     {13 clock}
pop ds                             {12 clock}
end;                               {total 242 clock}
end;


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
ADD DI,VS_OFFSET                   {13 clock}
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
ADD DI,VS_OFFSET                   {13 clock}
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

procedure SWriteSprite(x,y,x2,y2:word;sprite:pointer;scolor:byte);
var Sprite_segment,Sprite_offset:word;
begin
Sprite_Segment:=seg(sprite^);
Sprite_Offset:=ofs(sprite^);
asm
push ds                            {14 clock}
push es
mov ax,320                         {4 clock}
mov bx,y                           {12 clock}
mul bx                             {143 clock}
mov di,ax                          {2 clock}
add di,x                           {13 clock}
ADD DI,VS_OFFSET                   {13 clock}
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


procedure WriteSprite(x,y,x2,y2:word;sprite:pointer);
var Sprite_segment,Sprite_offset:word;
begin
Sprite_Segment:=seg(sprite^);
Sprite_Offset:=ofs(sprite^);
asm
push ds                            {14 clock}
push es
mov ax,320                         {4 clock}
mov bx,y                           {12 clock}
mul bx                             {143 clock}
mov di,ax                          {2 clock}
add di,x                           {13 clock}
{add di,VS_offset }                  {13 clock}
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


Procedure Synchronization;assembler;
asm
cli
mov dx,$3dA
@@z:
in al,dx
and al,08h
jnz @@z
@@z2:             {Синхронизировать с монитором}
in al,dx
and al,08h
jz @@z2
sti
end;

procedure RestoreBackground;assembler;
    asm
      push ds
      push es
      xor  di,di
      mov si,BK_offset
      cld
      mov  ax,word(Screen+2)
      mov  es,ax
      mov  ax,BK_segment
      mov  ds,ax
      mov  cx,32000
      rep  movsw
      pop  es
      pop  ds
    end;

procedure SetPalette;assembler;
asm
mov bx,0
mov cx,256
mov ax,pal_segment
mov es,ax
mov ax,pal_offset
mov dx,ax
mov al,18
mov ah,16
int $10
end;

procedure ClearScreen(color:byte);assembler;
    asm
      push ds
      push es
      xor  si,si
      mov di,2
      cld
      mov  ax,word(Screen+2)
      mov  ds,ax
      mov  es,ax
      mov  cx,32000
      mov al,color
      mov ds:[si],al
      inc si
      mov ds:[si],al
      dec si
      rep  movsw
      pop  es
      pop  ds
    end;

Procedure SetBackground(name:string);
var
f:file;nmr:word;
begin
assign (f,name);reset (f,1);
BlockRead (f,BackGround^,64000,Nmr);
close (f);
end;

Procedure LoadPalette(name:string);
var
f:file;nmr:word;
begin
assign (f,name);reset (f,1);
BlockRead (f,Palette^,768,Nmr);
close (f);
end;

procedure ParalSFX1(x,y,x2,y2:word;sprite:pointer);
var Sprite_segment,Sprite_offset:word;
begin
Sprite_Segment:=seg(sprite^);
Sprite_Offset:=ofs(sprite^);
asm
push ds                            {14 clock}
push es
mov ax,320                         {4 clock}
mov bx,y                           {12 clock}
mul bx                             {143 clock}
mov di,ax                          {2 clock}
add di,x                           {13 clock}
ADD DI,VS_OFFSET                   {13 clock}
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

mov bl,es:[si]
mov al,ds:[di]
cmp al,0
jz @@la
sub al,bl
@@la:mov ds:[di],al

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

procedure ParalSFX2(x,y,x2,y2:word;sprite:pointer);
var Sprite_segment,Sprite_offset:word;
begin
Sprite_Segment:=seg(sprite^);
Sprite_Offset:=ofs(sprite^);
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

mov bl,es:[si]
mov al,ds:[di]
cmp al,255
jz @@la
add al,bl
@@la:mov ds:[di],al

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

procedure SetShadowsTable(name:string);
var f:file;
NMR:word;
begin
assign (f,name);reset(f,1);
blockread (f,shadows,36,NMR);
close (f);
end;

procedure IParalSFX2(x,y,xlen,ylen:word;p:pointer);
var sg,ot,b,n,m,z:word;
a:integer;

begin
sg:=seg(p^);
ot:=ofs(p^);
for m:=x to x+xlen-1 do begin
for n:=y to y+ylen-1 do begin
A:=GetPixel(m,n);
if mem[sg:ot]<>0 then begin
{какой это color ?}
for z:=1 to 18 do begin
if (a>=shadows[z,1]) and (a<=shadows[z,2]) then b:=z;
end;
A:=A+mem[sg:ot];
{не перелез ли этот color на другой ?}
if (a<=shadows[b,1]) then a:=shadows[b,1];
if (a>=shadows[b,2]) then a:=shadows[b,2];
end;
Plot (m,n,A);ot:=ot+1;
end;end;
end;

procedure IParalSFX1(x,y,xlen,ylen:word;p:pointer);
var sg,ot,b,n,m,z:word;
a:integer;
begin
sg:=seg(p^);
ot:=ofs(p^);
for m:=x to x+xlen-1 do begin
for n:=y to y+ylen-1 do begin
A:=GetPixel(m,n);
if mem[sg:ot]<>0 then begin

{какой это color ?}
for z:=1 to 18 do begin
if (a>=shadows[z,1]) and (a<=shadows[z,2]) then b:=z;
end;
A:=A-mem[sg:ot];
{не перелез ли этот color на другой ?}
if (a<=shadows[b,1]) then a:=shadows[b,1];
if (a>=shadows[b,2]) then a:=shadows[b,2];
end;
Plot (m,n,A);ot:=ot+1;
end;end;
end;


begin
end.