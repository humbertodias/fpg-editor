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

#include "mod_mapb.h"

#define GRLIB_MAGIC_LENGTH 25
#define GRLIB_VERSION_LENGTH 2
#define GRLIB_NAME_LENGTH 64

uint8_t grlib_magic[GRLIB_MAGIC_LENGTH] = "BENNUGD GRAPHIC LIBRARY";
uint8_t grlib_version[GRLIB_VERSION_LENGTH] = { 1, 0 };

GRAPH * file_readGRAPH(file * fp);
/* Static convenience function */
static int gr_read_grlib(file * fp) {
	int libid = -1;
	int i;
	uint8_t magic[GRLIB_MAGIC_LENGTH];
	uint8_t version[GRLIB_VERSION_LENGTH];
	GRLIB * lib = 0;
	/*Check magic*/

	file_read(fp, magic, GRLIB_MAGIC_LENGTH);
	file_read(fp, version, GRLIB_VERSION_LENGTH);

	if (strncmp((char *) grlib_magic, (char *) magic, GRLIB_MAGIC_LENGTH) != 0) {
		free(lib);
		return -1;
	}

	/*Check version 1.0 */
	if (version[0] != 1 || version[0] != 0) {
		lib = malloc(sizeof(GRLIB));
		file_read(fp, lib->name, GRLIB_NAME_LENGTH);
		file_readSint32(fp, &lib->map_reserved);
		lib->maps = malloc(sizeof(GRAPH *) * lib->map_reserved);
		for (i = 0; i < lib->map_reserved; i++) {
			lib->maps[i] = file_readGRAPH(fp);
		}

	} else {
		free(lib);
	}

	return libid;
}

int gr_load_grlib(const char * libname) {
	int libid;
	file * fp = file_open(libname, "rb");
	if (!fp)
		return -1;
	libid = gr_read_grlib(fp);
	file_close(fp);
	return libid;
}

void file_writeGRAPH(file *fb, GRAPH * graph);

int gr_save_grlib(int libid, const char * filename) {
	GRLIB * lib;
	int i;

	lib = grlib_get(libid);

	if (!lib)
		return 0;

	file * fp = file_open(filename, "wb");
	file_write(fp, grlib_magic, GRLIB_MAGIC_LENGTH);
	file_write(fp, grlib_version, GRLIB_VERSION_LENGTH);
	file_write(fp, lib->name, GRLIB_NAME_LENGTH);
	file_writeSint32(fp, &lib->map_reserved);
	for (i = 0; i < lib->map_reserved; i++) {
		file_writeGRAPH(fp, lib->maps[i]);
	}

	file_close(fp);

	return 1;
}

