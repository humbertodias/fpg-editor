// Language Resource Manager for DIV Games Studio
class LanguageResourceManager {
    constructor() {
        this.resources = [];
        this.currentId = 1;
        this.editingId = null;
        this.init();
    }

    init() {
        this.loadFromStorage();
        this.setupEventListeners();
        this.renderResources();
        this.updateStats();
    }

    setupEventListeners() {
        // Add button
        document.getElementById('addBtn').addEventListener('click', () => this.showModal());

        // Import button
        document.getElementById('importBtn').addEventListener('click', () => this.importResources());

        // Export button
        document.getElementById('exportBtn').addEventListener('click', () => this.exportResources());

        // Search input
        document.getElementById('searchInput').addEventListener('input', (e) => {
            this.filterResources(e.target.value);
        });

        // Form submit
        document.getElementById('resourceForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.saveResource();
        });

        // Cancel button
        document.getElementById('cancelBtn').addEventListener('click', () => this.hideModal());

        // Close modal
        document.querySelector('.close').addEventListener('click', () => this.hideModal());

        // Click outside modal to close
        window.addEventListener('click', (e) => {
            const modal = document.getElementById('resourceModal');
            if (e.target === modal) {
                this.hideModal();
            }
        });

        // File input for import
        document.getElementById('fileInput').addEventListener('change', (e) => {
            this.handleFileImport(e);
        });
    }

    showModal(resource = null) {
        const modal = document.getElementById('resourceModal');
        const modalTitle = document.getElementById('modalTitle');
        
        if (resource) {
            // Edit mode
            modalTitle.textContent = 'Edit Resource';
            document.getElementById('resourceId').value = resource.id;
            document.getElementById('resourceKey').value = resource.key;
            document.getElementById('resourceLanguage').value = resource.language;
            document.getElementById('resourceValue').value = resource.value;
            this.editingId = resource.id;
        } else {
            // Add mode
            modalTitle.textContent = 'Add Resource';
            document.getElementById('resourceForm').reset();
            document.getElementById('resourceId').value = '';
            this.editingId = null;
        }
        
        modal.style.display = 'block';
    }

    hideModal() {
        document.getElementById('resourceModal').style.display = 'none';
        document.getElementById('resourceForm').reset();
        this.editingId = null;
    }

    saveResource() {
        const key = document.getElementById('resourceKey').value.trim();
        const language = document.getElementById('resourceLanguage').value;
        const value = document.getElementById('resourceValue').value.trim();

        if (!key || !language || !value) {
            alert('Please fill in all fields');
            return;
        }

        if (this.editingId) {
            // Update existing resource
            const resource = this.resources.find(r => r.id === this.editingId);
            if (resource) {
                resource.key = key;
                resource.language = language;
                resource.value = value;
            }
        } else {
            // Add new resource
            this.resources.push({
                id: this.currentId++,
                key,
                language,
                value
            });
        }

        this.saveToStorage();
        this.renderResources();
        this.updateStats();
        this.hideModal();
    }

    deleteResource(id) {
        if (confirm('Are you sure you want to delete this resource?')) {
            this.resources = this.resources.filter(r => r.id !== id);
            this.saveToStorage();
            this.renderResources();
            this.updateStats();
        }
    }

    editResource(id) {
        const resource = this.resources.find(r => r.id === id);
        if (resource) {
            this.showModal(resource);
        }
    }

    renderResources(filteredResources = null) {
        const tbody = document.getElementById('resourcesBody');
        const resourcesToRender = filteredResources || this.resources;

        if (resourcesToRender.length === 0) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="5" class="empty-state">
                        <div class="empty-state-icon">📚</div>
                        <div class="empty-state-text">No resources found. Click "Add Resource" to get started!</div>
                    </td>
                </tr>
            `;
            return;
        }

        tbody.innerHTML = resourcesToRender.map(resource => `
            <tr>
                <td>${resource.id}</td>
                <td><strong>${this.escapeHtml(resource.key)}</strong></td>
                <td><span class="badge">${this.getLanguageName(resource.language)}</span></td>
                <td>${this.escapeHtml(resource.value)}</td>
                <td class="actions">
                    <button class="btn btn-edit" onclick="manager.editResource(${resource.id})">Edit</button>
                    <button class="btn btn-danger" onclick="manager.deleteResource(${resource.id})">Delete</button>
                </td>
            </tr>
        `).join('');
    }

    filterResources(searchTerm) {
        const term = searchTerm.toLowerCase().trim();
        
        if (!term) {
            this.renderResources();
            return;
        }

        const filtered = this.resources.filter(resource => 
            resource.key.toLowerCase().includes(term) ||
            resource.value.toLowerCase().includes(term) ||
            resource.language.toLowerCase().includes(term)
        );

        this.renderResources(filtered);
    }

    updateStats() {
        document.getElementById('totalCount').textContent = this.resources.length;
        
        const uniqueLanguages = new Set(this.resources.map(r => r.language));
        document.getElementById('languageCount').textContent = uniqueLanguages.size;
    }

    exportResources() {
        if (this.resources.length === 0) {
            alert('No resources to export');
            return;
        }

        const data = {
            version: '1.0',
            exportDate: new Date().toISOString(),
            resources: this.resources
        };

        const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `div-language-resources-${Date.now()}.json`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    }

    importResources() {
        document.getElementById('fileInput').click();
    }

    handleFileImport(event) {
        const file = event.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (e) => {
            try {
                const data = JSON.parse(e.target.result);
                
                if (data.resources && Array.isArray(data.resources)) {
                    if (confirm(`Import ${data.resources.length} resources? This will add to existing resources.`)) {
                        // Find the maximum ID to avoid conflicts
                        const maxId = Math.max(
                            this.currentId,
                            ...data.resources.map(r => r.id || 0)
                        );
                        this.currentId = maxId + 1;

                        // Add imported resources
                        data.resources.forEach(resource => {
                            this.resources.push({
                                id: resource.id || this.currentId++,
                                key: resource.key,
                                language: resource.language,
                                value: resource.value
                            });
                        });

                        this.saveToStorage();
                        this.renderResources();
                        this.updateStats();
                        alert('Resources imported successfully!');
                    }
                } else {
                    alert('Invalid file format. Expected JSON with resources array.');
                }
            } catch (error) {
                alert('Error parsing file: ' + error.message);
            }
        };
        reader.readAsText(file);
        
        // Reset file input
        event.target.value = '';
    }

    saveToStorage() {
        localStorage.setItem('divLanguageResources', JSON.stringify({
            resources: this.resources,
            currentId: this.currentId
        }));
    }

    loadFromStorage() {
        const stored = localStorage.getItem('divLanguageResources');
        if (stored) {
            try {
                const data = JSON.parse(stored);
                this.resources = data.resources || [];
                this.currentId = data.currentId || 1;
            } catch (error) {
                console.error('Error loading from storage:', error);
                this.resources = [];
                this.currentId = 1;
            }
        }
    }

    getLanguageName(code) {
        const languages = {
            'en': 'English',
            'es': 'Spanish',
            'pt': 'Portuguese',
            'fr': 'French',
            'de': 'German',
            'it': 'Italian',
            'ru': 'Russian',
            'ja': 'Japanese'
        };
        return languages[code] || code;
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Initialize the manager when the page loads
let manager;
document.addEventListener('DOMContentLoaded', () => {
    manager = new LanguageResourceManager();
});
