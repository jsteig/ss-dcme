VERSION 5.00
Begin VB.Form frmRotate 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Rotate selection"
   ClientHeight    =   2520
   ClientLeft      =   210
   ClientTop       =   450
   ClientWidth     =   3315
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2520
   ScaleWidth      =   3315
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton cmdRotate270 
      Caption         =   "Rotate 270�"
      Height          =   375
      Left            =   2040
      TabIndex        =   4
      Top             =   1320
      Width           =   1095
   End
   Begin VB.CommandButton cmdRotate180 
      Caption         =   "Rotate 180�"
      Height          =   375
      Left            =   2040
      TabIndex        =   3
      Top             =   840
      Width           =   1095
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "Close"
      Height          =   375
      Left            =   360
      TabIndex        =   5
      Top             =   1440
      Width           =   1215
   End
   Begin VB.Frame frmDirection 
      Caption         =   "Direction"
      Height          =   1095
      Left            =   0
      TabIndex        =   0
      Top             =   120
      Width           =   1815
      Begin VB.OptionButton optDir 
         Caption         =   "Counterclockwise"
         Height          =   255
         Index           =   1
         Left            =   120
         TabIndex        =   2
         Top             =   720
         Width           =   1575
      End
      Begin VB.OptionButton optDir 
         Caption         =   "Clockwise"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   1
         Top             =   240
         Value           =   -1  'True
         Width           =   1335
      End
   End
   Begin VB.Frame frmAngle 
      Caption         =   "Angle"
      Height          =   2175
      Left            =   1920
      TabIndex        =   6
      Top             =   120
      Width           =   1335
      Begin VB.TextBox txtRotate 
         Height          =   285
         Left            =   120
         MaxLength       =   3
         TabIndex        =   8
         Text            =   "0"
         Top             =   1680
         Width           =   495
      End
      Begin VB.CommandButton cmdRotateFree 
         Caption         =   "Free"
         Height          =   375
         Left            =   720
         TabIndex        =   9
         Top             =   1680
         Width           =   495
      End
      Begin VB.CommandButton cmdRotate90 
         Caption         =   "Rotate 90�"
         Height          =   375
         Left            =   120
         TabIndex        =   7
         Top             =   240
         Width           =   1095
      End
   End
End
Attribute VB_Name = "frmRotate"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit




Private Sub cmdCancel_Click()
'Cancels the form
    Unload Me
End Sub

Private Sub cmdRotate180_Click()
'Rotate 180�
    Call frmGeneral.ExecuteRotate(2)
End Sub

Private Sub cmdRotate270_Click()
'Rotate either 90 or 270
    If optDir(0).value Then
        Call frmGeneral.ExecuteRotate(3)
    ElseIf optDir(1).value Then
        Call frmGeneral.ExecuteRotate(1)
    End If
End Sub

Private Sub cmdRotate90_Click()
'Rotate either 90 or 270
    If optDir(0).value Then
        Call frmGeneral.ExecuteRotate(1)
    ElseIf optDir(1).value Then
        Call frmGeneral.ExecuteRotate(3)
    End If
End Sub

Private Sub cmdRotateFree_Click()
    If val(txtRotate.Text) = 0 Then
        Exit Sub

        'Commented out for now, so we can test the method's accuracy
    ElseIf val(txtRotate.Text) = 90 Then
        cmdRotate90_Click
    ElseIf val(txtRotate.Text) = 180 Then
        cmdRotate180_Click
    ElseIf val(txtRotate.Text) = 270 Then
        cmdRotate270_Click
    Else
        If optDir(0).value Then
            Call frmGeneral.ExecuteRotate(4, CDbl(-(val(txtRotate.Text) * 3.14159) / 180))
        ElseIf optDir(1).value Then
            Call frmGeneral.ExecuteRotate(4, CDbl((val(txtRotate.Text) * 3.14159) / 180))
        End If
    End If

    Call SetSetting("FreeRotateAngle", txtRotate.Text)
End Sub

Private Sub Form_Load()
    Set Me.Icon = frmGeneral.Icon

    txtRotate.Text = GetSetting("FreeRotateAngle", "0")
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
'Cancels the form
    cmdCancel_Click
End Sub



Private Sub txtRotate_Change()
    Call removeDisallowedCharacters(txtRotate, 0, 360)
End Sub
