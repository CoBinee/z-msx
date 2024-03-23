; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Game.inc"
    .include    "Back.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; パターンジェネレータの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x0000) >> 11)
    ld      (_videoRegister + VDP_R4), a

    ; カラーテーブルの設定
    ld      a, #((APP_COLOR_TABLE + 0x0000) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName

    ; パターンネームの転送
    ld      a, #PATTERN_NAME_TRANSFER_0300
    ld      (_game + GAME_TRANSFER), a

    ; サウンドの停止
    call    _SoundStop

    ; ゲームの初期化
    ld      hl, #gameDefault
    ld      de, #_game
    ld      bc, #GAME_LENGTH
    ldir

    ; 背景の初期化
    call    _BackInitialize

    ; プレイヤの初期化
    call    _PlayerInitialize

    ; エネミーの初期化
    call    _EnemyInitialize
    
    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; 状態の設定
    ld      a, #GAME_STATE_START
    ld      (gameState), a
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (gameState)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; 転送の設定
    ld      hl, #(_game + GAME_TRANSFER)
    ld      a, (hl)
    ld      (_patternNameTransfer), a
    ld      (hl), #0x00

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
GameNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをスタートする
;
GameStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; スタートの描画
    call    GamePrintStart

    ; ステータスの描画
    call    GamePrintStatus

    ; パターンネームの転送
    ld      a, #PATTERN_NAME_TRANSFER_0300
    ld      (_game + GAME_TRANSFER), a

    ; フレームの設定
    ld      a, #0x60
    ld      (_game + GAME_FRAME), a

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
    ld      a, #GAME_STATE_PLAY
    ld      (gameState), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをプレイする
;
GamePlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; パターンネームの転送
    ld      a, #PATTERN_NAME_TRANSFER_0300
    ld      (_game + GAME_TRANSFER), a

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; 背景の更新
    call    _BackUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; ステータスの更新
    call    GameUpdateStatus

    ; 背景の描画
    call    _BackRender

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; ステータスの描画
    call    GamePrintStatus

    ; パターンネームの転送
    ld      hl, #(_game + GAME_TRANSFER)
    ld      a, (hl)
    cp      #PATTERN_NAME_TRANSFER_0300
    jr      z, 10$
    ld      (hl), #PATTERN_NAME_TRANSFER_0040
10$:

    ; リクエストの監視
    ld      a, (_game + GAME_REQUEST)

    ; ゲームクリア
    bit     #GAME_REQUEST_CLEAR_BIT, a
    jr      z, 90$
    ld      a, #GAME_STATE_CLEAR
    ld      (gameState), a
    jr      99$
90$:

    ; ゲームオーバー
    bit     #GAME_REQUEST_OVER_BIT, a
    jr      z, 91$
    ld      a, #GAME_STATE_OVER
    ld      (gameState), a
    jr      99$
91$:

    ; リクエスト監視の完了
99$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームオーバーになる
;
GameOver:

    ; レジスタの保存

    ; 初期化
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; ゲームオーバーの描画
    call    GamePrintOver

    ; ステータスの描画
    call    GamePrintStatus

    ; パターンネームの転送
    ld      a, #PATTERN_NAME_TRANSFER_0300
    ld      (_game + GAME_TRANSFER), a

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; スペースキーの押下
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_appState), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをクリアする
;
GameClear:

    ; レジスタの保存

    ; 初期化
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; クリアの描画
    call    GamePrintClear

    ; パターンネームの転送
    ld      a, #PATTERN_NAME_TRANSFER_0300
    ld      (_game + GAME_TRANSFER), a

    ; BGM の再生
    ld      a, #SOUND_BGM_CLEAR
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; 背景の更新
    call    _BackUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

;   ; ステータスの更新
;   call    GameUpdateStatus

    ; 背景の描画
    call    _BackRender

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

;   ; ステータスの描画
;   call    GamePrintStatus

    ; BGM の監視
    call    _SoundIsPlayBgm
    jr      c, 19$

    ; 状態の更新
    ld      a, #GAME_STATE_RESULT
    ld      (gameState), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームの結果を出す
;
GameResult:

    ; レジスタの保存

    ; 初期化
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; 結果の更新
    call    GameUpdateResult

    ; 結果のパターンネームの描画
    call    GamePrintResultPatternName

    ; パターンジェネレータの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11)
    ld      (_videoRegister + VDP_R4), a

    ; カラーテーブルの設定
    ld      a, #((APP_COLOR_TABLE + 0x0040) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; パターンネームの転送
    ld      a, #PATTERN_NAME_TRANSFER_0300
    ld      (_game + GAME_TRANSFER), a

    ; BGM の再生
    ld      a, #SOUND_BGM_RESULT
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; スペースキーの押下
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_appState), a
19$:

    ; 結果のスプライトの描画
    call    GamePrintResultSprite

    ; レジスタの復帰

    ; 終了
    ret

