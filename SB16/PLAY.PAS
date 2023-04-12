{ SetRate(Rate:Word);
  StartSound;
  StopSound;                 возможные функции
  PauseSound;
  ContinueSound;                }


{$M 4096,0,655360}
{$S-,R-,I-}
uses
   Mywav,Objects,CRT,DOS,Memory,univer;
var
   n,m:integer;FS:TDosStream;MS:TEmsStream;
chose:for_menu;
begin
   clrscr;
   SoundVolume:=64;SoundBufSize:=4096;
   {None,PcSpeaker,SoundBlaster,Covox1,Covox2}
   SoundDevice:=PcSpeaker;
   SbPort:=$220;
            offcursor;
            normal(0);
   chose[1]:='  Pc Speaker  ';
   chose[2]:='Sound  Blaster';
      single(31,10,46,13,14,1,'');
   repeat
   {function menu(x,y,x1,y1,colortext,selectcolor,
                fon,selectfon:byte;menuprompt:
                         for_menu;howmany:byte;mess:string):byte;
      }

   m:=menu(32,11,45,12,14,6,1,13,chose,2,'');
   case m of
   0:halt;
   1:SoundDevice:=PcSpeaker;
   2:SoundDevice:=SoundBlaster;
   3:SoundDevice:=Covox1;
   4:SoundDevice:=Covox2;
   end;
   until m in [0..2];

   writeln ('Enter sound blaster port:');
   writeln ('Example: $220, $240 etc');
   writeln ('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
   write ('Your port: ');
   readln (SbPort);
   if n=4 then SoundDevice:=Covox1;
   if n=5 then SoundDevice:=Covox2;
   clrscr;
   writeln ('Select volume:');
   writeln ('P.S. Volume change without mixer !!!');
   writeln ('But this is not very good.');
   writeln;
   write ('Enter you chose:(0-255), 64-Normal volume: ');
   readln (SoundVolume);
   clrscr;
   {Конец менюшке}

   InitMemory;
   FS.Init('bonus.WAV', stOpenRead);
   MS.Init(FS.GetSize, FS.GetSize);
   MS.CopyFrom(FS, FS.GetSize); FS.Done;MS.Seek(0);
   if InitSound(@MS)<>bsOk then begin
                 writeln ('Error initialization digital sound.');Halt;end;


   {Еще одна ненужная менюшка}
   writeln;
   writeln;
   writeln('P - Play sound');
   writeln('S - Stop sound');
   writeln('A - Pause sound');
   writeln('C - Continue sound');
   writeln ('~~~~~~~~~~~~~~~~~~~~~~~~~~~');
   writeln ('ESC - Quit');
   {А это глядишь ее окончание}



   {Начало цикла}
   StartSound;
   repeat

   inline ($fa);memw[0:$41a]:=memw[0:$41c];inline ($fb);


   gotoxy (1,1);
   if playingsound then write ('Playing.') else write ('Stoped. ');
   write ('  Vol-',soundvolume,'   ');
   if port[$60]=31 then stopsound;  
   if port[$60]=25 then startsound;
   if port[$60]=30 then pausesound;
   if port[$60]=46 then continuesound;
   if port[$60]=80 then soundvolume:=soundvolume-1;
   if port[$60]=72 then soundvolume:=soundvolume+1;
   if port[$60]=75 then  sounddevice:=PcSpeaker;
   if port[$60]=77 then sounddevice:=SoundBlaster;
   delay (150);

   until port[$60]=1;
   StopSound;
   {Конец цикла}

   DoneDosMem;InitDosMem;MS.Done;DoneMemory;
end.
