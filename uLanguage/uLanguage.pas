(*
 *  fpg-editor : Edit FPG file from DIV2, FENIX and CDIV
 *
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 *
 *)

unit uLanguage;


interface

uses Forms, SysUtils, DefaultTranslator,Translations, GetText, FileUtil , LResources;

procedure SetDefaultLangByFile(Lang: string);

resourcestring
  LNG_FPG	=	'FPG';
  LNG_IMAGES	=	'Imágenes';
  LNG_TOOLS	=	'Utilidades';
  LNG_HELP	=	'Ayuda';
  LNG_NEW	=	'Nuevo';
  LNG_OPEN	=	'Abrir';
  LNG_CLOSE	=	'Cerrar';
  LNG_SAVE	=	'Guardar';
  LNG_SAVE_AS	=	'Guardar como ...';
  LNG_CONVERT_TO	=	'Convertir a ...';
  LNG_HIDE_SHOW_UP_PANEL	=	'Ocultar/Mostrar panel superior';
  LNG_VIEW	=	'Ver';
  LNG_VIEW_ICONS      =	'Imágenes';
  LNG_LIST	=	'Lista';
  LNG_DETAILS	=	'Detalles';
  LNG_PALETTE_OF_256_COLORS	=	'Paleta de 256 colores';
  LNG_ANIMATE_SELECTED_IMAGES	=	'Animar imágenes seleccionadas';
  LNG_CHANGE_CODE_OF_IMAGE_INSERT	=	'Cambiar código de inserción de imagen';
  LNG_ADD_IMAGES	=	'Añadir imagen(es)';
  LNG_EDIT_SELECTION	=	'Editar selección';
  LNG_EXPORT_RESOURCES_FROM_FPG	=	'Exportar recursos del FPG';
  LNG_DELETE_IMAGES_SELECTEDS	=	'Eliminar imagen(es) seleccionada(s)';
  LNG_SELECT_ALL	=	'Seleccionar todo';
  LNG_INVERT_SELECTION	=	'Invertir selección';
  LNG_HIDE_SHOW_DIRECTORIES	=	'Ocultar/Mostrar directorios';
  LNG_RELOAD	=	'Recargar';
  LNG_FPG_EDITOR_COFIGURATION	=	'Configurar FPG Editor';
  LNG_COMPRESSOR	=	'Compresor';
  LNG_ABOUT_AS	=	'Acerca de ...';
  LNG_EDIT	=	'Editar';
  //LNG_RELOAD	=	'Recargar';
  LNG_ADD	=	'Añadir';
  LNG_EXPORT	=	'Exportar';
  LNG_DELETE	=	'Eliminar';
  LNG_FPG_FILE_OF_GRAPHICS	=	'FPG (Archivo de gráficos)';
  //LNG_HIDE_SHOW_DIRECTORIES	=	'Ocultar/Mostrar directorios';
  //LNG_IMAGES	=	'Imágenes';
  //LNG_LIST	=	'Lista';
  //LNG_DETAILS	=	'Detalles';
  LNG_EDIT_IMAGE_WITH_EXTERNAL_PROGRAM	=	'Editar imagen con un editor externo';
  LNG_RELOAD_IMAGES_FROM_DIRECTORY	=	'Recargar imágenes de un directorio';
  //LNG_HIDE_SHOW_UP_PANEL	=	'Ocultar/Mostrar panel superior';
  LNG_ANIMATE	=	'Animar';
  LNG_ANIMATE_IMAGES	=	'Animar imágenes';
  LNG_ADD_IMAGES_TO_FPG	=	'Añadir imagen(es) al FPG';
  LNG_EDIT_IMAGE	=	'Editar imagen';
  LNG_EXPORT_IMAGES_FROM_FPG_TO_DISK	=	'Exportar imagen(es) del FPG a disco';
  LNG_DELETE_IMAGES	=	'Eliminar imagen(es)';
  //LNG_NEW	=	'Nuevo';
  //LNG_OPEN	=	'Abrir';
  //LNG_SAVE	=	'Guardar';
  //LNG_SAVE_AS	=	'Guardar como ...';
  LNG_FILE_NAME	=	'Nombre de Archivo';
  LNG_WIDTH	=	'Ancho';
  LNG_HEIGHT	=	'Alto';
  LNG_CODE	=	'Código';
  LNG_NAME	=	'Nombre';
  LNG_CONTROL_POINTS	=	'Puntos de control';
  LNG_LOADING_FILES 	=	'Cargando imágenes';
  LNG_SAVE_CHANGES 	=	'¿Guardar los cambios?';
  LNG_WARNING 	=	'Aviso';
  LNG_WILL_BE_SELECT_IMAGE 	=	'Debe tener la imagen a editar seleccionada.';
  LNG_ONLY_ONE_IMAGE_EDIT 	=	'Solo se puede editar una imagen.';
  LNG_UNZIP_FPG 	=	'Descomprimiendo FPG';
  LNG_EXISTS_FILE_OVERWRITE 	=	'El archivo existe, ¿Desea sobreescribirlo?';
  LNG_FPG_SELECT_ONLY_ONE 	=	'Debe seleccionar solamente una imagen.';
  //LNG_EXPORT 	=	'Exportando imagen(es)';
  LNG_SELECT_MORE_IMAGES_FOR_ANIMATE 	=	'Debe seleccionar varias imágenes para hacer la animación';
  LNG_NOT_IMAGES_FOR_CONVERT 	=	'No hay imagen(es) para convertir.';
  LNG_ERROR 	=	'Error';
  LNG_ADAPT_IMAGES 	=	'Adaptando imagen(es)';
  LNG_PROCESING_IMAGES 	=	'Procesando imagen(es)';
  LNG_ANALISING_IMAGES 	=	'Analizando imagen(es)';
  LNG_UPDATE_IMAGES 	=	'Actualizando imagen(es)';
  LNG_PALETTE_PRECISION 	=	'La paleta generada tiene una precisión del';
  LNG_INFO 	=	'Información';
  LNG_SAVE_FPG 	=	'Guardando FPG';
  LNG_CORRECT_SAVING 	=	'Archivo FPG guardado correctamente';
  LNG_WRONG_FPG 	=	'Archivo FPG incorrecto';
  LNG_CREATING_CONVERT_TABLE 	=	'Creando tabla de conversión';
  LNG_CREDITS	=	'Creditos';
  LNG_CHARACTERISTIC	=	'Caracteristicas';
  LNG_ANIMATION	=	'Animación';
  LNG_CHANGE_INSERT_CODE	=	'Cambiar código de inserción';
  //LNG_FPG_EDITOR_COFIGURATION	=	'Configuración de FPG Edit';
  LNG_ENVIROMENT	=	'Entorno';
  LNG_PUBLISHER_OF_IMAGES	=	'Editor de imágenes';
  LNG_LANGUAGE	=	'Lenguaje';
  LNG_SIZE_OF_ICONS	=	'Tamaño de iconos';
  LNG_PIXELS	=	'Pixels';
  LNG_TIME_BETWEEN_IMAGE	=	'Tiempo entre imagen';
  LNG_MILLISECONDS	=	'Milisegundos';
  LNG_AUTOLOAD_IMAGES	=	'Auto-carga de imágenes';
  LNG_ACCEPT	=	'Aceptar';
  LNG_CANCEL	=	'Cancelar';
  LNG_LOCATE_PROGRAM_FOR_EDITION_OF_IMAGES	=	'Localizar programa para edición de imágenes';
  LNG_CHANGE_LANGUAGE_OF_PROGRAM	=	'Cambiar lenguaje del programa';
  LNG_ENABLED	=	'Activo';
  LNG_DISABLED	=	'Inactivo';
  LNG_EDIT_PROPERTIES_OF_THE_IMAGE	=	'Editar propiedades de la imagen';
  LNG_PROPERTIES_	=	'Propiedades';
  LNG_NUMBER	=	'Número';
  LNG_DELETE_CONTROL_POINT	=	'Eliminar punto de control';
  LNG_ADD_CONTROL_POINT	=	'Añadir punto de control';
  LNG_MODIFY_CONTROL_POINT	=	'Modificar punto de control';
  LNG_PUT_POINTS_IN_IMAGE	=	'Poner puntos en imagen';
  LNG_PUT_REAL_CENTER	=	'Poner centro real';
  LNG_VIEW_POINTS_IN_IMAGE	=	'Ver puntos de la imagen';
  LNG_CHANGE_COLOR_OF_POINTS	=	'Cambiar color de puntos';
  LNG_DELETE_ALL_POINTS	=	'Borrar todos los puntos';
  LNG_EXIST_CODE 	=	'El código establecido ya existe.';
  LNG_INCORRECT_SIZEOFICON 	=	'El tamaño de los iconos de imagen es incorrecto.';
  LNG_SURE_DELETE_ALLPOINTS 	=	'¿Seguro que desea borrar todos los puntos de control?';
  LNG_INSERT_COORD 	=	'Debe introducir la coordenada';
  LNG_TYPE_OF_FPG	=	'Tipo de FPG';
  LNG_PALETTE_FPG_8_BITS	=	'Paleta (FPG 8 bits)';
  LNG_LOAD_PALETTE	=	'Cargar Paleta';
  LNG_VIEW_PALETTE	=	'Visualizar Paleta';
  LNG_NOTLOAD_PALETTE 	=	'No ha cargado una paleta gráfica, ( en 8 bits debe seleccionar una paleta gráfica de 256 colores )';
  LNG_FILE_EXIST 	=	'El archivo ya existe.';
  LNG_FILE_NOTEXIST 	=	'El archivo no existe.';
  //LNG_PALETTE_OF_256_COLORS	=	'Paleta de 256 colores.';
  LNG_DETAILS_OF_IMAGE	=	'Detalles de la imagen';
  LNG_COMPRESSING_FILE	=	'Comprimiendo archivo...';
  LNG_COMPRESS_FILE	=	'Comprimir archivo';
  //LNG_COMPRESSOR	=	'Compresor';
  LNG_NOTFPG 	=	'El fichero no es un archivo FPG o puede estar comprimido.';
  LNG_NOT_FOUND_PALETTE 	=	'no contiene paleta de 256 colores.';
  LNG_NOT_OPEN_FILE 	=	'No se pudo abrir el archivo, compruebe que otro programa no este utilizando este archivo.';
  LNG_FILE_LANGUAGE_INCORRECT 	=	'Archivo de lenguaje incorrecto.';
  LNG_NOT_CLIPBOARD_IMAGE 	=	'No encuentra imagen en el portapapeles.';
  LNG_NOT_EXIST_FPG 	=	'No existe FPG.';
  LNG_COPY_IMAGE	=	'Copiar imagen';
  LNG_PASTE_IMAGE	=	'Pegar imagen';
  LNG_IMAGE_TO_CLIPBOARD 	=	'Imagen copiada al portapapeles.';
  LNG_CLIPBOARD	=	'Portapapeles';
  LNG_COPY_IMAGE_TO_CLIPBOARD	=	'Copiar imagen al portapapeles';
  LNG_IMAGE_TO 	=	'Imagen(es) a';
  LNG_PALETTE_TO 	=	'Paleta a';
  LNG_CLEAR_CLIPBOARD	=	'Vaciar portapapeles';
  LNG_ARE_YOU_SURE_DELETE_IMAGES 	=	'¿Seguro que desea borrar esta(s) imagen(es)?';
  LNG_IMAGES_MOVED_RECICLEDBIN 	=	'Imagen(es) movida(s) a la papelera de reciclaje';
  //LNG_EXPORT_RESOURCES_FROM_FPG	=	'Exportar recursos del FPG';
  LNG_TYPE_OF_RESOURCE	=	'Tipo de recurso';
  LNG_DIRECTORY	=	'Directorio';
  LNG_LOAD_CONTROL_POINTS	=	'Cargar puntos de control';
  LNG_YES	=	'Si';
  LNG_NO	=	'No';
  LNG_ABORT	=	'Anular';
  LNG_RETRY	=	'Reintentar';
  LNG_IGNORE	=	'Ignorar';
  LNG_ADD_POINT	=	'Añadir punto';
  LNG_PUT_CENTER	=	'Poner centro';
  LNG_FPG_CODE	=	'Código de FPG:';
  LNG_SET_INSERTION_CODE_IN_FPG	=	'Establece el código de insercción en el FPG';
  LNG_RELOAD_IMAGES_WITH_FILTER	=	'Recarga las imágenes con filtro';
  LNG_CODE_OF_IMAGE_INSERTION	=	'Código de inserción de imagen';
  LNG_THE_NUMBER_MUST_BE_BETWEEN_1_AND_999_BOTH_INCLUDING	=	'El número debe estar entre 1 y 999 ambos incluidos';
  LNG_THE_CODE_EXISTS_OR_NOT_ITS_VALID	=	'El código ya existe o no es valido';
  LNG_FLAT_BUTTONS	=	'Botones tipo "FLAT"';
  LNG_SHOW_START_SCREEN	=	'Mostrar pantalla de inicio';
  LNG_AUTOLOAD_IMAGES_AFTER_REMOVE	=	'Auto-cargar al eliminar';
  LNG_EXIT	=	'Salir';

