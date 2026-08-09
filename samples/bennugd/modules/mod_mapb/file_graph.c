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
#include <string.h>

#define GRAPH_MAGIC_LENGTH 25
#define GRAPH_VERSION_LENGTH 2
#define GRAPH_NAME_LENGTH 64

uint8_t graph_magic[GRAPH_MAGIC_LENGTH] = "BENNUGD GRAPHIC          ";
uint8_t graph_version[GRAPH_VERSION_LENGTH] = {1,0};

rgb_component file_read_rgb_component(file *fp) {

	rgb_component rgb;
	file_readUint8(fp, &(rgb.r));
	file_readUint8(fp, &(rgb.g));
	file_readUint8(fp, &(rgb.b));
	return rgb;

}

PALETTE *file_read_palette(file *fp) {
	PALETTE *palette = malloc(sizeof(PALETTE));
	int i;
	for (i = 0; i < 256; i++)
		palette->rgb[i] = file_read_rgb_component(fp);
	for (i = 0; i < 256; i++)
		file_readUint32(fp, &(palette->colorequiv[i]));
	file_readSint32(fp, &(palette->use));
	//struct _palette     * next ;
	//struct _palette     * prev ;

	return palette;
}

PIXEL_FORMAT * file_read_pixel_format(file * fp) {
	PIXEL_FORMAT * format = malloc(sizeof(* format));

	file_readUint8(fp, &format->depth);
	file_readUint8(fp, &format->depthb);

	if (format->depth > 1 && format->depth <= 8)
		format->palette = file_read_palette(fp);
	else
		format->palette = 0;

	file_readUint8(fp, &format->Rloss);
	file_readUint8(fp, &format->Gloss);
	file_readUint8(fp, &format->Bloss);
	file_readUint8(fp, &format->Aloss);

	file_readUint8(fp, &format->Rshift);
	file_readUint8(fp, &format->Gshift);
	file_readUint8(fp, &format->Bshift);
	file_readUint8(fp, &format->Ashift);

	file_readUint32(fp, &format->Rmask);
	file_readUint32(fp, &format->Gmask);
	file_readUint32(fp, &format->Bmask);
	file_readUint32(fp, &format->Amask);


	return format;
}

CPOINT file_read_cpoint(file * fp) {
	CPOINT cpoint;
	file_readSint16(fp, &cpoint.x);
	file_readSint16(fp, &cpoint.y);
	return cpoint;
}

GRAPH * file_readGRAPH(file * fp){
	long int bytes;
	int i;
	GRAPH * gr = 0;
	gr = malloc(sizeof(GRAPH));
	file_readSint32(fp, &gr->code);
	file_read(fp, &gr->name, GRAPH_NAME_LENGTH);
	file_readUint32(fp, &gr->width);
	file_readUint32(fp, &gr->height);
	file_readUint32(fp, &gr->pitch);
	file_readUint32(fp, &gr->widthb);
	gr->format = file_read_pixel_format(fp);

	file_readSint32(fp, &gr->modified);
	file_readSint32(fp, &gr->info_flags);

	if (gr->format->depth == 1) {
		bytes = (gr->width * gr->height) / 8;
		if ((gr->width * gr->height) % 8 != 0)
			bytes++;
	} else {
		bytes = gr->width * gr->height * gr->format->depthb;
	}

	gr->data = malloc(bytes);

	file_read(fp, gr->data, bytes);

	file_readUint32(fp, &gr->ncpoints);

	if (gr->ncpoints > 0) {
		gr->cpoints = malloc(sizeof(CPOINT) * gr->ncpoints);
		for (i = 0; i < gr->ncpoints; i++) {
			gr->cpoints[i] = file_read_cpoint(fp);
		}
	}else{
		gr->cpoints = 0;
	}


	/* Pointer to 16 bits blend table if any */
	if (!file_eof(fp))
		file_readSint16(fp, gr->blend_table);
	else
		gr->blend_table = 0;

	bitmap_analize( gr );

	return gr;
}

