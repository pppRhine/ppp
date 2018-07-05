org 8400h   ;密码为123ppp,正确出现welcome 错误出现errors，可实现删除功能，可先比较输入字符串长度判断对错，避免出现123ppppp此类输入判对的情况

jmp uboot

space		db 	'0000000000000000'	;用来存放输入内容的空间
tishi		db 	'Please input password.#'
errors 		db 	'error!#'
welcome  	db 	'You are welcome!#'
secret  	db 	'123ppp'
choice 		db	'error! enter 1 to input again,or exit'


;用到的寄存器al bl ds es di si
string:
	string1begin:
	mov al,[ds:di]
	cmp al,'#'
	je stringend

	mov byte[es:si],al
	inc si
	mov byte[es:si],bl
	inc si
	inc di
	jmp string1begin

	stringend:	
	ret


uboot:
	;默认进入80*25的文本模式，起始地址0xB8000
	;es 显存地址
	;ds 数据地址
	mov ax,0xb800    ;指向文本模式的显示缓冲区
  	mov es,ax
	mov ax,0
	mov ds,ax


	mov di,tishi			;确定要显示的字符串
	mov si,0x00			;在第一行第一位显示字符串1
	mov bl,0x09			;字符串1的颜色
	call string			;写入显存，显示字符串


	mov di,space			;存放输入数据的位置
	mov si,0xa0				;显示输入的位置
	mov al,0x00
begin:
	mov ah,0x00
	int 16h
	cmp al,0x0d	;回车键的ascii码
	je end
	cmp al,8d	;删除键的ascii码
	je backspace
	mov byte[ds:di],al
	inc di
	mov bl,'*'
	mov byte[es:si],bl		;将内容显示
	inc si
	mov byte[es:si],0x0f	;白颜色
	inc si
	jmp begin
backspace:
	dec di
	dec si
	dec si
	mov bl,' '
	mov byte[es:si],bl		;将内容显示
	inc si
	mov byte[es:si],0x00	;颜色
	dec si
	jmp begin
	
end:
        mov cl,00h
	mov si,0xa0
start1: 
	mov al,byte[es:si]
	cmp al,'*'
	jne out
	inc si
	inc si
	inc cl
	jmp start1
out:
	cmp cl,06h
	jne error
	mov si,secret			;si指向密码
	mov di,space			;di指向输入的数据
	mov bh,0x00
loop1:
	cmp bh,0x06
	jnb wel
	mov al,[ds:si]
	cmp al,[ds:di]
	jne error
	inc bh
	inc si
	inc di
	jmp loop1

wel:					;显示欢迎提示
	mov di,welcome
	mov si,320d			
	mov bl,0x09			
	call string		
	jmp $

error:    				;显示错误提示
	mov di,errors		
	mov si,320d			
	mov bl,0x0c			
	call string		
	jmp $	
jmp $	


	mov di,errors		
	mov si,320d			
	mov bl,0x0c			
	call string		
	jmp $	
jmp $	