implementation

procedure SetDefaultLangByFile(Lang: string);

var
  Dot1: integer;
  LCLPath: string;
  LocalTranslator: TUpdateTranslator;
  i: integer;
  lcfn: string;

begin
  if not FileExistsUTF8(Lang) then
     exit;
  LocalTranslator := nil;
  lcfn := lang;
  // search first po translation resources
   if (lcfn <> '') AND (ExtractFileExt(lcfn) = '.po') then
   begin
     Translations.TranslateResourceStrings(lcfn);
     LCLPath := ExtractFileName(lcfn);
     Dot1 := pos('.', LCLPath);
     if Dot1 > 1 then
     begin
       Delete(LCLPath, 1, Dot1 - 1);
       LCLPath := ExtractFilePath(lcfn) + 'lclstrconsts' + LCLPath;
       Translations.TranslateUnitResourceStrings('LCLStrConsts', LCLPath);
     end;
          LocalTranslator := TPOTranslator.Create(lcfn);
   end;

   // search mo translation resources
  if (lcfn<>'') and (ExtractFileExt(lcfn) = '.mo') then
  begin
      GetText.TranslateResourceStrings(UTF8ToSys(lcfn));
      LCLPath := ExtractFileName(lcfn);
      Dot1 := pos('.', LCLPath);
      if Dot1 > 1 then
      begin
        Delete(LCLPath, 1, Dot1 - 1);
        LCLPath := ExtractFilePath(lcfn) + 'lclstrconsts' + LCLPath;
        if FileExistsUTF8(LCLPath) then
          GetText.TranslateResourceStrings(UTF8ToSys(LCLPath));
      end;
      LocalTranslator := TDefaultTranslator.Create(lcfn);
  end;

  if LocalTranslator<>nil then
  begin
    if Assigned(LRSTranslator) then
      LRSTranslator.Free;
    LRSTranslator := LocalTranslator;
    for i := 0 to Screen.CustomFormCount-1 do
      LocalTranslator.UpdateTranslation(Screen.CustomForms[i]);
  end;
end;

end.