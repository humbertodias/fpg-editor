Program FPGsTester;

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
	
process showimage(file,x,y,graph)
begin
    while (!key(_esc))
      frame;
    end 
end
	
Begin
  set_title("FPGsTester");
	set_mode(800,600,depth);
	set_fps(teoricFPS,0);
  put_screen(0,load_png("fondo.png"));
    id1=load_fpg("1bit.fpg");
    id8=load_fpg("8bits.fpg");
    id16=load_fpg("16bits.fpg");
    id32=load_fpg("32bits.fpg");
    
    write(0,150,100,0,"1bit"); 
    showimage(id1,150,100,2); 
    
    write(0,450,100,0,"8bits"); 
    showimage(id8,450,100,2); 
    
    write(0,150,300,0,"16bits"); 
    showimage(id16,150,300,2); 
    
    write(0,450,300,0,"32bits"); 
    showimage(id32,450,300,5);
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
  // save_fpg(id8,"8bits2.fpg");
end
