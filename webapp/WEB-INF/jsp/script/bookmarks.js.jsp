<%@ include file="/WEB-INF/jsp/include.jsp" %>

var knownEntryTypes = new Array()
knownEntryTypes[0] = 'folder';
knownEntryTypes[1] = 'bookmark';


/***** Public Methods *****/
function toggleEditMode(enableEdit, namespace) {
	var editSpans = document.getElementsByName(namespace + "_entryEditSpan");
	for (var index = 0; index < editSpans.length; index++) {
		if (enableEdit) {
			editSpans[index].style.display = 'inline';
		}
		else {
			editSpans[index].style.display = 'none';
		}
	}
	
	if (enableEdit) {
		hideElement(namespace, 'editLink');
		showElementInline(namespace, 'cancelLink');
	}
	else {
		hideElement(namespace, 'cancelLink');
		showElementInline(namespace, 'editLink');
	}
}

function newEntry(type, namespace) {
    setupForm(type, 'new', namespace);
    getNamespacedElement(namespace, 'folderAction').innerHTML = "<spring:message code="portlet.script.folder.create" javaScriptEscape="true"/>";
    
    //Ensure all the Folder options are enabled
    var form = getForm(namespace);
    var folderOpts =  form.elements['folderPath'].options;
    for (var index = 0; index < folderOpts.length; index++) {
        folderOpts[index].disabled = false;
    }
    
    showForm(namespace);
}

function cancelEntry(namespace) {
	toggleEditMode(false, namespace);
    hideForm(namespace);
}

function editEntry(type, namespace, parentFolderIndexPath, entryIndexPath) {
    setupForm(type, 'edit', namespace);

    var form = getForm(namespace);
    
    form.elements['indexPath'].value = entryIndexPath;
    form.elements['type'].value = type;

    form.elements['name'].value = getNamespacedElement(namespace, 'name_' + entryIndexPath).innerHTML;
    form.elements['note'].value = getNamespacedElement(namespace, 'note_' + entryIndexPath).innerHTML;;
    
    if (type == 'bookmark') {
        var entryUrl = getNamespacedElement(namespace, 'url_' + entryIndexPath);
        form.elements['url'].value = entryUrl.href;
        form.elements['newWindow'].checked = (entryUrl.target != "");
    }
    
    getNamespacedElement(namespace, 'folderAction').innerHTML = "<spring:message code="portlet.script.folder.move" javaScriptEscape="true"/>";

    //Select the folder the entry is in
    var folderOpts =  form.elements['folderPath'].options;
    for (var index = 0; index < folderOpts.length; index++) {
        if (folderOpts[index].value == parentFolderIndexPath) {
            folderOpts[index].selected = true;
        }
        else {
            folderOpts[index].selected = false;
        }

        if (folderOpts[index].value.indexOf(entryIndexPath) == 0) {
            folderOpts[index].disabled = true;
        }
        else {
            folderOpts[index].disabled = false;
        }
    }
    
    showForm(namespace);
}

function deleteEntry(type, namespace, name, url) {
    var confirmMessage = "";

    if (type == 'bookmark') {
    	confirmMessage = confirmMessage + "<spring:message code="portlet.script.delete.confirm.bookmark.prefix" javaScriptEscape="true"/>";
    	confirmMessage = confirmMessage + name;
        confirmMessage = confirmMessage + "<spring:message code="portlet.script.delete.confirm.bookmark.suffix" javaScriptEscape="true"/>";
    }
    else {
    	confirmMessage = confirmMessage + "<spring:message code="portlet.script.delete.confirm.folder.prefix" javaScriptEscape="true"/>";
    	confirmMessage = confirmMessage + name;
        confirmMessage = confirmMessage + "<spring:message code="portlet.script.delete.confirm.folder.suffix" javaScriptEscape="true"/>";
    }
    
    var shouldDelete = confirm(confirmMessage);
    
    if (shouldDelete) {
        location.href = url;
    }
}



/***** Internal Methods *****/
function getForm(namespace) {
    return document.forms[namespace + 'bookmarksForm'];
}
function getNamespacedElement(namespace, elementId) {
    return document.getElementById(namespace + elementId);
}
function hideElement(namespace, elementId) {
    var element = getNamespacedElement(namespace, elementId);
    element.style.display = 'none';
}
function showElementBlock(namespace, elementId) {
    showElement(namespace, elementId, 'block');
}
function showElementInline(namespace, elementId) {
    showElement(namespace, elementId, 'inline');
}
function showElement(namespace, elementId) {
    showElement(namespace, elementId, '');
}
function showElement(namespace, elementId, displayType) {
    var element = getNamespacedElement(namespace, elementId);
    element.style.display = displayType;
}

function setupForm(type, action, namespace) {
    var form = getForm(namespace);
    form.reset();
    
    //Reset doesn't seem to affect hidden fields: 
    form.elements['indexPath'].value = "";
    form.elements['type'].value = "";
    form.elements['action'].value = "";

    if (type == 'bookmark') {
        if (action == 'new') {
            form.elements['action'].value = 'newBookmark';
        }
        else {
            form.elements['action'].value = 'editBookmark';
        }
        
        form.elements['url'].disabled = false;
        form.elements['newWindow'].disabled = false;
        showElement(namespace, 'urlRow');
        showElement(namespace, 'newWindowRow');
    }
    else {
        if (action == 'new') {
            form.elements['action'].value = 'newFolder';
        }
        else {
            form.elements['action'].value = 'editFolder';
        }
        
        form.elements['url'].disabled = true;
        form.elements['newWindow'].disabled = true;
        hideElement(namespace, 'urlRow');
        hideElement(namespace, 'newWindowRow');
    }
}

function showForm(namespace) {
    showElementBlock(namespace, 'bookmarksDiv');
    
    var form = getForm(namespace);
    form.elements['name'].focus();
}

function hideForm(namespace) {
    hideElement(namespace, 'bookmarksDiv');
    getForm(namespace).reset();
}