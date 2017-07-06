       //-----------------------------------------------------------------------------
   procedure testlos;
     var tx,ty,i,bx,by,ex,ey,dist:integer;
      currpoint:point;
      stop:boolean;

      procedure testlos2;
      var i:integer;
      begin;
       stop:=false;
       dist:=location.Geom_calcdist(bx,by,0,ex,ey,0);
       for i:=0 to dist do
        begin;
          currpoint:=SolveLine(bx,by,ex,ey,i);
          if (currpoint.x=ex)and(currpoint.y=ey)then stop:=true;
          if (Location.getground(currpoint.x,currpoint.y,0)<>'')and(i<>0)then stop:=true;
          if not stop then
            _screen.writeXYex('#',currpoint.x,currpoint.y,lyDEBUG,GrayRGB);
        end;
      end;

    begin
      bx:=trunc(player.xpos);
      by:=trunc(player.ypos);
      //ex:=cmouse_x;ey:=cmouse_y;

       //Function SolveLine(X1,Y1,X2,Y2,N: integer): Point;
      //dist:=

      ey:=0;for ex:=0 to maxXscreen do testlos2;
      ex:=0;for ey:=0 to maxYscreen do testlos2;
      ey:=maxYscreen;for ex:=0 to maxXscreen do testlos2;
      ex:=maxXscreen;for ey:=0 to maxYscreen do testlos2;

 //     _screen.writeXYex('@',cmouse_x,cmouse_y,lyDEBUG,White);
    end;
       //-----------------------------------------------------------------------------
       procedure sortcoords(var x1,y1,x2,y2:integer);
       var tmpx1,tmpx2,tmpy1,tmpy2:integer;
       begin;
        tmpx1:=min(x1,x2);tmpx2:=max(x1,x2);tmpy1:=min(y1,y2);tmpy2:=max(y1,y2);
        x1:=tmpx1;x2:=tmpx2;y1:=tmpy1;y2:=tmpy2;
       end;
       //-----------------------------------------------------------------------------
       procedure testpath2;
        var watchdog,igx,igy,step,step2,bx,by,ex,ey,dist,tmpx,tmpy:integer;
        currpoint,tmppoint:point;
        stop:boolean;
        tmpColor:TCastleColorRGB;
       label a,nextstep,ups;

      {    procedure testpathwork(gx,gy,dx,dy:integer);
          begin
           if (Location.getgroundEX(igx,igy,0).extra1=step-1) then
            if(Location.getgroundEX(igx+dx,igy+dy,0).Extra1=-1)
             //and(Location.ground[igx+dx,igy+dy,0]='')
              then
               Location.tiles[igx+dx,igy+dy,0].extra1:=step;
          end;
       }
       begin;
           bx:=trunc(player.xpos);
            by:=trunc(player.ypos);
            ex:=cmouse_x;ey:=cmouse_y;

            if (bx=ex)and(by=ey) then exit;

            sortcoords(bx,by,ex,ey);

            for igx:=0 to maxXscreen do
             for igy:=0 to maxYscreen do
              Location.tiles[igx,igy,0].extra1 := -1;

            Location.tiles[bx,by,0].extra1 := 0;

            watchdog:=0;
            step:=1;
          //  a: stop:=true;

            while Location.tiles[ex,ey,0].extra1=-1 do
            begin
                  {for igx:=bx-10 to ex+10 do
                  for igy:=by-10 to ey+10 do }
                   for igx:=0 to maxXscreen do
                   for igy:=0 to maxYscreen do
                    begin;
                     testpathwork(igx,igy,1,0);
                     testpathwork(igx,igy,-1,0);
                     testpathwork(igx,igy,0,1);
                     testpathwork(igx,igy,0,-1);

                      {if (Location.extra1[igx,igy,0]=step-1) then
                  //     if(igx < ex - 1) then
                        if(Location.extra1[igx+1,igy,0]=-1)and(Location.ground[igx+1,igy,0]='')then
                         Location.extra1[igx+1,igy,0]:=step;

                      if (Location.extra1[igx,igy,0]=step-1) then
                  //     if(igx < ex + 1) then
                        if(Location.extra1[igx-1,igy,0]=-1)and(Location.ground[igx-1,igy,0]='')then
                         Location.extra1[igx-1,igy,0]:=step;

                      if (Location.extra1[igx,igy,0]=step-1) then
                  //     if(igx < ex + 1) then
                        if(Location.extra1[igx,igy+1,0]=-1)and(Location.ground[igx,igy+1,0]='')then
                         Location.extra1[igx,igy+1,0]:=step;

                      if (Location.extra1[igx,igy,0]=step-1) then
                  //     if(igx < ex + 1) then
                        if(Location.extra1[igx,igy-1,0]=-1)and(Location.ground[igx,igy-1,0]='')then
                         Location.extra1[igx,igy-1,0]:=step;
                       }

                      {if Location.extra1[igx,igy,0]<>0 then begin;
                          if igx>0 then if (Location.extra1[igx-1,igy,0]=0)
                          and(Location.ground[igx-1,igy,0]='')
                          then begin;
                           Location.extra1[igx-1,igy,0]:=Location.extra1[igx,igy,0]+1;
                           inc(watchdog);stop:=false;
                          end;}
                      end;
                     //stop:=false;
                     inc(step);
                 //    if Location.extra1[ex,ey,0]=-1 then stop:=true;
                     //if watchdog>=(ex-bx)*(ey-by) then stop:=true;
                  //  end;
                 //  if not stop then goto a;
               if step>100 then goto a;
             end;

            a:

          {   for igx:=bx-10 to ex+10 do
             for igy:=by-10 to ey+10 do
           }
             for igx:=0 to maxXscreen do
             for igy:=0 to maxYscreen do
              begin;
               tmpColor:=WhiteRGB;
