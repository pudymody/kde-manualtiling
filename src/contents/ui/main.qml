import QtQuick 2.0;
import QtQuick.Window 2.0;
import QtQuick.Controls 2.0;
import QtQuick.Layouts 1.15;
import org.kde.plasma.core 2.0 as PlasmaCore;
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kwin 2.0;

PlasmaCore.Dialog {
    id: dialog
    location: PlasmaCore.Types.Floating
    visible: false
    flags: Qt.X11BypassWindowManagerHint | Qt.FramelessWindowHint

    function show() {
        var screen = workspace.clientArea(KWin.FullScreenArea, workspace.activeScreen, workspace.currentDesktop);
        dialog.visible = true;
        dialog.x = screen.x + screen.width/2 - dialogItem.width/2;
        dialog.y = screen.y + screen.height/2 - dialogItem.height/2;
    }

    function loadConfig(){
        dialogItem.rows = KWin.readConfig("rows", 8);
        dialogItem.columns = KWin.readConfig("columns", 8);
        dialogItem.spacing = KWin.readConfig("spacing", 2);
        dialogItem.squareSize = KWin.readConfig("squareSize", 25);
        dialogItem.color_unselected = KWin.readConfig("color_unselected", "#FFFFFF");
        dialogItem.color_selected = KWin.readConfig("color_selected", "#FF0000");

        console.log("READ CONFIG");
    }

    mainItem: ColumnLayout {
        id: dialogItem
        width: (dialogItem.squareSize * dialogItem.columns) + (dialogItem.spacing * (dialogItem.columns-1))

        // magic number here, need to learn how to set size as grid size
        height: (dialogItem.squareSize * dialogItem.rows) + (dialogItem.spacing * (dialogItem.rows-1)) + focusTitle.height + 5

        property int rows: 8
        property int columns: 8
        property int spacing: 2
        property int squareSize: 25

        property int row_start: -1
        property int col_start: -1

        property int row_end: -1
        property int col_end: -1

        property color color_unselected: "white"
        property color color_selected: "red"

        PlasmaExtras.Heading {
            id: focusTitle
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
            text: workspace.activeClient.caption
        }

        Grid {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            columns: dialogItem.columns
            rows: dialogItem.rows
            spacing: dialogItem.spacing

            Repeater {
                model: dialogItem.columns * dialogItem.rows
                Rectangle {
                    width: dialogItem.squareSize
                    height: dialogItem.squareSize

                    property int row: Math.floor( index / dialogItem.columns )
                    property int col: index % dialogItem.columns

                    color: {
                        let selection_started = dialogItem.row_start != -1 && dialogItem.col_start != -1;

                        if( selection_started ){
                            let row_min = Math.min(dialogItem.row_start, dialogItem.row_end);
                            let row_max = Math.max(dialogItem.row_start, dialogItem.row_end);

                            let col_min = Math.min(dialogItem.col_start, dialogItem.col_end);
                            let col_max = Math.max(dialogItem.col_start, dialogItem.col_end);

                            if( this.row >= row_min && this.row <= row_max && this.col >= col_min && this.col <= col_max ){
                                return dialogItem.color_selected;
                            }
                        }

                        return dialogItem.color_unselected;
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
                            }
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
    }
}
