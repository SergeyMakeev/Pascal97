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
   s:string;
   n,m:integer;FS:TDosStream;MS:TEmsStream;
chose:for_menu;
begin
   clrscr;
   SoundBufSize:=4096;
   {None,PcSpeaker,SoundBlaster,Covox1,Covox2}
            s:=paramstr(1);
            if s='' then halt;
            offcursor;
   chose[1]:='  Pc Speaker  ';
   chose[2]:='Sound  Blaster';
  sounddevice:=SoundBlaster;
   SbPort:=$220;
   SoundVolume:=64;
   InitMemory;
   FS.Init(s, stOpenRead);
   MS.Init(FS.GetSize, FS.GetSize);
   MS.CopyFrom(FS, FS.GetSize); FS.Done;MS.Seek(0);
   if InitSound(@MS)<>bsOk then begin
                 writeln ('Error initialization digital sound.');Halt;end;
   StartSound;
   repeat
   inline ($fa);memw[0:$41a]:=memw[0:$41c];inline ($fb);
   gotoxy (1,1);
   if playingsound then write ('Playing...') else write ('Stoped. ');
{   write ('  Vol-',soundvolume,'   ');}
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
