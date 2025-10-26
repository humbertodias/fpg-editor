# fpg-editor
FPG, FNT and PRG Editor Application

## DIV Language Resource Manager

A web-based application to manage language resources for DIV Games Studio projects.

### Features

- **Add/Edit/Delete Resources**: Manage language strings with easy-to-use interface
- **Multiple Language Support**: Support for English, Spanish, Portuguese, French, German, Italian, Russian, and Japanese
- **Search & Filter**: Quickly find resources by key, value, or language
- **Import/Export**: Import and export resources in JSON format for easy sharing and backup
- **Local Storage**: Resources are automatically saved to browser's local storage
- **Statistics**: View total resources and number of languages at a glance

### Getting Started

1. Open `index.html` in a modern web browser
2. Click "Add Resource" to create your first language resource
3. Fill in the resource key, select a language, and enter the translation
4. Use the search box to filter resources
5. Export your resources to save them as a JSON file
6. Import previously exported resources

### Usage

#### Adding a Resource
1. Click the "Add Resource" button
2. Enter a unique key (e.g., "MENU_START", "BUTTON_OK")
3. Select the target language
4. Enter the translated text
5. Click "Save"

#### Editing a Resource
1. Click the "Edit" button next to any resource
2. Modify the fields as needed
3. Click "Save"

#### Deleting a Resource
1. Click the "Delete" button next to any resource
2. Confirm the deletion

#### Importing Resources
1. Click the "Import" button
2. Select a JSON file with the correct format
3. Resources will be added to your existing collection

#### Exporting Resources
1. Click the "Export" button
2. A JSON file will be downloaded with all your resources

### File Format

Resources are stored in JSON format:

```json
{
  "version": "1.0",
  "exportDate": "2025-10-26T04:10:00.000Z",
  "resources": [
    {
      "id": 1,
      "key": "MENU_START",
      "language": "en",
      "value": "Start Game"
    },
    {
      "id": 2,
      "key": "MENU_START",
      "language": "es",
      "value": "Iniciar Juego"
    }
  ]
}
```

### Technologies Used

- HTML5
- CSS3 (with modern gradient designs)
- Vanilla JavaScript (ES6+)
- LocalStorage API for data persistence

### Browser Compatibility

Works with all modern browsers:
- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)
- Opera (latest)

### License

See LICENSE file for details.
