unit THForm1;

{$mode objfpc}{$H+}

interface

uses
  Classes, {Crt,} SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, PopupNotifier, Windows;

const
  uplimit = 1     ;
  downlimit = 55  ; //Form's height
  leftlimit = 1   ;
  rightlimit = 64 ; //Form's length
  distance = 1    ; //borderline
  r = 5;            //radius of cell
  h = 70;           //Panel1 height
  d = r * 2;           //diameter of cell
  snakelength = downlimit * rightlimit;//max length possible
  k = 1; //multiplier for score
  bonuseff = 1; //effect of the bonus
  startlimit = 10; //starting length
  drpos = 1; //drawing position
  erasecl = clgreen; //color for erasing
  foodela = 100; //time for food to spawn
type

  { TForm1 }

  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    GMOVRPOPUP: TPopupNotifier;
    ResetButton: TButton;
    CloserBTN: TButton;
    Panel1: TPanel;
    FoodTime: TTimer;
    Death: TTimer;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    //procedure FormKeyPress(Sender: TObject; var Key: char);

    procedure DeathStartTimer(Sender: TObject);
    procedure DeathStopTimer(Sender: TObject);
    procedure DeathTimer(Sender: TObject);
    procedure GMOVRPOPUPClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure ResetButtonClick(Sender: TObject);
    procedure CloserBTNClick(Sender: TObject);
  //  procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word);
    function rightallowed:boolean;
    function leftallowed:boolean;
    function downallowed:boolean;
    procedure Timer1StopTimer(Sender: TObject);
    function upallowed:boolean;
    procedure move(chngx,chngy:longint);
    procedure snakedraw;
    procedure snakeerase;
    function foodfound():boolean;
    procedure foodeat;
    procedure savesnake;
    procedure coordtest;
    procedure drawborders;
    procedure godie;
    procedure placefood;
    procedure checkcrash;
  private

  public

  end;

var
  Form1: TForm1;                                  //r u serious? >.<
  x,y:longint;                                    //x and y for snake's head
  map:array[1..64,1..56] of byte;                 //game object matrix
  snakebody:array[1..snakelength,1..2] of longint;//snake's body coord
  limit:longint;  //snake's length
  score:longint;   //score
  drb:longint;
  gameover,gm1,mv:boolean;
implementation

{$R *.lfm}

{ TForm1 }
//test procedures
procedure TForm1.coordtest;
begin
  Label1.Caption:=('Currentx >> '+inttostr(x)+'/'+inttostr(rightlimit)+' | Current y>> '+inttostr(y));
  label2.Caption:=('Coords of Tail: x >> '+inttostr(snakebody[limit,1])+' | y >> '+inttostr(snakebody[limit,2]));
end;


procedure TForm1.drawborders;
var i,j:longint;
begin
  with canvas do begin
     brush.color:=clblue;
     for i:=1 to 64 do
        for j:=8 to 62 do begin
          // rectangle(d*i-r,8*d-r,d*i+r,8*d+r);
           rectangle(d*i-r,(downlimit+7)*d-r,d*i+r,(downlimit+7)*d+r);
           rectangle((d div 2)-r,j*d-r,(d div 2)+r,j*d+r);
           rectangle(64*d-r,j*d-r,64*d+r,j*d+r);
        end;
     //fillrect(rightlimit,downlimit+1,leftlimit,downlimit);
     //fillrect(
  end;
end;
//testprocedures section end
//DEATH
procedure TForm1.checkcrash;
var i:longint;
begin
  for i:=2 to limit do begin
     if (snakebody[i,1]=x) and (snakebody[i,2]=y) then
         begin gameover:=true; godie; mv:=false end
          else gameover:=false;
  end;
  if gameover=false then begin deathstoptimer(Form1);end;
end;
procedure TForm1.godie;
begin
  DeathStartTimer(Form1);
end;
procedure TForm1.DeathStartTimer(Sender: TObject);
begin
  if gameover=true then begin
  GMOVRPOPUP.visible:=true;
  gm1:=true;
end;
end;
procedure TForm1.DeathStopTimer(Sender: TObject);
begin
    exit;
end;
procedure TForm1.DeathTimer(Sender: TObject);
begin
  if gm1=true then begin
  GMOVRPOPUP.visible:=false;
  ResetButtonClick(Form1);
  gm1:=false;
  mv:=true;
  end;
end;
//Gameover section end

//game section
procedure TForm1.placefood;
var bonx,bony,i:longint;
begin
   bonx:=random(rightlimit-leftlimit-distance*2)+2;
   bony:=random(downlimit-uplimit-distance*2)+2;
   for i:=1 to limit do
      if (bonx=snakebody[i,1]) and (bony=snakebody[i,2]) then
      begin
           score:=score+1;
           placefood;
           exit;
      end;
   map[bonx,bony]:=1;
   with canvas do begin
      brush.color:=clyellow;
      ellipse(bonx*d-r,bony*d+h-r,bonx*d+r,bony*d+r+h);
   end;
   if drb=0 then
   begin
   drawborders;
   drb:=1;
   ellipse(clred,snakebody[drpos,1]*d-r,snakebody[drpos,2]*d+h-r,snakebody[drpos,1]*d+r,snakebody[drpos,2]*d+h+r);
   end;