//               tmpColor:=ColorChangeBrightness(clwhite,0.1+(Location.tiles[igx,igy,0].extra1/100)); //
               _screen.writeXYex(inttostr(round(Location.tiles[igx,igy,0].extra1)),igx,igy,lyDEBUG,whiteRGB);
               //_screen.writeXYex('.',igx,igy,lyMouse,tmpColor);
              end;

           { for step:=Location.extra1[ex,ey,0] downto 0 do
             begin;
               if ex>0 then if Location.extra1[ex-1,ey,0]<Location.extra1[ex,ey,0] then
                 begin;dec(ex);goto nextstep;end;

               nextstep:
               tmpColor:=ColorChangeBrightness(clgreen,Location.extra1[ex,ey,0]/40);
             end;     }
             //for step:=Location.extra1[ex,ey,0] downto 0 do
             igx:=ex;
             igy:=ey;
             step:=0;

             ups:
               if igx>=0 then if Location.tiles[igx-1,igy,0].extra1<Location.tiles[igx,igy,0].extra1 then
                 begin;dec(igx);goto nextstep;end;
               if igx<=maxXscreen then if Location.tiles[igx+1,igy,0].extra1<Location.tiles[igx,igy,0].extra1 then
                 begin;inc(igx);goto nextstep;end;
               if igy>=0 then if Location.tiles[igx,igy-1,0].extra1<Location.tiles[igx,igy,0].extra1 then
                 begin;dec(igy);goto nextstep;end;
               if igy<=maxXscreen then if Location.tiles[igx,igy+1,0].extra1<Location.tiles[igx,igy,0].extra1 then
                 begin;inc(igy);goto nextstep;end;
               nextstep:
               //tmpColor:=ColorChangeBrightness(clgreen,Location.tiles[ex,ey,0].extra1/40);
               _screen.writeXYex('·',ex,ey,lyDEBUG,tmpColor);
               inc(step);
             if (igx<>bx)and(igy<>by)and(step<100) then goto ups;
             //tmppoint:=SolveLine(ex,ey,bx,by,0);
             tmppoint.x:=ex;tmppoint.y:=ey;
             //   untConsole.frmCon.Caption:=inttostr(Location.tiles[tmppoint.x,tmppoint.y,0].extra1)
             //   +'step2:'+inttostr(step2)+inttostr(Location.tiles[cmouse_x,cmouse_y,0].extra1);
             //_screen.writeXYex('·',tmppoint.x,tmppoint.y,lyMouse,clRed);
            // _screen.writeXYex('·',cmouse_x,cmouse_y,lyMouse,RedRGB);
       end; 