; ステータスを更新する
;
GameUpdateStatus:

    ; レジスタの保存

    ; 時間の更新
    ld      hl, #(_game + GAME_TIME_1000)
    xor     a
    ld      b, #0x04
10$:
    or      (hl)
    inc     hl
    djnz    10$
    or      a
    jr      z, 19$
11$:
    dec     hl
    ld      a, (hl)
    or      a
    jr      nz, 12$
    ld      (hl), #0x09
    jr      11$
12$:
    dec     (hl)
    ld      hl, #(_game + GAME_TIME_1000)
    ld      b, #0x04
13$:
    ld      a, (hl)
    or      a
    jr      nz, 19$
    inc     hl
    djnz    13$
    call    _PlayerSetBomb
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ステータスを描画する
;
GamePrintStatus:

    ; レジスタの保存

    ; 時間の描画
    ld      hl, #gameStatusPatternName
    ld      de, #(_patternName + 0x000b)
    ld      bc, #0x0004
    ldir
    ld      hl, #(_game + GAME_TIME_1000)
    ld      de, #(_patternName + 0x0010)
    ld      bc, #0x0304
10$:
    ld      a, (hl)
    or      a
    jr      nz, 11$
    ld      (de), a
    inc     hl
    inc     de
    dec     c
    djnz    10$
11$:
    ld      b, c
12$:
    ld      a, (hl)
    add     a, #0x10
    ld      (de), a
    inc     hl
    inc     de
    djnz    12$

    ; レジスタの復帰

    ; 終了
    ret

; スタートを描画する
;
GamePrintStart:

    ; レジスタの保存

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; パターンネームの描画
    ld      hl, #gameStartPatternName
    ld      de, #(_patternName + 0x016c)
    ld      bc, #0x0008
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; ゲームオーバーを描画する
;
GamePrintOver:

    ; レジスタの保存

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; パターンネームの描画
    ld      hl, #gameOverPatternName
    ld      de, #(_patternName + 0x0169)
    ld      bc, #0x000d
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; クリアを描画する
;
GamePrintClear:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #gameClearPatternName
    ld      de, #(_patternName + 0x016b)
    ld      bc, #0x0009
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; 結果を更新する
;
GameUpdateResult:

    ; レジスタの更新

    ; ボーナスの更新
    call    _PlayerIsJust
    jr      nc, 10$
    ld      hl, #(_game + GAME_BONUS_1000)
    inc     (hl)
    ld      hl, #(_game + GAME_FLAG)
    set     #GAME_FLAG_JUST_BIT, (hl)
10$:

    ; スコアの更新
    ld      hl, #(_game + GAME_TIME_1000)
    ld      de, #(_game + GAME_SCORE_1000)
    ld      bc, #0x0004
    ldir
    ld      hl, #(_game + GAME_SCORE_0001)
    ld      de, #(_game + GAME_BONUS_0001)
    ld      bc, #0x0400
20$:
    ld      a, (de)
    add     a, (hl)
    add     a, c
    ld      (hl), a
    ld      c, #0x00
    cp      #0x0a
    jr      c, 21$
    ld      (hl), #0x09
    inc     c
21$:
    dec     hl
    dec     de
    djnz    20$

    ; トップの更新
    ld      de, #(_game + GAME_SCORE_1000)
    call    _AppUpdateScore
    jr      nc, 30$
    ld      hl, #(_game + GAME_FLAG)
    set     #GAME_FLAG_TOP_BIT, (hl)
30$:

    ; レジスタの復帰

    ; 終了
    ret

; 結果を描画する
;
GamePrintResultPatternName:

    ; レジスタの保存

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; 背景の描画
    ld      hl, #gameResultPatternNameBack
    ld      de, #(_patternName + 0x010a)
    ld      b, #0x10
10$:
    push    bc
    ld      bc, #0x0016
    ldir
    ex      de, hl
    ld      bc, #(0x0020 - 0x0016)
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    10$

    ; 時間の描画
20$:
    ld      hl, #gameResultPatternNameTime
    ld      de, #(_patternName + 0x0022)
    ld      bc, #0x0006
    ldir
    ld      hl, #(_game + GAME_TIME_1000)
    call    80$

    ; ボーナスの描画
30$:
    ld      hl, #gameResultPatternNameBonus
    ld      de, #(_patternName + 0x0062)
    ld      bc, #0x0006
    ldir
    ld      hl, #(_game + GAME_BONUS_1000)
    call    80$

    ; スコアの描画