end;

//Functions for border checking
function TForm1.upallowed:boolean;
begin
  if y>(uplimit+distance) then upallowed:=true else upallowed:=false;
end;      
function TForm1.downallowed:boolean;
begin
  if y<(downlimit-distance) then downallowed:=true else downallowed:=false;
end;
function TForm1.leftallowed:boolean;
begin
  if x>(leftlimit+distance) then leftallowed:=true else leftallowed:=false;
end;
function TForm1.rightallowed:boolean;
begin
  if x<(rightlimit-distance) then rightallowed:=true else rightallowed:=false;
end;
//Procedure for saving snake's body coordinates
//for erasing body pieces later
procedure TForm1.savesnake;
var
cur:longint;
begin
  snakebody[1,1]:=x;
  snakebody[1,2]:=y;
  for cur:=limit downto 2 do begin
      snakebody[cur,1]:=snakebody[cur-1,1];
      snakebody[cur,2]:=snakebody[cur-1,2];
  end;
end;



//snake body's drawing
procedure TForm1.snakedraw;
begin
   with canvas do begin
    brush.color:=clred;
    ellipse(snakebody[drpos,1]*d-r,snakebody[drpos,2]*d+h-r,snakebody[drpos,1]*d+r,snakebody[drpos,2]*d+h+r);
    brush.color:=clnone;
  end;
end;
//snake tail's erasing
procedure TForm1.snakeerase;
begin
   with canvas do begin
      brush.color:=erasecl;
      fillrect(snakebody[limit,1]*d-r,snakebody[limit,2]*d+h-r,snakebody[limit,1]*d+r,snakebody[limit,2]*d+h+r);
      brush.color:=clnone;
   end;
end;
//snake checking for food
function TForm1.foodfound():boolean;
begin
   if map[x,y]=1 then foodfound:=true else foodfound:=false;
end;
//snake eating food
procedure TForm1.foodeat;
begin
   map[x,y]:=0;
   score:=score+bonuseff;
   limit:=k*score+startlimit;
   StaticText2.Caption:='Your score>> '+inttostr(score);
end;

//movement syncro procedures
procedure TForm1.move(chngx,chngy:longint);
begin
  if mv=true then begin
  //snakedraw;
  x:=x+chngx;
  y:=y+chngy;
  //coordtest;
  snakeerase;
  checkcrash;
  if foodfound then foodeat;

  //Shape1.Left:=x*d-r;    These are remains of Shape1 which fought till'
  //Shape1.Top:=y*d+h-r;   the end for being the only canvas moving object
  savesnake;
  snakedraw;
  end;

end;

//Closing of BSNone Form, KISSed
procedure TForm1.CloserBTNClick(Sender: TObject);
begin
  halt(0);
end;
//Reset  procedure
procedure TForm1.ResetButtonClick(Sender: TObject);
begin
  gm1:=false;
  mv:=true;
  deathstoptimer(Form1);
  gameover:=false;
  FoodTime.enabled:=true;
  x:=leftlimit+distance+1;
  y:=uplimit+distance+1;
  limit:=startlimit;
  score:=0;
  Form1.Canvas.Brush.Color:=clgreen;
  Form1.Canvas.Fillrect(1,1,640,640);
  Form1.Canvas.Brush.Color:=clnone;
  fillchar(snakebody,sizeof(snakebody),0);
  ResetButton.Enabled:=False;
  ResetButton.Enabled:=True;
  CloserBTN.Enabled:=False;
  CloserBTN.Enabled:=True;
  FoodTime.Interval:=foodela;
  GMOVRPOPUP.visible:=false;
  StaticText2.Caption:='Your score>> '+inttostr(score);
  move(0,0);
  drawborders;
  drb:=0;
end;
//***//


procedure TForm1.GMOVRPOPUPClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  //ResetButtonClick(Form1);
end;


//Simple movement, controlled by functions, orders procedure
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word );
begin

  if ((key=VK_UP) or (key=VK_W)) and (upallowed=true) then move(0,-1);
  if ((key=VK_DOWN)or (key=VK_S)) and (downallowed=true) then move(0,1);
  if ((key=VK_LEFT) or (key=VK_A)) and (leftallowed=true) then move(-1,0);
  if ((key=VK_RIGHT) or (key=VK_D))and (rightallowed=true) then move(1,0);
  if key=VK_ESCAPE then halt(0);

end;

procedure TForm1.Timer1StopTimer(Sender: TObject);
begin
   //if gameover=true then begin
    //GMOVRPOPUP.visible:=false;
    //ResetButtonClick(Form1);
    //end;
  placefood;
end;


end.

