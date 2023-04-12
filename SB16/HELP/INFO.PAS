{6416}
const
size=64000;
name='example.stm';

var
 n:word;
 a:text;c:longint;d:char;
 data:array [1..size] of byte;


begin



assign (a,name);reset (a);           {Откpыть файл с именем name}
for c:=1 to size do
begin                         {Загpузить данные}
read (a,d);
data[c]:=ord(d);
end;
close (a);              {Закpыть файл}


write ('Название   мелодии:   ');
for c:=1 to 20 do begin
if data[c]=0 then c:=20;
write (chr(data[c]));
end;
writeln;

write ('Название редактора:    ');
for c:=21 to 28 do begin
write (chr(data[c]));
end;writeln;
write ('File type:             ');
if data[30]=1 then writeln ('song');
if data[30]=2 then writeln ('module');

write ('Version:               ');
writeln (data[31],'.',data[32]);

write ('Temp:                  ');
writeln (data[33]);

write ('Количество pattern-ов: ');
writeln (data[34]);

write ('Общая громкость 0-64:  ');
writeln (data[35]);

writeln;
writeln ('Инструменты:');writeln ('-------------------------------------');

for n:=0 to 30 do begin
writeln ('Номер инструмента: ',n);
write ('Название инструмента:   ');for c:=49+(32*n) to 60+(32*n) do begin
write (chr(data[c]));
end;
writeln;

write ('Lentgh:                      ');
writeln (data[66+(32*n)]*256+data[65+(32*n)]);

write ('Loop start:                  ');
writeln (data[68+(32*n)]*256+data[67+(32*n)]);

write ('Loop end if 65535 no loop:   ');
writeln (data[70+(32*n)]*256+data[69+(32*n)]);

write ('Instrument volume:  (0-64)   ');
writeln (data [71+(32*n)]);

write ('Speed for middle C:          ');
writeln (data[73+(32*n)]);

write ('Sample offset:               ');
writeln (round(data[76+(32*n)]*256+data[75+(32*n)]/16));
writeln ('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
end;

writeln ('Порядок проигрывания pattern-ов');
for c:=1041 to 1041+128 do begin
write (data[c],':');
end;


end.