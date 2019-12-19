; iNES header stuff, just copy

  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; 1x  8KB CHR data
  .inesmap 0   ; mapper 0 = NROM, no bank swapping
  .inesmir 1   ; background mirroring
  
; ==========

  .bank 0
  .org $c000 ; prg code starts here
  
reset:
  sei
  cld
  ldx #$40
  stx $4017
  ldx #$ff
  txs
  inx
  stx $2000
  stx $2001
  stx $4010
  
vblankwait1:
  bit $2002
  bpl vblankwait1
  
clrmem:
  lda #$00
  sta $0000,x
  sta $0100,x
  sta $0200,x
  sta $0300,x
  sta $0400,x
  sta $0500,x
  sta $0600,x
  sta $0700,x
  lda #$fe
  sta $0300,x
  inx
  bne clrmem
  
vblankwait2:
  bit $2002
  bpl vblankwait2
  
  ; load palettes to ppu
loadpalettes:
  lda $2002
  lda #$3f
  sta $2006
  lda #$00
  sta $2006
  ldx #$00

loadbgpalette:
  lda bg_palette,x
  sta $2007
  inx
  cpx #$10
  bne loadbgpalette
  
  ldx #$00
  
loadspritepalette:
  lda sprite_palette,x
  sta $2007
  inx
  cpx #$10
  bne loadspritepalette
  
  lda #%10000000 ; enable nmi, select sprite table
  sta $2000
  lda #%00011110 ; enable sprites
  sta $2001
  
foreverloop:
  jmp foreverloop
    
; ==========
  
nmi: ; triggered every frame, 60 times/s

  lda #$3f  ;change color 3f00 (bg) to 0f
  sta $2006 ;
  lda #$00  ;
  sta $2006 ;
  lda #$0f  ;
  sta $2007 ;

  lda #$00  ; copy all sprites to memory $0200
  sta $2003 ;
  lda #$02  ;
  sta $4014 ;

; draw the sprite
  lda #$01
  sta $0200 ; y position
  lda #$41
  sta $0201 ; tile number
  lda #%00000000
  sta $0202 ; attributes
  lda #$01
  sta $0203 ; x position
  
; draw a background nametable
; trying to figure out on my own
  
; set some bg tiles
; h  o  l  y   f  u  c  k   i  t   w  o  r  k  s
; 48 4f 4c 59  46 55 43 4b  49 54  57 4f 52 4b 53
  lda #$20  
  sta $2006
  lda #$00
  sta $2006
  
  lda #$48
  sta $2007
  lda #$4f
  sta $2007
  lda #$4c
  sta $2007
  lda #$59
  sta $2007
  
  lda #$00
  sta $2007
  
  lda #$46
  sta $2007
  lda #$55
  sta $2007
  lda #$43
  sta $2007
  lda #$4b
  sta $2007
  
  lda #$00
  sta $2007
  
  lda #$49
  sta $2007
  lda #$54
  sta $2007
  
  lda #$00
  sta $2007
  
  lda #$57
  sta $2007
  lda #$4f
  sta $2007
  lda #$52
  sta $2007
  lda #$4b
  sta $2007
  lda #$53
  sta $2007
  
; set palettes  
  lda #$23  ;set palette for first block
  sta $2006
  lda #$c0
  sta $2006
  lda #$00
  sta $2007
    
  rti
  
; ==========
  .bank 1
  .org $e000 ; why $e000 ??
  
; set palette colors
; first color is bg
bg_palette:
  .db $22,$00,$1a,$30 ; backgrounds
  .db $22,$36,$17,$0F
  .db $22,$30,$21,$0F
  .db $22,$27,$17,$0F
  
sprite_palette:
  .db $22,$16,$1a,$28 ; sprites
  .db $22,$1A,$30,$27
  .db $22,$16,$30,$27
  .db $22,$0F,$36,$17

  .org $fffa
  .dw nmi
  .dw reset
  .dw 0
  
; ==========

  .bank 2
  .org $0000
  .incbin "asdf.chr"