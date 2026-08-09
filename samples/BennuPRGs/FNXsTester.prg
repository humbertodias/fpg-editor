Program pruebas;

import "mod_key"
import "mod_screen"
import "mod_wm"
import "mod_video"
import "mod_map"
import "mod_text"
import "mod_proc"

Global
	depth = 32;
	//depth = 16;
	teoricFPS=30;
	id_fnt1 =0;
	id_fnt8 =0;
	id_fnt16 =0;
	id_fnt32 =0;
        char value,v2;
Begin
    set_title("fuente 32 bits FNX");
	set_mode(800,600,depth);
	set_fps(teoricFPS,0);
    put_screen(0,load_png("fondo.png"));
	set_text_color(RGB(255,0,255));
    id_fnt1=load_fnt("1bit.fnt");
    id_fnt8=load_fnt("8bits.fnt");
    id_fnt16=load_fnt("16bits.fnt");
    id_fnt32=load_fnt("32bits.fnt");
    value=252;
    v2=209;
    write(id_fnt1,50,100,0,"€çÇhola j gañán 1" +value+v2); 
    write(id_fnt8,50,180,0,"€çÇhola j gañán 8"+value+v2 );  
    write(id_fnt16,50,260,0,"€çÇhola j gañán 16"+value +v2); 
    write(id_fnt32,50,340,0,"€çÇhola j gañán 32"+value +v2); 
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
        fnt_save(id_fnt8,"8bits2.fnt");
end