GRAPH * gr_read_graph(file * fp) {
	uint8_t magic[GRAPH_MAGIC_LENGTH] ;
	uint8_t version[GRAPH_VERSION_LENGTH] ;
	GRAPH * gr = 0;

	file_read(fp, magic, GRAPH_MAGIC_LENGTH);
	file_read(fp, version, GRAPH_VERSION_LENGTH);

	/*Check magic*/
	if (strncmp((char *)graph_magic,(char *)magic,GRAPH_MAGIC_LENGTH)!=0){
		free (gr);
		return 0;
	}

	/*Check version 1.0*/
	if (version[0]!=1 || version[0]!=0){
		gr=file_readGRAPH(fp);
	}else{
		free (gr);
	}

	return gr;
}


int gr_load_graph(const char * name) {
	GRAPH * gr;
	file * fp = file_open(name, "rb");
	if (!fp)
		return 0;

	gr = gr_read_graph(fp);
	file_close(fp);

	if (!gr)
		return 0;

	// Don't matter the file code, we must force a new code...
	gr->code = bitmap_next_code();

	grlib_add_map(0, gr);

	return gr->code;
}

void file_write_rgb_component(file * fp, rgb_component rgb) {
	file_writeUint8(fp, &rgb.r);
	file_writeUint8(fp, &rgb.g);
	file_writeUint8(fp, &rgb.b);
}
void file_write_palette(file * fp, PALETTE * palette) {
	int i;
	for (i = 0; i < 256; i++)
		file_write_rgb_component(fp, palette->rgb[i]);
	for (i = 0; i < 256; i++)
		file_writeUint32(fp, &(palette->colorequiv[i]));
	file_writeSint32(fp, &palette->use);
	//struct _palette     * next ;
	//struct _palette     * prev ;

}
void file_write_pixel_format(file * fp, PIXEL_FORMAT * format) {

	file_writeUint8(fp, &format->depth); /* bits per pixel */
	file_writeUint8(fp, &format->depthb);/* bytes per pixel */

	if (format->depth > 1 && format->depth <= 8)
		file_write_palette(fp, format->palette);


	file_writeUint8(fp, &format->Rloss);
	file_writeUint8(fp, &format->Gloss);
	file_writeUint8(fp, &format->Bloss);
	file_writeUint8(fp, &format->Aloss);

	file_writeUint8(fp, &format->Rshift);
	file_writeUint8(fp, &format->Gshift);
	file_writeUint8(fp, &format->Bshift);
	file_writeUint8(fp, &format->Ashift);

	file_writeUint32(fp, &format->Rmask);
	file_writeUint32(fp, &format->Gmask);
	file_writeUint32(fp, &format->Bmask);
	file_writeUint32(fp, &format->Amask);


}

void file_write_cpoint(file * fp, CPOINT cpoint) {
	file_writeSint16(fp, &cpoint.x);
	file_writeSint16(fp, &cpoint.y);
}

void file_writeGRAPH(file *fp,GRAPH * gr){
	int i;
	long int bytes;

	file_writeSint32(fp, &gr->code);
	file_write(fp, gr->name, GRAPH_NAME_LENGTH);
	file_writeUint32(fp, &gr->width);
	file_writeUint32(fp, &gr->height);
	file_writeUint32(fp, &gr->pitch);
	file_writeUint32(fp, &gr->widthb);
	/* Pixel format */
	file_write_pixel_format(fp, gr->format);
	file_writeSint32(fp, &gr->modified);
	file_writeSint32(fp, &gr->info_flags);

	/* Pointer to the bitmap data at current frame */
	if (gr->format->depth == 1) {
		bytes = (gr->width * gr->height) / 8;
		if ((gr->width * gr->height) % 8 != 0)
			bytes++;
	} else {
		bytes = gr->width * gr->height * gr->format->depthb;
	}

	file_write(fp, gr->data, bytes);

	file_writeUint32(fp, &gr->ncpoints);
	for (i = 0; i < gr->ncpoints; i++) {
		file_write_cpoint(fp, gr->cpoints[i]);
	}
	/* Pointer to 16 bits blend table if any */
	if (gr->blend_table != 0)
		file_writeSint16(fp, gr->blend_table);

}

int gr_save_graph(GRAPH * gr, const char * filename) {

	if (!gr)
		return (0);
	file * fp = file_open(filename, "wb");

	file_write(fp, graph_magic, GRAPH_MAGIC_LENGTH);

	file_write(fp, graph_version, GRAPH_VERSION_LENGTH);

	file_writeGRAPH(fp,gr);

	file_close(fp);
	return 1;
}

