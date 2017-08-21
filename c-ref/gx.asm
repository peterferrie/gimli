;
;  Copyright © 2017 Odzhan. All Rights Reserved.
;
;  Redistribution and use in source and binary forms, with or without
;  modification, are permitted provided that the following conditions are
;  met:
;
;  1. Redistributions of source code must retain the above copyright
;  notice, this list of conditions and the following disclaimer.
;
;  2. Redistributions in binary form must reproduce the above copyright
;  notice, this list of conditions and the following disclaimer in the
;  documentation and/or other materials provided with the distribution.
;
;  3. The name of the author may not be used to endorse or promote products
;  derived from this software without specific prior written permission.
;
;  THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
;  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
;  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;  POSSIBILITY OF SUCH DAMAGE.
;
; -----------------------------------------------
; Gimli permutation function
;
; size: 131 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------
bits 32

%define x ebx
%define y edi
%define z ebp

%define j edx
%define r ecx
%define s esi

%define t0 ecx 
%define t1 edx

%define s0 eax
%define s1 ebx
%define s2 edx
%define s3 ebp

gimli:
_gimli:
    pushad
    mov    esi, [esp+32+4] ; esi = s    
    push   24
    pop    ecx
g_l0:
    push   esi
    push   ecx
    xor    eax, eax
g_l1:
    ; x = ROTR32(s[    j], 8);
    mov    x, [s + j * 4]  
    ror    x, 8  
    
    ; y = ROTL32(s[4 + j], 9);
    mov    y, [s + j * 4 + (4*4)]   
    rol    y, 9
    
    ; z =        s[8 + j];
    mov    z, [s + j * 4 + (4*8)]
    
    ; s[8 + j] = x ^ (z << 1) ^ ((y & z) << 2);
    mov    t0, y
    lea    t1, [z + z]
    and    t0, z
    shl    t0, 2
    xor    t1, t0
    mov    t0, x
    xor    t0, t1    
    mov    [s + j*4 + (8*4)], t0
    
    ; s[4 + j] = y ^ x        ^ ((x | z) << 1);
    mov    t0, x
    mov    t1, y
    or     t0, z
    shl    t0, 1
    xor    t1, x
    xor    t1, t0
    mov    [s + j*4 + (4*4)], t1
    
    ; s[j]     = z ^ y        ^ ((x & y) << 3);
    
    xor    z, y
    and    x, y
    shl    x, 3
    xor    z, x
    mov    [s + j*4], z
    
    inc    eax
    cmp    al, 4
    jnz    g_l1
    
    pop    ecx
    
    lodsd
    xchg   eax, s3
    lodsd
    xchg   eax, s1
    lodsd
    xchg   eax, s2
    lodsd
    xchg   eax, s3
    pop    esi
    mov    edi, esi
    
    mov    dl, cl
    and    dl, 3
    jnz    g_l2
    
    ; XCHG (s[0], s[1]);
    xchg   s0, s1
    ; XCHG (s[2], s[3]);
    xchg   s2, s3
    ; s[0] ^= 0x9e377900 ^ r;
    xor    s0, 0x9e377900
    xor    s0, ecx    
g_l2:
    cmp    dl, 2
    jnz    g_l3  
    ; XCHG (s[0], s[2]);
    xchg   s0, s2
    ; XCHG (s[1], s[3]);
    xchg   s1, s3
g_l3:    
    stosd
    xchg   eax, s1
    stosd
    xchg   eax, s2
    stosd
    xchg   eax, s3
    stosd    
    loop   g_l0    
    popad
    ret
    
    
    