40$:
    ld      hl, #gameResultPatternNameScore
    ld      de, #(_patternName + 0x00a2)
    ld      bc, #0x0006
    ldir
    ld      hl, #(_game + GAME_SCORE_1000)
    call    80$

    ; トップの描画
50$:
    ld      a, (_game + GAME_FLAG)
    bit     #GAME_FLAG_TOP_BIT, a
    jr      z, 59$
    ld      hl, #gameResultPatternNameTop
    ld      de, #(_patternName + 0x00e2)
    ld      bc, #0x000a
    ldir
59$:

    ; ジャストの描画
60$:
    ld      a, (_game + GAME_FLAG)
    bit     #GAME_FLAG_JUST_BIT, a
    jr      z, 69$
    ld      hl, #gameResultPatternNameJust
    ld      de, #(_patternName + 0x006f)
    ld      bc, #0x000e
    ldir
69$:
    jr      90$

    ; 数字の描画
80$:
    ld      b, #0x03
81$:
    ld      a, (hl)
    or      a
    jr      nz, 82$
    inc     hl
    inc     de
    djnz    81$
82$:
    inc     b
83$:
    ld      a, (hl)
    add     a, #0x10
    ld      (de), a
    inc     hl
    inc     de
    djnz    83$
    ret

    ; 描画の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

GamePrintResultSprite:

    ; レジスタの保存

    ; スプライトの描画
    ld      hl, #gameResultSprite
    ld      de, #_sprite
    ld      bc, #(0x0010 * 0x0004)
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
gameProc:
    
    .dw     GameNull
    .dw     GameStart
    .dw     GamePlay
    .dw     GameOver
    .dw     GameClear
    .dw     GameResult

; ゲームの初期値
;
gameDefault:

    .db     GAME_REQUEST_NULL
    .db     GAME_FLAG_NULL
    .db     GAME_FRAME_NULL
    .db     PATTERN_NAME_TRANSFER_NULL
    .db     0x03 ; GAME_TIME_NULL
    .db     0x00 ; GAME_TIME_NULL
    .db     0x00 ; GAME_TIME_NULL
    .db     0x00 ; GAME_TIME_NULL
    .db     0x00 ; GAME_BONUS_NULL
    .db     0x00 ; GAME_BONUS_NULL
    .db     0x00 ; GAME_BONUS_NULL
    .db     0x00 ; GAME_BONUS_NULL
    .db     0x00 ; GAME_SCORE_NULL
    .db     0x00 ; GAME_SCORE_NULL
    .db     0x00 ; GAME_SCORE_NULL
    .db     0x00 ; GAME_SCORE_NULL

; ステータス
;
gameStatusPatternName:

    .db     0x34, 0x29, 0x2d, 0x25

; スタート
;
gameStartPatternName:

    .db     0x2d, 0x21, 0x3a, 0x29, 0x2e, 0x00, 0x27, 0x2f

; ゲームオーバー
;
gameOverPatternName:

    .db     0x2e, 0x2f, 0x34, 0x00, 0x30, 0x29, 0x2c, 0x24, 0x25, 0x32, 0x00, 0x2f, 0x2e

; クリア
;
gameClearPatternName:

    .db     0x30, 0x29, 0x2c, 0x24, 0x25, 0x32, 0x00, 0x2f, 0x2e

