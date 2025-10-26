Program pruebas;

Global
	depth = 16;
	teoricFPS=30;
	id_fnt =0;
Begin
    set_title("fuente 8 bits FNT");
	set_mode(800,600,depth);
	set_fps(teoricFPS,0);
    id_fnt=load_fnt("fuente8bppFNX.fnt");
    save_fnt(id_fnt,"fuente16bpp_.fnt");
    write_var(0,100,50,4,id_fnt); 
    write(id_fnt,100,100,4,"123456"); 
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
