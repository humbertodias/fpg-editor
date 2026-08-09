/*
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

#ifndef __MOD_MAPB_H
#define __MOD_MAPB_H

#include <stdio.h>

#include "libgrbase.h"
#include "libvideo.h"
#include "libblit.h"
#include "libfont.h"

#include "arrange.h"
#include "files.h"

/* --------------------------------------------------------------------------- */


#ifdef _MSC_VER
#pragma pack(push, 1)
#endif

typedef struct
{
    uint8_t magic[7] ;
    uint8_t version ;
    uint16_t width ;
    uint16_t height ;
    uint32_t code ;
    int8_t name[32] ;
}
#ifdef __GNUC__
__attribute__ ((packed))
#endif
MAP_HEADER ;

#ifdef _MSC_VER
#pragma pack(pop)
#endif

/* ------------------------------------------ */


extern int gr_load_graph( const char * filename ) ;
extern int gr_save_graph( GRAPH * gr, const char * filename ) ;

extern int gr_load_grlib(const char * filename);
extern int gr_save_grlib(int libid, const char * filename);

#endif