; 結果
;
gameResultPatternNameBack:

    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41, 0x42, 0x43, 0x44, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x45, 0x46, 0x40, 0x40, 0x47, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x48, 0x49, 0x4a, 0x4b, 0x40, 0x4c
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4d, 0x4e, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x50, 0x51, 0x40, 0x40, 0x40
    .db     0x00, 0x00, 0x00, 0x00, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x71, 0x72, 0x73, 0x00, 0x74, 0x75, 0x00, 0x00, 0x58, 0x40, 0x40, 0x40
    .db     0x00, 0x00, 0x00, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f, 0x91, 0x90, 0xb0, 0x76, 0x77, 0x78, 0x00, 0x00, 0x60, 0x40, 0x40, 0x40
    .db     0x00, 0x00, 0x00, 0x61, 0x40, 0x40, 0x62, 0x92, 0x93, 0x79, 0x90, 0x90, 0xb1, 0x70, 0x7a, 0x7b, 0x88, 0x89, 0x00, 0x63, 0x40, 0x40
    .db     0x00, 0x00, 0x00, 0x64, 0x40, 0xd0, 0xd1, 0xd2, 0xd3, 0xb2, 0xb3, 0xb4, 0xcc, 0xcd, 0x94, 0x95, 0x8a, 0x7c, 0x7d, 0x70, 0x68, 0x40
    .db     0x00, 0x00, 0x00, 0xa3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0xdb, 0x90, 0x90, 0x90, 0x90, 0xb5, 0x70, 0x70, 0x70, 0x70, 0x69
    .db     0x00, 0x00, 0x00, 0x96, 0xdc, 0xdd, 0xde, 0xdf, 0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0x90, 0xb6, 0x70, 0x70, 0x70, 0x70, 0x70, 0x70
    .db     0x00, 0x00, 0x97, 0x90, 0xe6, 0x90, 0xe7, 0xe8, 0xe9, 0xea, 0xeb, 0xec, 0x90, 0x90, 0x90, 0xb7, 0x70, 0x70, 0x70, 0x70, 0x7e, 0x7f
    .db     0x00, 0x00, 0x80, 0xb8, 0xb9, 0xba, 0xbb, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0xbc, 0xbd, 0xbe, 0x81, 0x82, 0x83, 0x00
    .db     0x00, 0x84, 0x70, 0x70, 0x70, 0x70, 0xbf, 0xc0, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x98, 0x99, 0x00, 0x00, 0x00
    .db     0x00, 0x85, 0xc1, 0xc2, 0x70, 0x70, 0x70, 0x70, 0xc3, 0x90, 0x90, 0x90, 0x90, 0x90, 0x9a, 0x9b, 0x9c, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x9d, 0x9e, 0x90, 0x90, 0xc4, 0xc5, 0xc6, 0x70, 0x70, 0xc7, 0xc8, 0xc9, 0x9f, 0xa0, 0xa1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0xa2, 0x90, 0x90, 0x90, 0x90, 0x90, 0xca, 0xcb, 0x70, 0x70, 0x70, 0x86, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

gameResultPatternNameTime:

    .db     0x34, 0x29, 0x2d, 0x25, 0x00, 0x00

gameResultPatternNameBonus:

    .db     0x22, 0x2f, 0x2e, 0x35, 0x33, 0x00

gameResultPatternNameScore:

    .db     0x33, 0x23, 0x2f, 0x32, 0x25, 0x00

gameResultPatternNameTop:

    .db     0x34, 0x2f, 0x30, 0x00, 0x33, 0x23, 0x2f, 0x32, 0x25, 0x01

gameResultPatternNameJust:

    .db     0x2a, 0x35, 0x33, 0x34, 0x00, 0x30, 0x29, 0x2c, 0x24, 0x25, 0x32, 0x00, 0x2f, 0x2e

gameResultSprite:

    .db     0x30 + 0x40 - 0x01, 0x24 + 0x50, 0x60, VDP_COLOR_LIGHT_RED
    .db     0x38 + 0x40 - 0x01, 0x1b + 0x50, 0x64, VDP_COLOR_WHITE
    .db     0x38 + 0x40 - 0x01, 0x60 + 0x50, 0x68, VDP_COLOR_LIGHT_RED
    .db     0x18 + 0x40 - 0x01, 0x5b + 0x50, 0x6c, VDP_COLOR_LIGHT_RED
    .db     0x1d + 0x40 - 0x01, 0x43 + 0x50, 0x70, VDP_COLOR_LIGHT_YELLOW
    .db     0x28 + 0x40 - 0x01, 0x50 + 0x50, 0x74, VDP_COLOR_WHITE
    .db     0x28 + 0x40 - 0x01, 0x5e + 0x50, 0x78, VDP_COLOR_LIGHT_YELLOW
    .db     0x36 + 0x40 - 0x01, 0x70 + 0x50, 0x7c, VDP_COLOR_LIGHT_RED
    .db     0x5e + 0x40 - 0x01, 0x90 + 0x50, 0x80, VDP_COLOR_BLACK
    .db     0x18 + 0x40 - 0x01, 0x56 + 0x50, 0x84, VDP_COLOR_BLACK
    .db     0x28 + 0x40 - 0x01, 0x56 + 0x50, 0x88, VDP_COLOR_LIGHT_BLUE
    .db     0x00 + 0x40 - 0x01, 0x00 + 0x50, 0x00, VDP_COLOR_WHITE
    .db     0x00 + 0x40 - 0x01, 0x00 + 0x50, 0x00, VDP_COLOR_WHITE
    .db     0x00 + 0x40 - 0x01, 0x00 + 0x50, 0x00, VDP_COLOR_WHITE
    .db     0x00 + 0x40 - 0x01, 0x00 + 0x50, 0x00, VDP_COLOR_WHITE
    .db     0x00 + 0x40 - 0x01, 0x00 + 0x50, 0x00, VDP_COLOR_WHITE


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
gameState:
    
    .ds     1

; ゲーム
;
_game:

    .ds     GAME_LENGTH
