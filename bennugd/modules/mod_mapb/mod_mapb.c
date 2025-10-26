/*
 *  mod_mapb  - native format for graphics and graphics container
 *
 *  Copyright � 2010 DCelso (Bennugd)
 *
 *  This file is part of Bennu - Game Development
 *
 *  Bennu is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  Bennu is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 *
 */

/* --------------------------------------------------------------------------- */

#include <stdlib.h>

#include "bgdrtm.h"

#include "bgddl.h"
#include "dlvaracc.h"

#include "xstrings.h"
#include "mod_mapb.h"

#include "librender.h"

static int modmapb_load_graph(INSTANCE * my, int * params) {
	int r = gr_load_graph(string_get(params[0]));
	string_discard(params[0]);

	return r;
}

static int modmapb_save_graph(INSTANCE * my, int * params) {
	int r = (int) gr_save_graph(bitmap_get(params[0], params[1]),
			(char *) string_get(params[2]));
	string_discard(params[2]);
	return r;
}

static int modmapb_load_grlib( INSTANCE * my, int * params )
{
    int r;

    r = gr_load_grlib( string_get( params[0] ) ) ;
    string_discard( params[0] ) ;
    return r ;
}

static int modmapb_unload_graph( INSTANCE * my, int * params )
{
    return grlib_unload_map( params[0], params[1] ) ;
}


typedef struct
{
    char *file;
    int *id, ( *fn )();
} bgdata ;
static int bgDoLoad( void *d )
{
    bgdata *t = ( bgdata* )d;
    *( t->id ) = -2 ; // WAIT STATUS
    *( t->id ) = ( *t->fn )( t->file );
    free( t );
    return 0;
}
static bgdata *prep( int *params )
{
    bgdata *t = ( bgdata* )malloc( sizeof( bgdata ) );
    t->file = ( char * )string_get( params[0] );
    t->id = ( int* )params[1];
    string_discard( params[0] );
    return t;
}

int modmapb_grliboad_grlib( INSTANCE * my, int * params )
{
    bgdata *t = prep( params );
    t->fn = gr_load_grlib;
    SDL_CreateThread( bgDoLoad, ( void * )t );
    return 0 ;
}


static int modmapb_unload_grlib( INSTANCE * my, int * params )
{
    grlib_destroy( params[0] ) ;
    return 1 ;
}

static int modmapb_save_grlib( INSTANCE * my, int * params )
{
    int r;
    r = gr_save_grlib( params[0], string_get( params[1] ) ) ;
    string_discard( params[1] ) ;
    return r ;
}


/* --------------------------------------------------------------------------- */

DLSYSFUNCS  __graphdexport( mod_natmap, functions_exports )[] =
{
    /* BGI */
    { "LOAD_GRAPH"            , "S"           , TYPE_INT      , modmapb_load_graph           },
    { "SAVE_GRAPH"            , "IIS"         , TYPE_INT      , modmapb_save_graph           },
    { "UNLOAD_GRAPH"          , "II"          , TYPE_INT      , modmapb_unload_graph         },

    /* BGL */
    { "LOAD_GRLIB"            , "S"           , TYPE_INT      , modmapb_load_grlib           },
    { "LOAD_GRLIB"            , "SP"          , TYPE_INT      , modmapb_grliboad_grlib         },
    { "SAVE_GRLIB"            , "IS"          , TYPE_INT      , modmapb_save_grlib           },
    { "UNLOAD_GRLIB"          , "I"           , TYPE_INT      , modmapb_unload_grlib         },

    { 0                     , 0             , 0             , 0                         }
};

/* --------------------------------------------------------------------------- */

char * __graphdexport( mod_mapb, modules_dependency )[] =
{
    "libgrbase",
    "libvideo",
    "libblit",
    "libfont",
    NULL
};
