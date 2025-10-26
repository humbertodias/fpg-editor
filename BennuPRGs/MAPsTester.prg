Program MAPsTester;

import "mod_key"
import "mod_screen"
import "mod_wm"
import "mod_video"
import "mod_map"
import "mod_text"
import "mod_proc"

Global
	depth = 32;
	teoricFPS=30;
	id1 =0;
	id8 =0;
	id16 =0;
	id32 =0;
	
process showimage(graph,x,y,dato)
begin
    while (!key(_esc))
      frame;
    end 
end
	
Begin
  set_title("MAPsTester");
	set_mode(800,600,depth);
	set_fps(teoricFPS,0);
  put_screen(0,load_png("fondo.png"));
    id1=load_map("1bit.map");
    id8=load_map("8bits.map");
    id16=load_map("16bits.map");
    id32=load_map("32bits.map");
    
    write(0,150,100,0,"1bit"); 
    showimage(id1,150,100,1); 
    
    write(0,450,100,0,"8bits"); 
    showimage(id8,450,100,1); 
    
    write(0,150,300,0,"16bits"); 
    showimage(id16,150,300,1); 
    
    write(0,450,300,0,"32bits"); 
    showimage(id32,450,300,1); 
    while (!key(_esc)) 
		if (key(_f))
            if (full_screen==true)
                full_screen=false;
            else 
                full_screen=true;
            end 
            set_mode(800,600,depth);
            while (key(_f)) 
		      frame;
            end;
        end
        frame;
	end
	let_me_alone();
end
