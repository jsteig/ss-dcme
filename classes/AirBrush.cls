VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "AirBrush"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Dim parent As frmMain
Dim undoch As Changes

Dim UseAsteroids As Boolean

Dim asteroidTypeCount As Integer
Dim AsteroidToUse(0 To 2) As Integer
    
Dim curSelection As TilesetSelection
Dim airBOptions As airBrushOptions

Private Type airBrushOptions
    BrushSize As Integer
    Density As Double
    TotalItemsToDraw As Long
    tileSize As Coordinate
    isSpecialObject As Boolean
End Type


Sub setParent(Main As frmMain)
    Set parent = Main
End Sub

Sub MouseDown(Button As Integer, X As Single, Y As Single)
    On Error GoTo MouseDown_Error
    
    If Button <> vbLeftButton And Button <> vbRightButton Then Exit Sub
    
    'get tileset selection
    Dim tooloptions As DrawOptions

    
    curSelection = parent.tileset.selection(Button)
    
    Call parent.tline.SetSelection(curSelection)
    Call parent.tline.SetOptions(tooloptions)
    
    
    UseAsteroids = CBool(GetSetting("UseAirBrushAsAsteroids", "0"))
    
    asteroidTypeCount = 0
    
    If UseAsteroids Then
        'Gather all types of asteroids to use
        
        If CBool(GetSetting("UseSmallAsteroids1", "0")) Then
            AsteroidToUse(asteroidTypeCount) = TILE_SML_ASTEROID1
            asteroidTypeCount = asteroidTypeCount + 1
        End If
        
        If CBool(GetSetting("UseSmallAsteroids2", "0")) Then
            AsteroidToUse(asteroidTypeCount) = TILE_SML_ASTEROID2
            asteroidTypeCount = asteroidTypeCount + 1
        End If
        
        If CBool(GetSetting("UseBigAsteroids", "0")) Then
            AsteroidToUse(asteroidTypeCount) = TILE_LRG_ASTEROID
            asteroidTypeCount = asteroidTypeCount + 1
        End If

        'If no types were checked, forget about asteroids
        If asteroidTypeCount = 0 Then
            UseAsteroids = False
        End If
    End If
    

    
    Dim decreaseNrOfObjects As Integer 'Factor to reduce the number of
                                   'objects created depending on their size
                                   
    If Not UseAsteroids And (curSelection.tileSize.X > 1 Or curSelection.tileSize.Y > 1) Then
        decreaseNrOfObjects = longMaximum(curSelection.tileSize.X, curSelection.tileSize.Y)
    Else
        decreaseNrOfObjects = 1
    End If
    
    airBOptions.BrushSize = frmGeneral.sldAirbSize.value
    airBOptions.Density = frmGeneral.sldAirbDensity.value / 100#
    
    'Items to draw = (Area/25) * Density \ decreaseNrOfObjects
    airBOptions.TotalItemsToDraw = (((airBOptions.BrushSize ^ 2) / 25#) * (airBOptions.Density)) \ decreaseNrOfObjects
    airBOptions.isSpecialObject = (Not UseAsteroids) And curSelection.isSpecialObject
    
    If UseAsteroids Then
        airBOptions.tileSize.X = 0
        airBOptions.tileSize.Y = 0
    Else
        airBOptions.tileSize.X = curSelection.tileSize.X - 1
        airBOptions.tileSize.Y = curSelection.tileSize.Y - 1
    End If
        
    parent.undoredo.ResetRedo
    Set undoch = New Changes
        
    Call MouseMove(Button, X, Y)

    On Error GoTo 0
    Exit Sub

MouseDown_Error:
    HandleError Err, "AirBrush.MouseDown"
End Sub

Sub MouseMove(Button As Integer, X As Single, Y As Single)
    'On Error GoTo MouseMove_Error

    If Button <> vbLeftButton And Button <> vbRightButton Then Exit Sub
    
    Dim curtilex As Integer, curtiley As Integer
    
    Dim rndx As Integer, rndy As Integer
    
    Dim maptile As Integer
    
    Dim tilecount As Integer
    Dim i As Integer, j As Integer
    
    Dim tmptile As Integer
    
    Randomize

setAnotherRandom:

    curtilex = (parent.hScr.value + X) \ parent.currenttilew
    curtiley = (parent.vScr.value + Y) \ parent.currenttilew
'    If (curtilex < 0 Or curtiley < 0 Or curtilex > 1023 Or curtiley > 1023) Then
'        Exit Sub
'    End If




'        If tmptileSizeX > (frmGeneral.sldAirbSize.Value * 2) Then
'            tmptileSizeX = (frmGeneral.sldAirbSize.Value * 2) + 1
'        End If
'
'        If tmptileSizeY > (frmGeneral.sldAirbSize.Value * 2) Then
'            tmptileSizeY = (frmGeneral.sldAirbSize.Value * 2) + 1
'        End If

    
    For tilecount = 0 To airBOptions.TotalItemsToDraw
        

        If UseAsteroids Then
            Dim rndAsteroid As Integer
            
            rndAsteroid = Int((asteroidTypeCount) * Rnd)
            
            tmptile = AsteroidToUse(rndAsteroid)
        Else
            tmptile = curSelection.tilenr
        End If
        
        rndx = Rnd() * Int(airBOptions.BrushSize * 2 - airBOptions.tileSize.X) + curtilex - airBOptions.BrushSize
        rndy = Rnd() * Int(airBOptions.BrushSize * 2 - airBOptions.tileSize.Y) + curtiley - airBOptions.BrushSize


'            If airBrushOptions.isSpecialObject Then
'            ElseIf tmptileSizeX > 1 Or tmptileSizeY > 1 Then
'                rndx = Rnd() * Int(frmGeneral.sldAirbSize.Value * 2 - (tmptileSizeX - 1)) + curtilex - frmGeneral.sldAirbSize.Value
'                rndy = Rnd() * Int(frmGeneral.sldAirbSize.Value * 2 - (tmptileSizeY - 1)) + curtiley - frmGeneral.sldAirbSize.Value
'            Else
'                rndx = Rnd() * Int(frmGeneral.sldAirbSize.Value * 2) + curtilex - frmGeneral.sldAirbSize.Value
'                rndy = Rnd() * Int(frmGeneral.sldAirbSize.Value * 2) + curtiley - frmGeneral.sldAirbSize.Value
'            End If

        'Boundary check
        If rndx + airBOptions.tileSize.X >= 0 And rndx <= 1023 And rndy + airBOptions.tileSize.Y >= 0 And rndy <= 1023 Then

            For j = 0 To airBOptions.tileSize.Y
                If rndy + j >= 0 And rndy + j <= 1023 Then
                
                    For i = 0 To airBOptions.tileSize.X
                        If rndx + i >= 0 And rndy + j >= 0 Then
'                            If AreaClearForObject(parent, rndx + i, rndy + j, tmptile) Then
                            maptile = parent.getTile(rndx + i, rndy + j)
                            
                            If parent.pastetype <> p_under Or maptile = 0 Then
                                If TileIsSpecial(tmptile) Then
                                    If AreaClearForObject(parent, rndx + i, rndy + j, tmptile) Then
                                    
                                        If TileIsSpecial(maptile) Then
                                            Call SearchAndDestroyObject(parent, rndx + i, rndy + j, undoch, False)
                                        End If
                                
                                        Call setObject(parent, tmptile, rndx, rndy, undoch, False)
                                    End If
                                Else
                                    If TileIsSpecial(maptile) Then
                                        Call SearchAndDestroyObject(parent, rndx + i, rndy + j, undoch, False)
                                    End If

                                    If curSelection.selectionType = TS_Walltiles Then
                                        Call parent.walltiles.setIsWallTile(rndx + i, rndy + j)
                                        tmptile = parent.walltiles.DrawWallTile(rndx + i, rndy + j, True, undoch, False, True)
                                        Call parent.walltiles.setIsWallTile(rndx + i, rndy + j, True)
                                    End If
                                    Call parent.setTile(rndx + i, rndy + j, tmptile + i + 19 * j, undoch)
                                    Call parent.UpdateLevelTile(rndx + i, rndy + j, False)
                                    
                                End If
                            End If
                        End If
                    Next
                    
                End If
            Next
            
'                For l = 0 To tmptileSizeY - 1
'                    For k = 0 To tmptileSizeX - 1
'                        If rndx + k >= 0 And rndy + l >= 0 And _
'                           rndx + k < 1024 And rndy + l < 1024 Then
'                            If AreaClearForObject(parent, rndx + k, rndy + l, tmptile) Then
'                                'if parent.pastetype <> p_under Or _
'                                    'parent.pastetype = p_under And parent.getTile(rndx + k, rndy + l) = 0 Then
'                                If isTileSpecial(parent, rndx + k, rndy + l) Then
'                                    Call SearchAndDestroyObject(parent, rndx + k, rndy + l, undoch, False)
'                                End If
'                                If tmptile = 217 Or tmptile = 219 Or tmptile = 220 Then
'                                    Call setObject(parent, tmptile, rndx, rndy, undoch, False, False)
'                                Else
'                                    If usewalltile Then
'                                        Call parent.walltiles.setIsWallTile(rndx, rndy)
'                                        tmptile = parent.walltiles.DrawWallTile(rndx, rndy, True, undoch, False)
'                                        Call parent.walltiles.setIsWallTile(rndx, rndy, True)
'                                    End If
'                                    Call parent.setTile(rndx + k, rndy + l, tmptile + k + 19 * l, undoch)
'                                    Call parent.UpdateLevelTile(rndx + k, rndy + l, False)
'                                End If
'                            End If
'                        End If
'                    Next
'                Next
            
        'End boundary check
        End If
        
    Next

    If parent.magnifier.UsingPixels Then
        parent.UpdateLevel
    Else
        parent.UpdatePreview
    End If


    DoEvents
    If SharedVar.MouseDown <> 0 Then
        Sleep 25
        GoTo setAnotherRandom
    End If

    On Error GoTo 0
    Exit Sub

MouseMove_Error:
    HandleError Err, "AirBrush.MouseMove"
End Sub

Sub MouseUp()
'do nothing
    On Error GoTo MouseUp_Error

    Call parent.undoredo.AddToUndo(undoch, UNDO_AIRBRUSH)

    'when using tile 0 we need to redraw grid
    parent.UpdateLevel

    On Error GoTo 0
    Exit Sub

MouseUp_Error:
    HandleError Err, "AirBrush.MouseUp"
End Sub

Private Sub Class_Terminate()
    Set parent = Nothing
    Set undoch = Nothing
End Sub
