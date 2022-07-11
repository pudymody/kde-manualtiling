import QtQuick 2.0;
import QtQuick.Window 2.0;
import QtQuick.Controls 2.0;
import QtQuick.Layouts 1.15;
import org.kde.plasma.core 2.0 as PlasmaCore;
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kwin 2.0;
import org.kde.taskmanager 0.1 as TaskManager

PlasmaCore.Dialog {
    id: dialog
    location: PlasmaCore.Types.Floating
    visible: false
    flags: Qt.X11BypassWindowManagerHint | Qt.FramelessWindowHint

    function resetGrid(){
        let grid = [];
        for(let i = 0; i < dialogItem.rows; i++){
            let r = [];
            for(let j = 0; j < dialogItem.columns; j++){
                r.push(0);
            }
            grid.push(r);
        }
        dialogItem.gridUsed = grid;
        dialogItem.windows = {};
    }

    function show() {
        var screen = workspace.clientArea(KWin.FullScreenArea, workspace.activeScreen, workspace.currentDesktop);
        dialog.visible = true;
        dialog.x = screen.x + screen.width/2 - dialogItem.width/2;
        dialog.y = screen.y + screen.height/2 - dialogItem.height/2;

        dialog.resetGrid();
    }

    function loadConfig(){
        dialogItem.rows = KWin.readConfig("rows", 8);
        dialogItem.columns = KWin.readConfig("columns", 8);
    }

    mainItem: RowLayout {
        id: dialogItem

        property int rows: 8
        property int columns: 8

        property int row_start: -1
        property int col_start: -1

        property int row_end: -1
        property int col_end: -1

        property var windows: ({})
        property var gridUsed: []

        GridLayout {
            id: gridPositioner
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            columns: dialogItem.columns
            rows: dialogItem.rows
            columnSpacing: PlasmaCore.Units.smallSpacing
            rowSpacing: PlasmaCore.Units.smallSpacing

            Repeater {
                model: dialogItem.columns * dialogItem.rows
                Rectangle {
                    width: PlasmaCore.Units.iconSizes.smallMedium
                    height: PlasmaCore.Units.iconSizes.smallMedium

                    property int row: Math.floor( index / dialogItem.columns )
                    property int col: index % dialogItem.columns
                    Layout.row: this.row
                    Layout.column: this.col

                    color: {
                        let selection_started = dialogItem.row_start != -1 && dialogItem.col_start != -1;

                        if( selection_started ){
                            let row_min = Math.min(dialogItem.row_start, dialogItem.row_end);
                            let row_max = Math.max(dialogItem.row_start, dialogItem.row_end);

                            let col_min = Math.min(dialogItem.col_start, dialogItem.col_end);
                            let col_max = Math.max(dialogItem.col_start, dialogItem.col_end);

                            if( this.row >= row_min && this.row <= row_max && this.col >= col_min && this.col <= col_max ){
                                return PlasmaCore.Theme.highlightColor;
                            }
                        }

                        return PlasmaCore.Theme.textColor;
                    }

                    PlasmaCore.IconItem {
                        source: dialogItem.windows[ dialogItem.gridUsed[ parent.row ][ parent.col ] ]
                        visible: this.source != undefined
                        width: parent.width
                        height: parent.height
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: function(){
                            let selection_started = dialogItem.row_start != -1 && dialogItem.col_start != -1;
                            if( selection_started ){
                                dialogItem.col_end = parent.col;
                                dialogItem.row_end = parent.row;
                            }
                        }

                        onReleased: function(){
                            let selection_started = dialogItem.row_start != -1 && dialogItem.col_start != -1;
                            if( !selection_started ){
                                dialogItem.col_start = parent.col;
                                dialogItem.row_start = parent.row;
                                dialogItem.col_end = parent.col;
                                dialogItem.row_end = parent.row;
                            }else{

                                let focused_win = workspace.activeClient;
                                if( focused_win.onAllDesktops ){
                                    return;
                                }

                                let row_min = Math.min(dialogItem.row_start, dialogItem.row_end);
                                let row_max = Math.max(dialogItem.row_start, dialogItem.row_end);
                                let col_min = Math.min(dialogItem.col_start, dialogItem.col_end);
                                let col_max = Math.max(dialogItem.col_start, dialogItem.col_end);

                                let screen = workspace.clientArea(KWin.MaximizeArea, workspace.activeScreen, focused_win.desktop);
                                let screen_width = screen.width;
                                let screen_height = screen.height;

                                let screen_width_unit = screen_width / dialogItem.columns;
                                let screen_height_unit = screen_height / dialogItem.rows;

                                let new_width = (col_max - col_min + 1) * screen_width_unit;
                                let new_height = (row_max - row_min + 1) * screen_height_unit;

                                let new_x_offset = col_min * screen_width_unit;
                                let new_y_offset = row_min * screen_height_unit;

                                focused_win.setMaximize(false, false);
                                workspace.activeClient.geometry = Qt.rect( screen.x + new_x_offset, screen.y + new_y_offset, new_width, new_height);

                                dialogItem.col_start = -1;
                                dialogItem.row_start = -1;
                                dialogItem.col_end = -1;
                                dialogItem.row_end = -1;

                                let windowID = workspace.activeClient.windowId;
                                dialogItem.windows[ windowID ] = workspace.activeClient.icon;
                                for( let i = 0; i < dialogItem.rows; i++){
                                    for(let j = 0; j < dialogItem.columns; j++){
                                        if( dialogItem.gridUsed[i][j] == windowID ){
                                            dialogItem.gridUsed[i][j] = null;
                                        }

                                        if( i >= row_min && i <= row_max && j >= col_min && j <= col_max ){
                                            dialogItem.gridUsed[i][j] = windowID;
                                        }
                                    }
                                }

                                dialogItem.windowsChanged();
                                dialogItem.gridUsedChanged();
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            TaskManager.VirtualDesktopInfo {
                id: virtualDesktopInfo
            }
            ListView {
                id: textListView
                Layout.minimumWidth: PlasmaCore.Units.gridUnit * 10
                Layout.preferredWidth: gridPositioner.width
                Layout.fillHeight: true
                clip: true
                model: TaskManager.TasksModel {
                    id: tasksModel
                    sortMode: TaskManager.TasksModel.SortVirtualDesktop
                    groupMode: TaskManager.TasksModel.GroupDisabled
                    filterByVirtualDesktop: true
                    virtualDesktop: virtualDesktopInfo.currentDesktop
                }

                highlight: PlasmaCore.FrameSvgItem {
                    id: highlightItem
                    imagePath: "widgets/viewitem"
                    prefix: "hover"
                }
                highlightMoveDuration: 0
                highlightResizeDuration: 0

                delegate: MouseArea {
                    onReleased: {
                        textListView.currentIndex = index;
                        tasksModel.requestActivate(tasksModel.makeModelIndex(model.index))
                    }
                    width:  textListView.width
                    height: childrenRect.height
                    Row {
                        spacing: PlasmaCore.Units.smallSpacing
                        PlasmaCore.IconItem {
                            source: model.decoration
                            visible: source !== ""

                            anchors.top: parent.top
                            anchors.verticalCenter: parent.verticalCenter

                            implicitWidth: PlasmaCore.Units.roundToIconSize(parent.height)
                            implicitHeight: PlasmaCore.Units.roundToIconSize(parent.height)
                        }
                        PlasmaExtras.Heading {
                            level: 2
                            text: model.display
                        }
                    }
                }
            }
        }

        Connections {
            target: options
            function onConfigChanged() { loadConfig(); }
        }

    }

    Component.onCompleted: {
        KWin.registerWindow(dialog);
        KWin.registerShortcut("Manual Tiling", "Manual Tiling", "Ctrl+Meta+D", function() {
            if( dialog.visible ){
                dialog.visible = false;
            }else{
                dialog.show();
            }
        });

        dialog.loadConfig();
        dialog.resetGrid();
    }
}
