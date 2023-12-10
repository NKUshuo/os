
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c020b137          	lui	sp,0xc020b

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	000a1517          	auipc	a0,0xa1
ffffffffc020003a:	f7250513          	addi	a0,a0,-142 # ffffffffc02a0fa8 <edata>
ffffffffc020003e:	000ac617          	auipc	a2,0xac
ffffffffc0200042:	4fa60613          	addi	a2,a2,1274 # ffffffffc02ac538 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	18a060ef          	jal	ra,ffffffffc02061d8 <memset>
    cons_init();                // init the console
ffffffffc0200052:	58e000ef          	jal	ra,ffffffffc02005e0 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	5c258593          	addi	a1,a1,1474 # ffffffffc0206618 <etext+0x6>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	5da50513          	addi	a0,a0,1498 # ffffffffc0206638 <etext+0x26>
ffffffffc0200066:	06a000ef          	jal	ra,ffffffffc02000d0 <cprintf>

    print_kerninfo();
ffffffffc020006a:	25a000ef          	jal	ra,ffffffffc02002c4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	57b030ef          	jal	ra,ffffffffc0203de8 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5e2000ef          	jal	ra,ffffffffc0200654 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5ec000ef          	jal	ra,ffffffffc0200662 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	19c010ef          	jal	ra,ffffffffc0201216 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	565050ef          	jal	ra,ffffffffc0205de2 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4b0000ef          	jal	ra,ffffffffc0200532 <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	06f010ef          	jal	ra,ffffffffc02018f4 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	500000ef          	jal	ra,ffffffffc020058a <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5c8000ef          	jal	ra,ffffffffc0200656 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	69d050ef          	jal	ra,ffffffffc0205f2e <cpu_idle>

ffffffffc0200096 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200096:	1141                	addi	sp,sp,-16
ffffffffc0200098:	e022                	sd	s0,0(sp)
ffffffffc020009a:	e406                	sd	ra,8(sp)
ffffffffc020009c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009e:	544000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
    (*cnt) ++;
ffffffffc02000a2:	401c                	lw	a5,0(s0)
}
ffffffffc02000a4:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a6:	2785                	addiw	a5,a5,1
ffffffffc02000a8:	c01c                	sw	a5,0(s0)
}
ffffffffc02000aa:	6402                	ld	s0,0(sp)
ffffffffc02000ac:	0141                	addi	sp,sp,16
ffffffffc02000ae:	8082                	ret

ffffffffc02000b0 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000b0:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	86ae                	mv	a3,a1
ffffffffc02000b4:	862a                	mv	a2,a0
ffffffffc02000b6:	006c                	addi	a1,sp,12
ffffffffc02000b8:	00000517          	auipc	a0,0x0
ffffffffc02000bc:	fde50513          	addi	a0,a0,-34 # ffffffffc0200096 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000c0:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000c2:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c4:	1aa060ef          	jal	ra,ffffffffc020626e <vprintfmt>
    return cnt;
}
ffffffffc02000c8:	60e2                	ld	ra,24(sp)
ffffffffc02000ca:	4532                	lw	a0,12(sp)
ffffffffc02000cc:	6105                	addi	sp,sp,32
ffffffffc02000ce:	8082                	ret

ffffffffc02000d0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000d2:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	f42e                	sd	a1,40(sp)
ffffffffc02000d8:	f832                	sd	a2,48(sp)
ffffffffc02000da:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	862a                	mv	a2,a0
ffffffffc02000de:	004c                	addi	a1,sp,4
ffffffffc02000e0:	00000517          	auipc	a0,0x0
ffffffffc02000e4:	fb650513          	addi	a0,a0,-74 # ffffffffc0200096 <cputch>
ffffffffc02000e8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000ea:	ec06                	sd	ra,24(sp)
ffffffffc02000ec:	e0ba                	sd	a4,64(sp)
ffffffffc02000ee:	e4be                	sd	a5,72(sp)
ffffffffc02000f0:	e8c2                	sd	a6,80(sp)
ffffffffc02000f2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f8:	176060ef          	jal	ra,ffffffffc020626e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fc:	60e2                	ld	ra,24(sp)
ffffffffc02000fe:	4512                	lw	a0,4(sp)
ffffffffc0200100:	6125                	addi	sp,sp,96
ffffffffc0200102:	8082                	ret

ffffffffc0200104 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200104:	4de0006f          	j	ffffffffc02005e2 <cons_putc>

ffffffffc0200108 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200108:	1101                	addi	sp,sp,-32
ffffffffc020010a:	e822                	sd	s0,16(sp)
ffffffffc020010c:	ec06                	sd	ra,24(sp)
ffffffffc020010e:	e426                	sd	s1,8(sp)
ffffffffc0200110:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200112:	00054503          	lbu	a0,0(a0)
ffffffffc0200116:	c51d                	beqz	a0,ffffffffc0200144 <cputs+0x3c>
ffffffffc0200118:	0405                	addi	s0,s0,1
ffffffffc020011a:	4485                	li	s1,1
ffffffffc020011c:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020011e:	4c4000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
    (*cnt) ++;
ffffffffc0200122:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	0405                	addi	s0,s0,1
ffffffffc0200128:	fff44503          	lbu	a0,-1(s0)
ffffffffc020012c:	f96d                	bnez	a0,ffffffffc020011e <cputs+0x16>
ffffffffc020012e:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200132:	4529                	li	a0,10
ffffffffc0200134:	4ae000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200138:	8522                	mv	a0,s0
ffffffffc020013a:	60e2                	ld	ra,24(sp)
ffffffffc020013c:	6442                	ld	s0,16(sp)
ffffffffc020013e:	64a2                	ld	s1,8(sp)
ffffffffc0200140:	6105                	addi	sp,sp,32
ffffffffc0200142:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200144:	4405                	li	s0,1
ffffffffc0200146:	b7f5                	j	ffffffffc0200132 <cputs+0x2a>

ffffffffc0200148 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200148:	1141                	addi	sp,sp,-16
ffffffffc020014a:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020014c:	4cc000ef          	jal	ra,ffffffffc0200618 <cons_getc>
ffffffffc0200150:	dd75                	beqz	a0,ffffffffc020014c <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200152:	60a2                	ld	ra,8(sp)
ffffffffc0200154:	0141                	addi	sp,sp,16
ffffffffc0200156:	8082                	ret

ffffffffc0200158 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200158:	715d                	addi	sp,sp,-80
ffffffffc020015a:	e486                	sd	ra,72(sp)
ffffffffc020015c:	e0a2                	sd	s0,64(sp)
ffffffffc020015e:	fc26                	sd	s1,56(sp)
ffffffffc0200160:	f84a                	sd	s2,48(sp)
ffffffffc0200162:	f44e                	sd	s3,40(sp)
ffffffffc0200164:	f052                	sd	s4,32(sp)
ffffffffc0200166:	ec56                	sd	s5,24(sp)
ffffffffc0200168:	e85a                	sd	s6,16(sp)
ffffffffc020016a:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020016c:	c901                	beqz	a0,ffffffffc020017c <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020016e:	85aa                	mv	a1,a0
ffffffffc0200170:	00006517          	auipc	a0,0x6
ffffffffc0200174:	4d050513          	addi	a0,a0,1232 # ffffffffc0206640 <etext+0x2e>
ffffffffc0200178:	f59ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
readline(const char *prompt) {
ffffffffc020017c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020017e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0200180:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200182:	4aa9                	li	s5,10
ffffffffc0200184:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200186:	000a1b97          	auipc	s7,0xa1
ffffffffc020018a:	e22b8b93          	addi	s7,s7,-478 # ffffffffc02a0fa8 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020018e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0200192:	fb7ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc0200196:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200198:	00054b63          	bltz	a0,ffffffffc02001ae <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020019c:	00a95b63          	ble	a0,s2,ffffffffc02001b2 <readline+0x5a>
ffffffffc02001a0:	029a5463          	ble	s1,s4,ffffffffc02001c8 <readline+0x70>
        c = getchar();
ffffffffc02001a4:	fa5ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc02001a8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001aa:	fe0559e3          	bgez	a0,ffffffffc020019c <readline+0x44>
            return NULL;
ffffffffc02001ae:	4501                	li	a0,0
ffffffffc02001b0:	a099                	j	ffffffffc02001f6 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02001b2:	03341463          	bne	s0,s3,ffffffffc02001da <readline+0x82>
ffffffffc02001b6:	e8b9                	bnez	s1,ffffffffc020020c <readline+0xb4>
        c = getchar();
ffffffffc02001b8:	f91ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc02001bc:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001be:	fe0548e3          	bltz	a0,ffffffffc02001ae <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001c2:	fea958e3          	ble	a0,s2,ffffffffc02001b2 <readline+0x5a>
ffffffffc02001c6:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001c8:	8522                	mv	a0,s0
ffffffffc02001ca:	f3bff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i ++] = c;
ffffffffc02001ce:	009b87b3          	add	a5,s7,s1
ffffffffc02001d2:	00878023          	sb	s0,0(a5)
ffffffffc02001d6:	2485                	addiw	s1,s1,1
ffffffffc02001d8:	bf6d                	j	ffffffffc0200192 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02001da:	01540463          	beq	s0,s5,ffffffffc02001e2 <readline+0x8a>
ffffffffc02001de:	fb641ae3          	bne	s0,s6,ffffffffc0200192 <readline+0x3a>
            cputchar(c);
ffffffffc02001e2:	8522                	mv	a0,s0
ffffffffc02001e4:	f21ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i] = '\0';
ffffffffc02001e8:	000a1517          	auipc	a0,0xa1
ffffffffc02001ec:	dc050513          	addi	a0,a0,-576 # ffffffffc02a0fa8 <edata>
ffffffffc02001f0:	94aa                	add	s1,s1,a0
ffffffffc02001f2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001f6:	60a6                	ld	ra,72(sp)
ffffffffc02001f8:	6406                	ld	s0,64(sp)
ffffffffc02001fa:	74e2                	ld	s1,56(sp)
ffffffffc02001fc:	7942                	ld	s2,48(sp)
ffffffffc02001fe:	79a2                	ld	s3,40(sp)
ffffffffc0200200:	7a02                	ld	s4,32(sp)
ffffffffc0200202:	6ae2                	ld	s5,24(sp)
ffffffffc0200204:	6b42                	ld	s6,16(sp)
ffffffffc0200206:	6ba2                	ld	s7,8(sp)
ffffffffc0200208:	6161                	addi	sp,sp,80
ffffffffc020020a:	8082                	ret
            cputchar(c);
ffffffffc020020c:	4521                	li	a0,8
ffffffffc020020e:	ef7ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            i --;
ffffffffc0200212:	34fd                	addiw	s1,s1,-1
ffffffffc0200214:	bfbd                	j	ffffffffc0200192 <readline+0x3a>

ffffffffc0200216 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200216:	000ac317          	auipc	t1,0xac
ffffffffc020021a:	19230313          	addi	t1,t1,402 # ffffffffc02ac3a8 <is_panic>
ffffffffc020021e:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200222:	715d                	addi	sp,sp,-80
ffffffffc0200224:	ec06                	sd	ra,24(sp)
ffffffffc0200226:	e822                	sd	s0,16(sp)
ffffffffc0200228:	f436                	sd	a3,40(sp)
ffffffffc020022a:	f83a                	sd	a4,48(sp)
ffffffffc020022c:	fc3e                	sd	a5,56(sp)
ffffffffc020022e:	e0c2                	sd	a6,64(sp)
ffffffffc0200230:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200232:	02031c63          	bnez	t1,ffffffffc020026a <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200236:	4785                	li	a5,1
ffffffffc0200238:	8432                	mv	s0,a2
ffffffffc020023a:	000ac717          	auipc	a4,0xac
ffffffffc020023e:	16f73723          	sd	a5,366(a4) # ffffffffc02ac3a8 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200242:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200244:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200246:	85aa                	mv	a1,a0
ffffffffc0200248:	00006517          	auipc	a0,0x6
ffffffffc020024c:	40050513          	addi	a0,a0,1024 # ffffffffc0206648 <etext+0x36>
    va_start(ap, fmt);
ffffffffc0200250:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200252:	e7fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200256:	65a2                	ld	a1,8(sp)
ffffffffc0200258:	8522                	mv	a0,s0
ffffffffc020025a:	e57ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc020025e:	00008517          	auipc	a0,0x8
ffffffffc0200262:	39a50513          	addi	a0,a0,922 # ffffffffc02085f8 <default_pmm_manager+0x888>
ffffffffc0200266:	e6bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020026a:	4501                	li	a0,0
ffffffffc020026c:	4581                	li	a1,0
ffffffffc020026e:	4601                	li	a2,0
ffffffffc0200270:	48a1                	li	a7,8
ffffffffc0200272:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc0200276:	3e6000ef          	jal	ra,ffffffffc020065c <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020027a:	4501                	li	a0,0
ffffffffc020027c:	174000ef          	jal	ra,ffffffffc02003f0 <kmonitor>
ffffffffc0200280:	bfed                	j	ffffffffc020027a <__panic+0x64>

ffffffffc0200282 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200282:	715d                	addi	sp,sp,-80
ffffffffc0200284:	e822                	sd	s0,16(sp)
ffffffffc0200286:	fc3e                	sd	a5,56(sp)
ffffffffc0200288:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc020028a:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020028c:	862e                	mv	a2,a1
ffffffffc020028e:	85aa                	mv	a1,a0
ffffffffc0200290:	00006517          	auipc	a0,0x6
ffffffffc0200294:	3d850513          	addi	a0,a0,984 # ffffffffc0206668 <etext+0x56>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200298:	ec06                	sd	ra,24(sp)
ffffffffc020029a:	f436                	sd	a3,40(sp)
ffffffffc020029c:	f83a                	sd	a4,48(sp)
ffffffffc020029e:	e0c2                	sd	a6,64(sp)
ffffffffc02002a0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02002a2:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02002a4:	e2dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02002a8:	65a2                	ld	a1,8(sp)
ffffffffc02002aa:	8522                	mv	a0,s0
ffffffffc02002ac:	e05ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc02002b0:	00008517          	auipc	a0,0x8
ffffffffc02002b4:	34850513          	addi	a0,a0,840 # ffffffffc02085f8 <default_pmm_manager+0x888>
ffffffffc02002b8:	e19ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    va_end(ap);
}
ffffffffc02002bc:	60e2                	ld	ra,24(sp)
ffffffffc02002be:	6442                	ld	s0,16(sp)
ffffffffc02002c0:	6161                	addi	sp,sp,80
ffffffffc02002c2:	8082                	ret

ffffffffc02002c4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002c4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002c6:	00006517          	auipc	a0,0x6
ffffffffc02002ca:	3f250513          	addi	a0,a0,1010 # ffffffffc02066b8 <etext+0xa6>
void print_kerninfo(void) {
ffffffffc02002ce:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002d0:	e01ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002d4:	00000597          	auipc	a1,0x0
ffffffffc02002d8:	d6258593          	addi	a1,a1,-670 # ffffffffc0200036 <kern_init>
ffffffffc02002dc:	00006517          	auipc	a0,0x6
ffffffffc02002e0:	3fc50513          	addi	a0,a0,1020 # ffffffffc02066d8 <etext+0xc6>
ffffffffc02002e4:	dedff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002e8:	00006597          	auipc	a1,0x6
ffffffffc02002ec:	32a58593          	addi	a1,a1,810 # ffffffffc0206612 <etext>
ffffffffc02002f0:	00006517          	auipc	a0,0x6
ffffffffc02002f4:	40850513          	addi	a0,a0,1032 # ffffffffc02066f8 <etext+0xe6>
ffffffffc02002f8:	dd9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002fc:	000a1597          	auipc	a1,0xa1
ffffffffc0200300:	cac58593          	addi	a1,a1,-852 # ffffffffc02a0fa8 <edata>
ffffffffc0200304:	00006517          	auipc	a0,0x6
ffffffffc0200308:	41450513          	addi	a0,a0,1044 # ffffffffc0206718 <etext+0x106>
ffffffffc020030c:	dc5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200310:	000ac597          	auipc	a1,0xac
ffffffffc0200314:	22858593          	addi	a1,a1,552 # ffffffffc02ac538 <end>
ffffffffc0200318:	00006517          	auipc	a0,0x6
ffffffffc020031c:	42050513          	addi	a0,a0,1056 # ffffffffc0206738 <etext+0x126>
ffffffffc0200320:	db1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200324:	000ac597          	auipc	a1,0xac
ffffffffc0200328:	61358593          	addi	a1,a1,1555 # ffffffffc02ac937 <end+0x3ff>
ffffffffc020032c:	00000797          	auipc	a5,0x0
ffffffffc0200330:	d0a78793          	addi	a5,a5,-758 # ffffffffc0200036 <kern_init>
ffffffffc0200334:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200338:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020033c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020033e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200342:	95be                	add	a1,a1,a5
ffffffffc0200344:	85a9                	srai	a1,a1,0xa
ffffffffc0200346:	00006517          	auipc	a0,0x6
ffffffffc020034a:	41250513          	addi	a0,a0,1042 # ffffffffc0206758 <etext+0x146>
}
ffffffffc020034e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200350:	d81ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200354 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200354:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200356:	00006617          	auipc	a2,0x6
ffffffffc020035a:	33260613          	addi	a2,a2,818 # ffffffffc0206688 <etext+0x76>
ffffffffc020035e:	04d00593          	li	a1,77
ffffffffc0200362:	00006517          	auipc	a0,0x6
ffffffffc0200366:	33e50513          	addi	a0,a0,830 # ffffffffc02066a0 <etext+0x8e>
void print_stackframe(void) {
ffffffffc020036a:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020036c:	eabff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200370 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200370:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200372:	00006617          	auipc	a2,0x6
ffffffffc0200376:	4f660613          	addi	a2,a2,1270 # ffffffffc0206868 <commands+0xe0>
ffffffffc020037a:	00006597          	auipc	a1,0x6
ffffffffc020037e:	50e58593          	addi	a1,a1,1294 # ffffffffc0206888 <commands+0x100>
ffffffffc0200382:	00006517          	auipc	a0,0x6
ffffffffc0200386:	50e50513          	addi	a0,a0,1294 # ffffffffc0206890 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020038a:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020038c:	d45ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0200390:	00006617          	auipc	a2,0x6
ffffffffc0200394:	51060613          	addi	a2,a2,1296 # ffffffffc02068a0 <commands+0x118>
ffffffffc0200398:	00006597          	auipc	a1,0x6
ffffffffc020039c:	53058593          	addi	a1,a1,1328 # ffffffffc02068c8 <commands+0x140>
ffffffffc02003a0:	00006517          	auipc	a0,0x6
ffffffffc02003a4:	4f050513          	addi	a0,a0,1264 # ffffffffc0206890 <commands+0x108>
ffffffffc02003a8:	d29ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02003ac:	00006617          	auipc	a2,0x6
ffffffffc02003b0:	52c60613          	addi	a2,a2,1324 # ffffffffc02068d8 <commands+0x150>
ffffffffc02003b4:	00006597          	auipc	a1,0x6
ffffffffc02003b8:	54458593          	addi	a1,a1,1348 # ffffffffc02068f8 <commands+0x170>
ffffffffc02003bc:	00006517          	auipc	a0,0x6
ffffffffc02003c0:	4d450513          	addi	a0,a0,1236 # ffffffffc0206890 <commands+0x108>
ffffffffc02003c4:	d0dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    }
    return 0;
}
ffffffffc02003c8:	60a2                	ld	ra,8(sp)
ffffffffc02003ca:	4501                	li	a0,0
ffffffffc02003cc:	0141                	addi	sp,sp,16
ffffffffc02003ce:	8082                	ret

ffffffffc02003d0 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003d0:	1141                	addi	sp,sp,-16
ffffffffc02003d2:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003d4:	ef1ff0ef          	jal	ra,ffffffffc02002c4 <print_kerninfo>
    return 0;
}
ffffffffc02003d8:	60a2                	ld	ra,8(sp)
ffffffffc02003da:	4501                	li	a0,0
ffffffffc02003dc:	0141                	addi	sp,sp,16
ffffffffc02003de:	8082                	ret

ffffffffc02003e0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003e0:	1141                	addi	sp,sp,-16
ffffffffc02003e2:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003e4:	f71ff0ef          	jal	ra,ffffffffc0200354 <print_stackframe>
    return 0;
}
ffffffffc02003e8:	60a2                	ld	ra,8(sp)
ffffffffc02003ea:	4501                	li	a0,0
ffffffffc02003ec:	0141                	addi	sp,sp,16
ffffffffc02003ee:	8082                	ret

ffffffffc02003f0 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003f0:	7115                	addi	sp,sp,-224
ffffffffc02003f2:	e962                	sd	s8,144(sp)
ffffffffc02003f4:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003f6:	00006517          	auipc	a0,0x6
ffffffffc02003fa:	3da50513          	addi	a0,a0,986 # ffffffffc02067d0 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02003fe:	ed86                	sd	ra,216(sp)
ffffffffc0200400:	e9a2                	sd	s0,208(sp)
ffffffffc0200402:	e5a6                	sd	s1,200(sp)
ffffffffc0200404:	e1ca                	sd	s2,192(sp)
ffffffffc0200406:	fd4e                	sd	s3,184(sp)
ffffffffc0200408:	f952                	sd	s4,176(sp)
ffffffffc020040a:	f556                	sd	s5,168(sp)
ffffffffc020040c:	f15a                	sd	s6,160(sp)
ffffffffc020040e:	ed5e                	sd	s7,152(sp)
ffffffffc0200410:	e566                	sd	s9,136(sp)
ffffffffc0200412:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200414:	cbdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200418:	00006517          	auipc	a0,0x6
ffffffffc020041c:	3e050513          	addi	a0,a0,992 # ffffffffc02067f8 <commands+0x70>
ffffffffc0200420:	cb1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (tf != NULL) {
ffffffffc0200424:	000c0563          	beqz	s8,ffffffffc020042e <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200428:	8562                	mv	a0,s8
ffffffffc020042a:	420000ef          	jal	ra,ffffffffc020084a <print_trapframe>
ffffffffc020042e:	00006c97          	auipc	s9,0x6
ffffffffc0200432:	35ac8c93          	addi	s9,s9,858 # ffffffffc0206788 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200436:	00006997          	auipc	s3,0x6
ffffffffc020043a:	3ea98993          	addi	s3,s3,1002 # ffffffffc0206820 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020043e:	00006917          	auipc	s2,0x6
ffffffffc0200442:	3ea90913          	addi	s2,s2,1002 # ffffffffc0206828 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200446:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200448:	00006b17          	auipc	s6,0x6
ffffffffc020044c:	3e8b0b13          	addi	s6,s6,1000 # ffffffffc0206830 <commands+0xa8>
    if (argc == 0) {
ffffffffc0200450:	00006a97          	auipc	s5,0x6
ffffffffc0200454:	438a8a93          	addi	s5,s5,1080 # ffffffffc0206888 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200458:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020045a:	854e                	mv	a0,s3
ffffffffc020045c:	cfdff0ef          	jal	ra,ffffffffc0200158 <readline>
ffffffffc0200460:	842a                	mv	s0,a0
ffffffffc0200462:	dd65                	beqz	a0,ffffffffc020045a <kmonitor+0x6a>
ffffffffc0200464:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200468:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020046a:	c999                	beqz	a1,ffffffffc0200480 <kmonitor+0x90>
ffffffffc020046c:	854a                	mv	a0,s2
ffffffffc020046e:	54d050ef          	jal	ra,ffffffffc02061ba <strchr>
ffffffffc0200472:	c925                	beqz	a0,ffffffffc02004e2 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc0200474:	00144583          	lbu	a1,1(s0)
ffffffffc0200478:	00040023          	sb	zero,0(s0)
ffffffffc020047c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020047e:	f5fd                	bnez	a1,ffffffffc020046c <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200480:	dce9                	beqz	s1,ffffffffc020045a <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200482:	6582                	ld	a1,0(sp)
ffffffffc0200484:	00006d17          	auipc	s10,0x6
ffffffffc0200488:	304d0d13          	addi	s10,s10,772 # ffffffffc0206788 <commands>
    if (argc == 0) {
ffffffffc020048c:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020048e:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200490:	0d61                	addi	s10,s10,24
ffffffffc0200492:	4ff050ef          	jal	ra,ffffffffc0206190 <strcmp>
ffffffffc0200496:	c919                	beqz	a0,ffffffffc02004ac <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200498:	2405                	addiw	s0,s0,1
ffffffffc020049a:	09740463          	beq	s0,s7,ffffffffc0200522 <kmonitor+0x132>
ffffffffc020049e:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02004a2:	6582                	ld	a1,0(sp)
ffffffffc02004a4:	0d61                	addi	s10,s10,24
ffffffffc02004a6:	4eb050ef          	jal	ra,ffffffffc0206190 <strcmp>
ffffffffc02004aa:	f57d                	bnez	a0,ffffffffc0200498 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02004ac:	00141793          	slli	a5,s0,0x1
ffffffffc02004b0:	97a2                	add	a5,a5,s0
ffffffffc02004b2:	078e                	slli	a5,a5,0x3
ffffffffc02004b4:	97e6                	add	a5,a5,s9
ffffffffc02004b6:	6b9c                	ld	a5,16(a5)
ffffffffc02004b8:	8662                	mv	a2,s8
ffffffffc02004ba:	002c                	addi	a1,sp,8
ffffffffc02004bc:	fff4851b          	addiw	a0,s1,-1
ffffffffc02004c0:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02004c2:	f8055ce3          	bgez	a0,ffffffffc020045a <kmonitor+0x6a>
}
ffffffffc02004c6:	60ee                	ld	ra,216(sp)
ffffffffc02004c8:	644e                	ld	s0,208(sp)
ffffffffc02004ca:	64ae                	ld	s1,200(sp)
ffffffffc02004cc:	690e                	ld	s2,192(sp)
ffffffffc02004ce:	79ea                	ld	s3,184(sp)
ffffffffc02004d0:	7a4a                	ld	s4,176(sp)
ffffffffc02004d2:	7aaa                	ld	s5,168(sp)
ffffffffc02004d4:	7b0a                	ld	s6,160(sp)
ffffffffc02004d6:	6bea                	ld	s7,152(sp)
ffffffffc02004d8:	6c4a                	ld	s8,144(sp)
ffffffffc02004da:	6caa                	ld	s9,136(sp)
ffffffffc02004dc:	6d0a                	ld	s10,128(sp)
ffffffffc02004de:	612d                	addi	sp,sp,224
ffffffffc02004e0:	8082                	ret
        if (*buf == '\0') {
ffffffffc02004e2:	00044783          	lbu	a5,0(s0)
ffffffffc02004e6:	dfc9                	beqz	a5,ffffffffc0200480 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02004e8:	03448863          	beq	s1,s4,ffffffffc0200518 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02004ec:	00349793          	slli	a5,s1,0x3
ffffffffc02004f0:	0118                	addi	a4,sp,128
ffffffffc02004f2:	97ba                	add	a5,a5,a4
ffffffffc02004f4:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004f8:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02004fc:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004fe:	e591                	bnez	a1,ffffffffc020050a <kmonitor+0x11a>
ffffffffc0200500:	b749                	j	ffffffffc0200482 <kmonitor+0x92>
            buf ++;
ffffffffc0200502:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200504:	00044583          	lbu	a1,0(s0)
ffffffffc0200508:	ddad                	beqz	a1,ffffffffc0200482 <kmonitor+0x92>
ffffffffc020050a:	854a                	mv	a0,s2
ffffffffc020050c:	4af050ef          	jal	ra,ffffffffc02061ba <strchr>
ffffffffc0200510:	d96d                	beqz	a0,ffffffffc0200502 <kmonitor+0x112>
ffffffffc0200512:	00044583          	lbu	a1,0(s0)
ffffffffc0200516:	bf91                	j	ffffffffc020046a <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200518:	45c1                	li	a1,16
ffffffffc020051a:	855a                	mv	a0,s6
ffffffffc020051c:	bb5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0200520:	b7f1                	j	ffffffffc02004ec <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200522:	6582                	ld	a1,0(sp)
ffffffffc0200524:	00006517          	auipc	a0,0x6
ffffffffc0200528:	32c50513          	addi	a0,a0,812 # ffffffffc0206850 <commands+0xc8>
ffffffffc020052c:	ba5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
ffffffffc0200530:	b72d                	j	ffffffffc020045a <kmonitor+0x6a>

ffffffffc0200532 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200532:	8082                	ret

ffffffffc0200534 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200534:	00253513          	sltiu	a0,a0,2
ffffffffc0200538:	8082                	ret

ffffffffc020053a <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020053a:	03800513          	li	a0,56
ffffffffc020053e:	8082                	ret

ffffffffc0200540 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200540:	000a1797          	auipc	a5,0xa1
ffffffffc0200544:	e6878793          	addi	a5,a5,-408 # ffffffffc02a13a8 <ide>
ffffffffc0200548:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc020054c:	1141                	addi	sp,sp,-16
ffffffffc020054e:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200550:	95be                	add	a1,a1,a5
ffffffffc0200552:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200556:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200558:	493050ef          	jal	ra,ffffffffc02061ea <memcpy>
    return 0;
}
ffffffffc020055c:	60a2                	ld	ra,8(sp)
ffffffffc020055e:	4501                	li	a0,0
ffffffffc0200560:	0141                	addi	sp,sp,16
ffffffffc0200562:	8082                	ret

ffffffffc0200564 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200564:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200566:	0095979b          	slliw	a5,a1,0x9
ffffffffc020056a:	000a1517          	auipc	a0,0xa1
ffffffffc020056e:	e3e50513          	addi	a0,a0,-450 # ffffffffc02a13a8 <ide>
                   size_t nsecs) {
ffffffffc0200572:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200574:	00969613          	slli	a2,a3,0x9
ffffffffc0200578:	85ba                	mv	a1,a4
ffffffffc020057a:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020057c:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020057e:	46d050ef          	jal	ra,ffffffffc02061ea <memcpy>
    return 0;
}
ffffffffc0200582:	60a2                	ld	ra,8(sp)
ffffffffc0200584:	4501                	li	a0,0
ffffffffc0200586:	0141                	addi	sp,sp,16
ffffffffc0200588:	8082                	ret

ffffffffc020058a <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020058a:	67e1                	lui	a5,0x18
ffffffffc020058c:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdc30>
ffffffffc0200590:	000ac717          	auipc	a4,0xac
ffffffffc0200594:	e2f73023          	sd	a5,-480(a4) # ffffffffc02ac3b0 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200598:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020059c:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020059e:	953e                	add	a0,a0,a5
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4881                	li	a7,0
ffffffffc02005a4:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02005a8:	02000793          	li	a5,32
ffffffffc02005ac:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02005b0:	00006517          	auipc	a0,0x6
ffffffffc02005b4:	35850513          	addi	a0,a0,856 # ffffffffc0206908 <commands+0x180>
    ticks = 0;
ffffffffc02005b8:	000ac797          	auipc	a5,0xac
ffffffffc02005bc:	e407b823          	sd	zero,-432(a5) # ffffffffc02ac408 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02005c0:	b11ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02005c4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02005c4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02005c8:	000ac797          	auipc	a5,0xac
ffffffffc02005cc:	de878793          	addi	a5,a5,-536 # ffffffffc02ac3b0 <timebase>
ffffffffc02005d0:	639c                	ld	a5,0(a5)
ffffffffc02005d2:	4581                	li	a1,0
ffffffffc02005d4:	4601                	li	a2,0
ffffffffc02005d6:	953e                	add	a0,a0,a5
ffffffffc02005d8:	4881                	li	a7,0
ffffffffc02005da:	00000073          	ecall
ffffffffc02005de:	8082                	ret

ffffffffc02005e0 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005e0:	8082                	ret

ffffffffc02005e2 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005e2:	100027f3          	csrr	a5,sstatus
ffffffffc02005e6:	8b89                	andi	a5,a5,2
ffffffffc02005e8:	0ff57513          	andi	a0,a0,255
ffffffffc02005ec:	e799                	bnez	a5,ffffffffc02005fa <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005ee:	4581                	li	a1,0
ffffffffc02005f0:	4601                	li	a2,0
ffffffffc02005f2:	4885                	li	a7,1
ffffffffc02005f4:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005f8:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005fa:	1101                	addi	sp,sp,-32
ffffffffc02005fc:	ec06                	sd	ra,24(sp)
ffffffffc02005fe:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200600:	05c000ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0200604:	6522                	ld	a0,8(sp)
ffffffffc0200606:	4581                	li	a1,0
ffffffffc0200608:	4601                	li	a2,0
ffffffffc020060a:	4885                	li	a7,1
ffffffffc020060c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200610:	60e2                	ld	ra,24(sp)
ffffffffc0200612:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200614:	0420006f          	j	ffffffffc0200656 <intr_enable>

ffffffffc0200618 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200618:	100027f3          	csrr	a5,sstatus
ffffffffc020061c:	8b89                	andi	a5,a5,2
ffffffffc020061e:	eb89                	bnez	a5,ffffffffc0200630 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200620:	4501                	li	a0,0
ffffffffc0200622:	4581                	li	a1,0
ffffffffc0200624:	4601                	li	a2,0
ffffffffc0200626:	4889                	li	a7,2
ffffffffc0200628:	00000073          	ecall
ffffffffc020062c:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020062e:	8082                	ret
int cons_getc(void) {
ffffffffc0200630:	1101                	addi	sp,sp,-32
ffffffffc0200632:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200634:	028000ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0200638:	4501                	li	a0,0
ffffffffc020063a:	4581                	li	a1,0
ffffffffc020063c:	4601                	li	a2,0
ffffffffc020063e:	4889                	li	a7,2
ffffffffc0200640:	00000073          	ecall
ffffffffc0200644:	2501                	sext.w	a0,a0
ffffffffc0200646:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200648:	00e000ef          	jal	ra,ffffffffc0200656 <intr_enable>
}
ffffffffc020064c:	60e2                	ld	ra,24(sp)
ffffffffc020064e:	6522                	ld	a0,8(sp)
ffffffffc0200650:	6105                	addi	sp,sp,32
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200654:	8082                	ret

ffffffffc0200656 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200656:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020065a:	8082                	ret

ffffffffc020065c <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020065c:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200660:	8082                	ret

ffffffffc0200662 <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200662:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200666:	00000797          	auipc	a5,0x0
ffffffffc020066a:	67a78793          	addi	a5,a5,1658 # ffffffffc0200ce0 <__alltraps>
ffffffffc020066e:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200672:	000407b7          	lui	a5,0x40
ffffffffc0200676:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020067a:	8082                	ret

ffffffffc020067c <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020067e:	1141                	addi	sp,sp,-16
ffffffffc0200680:	e022                	sd	s0,0(sp)
ffffffffc0200682:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200684:	00006517          	auipc	a0,0x6
ffffffffc0200688:	5cc50513          	addi	a0,a0,1484 # ffffffffc0206c50 <commands+0x4c8>
void print_regs(struct pushregs* gpr) {
ffffffffc020068c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020068e:	a43ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200692:	640c                	ld	a1,8(s0)
ffffffffc0200694:	00006517          	auipc	a0,0x6
ffffffffc0200698:	5d450513          	addi	a0,a0,1492 # ffffffffc0206c68 <commands+0x4e0>
ffffffffc020069c:	a35ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02006a0:	680c                	ld	a1,16(s0)
ffffffffc02006a2:	00006517          	auipc	a0,0x6
ffffffffc02006a6:	5de50513          	addi	a0,a0,1502 # ffffffffc0206c80 <commands+0x4f8>
ffffffffc02006aa:	a27ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006ae:	6c0c                	ld	a1,24(s0)
ffffffffc02006b0:	00006517          	auipc	a0,0x6
ffffffffc02006b4:	5e850513          	addi	a0,a0,1512 # ffffffffc0206c98 <commands+0x510>
ffffffffc02006b8:	a19ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006bc:	700c                	ld	a1,32(s0)
ffffffffc02006be:	00006517          	auipc	a0,0x6
ffffffffc02006c2:	5f250513          	addi	a0,a0,1522 # ffffffffc0206cb0 <commands+0x528>
ffffffffc02006c6:	a0bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ca:	740c                	ld	a1,40(s0)
ffffffffc02006cc:	00006517          	auipc	a0,0x6
ffffffffc02006d0:	5fc50513          	addi	a0,a0,1532 # ffffffffc0206cc8 <commands+0x540>
ffffffffc02006d4:	9fdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d8:	780c                	ld	a1,48(s0)
ffffffffc02006da:	00006517          	auipc	a0,0x6
ffffffffc02006de:	60650513          	addi	a0,a0,1542 # ffffffffc0206ce0 <commands+0x558>
ffffffffc02006e2:	9efff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006e6:	7c0c                	ld	a1,56(s0)
ffffffffc02006e8:	00006517          	auipc	a0,0x6
ffffffffc02006ec:	61050513          	addi	a0,a0,1552 # ffffffffc0206cf8 <commands+0x570>
ffffffffc02006f0:	9e1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006f4:	602c                	ld	a1,64(s0)
ffffffffc02006f6:	00006517          	auipc	a0,0x6
ffffffffc02006fa:	61a50513          	addi	a0,a0,1562 # ffffffffc0206d10 <commands+0x588>
ffffffffc02006fe:	9d3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200702:	642c                	ld	a1,72(s0)
ffffffffc0200704:	00006517          	auipc	a0,0x6
ffffffffc0200708:	62450513          	addi	a0,a0,1572 # ffffffffc0206d28 <commands+0x5a0>
ffffffffc020070c:	9c5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200710:	682c                	ld	a1,80(s0)
ffffffffc0200712:	00006517          	auipc	a0,0x6
ffffffffc0200716:	62e50513          	addi	a0,a0,1582 # ffffffffc0206d40 <commands+0x5b8>
ffffffffc020071a:	9b7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020071e:	6c2c                	ld	a1,88(s0)
ffffffffc0200720:	00006517          	auipc	a0,0x6
ffffffffc0200724:	63850513          	addi	a0,a0,1592 # ffffffffc0206d58 <commands+0x5d0>
ffffffffc0200728:	9a9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020072c:	702c                	ld	a1,96(s0)
ffffffffc020072e:	00006517          	auipc	a0,0x6
ffffffffc0200732:	64250513          	addi	a0,a0,1602 # ffffffffc0206d70 <commands+0x5e8>
ffffffffc0200736:	99bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020073a:	742c                	ld	a1,104(s0)
ffffffffc020073c:	00006517          	auipc	a0,0x6
ffffffffc0200740:	64c50513          	addi	a0,a0,1612 # ffffffffc0206d88 <commands+0x600>
ffffffffc0200744:	98dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200748:	782c                	ld	a1,112(s0)
ffffffffc020074a:	00006517          	auipc	a0,0x6
ffffffffc020074e:	65650513          	addi	a0,a0,1622 # ffffffffc0206da0 <commands+0x618>
ffffffffc0200752:	97fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200756:	7c2c                	ld	a1,120(s0)
ffffffffc0200758:	00006517          	auipc	a0,0x6
ffffffffc020075c:	66050513          	addi	a0,a0,1632 # ffffffffc0206db8 <commands+0x630>
ffffffffc0200760:	971ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200764:	604c                	ld	a1,128(s0)
ffffffffc0200766:	00006517          	auipc	a0,0x6
ffffffffc020076a:	66a50513          	addi	a0,a0,1642 # ffffffffc0206dd0 <commands+0x648>
ffffffffc020076e:	963ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200772:	644c                	ld	a1,136(s0)
ffffffffc0200774:	00006517          	auipc	a0,0x6
ffffffffc0200778:	67450513          	addi	a0,a0,1652 # ffffffffc0206de8 <commands+0x660>
ffffffffc020077c:	955ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200780:	684c                	ld	a1,144(s0)
ffffffffc0200782:	00006517          	auipc	a0,0x6
ffffffffc0200786:	67e50513          	addi	a0,a0,1662 # ffffffffc0206e00 <commands+0x678>
ffffffffc020078a:	947ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020078e:	6c4c                	ld	a1,152(s0)
ffffffffc0200790:	00006517          	auipc	a0,0x6
ffffffffc0200794:	68850513          	addi	a0,a0,1672 # ffffffffc0206e18 <commands+0x690>
ffffffffc0200798:	939ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020079c:	704c                	ld	a1,160(s0)
ffffffffc020079e:	00006517          	auipc	a0,0x6
ffffffffc02007a2:	69250513          	addi	a0,a0,1682 # ffffffffc0206e30 <commands+0x6a8>
ffffffffc02007a6:	92bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007aa:	744c                	ld	a1,168(s0)
ffffffffc02007ac:	00006517          	auipc	a0,0x6
ffffffffc02007b0:	69c50513          	addi	a0,a0,1692 # ffffffffc0206e48 <commands+0x6c0>
ffffffffc02007b4:	91dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b8:	784c                	ld	a1,176(s0)
ffffffffc02007ba:	00006517          	auipc	a0,0x6
ffffffffc02007be:	6a650513          	addi	a0,a0,1702 # ffffffffc0206e60 <commands+0x6d8>
ffffffffc02007c2:	90fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007c6:	7c4c                	ld	a1,184(s0)
ffffffffc02007c8:	00006517          	auipc	a0,0x6
ffffffffc02007cc:	6b050513          	addi	a0,a0,1712 # ffffffffc0206e78 <commands+0x6f0>
ffffffffc02007d0:	901ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007d4:	606c                	ld	a1,192(s0)
ffffffffc02007d6:	00006517          	auipc	a0,0x6
ffffffffc02007da:	6ba50513          	addi	a0,a0,1722 # ffffffffc0206e90 <commands+0x708>
ffffffffc02007de:	8f3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007e2:	646c                	ld	a1,200(s0)
ffffffffc02007e4:	00006517          	auipc	a0,0x6
ffffffffc02007e8:	6c450513          	addi	a0,a0,1732 # ffffffffc0206ea8 <commands+0x720>
ffffffffc02007ec:	8e5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007f0:	686c                	ld	a1,208(s0)
ffffffffc02007f2:	00006517          	auipc	a0,0x6
ffffffffc02007f6:	6ce50513          	addi	a0,a0,1742 # ffffffffc0206ec0 <commands+0x738>
ffffffffc02007fa:	8d7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200800:	00006517          	auipc	a0,0x6
ffffffffc0200804:	6d850513          	addi	a0,a0,1752 # ffffffffc0206ed8 <commands+0x750>
ffffffffc0200808:	8c9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020080c:	706c                	ld	a1,224(s0)
ffffffffc020080e:	00006517          	auipc	a0,0x6
ffffffffc0200812:	6e250513          	addi	a0,a0,1762 # ffffffffc0206ef0 <commands+0x768>
ffffffffc0200816:	8bbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020081a:	746c                	ld	a1,232(s0)
ffffffffc020081c:	00006517          	auipc	a0,0x6
ffffffffc0200820:	6ec50513          	addi	a0,a0,1772 # ffffffffc0206f08 <commands+0x780>
ffffffffc0200824:	8adff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200828:	786c                	ld	a1,240(s0)
ffffffffc020082a:	00006517          	auipc	a0,0x6
ffffffffc020082e:	6f650513          	addi	a0,a0,1782 # ffffffffc0206f20 <commands+0x798>
ffffffffc0200832:	89fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200838:	6402                	ld	s0,0(sp)
ffffffffc020083a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	6fc50513          	addi	a0,a0,1788 # ffffffffc0206f38 <commands+0x7b0>
}
ffffffffc0200844:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200846:	88bff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc020084a <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc020084a:	1141                	addi	sp,sp,-16
ffffffffc020084c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020084e:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200850:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200852:	00006517          	auipc	a0,0x6
ffffffffc0200856:	6fe50513          	addi	a0,a0,1790 # ffffffffc0206f50 <commands+0x7c8>
print_trapframe(struct trapframe *tf) {
ffffffffc020085a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020085c:	875ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200860:	8522                	mv	a0,s0
ffffffffc0200862:	e1bff0ef          	jal	ra,ffffffffc020067c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200866:	10043583          	ld	a1,256(s0)
ffffffffc020086a:	00006517          	auipc	a0,0x6
ffffffffc020086e:	6fe50513          	addi	a0,a0,1790 # ffffffffc0206f68 <commands+0x7e0>
ffffffffc0200872:	85fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200876:	10843583          	ld	a1,264(s0)
ffffffffc020087a:	00006517          	auipc	a0,0x6
ffffffffc020087e:	70650513          	addi	a0,a0,1798 # ffffffffc0206f80 <commands+0x7f8>
ffffffffc0200882:	84fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200886:	11043583          	ld	a1,272(s0)
ffffffffc020088a:	00006517          	auipc	a0,0x6
ffffffffc020088e:	70e50513          	addi	a0,a0,1806 # ffffffffc0206f98 <commands+0x810>
ffffffffc0200892:	83fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	11843583          	ld	a1,280(s0)
}
ffffffffc020089a:	6402                	ld	s0,0(sp)
ffffffffc020089c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020089e:	00006517          	auipc	a0,0x6
ffffffffc02008a2:	70a50513          	addi	a0,a0,1802 # ffffffffc0206fa8 <commands+0x820>
}
ffffffffc02008a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02008a8:	829ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02008ac <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ac:	1101                	addi	sp,sp,-32
ffffffffc02008ae:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b0:	000ac497          	auipc	s1,0xac
ffffffffc02008b4:	b6048493          	addi	s1,s1,-1184 # ffffffffc02ac410 <check_mm_struct>
ffffffffc02008b8:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ba:	e822                	sd	s0,16(sp)
ffffffffc02008bc:	ec06                	sd	ra,24(sp)
ffffffffc02008be:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008c0:	cbbd                	beqz	a5,ffffffffc0200936 <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c2:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008c6:	11053583          	ld	a1,272(a0)
ffffffffc02008ca:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ce:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008d2:	cba1                	beqz	a5,ffffffffc0200922 <pgfault_handler+0x76>
ffffffffc02008d4:	11843703          	ld	a4,280(s0)
ffffffffc02008d8:	47bd                	li	a5,15
ffffffffc02008da:	05700693          	li	a3,87
ffffffffc02008de:	00f70463          	beq	a4,a5,ffffffffc02008e6 <pgfault_handler+0x3a>
ffffffffc02008e2:	05200693          	li	a3,82
ffffffffc02008e6:	00006517          	auipc	a0,0x6
ffffffffc02008ea:	2ea50513          	addi	a0,a0,746 # ffffffffc0206bd0 <commands+0x448>
ffffffffc02008ee:	fe2ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008f2:	6088                	ld	a0,0(s1)
ffffffffc02008f4:	c129                	beqz	a0,ffffffffc0200936 <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008f6:	000ac797          	auipc	a5,0xac
ffffffffc02008fa:	af278793          	addi	a5,a5,-1294 # ffffffffc02ac3e8 <current>
ffffffffc02008fe:	6398                	ld	a4,0(a5)
ffffffffc0200900:	000ac797          	auipc	a5,0xac
ffffffffc0200904:	af078793          	addi	a5,a5,-1296 # ffffffffc02ac3f0 <idleproc>
ffffffffc0200908:	639c                	ld	a5,0(a5)
ffffffffc020090a:	04f71763          	bne	a4,a5,ffffffffc0200958 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020090e:	11043603          	ld	a2,272(s0)
ffffffffc0200912:	11843583          	ld	a1,280(s0)
}
ffffffffc0200916:	6442                	ld	s0,16(sp)
ffffffffc0200918:	60e2                	ld	ra,24(sp)
ffffffffc020091a:	64a2                	ld	s1,8(sp)
ffffffffc020091c:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020091e:	63f0006f          	j	ffffffffc020175c <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200922:	11843703          	ld	a4,280(s0)
ffffffffc0200926:	47bd                	li	a5,15
ffffffffc0200928:	05500613          	li	a2,85
ffffffffc020092c:	05700693          	li	a3,87
ffffffffc0200930:	faf719e3          	bne	a4,a5,ffffffffc02008e2 <pgfault_handler+0x36>
ffffffffc0200934:	bf4d                	j	ffffffffc02008e6 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc0200936:	000ac797          	auipc	a5,0xac
ffffffffc020093a:	ab278793          	addi	a5,a5,-1358 # ffffffffc02ac3e8 <current>
ffffffffc020093e:	639c                	ld	a5,0(a5)
ffffffffc0200940:	cf85                	beqz	a5,ffffffffc0200978 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200942:	11043603          	ld	a2,272(s0)
ffffffffc0200946:	11843583          	ld	a1,280(s0)
}
ffffffffc020094a:	6442                	ld	s0,16(sp)
ffffffffc020094c:	60e2                	ld	ra,24(sp)
ffffffffc020094e:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200950:	7788                	ld	a0,40(a5)
}
ffffffffc0200952:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200954:	6090006f          	j	ffffffffc020175c <do_pgfault>
        assert(current == idleproc);
ffffffffc0200958:	00006697          	auipc	a3,0x6
ffffffffc020095c:	29868693          	addi	a3,a3,664 # ffffffffc0206bf0 <commands+0x468>
ffffffffc0200960:	00006617          	auipc	a2,0x6
ffffffffc0200964:	2a860613          	addi	a2,a2,680 # ffffffffc0206c08 <commands+0x480>
ffffffffc0200968:	06b00593          	li	a1,107
ffffffffc020096c:	00006517          	auipc	a0,0x6
ffffffffc0200970:	2b450513          	addi	a0,a0,692 # ffffffffc0206c20 <commands+0x498>
ffffffffc0200974:	8a3ff0ef          	jal	ra,ffffffffc0200216 <__panic>
            print_trapframe(tf);
ffffffffc0200978:	8522                	mv	a0,s0
ffffffffc020097a:	ed1ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020097e:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200982:	11043583          	ld	a1,272(s0)
ffffffffc0200986:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020098a:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020098e:	e399                	bnez	a5,ffffffffc0200994 <pgfault_handler+0xe8>
ffffffffc0200990:	05500613          	li	a2,85
ffffffffc0200994:	11843703          	ld	a4,280(s0)
ffffffffc0200998:	47bd                	li	a5,15
ffffffffc020099a:	02f70663          	beq	a4,a5,ffffffffc02009c6 <pgfault_handler+0x11a>
ffffffffc020099e:	05200693          	li	a3,82
ffffffffc02009a2:	00006517          	auipc	a0,0x6
ffffffffc02009a6:	22e50513          	addi	a0,a0,558 # ffffffffc0206bd0 <commands+0x448>
ffffffffc02009aa:	f26ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009ae:	00006617          	auipc	a2,0x6
ffffffffc02009b2:	28a60613          	addi	a2,a2,650 # ffffffffc0206c38 <commands+0x4b0>
ffffffffc02009b6:	07200593          	li	a1,114
ffffffffc02009ba:	00006517          	auipc	a0,0x6
ffffffffc02009be:	26650513          	addi	a0,a0,614 # ffffffffc0206c20 <commands+0x498>
ffffffffc02009c2:	855ff0ef          	jal	ra,ffffffffc0200216 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009c6:	05700693          	li	a3,87
ffffffffc02009ca:	bfe1                	j	ffffffffc02009a2 <pgfault_handler+0xf6>

ffffffffc02009cc <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009cc:	11853783          	ld	a5,280(a0)
ffffffffc02009d0:	577d                	li	a4,-1
ffffffffc02009d2:	8305                	srli	a4,a4,0x1
ffffffffc02009d4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02009d6:	472d                	li	a4,11
ffffffffc02009d8:	08f76763          	bltu	a4,a5,ffffffffc0200a66 <interrupt_handler+0x9a>
ffffffffc02009dc:	00006717          	auipc	a4,0x6
ffffffffc02009e0:	f4870713          	addi	a4,a4,-184 # ffffffffc0206924 <commands+0x19c>
ffffffffc02009e4:	078a                	slli	a5,a5,0x2
ffffffffc02009e6:	97ba                	add	a5,a5,a4
ffffffffc02009e8:	439c                	lw	a5,0(a5)
ffffffffc02009ea:	97ba                	add	a5,a5,a4
ffffffffc02009ec:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	1a250513          	addi	a0,a0,418 # ffffffffc0206b90 <commands+0x408>
ffffffffc02009f6:	edaff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009fa:	00006517          	auipc	a0,0x6
ffffffffc02009fe:	17650513          	addi	a0,a0,374 # ffffffffc0206b70 <commands+0x3e8>
ffffffffc0200a02:	eceff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200a06:	00006517          	auipc	a0,0x6
ffffffffc0200a0a:	12a50513          	addi	a0,a0,298 # ffffffffc0206b30 <commands+0x3a8>
ffffffffc0200a0e:	ec2ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a12:	00006517          	auipc	a0,0x6
ffffffffc0200a16:	13e50513          	addi	a0,a0,318 # ffffffffc0206b50 <commands+0x3c8>
ffffffffc0200a1a:	eb6ff06f          	j	ffffffffc02000d0 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a1e:	00006517          	auipc	a0,0x6
ffffffffc0200a22:	19250513          	addi	a0,a0,402 # ffffffffc0206bb0 <commands+0x428>
ffffffffc0200a26:	eaaff06f          	j	ffffffffc02000d0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a2a:	1141                	addi	sp,sp,-16
ffffffffc0200a2c:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a2e:	b97ff0ef          	jal	ra,ffffffffc02005c4 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a32:	000ac797          	auipc	a5,0xac
ffffffffc0200a36:	9d678793          	addi	a5,a5,-1578 # ffffffffc02ac408 <ticks>
ffffffffc0200a3a:	639c                	ld	a5,0(a5)
ffffffffc0200a3c:	06400713          	li	a4,100
ffffffffc0200a40:	0785                	addi	a5,a5,1
ffffffffc0200a42:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a46:	000ac697          	auipc	a3,0xac
ffffffffc0200a4a:	9cf6b123          	sd	a5,-1598(a3) # ffffffffc02ac408 <ticks>
ffffffffc0200a4e:	eb09                	bnez	a4,ffffffffc0200a60 <interrupt_handler+0x94>
ffffffffc0200a50:	000ac797          	auipc	a5,0xac
ffffffffc0200a54:	99878793          	addi	a5,a5,-1640 # ffffffffc02ac3e8 <current>
ffffffffc0200a58:	639c                	ld	a5,0(a5)
ffffffffc0200a5a:	c399                	beqz	a5,ffffffffc0200a60 <interrupt_handler+0x94>
                current->need_resched = 1;
ffffffffc0200a5c:	4705                	li	a4,1
ffffffffc0200a5e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a60:	60a2                	ld	ra,8(sp)
ffffffffc0200a62:	0141                	addi	sp,sp,16
ffffffffc0200a64:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a66:	de5ff06f          	j	ffffffffc020084a <print_trapframe>

ffffffffc0200a6a <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a6a:	11853783          	ld	a5,280(a0)
ffffffffc0200a6e:	473d                	li	a4,15
ffffffffc0200a70:	1af76e63          	bltu	a4,a5,ffffffffc0200c2c <exception_handler+0x1c2>
ffffffffc0200a74:	00006717          	auipc	a4,0x6
ffffffffc0200a78:	ee070713          	addi	a4,a4,-288 # ffffffffc0206954 <commands+0x1cc>
ffffffffc0200a7c:	078a                	slli	a5,a5,0x2
ffffffffc0200a7e:	97ba                	add	a5,a5,a4
ffffffffc0200a80:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a82:	1101                	addi	sp,sp,-32
ffffffffc0200a84:	e822                	sd	s0,16(sp)
ffffffffc0200a86:	ec06                	sd	ra,24(sp)
ffffffffc0200a88:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a8a:	97ba                	add	a5,a5,a4
ffffffffc0200a8c:	842a                	mv	s0,a0
ffffffffc0200a8e:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a90:	00006517          	auipc	a0,0x6
ffffffffc0200a94:	ff850513          	addi	a0,a0,-8 # ffffffffc0206a88 <commands+0x300>
ffffffffc0200a98:	e38ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            tf->epc += 4;
ffffffffc0200a9c:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200aa0:	60e2                	ld	ra,24(sp)
ffffffffc0200aa2:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200aa4:	0791                	addi	a5,a5,4
ffffffffc0200aa6:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200aaa:	6442                	ld	s0,16(sp)
ffffffffc0200aac:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aae:	60c0506f          	j	ffffffffc02060ba <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	ff650513          	addi	a0,a0,-10 # ffffffffc0206aa8 <commands+0x320>
}
ffffffffc0200aba:	6442                	ld	s0,16(sp)
ffffffffc0200abc:	60e2                	ld	ra,24(sp)
ffffffffc0200abe:	64a2                	ld	s1,8(sp)
ffffffffc0200ac0:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ac2:	e0eff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ac6:	00006517          	auipc	a0,0x6
ffffffffc0200aca:	00250513          	addi	a0,a0,2 # ffffffffc0206ac8 <commands+0x340>
ffffffffc0200ace:	b7f5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ad0:	00006517          	auipc	a0,0x6
ffffffffc0200ad4:	01850513          	addi	a0,a0,24 # ffffffffc0206ae8 <commands+0x360>
ffffffffc0200ad8:	b7cd                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ada:	00006517          	auipc	a0,0x6
ffffffffc0200ade:	02650513          	addi	a0,a0,38 # ffffffffc0206b00 <commands+0x378>
ffffffffc0200ae2:	deeff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae6:	8522                	mv	a0,s0
ffffffffc0200ae8:	dc5ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200aec:	84aa                	mv	s1,a0
ffffffffc0200aee:	14051163          	bnez	a0,ffffffffc0200c30 <exception_handler+0x1c6>
}
ffffffffc0200af2:	60e2                	ld	ra,24(sp)
ffffffffc0200af4:	6442                	ld	s0,16(sp)
ffffffffc0200af6:	64a2                	ld	s1,8(sp)
ffffffffc0200af8:	6105                	addi	sp,sp,32
ffffffffc0200afa:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200afc:	00006517          	auipc	a0,0x6
ffffffffc0200b00:	01c50513          	addi	a0,a0,28 # ffffffffc0206b18 <commands+0x390>
ffffffffc0200b04:	dccff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b08:	8522                	mv	a0,s0
ffffffffc0200b0a:	da3ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200b0e:	84aa                	mv	s1,a0
ffffffffc0200b10:	d16d                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b12:	8522                	mv	a0,s0
ffffffffc0200b14:	d37ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b18:	86a6                	mv	a3,s1
ffffffffc0200b1a:	00006617          	auipc	a2,0x6
ffffffffc0200b1e:	f1e60613          	addi	a2,a2,-226 # ffffffffc0206a38 <commands+0x2b0>
ffffffffc0200b22:	0f800593          	li	a1,248
ffffffffc0200b26:	00006517          	auipc	a0,0x6
ffffffffc0200b2a:	0fa50513          	addi	a0,a0,250 # ffffffffc0206c20 <commands+0x498>
ffffffffc0200b2e:	ee8ff0ef          	jal	ra,ffffffffc0200216 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b32:	00006517          	auipc	a0,0x6
ffffffffc0200b36:	e6650513          	addi	a0,a0,-410 # ffffffffc0206998 <commands+0x210>
ffffffffc0200b3a:	b741                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b3c:	00006517          	auipc	a0,0x6
ffffffffc0200b40:	e7c50513          	addi	a0,a0,-388 # ffffffffc02069b8 <commands+0x230>
ffffffffc0200b44:	bf9d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b46:	00006517          	auipc	a0,0x6
ffffffffc0200b4a:	e9250513          	addi	a0,a0,-366 # ffffffffc02069d8 <commands+0x250>
ffffffffc0200b4e:	b7b5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b50:	00006517          	auipc	a0,0x6
ffffffffc0200b54:	ea050513          	addi	a0,a0,-352 # ffffffffc02069f0 <commands+0x268>
ffffffffc0200b58:	d78ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b5c:	6458                	ld	a4,136(s0)
ffffffffc0200b5e:	47a9                	li	a5,10
ffffffffc0200b60:	f8f719e3          	bne	a4,a5,ffffffffc0200af2 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b64:	10843783          	ld	a5,264(s0)
ffffffffc0200b68:	0791                	addi	a5,a5,4
ffffffffc0200b6a:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b6e:	54c050ef          	jal	ra,ffffffffc02060ba <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b72:	000ac797          	auipc	a5,0xac
ffffffffc0200b76:	87678793          	addi	a5,a5,-1930 # ffffffffc02ac3e8 <current>
ffffffffc0200b7a:	639c                	ld	a5,0(a5)
ffffffffc0200b7c:	8522                	mv	a0,s0
}
ffffffffc0200b7e:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b80:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b82:	60e2                	ld	ra,24(sp)
ffffffffc0200b84:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b86:	6589                	lui	a1,0x2
ffffffffc0200b88:	95be                	add	a1,a1,a5
}
ffffffffc0200b8a:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b8c:	2220006f          	j	ffffffffc0200dae <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b90:	00006517          	auipc	a0,0x6
ffffffffc0200b94:	e7050513          	addi	a0,a0,-400 # ffffffffc0206a00 <commands+0x278>
ffffffffc0200b98:	b70d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b9a:	00006517          	auipc	a0,0x6
ffffffffc0200b9e:	e8650513          	addi	a0,a0,-378 # ffffffffc0206a20 <commands+0x298>
ffffffffc0200ba2:	d2eff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ba6:	8522                	mv	a0,s0
ffffffffc0200ba8:	d05ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200bac:	84aa                	mv	s1,a0
ffffffffc0200bae:	d131                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bb0:	8522                	mv	a0,s0
ffffffffc0200bb2:	c99ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bb6:	86a6                	mv	a3,s1
ffffffffc0200bb8:	00006617          	auipc	a2,0x6
ffffffffc0200bbc:	e8060613          	addi	a2,a2,-384 # ffffffffc0206a38 <commands+0x2b0>
ffffffffc0200bc0:	0cd00593          	li	a1,205
ffffffffc0200bc4:	00006517          	auipc	a0,0x6
ffffffffc0200bc8:	05c50513          	addi	a0,a0,92 # ffffffffc0206c20 <commands+0x498>
ffffffffc0200bcc:	e4aff0ef          	jal	ra,ffffffffc0200216 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bd0:	00006517          	auipc	a0,0x6
ffffffffc0200bd4:	ea050513          	addi	a0,a0,-352 # ffffffffc0206a70 <commands+0x2e8>
ffffffffc0200bd8:	cf8ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bdc:	8522                	mv	a0,s0
ffffffffc0200bde:	ccfff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200be2:	84aa                	mv	s1,a0
ffffffffc0200be4:	f00507e3          	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200be8:	8522                	mv	a0,s0
ffffffffc0200bea:	c61ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bee:	86a6                	mv	a3,s1
ffffffffc0200bf0:	00006617          	auipc	a2,0x6
ffffffffc0200bf4:	e4860613          	addi	a2,a2,-440 # ffffffffc0206a38 <commands+0x2b0>
ffffffffc0200bf8:	0d700593          	li	a1,215
ffffffffc0200bfc:	00006517          	auipc	a0,0x6
ffffffffc0200c00:	02450513          	addi	a0,a0,36 # ffffffffc0206c20 <commands+0x498>
ffffffffc0200c04:	e12ff0ef          	jal	ra,ffffffffc0200216 <__panic>
}
ffffffffc0200c08:	6442                	ld	s0,16(sp)
ffffffffc0200c0a:	60e2                	ld	ra,24(sp)
ffffffffc0200c0c:	64a2                	ld	s1,8(sp)
ffffffffc0200c0e:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c10:	c3bff06f          	j	ffffffffc020084a <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c14:	00006617          	auipc	a2,0x6
ffffffffc0200c18:	e4460613          	addi	a2,a2,-444 # ffffffffc0206a58 <commands+0x2d0>
ffffffffc0200c1c:	0d100593          	li	a1,209
ffffffffc0200c20:	00006517          	auipc	a0,0x6
ffffffffc0200c24:	00050513          	mv	a0,a0
ffffffffc0200c28:	deeff0ef          	jal	ra,ffffffffc0200216 <__panic>
            print_trapframe(tf);
ffffffffc0200c2c:	c1fff06f          	j	ffffffffc020084a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c30:	8522                	mv	a0,s0
ffffffffc0200c32:	c19ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c36:	86a6                	mv	a3,s1
ffffffffc0200c38:	00006617          	auipc	a2,0x6
ffffffffc0200c3c:	e0060613          	addi	a2,a2,-512 # ffffffffc0206a38 <commands+0x2b0>
ffffffffc0200c40:	0f100593          	li	a1,241
ffffffffc0200c44:	00006517          	auipc	a0,0x6
ffffffffc0200c48:	fdc50513          	addi	a0,a0,-36 # ffffffffc0206c20 <commands+0x498>
ffffffffc0200c4c:	dcaff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200c50 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c50:	1101                	addi	sp,sp,-32
ffffffffc0200c52:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c54:	000ab417          	auipc	s0,0xab
ffffffffc0200c58:	79440413          	addi	s0,s0,1940 # ffffffffc02ac3e8 <current>
ffffffffc0200c5c:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c5e:	ec06                	sd	ra,24(sp)
ffffffffc0200c60:	e426                	sd	s1,8(sp)
ffffffffc0200c62:	e04a                	sd	s2,0(sp)
ffffffffc0200c64:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c68:	cf1d                	beqz	a4,ffffffffc0200ca6 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c6a:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c6e:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c72:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c74:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c78:	0206c463          	bltz	a3,ffffffffc0200ca0 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c7c:	defff0ef          	jal	ra,ffffffffc0200a6a <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c80:	601c                	ld	a5,0(s0)
ffffffffc0200c82:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c86:	e499                	bnez	s1,ffffffffc0200c94 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c88:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c8c:	8b05                	andi	a4,a4,1
ffffffffc0200c8e:	e339                	bnez	a4,ffffffffc0200cd4 <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c90:	6f9c                	ld	a5,24(a5)
ffffffffc0200c92:	eb95                	bnez	a5,ffffffffc0200cc6 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200c94:	60e2                	ld	ra,24(sp)
ffffffffc0200c96:	6442                	ld	s0,16(sp)
ffffffffc0200c98:	64a2                	ld	s1,8(sp)
ffffffffc0200c9a:	6902                	ld	s2,0(sp)
ffffffffc0200c9c:	6105                	addi	sp,sp,32
ffffffffc0200c9e:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200ca0:	d2dff0ef          	jal	ra,ffffffffc02009cc <interrupt_handler>
ffffffffc0200ca4:	bff1                	j	ffffffffc0200c80 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200ca6:	0006c963          	bltz	a3,ffffffffc0200cb8 <trap+0x68>
}
ffffffffc0200caa:	6442                	ld	s0,16(sp)
ffffffffc0200cac:	60e2                	ld	ra,24(sp)
ffffffffc0200cae:	64a2                	ld	s1,8(sp)
ffffffffc0200cb0:	6902                	ld	s2,0(sp)
ffffffffc0200cb2:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200cb4:	db7ff06f          	j	ffffffffc0200a6a <exception_handler>
}
ffffffffc0200cb8:	6442                	ld	s0,16(sp)
ffffffffc0200cba:	60e2                	ld	ra,24(sp)
ffffffffc0200cbc:	64a2                	ld	s1,8(sp)
ffffffffc0200cbe:	6902                	ld	s2,0(sp)
ffffffffc0200cc0:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cc2:	d0bff06f          	j	ffffffffc02009cc <interrupt_handler>
}
ffffffffc0200cc6:	6442                	ld	s0,16(sp)
ffffffffc0200cc8:	60e2                	ld	ra,24(sp)
ffffffffc0200cca:	64a2                	ld	s1,8(sp)
ffffffffc0200ccc:	6902                	ld	s2,0(sp)
ffffffffc0200cce:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cd0:	2f40506f          	j	ffffffffc0205fc4 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cd4:	555d                	li	a0,-9
ffffffffc0200cd6:	752040ef          	jal	ra,ffffffffc0205428 <do_exit>
ffffffffc0200cda:	601c                	ld	a5,0(s0)
ffffffffc0200cdc:	bf55                	j	ffffffffc0200c90 <trap+0x40>
	...

ffffffffc0200ce0 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ce0:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ce4:	00011463          	bnez	sp,ffffffffc0200cec <__alltraps+0xc>
ffffffffc0200ce8:	14002173          	csrr	sp,sscratch
ffffffffc0200cec:	712d                	addi	sp,sp,-288
ffffffffc0200cee:	e002                	sd	zero,0(sp)
ffffffffc0200cf0:	e406                	sd	ra,8(sp)
ffffffffc0200cf2:	ec0e                	sd	gp,24(sp)
ffffffffc0200cf4:	f012                	sd	tp,32(sp)
ffffffffc0200cf6:	f416                	sd	t0,40(sp)
ffffffffc0200cf8:	f81a                	sd	t1,48(sp)
ffffffffc0200cfa:	fc1e                	sd	t2,56(sp)
ffffffffc0200cfc:	e0a2                	sd	s0,64(sp)
ffffffffc0200cfe:	e4a6                	sd	s1,72(sp)
ffffffffc0200d00:	e8aa                	sd	a0,80(sp)
ffffffffc0200d02:	ecae                	sd	a1,88(sp)
ffffffffc0200d04:	f0b2                	sd	a2,96(sp)
ffffffffc0200d06:	f4b6                	sd	a3,104(sp)
ffffffffc0200d08:	f8ba                	sd	a4,112(sp)
ffffffffc0200d0a:	fcbe                	sd	a5,120(sp)
ffffffffc0200d0c:	e142                	sd	a6,128(sp)
ffffffffc0200d0e:	e546                	sd	a7,136(sp)
ffffffffc0200d10:	e94a                	sd	s2,144(sp)
ffffffffc0200d12:	ed4e                	sd	s3,152(sp)
ffffffffc0200d14:	f152                	sd	s4,160(sp)
ffffffffc0200d16:	f556                	sd	s5,168(sp)
ffffffffc0200d18:	f95a                	sd	s6,176(sp)
ffffffffc0200d1a:	fd5e                	sd	s7,184(sp)
ffffffffc0200d1c:	e1e2                	sd	s8,192(sp)
ffffffffc0200d1e:	e5e6                	sd	s9,200(sp)
ffffffffc0200d20:	e9ea                	sd	s10,208(sp)
ffffffffc0200d22:	edee                	sd	s11,216(sp)
ffffffffc0200d24:	f1f2                	sd	t3,224(sp)
ffffffffc0200d26:	f5f6                	sd	t4,232(sp)
ffffffffc0200d28:	f9fa                	sd	t5,240(sp)
ffffffffc0200d2a:	fdfe                	sd	t6,248(sp)
ffffffffc0200d2c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d30:	100024f3          	csrr	s1,sstatus
ffffffffc0200d34:	14102973          	csrr	s2,sepc
ffffffffc0200d38:	143029f3          	csrr	s3,stval
ffffffffc0200d3c:	14202a73          	csrr	s4,scause
ffffffffc0200d40:	e822                	sd	s0,16(sp)
ffffffffc0200d42:	e226                	sd	s1,256(sp)
ffffffffc0200d44:	e64a                	sd	s2,264(sp)
ffffffffc0200d46:	ea4e                	sd	s3,272(sp)
ffffffffc0200d48:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d4a:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d4c:	f05ff0ef          	jal	ra,ffffffffc0200c50 <trap>

ffffffffc0200d50 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d50:	6492                	ld	s1,256(sp)
ffffffffc0200d52:	6932                	ld	s2,264(sp)
ffffffffc0200d54:	1004f413          	andi	s0,s1,256
ffffffffc0200d58:	e401                	bnez	s0,ffffffffc0200d60 <__trapret+0x10>
ffffffffc0200d5a:	1200                	addi	s0,sp,288
ffffffffc0200d5c:	14041073          	csrw	sscratch,s0
ffffffffc0200d60:	10049073          	csrw	sstatus,s1
ffffffffc0200d64:	14191073          	csrw	sepc,s2
ffffffffc0200d68:	60a2                	ld	ra,8(sp)
ffffffffc0200d6a:	61e2                	ld	gp,24(sp)
ffffffffc0200d6c:	7202                	ld	tp,32(sp)
ffffffffc0200d6e:	72a2                	ld	t0,40(sp)
ffffffffc0200d70:	7342                	ld	t1,48(sp)
ffffffffc0200d72:	73e2                	ld	t2,56(sp)
ffffffffc0200d74:	6406                	ld	s0,64(sp)
ffffffffc0200d76:	64a6                	ld	s1,72(sp)
ffffffffc0200d78:	6546                	ld	a0,80(sp)
ffffffffc0200d7a:	65e6                	ld	a1,88(sp)
ffffffffc0200d7c:	7606                	ld	a2,96(sp)
ffffffffc0200d7e:	76a6                	ld	a3,104(sp)
ffffffffc0200d80:	7746                	ld	a4,112(sp)
ffffffffc0200d82:	77e6                	ld	a5,120(sp)
ffffffffc0200d84:	680a                	ld	a6,128(sp)
ffffffffc0200d86:	68aa                	ld	a7,136(sp)
ffffffffc0200d88:	694a                	ld	s2,144(sp)
ffffffffc0200d8a:	69ea                	ld	s3,152(sp)
ffffffffc0200d8c:	7a0a                	ld	s4,160(sp)
ffffffffc0200d8e:	7aaa                	ld	s5,168(sp)
ffffffffc0200d90:	7b4a                	ld	s6,176(sp)
ffffffffc0200d92:	7bea                	ld	s7,184(sp)
ffffffffc0200d94:	6c0e                	ld	s8,192(sp)
ffffffffc0200d96:	6cae                	ld	s9,200(sp)
ffffffffc0200d98:	6d4e                	ld	s10,208(sp)
ffffffffc0200d9a:	6dee                	ld	s11,216(sp)
ffffffffc0200d9c:	7e0e                	ld	t3,224(sp)
ffffffffc0200d9e:	7eae                	ld	t4,232(sp)
ffffffffc0200da0:	7f4e                	ld	t5,240(sp)
ffffffffc0200da2:	7fee                	ld	t6,248(sp)
ffffffffc0200da4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200da6:	10200073          	sret

ffffffffc0200daa <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200daa:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200dac:	b755                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200dae <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200dae:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7690>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200db2:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200db6:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200dba:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200dbe:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200dc2:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dc6:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200dca:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200dce:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dd2:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200dd4:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dd6:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dd8:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dda:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200ddc:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dde:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200de0:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200de2:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200de4:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200de6:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200de8:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dea:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200dec:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dee:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200df0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200df2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200df4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200df6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200df8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dfa:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dfc:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dfe:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200e00:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200e02:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200e04:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200e06:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200e08:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200e0a:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200e0c:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200e0e:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200e10:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200e12:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200e14:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200e16:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e18:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e1a:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e1c:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e1e:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e20:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e22:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e24:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e26:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e28:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e2a:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e2c:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e2e:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e30:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e32:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e34:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e36:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e38:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e3a:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e3c:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e3e:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e40:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e42:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e44:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e46:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e48:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e4a:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e4c:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e4e:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e50:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e52:	812e                	mv	sp,a1
ffffffffc0200e54:	bdf5                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200e56 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200e56:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200e58:	00006697          	auipc	a3,0x6
ffffffffc0200e5c:	16868693          	addi	a3,a3,360 # ffffffffc0206fc0 <commands+0x838>
ffffffffc0200e60:	00006617          	auipc	a2,0x6
ffffffffc0200e64:	da860613          	addi	a2,a2,-600 # ffffffffc0206c08 <commands+0x480>
ffffffffc0200e68:	06d00593          	li	a1,109
ffffffffc0200e6c:	00006517          	auipc	a0,0x6
ffffffffc0200e70:	17450513          	addi	a0,a0,372 # ffffffffc0206fe0 <commands+0x858>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200e74:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200e76:	ba0ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200e7a <mm_create>:
mm_create(void) {
ffffffffc0200e7a:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e7c:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0200e80:	e022                	sd	s0,0(sp)
ffffffffc0200e82:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e84:	650010ef          	jal	ra,ffffffffc02024d4 <kmalloc>
ffffffffc0200e88:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200e8a:	c515                	beqz	a0,ffffffffc0200eb6 <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200e8c:	000ab797          	auipc	a5,0xab
ffffffffc0200e90:	53c78793          	addi	a5,a5,1340 # ffffffffc02ac3c8 <swap_init_ok>
ffffffffc0200e94:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e96:	e408                	sd	a0,8(s0)
ffffffffc0200e98:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200e9a:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200e9e:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200ea2:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200ea6:	2781                	sext.w	a5,a5
ffffffffc0200ea8:	ef81                	bnez	a5,ffffffffc0200ec0 <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc0200eaa:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0200eae:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0200eb2:	02043c23          	sd	zero,56(s0)
}
ffffffffc0200eb6:	8522                	mv	a0,s0
ffffffffc0200eb8:	60a2                	ld	ra,8(sp)
ffffffffc0200eba:	6402                	ld	s0,0(sp)
ffffffffc0200ebc:	0141                	addi	sp,sp,16
ffffffffc0200ebe:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200ec0:	1b4010ef          	jal	ra,ffffffffc0202074 <swap_init_mm>
ffffffffc0200ec4:	b7ed                	j	ffffffffc0200eae <mm_create+0x34>

ffffffffc0200ec6 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200ec6:	1101                	addi	sp,sp,-32
ffffffffc0200ec8:	e04a                	sd	s2,0(sp)
ffffffffc0200eca:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200ecc:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200ed0:	e822                	sd	s0,16(sp)
ffffffffc0200ed2:	e426                	sd	s1,8(sp)
ffffffffc0200ed4:	ec06                	sd	ra,24(sp)
ffffffffc0200ed6:	84ae                	mv	s1,a1
ffffffffc0200ed8:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200eda:	5fa010ef          	jal	ra,ffffffffc02024d4 <kmalloc>
    if (vma != NULL) {
ffffffffc0200ede:	c509                	beqz	a0,ffffffffc0200ee8 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200ee0:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200ee4:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200ee6:	cd00                	sw	s0,24(a0)
}
ffffffffc0200ee8:	60e2                	ld	ra,24(sp)
ffffffffc0200eea:	6442                	ld	s0,16(sp)
ffffffffc0200eec:	64a2                	ld	s1,8(sp)
ffffffffc0200eee:	6902                	ld	s2,0(sp)
ffffffffc0200ef0:	6105                	addi	sp,sp,32
ffffffffc0200ef2:	8082                	ret

ffffffffc0200ef4 <find_vma>:
    if (mm != NULL) {
ffffffffc0200ef4:	c51d                	beqz	a0,ffffffffc0200f22 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0200ef6:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200ef8:	c781                	beqz	a5,ffffffffc0200f00 <find_vma+0xc>
ffffffffc0200efa:	6798                	ld	a4,8(a5)
ffffffffc0200efc:	02e5f663          	bleu	a4,a1,ffffffffc0200f28 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0200f00:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200f02:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200f04:	00f50f63          	beq	a0,a5,ffffffffc0200f22 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200f08:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200f0c:	fee5ebe3          	bltu	a1,a4,ffffffffc0200f02 <find_vma+0xe>
ffffffffc0200f10:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200f14:	fee5f7e3          	bleu	a4,a1,ffffffffc0200f02 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0200f18:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0200f1a:	c781                	beqz	a5,ffffffffc0200f22 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0200f1c:	e91c                	sd	a5,16(a0)
}
ffffffffc0200f1e:	853e                	mv	a0,a5
ffffffffc0200f20:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0200f22:	4781                	li	a5,0
}
ffffffffc0200f24:	853e                	mv	a0,a5
ffffffffc0200f26:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200f28:	6b98                	ld	a4,16(a5)
ffffffffc0200f2a:	fce5fbe3          	bleu	a4,a1,ffffffffc0200f00 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0200f2e:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0200f30:	b7fd                	j	ffffffffc0200f1e <find_vma+0x2a>

ffffffffc0200f32 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f32:	6590                	ld	a2,8(a1)
ffffffffc0200f34:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200f38:	1141                	addi	sp,sp,-16
ffffffffc0200f3a:	e406                	sd	ra,8(sp)
ffffffffc0200f3c:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f3e:	01066863          	bltu	a2,a6,ffffffffc0200f4e <insert_vma_struct+0x1c>
ffffffffc0200f42:	a8b9                	j	ffffffffc0200fa0 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200f44:	fe87b683          	ld	a3,-24(a5)
ffffffffc0200f48:	04d66763          	bltu	a2,a3,ffffffffc0200f96 <insert_vma_struct+0x64>
ffffffffc0200f4c:	873e                	mv	a4,a5
ffffffffc0200f4e:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0200f50:	fef51ae3          	bne	a0,a5,ffffffffc0200f44 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200f54:	02a70463          	beq	a4,a0,ffffffffc0200f7c <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200f58:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200f5c:	fe873883          	ld	a7,-24(a4)
ffffffffc0200f60:	08d8f063          	bleu	a3,a7,ffffffffc0200fe0 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f64:	04d66e63          	bltu	a2,a3,ffffffffc0200fc0 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0200f68:	00f50a63          	beq	a0,a5,ffffffffc0200f7c <insert_vma_struct+0x4a>
ffffffffc0200f6c:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f70:	0506e863          	bltu	a3,a6,ffffffffc0200fc0 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0200f74:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200f78:	02c6f263          	bleu	a2,a3,ffffffffc0200f9c <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200f7c:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0200f7e:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200f80:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200f84:	e390                	sd	a2,0(a5)
ffffffffc0200f86:	e710                	sd	a2,8(a4)
}
ffffffffc0200f88:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200f8a:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200f8c:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0200f8e:	2685                	addiw	a3,a3,1
ffffffffc0200f90:	d114                	sw	a3,32(a0)
}
ffffffffc0200f92:	0141                	addi	sp,sp,16
ffffffffc0200f94:	8082                	ret
    if (le_prev != list) {
ffffffffc0200f96:	fca711e3          	bne	a4,a0,ffffffffc0200f58 <insert_vma_struct+0x26>
ffffffffc0200f9a:	bfd9                	j	ffffffffc0200f70 <insert_vma_struct+0x3e>
ffffffffc0200f9c:	ebbff0ef          	jal	ra,ffffffffc0200e56 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200fa0:	00006697          	auipc	a3,0x6
ffffffffc0200fa4:	14068693          	addi	a3,a3,320 # ffffffffc02070e0 <commands+0x958>
ffffffffc0200fa8:	00006617          	auipc	a2,0x6
ffffffffc0200fac:	c6060613          	addi	a2,a2,-928 # ffffffffc0206c08 <commands+0x480>
ffffffffc0200fb0:	07400593          	li	a1,116
ffffffffc0200fb4:	00006517          	auipc	a0,0x6
ffffffffc0200fb8:	02c50513          	addi	a0,a0,44 # ffffffffc0206fe0 <commands+0x858>
ffffffffc0200fbc:	a5aff0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200fc0:	00006697          	auipc	a3,0x6
ffffffffc0200fc4:	16068693          	addi	a3,a3,352 # ffffffffc0207120 <commands+0x998>
ffffffffc0200fc8:	00006617          	auipc	a2,0x6
ffffffffc0200fcc:	c4060613          	addi	a2,a2,-960 # ffffffffc0206c08 <commands+0x480>
ffffffffc0200fd0:	06c00593          	li	a1,108
ffffffffc0200fd4:	00006517          	auipc	a0,0x6
ffffffffc0200fd8:	00c50513          	addi	a0,a0,12 # ffffffffc0206fe0 <commands+0x858>
ffffffffc0200fdc:	a3aff0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200fe0:	00006697          	auipc	a3,0x6
ffffffffc0200fe4:	12068693          	addi	a3,a3,288 # ffffffffc0207100 <commands+0x978>
ffffffffc0200fe8:	00006617          	auipc	a2,0x6
ffffffffc0200fec:	c2060613          	addi	a2,a2,-992 # ffffffffc0206c08 <commands+0x480>
ffffffffc0200ff0:	06b00593          	li	a1,107
ffffffffc0200ff4:	00006517          	auipc	a0,0x6
ffffffffc0200ff8:	fec50513          	addi	a0,a0,-20 # ffffffffc0206fe0 <commands+0x858>
ffffffffc0200ffc:	a1aff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201000 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0201000:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0201002:	1141                	addi	sp,sp,-16
ffffffffc0201004:	e406                	sd	ra,8(sp)
ffffffffc0201006:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0201008:	e78d                	bnez	a5,ffffffffc0201032 <mm_destroy+0x32>
ffffffffc020100a:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020100c:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020100e:	00a40c63          	beq	s0,a0,ffffffffc0201026 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201012:	6118                	ld	a4,0(a0)
ffffffffc0201014:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0201016:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201018:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020101a:	e398                	sd	a4,0(a5)
ffffffffc020101c:	574010ef          	jal	ra,ffffffffc0202590 <kfree>
    return listelm->next;
ffffffffc0201020:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201022:	fea418e3          	bne	s0,a0,ffffffffc0201012 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0201026:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0201028:	6402                	ld	s0,0(sp)
ffffffffc020102a:	60a2                	ld	ra,8(sp)
ffffffffc020102c:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc020102e:	5620106f          	j	ffffffffc0202590 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0201032:	00006697          	auipc	a3,0x6
ffffffffc0201036:	10e68693          	addi	a3,a3,270 # ffffffffc0207140 <commands+0x9b8>
ffffffffc020103a:	00006617          	auipc	a2,0x6
ffffffffc020103e:	bce60613          	addi	a2,a2,-1074 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201042:	09400593          	li	a1,148
ffffffffc0201046:	00006517          	auipc	a0,0x6
ffffffffc020104a:	f9a50513          	addi	a0,a0,-102 # ffffffffc0206fe0 <commands+0x858>
ffffffffc020104e:	9c8ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201052 <mm_map>:

// 将虚拟地址空间映射到物理地址空间
int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201052:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc0201054:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201056:	17fd                	addi	a5,a5,-1
ffffffffc0201058:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc020105a:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020105c:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc0201060:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201062:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc0201064:	fc06                	sd	ra,56(sp)
ffffffffc0201066:	f04a                	sd	s2,32(sp)
ffffffffc0201068:	ec4e                	sd	s3,24(sp)
ffffffffc020106a:	e852                	sd	s4,16(sp)
ffffffffc020106c:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020106e:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc0201072:	002007b7          	lui	a5,0x200
ffffffffc0201076:	01047433          	and	s0,s0,a6
ffffffffc020107a:	06f4e363          	bltu	s1,a5,ffffffffc02010e0 <mm_map+0x8e>
ffffffffc020107e:	0684f163          	bleu	s0,s1,ffffffffc02010e0 <mm_map+0x8e>
ffffffffc0201082:	4785                	li	a5,1
ffffffffc0201084:	07fe                	slli	a5,a5,0x1f
ffffffffc0201086:	0487ed63          	bltu	a5,s0,ffffffffc02010e0 <mm_map+0x8e>
ffffffffc020108a:	89aa                	mv	s3,a0
ffffffffc020108c:	8a3a                	mv	s4,a4
ffffffffc020108e:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0201090:	c931                	beqz	a0,ffffffffc02010e4 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {// 如果已经存在那么就返回错误
ffffffffc0201092:	85a6                	mv	a1,s1
ffffffffc0201094:	e61ff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc0201098:	c501                	beqz	a0,ffffffffc02010a0 <mm_map+0x4e>
ffffffffc020109a:	651c                	ld	a5,8(a0)
ffffffffc020109c:	0487e263          	bltu	a5,s0,ffffffffc02010e0 <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02010a0:	03000513          	li	a0,48
ffffffffc02010a4:	430010ef          	jal	ra,ffffffffc02024d4 <kmalloc>
ffffffffc02010a8:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02010aa:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc02010ac:	02090163          	beqz	s2,ffffffffc02010ce <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);// 创建并插入vma
ffffffffc02010b0:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02010b2:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02010b6:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02010ba:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);// 创建并插入vma
ffffffffc02010be:	85ca                	mv	a1,s2
ffffffffc02010c0:	e73ff0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02010c4:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc02010c6:	000a0463          	beqz	s4,ffffffffc02010ce <mm_map+0x7c>
        *vma_store = vma;
ffffffffc02010ca:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc02010ce:	70e2                	ld	ra,56(sp)
ffffffffc02010d0:	7442                	ld	s0,48(sp)
ffffffffc02010d2:	74a2                	ld	s1,40(sp)
ffffffffc02010d4:	7902                	ld	s2,32(sp)
ffffffffc02010d6:	69e2                	ld	s3,24(sp)
ffffffffc02010d8:	6a42                	ld	s4,16(sp)
ffffffffc02010da:	6aa2                	ld	s5,8(sp)
ffffffffc02010dc:	6121                	addi	sp,sp,64
ffffffffc02010de:	8082                	ret
        return -E_INVAL;
ffffffffc02010e0:	5575                	li	a0,-3
ffffffffc02010e2:	b7f5                	j	ffffffffc02010ce <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc02010e4:	00006697          	auipc	a3,0x6
ffffffffc02010e8:	07468693          	addi	a3,a3,116 # ffffffffc0207158 <commands+0x9d0>
ffffffffc02010ec:	00006617          	auipc	a2,0x6
ffffffffc02010f0:	b1c60613          	addi	a2,a2,-1252 # ffffffffc0206c08 <commands+0x480>
ffffffffc02010f4:	0a800593          	li	a1,168
ffffffffc02010f8:	00006517          	auipc	a0,0x6
ffffffffc02010fc:	ee850513          	addi	a0,a0,-280 # ffffffffc0206fe0 <commands+0x858>
ffffffffc0201100:	916ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201104 <dup_mmap>:

// 复制一个进程的地址空间映射关系
int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0201104:	7139                	addi	sp,sp,-64
ffffffffc0201106:	fc06                	sd	ra,56(sp)
ffffffffc0201108:	f822                	sd	s0,48(sp)
ffffffffc020110a:	f426                	sd	s1,40(sp)
ffffffffc020110c:	f04a                	sd	s2,32(sp)
ffffffffc020110e:	ec4e                	sd	s3,24(sp)
ffffffffc0201110:	e852                	sd	s4,16(sp)
ffffffffc0201112:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0201114:	c535                	beqz	a0,ffffffffc0201180 <dup_mmap+0x7c>
ffffffffc0201116:	892a                	mv	s2,a0
ffffffffc0201118:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc020111a:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc020111c:	e59d                	bnez	a1,ffffffffc020114a <dup_mmap+0x46>
ffffffffc020111e:	a08d                	j	ffffffffc0201180 <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);// 属性相同
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0201120:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0201122:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5598>
        insert_vma_struct(to, nvma);
ffffffffc0201126:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc0201128:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc020112c:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc0201130:	e03ff0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0201134:	ff043683          	ld	a3,-16(s0)
ffffffffc0201138:	fe843603          	ld	a2,-24(s0)
ffffffffc020113c:	6c8c                	ld	a1,24(s1)
ffffffffc020113e:	01893503          	ld	a0,24(s2)
ffffffffc0201142:	4701                	li	a4,0
ffffffffc0201144:	72e030ef          	jal	ra,ffffffffc0204872 <copy_range>
ffffffffc0201148:	e105                	bnez	a0,ffffffffc0201168 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc020114a:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc020114c:	02848863          	beq	s1,s0,ffffffffc020117c <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201150:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);// 属性相同
ffffffffc0201154:	fe843a83          	ld	s5,-24(s0)
ffffffffc0201158:	ff043a03          	ld	s4,-16(s0)
ffffffffc020115c:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201160:	374010ef          	jal	ra,ffffffffc02024d4 <kmalloc>
ffffffffc0201164:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc0201166:	fd4d                	bnez	a0,ffffffffc0201120 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0201168:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc020116a:	70e2                	ld	ra,56(sp)
ffffffffc020116c:	7442                	ld	s0,48(sp)
ffffffffc020116e:	74a2                	ld	s1,40(sp)
ffffffffc0201170:	7902                	ld	s2,32(sp)
ffffffffc0201172:	69e2                	ld	s3,24(sp)
ffffffffc0201174:	6a42                	ld	s4,16(sp)
ffffffffc0201176:	6aa2                	ld	s5,8(sp)
ffffffffc0201178:	6121                	addi	sp,sp,64
ffffffffc020117a:	8082                	ret
    return 0;
ffffffffc020117c:	4501                	li	a0,0
ffffffffc020117e:	b7f5                	j	ffffffffc020116a <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc0201180:	00006697          	auipc	a3,0x6
ffffffffc0201184:	f2068693          	addi	a3,a3,-224 # ffffffffc02070a0 <commands+0x918>
ffffffffc0201188:	00006617          	auipc	a2,0x6
ffffffffc020118c:	a8060613          	addi	a2,a2,-1408 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201190:	0c200593          	li	a1,194
ffffffffc0201194:	00006517          	auipc	a0,0x6
ffffffffc0201198:	e4c50513          	addi	a0,a0,-436 # ffffffffc0206fe0 <commands+0x858>
ffffffffc020119c:	87aff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02011a0 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02011a0:	1101                	addi	sp,sp,-32
ffffffffc02011a2:	ec06                	sd	ra,24(sp)
ffffffffc02011a4:	e822                	sd	s0,16(sp)
ffffffffc02011a6:	e426                	sd	s1,8(sp)
ffffffffc02011a8:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02011aa:	c531                	beqz	a0,ffffffffc02011f6 <exit_mmap+0x56>
ffffffffc02011ac:	591c                	lw	a5,48(a0)
ffffffffc02011ae:	84aa                	mv	s1,a0
ffffffffc02011b0:	e3b9                	bnez	a5,ffffffffc02011f6 <exit_mmap+0x56>
    return listelm->next;
ffffffffc02011b2:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02011b4:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc02011b8:	02850663          	beq	a0,s0,ffffffffc02011e4 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);// 从页表中解除
ffffffffc02011bc:	ff043603          	ld	a2,-16(s0)
ffffffffc02011c0:	fe843583          	ld	a1,-24(s0)
ffffffffc02011c4:	854a                	mv	a0,s2
ffffffffc02011c6:	782020ef          	jal	ra,ffffffffc0203948 <unmap_range>
ffffffffc02011ca:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02011cc:	fe8498e3          	bne	s1,s0,ffffffffc02011bc <exit_mmap+0x1c>
ffffffffc02011d0:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc02011d2:	00848c63          	beq	s1,s0,ffffffffc02011ea <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);// 释放物理页并且从VMA列表中移除
ffffffffc02011d6:	ff043603          	ld	a2,-16(s0)
ffffffffc02011da:	fe843583          	ld	a1,-24(s0)
ffffffffc02011de:	854a                	mv	a0,s2
ffffffffc02011e0:	081020ef          	jal	ra,ffffffffc0203a60 <exit_range>
ffffffffc02011e4:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02011e6:	fe8498e3          	bne	s1,s0,ffffffffc02011d6 <exit_mmap+0x36>
    }
}
ffffffffc02011ea:	60e2                	ld	ra,24(sp)
ffffffffc02011ec:	6442                	ld	s0,16(sp)
ffffffffc02011ee:	64a2                	ld	s1,8(sp)
ffffffffc02011f0:	6902                	ld	s2,0(sp)
ffffffffc02011f2:	6105                	addi	sp,sp,32
ffffffffc02011f4:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02011f6:	00006697          	auipc	a3,0x6
ffffffffc02011fa:	eca68693          	addi	a3,a3,-310 # ffffffffc02070c0 <commands+0x938>
ffffffffc02011fe:	00006617          	auipc	a2,0x6
ffffffffc0201202:	a0a60613          	addi	a2,a2,-1526 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201206:	0d800593          	li	a1,216
ffffffffc020120a:	00006517          	auipc	a0,0x6
ffffffffc020120e:	dd650513          	addi	a0,a0,-554 # ffffffffc0206fe0 <commands+0x858>
ffffffffc0201212:	804ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201216 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0201216:	7139                	addi	sp,sp,-64
ffffffffc0201218:	f822                	sd	s0,48(sp)
ffffffffc020121a:	f426                	sd	s1,40(sp)
ffffffffc020121c:	fc06                	sd	ra,56(sp)
ffffffffc020121e:	f04a                	sd	s2,32(sp)
ffffffffc0201220:	ec4e                	sd	s3,24(sp)
ffffffffc0201222:	e852                	sd	s4,16(sp)
ffffffffc0201224:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0201226:	c55ff0ef          	jal	ra,ffffffffc0200e7a <mm_create>
    assert(mm != NULL);
ffffffffc020122a:	842a                	mv	s0,a0
ffffffffc020122c:	03200493          	li	s1,50
ffffffffc0201230:	e919                	bnez	a0,ffffffffc0201246 <vmm_init+0x30>
ffffffffc0201232:	a989                	j	ffffffffc0201684 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0201234:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201236:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201238:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020123c:	14ed                	addi	s1,s1,-5
ffffffffc020123e:	8522                	mv	a0,s0
ffffffffc0201240:	cf3ff0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0201244:	c88d                	beqz	s1,ffffffffc0201276 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201246:	03000513          	li	a0,48
ffffffffc020124a:	28a010ef          	jal	ra,ffffffffc02024d4 <kmalloc>
ffffffffc020124e:	85aa                	mv	a1,a0
ffffffffc0201250:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201254:	f165                	bnez	a0,ffffffffc0201234 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0201256:	00006697          	auipc	a3,0x6
ffffffffc020125a:	18268693          	addi	a3,a3,386 # ffffffffc02073d8 <commands+0xc50>
ffffffffc020125e:	00006617          	auipc	a2,0x6
ffffffffc0201262:	9aa60613          	addi	a2,a2,-1622 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201266:	11700593          	li	a1,279
ffffffffc020126a:	00006517          	auipc	a0,0x6
ffffffffc020126e:	d7650513          	addi	a0,a0,-650 # ffffffffc0206fe0 <commands+0x858>
ffffffffc0201272:	fa5fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0201276:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020127a:	1f900913          	li	s2,505
ffffffffc020127e:	a819                	j	ffffffffc0201294 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0201280:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201282:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201284:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201288:	0495                	addi	s1,s1,5
ffffffffc020128a:	8522                	mv	a0,s0
ffffffffc020128c:	ca7ff0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201290:	03248a63          	beq	s1,s2,ffffffffc02012c4 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201294:	03000513          	li	a0,48
ffffffffc0201298:	23c010ef          	jal	ra,ffffffffc02024d4 <kmalloc>
ffffffffc020129c:	85aa                	mv	a1,a0
ffffffffc020129e:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02012a2:	fd79                	bnez	a0,ffffffffc0201280 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02012a4:	00006697          	auipc	a3,0x6
ffffffffc02012a8:	13468693          	addi	a3,a3,308 # ffffffffc02073d8 <commands+0xc50>
ffffffffc02012ac:	00006617          	auipc	a2,0x6
ffffffffc02012b0:	95c60613          	addi	a2,a2,-1700 # ffffffffc0206c08 <commands+0x480>
ffffffffc02012b4:	11d00593          	li	a1,285
ffffffffc02012b8:	00006517          	auipc	a0,0x6
ffffffffc02012bc:	d2850513          	addi	a0,a0,-728 # ffffffffc0206fe0 <commands+0x858>
ffffffffc02012c0:	f57fe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc02012c4:	6418                	ld	a4,8(s0)
ffffffffc02012c6:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02012c8:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02012cc:	2ee40063          	beq	s0,a4,ffffffffc02015ac <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02012d0:	fe873603          	ld	a2,-24(a4)
ffffffffc02012d4:	ffe78693          	addi	a3,a5,-2
ffffffffc02012d8:	24d61a63          	bne	a2,a3,ffffffffc020152c <vmm_init+0x316>
ffffffffc02012dc:	ff073683          	ld	a3,-16(a4)
ffffffffc02012e0:	24f69663          	bne	a3,a5,ffffffffc020152c <vmm_init+0x316>
ffffffffc02012e4:	0795                	addi	a5,a5,5
ffffffffc02012e6:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc02012e8:	feb792e3          	bne	a5,a1,ffffffffc02012cc <vmm_init+0xb6>
ffffffffc02012ec:	491d                	li	s2,7
ffffffffc02012ee:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02012f0:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02012f4:	85a6                	mv	a1,s1
ffffffffc02012f6:	8522                	mv	a0,s0
ffffffffc02012f8:	bfdff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc02012fc:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc02012fe:	30050763          	beqz	a0,ffffffffc020160c <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0201302:	00148593          	addi	a1,s1,1
ffffffffc0201306:	8522                	mv	a0,s0
ffffffffc0201308:	bedff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc020130c:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020130e:	2c050f63          	beqz	a0,ffffffffc02015ec <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0201312:	85ca                	mv	a1,s2
ffffffffc0201314:	8522                	mv	a0,s0
ffffffffc0201316:	bdfff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
        assert(vma3 == NULL);
ffffffffc020131a:	2a051963          	bnez	a0,ffffffffc02015cc <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020131e:	00348593          	addi	a1,s1,3
ffffffffc0201322:	8522                	mv	a0,s0
ffffffffc0201324:	bd1ff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
        assert(vma4 == NULL);
ffffffffc0201328:	32051263          	bnez	a0,ffffffffc020164c <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020132c:	00448593          	addi	a1,s1,4
ffffffffc0201330:	8522                	mv	a0,s0
ffffffffc0201332:	bc3ff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
        assert(vma5 == NULL);
ffffffffc0201336:	2e051b63          	bnez	a0,ffffffffc020162c <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020133a:	008a3783          	ld	a5,8(s4)
ffffffffc020133e:	20979763          	bne	a5,s1,ffffffffc020154c <vmm_init+0x336>
ffffffffc0201342:	010a3783          	ld	a5,16(s4)
ffffffffc0201346:	21279363          	bne	a5,s2,ffffffffc020154c <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020134a:	0089b783          	ld	a5,8(s3)
ffffffffc020134e:	20979f63          	bne	a5,s1,ffffffffc020156c <vmm_init+0x356>
ffffffffc0201352:	0109b783          	ld	a5,16(s3)
ffffffffc0201356:	21279b63          	bne	a5,s2,ffffffffc020156c <vmm_init+0x356>
ffffffffc020135a:	0495                	addi	s1,s1,5
ffffffffc020135c:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020135e:	f9549be3          	bne	s1,s5,ffffffffc02012f4 <vmm_init+0xde>
ffffffffc0201362:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201364:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0201366:	85a6                	mv	a1,s1
ffffffffc0201368:	8522                	mv	a0,s0
ffffffffc020136a:	b8bff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc020136e:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0201372:	c90d                	beqz	a0,ffffffffc02013a4 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0201374:	6914                	ld	a3,16(a0)
ffffffffc0201376:	6510                	ld	a2,8(a0)
ffffffffc0201378:	00006517          	auipc	a0,0x6
ffffffffc020137c:	ef050513          	addi	a0,a0,-272 # ffffffffc0207268 <commands+0xae0>
ffffffffc0201380:	d51fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0201384:	00006697          	auipc	a3,0x6
ffffffffc0201388:	f0c68693          	addi	a3,a3,-244 # ffffffffc0207290 <commands+0xb08>
ffffffffc020138c:	00006617          	auipc	a2,0x6
ffffffffc0201390:	87c60613          	addi	a2,a2,-1924 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201394:	13f00593          	li	a1,319
ffffffffc0201398:	00006517          	auipc	a0,0x6
ffffffffc020139c:	c4850513          	addi	a0,a0,-952 # ffffffffc0206fe0 <commands+0x858>
ffffffffc02013a0:	e77fe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc02013a4:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02013a6:	fd2490e3          	bne	s1,s2,ffffffffc0201366 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc02013aa:	8522                	mv	a0,s0
ffffffffc02013ac:	c55ff0ef          	jal	ra,ffffffffc0201000 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02013b0:	00006517          	auipc	a0,0x6
ffffffffc02013b4:	ef850513          	addi	a0,a0,-264 # ffffffffc02072a8 <commands+0xb20>
ffffffffc02013b8:	d19fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02013bc:	318020ef          	jal	ra,ffffffffc02036d4 <nr_free_pages>
ffffffffc02013c0:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02013c2:	ab9ff0ef          	jal	ra,ffffffffc0200e7a <mm_create>
ffffffffc02013c6:	000ab797          	auipc	a5,0xab
ffffffffc02013ca:	04a7b523          	sd	a0,74(a5) # ffffffffc02ac410 <check_mm_struct>
ffffffffc02013ce:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc02013d0:	36050663          	beqz	a0,ffffffffc020173c <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013d4:	000ab797          	auipc	a5,0xab
ffffffffc02013d8:	00478793          	addi	a5,a5,4 # ffffffffc02ac3d8 <boot_pgdir>
ffffffffc02013dc:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc02013e0:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013e4:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02013e8:	2c079e63          	bnez	a5,ffffffffc02016c4 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02013ec:	03000513          	li	a0,48
ffffffffc02013f0:	0e4010ef          	jal	ra,ffffffffc02024d4 <kmalloc>
ffffffffc02013f4:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc02013f6:	18050b63          	beqz	a0,ffffffffc020158c <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc02013fa:	002007b7          	lui	a5,0x200
ffffffffc02013fe:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0201400:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0201402:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0201404:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0201406:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0201408:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc020140c:	b27ff0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0201410:	10000593          	li	a1,256
ffffffffc0201414:	8526                	mv	a0,s1
ffffffffc0201416:	adfff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc020141a:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc020141e:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0201422:	2ca41163          	bne	s0,a0,ffffffffc02016e4 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0201426:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5590>
        sum += i;
ffffffffc020142a:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc020142c:	fee79de3          	bne	a5,a4,ffffffffc0201426 <vmm_init+0x210>
        sum += i;
ffffffffc0201430:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0201432:	10000793          	li	a5,256
        sum += i;
ffffffffc0201436:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x821a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc020143a:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020143e:	0007c683          	lbu	a3,0(a5)
ffffffffc0201442:	0785                	addi	a5,a5,1
ffffffffc0201444:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0201446:	fec79ce3          	bne	a5,a2,ffffffffc020143e <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc020144a:	2c071963          	bnez	a4,ffffffffc020171c <vmm_init+0x506>
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc020144e:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201452:	000aba97          	auipc	s5,0xab
ffffffffc0201456:	f8ea8a93          	addi	s5,s5,-114 # ffffffffc02ac3e0 <npage>
ffffffffc020145a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020145e:	078a                	slli	a5,a5,0x2
ffffffffc0201460:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201462:	20e7f563          	bleu	a4,a5,ffffffffc020166c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0201466:	00008697          	auipc	a3,0x8
ffffffffc020146a:	8aa68693          	addi	a3,a3,-1878 # ffffffffc0208d10 <nbase>
ffffffffc020146e:	0006ba03          	ld	s4,0(a3)
ffffffffc0201472:	414786b3          	sub	a3,a5,s4
ffffffffc0201476:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0201478:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020147a:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc020147c:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc020147e:	83b1                	srli	a5,a5,0xc
ffffffffc0201480:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201482:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201484:	28e7f063          	bleu	a4,a5,ffffffffc0201704 <vmm_init+0x4ee>
ffffffffc0201488:	000ab797          	auipc	a5,0xab
ffffffffc020148c:	08878793          	addi	a5,a5,136 # ffffffffc02ac510 <va_pa_offset>
ffffffffc0201490:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0201492:	4581                	li	a1,0
ffffffffc0201494:	854a                	mv	a0,s2
ffffffffc0201496:	9436                	add	s0,s0,a3
ffffffffc0201498:	01f020ef          	jal	ra,ffffffffc0203cb6 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020149c:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020149e:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014a2:	078a                	slli	a5,a5,0x2
ffffffffc02014a4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014a6:	1ce7f363          	bleu	a4,a5,ffffffffc020166c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02014aa:	000ab417          	auipc	s0,0xab
ffffffffc02014ae:	07640413          	addi	s0,s0,118 # ffffffffc02ac520 <pages>
ffffffffc02014b2:	6008                	ld	a0,0(s0)
ffffffffc02014b4:	414787b3          	sub	a5,a5,s4
ffffffffc02014b8:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02014ba:	953e                	add	a0,a0,a5
ffffffffc02014bc:	4585                	li	a1,1
ffffffffc02014be:	1d0020ef          	jal	ra,ffffffffc020368e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02014c2:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02014c6:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014ca:	078a                	slli	a5,a5,0x2
ffffffffc02014cc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014ce:	18e7ff63          	bleu	a4,a5,ffffffffc020166c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02014d2:	6008                	ld	a0,0(s0)
ffffffffc02014d4:	414787b3          	sub	a5,a5,s4
ffffffffc02014d8:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02014da:	4585                	li	a1,1
ffffffffc02014dc:	953e                	add	a0,a0,a5
ffffffffc02014de:	1b0020ef          	jal	ra,ffffffffc020368e <free_pages>
    pgdir[0] = 0;
ffffffffc02014e2:	00093023          	sd	zero,0(s2)
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() {
  asm volatile("sfence.vma");
ffffffffc02014e6:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc02014ea:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc02014ee:	8526                	mv	a0,s1
ffffffffc02014f0:	b11ff0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc02014f4:	000ab797          	auipc	a5,0xab
ffffffffc02014f8:	f007be23          	sd	zero,-228(a5) # ffffffffc02ac410 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02014fc:	1d8020ef          	jal	ra,ffffffffc02036d4 <nr_free_pages>
ffffffffc0201500:	1aa99263          	bne	s3,a0,ffffffffc02016a4 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0201504:	00006517          	auipc	a0,0x6
ffffffffc0201508:	e9c50513          	addi	a0,a0,-356 # ffffffffc02073a0 <commands+0xc18>
ffffffffc020150c:	bc5fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0201510:	7442                	ld	s0,48(sp)
ffffffffc0201512:	70e2                	ld	ra,56(sp)
ffffffffc0201514:	74a2                	ld	s1,40(sp)
ffffffffc0201516:	7902                	ld	s2,32(sp)
ffffffffc0201518:	69e2                	ld	s3,24(sp)
ffffffffc020151a:	6a42                	ld	s4,16(sp)
ffffffffc020151c:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020151e:	00006517          	auipc	a0,0x6
ffffffffc0201522:	ea250513          	addi	a0,a0,-350 # ffffffffc02073c0 <commands+0xc38>
}
ffffffffc0201526:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201528:	ba9fe06f          	j	ffffffffc02000d0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020152c:	00006697          	auipc	a3,0x6
ffffffffc0201530:	c5468693          	addi	a3,a3,-940 # ffffffffc0207180 <commands+0x9f8>
ffffffffc0201534:	00005617          	auipc	a2,0x5
ffffffffc0201538:	6d460613          	addi	a2,a2,1748 # ffffffffc0206c08 <commands+0x480>
ffffffffc020153c:	12600593          	li	a1,294
ffffffffc0201540:	00006517          	auipc	a0,0x6
ffffffffc0201544:	aa050513          	addi	a0,a0,-1376 # ffffffffc0206fe0 <commands+0x858>
ffffffffc0201548:	ccffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020154c:	00006697          	auipc	a3,0x6
ffffffffc0201550:	cbc68693          	addi	a3,a3,-836 # ffffffffc0207208 <commands+0xa80>
ffffffffc0201554:	00005617          	auipc	a2,0x5
ffffffffc0201558:	6b460613          	addi	a2,a2,1716 # ffffffffc0206c08 <commands+0x480>
ffffffffc020155c:	13600593          	li	a1,310
ffffffffc0201560:	00006517          	auipc	a0,0x6
ffffffffc0201564:	a8050513          	addi	a0,a0,-1408 # ffffffffc0206fe0 <commands+0x858>
ffffffffc0201568:	caffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020156c:	00006697          	auipc	a3,0x6
ffffffffc0201570:	ccc68693          	addi	a3,a3,-820 # ffffffffc0207238 <commands+0xab0>
ffffffffc0201574:	00005617          	auipc	a2,0x5
ffffffffc0201578:	69460613          	addi	a2,a2,1684 # ffffffffc0206c08 <commands+0x480>
ffffffffc020157c:	13700593          	li	a1,311
ffffffffc0201580:	00006517          	auipc	a0,0x6
ffffffffc0201584:	a6050513          	addi	a0,a0,-1440 # ffffffffc0206fe0 <commands+0x858>
ffffffffc0201588:	c8ffe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(vma != NULL);
ffffffffc020158c:	00006697          	auipc	a3,0x6
ffffffffc0201590:	e4c68693          	addi	a3,a3,-436 # ffffffffc02073d8 <commands+0xc50>
ffffffffc0201594:	00005617          	auipc	a2,0x5
ffffffffc0201598:	67460613          	addi	a2,a2,1652 # ffffffffc0206c08 <commands+0x480>
ffffffffc020159c:	15600593          	li	a1,342
ffffffffc02015a0:	00006517          	auipc	a0,0x6
ffffffffc02015a4:	a4050513          	addi	a0,a0,-1472 # ffffffffc0206fe0 <commands+0x858>
ffffffffc02015a8:	c6ffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02015ac:	00006697          	auipc	a3,0x6
ffffffffc02015b0:	bbc68693          	addi	a3,a3,-1092 # ffffffffc0207168 <commands+0x9e0>
ffffffffc02015b4:	00005617          	auipc	a2,0x5
ffffffffc02015b8:	65460613          	addi	a2,a2,1620 # ffffffffc0206c08 <commands+0x480>
ffffffffc02015bc:	12400593          	li	a1,292
ffffffffc02015c0:	00006517          	auipc	a0,0x6
ffffffffc02015c4:	a2050513          	addi	a0,a0,-1504 # ffffffffc0206fe0 <commands+0x858>
ffffffffc02015c8:	c4ffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma3 == NULL);
ffffffffc02015cc:	00006697          	auipc	a3,0x6
ffffffffc02015d0:	c0c68693          	addi	a3,a3,-1012 # ffffffffc02071d8 <commands+0xa50>
ffffffffc02015d4:	00005617          	auipc	a2,0x5
ffffffffc02015d8:	63460613          	addi	a2,a2,1588 # ffffffffc0206c08 <commands+0x480>
ffffffffc02015dc:	13000593          	li	a1,304
ffffffffc02015e0:	00006517          	auipc	a0,0x6
ffffffffc02015e4:	a0050513          	addi	a0,a0,-1536 # ffffffffc0206fe0 <commands+0x858>
ffffffffc02015e8:	c2ffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma2 != NULL);
ffffffffc02015ec:	00006697          	auipc	a3,0x6
ffffffffc02015f0:	bdc68693          	addi	a3,a3,-1060 # ffffffffc02071c8 <commands+0xa40>
ffffffffc02015f4:	00005617          	auipc	a2,0x5
ffffffffc02015f8:	61460613          	addi	a2,a2,1556 # ffffffffc0206c08 <commands+0x480>
ffffffffc02015fc:	12e00593          	li	a1,302
ffffffffc0201600:	00006517          	auipc	a0,0x6
ffffffffc0201604:	9e050513          	addi	a0,a0,-1568 # ffffffffc0206fe0 <commands+0x858>
ffffffffc0201608:	c0ffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma1 != NULL);
ffffffffc020160c:	00006697          	auipc	a3,0x6
ffffffffc0201610:	bac68693          	addi	a3,a3,-1108 # ffffffffc02071b8 <commands+0xa30>
ffffffffc0201614:	00005617          	auipc	a2,0x5
ffffffffc0201618:	5f460613          	addi	a2,a2,1524 # ffffffffc0206c08 <commands+0x480>
ffffffffc020161c:	12c00593          	li	a1,300
ffffffffc0201620:	00006517          	auipc	a0,0x6
ffffffffc0201624:	9c050513          	addi	a0,a0,-1600 # ffffffffc0206fe0 <commands+0x858>
ffffffffc0201628:	beffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma5 == NULL);
ffffffffc020162c:	00006697          	auipc	a3,0x6
ffffffffc0201630:	bcc68693          	addi	a3,a3,-1076 # ffffffffc02071f8 <commands+0xa70>
ffffffffc0201634:	00005617          	auipc	a2,0x5
ffffffffc0201638:	5d460613          	addi	a2,a2,1492 # ffffffffc0206c08 <commands+0x480>
ffffffffc020163c:	13400593          	li	a1,308
ffffffffc0201640:	00006517          	auipc	a0,0x6
ffffffffc0201644:	9a050513          	addi	a0,a0,-1632 # ffffffffc0206fe0 <commands+0x858>
ffffffffc0201648:	bcffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma4 == NULL);
ffffffffc020164c:	00006697          	auipc	a3,0x6
ffffffffc0201650:	b9c68693          	addi	a3,a3,-1124 # ffffffffc02071e8 <commands+0xa60>
ffffffffc0201654:	00005617          	auipc	a2,0x5
ffffffffc0201658:	5b460613          	addi	a2,a2,1460 # ffffffffc0206c08 <commands+0x480>
ffffffffc020165c:	13200593          	li	a1,306
ffffffffc0201660:	00006517          	auipc	a0,0x6
ffffffffc0201664:	98050513          	addi	a0,a0,-1664 # ffffffffc0206fe0 <commands+0x858>
ffffffffc0201668:	baffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020166c:	00006617          	auipc	a2,0x6
ffffffffc0201670:	cb460613          	addi	a2,a2,-844 # ffffffffc0207320 <commands+0xb98>
ffffffffc0201674:	06200593          	li	a1,98
ffffffffc0201678:	00006517          	auipc	a0,0x6
ffffffffc020167c:	cc850513          	addi	a0,a0,-824 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0201680:	b97fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(mm != NULL);
ffffffffc0201684:	00006697          	auipc	a3,0x6
ffffffffc0201688:	ad468693          	addi	a3,a3,-1324 # ffffffffc0207158 <commands+0x9d0>
ffffffffc020168c:	00005617          	auipc	a2,0x5
ffffffffc0201690:	57c60613          	addi	a2,a2,1404 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201694:	11000593          	li	a1,272
ffffffffc0201698:	00006517          	auipc	a0,0x6
ffffffffc020169c:	94850513          	addi	a0,a0,-1720 # ffffffffc0206fe0 <commands+0x858>
ffffffffc02016a0:	b77fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02016a4:	00006697          	auipc	a3,0x6
ffffffffc02016a8:	cd468693          	addi	a3,a3,-812 # ffffffffc0207378 <commands+0xbf0>
ffffffffc02016ac:	00005617          	auipc	a2,0x5
ffffffffc02016b0:	55c60613          	addi	a2,a2,1372 # ffffffffc0206c08 <commands+0x480>
ffffffffc02016b4:	17400593          	li	a1,372
ffffffffc02016b8:	00006517          	auipc	a0,0x6
ffffffffc02016bc:	92850513          	addi	a0,a0,-1752 # ffffffffc0206fe0 <commands+0x858>
ffffffffc02016c0:	b57fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02016c4:	00006697          	auipc	a3,0x6
ffffffffc02016c8:	c1c68693          	addi	a3,a3,-996 # ffffffffc02072e0 <commands+0xb58>
ffffffffc02016cc:	00005617          	auipc	a2,0x5
ffffffffc02016d0:	53c60613          	addi	a2,a2,1340 # ffffffffc0206c08 <commands+0x480>
ffffffffc02016d4:	15300593          	li	a1,339
ffffffffc02016d8:	00006517          	auipc	a0,0x6
ffffffffc02016dc:	90850513          	addi	a0,a0,-1784 # ffffffffc0206fe0 <commands+0x858>
ffffffffc02016e0:	b37fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02016e4:	00006697          	auipc	a3,0x6
ffffffffc02016e8:	c0c68693          	addi	a3,a3,-1012 # ffffffffc02072f0 <commands+0xb68>
ffffffffc02016ec:	00005617          	auipc	a2,0x5
ffffffffc02016f0:	51c60613          	addi	a2,a2,1308 # ffffffffc0206c08 <commands+0x480>
ffffffffc02016f4:	15b00593          	li	a1,347
ffffffffc02016f8:	00006517          	auipc	a0,0x6
ffffffffc02016fc:	8e850513          	addi	a0,a0,-1816 # ffffffffc0206fe0 <commands+0x858>
ffffffffc0201700:	b17fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201704:	00006617          	auipc	a2,0x6
ffffffffc0201708:	c4c60613          	addi	a2,a2,-948 # ffffffffc0207350 <commands+0xbc8>
ffffffffc020170c:	06900593          	li	a1,105
ffffffffc0201710:	00006517          	auipc	a0,0x6
ffffffffc0201714:	c3050513          	addi	a0,a0,-976 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0201718:	afffe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(sum == 0);
ffffffffc020171c:	00006697          	auipc	a3,0x6
ffffffffc0201720:	bf468693          	addi	a3,a3,-1036 # ffffffffc0207310 <commands+0xb88>
ffffffffc0201724:	00005617          	auipc	a2,0x5
ffffffffc0201728:	4e460613          	addi	a2,a2,1252 # ffffffffc0206c08 <commands+0x480>
ffffffffc020172c:	16700593          	li	a1,359
ffffffffc0201730:	00006517          	auipc	a0,0x6
ffffffffc0201734:	8b050513          	addi	a0,a0,-1872 # ffffffffc0206fe0 <commands+0x858>
ffffffffc0201738:	adffe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020173c:	00006697          	auipc	a3,0x6
ffffffffc0201740:	b8c68693          	addi	a3,a3,-1140 # ffffffffc02072c8 <commands+0xb40>
ffffffffc0201744:	00005617          	auipc	a2,0x5
ffffffffc0201748:	4c460613          	addi	a2,a2,1220 # ffffffffc0206c08 <commands+0x480>
ffffffffc020174c:	14f00593          	li	a1,335
ffffffffc0201750:	00006517          	auipc	a0,0x6
ffffffffc0201754:	89050513          	addi	a0,a0,-1904 # ffffffffc0206fe0 <commands+0x858>
ffffffffc0201758:	abffe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020175c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020175c:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020175e:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201760:	f822                	sd	s0,48(sp)
ffffffffc0201762:	f426                	sd	s1,40(sp)
ffffffffc0201764:	fc06                	sd	ra,56(sp)
ffffffffc0201766:	f04a                	sd	s2,32(sp)
ffffffffc0201768:	ec4e                	sd	s3,24(sp)
ffffffffc020176a:	8432                	mv	s0,a2
ffffffffc020176c:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020176e:	f86ff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>

    pgfault_num++;
ffffffffc0201772:	000ab797          	auipc	a5,0xab
ffffffffc0201776:	c4678793          	addi	a5,a5,-954 # ffffffffc02ac3b8 <pgfault_num>
ffffffffc020177a:	439c                	lw	a5,0(a5)
ffffffffc020177c:	2785                	addiw	a5,a5,1
ffffffffc020177e:	000ab717          	auipc	a4,0xab
ffffffffc0201782:	c2f72d23          	sw	a5,-966(a4) # ffffffffc02ac3b8 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201786:	c545                	beqz	a0,ffffffffc020182e <do_pgfault+0xd2>
ffffffffc0201788:	651c                	ld	a5,8(a0)
ffffffffc020178a:	0af46263          	bltu	s0,a5,ffffffffc020182e <do_pgfault+0xd2>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020178e:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0201790:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201792:	8b89                	andi	a5,a5,2
ffffffffc0201794:	efb1                	bnez	a5,ffffffffc02017f0 <do_pgfault+0x94>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201796:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201798:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc020179a:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020179c:	85a2                	mv	a1,s0
ffffffffc020179e:	4605                	li	a2,1
ffffffffc02017a0:	775010ef          	jal	ra,ffffffffc0203714 <get_pte>
ffffffffc02017a4:	c555                	beqz	a0,ffffffffc0201850 <do_pgfault+0xf4>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02017a6:	610c                	ld	a1,0(a0)
ffffffffc02017a8:	c5a5                	beqz	a1,ffffffffc0201810 <do_pgfault+0xb4>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02017aa:	000ab797          	auipc	a5,0xab
ffffffffc02017ae:	c1e78793          	addi	a5,a5,-994 # ffffffffc02ac3c8 <swap_init_ok>
ffffffffc02017b2:	439c                	lw	a5,0(a5)
ffffffffc02017b4:	2781                	sext.w	a5,a5
ffffffffc02017b6:	c7c9                	beqz	a5,ffffffffc0201840 <do_pgfault+0xe4>
            //(3) make the page swappable.

            // page->pra_vaddr = addr;


            ret = swap_in(mm, addr, &page);// 将addr对应的在磁盘上的数据换到page上  
ffffffffc02017b8:	0030                	addi	a2,sp,8
ffffffffc02017ba:	85a2                	mv	a1,s0
ffffffffc02017bc:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02017be:	e402                	sd	zero,8(sp)
            ret = swap_in(mm, addr, &page);// 将addr对应的在磁盘上的数据换到page上  
ffffffffc02017c0:	1e9000ef          	jal	ra,ffffffffc02021a8 <swap_in>
ffffffffc02017c4:	892a                	mv	s2,a0
            if(ret!=0){
ffffffffc02017c6:	e51d                	bnez	a0,ffffffffc02017f4 <do_pgfault+0x98>
                cprintf("swap_in failed\n");
                goto failed;
            }
            page_insert(mm->pgdir, page, addr, perm);// 建立索引：addr到page的映射关系，设置page的权限为perm
ffffffffc02017c8:	65a2                	ld	a1,8(sp)
ffffffffc02017ca:	6c88                	ld	a0,24(s1)
ffffffffc02017cc:	86ce                	mv	a3,s3
ffffffffc02017ce:	8622                	mv	a2,s0
ffffffffc02017d0:	55a020ef          	jal	ra,ffffffffc0203d2a <page_insert>
            swap_map_swappable(mm, addr, page, 1);// 标记为可替换
ffffffffc02017d4:	6622                	ld	a2,8(sp)
ffffffffc02017d6:	4685                	li	a3,1
ffffffffc02017d8:	85a2                	mv	a1,s0
ffffffffc02017da:	8526                	mv	a0,s1
ffffffffc02017dc:	0a9000ef          	jal	ra,ffffffffc0202084 <swap_map_swappable>
        }
   }
   ret = 0;
failed:
    return ret;
}
ffffffffc02017e0:	70e2                	ld	ra,56(sp)
ffffffffc02017e2:	7442                	ld	s0,48(sp)
ffffffffc02017e4:	854a                	mv	a0,s2
ffffffffc02017e6:	74a2                	ld	s1,40(sp)
ffffffffc02017e8:	7902                	ld	s2,32(sp)
ffffffffc02017ea:	69e2                	ld	s3,24(sp)
ffffffffc02017ec:	6121                	addi	sp,sp,64
ffffffffc02017ee:	8082                	ret
        perm |= READ_WRITE;
ffffffffc02017f0:	49dd                	li	s3,23
ffffffffc02017f2:	b755                	j	ffffffffc0201796 <do_pgfault+0x3a>
                cprintf("swap_in failed\n");
ffffffffc02017f4:	00006517          	auipc	a0,0x6
ffffffffc02017f8:	87450513          	addi	a0,a0,-1932 # ffffffffc0207068 <commands+0x8e0>
ffffffffc02017fc:	8d5fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0201800:	70e2                	ld	ra,56(sp)
ffffffffc0201802:	7442                	ld	s0,48(sp)
ffffffffc0201804:	854a                	mv	a0,s2
ffffffffc0201806:	74a2                	ld	s1,40(sp)
ffffffffc0201808:	7902                	ld	s2,32(sp)
ffffffffc020180a:	69e2                	ld	s3,24(sp)
ffffffffc020180c:	6121                	addi	sp,sp,64
ffffffffc020180e:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201810:	6c88                	ld	a0,24(s1)
ffffffffc0201812:	864e                	mv	a2,s3
ffffffffc0201814:	85a2                	mv	a1,s0
ffffffffc0201816:	27c030ef          	jal	ra,ffffffffc0204a92 <pgdir_alloc_page>
   ret = 0;
ffffffffc020181a:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020181c:	f171                	bnez	a0,ffffffffc02017e0 <do_pgfault+0x84>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc020181e:	00006517          	auipc	a0,0x6
ffffffffc0201822:	82250513          	addi	a0,a0,-2014 # ffffffffc0207040 <commands+0x8b8>
ffffffffc0201826:	8abfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020182a:	5971                	li	s2,-4
            goto failed;
ffffffffc020182c:	bf55                	j	ffffffffc02017e0 <do_pgfault+0x84>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc020182e:	85a2                	mv	a1,s0
ffffffffc0201830:	00005517          	auipc	a0,0x5
ffffffffc0201834:	7c050513          	addi	a0,a0,1984 # ffffffffc0206ff0 <commands+0x868>
ffffffffc0201838:	899fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc020183c:	5975                	li	s2,-3
        goto failed;
ffffffffc020183e:	b74d                	j	ffffffffc02017e0 <do_pgfault+0x84>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0201840:	00006517          	auipc	a0,0x6
ffffffffc0201844:	83850513          	addi	a0,a0,-1992 # ffffffffc0207078 <commands+0x8f0>
ffffffffc0201848:	889fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020184c:	5971                	li	s2,-4
            goto failed;
ffffffffc020184e:	bf49                	j	ffffffffc02017e0 <do_pgfault+0x84>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0201850:	00005517          	auipc	a0,0x5
ffffffffc0201854:	7d050513          	addi	a0,a0,2000 # ffffffffc0207020 <commands+0x898>
ffffffffc0201858:	879fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020185c:	5971                	li	s2,-4
        goto failed;
ffffffffc020185e:	b749                	j	ffffffffc02017e0 <do_pgfault+0x84>

ffffffffc0201860 <user_mem_check>:


// 检查用户空间的内存访问是否合法
bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0201860:	7179                	addi	sp,sp,-48
ffffffffc0201862:	f022                	sd	s0,32(sp)
ffffffffc0201864:	f406                	sd	ra,40(sp)
ffffffffc0201866:	ec26                	sd	s1,24(sp)
ffffffffc0201868:	e84a                	sd	s2,16(sp)
ffffffffc020186a:	e44e                	sd	s3,8(sp)
ffffffffc020186c:	e052                	sd	s4,0(sp)
ffffffffc020186e:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0201870:	c135                	beqz	a0,ffffffffc02018d4 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0201872:	002007b7          	lui	a5,0x200
ffffffffc0201876:	04f5e663          	bltu	a1,a5,ffffffffc02018c2 <user_mem_check+0x62>
ffffffffc020187a:	00c584b3          	add	s1,a1,a2
ffffffffc020187e:	0495f263          	bleu	s1,a1,ffffffffc02018c2 <user_mem_check+0x62>
ffffffffc0201882:	4785                	li	a5,1
ffffffffc0201884:	07fe                	slli	a5,a5,0x1f
ffffffffc0201886:	0297ee63          	bltu	a5,s1,ffffffffc02018c2 <user_mem_check+0x62>
ffffffffc020188a:	892a                	mv	s2,a0
ffffffffc020188c:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc020188e:	6a05                	lui	s4,0x1
ffffffffc0201890:	a821                	j	ffffffffc02018a8 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201892:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0201896:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0201898:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc020189a:	c685                	beqz	a3,ffffffffc02018c2 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc020189c:	c399                	beqz	a5,ffffffffc02018a2 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc020189e:	02e46263          	bltu	s0,a4,ffffffffc02018c2 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc02018a2:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc02018a4:	04947663          	bleu	s1,s0,ffffffffc02018f0 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc02018a8:	85a2                	mv	a1,s0
ffffffffc02018aa:	854a                	mv	a0,s2
ffffffffc02018ac:	e48ff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc02018b0:	c909                	beqz	a0,ffffffffc02018c2 <user_mem_check+0x62>
ffffffffc02018b2:	6518                	ld	a4,8(a0)
ffffffffc02018b4:	00e46763          	bltu	s0,a4,ffffffffc02018c2 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02018b8:	4d1c                	lw	a5,24(a0)
ffffffffc02018ba:	fc099ce3          	bnez	s3,ffffffffc0201892 <user_mem_check+0x32>
ffffffffc02018be:	8b85                	andi	a5,a5,1
ffffffffc02018c0:	f3ed                	bnez	a5,ffffffffc02018a2 <user_mem_check+0x42>
            return 0;
ffffffffc02018c2:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc02018c4:	70a2                	ld	ra,40(sp)
ffffffffc02018c6:	7402                	ld	s0,32(sp)
ffffffffc02018c8:	64e2                	ld	s1,24(sp)
ffffffffc02018ca:	6942                	ld	s2,16(sp)
ffffffffc02018cc:	69a2                	ld	s3,8(sp)
ffffffffc02018ce:	6a02                	ld	s4,0(sp)
ffffffffc02018d0:	6145                	addi	sp,sp,48
ffffffffc02018d2:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc02018d4:	c02007b7          	lui	a5,0xc0200
ffffffffc02018d8:	4501                	li	a0,0
ffffffffc02018da:	fef5e5e3          	bltu	a1,a5,ffffffffc02018c4 <user_mem_check+0x64>
ffffffffc02018de:	962e                	add	a2,a2,a1
ffffffffc02018e0:	fec5f2e3          	bleu	a2,a1,ffffffffc02018c4 <user_mem_check+0x64>
ffffffffc02018e4:	c8000537          	lui	a0,0xc8000
ffffffffc02018e8:	0505                	addi	a0,a0,1
ffffffffc02018ea:	00a63533          	sltu	a0,a2,a0
ffffffffc02018ee:	bfd9                	j	ffffffffc02018c4 <user_mem_check+0x64>
        return 1;
ffffffffc02018f0:	4505                	li	a0,1
ffffffffc02018f2:	bfc9                	j	ffffffffc02018c4 <user_mem_check+0x64>

ffffffffc02018f4 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02018f4:	7135                	addi	sp,sp,-160
ffffffffc02018f6:	ed06                	sd	ra,152(sp)
ffffffffc02018f8:	e922                	sd	s0,144(sp)
ffffffffc02018fa:	e526                	sd	s1,136(sp)
ffffffffc02018fc:	e14a                	sd	s2,128(sp)
ffffffffc02018fe:	fcce                	sd	s3,120(sp)
ffffffffc0201900:	f8d2                	sd	s4,112(sp)
ffffffffc0201902:	f4d6                	sd	s5,104(sp)
ffffffffc0201904:	f0da                	sd	s6,96(sp)
ffffffffc0201906:	ecde                	sd	s7,88(sp)
ffffffffc0201908:	e8e2                	sd	s8,80(sp)
ffffffffc020190a:	e4e6                	sd	s9,72(sp)
ffffffffc020190c:	e0ea                	sd	s10,64(sp)
ffffffffc020190e:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0201910:	216030ef          	jal	ra,ffffffffc0204b26 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0201914:	000ab797          	auipc	a5,0xab
ffffffffc0201918:	b8c78793          	addi	a5,a5,-1140 # ffffffffc02ac4a0 <max_swap_offset>
ffffffffc020191c:	6394                	ld	a3,0(a5)
ffffffffc020191e:	010007b7          	lui	a5,0x1000
ffffffffc0201922:	17e1                	addi	a5,a5,-8
ffffffffc0201924:	ff968713          	addi	a4,a3,-7
ffffffffc0201928:	4ae7ee63          	bltu	a5,a4,ffffffffc0201de4 <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc020192c:	0009f797          	auipc	a5,0x9f
ffffffffc0201930:	62c78793          	addi	a5,a5,1580 # ffffffffc02a0f58 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0201934:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0201936:	000ab697          	auipc	a3,0xab
ffffffffc020193a:	a8f6b523          	sd	a5,-1398(a3) # ffffffffc02ac3c0 <sm>
     int r = sm->init();
ffffffffc020193e:	9702                	jalr	a4
ffffffffc0201940:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0201942:	c10d                	beqz	a0,ffffffffc0201964 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0201944:	60ea                	ld	ra,152(sp)
ffffffffc0201946:	644a                	ld	s0,144(sp)
ffffffffc0201948:	8556                	mv	a0,s5
ffffffffc020194a:	64aa                	ld	s1,136(sp)
ffffffffc020194c:	690a                	ld	s2,128(sp)
ffffffffc020194e:	79e6                	ld	s3,120(sp)
ffffffffc0201950:	7a46                	ld	s4,112(sp)
ffffffffc0201952:	7aa6                	ld	s5,104(sp)
ffffffffc0201954:	7b06                	ld	s6,96(sp)
ffffffffc0201956:	6be6                	ld	s7,88(sp)
ffffffffc0201958:	6c46                	ld	s8,80(sp)
ffffffffc020195a:	6ca6                	ld	s9,72(sp)
ffffffffc020195c:	6d06                	ld	s10,64(sp)
ffffffffc020195e:	7de2                	ld	s11,56(sp)
ffffffffc0201960:	610d                	addi	sp,sp,160
ffffffffc0201962:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201964:	000ab797          	auipc	a5,0xab
ffffffffc0201968:	a5c78793          	addi	a5,a5,-1444 # ffffffffc02ac3c0 <sm>
ffffffffc020196c:	639c                	ld	a5,0(a5)
ffffffffc020196e:	00006517          	auipc	a0,0x6
ffffffffc0201972:	afa50513          	addi	a0,a0,-1286 # ffffffffc0207468 <commands+0xce0>
ffffffffc0201976:	000ab417          	auipc	s0,0xab
ffffffffc020197a:	b7a40413          	addi	s0,s0,-1158 # ffffffffc02ac4f0 <free_area>
ffffffffc020197e:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0201980:	4785                	li	a5,1
ffffffffc0201982:	000ab717          	auipc	a4,0xab
ffffffffc0201986:	a4f72323          	sw	a5,-1466(a4) # ffffffffc02ac3c8 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020198a:	f46fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020198e:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201990:	36878e63          	beq	a5,s0,ffffffffc0201d0c <swap_init+0x418>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201994:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201998:	8305                	srli	a4,a4,0x1
ffffffffc020199a:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020199c:	36070c63          	beqz	a4,ffffffffc0201d14 <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc02019a0:	4481                	li	s1,0
ffffffffc02019a2:	4901                	li	s2,0
ffffffffc02019a4:	a031                	j	ffffffffc02019b0 <swap_init+0xbc>
ffffffffc02019a6:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc02019aa:	8b09                	andi	a4,a4,2
ffffffffc02019ac:	36070463          	beqz	a4,ffffffffc0201d14 <swap_init+0x420>
        count ++, total += p->property;
ffffffffc02019b0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02019b4:	679c                	ld	a5,8(a5)
ffffffffc02019b6:	2905                	addiw	s2,s2,1
ffffffffc02019b8:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02019ba:	fe8796e3          	bne	a5,s0,ffffffffc02019a6 <swap_init+0xb2>
ffffffffc02019be:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc02019c0:	515010ef          	jal	ra,ffffffffc02036d4 <nr_free_pages>
ffffffffc02019c4:	69351863          	bne	a0,s3,ffffffffc0202054 <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02019c8:	8626                	mv	a2,s1
ffffffffc02019ca:	85ca                	mv	a1,s2
ffffffffc02019cc:	00006517          	auipc	a0,0x6
ffffffffc02019d0:	ae450513          	addi	a0,a0,-1308 # ffffffffc02074b0 <commands+0xd28>
ffffffffc02019d4:	efcfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02019d8:	ca2ff0ef          	jal	ra,ffffffffc0200e7a <mm_create>
ffffffffc02019dc:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc02019de:	60050b63          	beqz	a0,ffffffffc0201ff4 <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02019e2:	000ab797          	auipc	a5,0xab
ffffffffc02019e6:	a2e78793          	addi	a5,a5,-1490 # ffffffffc02ac410 <check_mm_struct>
ffffffffc02019ea:	639c                	ld	a5,0(a5)
ffffffffc02019ec:	62079463          	bnez	a5,ffffffffc0202014 <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02019f0:	000ab797          	auipc	a5,0xab
ffffffffc02019f4:	9e878793          	addi	a5,a5,-1560 # ffffffffc02ac3d8 <boot_pgdir>
ffffffffc02019f8:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc02019fc:	000ab797          	auipc	a5,0xab
ffffffffc0201a00:	a0a7ba23          	sd	a0,-1516(a5) # ffffffffc02ac410 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0201a04:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201a08:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0201a0c:	4e079863          	bnez	a5,ffffffffc0201efc <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0201a10:	6599                	lui	a1,0x6
ffffffffc0201a12:	460d                	li	a2,3
ffffffffc0201a14:	6505                	lui	a0,0x1
ffffffffc0201a16:	cb0ff0ef          	jal	ra,ffffffffc0200ec6 <vma_create>
ffffffffc0201a1a:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0201a1c:	50050063          	beqz	a0,ffffffffc0201f1c <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc0201a20:	855e                	mv	a0,s7
ffffffffc0201a22:	d10ff0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0201a26:	00006517          	auipc	a0,0x6
ffffffffc0201a2a:	aca50513          	addi	a0,a0,-1334 # ffffffffc02074f0 <commands+0xd68>
ffffffffc0201a2e:	ea2fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0201a32:	018bb503          	ld	a0,24(s7)
ffffffffc0201a36:	4605                	li	a2,1
ffffffffc0201a38:	6585                	lui	a1,0x1
ffffffffc0201a3a:	4db010ef          	jal	ra,ffffffffc0203714 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0201a3e:	4e050f63          	beqz	a0,ffffffffc0201f3c <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201a42:	00006517          	auipc	a0,0x6
ffffffffc0201a46:	afe50513          	addi	a0,a0,-1282 # ffffffffc0207540 <commands+0xdb8>
ffffffffc0201a4a:	000ab997          	auipc	s3,0xab
ffffffffc0201a4e:	9ce98993          	addi	s3,s3,-1586 # ffffffffc02ac418 <check_rp>
ffffffffc0201a52:	e7efe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201a56:	000aba17          	auipc	s4,0xab
ffffffffc0201a5a:	9e2a0a13          	addi	s4,s4,-1566 # ffffffffc02ac438 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201a5e:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0201a60:	4505                	li	a0,1
ffffffffc0201a62:	3a5010ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0201a66:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0201a6a:	32050d63          	beqz	a0,ffffffffc0201da4 <swap_init+0x4b0>
ffffffffc0201a6e:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0201a70:	8b89                	andi	a5,a5,2
ffffffffc0201a72:	30079963          	bnez	a5,ffffffffc0201d84 <swap_init+0x490>
ffffffffc0201a76:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201a78:	ff4c14e3          	bne	s8,s4,ffffffffc0201a60 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0201a7c:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0201a7e:	000abc17          	auipc	s8,0xab
ffffffffc0201a82:	99ac0c13          	addi	s8,s8,-1638 # ffffffffc02ac418 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0201a86:	ec3e                	sd	a5,24(sp)
ffffffffc0201a88:	641c                	ld	a5,8(s0)
ffffffffc0201a8a:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0201a8c:	481c                	lw	a5,16(s0)
ffffffffc0201a8e:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0201a90:	000ab797          	auipc	a5,0xab
ffffffffc0201a94:	a687b423          	sd	s0,-1432(a5) # ffffffffc02ac4f8 <free_area+0x8>
ffffffffc0201a98:	000ab797          	auipc	a5,0xab
ffffffffc0201a9c:	a487bc23          	sd	s0,-1448(a5) # ffffffffc02ac4f0 <free_area>
     nr_free = 0;
ffffffffc0201aa0:	000ab797          	auipc	a5,0xab
ffffffffc0201aa4:	a607a023          	sw	zero,-1440(a5) # ffffffffc02ac500 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0201aa8:	000c3503          	ld	a0,0(s8)
ffffffffc0201aac:	4585                	li	a1,1
ffffffffc0201aae:	0c21                	addi	s8,s8,8
ffffffffc0201ab0:	3df010ef          	jal	ra,ffffffffc020368e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201ab4:	ff4c1ae3          	bne	s8,s4,ffffffffc0201aa8 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201ab8:	01042c03          	lw	s8,16(s0)
ffffffffc0201abc:	4791                	li	a5,4
ffffffffc0201abe:	50fc1b63          	bne	s8,a5,ffffffffc0201fd4 <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0201ac2:	00006517          	auipc	a0,0x6
ffffffffc0201ac6:	b0650513          	addi	a0,a0,-1274 # ffffffffc02075c8 <commands+0xe40>
ffffffffc0201aca:	e06fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201ace:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0201ad0:	000ab797          	auipc	a5,0xab
ffffffffc0201ad4:	8e07a423          	sw	zero,-1816(a5) # ffffffffc02ac3b8 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201ad8:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0201ada:	000ab797          	auipc	a5,0xab
ffffffffc0201ade:	8de78793          	addi	a5,a5,-1826 # ffffffffc02ac3b8 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201ae2:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
     assert(pgfault_num==1);
ffffffffc0201ae6:	4398                	lw	a4,0(a5)
ffffffffc0201ae8:	4585                	li	a1,1
ffffffffc0201aea:	2701                	sext.w	a4,a4
ffffffffc0201aec:	38b71863          	bne	a4,a1,ffffffffc0201e7c <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0201af0:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0201af4:	4394                	lw	a3,0(a5)
ffffffffc0201af6:	2681                	sext.w	a3,a3
ffffffffc0201af8:	3ae69263          	bne	a3,a4,ffffffffc0201e9c <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201afc:	6689                	lui	a3,0x2
ffffffffc0201afe:	462d                	li	a2,11
ffffffffc0201b00:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7570>
     assert(pgfault_num==2);
ffffffffc0201b04:	4398                	lw	a4,0(a5)
ffffffffc0201b06:	4589                	li	a1,2
ffffffffc0201b08:	2701                	sext.w	a4,a4
ffffffffc0201b0a:	2eb71963          	bne	a4,a1,ffffffffc0201dfc <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0201b0e:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0201b12:	4394                	lw	a3,0(a5)
ffffffffc0201b14:	2681                	sext.w	a3,a3
ffffffffc0201b16:	30e69363          	bne	a3,a4,ffffffffc0201e1c <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201b1a:	668d                	lui	a3,0x3
ffffffffc0201b1c:	4631                	li	a2,12
ffffffffc0201b1e:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6570>
     assert(pgfault_num==3);
ffffffffc0201b22:	4398                	lw	a4,0(a5)
ffffffffc0201b24:	458d                	li	a1,3
ffffffffc0201b26:	2701                	sext.w	a4,a4
ffffffffc0201b28:	30b71a63          	bne	a4,a1,ffffffffc0201e3c <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0201b2c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0201b30:	4394                	lw	a3,0(a5)
ffffffffc0201b32:	2681                	sext.w	a3,a3
ffffffffc0201b34:	32e69463          	bne	a3,a4,ffffffffc0201e5c <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201b38:	6691                	lui	a3,0x4
ffffffffc0201b3a:	4635                	li	a2,13
ffffffffc0201b3c:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5570>
     assert(pgfault_num==4);
ffffffffc0201b40:	4398                	lw	a4,0(a5)
ffffffffc0201b42:	2701                	sext.w	a4,a4
ffffffffc0201b44:	37871c63          	bne	a4,s8,ffffffffc0201ebc <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201b48:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0201b4c:	439c                	lw	a5,0(a5)
ffffffffc0201b4e:	2781                	sext.w	a5,a5
ffffffffc0201b50:	38e79663          	bne	a5,a4,ffffffffc0201edc <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0201b54:	481c                	lw	a5,16(s0)
ffffffffc0201b56:	40079363          	bnez	a5,ffffffffc0201f5c <swap_init+0x668>
ffffffffc0201b5a:	000ab797          	auipc	a5,0xab
ffffffffc0201b5e:	8de78793          	addi	a5,a5,-1826 # ffffffffc02ac438 <swap_in_seq_no>
ffffffffc0201b62:	000ab717          	auipc	a4,0xab
ffffffffc0201b66:	8fe70713          	addi	a4,a4,-1794 # ffffffffc02ac460 <swap_out_seq_no>
ffffffffc0201b6a:	000ab617          	auipc	a2,0xab
ffffffffc0201b6e:	8f660613          	addi	a2,a2,-1802 # ffffffffc02ac460 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0201b72:	56fd                	li	a3,-1
ffffffffc0201b74:	c394                	sw	a3,0(a5)
ffffffffc0201b76:	c314                	sw	a3,0(a4)
ffffffffc0201b78:	0791                	addi	a5,a5,4
ffffffffc0201b7a:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201b7c:	fef61ce3          	bne	a2,a5,ffffffffc0201b74 <swap_init+0x280>
ffffffffc0201b80:	000ab697          	auipc	a3,0xab
ffffffffc0201b84:	94068693          	addi	a3,a3,-1728 # ffffffffc02ac4c0 <check_ptep>
ffffffffc0201b88:	000ab817          	auipc	a6,0xab
ffffffffc0201b8c:	89080813          	addi	a6,a6,-1904 # ffffffffc02ac418 <check_rp>
ffffffffc0201b90:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0201b92:	000abc97          	auipc	s9,0xab
ffffffffc0201b96:	84ec8c93          	addi	s9,s9,-1970 # ffffffffc02ac3e0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b9a:	00007d97          	auipc	s11,0x7
ffffffffc0201b9e:	176d8d93          	addi	s11,s11,374 # ffffffffc0208d10 <nbase>
ffffffffc0201ba2:	000abc17          	auipc	s8,0xab
ffffffffc0201ba6:	97ec0c13          	addi	s8,s8,-1666 # ffffffffc02ac520 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0201baa:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201bae:	4601                	li	a2,0
ffffffffc0201bb0:	85ea                	mv	a1,s10
ffffffffc0201bb2:	855a                	mv	a0,s6
ffffffffc0201bb4:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0201bb6:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201bb8:	35d010ef          	jal	ra,ffffffffc0203714 <get_pte>
ffffffffc0201bbc:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0201bbe:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201bc0:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0201bc2:	20050163          	beqz	a0,ffffffffc0201dc4 <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201bc6:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201bc8:	0017f613          	andi	a2,a5,1
ffffffffc0201bcc:	1a060063          	beqz	a2,ffffffffc0201d6c <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0201bd0:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201bd4:	078a                	slli	a5,a5,0x2
ffffffffc0201bd6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201bd8:	14c7fe63          	bleu	a2,a5,ffffffffc0201d34 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0201bdc:	000db703          	ld	a4,0(s11)
ffffffffc0201be0:	000c3603          	ld	a2,0(s8)
ffffffffc0201be4:	00083583          	ld	a1,0(a6)
ffffffffc0201be8:	8f99                	sub	a5,a5,a4
ffffffffc0201bea:	079a                	slli	a5,a5,0x6
ffffffffc0201bec:	e43a                	sd	a4,8(sp)
ffffffffc0201bee:	97b2                	add	a5,a5,a2
ffffffffc0201bf0:	14f59e63          	bne	a1,a5,ffffffffc0201d4c <swap_init+0x458>
ffffffffc0201bf4:	6785                	lui	a5,0x1
ffffffffc0201bf6:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201bf8:	6795                	lui	a5,0x5
ffffffffc0201bfa:	06a1                	addi	a3,a3,8
ffffffffc0201bfc:	0821                	addi	a6,a6,8
ffffffffc0201bfe:	fafd16e3          	bne	s10,a5,ffffffffc0201baa <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0201c02:	00006517          	auipc	a0,0x6
ffffffffc0201c06:	aa650513          	addi	a0,a0,-1370 # ffffffffc02076a8 <commands+0xf20>
ffffffffc0201c0a:	cc6fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = sm->check_swap();
ffffffffc0201c0e:	000aa797          	auipc	a5,0xaa
ffffffffc0201c12:	7b278793          	addi	a5,a5,1970 # ffffffffc02ac3c0 <sm>
ffffffffc0201c16:	639c                	ld	a5,0(a5)
ffffffffc0201c18:	7f9c                	ld	a5,56(a5)
ffffffffc0201c1a:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0201c1c:	40051c63          	bnez	a0,ffffffffc0202034 <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc0201c20:	77a2                	ld	a5,40(sp)
ffffffffc0201c22:	000ab717          	auipc	a4,0xab
ffffffffc0201c26:	8cf72f23          	sw	a5,-1826(a4) # ffffffffc02ac500 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0201c2a:	67e2                	ld	a5,24(sp)
ffffffffc0201c2c:	000ab717          	auipc	a4,0xab
ffffffffc0201c30:	8cf73223          	sd	a5,-1852(a4) # ffffffffc02ac4f0 <free_area>
ffffffffc0201c34:	7782                	ld	a5,32(sp)
ffffffffc0201c36:	000ab717          	auipc	a4,0xab
ffffffffc0201c3a:	8cf73123          	sd	a5,-1854(a4) # ffffffffc02ac4f8 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0201c3e:	0009b503          	ld	a0,0(s3)
ffffffffc0201c42:	4585                	li	a1,1
ffffffffc0201c44:	09a1                	addi	s3,s3,8
ffffffffc0201c46:	249010ef          	jal	ra,ffffffffc020368e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201c4a:	ff499ae3          	bne	s3,s4,ffffffffc0201c3e <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0201c4e:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc0201c52:	855e                	mv	a0,s7
ffffffffc0201c54:	bacff0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201c58:	000aa797          	auipc	a5,0xaa
ffffffffc0201c5c:	78078793          	addi	a5,a5,1920 # ffffffffc02ac3d8 <boot_pgdir>
ffffffffc0201c60:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc0201c62:	000aa697          	auipc	a3,0xaa
ffffffffc0201c66:	7a06b723          	sd	zero,1966(a3) # ffffffffc02ac410 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc0201c6a:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c6e:	6394                	ld	a3,0(a5)
ffffffffc0201c70:	068a                	slli	a3,a3,0x2
ffffffffc0201c72:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201c74:	0ce6f063          	bleu	a4,a3,ffffffffc0201d34 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c78:	67a2                	ld	a5,8(sp)
ffffffffc0201c7a:	000c3503          	ld	a0,0(s8)
ffffffffc0201c7e:	8e9d                	sub	a3,a3,a5
ffffffffc0201c80:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0201c82:	8699                	srai	a3,a3,0x6
ffffffffc0201c84:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0201c86:	57fd                	li	a5,-1
ffffffffc0201c88:	83b1                	srli	a5,a5,0xc
ffffffffc0201c8a:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c8c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201c8e:	2ee7f763          	bleu	a4,a5,ffffffffc0201f7c <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc0201c92:	000ab797          	auipc	a5,0xab
ffffffffc0201c96:	87e78793          	addi	a5,a5,-1922 # ffffffffc02ac510 <va_pa_offset>
ffffffffc0201c9a:	639c                	ld	a5,0(a5)
ffffffffc0201c9c:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c9e:	629c                	ld	a5,0(a3)
ffffffffc0201ca0:	078a                	slli	a5,a5,0x2
ffffffffc0201ca2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ca4:	08e7f863          	bleu	a4,a5,ffffffffc0201d34 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ca8:	69a2                	ld	s3,8(sp)
ffffffffc0201caa:	4585                	li	a1,1
ffffffffc0201cac:	413787b3          	sub	a5,a5,s3
ffffffffc0201cb0:	079a                	slli	a5,a5,0x6
ffffffffc0201cb2:	953e                	add	a0,a0,a5
ffffffffc0201cb4:	1db010ef          	jal	ra,ffffffffc020368e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201cb8:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201cbc:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201cc0:	078a                	slli	a5,a5,0x2
ffffffffc0201cc2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201cc4:	06e7f863          	bleu	a4,a5,ffffffffc0201d34 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0201cc8:	000c3503          	ld	a0,0(s8)
ffffffffc0201ccc:	413787b3          	sub	a5,a5,s3
ffffffffc0201cd0:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0201cd2:	4585                	li	a1,1
ffffffffc0201cd4:	953e                	add	a0,a0,a5
ffffffffc0201cd6:	1b9010ef          	jal	ra,ffffffffc020368e <free_pages>
     pgdir[0] = 0;
ffffffffc0201cda:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0201cde:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0201ce2:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201ce4:	00878963          	beq	a5,s0,ffffffffc0201cf6 <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201ce8:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201cec:	679c                	ld	a5,8(a5)
ffffffffc0201cee:	397d                	addiw	s2,s2,-1
ffffffffc0201cf0:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201cf2:	fe879be3          	bne	a5,s0,ffffffffc0201ce8 <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc0201cf6:	28091f63          	bnez	s2,ffffffffc0201f94 <swap_init+0x6a0>
     assert(total==0);
ffffffffc0201cfa:	2a049d63          	bnez	s1,ffffffffc0201fb4 <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0201cfe:	00006517          	auipc	a0,0x6
ffffffffc0201d02:	9fa50513          	addi	a0,a0,-1542 # ffffffffc02076f8 <commands+0xf70>
ffffffffc0201d06:	bcafe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0201d0a:	b92d                	j	ffffffffc0201944 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0201d0c:	4481                	li	s1,0
ffffffffc0201d0e:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201d10:	4981                	li	s3,0
ffffffffc0201d12:	b17d                	j	ffffffffc02019c0 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0201d14:	00005697          	auipc	a3,0x5
ffffffffc0201d18:	76c68693          	addi	a3,a3,1900 # ffffffffc0207480 <commands+0xcf8>
ffffffffc0201d1c:	00005617          	auipc	a2,0x5
ffffffffc0201d20:	eec60613          	addi	a2,a2,-276 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201d24:	0bc00593          	li	a1,188
ffffffffc0201d28:	00005517          	auipc	a0,0x5
ffffffffc0201d2c:	73050513          	addi	a0,a0,1840 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201d30:	ce6fe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201d34:	00005617          	auipc	a2,0x5
ffffffffc0201d38:	5ec60613          	addi	a2,a2,1516 # ffffffffc0207320 <commands+0xb98>
ffffffffc0201d3c:	06200593          	li	a1,98
ffffffffc0201d40:	00005517          	auipc	a0,0x5
ffffffffc0201d44:	60050513          	addi	a0,a0,1536 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0201d48:	ccefe0ef          	jal	ra,ffffffffc0200216 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201d4c:	00006697          	auipc	a3,0x6
ffffffffc0201d50:	93468693          	addi	a3,a3,-1740 # ffffffffc0207680 <commands+0xef8>
ffffffffc0201d54:	00005617          	auipc	a2,0x5
ffffffffc0201d58:	eb460613          	addi	a2,a2,-332 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201d5c:	0fc00593          	li	a1,252
ffffffffc0201d60:	00005517          	auipc	a0,0x5
ffffffffc0201d64:	6f850513          	addi	a0,a0,1784 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201d68:	caefe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201d6c:	00006617          	auipc	a2,0x6
ffffffffc0201d70:	8ec60613          	addi	a2,a2,-1812 # ffffffffc0207658 <commands+0xed0>
ffffffffc0201d74:	07400593          	li	a1,116
ffffffffc0201d78:	00005517          	auipc	a0,0x5
ffffffffc0201d7c:	5c850513          	addi	a0,a0,1480 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0201d80:	c96fe0ef          	jal	ra,ffffffffc0200216 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0201d84:	00005697          	auipc	a3,0x5
ffffffffc0201d88:	7fc68693          	addi	a3,a3,2044 # ffffffffc0207580 <commands+0xdf8>
ffffffffc0201d8c:	00005617          	auipc	a2,0x5
ffffffffc0201d90:	e7c60613          	addi	a2,a2,-388 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201d94:	0dd00593          	li	a1,221
ffffffffc0201d98:	00005517          	auipc	a0,0x5
ffffffffc0201d9c:	6c050513          	addi	a0,a0,1728 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201da0:	c76fe0ef          	jal	ra,ffffffffc0200216 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0201da4:	00005697          	auipc	a3,0x5
ffffffffc0201da8:	7c468693          	addi	a3,a3,1988 # ffffffffc0207568 <commands+0xde0>
ffffffffc0201dac:	00005617          	auipc	a2,0x5
ffffffffc0201db0:	e5c60613          	addi	a2,a2,-420 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201db4:	0dc00593          	li	a1,220
ffffffffc0201db8:	00005517          	auipc	a0,0x5
ffffffffc0201dbc:	6a050513          	addi	a0,a0,1696 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201dc0:	c56fe0ef          	jal	ra,ffffffffc0200216 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0201dc4:	00006697          	auipc	a3,0x6
ffffffffc0201dc8:	87c68693          	addi	a3,a3,-1924 # ffffffffc0207640 <commands+0xeb8>
ffffffffc0201dcc:	00005617          	auipc	a2,0x5
ffffffffc0201dd0:	e3c60613          	addi	a2,a2,-452 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201dd4:	0fb00593          	li	a1,251
ffffffffc0201dd8:	00005517          	auipc	a0,0x5
ffffffffc0201ddc:	68050513          	addi	a0,a0,1664 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201de0:	c36fe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0201de4:	00005617          	auipc	a2,0x5
ffffffffc0201de8:	65460613          	addi	a2,a2,1620 # ffffffffc0207438 <commands+0xcb0>
ffffffffc0201dec:	02800593          	li	a1,40
ffffffffc0201df0:	00005517          	auipc	a0,0x5
ffffffffc0201df4:	66850513          	addi	a0,a0,1640 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201df8:	c1efe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==2);
ffffffffc0201dfc:	00006697          	auipc	a3,0x6
ffffffffc0201e00:	80468693          	addi	a3,a3,-2044 # ffffffffc0207600 <commands+0xe78>
ffffffffc0201e04:	00005617          	auipc	a2,0x5
ffffffffc0201e08:	e0460613          	addi	a2,a2,-508 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201e0c:	09700593          	li	a1,151
ffffffffc0201e10:	00005517          	auipc	a0,0x5
ffffffffc0201e14:	64850513          	addi	a0,a0,1608 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201e18:	bfefe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==2);
ffffffffc0201e1c:	00005697          	auipc	a3,0x5
ffffffffc0201e20:	7e468693          	addi	a3,a3,2020 # ffffffffc0207600 <commands+0xe78>
ffffffffc0201e24:	00005617          	auipc	a2,0x5
ffffffffc0201e28:	de460613          	addi	a2,a2,-540 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201e2c:	09900593          	li	a1,153
ffffffffc0201e30:	00005517          	auipc	a0,0x5
ffffffffc0201e34:	62850513          	addi	a0,a0,1576 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201e38:	bdefe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==3);
ffffffffc0201e3c:	00005697          	auipc	a3,0x5
ffffffffc0201e40:	7d468693          	addi	a3,a3,2004 # ffffffffc0207610 <commands+0xe88>
ffffffffc0201e44:	00005617          	auipc	a2,0x5
ffffffffc0201e48:	dc460613          	addi	a2,a2,-572 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201e4c:	09b00593          	li	a1,155
ffffffffc0201e50:	00005517          	auipc	a0,0x5
ffffffffc0201e54:	60850513          	addi	a0,a0,1544 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201e58:	bbefe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==3);
ffffffffc0201e5c:	00005697          	auipc	a3,0x5
ffffffffc0201e60:	7b468693          	addi	a3,a3,1972 # ffffffffc0207610 <commands+0xe88>
ffffffffc0201e64:	00005617          	auipc	a2,0x5
ffffffffc0201e68:	da460613          	addi	a2,a2,-604 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201e6c:	09d00593          	li	a1,157
ffffffffc0201e70:	00005517          	auipc	a0,0x5
ffffffffc0201e74:	5e850513          	addi	a0,a0,1512 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201e78:	b9efe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==1);
ffffffffc0201e7c:	00005697          	auipc	a3,0x5
ffffffffc0201e80:	77468693          	addi	a3,a3,1908 # ffffffffc02075f0 <commands+0xe68>
ffffffffc0201e84:	00005617          	auipc	a2,0x5
ffffffffc0201e88:	d8460613          	addi	a2,a2,-636 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201e8c:	09300593          	li	a1,147
ffffffffc0201e90:	00005517          	auipc	a0,0x5
ffffffffc0201e94:	5c850513          	addi	a0,a0,1480 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201e98:	b7efe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==1);
ffffffffc0201e9c:	00005697          	auipc	a3,0x5
ffffffffc0201ea0:	75468693          	addi	a3,a3,1876 # ffffffffc02075f0 <commands+0xe68>
ffffffffc0201ea4:	00005617          	auipc	a2,0x5
ffffffffc0201ea8:	d6460613          	addi	a2,a2,-668 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201eac:	09500593          	li	a1,149
ffffffffc0201eb0:	00005517          	auipc	a0,0x5
ffffffffc0201eb4:	5a850513          	addi	a0,a0,1448 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201eb8:	b5efe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==4);
ffffffffc0201ebc:	00005697          	auipc	a3,0x5
ffffffffc0201ec0:	76468693          	addi	a3,a3,1892 # ffffffffc0207620 <commands+0xe98>
ffffffffc0201ec4:	00005617          	auipc	a2,0x5
ffffffffc0201ec8:	d4460613          	addi	a2,a2,-700 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201ecc:	09f00593          	li	a1,159
ffffffffc0201ed0:	00005517          	auipc	a0,0x5
ffffffffc0201ed4:	58850513          	addi	a0,a0,1416 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201ed8:	b3efe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==4);
ffffffffc0201edc:	00005697          	auipc	a3,0x5
ffffffffc0201ee0:	74468693          	addi	a3,a3,1860 # ffffffffc0207620 <commands+0xe98>
ffffffffc0201ee4:	00005617          	auipc	a2,0x5
ffffffffc0201ee8:	d2460613          	addi	a2,a2,-732 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201eec:	0a100593          	li	a1,161
ffffffffc0201ef0:	00005517          	auipc	a0,0x5
ffffffffc0201ef4:	56850513          	addi	a0,a0,1384 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201ef8:	b1efe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201efc:	00005697          	auipc	a3,0x5
ffffffffc0201f00:	3e468693          	addi	a3,a3,996 # ffffffffc02072e0 <commands+0xb58>
ffffffffc0201f04:	00005617          	auipc	a2,0x5
ffffffffc0201f08:	d0460613          	addi	a2,a2,-764 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201f0c:	0cc00593          	li	a1,204
ffffffffc0201f10:	00005517          	auipc	a0,0x5
ffffffffc0201f14:	54850513          	addi	a0,a0,1352 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201f18:	afefe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(vma != NULL);
ffffffffc0201f1c:	00005697          	auipc	a3,0x5
ffffffffc0201f20:	4bc68693          	addi	a3,a3,1212 # ffffffffc02073d8 <commands+0xc50>
ffffffffc0201f24:	00005617          	auipc	a2,0x5
ffffffffc0201f28:	ce460613          	addi	a2,a2,-796 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201f2c:	0cf00593          	li	a1,207
ffffffffc0201f30:	00005517          	auipc	a0,0x5
ffffffffc0201f34:	52850513          	addi	a0,a0,1320 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201f38:	adefe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0201f3c:	00005697          	auipc	a3,0x5
ffffffffc0201f40:	5ec68693          	addi	a3,a3,1516 # ffffffffc0207528 <commands+0xda0>
ffffffffc0201f44:	00005617          	auipc	a2,0x5
ffffffffc0201f48:	cc460613          	addi	a2,a2,-828 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201f4c:	0d700593          	li	a1,215
ffffffffc0201f50:	00005517          	auipc	a0,0x5
ffffffffc0201f54:	50850513          	addi	a0,a0,1288 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201f58:	abefe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert( nr_free == 0);         
ffffffffc0201f5c:	00005697          	auipc	a3,0x5
ffffffffc0201f60:	6d468693          	addi	a3,a3,1748 # ffffffffc0207630 <commands+0xea8>
ffffffffc0201f64:	00005617          	auipc	a2,0x5
ffffffffc0201f68:	ca460613          	addi	a2,a2,-860 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201f6c:	0f300593          	li	a1,243
ffffffffc0201f70:	00005517          	auipc	a0,0x5
ffffffffc0201f74:	4e850513          	addi	a0,a0,1256 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201f78:	a9efe0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201f7c:	00005617          	auipc	a2,0x5
ffffffffc0201f80:	3d460613          	addi	a2,a2,980 # ffffffffc0207350 <commands+0xbc8>
ffffffffc0201f84:	06900593          	li	a1,105
ffffffffc0201f88:	00005517          	auipc	a0,0x5
ffffffffc0201f8c:	3b850513          	addi	a0,a0,952 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0201f90:	a86fe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(count==0);
ffffffffc0201f94:	00005697          	auipc	a3,0x5
ffffffffc0201f98:	74468693          	addi	a3,a3,1860 # ffffffffc02076d8 <commands+0xf50>
ffffffffc0201f9c:	00005617          	auipc	a2,0x5
ffffffffc0201fa0:	c6c60613          	addi	a2,a2,-916 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201fa4:	11d00593          	li	a1,285
ffffffffc0201fa8:	00005517          	auipc	a0,0x5
ffffffffc0201fac:	4b050513          	addi	a0,a0,1200 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201fb0:	a66fe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(total==0);
ffffffffc0201fb4:	00005697          	auipc	a3,0x5
ffffffffc0201fb8:	73468693          	addi	a3,a3,1844 # ffffffffc02076e8 <commands+0xf60>
ffffffffc0201fbc:	00005617          	auipc	a2,0x5
ffffffffc0201fc0:	c4c60613          	addi	a2,a2,-948 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201fc4:	11e00593          	li	a1,286
ffffffffc0201fc8:	00005517          	auipc	a0,0x5
ffffffffc0201fcc:	49050513          	addi	a0,a0,1168 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201fd0:	a46fe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201fd4:	00005697          	auipc	a3,0x5
ffffffffc0201fd8:	5cc68693          	addi	a3,a3,1484 # ffffffffc02075a0 <commands+0xe18>
ffffffffc0201fdc:	00005617          	auipc	a2,0x5
ffffffffc0201fe0:	c2c60613          	addi	a2,a2,-980 # ffffffffc0206c08 <commands+0x480>
ffffffffc0201fe4:	0ea00593          	li	a1,234
ffffffffc0201fe8:	00005517          	auipc	a0,0x5
ffffffffc0201fec:	47050513          	addi	a0,a0,1136 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0201ff0:	a26fe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(mm != NULL);
ffffffffc0201ff4:	00005697          	auipc	a3,0x5
ffffffffc0201ff8:	16468693          	addi	a3,a3,356 # ffffffffc0207158 <commands+0x9d0>
ffffffffc0201ffc:	00005617          	auipc	a2,0x5
ffffffffc0202000:	c0c60613          	addi	a2,a2,-1012 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202004:	0c400593          	li	a1,196
ffffffffc0202008:	00005517          	auipc	a0,0x5
ffffffffc020200c:	45050513          	addi	a0,a0,1104 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0202010:	a06fe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202014:	00005697          	auipc	a3,0x5
ffffffffc0202018:	4c468693          	addi	a3,a3,1220 # ffffffffc02074d8 <commands+0xd50>
ffffffffc020201c:	00005617          	auipc	a2,0x5
ffffffffc0202020:	bec60613          	addi	a2,a2,-1044 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202024:	0c700593          	li	a1,199
ffffffffc0202028:	00005517          	auipc	a0,0x5
ffffffffc020202c:	43050513          	addi	a0,a0,1072 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0202030:	9e6fe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(ret==0);
ffffffffc0202034:	00005697          	auipc	a3,0x5
ffffffffc0202038:	69c68693          	addi	a3,a3,1692 # ffffffffc02076d0 <commands+0xf48>
ffffffffc020203c:	00005617          	auipc	a2,0x5
ffffffffc0202040:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202044:	10200593          	li	a1,258
ffffffffc0202048:	00005517          	auipc	a0,0x5
ffffffffc020204c:	41050513          	addi	a0,a0,1040 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0202050:	9c6fe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202054:	00005697          	auipc	a3,0x5
ffffffffc0202058:	43c68693          	addi	a3,a3,1084 # ffffffffc0207490 <commands+0xd08>
ffffffffc020205c:	00005617          	auipc	a2,0x5
ffffffffc0202060:	bac60613          	addi	a2,a2,-1108 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202064:	0bf00593          	li	a1,191
ffffffffc0202068:	00005517          	auipc	a0,0x5
ffffffffc020206c:	3f050513          	addi	a0,a0,1008 # ffffffffc0207458 <commands+0xcd0>
ffffffffc0202070:	9a6fe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202074 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202074:	000aa797          	auipc	a5,0xaa
ffffffffc0202078:	34c78793          	addi	a5,a5,844 # ffffffffc02ac3c0 <sm>
ffffffffc020207c:	639c                	ld	a5,0(a5)
ffffffffc020207e:	0107b303          	ld	t1,16(a5)
ffffffffc0202082:	8302                	jr	t1

ffffffffc0202084 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202084:	000aa797          	auipc	a5,0xaa
ffffffffc0202088:	33c78793          	addi	a5,a5,828 # ffffffffc02ac3c0 <sm>
ffffffffc020208c:	639c                	ld	a5,0(a5)
ffffffffc020208e:	0207b303          	ld	t1,32(a5)
ffffffffc0202092:	8302                	jr	t1

ffffffffc0202094 <swap_out>:
{
ffffffffc0202094:	711d                	addi	sp,sp,-96
ffffffffc0202096:	ec86                	sd	ra,88(sp)
ffffffffc0202098:	e8a2                	sd	s0,80(sp)
ffffffffc020209a:	e4a6                	sd	s1,72(sp)
ffffffffc020209c:	e0ca                	sd	s2,64(sp)
ffffffffc020209e:	fc4e                	sd	s3,56(sp)
ffffffffc02020a0:	f852                	sd	s4,48(sp)
ffffffffc02020a2:	f456                	sd	s5,40(sp)
ffffffffc02020a4:	f05a                	sd	s6,32(sp)
ffffffffc02020a6:	ec5e                	sd	s7,24(sp)
ffffffffc02020a8:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02020aa:	cde9                	beqz	a1,ffffffffc0202184 <swap_out+0xf0>
ffffffffc02020ac:	8ab2                	mv	s5,a2
ffffffffc02020ae:	892a                	mv	s2,a0
ffffffffc02020b0:	8a2e                	mv	s4,a1
ffffffffc02020b2:	4401                	li	s0,0
ffffffffc02020b4:	000aa997          	auipc	s3,0xaa
ffffffffc02020b8:	30c98993          	addi	s3,s3,780 # ffffffffc02ac3c0 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02020bc:	00005b17          	auipc	s6,0x5
ffffffffc02020c0:	6bcb0b13          	addi	s6,s6,1724 # ffffffffc0207778 <commands+0xff0>
                    cprintf("SWAP: failed to save\n");
ffffffffc02020c4:	00005b97          	auipc	s7,0x5
ffffffffc02020c8:	69cb8b93          	addi	s7,s7,1692 # ffffffffc0207760 <commands+0xfd8>
ffffffffc02020cc:	a825                	j	ffffffffc0202104 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02020ce:	67a2                	ld	a5,8(sp)
ffffffffc02020d0:	8626                	mv	a2,s1
ffffffffc02020d2:	85a2                	mv	a1,s0
ffffffffc02020d4:	7f94                	ld	a3,56(a5)
ffffffffc02020d6:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc02020d8:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02020da:	82b1                	srli	a3,a3,0xc
ffffffffc02020dc:	0685                	addi	a3,a3,1
ffffffffc02020de:	ff3fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02020e2:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc02020e4:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02020e6:	7d1c                	ld	a5,56(a0)
ffffffffc02020e8:	83b1                	srli	a5,a5,0xc
ffffffffc02020ea:	0785                	addi	a5,a5,1
ffffffffc02020ec:	07a2                	slli	a5,a5,0x8
ffffffffc02020ee:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc02020f2:	59c010ef          	jal	ra,ffffffffc020368e <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc02020f6:	01893503          	ld	a0,24(s2)
ffffffffc02020fa:	85a6                	mv	a1,s1
ffffffffc02020fc:	191020ef          	jal	ra,ffffffffc0204a8c <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202100:	048a0d63          	beq	s4,s0,ffffffffc020215a <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202104:	0009b783          	ld	a5,0(s3)
ffffffffc0202108:	8656                	mv	a2,s5
ffffffffc020210a:	002c                	addi	a1,sp,8
ffffffffc020210c:	7b9c                	ld	a5,48(a5)
ffffffffc020210e:	854a                	mv	a0,s2
ffffffffc0202110:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202112:	e12d                	bnez	a0,ffffffffc0202174 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202114:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202116:	01893503          	ld	a0,24(s2)
ffffffffc020211a:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc020211c:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020211e:	85a6                	mv	a1,s1
ffffffffc0202120:	5f4010ef          	jal	ra,ffffffffc0203714 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202124:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202126:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202128:	8b85                	andi	a5,a5,1
ffffffffc020212a:	cfb9                	beqz	a5,ffffffffc0202188 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc020212c:	65a2                	ld	a1,8(sp)
ffffffffc020212e:	7d9c                	ld	a5,56(a1)
ffffffffc0202130:	83b1                	srli	a5,a5,0xc
ffffffffc0202132:	00178513          	addi	a0,a5,1
ffffffffc0202136:	0522                	slli	a0,a0,0x8
ffffffffc0202138:	2bf020ef          	jal	ra,ffffffffc0204bf6 <swapfs_write>
ffffffffc020213c:	d949                	beqz	a0,ffffffffc02020ce <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc020213e:	855e                	mv	a0,s7
ffffffffc0202140:	f91fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202144:	0009b783          	ld	a5,0(s3)
ffffffffc0202148:	6622                	ld	a2,8(sp)
ffffffffc020214a:	4681                	li	a3,0
ffffffffc020214c:	739c                	ld	a5,32(a5)
ffffffffc020214e:	85a6                	mv	a1,s1
ffffffffc0202150:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202152:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202154:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202156:	fa8a17e3          	bne	s4,s0,ffffffffc0202104 <swap_out+0x70>
}
ffffffffc020215a:	8522                	mv	a0,s0
ffffffffc020215c:	60e6                	ld	ra,88(sp)
ffffffffc020215e:	6446                	ld	s0,80(sp)
ffffffffc0202160:	64a6                	ld	s1,72(sp)
ffffffffc0202162:	6906                	ld	s2,64(sp)
ffffffffc0202164:	79e2                	ld	s3,56(sp)
ffffffffc0202166:	7a42                	ld	s4,48(sp)
ffffffffc0202168:	7aa2                	ld	s5,40(sp)
ffffffffc020216a:	7b02                	ld	s6,32(sp)
ffffffffc020216c:	6be2                	ld	s7,24(sp)
ffffffffc020216e:	6c42                	ld	s8,16(sp)
ffffffffc0202170:	6125                	addi	sp,sp,96
ffffffffc0202172:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202174:	85a2                	mv	a1,s0
ffffffffc0202176:	00005517          	auipc	a0,0x5
ffffffffc020217a:	5a250513          	addi	a0,a0,1442 # ffffffffc0207718 <commands+0xf90>
ffffffffc020217e:	f53fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                  break;
ffffffffc0202182:	bfe1                	j	ffffffffc020215a <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202184:	4401                	li	s0,0
ffffffffc0202186:	bfd1                	j	ffffffffc020215a <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202188:	00005697          	auipc	a3,0x5
ffffffffc020218c:	5c068693          	addi	a3,a3,1472 # ffffffffc0207748 <commands+0xfc0>
ffffffffc0202190:	00005617          	auipc	a2,0x5
ffffffffc0202194:	a7860613          	addi	a2,a2,-1416 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202198:	06800593          	li	a1,104
ffffffffc020219c:	00005517          	auipc	a0,0x5
ffffffffc02021a0:	2bc50513          	addi	a0,a0,700 # ffffffffc0207458 <commands+0xcd0>
ffffffffc02021a4:	872fe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02021a8 <swap_in>:
{
ffffffffc02021a8:	7179                	addi	sp,sp,-48
ffffffffc02021aa:	e84a                	sd	s2,16(sp)
ffffffffc02021ac:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02021ae:	4505                	li	a0,1
{
ffffffffc02021b0:	ec26                	sd	s1,24(sp)
ffffffffc02021b2:	e44e                	sd	s3,8(sp)
ffffffffc02021b4:	f406                	sd	ra,40(sp)
ffffffffc02021b6:	f022                	sd	s0,32(sp)
ffffffffc02021b8:	84ae                	mv	s1,a1
ffffffffc02021ba:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02021bc:	44a010ef          	jal	ra,ffffffffc0203606 <alloc_pages>
     assert(result!=NULL);
ffffffffc02021c0:	c129                	beqz	a0,ffffffffc0202202 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02021c2:	842a                	mv	s0,a0
ffffffffc02021c4:	01893503          	ld	a0,24(s2)
ffffffffc02021c8:	4601                	li	a2,0
ffffffffc02021ca:	85a6                	mv	a1,s1
ffffffffc02021cc:	548010ef          	jal	ra,ffffffffc0203714 <get_pte>
ffffffffc02021d0:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc02021d2:	6108                	ld	a0,0(a0)
ffffffffc02021d4:	85a2                	mv	a1,s0
ffffffffc02021d6:	189020ef          	jal	ra,ffffffffc0204b5e <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc02021da:	00093583          	ld	a1,0(s2)
ffffffffc02021de:	8626                	mv	a2,s1
ffffffffc02021e0:	00005517          	auipc	a0,0x5
ffffffffc02021e4:	21850513          	addi	a0,a0,536 # ffffffffc02073f8 <commands+0xc70>
ffffffffc02021e8:	81a1                	srli	a1,a1,0x8
ffffffffc02021ea:	ee7fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc02021ee:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc02021f0:	0089b023          	sd	s0,0(s3)
}
ffffffffc02021f4:	7402                	ld	s0,32(sp)
ffffffffc02021f6:	64e2                	ld	s1,24(sp)
ffffffffc02021f8:	6942                	ld	s2,16(sp)
ffffffffc02021fa:	69a2                	ld	s3,8(sp)
ffffffffc02021fc:	4501                	li	a0,0
ffffffffc02021fe:	6145                	addi	sp,sp,48
ffffffffc0202200:	8082                	ret
     assert(result!=NULL);
ffffffffc0202202:	00005697          	auipc	a3,0x5
ffffffffc0202206:	1e668693          	addi	a3,a3,486 # ffffffffc02073e8 <commands+0xc60>
ffffffffc020220a:	00005617          	auipc	a2,0x5
ffffffffc020220e:	9fe60613          	addi	a2,a2,-1538 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202212:	07e00593          	li	a1,126
ffffffffc0202216:	00005517          	auipc	a0,0x5
ffffffffc020221a:	24250513          	addi	a0,a0,578 # ffffffffc0207458 <commands+0xcd0>
ffffffffc020221e:	ff9fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202222 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0202222:	c125                	beqz	a0,ffffffffc0202282 <slob_free+0x60>
		return;

	if (size)
ffffffffc0202224:	e1a5                	bnez	a1,ffffffffc0202284 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202226:	100027f3          	csrr	a5,sstatus
ffffffffc020222a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020222c:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020222e:	e3bd                	bnez	a5,ffffffffc0202294 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202230:	0009f797          	auipc	a5,0x9f
ffffffffc0202234:	d6878793          	addi	a5,a5,-664 # ffffffffc02a0f98 <slobfree>
ffffffffc0202238:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020223a:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020223c:	00a7fa63          	bleu	a0,a5,ffffffffc0202250 <slob_free+0x2e>
ffffffffc0202240:	00e56c63          	bltu	a0,a4,ffffffffc0202258 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202244:	00e7fa63          	bleu	a4,a5,ffffffffc0202258 <slob_free+0x36>
    return 0;
ffffffffc0202248:	87ba                	mv	a5,a4
ffffffffc020224a:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020224c:	fea7eae3          	bltu	a5,a0,ffffffffc0202240 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202250:	fee7ece3          	bltu	a5,a4,ffffffffc0202248 <slob_free+0x26>
ffffffffc0202254:	fee57ae3          	bleu	a4,a0,ffffffffc0202248 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc0202258:	4110                	lw	a2,0(a0)
ffffffffc020225a:	00461693          	slli	a3,a2,0x4
ffffffffc020225e:	96aa                	add	a3,a3,a0
ffffffffc0202260:	08d70b63          	beq	a4,a3,ffffffffc02022f6 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0202264:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc0202266:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0202268:	00469713          	slli	a4,a3,0x4
ffffffffc020226c:	973e                	add	a4,a4,a5
ffffffffc020226e:	08e50f63          	beq	a0,a4,ffffffffc020230c <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0202272:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc0202274:	0009f717          	auipc	a4,0x9f
ffffffffc0202278:	d2f73223          	sd	a5,-732(a4) # ffffffffc02a0f98 <slobfree>
    if (flag) {
ffffffffc020227c:	c199                	beqz	a1,ffffffffc0202282 <slob_free+0x60>
        intr_enable();
ffffffffc020227e:	bd8fe06f          	j	ffffffffc0200656 <intr_enable>
ffffffffc0202282:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0202284:	05bd                	addi	a1,a1,15
ffffffffc0202286:	8191                	srli	a1,a1,0x4
ffffffffc0202288:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020228a:	100027f3          	csrr	a5,sstatus
ffffffffc020228e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0202290:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202292:	dfd9                	beqz	a5,ffffffffc0202230 <slob_free+0xe>
{
ffffffffc0202294:	1101                	addi	sp,sp,-32
ffffffffc0202296:	e42a                	sd	a0,8(sp)
ffffffffc0202298:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020229a:	bc2fe0ef          	jal	ra,ffffffffc020065c <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020229e:	0009f797          	auipc	a5,0x9f
ffffffffc02022a2:	cfa78793          	addi	a5,a5,-774 # ffffffffc02a0f98 <slobfree>
ffffffffc02022a6:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc02022a8:	6522                	ld	a0,8(sp)
ffffffffc02022aa:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02022ac:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02022ae:	00a7fa63          	bleu	a0,a5,ffffffffc02022c2 <slob_free+0xa0>
ffffffffc02022b2:	00e56c63          	bltu	a0,a4,ffffffffc02022ca <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02022b6:	00e7fa63          	bleu	a4,a5,ffffffffc02022ca <slob_free+0xa8>
    return 0;
ffffffffc02022ba:	87ba                	mv	a5,a4
ffffffffc02022bc:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02022be:	fea7eae3          	bltu	a5,a0,ffffffffc02022b2 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02022c2:	fee7ece3          	bltu	a5,a4,ffffffffc02022ba <slob_free+0x98>
ffffffffc02022c6:	fee57ae3          	bleu	a4,a0,ffffffffc02022ba <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc02022ca:	4110                	lw	a2,0(a0)
ffffffffc02022cc:	00461693          	slli	a3,a2,0x4
ffffffffc02022d0:	96aa                	add	a3,a3,a0
ffffffffc02022d2:	04d70763          	beq	a4,a3,ffffffffc0202320 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc02022d6:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02022d8:	4394                	lw	a3,0(a5)
ffffffffc02022da:	00469713          	slli	a4,a3,0x4
ffffffffc02022de:	973e                	add	a4,a4,a5
ffffffffc02022e0:	04e50663          	beq	a0,a4,ffffffffc020232c <slob_free+0x10a>
		cur->next = b;
ffffffffc02022e4:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc02022e6:	0009f717          	auipc	a4,0x9f
ffffffffc02022ea:	caf73923          	sd	a5,-846(a4) # ffffffffc02a0f98 <slobfree>
    if (flag) {
ffffffffc02022ee:	e58d                	bnez	a1,ffffffffc0202318 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02022f0:	60e2                	ld	ra,24(sp)
ffffffffc02022f2:	6105                	addi	sp,sp,32
ffffffffc02022f4:	8082                	ret
		b->units += cur->next->units;
ffffffffc02022f6:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02022f8:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc02022fa:	9e35                	addw	a2,a2,a3
ffffffffc02022fc:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc02022fe:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0202300:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0202302:	00469713          	slli	a4,a3,0x4
ffffffffc0202306:	973e                	add	a4,a4,a5
ffffffffc0202308:	f6e515e3          	bne	a0,a4,ffffffffc0202272 <slob_free+0x50>
		cur->units += b->units;
ffffffffc020230c:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc020230e:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0202310:	9eb9                	addw	a3,a3,a4
ffffffffc0202312:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0202314:	e790                	sd	a2,8(a5)
ffffffffc0202316:	bfb9                	j	ffffffffc0202274 <slob_free+0x52>
}
ffffffffc0202318:	60e2                	ld	ra,24(sp)
ffffffffc020231a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020231c:	b3afe06f          	j	ffffffffc0200656 <intr_enable>
		b->units += cur->next->units;
ffffffffc0202320:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0202322:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0202324:	9e35                	addw	a2,a2,a3
ffffffffc0202326:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0202328:	e518                	sd	a4,8(a0)
ffffffffc020232a:	b77d                	j	ffffffffc02022d8 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc020232c:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc020232e:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0202330:	9eb9                	addw	a3,a3,a4
ffffffffc0202332:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0202334:	e790                	sd	a2,8(a5)
ffffffffc0202336:	bf45                	j	ffffffffc02022e6 <slob_free+0xc4>

ffffffffc0202338 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202338:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020233a:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc020233c:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202340:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202342:	2c4010ef          	jal	ra,ffffffffc0203606 <alloc_pages>
  if(!page)
ffffffffc0202346:	c139                	beqz	a0,ffffffffc020238c <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0202348:	000aa797          	auipc	a5,0xaa
ffffffffc020234c:	1d878793          	addi	a5,a5,472 # ffffffffc02ac520 <pages>
ffffffffc0202350:	6394                	ld	a3,0(a5)
ffffffffc0202352:	00007797          	auipc	a5,0x7
ffffffffc0202356:	9be78793          	addi	a5,a5,-1602 # ffffffffc0208d10 <nbase>
    return KADDR(page2pa(page));
ffffffffc020235a:	000aa717          	auipc	a4,0xaa
ffffffffc020235e:	08670713          	addi	a4,a4,134 # ffffffffc02ac3e0 <npage>
    return page - pages + nbase;
ffffffffc0202362:	40d506b3          	sub	a3,a0,a3
ffffffffc0202366:	6388                	ld	a0,0(a5)
ffffffffc0202368:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020236a:	57fd                	li	a5,-1
ffffffffc020236c:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc020236e:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0202370:	83b1                	srli	a5,a5,0xc
ffffffffc0202372:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202374:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202376:	00e7ff63          	bleu	a4,a5,ffffffffc0202394 <__slob_get_free_pages.isra.0+0x5c>
ffffffffc020237a:	000aa797          	auipc	a5,0xaa
ffffffffc020237e:	19678793          	addi	a5,a5,406 # ffffffffc02ac510 <va_pa_offset>
ffffffffc0202382:	6388                	ld	a0,0(a5)
}
ffffffffc0202384:	60a2                	ld	ra,8(sp)
ffffffffc0202386:	9536                	add	a0,a0,a3
ffffffffc0202388:	0141                	addi	sp,sp,16
ffffffffc020238a:	8082                	ret
ffffffffc020238c:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc020238e:	4501                	li	a0,0
}
ffffffffc0202390:	0141                	addi	sp,sp,16
ffffffffc0202392:	8082                	ret
ffffffffc0202394:	00005617          	auipc	a2,0x5
ffffffffc0202398:	fbc60613          	addi	a2,a2,-68 # ffffffffc0207350 <commands+0xbc8>
ffffffffc020239c:	06900593          	li	a1,105
ffffffffc02023a0:	00005517          	auipc	a0,0x5
ffffffffc02023a4:	fa050513          	addi	a0,a0,-96 # ffffffffc0207340 <commands+0xbb8>
ffffffffc02023a8:	e6ffd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02023ac <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02023ac:	7179                	addi	sp,sp,-48
ffffffffc02023ae:	f406                	sd	ra,40(sp)
ffffffffc02023b0:	f022                	sd	s0,32(sp)
ffffffffc02023b2:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02023b4:	01050713          	addi	a4,a0,16
ffffffffc02023b8:	6785                	lui	a5,0x1
ffffffffc02023ba:	0cf77b63          	bleu	a5,a4,ffffffffc0202490 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02023be:	00f50413          	addi	s0,a0,15
ffffffffc02023c2:	8011                	srli	s0,s0,0x4
ffffffffc02023c4:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02023c6:	10002673          	csrr	a2,sstatus
ffffffffc02023ca:	8a09                	andi	a2,a2,2
ffffffffc02023cc:	ea5d                	bnez	a2,ffffffffc0202482 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc02023ce:	0009f497          	auipc	s1,0x9f
ffffffffc02023d2:	bca48493          	addi	s1,s1,-1078 # ffffffffc02a0f98 <slobfree>
ffffffffc02023d6:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02023d8:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02023da:	4398                	lw	a4,0(a5)
ffffffffc02023dc:	0a875763          	ble	s0,a4,ffffffffc020248a <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc02023e0:	00f68a63          	beq	a3,a5,ffffffffc02023f4 <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02023e4:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02023e6:	4118                	lw	a4,0(a0)
ffffffffc02023e8:	02875763          	ble	s0,a4,ffffffffc0202416 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc02023ec:	6094                	ld	a3,0(s1)
ffffffffc02023ee:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc02023f0:	fef69ae3          	bne	a3,a5,ffffffffc02023e4 <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc02023f4:	ea39                	bnez	a2,ffffffffc020244a <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02023f6:	4501                	li	a0,0
ffffffffc02023f8:	f41ff0ef          	jal	ra,ffffffffc0202338 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc02023fc:	cd29                	beqz	a0,ffffffffc0202456 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc02023fe:	6585                	lui	a1,0x1
ffffffffc0202400:	e23ff0ef          	jal	ra,ffffffffc0202222 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202404:	10002673          	csrr	a2,sstatus
ffffffffc0202408:	8a09                	andi	a2,a2,2
ffffffffc020240a:	ea1d                	bnez	a2,ffffffffc0202440 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc020240c:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020240e:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202410:	4118                	lw	a4,0(a0)
ffffffffc0202412:	fc874de3          	blt	a4,s0,ffffffffc02023ec <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0202416:	04e40663          	beq	s0,a4,ffffffffc0202462 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc020241a:	00441693          	slli	a3,s0,0x4
ffffffffc020241e:	96aa                	add	a3,a3,a0
ffffffffc0202420:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0202422:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0202424:	9f01                	subw	a4,a4,s0
ffffffffc0202426:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0202428:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc020242a:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc020242c:	0009f717          	auipc	a4,0x9f
ffffffffc0202430:	b6f73623          	sd	a5,-1172(a4) # ffffffffc02a0f98 <slobfree>
    if (flag) {
ffffffffc0202434:	ee15                	bnez	a2,ffffffffc0202470 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0202436:	70a2                	ld	ra,40(sp)
ffffffffc0202438:	7402                	ld	s0,32(sp)
ffffffffc020243a:	64e2                	ld	s1,24(sp)
ffffffffc020243c:	6145                	addi	sp,sp,48
ffffffffc020243e:	8082                	ret
        intr_disable();
ffffffffc0202440:	a1cfe0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0202444:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0202446:	609c                	ld	a5,0(s1)
ffffffffc0202448:	b7d9                	j	ffffffffc020240e <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc020244a:	a0cfe0ef          	jal	ra,ffffffffc0200656 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc020244e:	4501                	li	a0,0
ffffffffc0202450:	ee9ff0ef          	jal	ra,ffffffffc0202338 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0202454:	f54d                	bnez	a0,ffffffffc02023fe <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc0202456:	70a2                	ld	ra,40(sp)
ffffffffc0202458:	7402                	ld	s0,32(sp)
ffffffffc020245a:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc020245c:	4501                	li	a0,0
}
ffffffffc020245e:	6145                	addi	sp,sp,48
ffffffffc0202460:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0202462:	6518                	ld	a4,8(a0)
ffffffffc0202464:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc0202466:	0009f717          	auipc	a4,0x9f
ffffffffc020246a:	b2f73923          	sd	a5,-1230(a4) # ffffffffc02a0f98 <slobfree>
    if (flag) {
ffffffffc020246e:	d661                	beqz	a2,ffffffffc0202436 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0202470:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202472:	9e4fe0ef          	jal	ra,ffffffffc0200656 <intr_enable>
}
ffffffffc0202476:	70a2                	ld	ra,40(sp)
ffffffffc0202478:	7402                	ld	s0,32(sp)
ffffffffc020247a:	6522                	ld	a0,8(sp)
ffffffffc020247c:	64e2                	ld	s1,24(sp)
ffffffffc020247e:	6145                	addi	sp,sp,48
ffffffffc0202480:	8082                	ret
        intr_disable();
ffffffffc0202482:	9dafe0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0202486:	4605                	li	a2,1
ffffffffc0202488:	b799                	j	ffffffffc02023ce <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020248a:	853e                	mv	a0,a5
ffffffffc020248c:	87b6                	mv	a5,a3
ffffffffc020248e:	b761                	j	ffffffffc0202416 <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0202490:	00005697          	auipc	a3,0x5
ffffffffc0202494:	37068693          	addi	a3,a3,880 # ffffffffc0207800 <commands+0x1078>
ffffffffc0202498:	00004617          	auipc	a2,0x4
ffffffffc020249c:	77060613          	addi	a2,a2,1904 # ffffffffc0206c08 <commands+0x480>
ffffffffc02024a0:	06400593          	li	a1,100
ffffffffc02024a4:	00005517          	auipc	a0,0x5
ffffffffc02024a8:	37c50513          	addi	a0,a0,892 # ffffffffc0207820 <commands+0x1098>
ffffffffc02024ac:	d6bfd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02024b0 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc02024b0:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc02024b2:	00005517          	auipc	a0,0x5
ffffffffc02024b6:	38650513          	addi	a0,a0,902 # ffffffffc0207838 <commands+0x10b0>
kmalloc_init(void) {
ffffffffc02024ba:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc02024bc:	c15fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02024c0:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02024c2:	00005517          	auipc	a0,0x5
ffffffffc02024c6:	31e50513          	addi	a0,a0,798 # ffffffffc02077e0 <commands+0x1058>
}
ffffffffc02024ca:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02024cc:	c05fd06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02024d0 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc02024d0:	4501                	li	a0,0
ffffffffc02024d2:	8082                	ret

ffffffffc02024d4 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02024d4:	1101                	addi	sp,sp,-32
ffffffffc02024d6:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02024d8:	6905                	lui	s2,0x1
{
ffffffffc02024da:	e822                	sd	s0,16(sp)
ffffffffc02024dc:	ec06                	sd	ra,24(sp)
ffffffffc02024de:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02024e0:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8581>
{
ffffffffc02024e4:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02024e6:	04a7fc63          	bleu	a0,a5,ffffffffc020253e <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02024ea:	4561                	li	a0,24
ffffffffc02024ec:	ec1ff0ef          	jal	ra,ffffffffc02023ac <slob_alloc.isra.1.constprop.3>
ffffffffc02024f0:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02024f2:	cd21                	beqz	a0,ffffffffc020254a <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc02024f4:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02024f8:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc02024fa:	00f95763          	ble	a5,s2,ffffffffc0202508 <kmalloc+0x34>
ffffffffc02024fe:	6705                	lui	a4,0x1
ffffffffc0202500:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0202502:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0202504:	fef74ee3          	blt	a4,a5,ffffffffc0202500 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0202508:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc020250a:	e2fff0ef          	jal	ra,ffffffffc0202338 <__slob_get_free_pages.isra.0>
ffffffffc020250e:	e488                	sd	a0,8(s1)
ffffffffc0202510:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0202512:	c935                	beqz	a0,ffffffffc0202586 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202514:	100027f3          	csrr	a5,sstatus
ffffffffc0202518:	8b89                	andi	a5,a5,2
ffffffffc020251a:	e3a1                	bnez	a5,ffffffffc020255a <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc020251c:	000aa797          	auipc	a5,0xaa
ffffffffc0202520:	eb478793          	addi	a5,a5,-332 # ffffffffc02ac3d0 <bigblocks>
ffffffffc0202524:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0202526:	000aa717          	auipc	a4,0xaa
ffffffffc020252a:	ea973523          	sd	s1,-342(a4) # ffffffffc02ac3d0 <bigblocks>
		bb->next = bigblocks;
ffffffffc020252e:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0202530:	8522                	mv	a0,s0
ffffffffc0202532:	60e2                	ld	ra,24(sp)
ffffffffc0202534:	6442                	ld	s0,16(sp)
ffffffffc0202536:	64a2                	ld	s1,8(sp)
ffffffffc0202538:	6902                	ld	s2,0(sp)
ffffffffc020253a:	6105                	addi	sp,sp,32
ffffffffc020253c:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc020253e:	0541                	addi	a0,a0,16
ffffffffc0202540:	e6dff0ef          	jal	ra,ffffffffc02023ac <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0202544:	01050413          	addi	s0,a0,16
ffffffffc0202548:	f565                	bnez	a0,ffffffffc0202530 <kmalloc+0x5c>
ffffffffc020254a:	4401                	li	s0,0
}
ffffffffc020254c:	8522                	mv	a0,s0
ffffffffc020254e:	60e2                	ld	ra,24(sp)
ffffffffc0202550:	6442                	ld	s0,16(sp)
ffffffffc0202552:	64a2                	ld	s1,8(sp)
ffffffffc0202554:	6902                	ld	s2,0(sp)
ffffffffc0202556:	6105                	addi	sp,sp,32
ffffffffc0202558:	8082                	ret
        intr_disable();
ffffffffc020255a:	902fe0ef          	jal	ra,ffffffffc020065c <intr_disable>
		bb->next = bigblocks;
ffffffffc020255e:	000aa797          	auipc	a5,0xaa
ffffffffc0202562:	e7278793          	addi	a5,a5,-398 # ffffffffc02ac3d0 <bigblocks>
ffffffffc0202566:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0202568:	000aa717          	auipc	a4,0xaa
ffffffffc020256c:	e6973423          	sd	s1,-408(a4) # ffffffffc02ac3d0 <bigblocks>
		bb->next = bigblocks;
ffffffffc0202570:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0202572:	8e4fe0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0202576:	6480                	ld	s0,8(s1)
}
ffffffffc0202578:	60e2                	ld	ra,24(sp)
ffffffffc020257a:	64a2                	ld	s1,8(sp)
ffffffffc020257c:	8522                	mv	a0,s0
ffffffffc020257e:	6442                	ld	s0,16(sp)
ffffffffc0202580:	6902                	ld	s2,0(sp)
ffffffffc0202582:	6105                	addi	sp,sp,32
ffffffffc0202584:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0202586:	45e1                	li	a1,24
ffffffffc0202588:	8526                	mv	a0,s1
ffffffffc020258a:	c99ff0ef          	jal	ra,ffffffffc0202222 <slob_free>
  return __kmalloc(size, 0);
ffffffffc020258e:	b74d                	j	ffffffffc0202530 <kmalloc+0x5c>

ffffffffc0202590 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0202590:	c175                	beqz	a0,ffffffffc0202674 <kfree+0xe4>
{
ffffffffc0202592:	1101                	addi	sp,sp,-32
ffffffffc0202594:	e426                	sd	s1,8(sp)
ffffffffc0202596:	ec06                	sd	ra,24(sp)
ffffffffc0202598:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc020259a:	03451793          	slli	a5,a0,0x34
ffffffffc020259e:	84aa                	mv	s1,a0
ffffffffc02025a0:	eb8d                	bnez	a5,ffffffffc02025d2 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02025a2:	100027f3          	csrr	a5,sstatus
ffffffffc02025a6:	8b89                	andi	a5,a5,2
ffffffffc02025a8:	efc9                	bnez	a5,ffffffffc0202642 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02025aa:	000aa797          	auipc	a5,0xaa
ffffffffc02025ae:	e2678793          	addi	a5,a5,-474 # ffffffffc02ac3d0 <bigblocks>
ffffffffc02025b2:	6394                	ld	a3,0(a5)
ffffffffc02025b4:	ce99                	beqz	a3,ffffffffc02025d2 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc02025b6:	669c                	ld	a5,8(a3)
ffffffffc02025b8:	6a80                	ld	s0,16(a3)
ffffffffc02025ba:	0af50e63          	beq	a0,a5,ffffffffc0202676 <kfree+0xe6>
    return 0;
ffffffffc02025be:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02025c0:	c801                	beqz	s0,ffffffffc02025d0 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc02025c2:	6418                	ld	a4,8(s0)
ffffffffc02025c4:	681c                	ld	a5,16(s0)
ffffffffc02025c6:	00970f63          	beq	a4,s1,ffffffffc02025e4 <kfree+0x54>
ffffffffc02025ca:	86a2                	mv	a3,s0
ffffffffc02025cc:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02025ce:	f875                	bnez	s0,ffffffffc02025c2 <kfree+0x32>
    if (flag) {
ffffffffc02025d0:	e659                	bnez	a2,ffffffffc020265e <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc02025d2:	6442                	ld	s0,16(sp)
ffffffffc02025d4:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02025d6:	ff048513          	addi	a0,s1,-16
}
ffffffffc02025da:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02025dc:	4581                	li	a1,0
}
ffffffffc02025de:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02025e0:	c43ff06f          	j	ffffffffc0202222 <slob_free>
				*last = bb->next;
ffffffffc02025e4:	ea9c                	sd	a5,16(a3)
ffffffffc02025e6:	e641                	bnez	a2,ffffffffc020266e <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc02025e8:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc02025ec:	4018                	lw	a4,0(s0)
ffffffffc02025ee:	08f4ea63          	bltu	s1,a5,ffffffffc0202682 <kfree+0xf2>
ffffffffc02025f2:	000aa797          	auipc	a5,0xaa
ffffffffc02025f6:	f1e78793          	addi	a5,a5,-226 # ffffffffc02ac510 <va_pa_offset>
ffffffffc02025fa:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02025fc:	000aa797          	auipc	a5,0xaa
ffffffffc0202600:	de478793          	addi	a5,a5,-540 # ffffffffc02ac3e0 <npage>
ffffffffc0202604:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0202606:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0202608:	80b1                	srli	s1,s1,0xc
ffffffffc020260a:	08f4f963          	bleu	a5,s1,ffffffffc020269c <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc020260e:	00006797          	auipc	a5,0x6
ffffffffc0202612:	70278793          	addi	a5,a5,1794 # ffffffffc0208d10 <nbase>
ffffffffc0202616:	639c                	ld	a5,0(a5)
ffffffffc0202618:	000aa697          	auipc	a3,0xaa
ffffffffc020261c:	f0868693          	addi	a3,a3,-248 # ffffffffc02ac520 <pages>
ffffffffc0202620:	6288                	ld	a0,0(a3)
ffffffffc0202622:	8c9d                	sub	s1,s1,a5
ffffffffc0202624:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0202626:	4585                	li	a1,1
ffffffffc0202628:	9526                	add	a0,a0,s1
ffffffffc020262a:	00e595bb          	sllw	a1,a1,a4
ffffffffc020262e:	060010ef          	jal	ra,ffffffffc020368e <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202632:	8522                	mv	a0,s0
}
ffffffffc0202634:	6442                	ld	s0,16(sp)
ffffffffc0202636:	60e2                	ld	ra,24(sp)
ffffffffc0202638:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc020263a:	45e1                	li	a1,24
}
ffffffffc020263c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020263e:	be5ff06f          	j	ffffffffc0202222 <slob_free>
        intr_disable();
ffffffffc0202642:	81afe0ef          	jal	ra,ffffffffc020065c <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202646:	000aa797          	auipc	a5,0xaa
ffffffffc020264a:	d8a78793          	addi	a5,a5,-630 # ffffffffc02ac3d0 <bigblocks>
ffffffffc020264e:	6394                	ld	a3,0(a5)
ffffffffc0202650:	c699                	beqz	a3,ffffffffc020265e <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0202652:	669c                	ld	a5,8(a3)
ffffffffc0202654:	6a80                	ld	s0,16(a3)
ffffffffc0202656:	00f48763          	beq	s1,a5,ffffffffc0202664 <kfree+0xd4>
        return 1;
ffffffffc020265a:	4605                	li	a2,1
ffffffffc020265c:	b795                	j	ffffffffc02025c0 <kfree+0x30>
        intr_enable();
ffffffffc020265e:	ff9fd0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0202662:	bf85                	j	ffffffffc02025d2 <kfree+0x42>
				*last = bb->next;
ffffffffc0202664:	000aa797          	auipc	a5,0xaa
ffffffffc0202668:	d687b623          	sd	s0,-660(a5) # ffffffffc02ac3d0 <bigblocks>
ffffffffc020266c:	8436                	mv	s0,a3
ffffffffc020266e:	fe9fd0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0202672:	bf9d                	j	ffffffffc02025e8 <kfree+0x58>
ffffffffc0202674:	8082                	ret
ffffffffc0202676:	000aa797          	auipc	a5,0xaa
ffffffffc020267a:	d487bd23          	sd	s0,-678(a5) # ffffffffc02ac3d0 <bigblocks>
ffffffffc020267e:	8436                	mv	s0,a3
ffffffffc0202680:	b7a5                	j	ffffffffc02025e8 <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0202682:	86a6                	mv	a3,s1
ffffffffc0202684:	00005617          	auipc	a2,0x5
ffffffffc0202688:	13460613          	addi	a2,a2,308 # ffffffffc02077b8 <commands+0x1030>
ffffffffc020268c:	06e00593          	li	a1,110
ffffffffc0202690:	00005517          	auipc	a0,0x5
ffffffffc0202694:	cb050513          	addi	a0,a0,-848 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0202698:	b7ffd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020269c:	00005617          	auipc	a2,0x5
ffffffffc02026a0:	c8460613          	addi	a2,a2,-892 # ffffffffc0207320 <commands+0xb98>
ffffffffc02026a4:	06200593          	li	a1,98
ffffffffc02026a8:	00005517          	auipc	a0,0x5
ffffffffc02026ac:	c9850513          	addi	a0,a0,-872 # ffffffffc0207340 <commands+0xbb8>
ffffffffc02026b0:	b67fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02026b4 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02026b4:	000aa797          	auipc	a5,0xaa
ffffffffc02026b8:	e2c78793          	addi	a5,a5,-468 # ffffffffc02ac4e0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc02026bc:	f51c                	sd	a5,40(a0)
ffffffffc02026be:	e79c                	sd	a5,8(a5)
ffffffffc02026c0:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02026c2:	4501                	li	a0,0
ffffffffc02026c4:	8082                	ret

ffffffffc02026c6 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc02026c6:	4501                	li	a0,0
ffffffffc02026c8:	8082                	ret

ffffffffc02026ca <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02026ca:	4501                	li	a0,0
ffffffffc02026cc:	8082                	ret

ffffffffc02026ce <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02026ce:	4501                	li	a0,0
ffffffffc02026d0:	8082                	ret

ffffffffc02026d2 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc02026d2:	711d                	addi	sp,sp,-96
ffffffffc02026d4:	fc4e                	sd	s3,56(sp)
ffffffffc02026d6:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02026d8:	00005517          	auipc	a0,0x5
ffffffffc02026dc:	17850513          	addi	a0,a0,376 # ffffffffc0207850 <commands+0x10c8>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02026e0:	698d                	lui	s3,0x3
ffffffffc02026e2:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02026e4:	e8a2                	sd	s0,80(sp)
ffffffffc02026e6:	e4a6                	sd	s1,72(sp)
ffffffffc02026e8:	ec86                	sd	ra,88(sp)
ffffffffc02026ea:	e0ca                	sd	s2,64(sp)
ffffffffc02026ec:	f456                	sd	s5,40(sp)
ffffffffc02026ee:	f05a                	sd	s6,32(sp)
ffffffffc02026f0:	ec5e                	sd	s7,24(sp)
ffffffffc02026f2:	e862                	sd	s8,16(sp)
ffffffffc02026f4:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc02026f6:	000aa417          	auipc	s0,0xaa
ffffffffc02026fa:	cc240413          	addi	s0,s0,-830 # ffffffffc02ac3b8 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02026fe:	9d3fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202702:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6570>
    assert(pgfault_num==4);
ffffffffc0202706:	4004                	lw	s1,0(s0)
ffffffffc0202708:	4791                	li	a5,4
ffffffffc020270a:	2481                	sext.w	s1,s1
ffffffffc020270c:	14f49963          	bne	s1,a5,ffffffffc020285e <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0202710:	00005517          	auipc	a0,0x5
ffffffffc0202714:	18050513          	addi	a0,a0,384 # ffffffffc0207890 <commands+0x1108>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202718:	6a85                	lui	s5,0x1
ffffffffc020271a:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020271c:	9b5fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202720:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
    assert(pgfault_num==4);
ffffffffc0202724:	00042903          	lw	s2,0(s0)
ffffffffc0202728:	2901                	sext.w	s2,s2
ffffffffc020272a:	2a991a63          	bne	s2,s1,ffffffffc02029de <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020272e:	00005517          	auipc	a0,0x5
ffffffffc0202732:	18a50513          	addi	a0,a0,394 # ffffffffc02078b8 <commands+0x1130>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202736:	6b91                	lui	s7,0x4
ffffffffc0202738:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020273a:	997fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020273e:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5570>
    assert(pgfault_num==4);
ffffffffc0202742:	4004                	lw	s1,0(s0)
ffffffffc0202744:	2481                	sext.w	s1,s1
ffffffffc0202746:	27249c63          	bne	s1,s2,ffffffffc02029be <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020274a:	00005517          	auipc	a0,0x5
ffffffffc020274e:	19650513          	addi	a0,a0,406 # ffffffffc02078e0 <commands+0x1158>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202752:	6909                	lui	s2,0x2
ffffffffc0202754:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202756:	97bfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020275a:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7570>
    assert(pgfault_num==4);
ffffffffc020275e:	401c                	lw	a5,0(s0)
ffffffffc0202760:	2781                	sext.w	a5,a5
ffffffffc0202762:	22979e63          	bne	a5,s1,ffffffffc020299e <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0202766:	00005517          	auipc	a0,0x5
ffffffffc020276a:	1a250513          	addi	a0,a0,418 # ffffffffc0207908 <commands+0x1180>
ffffffffc020276e:	963fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0202772:	6795                	lui	a5,0x5
ffffffffc0202774:	4739                	li	a4,14
ffffffffc0202776:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4570>
    assert(pgfault_num==5);
ffffffffc020277a:	4004                	lw	s1,0(s0)
ffffffffc020277c:	4795                	li	a5,5
ffffffffc020277e:	2481                	sext.w	s1,s1
ffffffffc0202780:	1ef49f63          	bne	s1,a5,ffffffffc020297e <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202784:	00005517          	auipc	a0,0x5
ffffffffc0202788:	15c50513          	addi	a0,a0,348 # ffffffffc02078e0 <commands+0x1158>
ffffffffc020278c:	945fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202790:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0202794:	401c                	lw	a5,0(s0)
ffffffffc0202796:	2781                	sext.w	a5,a5
ffffffffc0202798:	1c979363          	bne	a5,s1,ffffffffc020295e <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020279c:	00005517          	auipc	a0,0x5
ffffffffc02027a0:	0f450513          	addi	a0,a0,244 # ffffffffc0207890 <commands+0x1108>
ffffffffc02027a4:	92dfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02027a8:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc02027ac:	401c                	lw	a5,0(s0)
ffffffffc02027ae:	4719                	li	a4,6
ffffffffc02027b0:	2781                	sext.w	a5,a5
ffffffffc02027b2:	18e79663          	bne	a5,a4,ffffffffc020293e <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02027b6:	00005517          	auipc	a0,0x5
ffffffffc02027ba:	12a50513          	addi	a0,a0,298 # ffffffffc02078e0 <commands+0x1158>
ffffffffc02027be:	913fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02027c2:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc02027c6:	401c                	lw	a5,0(s0)
ffffffffc02027c8:	471d                	li	a4,7
ffffffffc02027ca:	2781                	sext.w	a5,a5
ffffffffc02027cc:	14e79963          	bne	a5,a4,ffffffffc020291e <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02027d0:	00005517          	auipc	a0,0x5
ffffffffc02027d4:	08050513          	addi	a0,a0,128 # ffffffffc0207850 <commands+0x10c8>
ffffffffc02027d8:	8f9fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02027dc:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02027e0:	401c                	lw	a5,0(s0)
ffffffffc02027e2:	4721                	li	a4,8
ffffffffc02027e4:	2781                	sext.w	a5,a5
ffffffffc02027e6:	10e79c63          	bne	a5,a4,ffffffffc02028fe <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02027ea:	00005517          	auipc	a0,0x5
ffffffffc02027ee:	0ce50513          	addi	a0,a0,206 # ffffffffc02078b8 <commands+0x1130>
ffffffffc02027f2:	8dffd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02027f6:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02027fa:	401c                	lw	a5,0(s0)
ffffffffc02027fc:	4725                	li	a4,9
ffffffffc02027fe:	2781                	sext.w	a5,a5
ffffffffc0202800:	0ce79f63          	bne	a5,a4,ffffffffc02028de <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0202804:	00005517          	auipc	a0,0x5
ffffffffc0202808:	10450513          	addi	a0,a0,260 # ffffffffc0207908 <commands+0x1180>
ffffffffc020280c:	8c5fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0202810:	6795                	lui	a5,0x5
ffffffffc0202812:	4739                	li	a4,14
ffffffffc0202814:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4570>
    assert(pgfault_num==10);
ffffffffc0202818:	4004                	lw	s1,0(s0)
ffffffffc020281a:	47a9                	li	a5,10
ffffffffc020281c:	2481                	sext.w	s1,s1
ffffffffc020281e:	0af49063          	bne	s1,a5,ffffffffc02028be <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0202822:	00005517          	auipc	a0,0x5
ffffffffc0202826:	06e50513          	addi	a0,a0,110 # ffffffffc0207890 <commands+0x1108>
ffffffffc020282a:	8a7fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020282e:	6785                	lui	a5,0x1
ffffffffc0202830:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
ffffffffc0202834:	06979563          	bne	a5,s1,ffffffffc020289e <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0202838:	401c                	lw	a5,0(s0)
ffffffffc020283a:	472d                	li	a4,11
ffffffffc020283c:	2781                	sext.w	a5,a5
ffffffffc020283e:	04e79063          	bne	a5,a4,ffffffffc020287e <_fifo_check_swap+0x1ac>
}
ffffffffc0202842:	60e6                	ld	ra,88(sp)
ffffffffc0202844:	6446                	ld	s0,80(sp)
ffffffffc0202846:	64a6                	ld	s1,72(sp)
ffffffffc0202848:	6906                	ld	s2,64(sp)
ffffffffc020284a:	79e2                	ld	s3,56(sp)
ffffffffc020284c:	7a42                	ld	s4,48(sp)
ffffffffc020284e:	7aa2                	ld	s5,40(sp)
ffffffffc0202850:	7b02                	ld	s6,32(sp)
ffffffffc0202852:	6be2                	ld	s7,24(sp)
ffffffffc0202854:	6c42                	ld	s8,16(sp)
ffffffffc0202856:	6ca2                	ld	s9,8(sp)
ffffffffc0202858:	4501                	li	a0,0
ffffffffc020285a:	6125                	addi	sp,sp,96
ffffffffc020285c:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020285e:	00005697          	auipc	a3,0x5
ffffffffc0202862:	dc268693          	addi	a3,a3,-574 # ffffffffc0207620 <commands+0xe98>
ffffffffc0202866:	00004617          	auipc	a2,0x4
ffffffffc020286a:	3a260613          	addi	a2,a2,930 # ffffffffc0206c08 <commands+0x480>
ffffffffc020286e:	05100593          	li	a1,81
ffffffffc0202872:	00005517          	auipc	a0,0x5
ffffffffc0202876:	00650513          	addi	a0,a0,6 # ffffffffc0207878 <commands+0x10f0>
ffffffffc020287a:	99dfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==11);
ffffffffc020287e:	00005697          	auipc	a3,0x5
ffffffffc0202882:	13a68693          	addi	a3,a3,314 # ffffffffc02079b8 <commands+0x1230>
ffffffffc0202886:	00004617          	auipc	a2,0x4
ffffffffc020288a:	38260613          	addi	a2,a2,898 # ffffffffc0206c08 <commands+0x480>
ffffffffc020288e:	07300593          	li	a1,115
ffffffffc0202892:	00005517          	auipc	a0,0x5
ffffffffc0202896:	fe650513          	addi	a0,a0,-26 # ffffffffc0207878 <commands+0x10f0>
ffffffffc020289a:	97dfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020289e:	00005697          	auipc	a3,0x5
ffffffffc02028a2:	0f268693          	addi	a3,a3,242 # ffffffffc0207990 <commands+0x1208>
ffffffffc02028a6:	00004617          	auipc	a2,0x4
ffffffffc02028aa:	36260613          	addi	a2,a2,866 # ffffffffc0206c08 <commands+0x480>
ffffffffc02028ae:	07100593          	li	a1,113
ffffffffc02028b2:	00005517          	auipc	a0,0x5
ffffffffc02028b6:	fc650513          	addi	a0,a0,-58 # ffffffffc0207878 <commands+0x10f0>
ffffffffc02028ba:	95dfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==10);
ffffffffc02028be:	00005697          	auipc	a3,0x5
ffffffffc02028c2:	0c268693          	addi	a3,a3,194 # ffffffffc0207980 <commands+0x11f8>
ffffffffc02028c6:	00004617          	auipc	a2,0x4
ffffffffc02028ca:	34260613          	addi	a2,a2,834 # ffffffffc0206c08 <commands+0x480>
ffffffffc02028ce:	06f00593          	li	a1,111
ffffffffc02028d2:	00005517          	auipc	a0,0x5
ffffffffc02028d6:	fa650513          	addi	a0,a0,-90 # ffffffffc0207878 <commands+0x10f0>
ffffffffc02028da:	93dfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==9);
ffffffffc02028de:	00005697          	auipc	a3,0x5
ffffffffc02028e2:	09268693          	addi	a3,a3,146 # ffffffffc0207970 <commands+0x11e8>
ffffffffc02028e6:	00004617          	auipc	a2,0x4
ffffffffc02028ea:	32260613          	addi	a2,a2,802 # ffffffffc0206c08 <commands+0x480>
ffffffffc02028ee:	06c00593          	li	a1,108
ffffffffc02028f2:	00005517          	auipc	a0,0x5
ffffffffc02028f6:	f8650513          	addi	a0,a0,-122 # ffffffffc0207878 <commands+0x10f0>
ffffffffc02028fa:	91dfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==8);
ffffffffc02028fe:	00005697          	auipc	a3,0x5
ffffffffc0202902:	06268693          	addi	a3,a3,98 # ffffffffc0207960 <commands+0x11d8>
ffffffffc0202906:	00004617          	auipc	a2,0x4
ffffffffc020290a:	30260613          	addi	a2,a2,770 # ffffffffc0206c08 <commands+0x480>
ffffffffc020290e:	06900593          	li	a1,105
ffffffffc0202912:	00005517          	auipc	a0,0x5
ffffffffc0202916:	f6650513          	addi	a0,a0,-154 # ffffffffc0207878 <commands+0x10f0>
ffffffffc020291a:	8fdfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==7);
ffffffffc020291e:	00005697          	auipc	a3,0x5
ffffffffc0202922:	03268693          	addi	a3,a3,50 # ffffffffc0207950 <commands+0x11c8>
ffffffffc0202926:	00004617          	auipc	a2,0x4
ffffffffc020292a:	2e260613          	addi	a2,a2,738 # ffffffffc0206c08 <commands+0x480>
ffffffffc020292e:	06600593          	li	a1,102
ffffffffc0202932:	00005517          	auipc	a0,0x5
ffffffffc0202936:	f4650513          	addi	a0,a0,-186 # ffffffffc0207878 <commands+0x10f0>
ffffffffc020293a:	8ddfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==6);
ffffffffc020293e:	00005697          	auipc	a3,0x5
ffffffffc0202942:	00268693          	addi	a3,a3,2 # ffffffffc0207940 <commands+0x11b8>
ffffffffc0202946:	00004617          	auipc	a2,0x4
ffffffffc020294a:	2c260613          	addi	a2,a2,706 # ffffffffc0206c08 <commands+0x480>
ffffffffc020294e:	06300593          	li	a1,99
ffffffffc0202952:	00005517          	auipc	a0,0x5
ffffffffc0202956:	f2650513          	addi	a0,a0,-218 # ffffffffc0207878 <commands+0x10f0>
ffffffffc020295a:	8bdfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==5);
ffffffffc020295e:	00005697          	auipc	a3,0x5
ffffffffc0202962:	fd268693          	addi	a3,a3,-46 # ffffffffc0207930 <commands+0x11a8>
ffffffffc0202966:	00004617          	auipc	a2,0x4
ffffffffc020296a:	2a260613          	addi	a2,a2,674 # ffffffffc0206c08 <commands+0x480>
ffffffffc020296e:	06000593          	li	a1,96
ffffffffc0202972:	00005517          	auipc	a0,0x5
ffffffffc0202976:	f0650513          	addi	a0,a0,-250 # ffffffffc0207878 <commands+0x10f0>
ffffffffc020297a:	89dfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==5);
ffffffffc020297e:	00005697          	auipc	a3,0x5
ffffffffc0202982:	fb268693          	addi	a3,a3,-78 # ffffffffc0207930 <commands+0x11a8>
ffffffffc0202986:	00004617          	auipc	a2,0x4
ffffffffc020298a:	28260613          	addi	a2,a2,642 # ffffffffc0206c08 <commands+0x480>
ffffffffc020298e:	05d00593          	li	a1,93
ffffffffc0202992:	00005517          	auipc	a0,0x5
ffffffffc0202996:	ee650513          	addi	a0,a0,-282 # ffffffffc0207878 <commands+0x10f0>
ffffffffc020299a:	87dfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc020299e:	00005697          	auipc	a3,0x5
ffffffffc02029a2:	c8268693          	addi	a3,a3,-894 # ffffffffc0207620 <commands+0xe98>
ffffffffc02029a6:	00004617          	auipc	a2,0x4
ffffffffc02029aa:	26260613          	addi	a2,a2,610 # ffffffffc0206c08 <commands+0x480>
ffffffffc02029ae:	05a00593          	li	a1,90
ffffffffc02029b2:	00005517          	auipc	a0,0x5
ffffffffc02029b6:	ec650513          	addi	a0,a0,-314 # ffffffffc0207878 <commands+0x10f0>
ffffffffc02029ba:	85dfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc02029be:	00005697          	auipc	a3,0x5
ffffffffc02029c2:	c6268693          	addi	a3,a3,-926 # ffffffffc0207620 <commands+0xe98>
ffffffffc02029c6:	00004617          	auipc	a2,0x4
ffffffffc02029ca:	24260613          	addi	a2,a2,578 # ffffffffc0206c08 <commands+0x480>
ffffffffc02029ce:	05700593          	li	a1,87
ffffffffc02029d2:	00005517          	auipc	a0,0x5
ffffffffc02029d6:	ea650513          	addi	a0,a0,-346 # ffffffffc0207878 <commands+0x10f0>
ffffffffc02029da:	83dfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc02029de:	00005697          	auipc	a3,0x5
ffffffffc02029e2:	c4268693          	addi	a3,a3,-958 # ffffffffc0207620 <commands+0xe98>
ffffffffc02029e6:	00004617          	auipc	a2,0x4
ffffffffc02029ea:	22260613          	addi	a2,a2,546 # ffffffffc0206c08 <commands+0x480>
ffffffffc02029ee:	05400593          	li	a1,84
ffffffffc02029f2:	00005517          	auipc	a0,0x5
ffffffffc02029f6:	e8650513          	addi	a0,a0,-378 # ffffffffc0207878 <commands+0x10f0>
ffffffffc02029fa:	81dfd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02029fe <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02029fe:	751c                	ld	a5,40(a0)
{
ffffffffc0202a00:	1141                	addi	sp,sp,-16
ffffffffc0202a02:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0202a04:	cf91                	beqz	a5,ffffffffc0202a20 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0202a06:	ee0d                	bnez	a2,ffffffffc0202a40 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0202a08:	679c                	ld	a5,8(a5)
}
ffffffffc0202a0a:	60a2                	ld	ra,8(sp)
ffffffffc0202a0c:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0202a0e:	6394                	ld	a3,0(a5)
ffffffffc0202a10:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0202a12:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0202a16:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0202a18:	e314                	sd	a3,0(a4)
ffffffffc0202a1a:	e19c                	sd	a5,0(a1)
}
ffffffffc0202a1c:	0141                	addi	sp,sp,16
ffffffffc0202a1e:	8082                	ret
         assert(head != NULL);
ffffffffc0202a20:	00005697          	auipc	a3,0x5
ffffffffc0202a24:	fc868693          	addi	a3,a3,-56 # ffffffffc02079e8 <commands+0x1260>
ffffffffc0202a28:	00004617          	auipc	a2,0x4
ffffffffc0202a2c:	1e060613          	addi	a2,a2,480 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202a30:	04100593          	li	a1,65
ffffffffc0202a34:	00005517          	auipc	a0,0x5
ffffffffc0202a38:	e4450513          	addi	a0,a0,-444 # ffffffffc0207878 <commands+0x10f0>
ffffffffc0202a3c:	fdafd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(in_tick==0);
ffffffffc0202a40:	00005697          	auipc	a3,0x5
ffffffffc0202a44:	fb868693          	addi	a3,a3,-72 # ffffffffc02079f8 <commands+0x1270>
ffffffffc0202a48:	00004617          	auipc	a2,0x4
ffffffffc0202a4c:	1c060613          	addi	a2,a2,448 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202a50:	04200593          	li	a1,66
ffffffffc0202a54:	00005517          	auipc	a0,0x5
ffffffffc0202a58:	e2450513          	addi	a0,a0,-476 # ffffffffc0207878 <commands+0x10f0>
ffffffffc0202a5c:	fbafd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202a60 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0202a60:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0202a64:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0202a66:	cb09                	beqz	a4,ffffffffc0202a78 <_fifo_map_swappable+0x18>
ffffffffc0202a68:	cb81                	beqz	a5,ffffffffc0202a78 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202a6a:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0202a6c:	e398                	sd	a4,0(a5)
}
ffffffffc0202a6e:	4501                	li	a0,0
ffffffffc0202a70:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0202a72:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0202a74:	f614                	sd	a3,40(a2)
ffffffffc0202a76:	8082                	ret
{
ffffffffc0202a78:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0202a7a:	00005697          	auipc	a3,0x5
ffffffffc0202a7e:	f4e68693          	addi	a3,a3,-178 # ffffffffc02079c8 <commands+0x1240>
ffffffffc0202a82:	00004617          	auipc	a2,0x4
ffffffffc0202a86:	18660613          	addi	a2,a2,390 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202a8a:	03200593          	li	a1,50
ffffffffc0202a8e:	00005517          	auipc	a0,0x5
ffffffffc0202a92:	dea50513          	addi	a0,a0,-534 # ffffffffc0207878 <commands+0x10f0>
{
ffffffffc0202a96:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0202a98:	f7efd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202a9c <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0202a9c:	000aa797          	auipc	a5,0xaa
ffffffffc0202aa0:	a5478793          	addi	a5,a5,-1452 # ffffffffc02ac4f0 <free_area>
ffffffffc0202aa4:	e79c                	sd	a5,8(a5)
ffffffffc0202aa6:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0202aa8:	0007a823          	sw	zero,16(a5)
}
ffffffffc0202aac:	8082                	ret

ffffffffc0202aae <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202aae:	000aa517          	auipc	a0,0xaa
ffffffffc0202ab2:	a5256503          	lwu	a0,-1454(a0) # ffffffffc02ac500 <free_area+0x10>
ffffffffc0202ab6:	8082                	ret

ffffffffc0202ab8 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0202ab8:	715d                	addi	sp,sp,-80
ffffffffc0202aba:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0202abc:	000aa917          	auipc	s2,0xaa
ffffffffc0202ac0:	a3490913          	addi	s2,s2,-1484 # ffffffffc02ac4f0 <free_area>
ffffffffc0202ac4:	00893783          	ld	a5,8(s2)
ffffffffc0202ac8:	e486                	sd	ra,72(sp)
ffffffffc0202aca:	e0a2                	sd	s0,64(sp)
ffffffffc0202acc:	fc26                	sd	s1,56(sp)
ffffffffc0202ace:	f44e                	sd	s3,40(sp)
ffffffffc0202ad0:	f052                	sd	s4,32(sp)
ffffffffc0202ad2:	ec56                	sd	s5,24(sp)
ffffffffc0202ad4:	e85a                	sd	s6,16(sp)
ffffffffc0202ad6:	e45e                	sd	s7,8(sp)
ffffffffc0202ad8:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202ada:	31278463          	beq	a5,s2,ffffffffc0202de2 <default_check+0x32a>
ffffffffc0202ade:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202ae2:	8305                	srli	a4,a4,0x1
ffffffffc0202ae4:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202ae6:	30070263          	beqz	a4,ffffffffc0202dea <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0202aea:	4401                	li	s0,0
ffffffffc0202aec:	4481                	li	s1,0
ffffffffc0202aee:	a031                	j	ffffffffc0202afa <default_check+0x42>
ffffffffc0202af0:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0202af4:	8b09                	andi	a4,a4,2
ffffffffc0202af6:	2e070a63          	beqz	a4,ffffffffc0202dea <default_check+0x332>
        count ++, total += p->property;
ffffffffc0202afa:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202afe:	679c                	ld	a5,8(a5)
ffffffffc0202b00:	2485                	addiw	s1,s1,1
ffffffffc0202b02:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202b04:	ff2796e3          	bne	a5,s2,ffffffffc0202af0 <default_check+0x38>
ffffffffc0202b08:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0202b0a:	3cb000ef          	jal	ra,ffffffffc02036d4 <nr_free_pages>
ffffffffc0202b0e:	73351e63          	bne	a0,s3,ffffffffc020324a <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202b12:	4505                	li	a0,1
ffffffffc0202b14:	2f3000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202b18:	8a2a                	mv	s4,a0
ffffffffc0202b1a:	46050863          	beqz	a0,ffffffffc0202f8a <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202b1e:	4505                	li	a0,1
ffffffffc0202b20:	2e7000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202b24:	89aa                	mv	s3,a0
ffffffffc0202b26:	74050263          	beqz	a0,ffffffffc020326a <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202b2a:	4505                	li	a0,1
ffffffffc0202b2c:	2db000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202b30:	8aaa                	mv	s5,a0
ffffffffc0202b32:	4c050c63          	beqz	a0,ffffffffc020300a <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202b36:	2d3a0a63          	beq	s4,s3,ffffffffc0202e0a <default_check+0x352>
ffffffffc0202b3a:	2caa0863          	beq	s4,a0,ffffffffc0202e0a <default_check+0x352>
ffffffffc0202b3e:	2ca98663          	beq	s3,a0,ffffffffc0202e0a <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202b42:	000a2783          	lw	a5,0(s4)
ffffffffc0202b46:	2e079263          	bnez	a5,ffffffffc0202e2a <default_check+0x372>
ffffffffc0202b4a:	0009a783          	lw	a5,0(s3)
ffffffffc0202b4e:	2c079e63          	bnez	a5,ffffffffc0202e2a <default_check+0x372>
ffffffffc0202b52:	411c                	lw	a5,0(a0)
ffffffffc0202b54:	2c079b63          	bnez	a5,ffffffffc0202e2a <default_check+0x372>
    return page - pages + nbase;
ffffffffc0202b58:	000aa797          	auipc	a5,0xaa
ffffffffc0202b5c:	9c878793          	addi	a5,a5,-1592 # ffffffffc02ac520 <pages>
ffffffffc0202b60:	639c                	ld	a5,0(a5)
ffffffffc0202b62:	00006717          	auipc	a4,0x6
ffffffffc0202b66:	1ae70713          	addi	a4,a4,430 # ffffffffc0208d10 <nbase>
ffffffffc0202b6a:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202b6c:	000aa717          	auipc	a4,0xaa
ffffffffc0202b70:	87470713          	addi	a4,a4,-1932 # ffffffffc02ac3e0 <npage>
ffffffffc0202b74:	6314                	ld	a3,0(a4)
ffffffffc0202b76:	40fa0733          	sub	a4,s4,a5
ffffffffc0202b7a:	8719                	srai	a4,a4,0x6
ffffffffc0202b7c:	9732                	add	a4,a4,a2
ffffffffc0202b7e:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b80:	0732                	slli	a4,a4,0xc
ffffffffc0202b82:	2cd77463          	bleu	a3,a4,ffffffffc0202e4a <default_check+0x392>
    return page - pages + nbase;
ffffffffc0202b86:	40f98733          	sub	a4,s3,a5
ffffffffc0202b8a:	8719                	srai	a4,a4,0x6
ffffffffc0202b8c:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b8e:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202b90:	4ed77d63          	bleu	a3,a4,ffffffffc020308a <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0202b94:	40f507b3          	sub	a5,a0,a5
ffffffffc0202b98:	8799                	srai	a5,a5,0x6
ffffffffc0202b9a:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b9c:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202b9e:	34d7f663          	bleu	a3,a5,ffffffffc0202eea <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0202ba2:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202ba4:	00093c03          	ld	s8,0(s2)
ffffffffc0202ba8:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0202bac:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0202bb0:	000aa797          	auipc	a5,0xaa
ffffffffc0202bb4:	9527b423          	sd	s2,-1720(a5) # ffffffffc02ac4f8 <free_area+0x8>
ffffffffc0202bb8:	000aa797          	auipc	a5,0xaa
ffffffffc0202bbc:	9327bc23          	sd	s2,-1736(a5) # ffffffffc02ac4f0 <free_area>
    nr_free = 0;
ffffffffc0202bc0:	000aa797          	auipc	a5,0xaa
ffffffffc0202bc4:	9407a023          	sw	zero,-1728(a5) # ffffffffc02ac500 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202bc8:	23f000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202bcc:	2e051f63          	bnez	a0,ffffffffc0202eca <default_check+0x412>
    free_page(p0);
ffffffffc0202bd0:	4585                	li	a1,1
ffffffffc0202bd2:	8552                	mv	a0,s4
ffffffffc0202bd4:	2bb000ef          	jal	ra,ffffffffc020368e <free_pages>
    free_page(p1);
ffffffffc0202bd8:	4585                	li	a1,1
ffffffffc0202bda:	854e                	mv	a0,s3
ffffffffc0202bdc:	2b3000ef          	jal	ra,ffffffffc020368e <free_pages>
    free_page(p2);
ffffffffc0202be0:	4585                	li	a1,1
ffffffffc0202be2:	8556                	mv	a0,s5
ffffffffc0202be4:	2ab000ef          	jal	ra,ffffffffc020368e <free_pages>
    assert(nr_free == 3);
ffffffffc0202be8:	01092703          	lw	a4,16(s2)
ffffffffc0202bec:	478d                	li	a5,3
ffffffffc0202bee:	2af71e63          	bne	a4,a5,ffffffffc0202eaa <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202bf2:	4505                	li	a0,1
ffffffffc0202bf4:	213000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202bf8:	89aa                	mv	s3,a0
ffffffffc0202bfa:	28050863          	beqz	a0,ffffffffc0202e8a <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202bfe:	4505                	li	a0,1
ffffffffc0202c00:	207000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202c04:	8aaa                	mv	s5,a0
ffffffffc0202c06:	3e050263          	beqz	a0,ffffffffc0202fea <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202c0a:	4505                	li	a0,1
ffffffffc0202c0c:	1fb000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202c10:	8a2a                	mv	s4,a0
ffffffffc0202c12:	3a050c63          	beqz	a0,ffffffffc0202fca <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0202c16:	4505                	li	a0,1
ffffffffc0202c18:	1ef000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202c1c:	38051763          	bnez	a0,ffffffffc0202faa <default_check+0x4f2>
    free_page(p0);
ffffffffc0202c20:	4585                	li	a1,1
ffffffffc0202c22:	854e                	mv	a0,s3
ffffffffc0202c24:	26b000ef          	jal	ra,ffffffffc020368e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202c28:	00893783          	ld	a5,8(s2)
ffffffffc0202c2c:	23278f63          	beq	a5,s2,ffffffffc0202e6a <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0202c30:	4505                	li	a0,1
ffffffffc0202c32:	1d5000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202c36:	32a99a63          	bne	s3,a0,ffffffffc0202f6a <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0202c3a:	4505                	li	a0,1
ffffffffc0202c3c:	1cb000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202c40:	30051563          	bnez	a0,ffffffffc0202f4a <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0202c44:	01092783          	lw	a5,16(s2)
ffffffffc0202c48:	2e079163          	bnez	a5,ffffffffc0202f2a <default_check+0x472>
    free_page(p);
ffffffffc0202c4c:	854e                	mv	a0,s3
ffffffffc0202c4e:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202c50:	000aa797          	auipc	a5,0xaa
ffffffffc0202c54:	8b87b023          	sd	s8,-1888(a5) # ffffffffc02ac4f0 <free_area>
ffffffffc0202c58:	000aa797          	auipc	a5,0xaa
ffffffffc0202c5c:	8b77b023          	sd	s7,-1888(a5) # ffffffffc02ac4f8 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0202c60:	000aa797          	auipc	a5,0xaa
ffffffffc0202c64:	8b67a023          	sw	s6,-1888(a5) # ffffffffc02ac500 <free_area+0x10>
    free_page(p);
ffffffffc0202c68:	227000ef          	jal	ra,ffffffffc020368e <free_pages>
    free_page(p1);
ffffffffc0202c6c:	4585                	li	a1,1
ffffffffc0202c6e:	8556                	mv	a0,s5
ffffffffc0202c70:	21f000ef          	jal	ra,ffffffffc020368e <free_pages>
    free_page(p2);
ffffffffc0202c74:	4585                	li	a1,1
ffffffffc0202c76:	8552                	mv	a0,s4
ffffffffc0202c78:	217000ef          	jal	ra,ffffffffc020368e <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202c7c:	4515                	li	a0,5
ffffffffc0202c7e:	189000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202c82:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202c84:	28050363          	beqz	a0,ffffffffc0202f0a <default_check+0x452>
ffffffffc0202c88:	651c                	ld	a5,8(a0)
ffffffffc0202c8a:	8385                	srli	a5,a5,0x1
ffffffffc0202c8c:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0202c8e:	54079e63          	bnez	a5,ffffffffc02031ea <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202c92:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202c94:	00093b03          	ld	s6,0(s2)
ffffffffc0202c98:	00893a83          	ld	s5,8(s2)
ffffffffc0202c9c:	000aa797          	auipc	a5,0xaa
ffffffffc0202ca0:	8527ba23          	sd	s2,-1964(a5) # ffffffffc02ac4f0 <free_area>
ffffffffc0202ca4:	000aa797          	auipc	a5,0xaa
ffffffffc0202ca8:	8527ba23          	sd	s2,-1964(a5) # ffffffffc02ac4f8 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0202cac:	15b000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202cb0:	50051d63          	bnez	a0,ffffffffc02031ca <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202cb4:	08098a13          	addi	s4,s3,128
ffffffffc0202cb8:	8552                	mv	a0,s4
ffffffffc0202cba:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202cbc:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0202cc0:	000aa797          	auipc	a5,0xaa
ffffffffc0202cc4:	8407a023          	sw	zero,-1984(a5) # ffffffffc02ac500 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202cc8:	1c7000ef          	jal	ra,ffffffffc020368e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0202ccc:	4511                	li	a0,4
ffffffffc0202cce:	139000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202cd2:	4c051c63          	bnez	a0,ffffffffc02031aa <default_check+0x6f2>
ffffffffc0202cd6:	0889b783          	ld	a5,136(s3)
ffffffffc0202cda:	8385                	srli	a5,a5,0x1
ffffffffc0202cdc:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202cde:	4a078663          	beqz	a5,ffffffffc020318a <default_check+0x6d2>
ffffffffc0202ce2:	0909a703          	lw	a4,144(s3)
ffffffffc0202ce6:	478d                	li	a5,3
ffffffffc0202ce8:	4af71163          	bne	a4,a5,ffffffffc020318a <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202cec:	450d                	li	a0,3
ffffffffc0202cee:	119000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202cf2:	8c2a                	mv	s8,a0
ffffffffc0202cf4:	46050b63          	beqz	a0,ffffffffc020316a <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0202cf8:	4505                	li	a0,1
ffffffffc0202cfa:	10d000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202cfe:	44051663          	bnez	a0,ffffffffc020314a <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0202d02:	438a1463          	bne	s4,s8,ffffffffc020312a <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202d06:	4585                	li	a1,1
ffffffffc0202d08:	854e                	mv	a0,s3
ffffffffc0202d0a:	185000ef          	jal	ra,ffffffffc020368e <free_pages>
    free_pages(p1, 3);
ffffffffc0202d0e:	458d                	li	a1,3
ffffffffc0202d10:	8552                	mv	a0,s4
ffffffffc0202d12:	17d000ef          	jal	ra,ffffffffc020368e <free_pages>
ffffffffc0202d16:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202d1a:	04098c13          	addi	s8,s3,64
ffffffffc0202d1e:	8385                	srli	a5,a5,0x1
ffffffffc0202d20:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202d22:	3e078463          	beqz	a5,ffffffffc020310a <default_check+0x652>
ffffffffc0202d26:	0109a703          	lw	a4,16(s3)
ffffffffc0202d2a:	4785                	li	a5,1
ffffffffc0202d2c:	3cf71f63          	bne	a4,a5,ffffffffc020310a <default_check+0x652>
ffffffffc0202d30:	008a3783          	ld	a5,8(s4)
ffffffffc0202d34:	8385                	srli	a5,a5,0x1
ffffffffc0202d36:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202d38:	3a078963          	beqz	a5,ffffffffc02030ea <default_check+0x632>
ffffffffc0202d3c:	010a2703          	lw	a4,16(s4)
ffffffffc0202d40:	478d                	li	a5,3
ffffffffc0202d42:	3af71463          	bne	a4,a5,ffffffffc02030ea <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202d46:	4505                	li	a0,1
ffffffffc0202d48:	0bf000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202d4c:	36a99f63          	bne	s3,a0,ffffffffc02030ca <default_check+0x612>
    free_page(p0);
ffffffffc0202d50:	4585                	li	a1,1
ffffffffc0202d52:	13d000ef          	jal	ra,ffffffffc020368e <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202d56:	4509                	li	a0,2
ffffffffc0202d58:	0af000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202d5c:	34aa1763          	bne	s4,a0,ffffffffc02030aa <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0202d60:	4589                	li	a1,2
ffffffffc0202d62:	12d000ef          	jal	ra,ffffffffc020368e <free_pages>
    free_page(p2);
ffffffffc0202d66:	4585                	li	a1,1
ffffffffc0202d68:	8562                	mv	a0,s8
ffffffffc0202d6a:	125000ef          	jal	ra,ffffffffc020368e <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202d6e:	4515                	li	a0,5
ffffffffc0202d70:	097000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202d74:	89aa                	mv	s3,a0
ffffffffc0202d76:	48050a63          	beqz	a0,ffffffffc020320a <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0202d7a:	4505                	li	a0,1
ffffffffc0202d7c:	08b000ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0202d80:	2e051563          	bnez	a0,ffffffffc020306a <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0202d84:	01092783          	lw	a5,16(s2)
ffffffffc0202d88:	2c079163          	bnez	a5,ffffffffc020304a <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202d8c:	4595                	li	a1,5
ffffffffc0202d8e:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0202d90:	000a9797          	auipc	a5,0xa9
ffffffffc0202d94:	7777a823          	sw	s7,1904(a5) # ffffffffc02ac500 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0202d98:	000a9797          	auipc	a5,0xa9
ffffffffc0202d9c:	7567bc23          	sd	s6,1880(a5) # ffffffffc02ac4f0 <free_area>
ffffffffc0202da0:	000a9797          	auipc	a5,0xa9
ffffffffc0202da4:	7557bc23          	sd	s5,1880(a5) # ffffffffc02ac4f8 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0202da8:	0e7000ef          	jal	ra,ffffffffc020368e <free_pages>
    return listelm->next;
ffffffffc0202dac:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202db0:	01278963          	beq	a5,s2,ffffffffc0202dc2 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0202db4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202db8:	679c                	ld	a5,8(a5)
ffffffffc0202dba:	34fd                	addiw	s1,s1,-1
ffffffffc0202dbc:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202dbe:	ff279be3          	bne	a5,s2,ffffffffc0202db4 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0202dc2:	26049463          	bnez	s1,ffffffffc020302a <default_check+0x572>
    assert(total == 0);
ffffffffc0202dc6:	46041263          	bnez	s0,ffffffffc020322a <default_check+0x772>
}
ffffffffc0202dca:	60a6                	ld	ra,72(sp)
ffffffffc0202dcc:	6406                	ld	s0,64(sp)
ffffffffc0202dce:	74e2                	ld	s1,56(sp)
ffffffffc0202dd0:	7942                	ld	s2,48(sp)
ffffffffc0202dd2:	79a2                	ld	s3,40(sp)
ffffffffc0202dd4:	7a02                	ld	s4,32(sp)
ffffffffc0202dd6:	6ae2                	ld	s5,24(sp)
ffffffffc0202dd8:	6b42                	ld	s6,16(sp)
ffffffffc0202dda:	6ba2                	ld	s7,8(sp)
ffffffffc0202ddc:	6c02                	ld	s8,0(sp)
ffffffffc0202dde:	6161                	addi	sp,sp,80
ffffffffc0202de0:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202de2:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0202de4:	4401                	li	s0,0
ffffffffc0202de6:	4481                	li	s1,0
ffffffffc0202de8:	b30d                	j	ffffffffc0202b0a <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0202dea:	00004697          	auipc	a3,0x4
ffffffffc0202dee:	69668693          	addi	a3,a3,1686 # ffffffffc0207480 <commands+0xcf8>
ffffffffc0202df2:	00004617          	auipc	a2,0x4
ffffffffc0202df6:	e1660613          	addi	a2,a2,-490 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202dfa:	0f000593          	li	a1,240
ffffffffc0202dfe:	00005517          	auipc	a0,0x5
ffffffffc0202e02:	c2250513          	addi	a0,a0,-990 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0202e06:	c10fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202e0a:	00005697          	auipc	a3,0x5
ffffffffc0202e0e:	c8e68693          	addi	a3,a3,-882 # ffffffffc0207a98 <commands+0x1310>
ffffffffc0202e12:	00004617          	auipc	a2,0x4
ffffffffc0202e16:	df660613          	addi	a2,a2,-522 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202e1a:	0bd00593          	li	a1,189
ffffffffc0202e1e:	00005517          	auipc	a0,0x5
ffffffffc0202e22:	c0250513          	addi	a0,a0,-1022 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0202e26:	bf0fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202e2a:	00005697          	auipc	a3,0x5
ffffffffc0202e2e:	c9668693          	addi	a3,a3,-874 # ffffffffc0207ac0 <commands+0x1338>
ffffffffc0202e32:	00004617          	auipc	a2,0x4
ffffffffc0202e36:	dd660613          	addi	a2,a2,-554 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202e3a:	0be00593          	li	a1,190
ffffffffc0202e3e:	00005517          	auipc	a0,0x5
ffffffffc0202e42:	be250513          	addi	a0,a0,-1054 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0202e46:	bd0fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202e4a:	00005697          	auipc	a3,0x5
ffffffffc0202e4e:	cb668693          	addi	a3,a3,-842 # ffffffffc0207b00 <commands+0x1378>
ffffffffc0202e52:	00004617          	auipc	a2,0x4
ffffffffc0202e56:	db660613          	addi	a2,a2,-586 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202e5a:	0c000593          	li	a1,192
ffffffffc0202e5e:	00005517          	auipc	a0,0x5
ffffffffc0202e62:	bc250513          	addi	a0,a0,-1086 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0202e66:	bb0fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202e6a:	00005697          	auipc	a3,0x5
ffffffffc0202e6e:	d1e68693          	addi	a3,a3,-738 # ffffffffc0207b88 <commands+0x1400>
ffffffffc0202e72:	00004617          	auipc	a2,0x4
ffffffffc0202e76:	d9660613          	addi	a2,a2,-618 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202e7a:	0d900593          	li	a1,217
ffffffffc0202e7e:	00005517          	auipc	a0,0x5
ffffffffc0202e82:	ba250513          	addi	a0,a0,-1118 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0202e86:	b90fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202e8a:	00005697          	auipc	a3,0x5
ffffffffc0202e8e:	bae68693          	addi	a3,a3,-1106 # ffffffffc0207a38 <commands+0x12b0>
ffffffffc0202e92:	00004617          	auipc	a2,0x4
ffffffffc0202e96:	d7660613          	addi	a2,a2,-650 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202e9a:	0d200593          	li	a1,210
ffffffffc0202e9e:	00005517          	auipc	a0,0x5
ffffffffc0202ea2:	b8250513          	addi	a0,a0,-1150 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0202ea6:	b70fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 3);
ffffffffc0202eaa:	00005697          	auipc	a3,0x5
ffffffffc0202eae:	cce68693          	addi	a3,a3,-818 # ffffffffc0207b78 <commands+0x13f0>
ffffffffc0202eb2:	00004617          	auipc	a2,0x4
ffffffffc0202eb6:	d5660613          	addi	a2,a2,-682 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202eba:	0d000593          	li	a1,208
ffffffffc0202ebe:	00005517          	auipc	a0,0x5
ffffffffc0202ec2:	b6250513          	addi	a0,a0,-1182 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0202ec6:	b50fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202eca:	00005697          	auipc	a3,0x5
ffffffffc0202ece:	c9668693          	addi	a3,a3,-874 # ffffffffc0207b60 <commands+0x13d8>
ffffffffc0202ed2:	00004617          	auipc	a2,0x4
ffffffffc0202ed6:	d3660613          	addi	a2,a2,-714 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202eda:	0cb00593          	li	a1,203
ffffffffc0202ede:	00005517          	auipc	a0,0x5
ffffffffc0202ee2:	b4250513          	addi	a0,a0,-1214 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0202ee6:	b30fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202eea:	00005697          	auipc	a3,0x5
ffffffffc0202eee:	c5668693          	addi	a3,a3,-938 # ffffffffc0207b40 <commands+0x13b8>
ffffffffc0202ef2:	00004617          	auipc	a2,0x4
ffffffffc0202ef6:	d1660613          	addi	a2,a2,-746 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202efa:	0c200593          	li	a1,194
ffffffffc0202efe:	00005517          	auipc	a0,0x5
ffffffffc0202f02:	b2250513          	addi	a0,a0,-1246 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0202f06:	b10fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 != NULL);
ffffffffc0202f0a:	00005697          	auipc	a3,0x5
ffffffffc0202f0e:	cb668693          	addi	a3,a3,-842 # ffffffffc0207bc0 <commands+0x1438>
ffffffffc0202f12:	00004617          	auipc	a2,0x4
ffffffffc0202f16:	cf660613          	addi	a2,a2,-778 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202f1a:	0f800593          	li	a1,248
ffffffffc0202f1e:	00005517          	auipc	a0,0x5
ffffffffc0202f22:	b0250513          	addi	a0,a0,-1278 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0202f26:	af0fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 0);
ffffffffc0202f2a:	00004697          	auipc	a3,0x4
ffffffffc0202f2e:	70668693          	addi	a3,a3,1798 # ffffffffc0207630 <commands+0xea8>
ffffffffc0202f32:	00004617          	auipc	a2,0x4
ffffffffc0202f36:	cd660613          	addi	a2,a2,-810 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202f3a:	0df00593          	li	a1,223
ffffffffc0202f3e:	00005517          	auipc	a0,0x5
ffffffffc0202f42:	ae250513          	addi	a0,a0,-1310 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0202f46:	ad0fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202f4a:	00005697          	auipc	a3,0x5
ffffffffc0202f4e:	c1668693          	addi	a3,a3,-1002 # ffffffffc0207b60 <commands+0x13d8>
ffffffffc0202f52:	00004617          	auipc	a2,0x4
ffffffffc0202f56:	cb660613          	addi	a2,a2,-842 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202f5a:	0dd00593          	li	a1,221
ffffffffc0202f5e:	00005517          	auipc	a0,0x5
ffffffffc0202f62:	ac250513          	addi	a0,a0,-1342 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0202f66:	ab0fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202f6a:	00005697          	auipc	a3,0x5
ffffffffc0202f6e:	c3668693          	addi	a3,a3,-970 # ffffffffc0207ba0 <commands+0x1418>
ffffffffc0202f72:	00004617          	auipc	a2,0x4
ffffffffc0202f76:	c9660613          	addi	a2,a2,-874 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202f7a:	0dc00593          	li	a1,220
ffffffffc0202f7e:	00005517          	auipc	a0,0x5
ffffffffc0202f82:	aa250513          	addi	a0,a0,-1374 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0202f86:	a90fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202f8a:	00005697          	auipc	a3,0x5
ffffffffc0202f8e:	aae68693          	addi	a3,a3,-1362 # ffffffffc0207a38 <commands+0x12b0>
ffffffffc0202f92:	00004617          	auipc	a2,0x4
ffffffffc0202f96:	c7660613          	addi	a2,a2,-906 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202f9a:	0b900593          	li	a1,185
ffffffffc0202f9e:	00005517          	auipc	a0,0x5
ffffffffc0202fa2:	a8250513          	addi	a0,a0,-1406 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0202fa6:	a70fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202faa:	00005697          	auipc	a3,0x5
ffffffffc0202fae:	bb668693          	addi	a3,a3,-1098 # ffffffffc0207b60 <commands+0x13d8>
ffffffffc0202fb2:	00004617          	auipc	a2,0x4
ffffffffc0202fb6:	c5660613          	addi	a2,a2,-938 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202fba:	0d600593          	li	a1,214
ffffffffc0202fbe:	00005517          	auipc	a0,0x5
ffffffffc0202fc2:	a6250513          	addi	a0,a0,-1438 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0202fc6:	a50fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202fca:	00005697          	auipc	a3,0x5
ffffffffc0202fce:	aae68693          	addi	a3,a3,-1362 # ffffffffc0207a78 <commands+0x12f0>
ffffffffc0202fd2:	00004617          	auipc	a2,0x4
ffffffffc0202fd6:	c3660613          	addi	a2,a2,-970 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202fda:	0d400593          	li	a1,212
ffffffffc0202fde:	00005517          	auipc	a0,0x5
ffffffffc0202fe2:	a4250513          	addi	a0,a0,-1470 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0202fe6:	a30fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202fea:	00005697          	auipc	a3,0x5
ffffffffc0202fee:	a6e68693          	addi	a3,a3,-1426 # ffffffffc0207a58 <commands+0x12d0>
ffffffffc0202ff2:	00004617          	auipc	a2,0x4
ffffffffc0202ff6:	c1660613          	addi	a2,a2,-1002 # ffffffffc0206c08 <commands+0x480>
ffffffffc0202ffa:	0d300593          	li	a1,211
ffffffffc0202ffe:	00005517          	auipc	a0,0x5
ffffffffc0203002:	a2250513          	addi	a0,a0,-1502 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0203006:	a10fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020300a:	00005697          	auipc	a3,0x5
ffffffffc020300e:	a6e68693          	addi	a3,a3,-1426 # ffffffffc0207a78 <commands+0x12f0>
ffffffffc0203012:	00004617          	auipc	a2,0x4
ffffffffc0203016:	bf660613          	addi	a2,a2,-1034 # ffffffffc0206c08 <commands+0x480>
ffffffffc020301a:	0bb00593          	li	a1,187
ffffffffc020301e:	00005517          	auipc	a0,0x5
ffffffffc0203022:	a0250513          	addi	a0,a0,-1534 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0203026:	9f0fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(count == 0);
ffffffffc020302a:	00005697          	auipc	a3,0x5
ffffffffc020302e:	ce668693          	addi	a3,a3,-794 # ffffffffc0207d10 <commands+0x1588>
ffffffffc0203032:	00004617          	auipc	a2,0x4
ffffffffc0203036:	bd660613          	addi	a2,a2,-1066 # ffffffffc0206c08 <commands+0x480>
ffffffffc020303a:	12500593          	li	a1,293
ffffffffc020303e:	00005517          	auipc	a0,0x5
ffffffffc0203042:	9e250513          	addi	a0,a0,-1566 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0203046:	9d0fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 0);
ffffffffc020304a:	00004697          	auipc	a3,0x4
ffffffffc020304e:	5e668693          	addi	a3,a3,1510 # ffffffffc0207630 <commands+0xea8>
ffffffffc0203052:	00004617          	auipc	a2,0x4
ffffffffc0203056:	bb660613          	addi	a2,a2,-1098 # ffffffffc0206c08 <commands+0x480>
ffffffffc020305a:	11a00593          	li	a1,282
ffffffffc020305e:	00005517          	auipc	a0,0x5
ffffffffc0203062:	9c250513          	addi	a0,a0,-1598 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0203066:	9b0fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020306a:	00005697          	auipc	a3,0x5
ffffffffc020306e:	af668693          	addi	a3,a3,-1290 # ffffffffc0207b60 <commands+0x13d8>
ffffffffc0203072:	00004617          	auipc	a2,0x4
ffffffffc0203076:	b9660613          	addi	a2,a2,-1130 # ffffffffc0206c08 <commands+0x480>
ffffffffc020307a:	11800593          	li	a1,280
ffffffffc020307e:	00005517          	auipc	a0,0x5
ffffffffc0203082:	9a250513          	addi	a0,a0,-1630 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0203086:	990fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020308a:	00005697          	auipc	a3,0x5
ffffffffc020308e:	a9668693          	addi	a3,a3,-1386 # ffffffffc0207b20 <commands+0x1398>
ffffffffc0203092:	00004617          	auipc	a2,0x4
ffffffffc0203096:	b7660613          	addi	a2,a2,-1162 # ffffffffc0206c08 <commands+0x480>
ffffffffc020309a:	0c100593          	li	a1,193
ffffffffc020309e:	00005517          	auipc	a0,0x5
ffffffffc02030a2:	98250513          	addi	a0,a0,-1662 # ffffffffc0207a20 <commands+0x1298>
ffffffffc02030a6:	970fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02030aa:	00005697          	auipc	a3,0x5
ffffffffc02030ae:	c2668693          	addi	a3,a3,-986 # ffffffffc0207cd0 <commands+0x1548>
ffffffffc02030b2:	00004617          	auipc	a2,0x4
ffffffffc02030b6:	b5660613          	addi	a2,a2,-1194 # ffffffffc0206c08 <commands+0x480>
ffffffffc02030ba:	11200593          	li	a1,274
ffffffffc02030be:	00005517          	auipc	a0,0x5
ffffffffc02030c2:	96250513          	addi	a0,a0,-1694 # ffffffffc0207a20 <commands+0x1298>
ffffffffc02030c6:	950fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02030ca:	00005697          	auipc	a3,0x5
ffffffffc02030ce:	be668693          	addi	a3,a3,-1050 # ffffffffc0207cb0 <commands+0x1528>
ffffffffc02030d2:	00004617          	auipc	a2,0x4
ffffffffc02030d6:	b3660613          	addi	a2,a2,-1226 # ffffffffc0206c08 <commands+0x480>
ffffffffc02030da:	11000593          	li	a1,272
ffffffffc02030de:	00005517          	auipc	a0,0x5
ffffffffc02030e2:	94250513          	addi	a0,a0,-1726 # ffffffffc0207a20 <commands+0x1298>
ffffffffc02030e6:	930fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02030ea:	00005697          	auipc	a3,0x5
ffffffffc02030ee:	b9e68693          	addi	a3,a3,-1122 # ffffffffc0207c88 <commands+0x1500>
ffffffffc02030f2:	00004617          	auipc	a2,0x4
ffffffffc02030f6:	b1660613          	addi	a2,a2,-1258 # ffffffffc0206c08 <commands+0x480>
ffffffffc02030fa:	10e00593          	li	a1,270
ffffffffc02030fe:	00005517          	auipc	a0,0x5
ffffffffc0203102:	92250513          	addi	a0,a0,-1758 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0203106:	910fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020310a:	00005697          	auipc	a3,0x5
ffffffffc020310e:	b5668693          	addi	a3,a3,-1194 # ffffffffc0207c60 <commands+0x14d8>
ffffffffc0203112:	00004617          	auipc	a2,0x4
ffffffffc0203116:	af660613          	addi	a2,a2,-1290 # ffffffffc0206c08 <commands+0x480>
ffffffffc020311a:	10d00593          	li	a1,269
ffffffffc020311e:	00005517          	auipc	a0,0x5
ffffffffc0203122:	90250513          	addi	a0,a0,-1790 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0203126:	8f0fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020312a:	00005697          	auipc	a3,0x5
ffffffffc020312e:	b2668693          	addi	a3,a3,-1242 # ffffffffc0207c50 <commands+0x14c8>
ffffffffc0203132:	00004617          	auipc	a2,0x4
ffffffffc0203136:	ad660613          	addi	a2,a2,-1322 # ffffffffc0206c08 <commands+0x480>
ffffffffc020313a:	10800593          	li	a1,264
ffffffffc020313e:	00005517          	auipc	a0,0x5
ffffffffc0203142:	8e250513          	addi	a0,a0,-1822 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0203146:	8d0fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020314a:	00005697          	auipc	a3,0x5
ffffffffc020314e:	a1668693          	addi	a3,a3,-1514 # ffffffffc0207b60 <commands+0x13d8>
ffffffffc0203152:	00004617          	auipc	a2,0x4
ffffffffc0203156:	ab660613          	addi	a2,a2,-1354 # ffffffffc0206c08 <commands+0x480>
ffffffffc020315a:	10700593          	li	a1,263
ffffffffc020315e:	00005517          	auipc	a0,0x5
ffffffffc0203162:	8c250513          	addi	a0,a0,-1854 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0203166:	8b0fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020316a:	00005697          	auipc	a3,0x5
ffffffffc020316e:	ac668693          	addi	a3,a3,-1338 # ffffffffc0207c30 <commands+0x14a8>
ffffffffc0203172:	00004617          	auipc	a2,0x4
ffffffffc0203176:	a9660613          	addi	a2,a2,-1386 # ffffffffc0206c08 <commands+0x480>
ffffffffc020317a:	10600593          	li	a1,262
ffffffffc020317e:	00005517          	auipc	a0,0x5
ffffffffc0203182:	8a250513          	addi	a0,a0,-1886 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0203186:	890fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020318a:	00005697          	auipc	a3,0x5
ffffffffc020318e:	a7668693          	addi	a3,a3,-1418 # ffffffffc0207c00 <commands+0x1478>
ffffffffc0203192:	00004617          	auipc	a2,0x4
ffffffffc0203196:	a7660613          	addi	a2,a2,-1418 # ffffffffc0206c08 <commands+0x480>
ffffffffc020319a:	10500593          	li	a1,261
ffffffffc020319e:	00005517          	auipc	a0,0x5
ffffffffc02031a2:	88250513          	addi	a0,a0,-1918 # ffffffffc0207a20 <commands+0x1298>
ffffffffc02031a6:	870fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02031aa:	00005697          	auipc	a3,0x5
ffffffffc02031ae:	a3e68693          	addi	a3,a3,-1474 # ffffffffc0207be8 <commands+0x1460>
ffffffffc02031b2:	00004617          	auipc	a2,0x4
ffffffffc02031b6:	a5660613          	addi	a2,a2,-1450 # ffffffffc0206c08 <commands+0x480>
ffffffffc02031ba:	10400593          	li	a1,260
ffffffffc02031be:	00005517          	auipc	a0,0x5
ffffffffc02031c2:	86250513          	addi	a0,a0,-1950 # ffffffffc0207a20 <commands+0x1298>
ffffffffc02031c6:	850fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02031ca:	00005697          	auipc	a3,0x5
ffffffffc02031ce:	99668693          	addi	a3,a3,-1642 # ffffffffc0207b60 <commands+0x13d8>
ffffffffc02031d2:	00004617          	auipc	a2,0x4
ffffffffc02031d6:	a3660613          	addi	a2,a2,-1482 # ffffffffc0206c08 <commands+0x480>
ffffffffc02031da:	0fe00593          	li	a1,254
ffffffffc02031de:	00005517          	auipc	a0,0x5
ffffffffc02031e2:	84250513          	addi	a0,a0,-1982 # ffffffffc0207a20 <commands+0x1298>
ffffffffc02031e6:	830fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(!PageProperty(p0));
ffffffffc02031ea:	00005697          	auipc	a3,0x5
ffffffffc02031ee:	9e668693          	addi	a3,a3,-1562 # ffffffffc0207bd0 <commands+0x1448>
ffffffffc02031f2:	00004617          	auipc	a2,0x4
ffffffffc02031f6:	a1660613          	addi	a2,a2,-1514 # ffffffffc0206c08 <commands+0x480>
ffffffffc02031fa:	0f900593          	li	a1,249
ffffffffc02031fe:	00005517          	auipc	a0,0x5
ffffffffc0203202:	82250513          	addi	a0,a0,-2014 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0203206:	810fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020320a:	00005697          	auipc	a3,0x5
ffffffffc020320e:	ae668693          	addi	a3,a3,-1306 # ffffffffc0207cf0 <commands+0x1568>
ffffffffc0203212:	00004617          	auipc	a2,0x4
ffffffffc0203216:	9f660613          	addi	a2,a2,-1546 # ffffffffc0206c08 <commands+0x480>
ffffffffc020321a:	11700593          	li	a1,279
ffffffffc020321e:	00005517          	auipc	a0,0x5
ffffffffc0203222:	80250513          	addi	a0,a0,-2046 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0203226:	ff1fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(total == 0);
ffffffffc020322a:	00005697          	auipc	a3,0x5
ffffffffc020322e:	af668693          	addi	a3,a3,-1290 # ffffffffc0207d20 <commands+0x1598>
ffffffffc0203232:	00004617          	auipc	a2,0x4
ffffffffc0203236:	9d660613          	addi	a2,a2,-1578 # ffffffffc0206c08 <commands+0x480>
ffffffffc020323a:	12600593          	li	a1,294
ffffffffc020323e:	00004517          	auipc	a0,0x4
ffffffffc0203242:	7e250513          	addi	a0,a0,2018 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0203246:	fd1fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(total == nr_free_pages());
ffffffffc020324a:	00004697          	auipc	a3,0x4
ffffffffc020324e:	24668693          	addi	a3,a3,582 # ffffffffc0207490 <commands+0xd08>
ffffffffc0203252:	00004617          	auipc	a2,0x4
ffffffffc0203256:	9b660613          	addi	a2,a2,-1610 # ffffffffc0206c08 <commands+0x480>
ffffffffc020325a:	0f300593          	li	a1,243
ffffffffc020325e:	00004517          	auipc	a0,0x4
ffffffffc0203262:	7c250513          	addi	a0,a0,1986 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0203266:	fb1fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020326a:	00004697          	auipc	a3,0x4
ffffffffc020326e:	7ee68693          	addi	a3,a3,2030 # ffffffffc0207a58 <commands+0x12d0>
ffffffffc0203272:	00004617          	auipc	a2,0x4
ffffffffc0203276:	99660613          	addi	a2,a2,-1642 # ffffffffc0206c08 <commands+0x480>
ffffffffc020327a:	0ba00593          	li	a1,186
ffffffffc020327e:	00004517          	auipc	a0,0x4
ffffffffc0203282:	7a250513          	addi	a0,a0,1954 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0203286:	f91fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020328a <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020328a:	1141                	addi	sp,sp,-16
ffffffffc020328c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020328e:	16058e63          	beqz	a1,ffffffffc020340a <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0203292:	00659693          	slli	a3,a1,0x6
ffffffffc0203296:	96aa                	add	a3,a3,a0
ffffffffc0203298:	02d50d63          	beq	a0,a3,ffffffffc02032d2 <default_free_pages+0x48>
ffffffffc020329c:	651c                	ld	a5,8(a0)
ffffffffc020329e:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02032a0:	14079563          	bnez	a5,ffffffffc02033ea <default_free_pages+0x160>
ffffffffc02032a4:	651c                	ld	a5,8(a0)
ffffffffc02032a6:	8385                	srli	a5,a5,0x1
ffffffffc02032a8:	8b85                	andi	a5,a5,1
ffffffffc02032aa:	14079063          	bnez	a5,ffffffffc02033ea <default_free_pages+0x160>
ffffffffc02032ae:	87aa                	mv	a5,a0
ffffffffc02032b0:	a809                	j	ffffffffc02032c2 <default_free_pages+0x38>
ffffffffc02032b2:	6798                	ld	a4,8(a5)
ffffffffc02032b4:	8b05                	andi	a4,a4,1
ffffffffc02032b6:	12071a63          	bnez	a4,ffffffffc02033ea <default_free_pages+0x160>
ffffffffc02032ba:	6798                	ld	a4,8(a5)
ffffffffc02032bc:	8b09                	andi	a4,a4,2
ffffffffc02032be:	12071663          	bnez	a4,ffffffffc02033ea <default_free_pages+0x160>
        p->flags = 0;
ffffffffc02032c2:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc02032c6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02032ca:	04078793          	addi	a5,a5,64
ffffffffc02032ce:	fed792e3          	bne	a5,a3,ffffffffc02032b2 <default_free_pages+0x28>
    base->property = n;
ffffffffc02032d2:	2581                	sext.w	a1,a1
ffffffffc02032d4:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02032d6:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02032da:	4789                	li	a5,2
ffffffffc02032dc:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02032e0:	000a9697          	auipc	a3,0xa9
ffffffffc02032e4:	21068693          	addi	a3,a3,528 # ffffffffc02ac4f0 <free_area>
ffffffffc02032e8:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02032ea:	669c                	ld	a5,8(a3)
ffffffffc02032ec:	9db9                	addw	a1,a1,a4
ffffffffc02032ee:	000a9717          	auipc	a4,0xa9
ffffffffc02032f2:	20b72923          	sw	a1,530(a4) # ffffffffc02ac500 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02032f6:	0cd78163          	beq	a5,a3,ffffffffc02033b8 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc02032fa:	fe878713          	addi	a4,a5,-24
ffffffffc02032fe:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203300:	4801                	li	a6,0
ffffffffc0203302:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0203306:	00e56a63          	bltu	a0,a4,ffffffffc020331a <default_free_pages+0x90>
    return listelm->next;
ffffffffc020330a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020330c:	04d70f63          	beq	a4,a3,ffffffffc020336a <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203310:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203312:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0203316:	fee57ae3          	bleu	a4,a0,ffffffffc020330a <default_free_pages+0x80>
ffffffffc020331a:	00080663          	beqz	a6,ffffffffc0203326 <default_free_pages+0x9c>
ffffffffc020331e:	000a9817          	auipc	a6,0xa9
ffffffffc0203322:	1cb83923          	sd	a1,466(a6) # ffffffffc02ac4f0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203326:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203328:	e390                	sd	a2,0(a5)
ffffffffc020332a:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020332c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020332e:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0203330:	06d58a63          	beq	a1,a3,ffffffffc02033a4 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0203334:	ff85a603          	lw	a2,-8(a1) # ff8 <_binary_obj___user_faultread_out_size-0x8578>
        p = le2page(le, page_link);
ffffffffc0203338:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc020333c:	02061793          	slli	a5,a2,0x20
ffffffffc0203340:	83e9                	srli	a5,a5,0x1a
ffffffffc0203342:	97ba                	add	a5,a5,a4
ffffffffc0203344:	04f51b63          	bne	a0,a5,ffffffffc020339a <default_free_pages+0x110>
            p->property += base->property;
ffffffffc0203348:	491c                	lw	a5,16(a0)
ffffffffc020334a:	9e3d                	addw	a2,a2,a5
ffffffffc020334c:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203350:	57f5                	li	a5,-3
ffffffffc0203352:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203356:	01853803          	ld	a6,24(a0)
ffffffffc020335a:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc020335c:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc020335e:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0203362:	659c                	ld	a5,8(a1)
ffffffffc0203364:	01063023          	sd	a6,0(a2)
ffffffffc0203368:	a815                	j	ffffffffc020339c <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc020336a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020336c:	f114                	sd	a3,32(a0)
ffffffffc020336e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203370:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0203372:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203374:	00d70563          	beq	a4,a3,ffffffffc020337e <default_free_pages+0xf4>
ffffffffc0203378:	4805                	li	a6,1
ffffffffc020337a:	87ba                	mv	a5,a4
ffffffffc020337c:	bf59                	j	ffffffffc0203312 <default_free_pages+0x88>
ffffffffc020337e:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0203380:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0203382:	00d78d63          	beq	a5,a3,ffffffffc020339c <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0203386:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc020338a:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc020338e:	02061793          	slli	a5,a2,0x20
ffffffffc0203392:	83e9                	srli	a5,a5,0x1a
ffffffffc0203394:	97ba                	add	a5,a5,a4
ffffffffc0203396:	faf509e3          	beq	a0,a5,ffffffffc0203348 <default_free_pages+0xbe>
ffffffffc020339a:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020339c:	fe878713          	addi	a4,a5,-24
ffffffffc02033a0:	00d78963          	beq	a5,a3,ffffffffc02033b2 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc02033a4:	4910                	lw	a2,16(a0)
ffffffffc02033a6:	02061693          	slli	a3,a2,0x20
ffffffffc02033aa:	82e9                	srli	a3,a3,0x1a
ffffffffc02033ac:	96aa                	add	a3,a3,a0
ffffffffc02033ae:	00d70e63          	beq	a4,a3,ffffffffc02033ca <default_free_pages+0x140>
}
ffffffffc02033b2:	60a2                	ld	ra,8(sp)
ffffffffc02033b4:	0141                	addi	sp,sp,16
ffffffffc02033b6:	8082                	ret
ffffffffc02033b8:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02033ba:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02033be:	e398                	sd	a4,0(a5)
ffffffffc02033c0:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02033c2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02033c4:	ed1c                	sd	a5,24(a0)
}
ffffffffc02033c6:	0141                	addi	sp,sp,16
ffffffffc02033c8:	8082                	ret
            base->property += p->property;
ffffffffc02033ca:	ff87a703          	lw	a4,-8(a5)
ffffffffc02033ce:	ff078693          	addi	a3,a5,-16
ffffffffc02033d2:	9e39                	addw	a2,a2,a4
ffffffffc02033d4:	c910                	sw	a2,16(a0)
ffffffffc02033d6:	5775                	li	a4,-3
ffffffffc02033d8:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02033dc:	6398                	ld	a4,0(a5)
ffffffffc02033de:	679c                	ld	a5,8(a5)
}
ffffffffc02033e0:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02033e2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02033e4:	e398                	sd	a4,0(a5)
ffffffffc02033e6:	0141                	addi	sp,sp,16
ffffffffc02033e8:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02033ea:	00005697          	auipc	a3,0x5
ffffffffc02033ee:	94668693          	addi	a3,a3,-1722 # ffffffffc0207d30 <commands+0x15a8>
ffffffffc02033f2:	00004617          	auipc	a2,0x4
ffffffffc02033f6:	81660613          	addi	a2,a2,-2026 # ffffffffc0206c08 <commands+0x480>
ffffffffc02033fa:	08300593          	li	a1,131
ffffffffc02033fe:	00004517          	auipc	a0,0x4
ffffffffc0203402:	62250513          	addi	a0,a0,1570 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0203406:	e11fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(n > 0);
ffffffffc020340a:	00005697          	auipc	a3,0x5
ffffffffc020340e:	94e68693          	addi	a3,a3,-1714 # ffffffffc0207d58 <commands+0x15d0>
ffffffffc0203412:	00003617          	auipc	a2,0x3
ffffffffc0203416:	7f660613          	addi	a2,a2,2038 # ffffffffc0206c08 <commands+0x480>
ffffffffc020341a:	08000593          	li	a1,128
ffffffffc020341e:	00004517          	auipc	a0,0x4
ffffffffc0203422:	60250513          	addi	a0,a0,1538 # ffffffffc0207a20 <commands+0x1298>
ffffffffc0203426:	df1fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020342a <default_alloc_pages>:
    assert(n > 0);
ffffffffc020342a:	c959                	beqz	a0,ffffffffc02034c0 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020342c:	000a9597          	auipc	a1,0xa9
ffffffffc0203430:	0c458593          	addi	a1,a1,196 # ffffffffc02ac4f0 <free_area>
ffffffffc0203434:	0105a803          	lw	a6,16(a1)
ffffffffc0203438:	862a                	mv	a2,a0
ffffffffc020343a:	02081793          	slli	a5,a6,0x20
ffffffffc020343e:	9381                	srli	a5,a5,0x20
ffffffffc0203440:	00a7ee63          	bltu	a5,a0,ffffffffc020345c <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0203444:	87ae                	mv	a5,a1
ffffffffc0203446:	a801                	j	ffffffffc0203456 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0203448:	ff87a703          	lw	a4,-8(a5)
ffffffffc020344c:	02071693          	slli	a3,a4,0x20
ffffffffc0203450:	9281                	srli	a3,a3,0x20
ffffffffc0203452:	00c6f763          	bleu	a2,a3,ffffffffc0203460 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0203456:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203458:	feb798e3          	bne	a5,a1,ffffffffc0203448 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020345c:	4501                	li	a0,0
}
ffffffffc020345e:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0203460:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0203464:	dd6d                	beqz	a0,ffffffffc020345e <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0203466:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020346a:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc020346e:	00060e1b          	sext.w	t3,a2
ffffffffc0203472:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0203476:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc020347a:	02d67863          	bleu	a3,a2,ffffffffc02034aa <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc020347e:	061a                	slli	a2,a2,0x6
ffffffffc0203480:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0203482:	41c7073b          	subw	a4,a4,t3
ffffffffc0203486:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203488:	00860693          	addi	a3,a2,8
ffffffffc020348c:	4709                	li	a4,2
ffffffffc020348e:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203492:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203496:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc020349a:	0105a803          	lw	a6,16(a1)
ffffffffc020349e:	e314                	sd	a3,0(a4)
ffffffffc02034a0:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc02034a4:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc02034a6:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc02034aa:	41c8083b          	subw	a6,a6,t3
ffffffffc02034ae:	000a9717          	auipc	a4,0xa9
ffffffffc02034b2:	05072923          	sw	a6,82(a4) # ffffffffc02ac500 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02034b6:	5775                	li	a4,-3
ffffffffc02034b8:	17c1                	addi	a5,a5,-16
ffffffffc02034ba:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02034be:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02034c0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02034c2:	00005697          	auipc	a3,0x5
ffffffffc02034c6:	89668693          	addi	a3,a3,-1898 # ffffffffc0207d58 <commands+0x15d0>
ffffffffc02034ca:	00003617          	auipc	a2,0x3
ffffffffc02034ce:	73e60613          	addi	a2,a2,1854 # ffffffffc0206c08 <commands+0x480>
ffffffffc02034d2:	06200593          	li	a1,98
ffffffffc02034d6:	00004517          	auipc	a0,0x4
ffffffffc02034da:	54a50513          	addi	a0,a0,1354 # ffffffffc0207a20 <commands+0x1298>
default_alloc_pages(size_t n) {
ffffffffc02034de:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02034e0:	d37fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02034e4 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02034e4:	1141                	addi	sp,sp,-16
ffffffffc02034e6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02034e8:	c1ed                	beqz	a1,ffffffffc02035ca <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc02034ea:	00659693          	slli	a3,a1,0x6
ffffffffc02034ee:	96aa                	add	a3,a3,a0
ffffffffc02034f0:	02d50463          	beq	a0,a3,ffffffffc0203518 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02034f4:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02034f6:	87aa                	mv	a5,a0
ffffffffc02034f8:	8b05                	andi	a4,a4,1
ffffffffc02034fa:	e709                	bnez	a4,ffffffffc0203504 <default_init_memmap+0x20>
ffffffffc02034fc:	a07d                	j	ffffffffc02035aa <default_init_memmap+0xc6>
ffffffffc02034fe:	6798                	ld	a4,8(a5)
ffffffffc0203500:	8b05                	andi	a4,a4,1
ffffffffc0203502:	c745                	beqz	a4,ffffffffc02035aa <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc0203504:	0007a823          	sw	zero,16(a5)
ffffffffc0203508:	0007b423          	sd	zero,8(a5)
ffffffffc020350c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203510:	04078793          	addi	a5,a5,64
ffffffffc0203514:	fed795e3          	bne	a5,a3,ffffffffc02034fe <default_init_memmap+0x1a>
    base->property = n;
ffffffffc0203518:	2581                	sext.w	a1,a1
ffffffffc020351a:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020351c:	4789                	li	a5,2
ffffffffc020351e:	00850713          	addi	a4,a0,8
ffffffffc0203522:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0203526:	000a9697          	auipc	a3,0xa9
ffffffffc020352a:	fca68693          	addi	a3,a3,-54 # ffffffffc02ac4f0 <free_area>
ffffffffc020352e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203530:	669c                	ld	a5,8(a3)
ffffffffc0203532:	9db9                	addw	a1,a1,a4
ffffffffc0203534:	000a9717          	auipc	a4,0xa9
ffffffffc0203538:	fcb72623          	sw	a1,-52(a4) # ffffffffc02ac500 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020353c:	04d78a63          	beq	a5,a3,ffffffffc0203590 <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0203540:	fe878713          	addi	a4,a5,-24
ffffffffc0203544:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203546:	4801                	li	a6,0
ffffffffc0203548:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020354c:	00e56a63          	bltu	a0,a4,ffffffffc0203560 <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0203550:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203552:	02d70563          	beq	a4,a3,ffffffffc020357c <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203556:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203558:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020355c:	fee57ae3          	bleu	a4,a0,ffffffffc0203550 <default_init_memmap+0x6c>
ffffffffc0203560:	00080663          	beqz	a6,ffffffffc020356c <default_init_memmap+0x88>
ffffffffc0203564:	000a9717          	auipc	a4,0xa9
ffffffffc0203568:	f8b73623          	sd	a1,-116(a4) # ffffffffc02ac4f0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020356c:	6398                	ld	a4,0(a5)
}
ffffffffc020356e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203570:	e390                	sd	a2,0(a5)
ffffffffc0203572:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203574:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203576:	ed18                	sd	a4,24(a0)
ffffffffc0203578:	0141                	addi	sp,sp,16
ffffffffc020357a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020357c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020357e:	f114                	sd	a3,32(a0)
ffffffffc0203580:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203582:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0203584:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203586:	00d70e63          	beq	a4,a3,ffffffffc02035a2 <default_init_memmap+0xbe>
ffffffffc020358a:	4805                	li	a6,1
ffffffffc020358c:	87ba                	mv	a5,a4
ffffffffc020358e:	b7e9                	j	ffffffffc0203558 <default_init_memmap+0x74>
}
ffffffffc0203590:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0203592:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0203596:	e398                	sd	a4,0(a5)
ffffffffc0203598:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020359a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020359c:	ed1c                	sd	a5,24(a0)
}
ffffffffc020359e:	0141                	addi	sp,sp,16
ffffffffc02035a0:	8082                	ret
ffffffffc02035a2:	60a2                	ld	ra,8(sp)
ffffffffc02035a4:	e290                	sd	a2,0(a3)
ffffffffc02035a6:	0141                	addi	sp,sp,16
ffffffffc02035a8:	8082                	ret
        assert(PageReserved(p));
ffffffffc02035aa:	00004697          	auipc	a3,0x4
ffffffffc02035ae:	7b668693          	addi	a3,a3,1974 # ffffffffc0207d60 <commands+0x15d8>
ffffffffc02035b2:	00003617          	auipc	a2,0x3
ffffffffc02035b6:	65660613          	addi	a2,a2,1622 # ffffffffc0206c08 <commands+0x480>
ffffffffc02035ba:	04900593          	li	a1,73
ffffffffc02035be:	00004517          	auipc	a0,0x4
ffffffffc02035c2:	46250513          	addi	a0,a0,1122 # ffffffffc0207a20 <commands+0x1298>
ffffffffc02035c6:	c51fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(n > 0);
ffffffffc02035ca:	00004697          	auipc	a3,0x4
ffffffffc02035ce:	78e68693          	addi	a3,a3,1934 # ffffffffc0207d58 <commands+0x15d0>
ffffffffc02035d2:	00003617          	auipc	a2,0x3
ffffffffc02035d6:	63660613          	addi	a2,a2,1590 # ffffffffc0206c08 <commands+0x480>
ffffffffc02035da:	04600593          	li	a1,70
ffffffffc02035de:	00004517          	auipc	a0,0x4
ffffffffc02035e2:	44250513          	addi	a0,a0,1090 # ffffffffc0207a20 <commands+0x1298>
ffffffffc02035e6:	c31fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02035ea <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc02035ea:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02035ec:	00004617          	auipc	a2,0x4
ffffffffc02035f0:	d3460613          	addi	a2,a2,-716 # ffffffffc0207320 <commands+0xb98>
ffffffffc02035f4:	06200593          	li	a1,98
ffffffffc02035f8:	00004517          	auipc	a0,0x4
ffffffffc02035fc:	d4850513          	addi	a0,a0,-696 # ffffffffc0207340 <commands+0xbb8>
pa2page(uintptr_t pa) {
ffffffffc0203600:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0203602:	c15fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203606 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0203606:	715d                	addi	sp,sp,-80
ffffffffc0203608:	e0a2                	sd	s0,64(sp)
ffffffffc020360a:	fc26                	sd	s1,56(sp)
ffffffffc020360c:	f84a                	sd	s2,48(sp)
ffffffffc020360e:	f44e                	sd	s3,40(sp)
ffffffffc0203610:	f052                	sd	s4,32(sp)
ffffffffc0203612:	ec56                	sd	s5,24(sp)
ffffffffc0203614:	e486                	sd	ra,72(sp)
ffffffffc0203616:	842a                	mv	s0,a0
ffffffffc0203618:	000a9497          	auipc	s1,0xa9
ffffffffc020361c:	ef048493          	addi	s1,s1,-272 # ffffffffc02ac508 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);// 还原中断

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203620:	4985                	li	s3,1
ffffffffc0203622:	000a9a17          	auipc	s4,0xa9
ffffffffc0203626:	da6a0a13          	addi	s4,s4,-602 # ffffffffc02ac3c8 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);// 交换空间
ffffffffc020362a:	0005091b          	sext.w	s2,a0
ffffffffc020362e:	000a9a97          	auipc	s5,0xa9
ffffffffc0203632:	de2a8a93          	addi	s5,s5,-542 # ffffffffc02ac410 <check_mm_struct>
ffffffffc0203636:	a00d                	j	ffffffffc0203658 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0203638:	609c                	ld	a5,0(s1)
ffffffffc020363a:	6f9c                	ld	a5,24(a5)
ffffffffc020363c:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);// 交换空间
ffffffffc020363e:	4601                	li	a2,0
ffffffffc0203640:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203642:	ed0d                	bnez	a0,ffffffffc020367c <alloc_pages+0x76>
ffffffffc0203644:	0289ec63          	bltu	s3,s0,ffffffffc020367c <alloc_pages+0x76>
ffffffffc0203648:	000a2783          	lw	a5,0(s4)
ffffffffc020364c:	2781                	sext.w	a5,a5
ffffffffc020364e:	c79d                	beqz	a5,ffffffffc020367c <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);// 交换空间
ffffffffc0203650:	000ab503          	ld	a0,0(s5)
ffffffffc0203654:	a41fe0ef          	jal	ra,ffffffffc0202094 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203658:	100027f3          	csrr	a5,sstatus
ffffffffc020365c:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc020365e:	8522                	mv	a0,s0
ffffffffc0203660:	dfe1                	beqz	a5,ffffffffc0203638 <alloc_pages+0x32>
        intr_disable();
ffffffffc0203662:	ffbfc0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0203666:	609c                	ld	a5,0(s1)
ffffffffc0203668:	8522                	mv	a0,s0
ffffffffc020366a:	6f9c                	ld	a5,24(a5)
ffffffffc020366c:	9782                	jalr	a5
ffffffffc020366e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0203670:	fe7fc0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0203674:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);// 交换空间
ffffffffc0203676:	4601                	li	a2,0
ffffffffc0203678:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020367a:	d569                	beqz	a0,ffffffffc0203644 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020367c:	60a6                	ld	ra,72(sp)
ffffffffc020367e:	6406                	ld	s0,64(sp)
ffffffffc0203680:	74e2                	ld	s1,56(sp)
ffffffffc0203682:	7942                	ld	s2,48(sp)
ffffffffc0203684:	79a2                	ld	s3,40(sp)
ffffffffc0203686:	7a02                	ld	s4,32(sp)
ffffffffc0203688:	6ae2                	ld	s5,24(sp)
ffffffffc020368a:	6161                	addi	sp,sp,80
ffffffffc020368c:	8082                	ret

ffffffffc020368e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020368e:	100027f3          	csrr	a5,sstatus
ffffffffc0203692:	8b89                	andi	a5,a5,2
ffffffffc0203694:	eb89                	bnez	a5,ffffffffc02036a6 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0203696:	000a9797          	auipc	a5,0xa9
ffffffffc020369a:	e7278793          	addi	a5,a5,-398 # ffffffffc02ac508 <pmm_manager>
ffffffffc020369e:	639c                	ld	a5,0(a5)
ffffffffc02036a0:	0207b303          	ld	t1,32(a5)
ffffffffc02036a4:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc02036a6:	1101                	addi	sp,sp,-32
ffffffffc02036a8:	ec06                	sd	ra,24(sp)
ffffffffc02036aa:	e822                	sd	s0,16(sp)
ffffffffc02036ac:	e426                	sd	s1,8(sp)
ffffffffc02036ae:	842a                	mv	s0,a0
ffffffffc02036b0:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02036b2:	fabfc0ef          	jal	ra,ffffffffc020065c <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02036b6:	000a9797          	auipc	a5,0xa9
ffffffffc02036ba:	e5278793          	addi	a5,a5,-430 # ffffffffc02ac508 <pmm_manager>
ffffffffc02036be:	639c                	ld	a5,0(a5)
ffffffffc02036c0:	85a6                	mv	a1,s1
ffffffffc02036c2:	8522                	mv	a0,s0
ffffffffc02036c4:	739c                	ld	a5,32(a5)
ffffffffc02036c6:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02036c8:	6442                	ld	s0,16(sp)
ffffffffc02036ca:	60e2                	ld	ra,24(sp)
ffffffffc02036cc:	64a2                	ld	s1,8(sp)
ffffffffc02036ce:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02036d0:	f87fc06f          	j	ffffffffc0200656 <intr_enable>

ffffffffc02036d4 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02036d4:	100027f3          	csrr	a5,sstatus
ffffffffc02036d8:	8b89                	andi	a5,a5,2
ffffffffc02036da:	eb89                	bnez	a5,ffffffffc02036ec <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02036dc:	000a9797          	auipc	a5,0xa9
ffffffffc02036e0:	e2c78793          	addi	a5,a5,-468 # ffffffffc02ac508 <pmm_manager>
ffffffffc02036e4:	639c                	ld	a5,0(a5)
ffffffffc02036e6:	0287b303          	ld	t1,40(a5)
ffffffffc02036ea:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc02036ec:	1141                	addi	sp,sp,-16
ffffffffc02036ee:	e406                	sd	ra,8(sp)
ffffffffc02036f0:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02036f2:	f6bfc0ef          	jal	ra,ffffffffc020065c <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02036f6:	000a9797          	auipc	a5,0xa9
ffffffffc02036fa:	e1278793          	addi	a5,a5,-494 # ffffffffc02ac508 <pmm_manager>
ffffffffc02036fe:	639c                	ld	a5,0(a5)
ffffffffc0203700:	779c                	ld	a5,40(a5)
ffffffffc0203702:	9782                	jalr	a5
ffffffffc0203704:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203706:	f51fc0ef          	jal	ra,ffffffffc0200656 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc020370a:	8522                	mv	a0,s0
ffffffffc020370c:	60a2                	ld	ra,8(sp)
ffffffffc020370e:	6402                	ld	s0,0(sp)
ffffffffc0203710:	0141                	addi	sp,sp,16
ffffffffc0203712:	8082                	ret

ffffffffc0203714 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203714:	7139                	addi	sp,sp,-64
ffffffffc0203716:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];// 一级页表项
ffffffffc0203718:	01e5d493          	srli	s1,a1,0x1e
ffffffffc020371c:	1ff4f493          	andi	s1,s1,511
ffffffffc0203720:	048e                	slli	s1,s1,0x3
ffffffffc0203722:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203724:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203726:	f04a                	sd	s2,32(sp)
ffffffffc0203728:	ec4e                	sd	s3,24(sp)
ffffffffc020372a:	e852                	sd	s4,16(sp)
ffffffffc020372c:	fc06                	sd	ra,56(sp)
ffffffffc020372e:	f822                	sd	s0,48(sp)
ffffffffc0203730:	e456                	sd	s5,8(sp)
ffffffffc0203732:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203734:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203738:	892e                	mv	s2,a1
ffffffffc020373a:	8a32                	mv	s4,a2
ffffffffc020373c:	000a9997          	auipc	s3,0xa9
ffffffffc0203740:	ca498993          	addi	s3,s3,-860 # ffffffffc02ac3e0 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203744:	e7bd                	bnez	a5,ffffffffc02037b2 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {// 不需要新分配或者分配失败
ffffffffc0203746:	12060c63          	beqz	a2,ffffffffc020387e <get_pte+0x16a>
ffffffffc020374a:	4505                	li	a0,1
ffffffffc020374c:	ebbff0ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0203750:	842a                	mv	s0,a0
ffffffffc0203752:	12050663          	beqz	a0,ffffffffc020387e <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0203756:	000a9b17          	auipc	s6,0xa9
ffffffffc020375a:	dcab0b13          	addi	s6,s6,-566 # ffffffffc02ac520 <pages>
ffffffffc020375e:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0203762:	4785                	li	a5,1
            return NULL;// 短路
        }
        set_page_ref(page, 1);// 设置引用次数
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203764:	000a9997          	auipc	s3,0xa9
ffffffffc0203768:	c7c98993          	addi	s3,s3,-900 # ffffffffc02ac3e0 <npage>
    return page - pages + nbase;
ffffffffc020376c:	40a40533          	sub	a0,s0,a0
ffffffffc0203770:	00080ab7          	lui	s5,0x80
ffffffffc0203774:	8519                	srai	a0,a0,0x6
ffffffffc0203776:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc020377a:	c01c                	sw	a5,0(s0)
ffffffffc020377c:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc020377e:	9556                	add	a0,a0,s5
ffffffffc0203780:	83b1                	srli	a5,a5,0xc
ffffffffc0203782:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203784:	0532                	slli	a0,a0,0xc
ffffffffc0203786:	14e7f363          	bleu	a4,a5,ffffffffc02038cc <get_pte+0x1b8>
ffffffffc020378a:	000a9797          	auipc	a5,0xa9
ffffffffc020378e:	d8678793          	addi	a5,a5,-634 # ffffffffc02ac510 <va_pa_offset>
ffffffffc0203792:	639c                	ld	a5,0(a5)
ffffffffc0203794:	6605                	lui	a2,0x1
ffffffffc0203796:	4581                	li	a1,0
ffffffffc0203798:	953e                	add	a0,a0,a5
ffffffffc020379a:	23f020ef          	jal	ra,ffffffffc02061d8 <memset>
    return page - pages + nbase;
ffffffffc020379e:	000b3683          	ld	a3,0(s6)
ffffffffc02037a2:	40d406b3          	sub	a3,s0,a3
ffffffffc02037a6:	8699                	srai	a3,a3,0x6
ffffffffc02037a8:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02037aa:	06aa                	slli	a3,a3,0xa
ffffffffc02037ac:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02037b0:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];// 二级页表项
ffffffffc02037b2:	77fd                	lui	a5,0xfffff
ffffffffc02037b4:	068a                	slli	a3,a3,0x2
ffffffffc02037b6:	0009b703          	ld	a4,0(s3)
ffffffffc02037ba:	8efd                	and	a3,a3,a5
ffffffffc02037bc:	00c6d793          	srli	a5,a3,0xc
ffffffffc02037c0:	0ce7f163          	bleu	a4,a5,ffffffffc0203882 <get_pte+0x16e>
ffffffffc02037c4:	000a9a97          	auipc	s5,0xa9
ffffffffc02037c8:	d4ca8a93          	addi	s5,s5,-692 # ffffffffc02ac510 <va_pa_offset>
ffffffffc02037cc:	000ab403          	ld	s0,0(s5)
ffffffffc02037d0:	01595793          	srli	a5,s2,0x15
ffffffffc02037d4:	1ff7f793          	andi	a5,a5,511
ffffffffc02037d8:	96a2                	add	a3,a3,s0
ffffffffc02037da:	00379413          	slli	s0,a5,0x3
ffffffffc02037de:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc02037e0:	6014                	ld	a3,0(s0)
ffffffffc02037e2:	0016f793          	andi	a5,a3,1
ffffffffc02037e6:	e3ad                	bnez	a5,ffffffffc0203848 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02037e8:	080a0b63          	beqz	s4,ffffffffc020387e <get_pte+0x16a>
ffffffffc02037ec:	4505                	li	a0,1
ffffffffc02037ee:	e19ff0ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc02037f2:	84aa                	mv	s1,a0
ffffffffc02037f4:	c549                	beqz	a0,ffffffffc020387e <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc02037f6:	000a9b17          	auipc	s6,0xa9
ffffffffc02037fa:	d2ab0b13          	addi	s6,s6,-726 # ffffffffc02ac520 <pages>
ffffffffc02037fe:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0203802:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0203804:	00080a37          	lui	s4,0x80
ffffffffc0203808:	40a48533          	sub	a0,s1,a0
ffffffffc020380c:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020380e:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0203812:	c09c                	sw	a5,0(s1)
ffffffffc0203814:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0203816:	9552                	add	a0,a0,s4
ffffffffc0203818:	83b1                	srli	a5,a5,0xc
ffffffffc020381a:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020381c:	0532                	slli	a0,a0,0xc
ffffffffc020381e:	08e7fa63          	bleu	a4,a5,ffffffffc02038b2 <get_pte+0x19e>
ffffffffc0203822:	000ab783          	ld	a5,0(s5)
ffffffffc0203826:	6605                	lui	a2,0x1
ffffffffc0203828:	4581                	li	a1,0
ffffffffc020382a:	953e                	add	a0,a0,a5
ffffffffc020382c:	1ad020ef          	jal	ra,ffffffffc02061d8 <memset>
    return page - pages + nbase;
ffffffffc0203830:	000b3683          	ld	a3,0(s6)
ffffffffc0203834:	40d486b3          	sub	a3,s1,a3
ffffffffc0203838:	8699                	srai	a3,a3,0x6
ffffffffc020383a:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020383c:	06aa                	slli	a3,a3,0xa
ffffffffc020383e:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0203842:	e014                	sd	a3,0(s0)
ffffffffc0203844:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];// 三级页表项
ffffffffc0203848:	068a                	slli	a3,a3,0x2
ffffffffc020384a:	757d                	lui	a0,0xfffff
ffffffffc020384c:	8ee9                	and	a3,a3,a0
ffffffffc020384e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0203852:	04e7f463          	bleu	a4,a5,ffffffffc020389a <get_pte+0x186>
ffffffffc0203856:	000ab503          	ld	a0,0(s5)
ffffffffc020385a:	00c95793          	srli	a5,s2,0xc
ffffffffc020385e:	1ff7f793          	andi	a5,a5,511
ffffffffc0203862:	96aa                	add	a3,a3,a0
ffffffffc0203864:	00379513          	slli	a0,a5,0x3
ffffffffc0203868:	9536                	add	a0,a0,a3
}
ffffffffc020386a:	70e2                	ld	ra,56(sp)
ffffffffc020386c:	7442                	ld	s0,48(sp)
ffffffffc020386e:	74a2                	ld	s1,40(sp)
ffffffffc0203870:	7902                	ld	s2,32(sp)
ffffffffc0203872:	69e2                	ld	s3,24(sp)
ffffffffc0203874:	6a42                	ld	s4,16(sp)
ffffffffc0203876:	6aa2                	ld	s5,8(sp)
ffffffffc0203878:	6b02                	ld	s6,0(sp)
ffffffffc020387a:	6121                	addi	sp,sp,64
ffffffffc020387c:	8082                	ret
            return NULL;// 短路
ffffffffc020387e:	4501                	li	a0,0
ffffffffc0203880:	b7ed                	j	ffffffffc020386a <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];// 二级页表项
ffffffffc0203882:	00004617          	auipc	a2,0x4
ffffffffc0203886:	ace60613          	addi	a2,a2,-1330 # ffffffffc0207350 <commands+0xbc8>
ffffffffc020388a:	0e500593          	li	a1,229
ffffffffc020388e:	00004517          	auipc	a0,0x4
ffffffffc0203892:	55250513          	addi	a0,a0,1362 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0203896:	981fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];// 三级页表项
ffffffffc020389a:	00004617          	auipc	a2,0x4
ffffffffc020389e:	ab660613          	addi	a2,a2,-1354 # ffffffffc0207350 <commands+0xbc8>
ffffffffc02038a2:	0f000593          	li	a1,240
ffffffffc02038a6:	00004517          	auipc	a0,0x4
ffffffffc02038aa:	53a50513          	addi	a0,a0,1338 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc02038ae:	969fc0ef          	jal	ra,ffffffffc0200216 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02038b2:	86aa                	mv	a3,a0
ffffffffc02038b4:	00004617          	auipc	a2,0x4
ffffffffc02038b8:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0207350 <commands+0xbc8>
ffffffffc02038bc:	0ed00593          	li	a1,237
ffffffffc02038c0:	00004517          	auipc	a0,0x4
ffffffffc02038c4:	52050513          	addi	a0,a0,1312 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc02038c8:	94ffc0ef          	jal	ra,ffffffffc0200216 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02038cc:	86aa                	mv	a3,a0
ffffffffc02038ce:	00004617          	auipc	a2,0x4
ffffffffc02038d2:	a8260613          	addi	a2,a2,-1406 # ffffffffc0207350 <commands+0xbc8>
ffffffffc02038d6:	0e100593          	li	a1,225
ffffffffc02038da:	00004517          	auipc	a0,0x4
ffffffffc02038de:	50650513          	addi	a0,a0,1286 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc02038e2:	935fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02038e6 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02038e6:	1141                	addi	sp,sp,-16
ffffffffc02038e8:	e022                	sd	s0,0(sp)
ffffffffc02038ea:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02038ec:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02038ee:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02038f0:	e25ff0ef          	jal	ra,ffffffffc0203714 <get_pte>
    if (ptep_store != NULL) {
ffffffffc02038f4:	c011                	beqz	s0,ffffffffc02038f8 <get_page+0x12>
        *ptep_store = ptep;// 获取页表项
ffffffffc02038f6:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02038f8:	c129                	beqz	a0,ffffffffc020393a <get_page+0x54>
ffffffffc02038fa:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);// 返回页面
    }
    return NULL;
ffffffffc02038fc:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02038fe:	0017f713          	andi	a4,a5,1
ffffffffc0203902:	e709                	bnez	a4,ffffffffc020390c <get_page+0x26>
}
ffffffffc0203904:	60a2                	ld	ra,8(sp)
ffffffffc0203906:	6402                	ld	s0,0(sp)
ffffffffc0203908:	0141                	addi	sp,sp,16
ffffffffc020390a:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc020390c:	000a9717          	auipc	a4,0xa9
ffffffffc0203910:	ad470713          	addi	a4,a4,-1324 # ffffffffc02ac3e0 <npage>
ffffffffc0203914:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203916:	078a                	slli	a5,a5,0x2
ffffffffc0203918:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020391a:	02e7f563          	bleu	a4,a5,ffffffffc0203944 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc020391e:	000a9717          	auipc	a4,0xa9
ffffffffc0203922:	c0270713          	addi	a4,a4,-1022 # ffffffffc02ac520 <pages>
ffffffffc0203926:	6308                	ld	a0,0(a4)
ffffffffc0203928:	60a2                	ld	ra,8(sp)
ffffffffc020392a:	6402                	ld	s0,0(sp)
ffffffffc020392c:	fff80737          	lui	a4,0xfff80
ffffffffc0203930:	97ba                	add	a5,a5,a4
ffffffffc0203932:	079a                	slli	a5,a5,0x6
ffffffffc0203934:	953e                	add	a0,a0,a5
ffffffffc0203936:	0141                	addi	sp,sp,16
ffffffffc0203938:	8082                	ret
ffffffffc020393a:	60a2                	ld	ra,8(sp)
ffffffffc020393c:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc020393e:	4501                	li	a0,0
}
ffffffffc0203940:	0141                	addi	sp,sp,16
ffffffffc0203942:	8082                	ret
ffffffffc0203944:	ca7ff0ef          	jal	ra,ffffffffc02035ea <pa2page.part.4>

ffffffffc0203948 <unmap_range>:
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

// 清除一块区域的内存空间和映射
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203948:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020394a:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020394e:	ec86                	sd	ra,88(sp)
ffffffffc0203950:	e8a2                	sd	s0,80(sp)
ffffffffc0203952:	e4a6                	sd	s1,72(sp)
ffffffffc0203954:	e0ca                	sd	s2,64(sp)
ffffffffc0203956:	fc4e                	sd	s3,56(sp)
ffffffffc0203958:	f852                	sd	s4,48(sp)
ffffffffc020395a:	f456                	sd	s5,40(sp)
ffffffffc020395c:	f05a                	sd	s6,32(sp)
ffffffffc020395e:	ec5e                	sd	s7,24(sp)
ffffffffc0203960:	e862                	sd	s8,16(sp)
ffffffffc0203962:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203964:	03479713          	slli	a4,a5,0x34
ffffffffc0203968:	eb71                	bnez	a4,ffffffffc0203a3c <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc020396a:	002007b7          	lui	a5,0x200
ffffffffc020396e:	842e                	mv	s0,a1
ffffffffc0203970:	0af5e663          	bltu	a1,a5,ffffffffc0203a1c <unmap_range+0xd4>
ffffffffc0203974:	8932                	mv	s2,a2
ffffffffc0203976:	0ac5f363          	bleu	a2,a1,ffffffffc0203a1c <unmap_range+0xd4>
ffffffffc020397a:	4785                	li	a5,1
ffffffffc020397c:	07fe                	slli	a5,a5,0x1f
ffffffffc020397e:	08c7ef63          	bltu	a5,a2,ffffffffc0203a1c <unmap_range+0xd4>
ffffffffc0203982:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0203984:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203986:	000a9c97          	auipc	s9,0xa9
ffffffffc020398a:	a5ac8c93          	addi	s9,s9,-1446 # ffffffffc02ac3e0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020398e:	000a9c17          	auipc	s8,0xa9
ffffffffc0203992:	b92c0c13          	addi	s8,s8,-1134 # ffffffffc02ac520 <pages>
ffffffffc0203996:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020399a:	00200b37          	lui	s6,0x200
ffffffffc020399e:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02039a2:	4601                	li	a2,0
ffffffffc02039a4:	85a2                	mv	a1,s0
ffffffffc02039a6:	854e                	mv	a0,s3
ffffffffc02039a8:	d6dff0ef          	jal	ra,ffffffffc0203714 <get_pte>
ffffffffc02039ac:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02039ae:	cd21                	beqz	a0,ffffffffc0203a06 <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc02039b0:	611c                	ld	a5,0(a0)
ffffffffc02039b2:	e38d                	bnez	a5,ffffffffc02039d4 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc02039b4:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02039b6:	ff2466e3          	bltu	s0,s2,ffffffffc02039a2 <unmap_range+0x5a>
}
ffffffffc02039ba:	60e6                	ld	ra,88(sp)
ffffffffc02039bc:	6446                	ld	s0,80(sp)
ffffffffc02039be:	64a6                	ld	s1,72(sp)
ffffffffc02039c0:	6906                	ld	s2,64(sp)
ffffffffc02039c2:	79e2                	ld	s3,56(sp)
ffffffffc02039c4:	7a42                	ld	s4,48(sp)
ffffffffc02039c6:	7aa2                	ld	s5,40(sp)
ffffffffc02039c8:	7b02                	ld	s6,32(sp)
ffffffffc02039ca:	6be2                	ld	s7,24(sp)
ffffffffc02039cc:	6c42                	ld	s8,16(sp)
ffffffffc02039ce:	6ca2                	ld	s9,8(sp)
ffffffffc02039d0:	6125                	addi	sp,sp,96
ffffffffc02039d2:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02039d4:	0017f713          	andi	a4,a5,1
ffffffffc02039d8:	df71                	beqz	a4,ffffffffc02039b4 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc02039da:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02039de:	078a                	slli	a5,a5,0x2
ffffffffc02039e0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02039e2:	06e7fd63          	bleu	a4,a5,ffffffffc0203a5c <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc02039e6:	000c3503          	ld	a0,0(s8)
ffffffffc02039ea:	97de                	add	a5,a5,s7
ffffffffc02039ec:	079a                	slli	a5,a5,0x6
ffffffffc02039ee:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02039f0:	411c                	lw	a5,0(a0)
ffffffffc02039f2:	fff7871b          	addiw	a4,a5,-1
ffffffffc02039f6:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02039f8:	cf11                	beqz	a4,ffffffffc0203a14 <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02039fa:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02039fe:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0203a02:	9452                	add	s0,s0,s4
ffffffffc0203a04:	bf4d                	j	ffffffffc02039b6 <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203a06:	945a                	add	s0,s0,s6
ffffffffc0203a08:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0203a0c:	d45d                	beqz	s0,ffffffffc02039ba <unmap_range+0x72>
ffffffffc0203a0e:	f9246ae3          	bltu	s0,s2,ffffffffc02039a2 <unmap_range+0x5a>
ffffffffc0203a12:	b765                	j	ffffffffc02039ba <unmap_range+0x72>
            free_page(page);
ffffffffc0203a14:	4585                	li	a1,1
ffffffffc0203a16:	c79ff0ef          	jal	ra,ffffffffc020368e <free_pages>
ffffffffc0203a1a:	b7c5                	j	ffffffffc02039fa <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0203a1c:	00005697          	auipc	a3,0x5
ffffffffc0203a20:	94468693          	addi	a3,a3,-1724 # ffffffffc0208360 <default_pmm_manager+0x5f0>
ffffffffc0203a24:	00003617          	auipc	a2,0x3
ffffffffc0203a28:	1e460613          	addi	a2,a2,484 # ffffffffc0206c08 <commands+0x480>
ffffffffc0203a2c:	11400593          	li	a1,276
ffffffffc0203a30:	00004517          	auipc	a0,0x4
ffffffffc0203a34:	3b050513          	addi	a0,a0,944 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0203a38:	fdefc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203a3c:	00005697          	auipc	a3,0x5
ffffffffc0203a40:	8f468693          	addi	a3,a3,-1804 # ffffffffc0208330 <default_pmm_manager+0x5c0>
ffffffffc0203a44:	00003617          	auipc	a2,0x3
ffffffffc0203a48:	1c460613          	addi	a2,a2,452 # ffffffffc0206c08 <commands+0x480>
ffffffffc0203a4c:	11300593          	li	a1,275
ffffffffc0203a50:	00004517          	auipc	a0,0x4
ffffffffc0203a54:	39050513          	addi	a0,a0,912 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0203a58:	fbefc0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0203a5c:	b8fff0ef          	jal	ra,ffffffffc02035ea <pa2page.part.4>

ffffffffc0203a60 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203a60:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203a62:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203a66:	fc86                	sd	ra,120(sp)
ffffffffc0203a68:	f8a2                	sd	s0,112(sp)
ffffffffc0203a6a:	f4a6                	sd	s1,104(sp)
ffffffffc0203a6c:	f0ca                	sd	s2,96(sp)
ffffffffc0203a6e:	ecce                	sd	s3,88(sp)
ffffffffc0203a70:	e8d2                	sd	s4,80(sp)
ffffffffc0203a72:	e4d6                	sd	s5,72(sp)
ffffffffc0203a74:	e0da                	sd	s6,64(sp)
ffffffffc0203a76:	fc5e                	sd	s7,56(sp)
ffffffffc0203a78:	f862                	sd	s8,48(sp)
ffffffffc0203a7a:	f466                	sd	s9,40(sp)
ffffffffc0203a7c:	f06a                	sd	s10,32(sp)
ffffffffc0203a7e:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203a80:	03479713          	slli	a4,a5,0x34
ffffffffc0203a84:	1c071163          	bnez	a4,ffffffffc0203c46 <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc0203a88:	002007b7          	lui	a5,0x200
ffffffffc0203a8c:	20f5e563          	bltu	a1,a5,ffffffffc0203c96 <exit_range+0x236>
ffffffffc0203a90:	8b32                	mv	s6,a2
ffffffffc0203a92:	20c5f263          	bleu	a2,a1,ffffffffc0203c96 <exit_range+0x236>
ffffffffc0203a96:	4785                	li	a5,1
ffffffffc0203a98:	07fe                	slli	a5,a5,0x1f
ffffffffc0203a9a:	1ec7ee63          	bltu	a5,a2,ffffffffc0203c96 <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0203a9e:	c00009b7          	lui	s3,0xc0000
ffffffffc0203aa2:	400007b7          	lui	a5,0x40000
ffffffffc0203aa6:	0135f9b3          	and	s3,a1,s3
ffffffffc0203aaa:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];// 每次找一级页表项
ffffffffc0203aac:	c0000337          	lui	t1,0xc0000
ffffffffc0203ab0:	00698933          	add	s2,s3,t1
ffffffffc0203ab4:	01e95913          	srli	s2,s2,0x1e
ffffffffc0203ab8:	1ff97913          	andi	s2,s2,511
ffffffffc0203abc:	8e2a                	mv	t3,a0
ffffffffc0203abe:	090e                	slli	s2,s2,0x3
ffffffffc0203ac0:	9972                	add	s2,s2,t3
ffffffffc0203ac2:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0203ac6:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc0203aca:	5dfd                	li	s11,-1
        if (pde1&PTE_V){// 一级页表项有效
ffffffffc0203acc:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0203ad0:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc0203ad2:	000a9d17          	auipc	s10,0xa9
ffffffffc0203ad6:	90ed0d13          	addi	s10,s10,-1778 # ffffffffc02ac3e0 <npage>
    return KADDR(page2pa(page));
ffffffffc0203ada:	00cddd93          	srli	s11,s11,0xc
ffffffffc0203ade:	000a9717          	auipc	a4,0xa9
ffffffffc0203ae2:	a3270713          	addi	a4,a4,-1486 # ffffffffc02ac510 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc0203ae6:	000a9e97          	auipc	t4,0xa9
ffffffffc0203aea:	a3ae8e93          	addi	t4,t4,-1478 # ffffffffc02ac520 <pages>
        if (pde1&PTE_V){// 一级页表项有效
ffffffffc0203aee:	e79d                	bnez	a5,ffffffffc0203b1c <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc0203af0:	12098963          	beqz	s3,ffffffffc0203c22 <exit_range+0x1c2>
ffffffffc0203af4:	400007b7          	lui	a5,0x40000
ffffffffc0203af8:	84ce                	mv	s1,s3
ffffffffc0203afa:	97ce                	add	a5,a5,s3
ffffffffc0203afc:	1369f363          	bleu	s6,s3,ffffffffc0203c22 <exit_range+0x1c2>
ffffffffc0203b00:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];// 每次找一级页表项
ffffffffc0203b02:	00698933          	add	s2,s3,t1
ffffffffc0203b06:	01e95913          	srli	s2,s2,0x1e
ffffffffc0203b0a:	1ff97913          	andi	s2,s2,511
ffffffffc0203b0e:	090e                	slli	s2,s2,0x3
ffffffffc0203b10:	9972                	add	s2,s2,t3
ffffffffc0203b12:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){// 一级页表项有效
ffffffffc0203b16:	001bf793          	andi	a5,s7,1
ffffffffc0203b1a:	dbf9                	beqz	a5,ffffffffc0203af0 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0203b1c:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b20:	0b8a                	slli	s7,s7,0x2
ffffffffc0203b22:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b26:	14fbfc63          	bleu	a5,s7,ffffffffc0203c7e <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b2a:	fff80ab7          	lui	s5,0xfff80
ffffffffc0203b2e:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc0203b30:	000806b7          	lui	a3,0x80
ffffffffc0203b34:	96d6                	add	a3,a3,s5
ffffffffc0203b36:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc0203b3a:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc0203b3e:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0203b40:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203b42:	12f67263          	bleu	a5,a2,ffffffffc0203c66 <exit_range+0x206>
ffffffffc0203b46:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc0203b4a:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0203b4c:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc0203b50:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc0203b52:	00080837          	lui	a6,0x80
ffffffffc0203b56:	6a85                	lui	s5,0x1
                d0start += PTSIZE;// 下一个pde0页目录项
ffffffffc0203b58:	00200c37          	lui	s8,0x200
ffffffffc0203b5c:	a801                	j	ffffffffc0203b6c <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc0203b5e:	4c81                	li	s9,0
                d0start += PTSIZE;// 下一个pde0页目录项
ffffffffc0203b60:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0203b62:	c0d9                	beqz	s1,ffffffffc0203be8 <exit_range+0x188>
ffffffffc0203b64:	0934f263          	bleu	s3,s1,ffffffffc0203be8 <exit_range+0x188>
ffffffffc0203b68:	0d64fc63          	bleu	s6,s1,ffffffffc0203c40 <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0203b6c:	0154d413          	srli	s0,s1,0x15
ffffffffc0203b70:	1ff47413          	andi	s0,s0,511
ffffffffc0203b74:	040e                	slli	s0,s0,0x3
ffffffffc0203b76:	9452                	add	s0,s0,s4
ffffffffc0203b78:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {// 检测是否有效，有效就找下一级
ffffffffc0203b7a:	0017f693          	andi	a3,a5,1
ffffffffc0203b7e:	d2e5                	beqz	a3,ffffffffc0203b5e <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc0203b80:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b84:	00279513          	slli	a0,a5,0x2
ffffffffc0203b88:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b8a:	0eb57a63          	bleu	a1,a0,ffffffffc0203c7e <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b8e:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc0203b90:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc0203b94:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc0203b98:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203b9a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203b9c:	0cb7f563          	bleu	a1,a5,ffffffffc0203c66 <exit_range+0x206>
ffffffffc0203ba0:	631c                	ld	a5,0(a4)
ffffffffc0203ba2:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0203ba4:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){// 检测是否有效
ffffffffc0203ba8:	629c                	ld	a5,0(a3)
ffffffffc0203baa:	8b85                	andi	a5,a5,1
ffffffffc0203bac:	fbd5                	bnez	a5,ffffffffc0203b60 <exit_range+0x100>
ffffffffc0203bae:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0203bb0:	fed59ce3          	bne	a1,a3,ffffffffc0203ba8 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc0203bb4:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc0203bb8:	4585                	li	a1,1
ffffffffc0203bba:	e072                	sd	t3,0(sp)
ffffffffc0203bbc:	953e                	add	a0,a0,a5
ffffffffc0203bbe:	ad1ff0ef          	jal	ra,ffffffffc020368e <free_pages>
                d0start += PTSIZE;// 下一个pde0页目录项
ffffffffc0203bc2:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc0203bc4:	00043023          	sd	zero,0(s0)
ffffffffc0203bc8:	000a9e97          	auipc	t4,0xa9
ffffffffc0203bcc:	958e8e93          	addi	t4,t4,-1704 # ffffffffc02ac520 <pages>
ffffffffc0203bd0:	6e02                	ld	t3,0(sp)
ffffffffc0203bd2:	c0000337          	lui	t1,0xc0000
ffffffffc0203bd6:	fff808b7          	lui	a7,0xfff80
ffffffffc0203bda:	00080837          	lui	a6,0x80
ffffffffc0203bde:	000a9717          	auipc	a4,0xa9
ffffffffc0203be2:	93270713          	addi	a4,a4,-1742 # ffffffffc02ac510 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0203be6:	fcbd                	bnez	s1,ffffffffc0203b64 <exit_range+0x104>
            if (free_pd0) {// 如果全部pde0有效并且释放，pde1才释放，并且设置为空
ffffffffc0203be8:	f00c84e3          	beqz	s9,ffffffffc0203af0 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0203bec:	000d3783          	ld	a5,0(s10)
ffffffffc0203bf0:	e072                	sd	t3,0(sp)
ffffffffc0203bf2:	08fbf663          	bleu	a5,s7,ffffffffc0203c7e <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203bf6:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0203bfa:	67a2                	ld	a5,8(sp)
ffffffffc0203bfc:	4585                	li	a1,1
ffffffffc0203bfe:	953e                	add	a0,a0,a5
ffffffffc0203c00:	a8fff0ef          	jal	ra,ffffffffc020368e <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0203c04:	00093023          	sd	zero,0(s2)
ffffffffc0203c08:	000a9717          	auipc	a4,0xa9
ffffffffc0203c0c:	90870713          	addi	a4,a4,-1784 # ffffffffc02ac510 <va_pa_offset>
ffffffffc0203c10:	c0000337          	lui	t1,0xc0000
ffffffffc0203c14:	6e02                	ld	t3,0(sp)
ffffffffc0203c16:	000a9e97          	auipc	t4,0xa9
ffffffffc0203c1a:	90ae8e93          	addi	t4,t4,-1782 # ffffffffc02ac520 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc0203c1e:	ec099be3          	bnez	s3,ffffffffc0203af4 <exit_range+0x94>
}
ffffffffc0203c22:	70e6                	ld	ra,120(sp)
ffffffffc0203c24:	7446                	ld	s0,112(sp)
ffffffffc0203c26:	74a6                	ld	s1,104(sp)
ffffffffc0203c28:	7906                	ld	s2,96(sp)
ffffffffc0203c2a:	69e6                	ld	s3,88(sp)
ffffffffc0203c2c:	6a46                	ld	s4,80(sp)
ffffffffc0203c2e:	6aa6                	ld	s5,72(sp)
ffffffffc0203c30:	6b06                	ld	s6,64(sp)
ffffffffc0203c32:	7be2                	ld	s7,56(sp)
ffffffffc0203c34:	7c42                	ld	s8,48(sp)
ffffffffc0203c36:	7ca2                	ld	s9,40(sp)
ffffffffc0203c38:	7d02                	ld	s10,32(sp)
ffffffffc0203c3a:	6de2                	ld	s11,24(sp)
ffffffffc0203c3c:	6109                	addi	sp,sp,128
ffffffffc0203c3e:	8082                	ret
            if (free_pd0) {// 如果全部pde0有效并且释放，pde1才释放，并且设置为空
ffffffffc0203c40:	ea0c8ae3          	beqz	s9,ffffffffc0203af4 <exit_range+0x94>
ffffffffc0203c44:	b765                	j	ffffffffc0203bec <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203c46:	00004697          	auipc	a3,0x4
ffffffffc0203c4a:	6ea68693          	addi	a3,a3,1770 # ffffffffc0208330 <default_pmm_manager+0x5c0>
ffffffffc0203c4e:	00003617          	auipc	a2,0x3
ffffffffc0203c52:	fba60613          	addi	a2,a2,-70 # ffffffffc0206c08 <commands+0x480>
ffffffffc0203c56:	12500593          	li	a1,293
ffffffffc0203c5a:	00004517          	auipc	a0,0x4
ffffffffc0203c5e:	18650513          	addi	a0,a0,390 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0203c62:	db4fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203c66:	00003617          	auipc	a2,0x3
ffffffffc0203c6a:	6ea60613          	addi	a2,a2,1770 # ffffffffc0207350 <commands+0xbc8>
ffffffffc0203c6e:	06900593          	li	a1,105
ffffffffc0203c72:	00003517          	auipc	a0,0x3
ffffffffc0203c76:	6ce50513          	addi	a0,a0,1742 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0203c7a:	d9cfc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203c7e:	00003617          	auipc	a2,0x3
ffffffffc0203c82:	6a260613          	addi	a2,a2,1698 # ffffffffc0207320 <commands+0xb98>
ffffffffc0203c86:	06200593          	li	a1,98
ffffffffc0203c8a:	00003517          	auipc	a0,0x3
ffffffffc0203c8e:	6b650513          	addi	a0,a0,1718 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0203c92:	d84fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203c96:	00004697          	auipc	a3,0x4
ffffffffc0203c9a:	6ca68693          	addi	a3,a3,1738 # ffffffffc0208360 <default_pmm_manager+0x5f0>
ffffffffc0203c9e:	00003617          	auipc	a2,0x3
ffffffffc0203ca2:	f6a60613          	addi	a2,a2,-150 # ffffffffc0206c08 <commands+0x480>
ffffffffc0203ca6:	12600593          	li	a1,294
ffffffffc0203caa:	00004517          	auipc	a0,0x4
ffffffffc0203cae:	13650513          	addi	a0,a0,310 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0203cb2:	d64fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203cb6 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203cb6:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203cb8:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203cba:	e426                	sd	s1,8(sp)
ffffffffc0203cbc:	ec06                	sd	ra,24(sp)
ffffffffc0203cbe:	e822                	sd	s0,16(sp)
ffffffffc0203cc0:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203cc2:	a53ff0ef          	jal	ra,ffffffffc0203714 <get_pte>
    if (ptep != NULL) {
ffffffffc0203cc6:	c511                	beqz	a0,ffffffffc0203cd2 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203cc8:	611c                	ld	a5,0(a0)
ffffffffc0203cca:	842a                	mv	s0,a0
ffffffffc0203ccc:	0017f713          	andi	a4,a5,1
ffffffffc0203cd0:	e711                	bnez	a4,ffffffffc0203cdc <page_remove+0x26>
}
ffffffffc0203cd2:	60e2                	ld	ra,24(sp)
ffffffffc0203cd4:	6442                	ld	s0,16(sp)
ffffffffc0203cd6:	64a2                	ld	s1,8(sp)
ffffffffc0203cd8:	6105                	addi	sp,sp,32
ffffffffc0203cda:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0203cdc:	000a8717          	auipc	a4,0xa8
ffffffffc0203ce0:	70470713          	addi	a4,a4,1796 # ffffffffc02ac3e0 <npage>
ffffffffc0203ce4:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203ce6:	078a                	slli	a5,a5,0x2
ffffffffc0203ce8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203cea:	02e7fe63          	bleu	a4,a5,ffffffffc0203d26 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0203cee:	000a9717          	auipc	a4,0xa9
ffffffffc0203cf2:	83270713          	addi	a4,a4,-1998 # ffffffffc02ac520 <pages>
ffffffffc0203cf6:	6308                	ld	a0,0(a4)
ffffffffc0203cf8:	fff80737          	lui	a4,0xfff80
ffffffffc0203cfc:	97ba                	add	a5,a5,a4
ffffffffc0203cfe:	079a                	slli	a5,a5,0x6
ffffffffc0203d00:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0203d02:	411c                	lw	a5,0(a0)
ffffffffc0203d04:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203d08:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203d0a:	cb11                	beqz	a4,ffffffffc0203d1e <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203d0c:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203d10:	12048073          	sfence.vma	s1
}
ffffffffc0203d14:	60e2                	ld	ra,24(sp)
ffffffffc0203d16:	6442                	ld	s0,16(sp)
ffffffffc0203d18:	64a2                	ld	s1,8(sp)
ffffffffc0203d1a:	6105                	addi	sp,sp,32
ffffffffc0203d1c:	8082                	ret
            free_page(page);
ffffffffc0203d1e:	4585                	li	a1,1
ffffffffc0203d20:	96fff0ef          	jal	ra,ffffffffc020368e <free_pages>
ffffffffc0203d24:	b7e5                	j	ffffffffc0203d0c <page_remove+0x56>
ffffffffc0203d26:	8c5ff0ef          	jal	ra,ffffffffc02035ea <pa2page.part.4>

ffffffffc0203d2a <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203d2a:	7179                	addi	sp,sp,-48
ffffffffc0203d2c:	e44e                	sd	s3,8(sp)
ffffffffc0203d2e:	89b2                	mv	s3,a2
ffffffffc0203d30:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203d32:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203d34:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203d36:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203d38:	ec26                	sd	s1,24(sp)
ffffffffc0203d3a:	f406                	sd	ra,40(sp)
ffffffffc0203d3c:	e84a                	sd	s2,16(sp)
ffffffffc0203d3e:	e052                	sd	s4,0(sp)
ffffffffc0203d40:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203d42:	9d3ff0ef          	jal	ra,ffffffffc0203714 <get_pte>
    if (ptep == NULL) {
ffffffffc0203d46:	cd49                	beqz	a0,ffffffffc0203de0 <page_insert+0xb6>
    page->ref += 1;
ffffffffc0203d48:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0203d4a:	611c                	ld	a5,0(a0)
ffffffffc0203d4c:	892a                	mv	s2,a0
ffffffffc0203d4e:	0016871b          	addiw	a4,a3,1
ffffffffc0203d52:	c018                	sw	a4,0(s0)
ffffffffc0203d54:	0017f713          	andi	a4,a5,1
ffffffffc0203d58:	ef05                	bnez	a4,ffffffffc0203d90 <page_insert+0x66>
ffffffffc0203d5a:	000a8797          	auipc	a5,0xa8
ffffffffc0203d5e:	7c678793          	addi	a5,a5,1990 # ffffffffc02ac520 <pages>
ffffffffc0203d62:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0203d64:	8c19                	sub	s0,s0,a4
ffffffffc0203d66:	000806b7          	lui	a3,0x80
ffffffffc0203d6a:	8419                	srai	s0,s0,0x6
ffffffffc0203d6c:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203d6e:	042a                	slli	s0,s0,0xa
ffffffffc0203d70:	8c45                	or	s0,s0,s1
ffffffffc0203d72:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0203d76:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203d7a:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0203d7e:	4501                	li	a0,0
}
ffffffffc0203d80:	70a2                	ld	ra,40(sp)
ffffffffc0203d82:	7402                	ld	s0,32(sp)
ffffffffc0203d84:	64e2                	ld	s1,24(sp)
ffffffffc0203d86:	6942                	ld	s2,16(sp)
ffffffffc0203d88:	69a2                	ld	s3,8(sp)
ffffffffc0203d8a:	6a02                	ld	s4,0(sp)
ffffffffc0203d8c:	6145                	addi	sp,sp,48
ffffffffc0203d8e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0203d90:	000a8717          	auipc	a4,0xa8
ffffffffc0203d94:	65070713          	addi	a4,a4,1616 # ffffffffc02ac3e0 <npage>
ffffffffc0203d98:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203d9a:	078a                	slli	a5,a5,0x2
ffffffffc0203d9c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203d9e:	04e7f363          	bleu	a4,a5,ffffffffc0203de4 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0203da2:	000a8a17          	auipc	s4,0xa8
ffffffffc0203da6:	77ea0a13          	addi	s4,s4,1918 # ffffffffc02ac520 <pages>
ffffffffc0203daa:	000a3703          	ld	a4,0(s4)
ffffffffc0203dae:	fff80537          	lui	a0,0xfff80
ffffffffc0203db2:	953e                	add	a0,a0,a5
ffffffffc0203db4:	051a                	slli	a0,a0,0x6
ffffffffc0203db6:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0203db8:	00a40a63          	beq	s0,a0,ffffffffc0203dcc <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0203dbc:	411c                	lw	a5,0(a0)
ffffffffc0203dbe:	fff7869b          	addiw	a3,a5,-1
ffffffffc0203dc2:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0203dc4:	c691                	beqz	a3,ffffffffc0203dd0 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203dc6:	12098073          	sfence.vma	s3
ffffffffc0203dca:	bf69                	j	ffffffffc0203d64 <page_insert+0x3a>
ffffffffc0203dcc:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0203dce:	bf59                	j	ffffffffc0203d64 <page_insert+0x3a>
            free_page(page);
ffffffffc0203dd0:	4585                	li	a1,1
ffffffffc0203dd2:	8bdff0ef          	jal	ra,ffffffffc020368e <free_pages>
ffffffffc0203dd6:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203dda:	12098073          	sfence.vma	s3
ffffffffc0203dde:	b759                	j	ffffffffc0203d64 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0203de0:	5571                	li	a0,-4
ffffffffc0203de2:	bf79                	j	ffffffffc0203d80 <page_insert+0x56>
ffffffffc0203de4:	807ff0ef          	jal	ra,ffffffffc02035ea <pa2page.part.4>

ffffffffc0203de8 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0203de8:	00004797          	auipc	a5,0x4
ffffffffc0203dec:	f8878793          	addi	a5,a5,-120 # ffffffffc0207d70 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203df0:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0203df2:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203df4:	00004517          	auipc	a0,0x4
ffffffffc0203df8:	01450513          	addi	a0,a0,20 # ffffffffc0207e08 <default_pmm_manager+0x98>
void pmm_init(void) {
ffffffffc0203dfc:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203dfe:	000a8717          	auipc	a4,0xa8
ffffffffc0203e02:	70f73523          	sd	a5,1802(a4) # ffffffffc02ac508 <pmm_manager>
void pmm_init(void) {
ffffffffc0203e06:	e0a2                	sd	s0,64(sp)
ffffffffc0203e08:	fc26                	sd	s1,56(sp)
ffffffffc0203e0a:	f84a                	sd	s2,48(sp)
ffffffffc0203e0c:	f44e                	sd	s3,40(sp)
ffffffffc0203e0e:	f052                	sd	s4,32(sp)
ffffffffc0203e10:	ec56                	sd	s5,24(sp)
ffffffffc0203e12:	e85a                	sd	s6,16(sp)
ffffffffc0203e14:	e45e                	sd	s7,8(sp)
ffffffffc0203e16:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203e18:	000a8417          	auipc	s0,0xa8
ffffffffc0203e1c:	6f040413          	addi	s0,s0,1776 # ffffffffc02ac508 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203e20:	ab0fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pmm_manager->init();
ffffffffc0203e24:	601c                	ld	a5,0(s0)
ffffffffc0203e26:	000a8497          	auipc	s1,0xa8
ffffffffc0203e2a:	5ba48493          	addi	s1,s1,1466 # ffffffffc02ac3e0 <npage>
ffffffffc0203e2e:	000a8917          	auipc	s2,0xa8
ffffffffc0203e32:	6f290913          	addi	s2,s2,1778 # ffffffffc02ac520 <pages>
ffffffffc0203e36:	679c                	ld	a5,8(a5)
ffffffffc0203e38:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203e3a:	57f5                	li	a5,-3
ffffffffc0203e3c:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0203e3e:	00004517          	auipc	a0,0x4
ffffffffc0203e42:	fe250513          	addi	a0,a0,-30 # ffffffffc0207e20 <default_pmm_manager+0xb0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203e46:	000a8717          	auipc	a4,0xa8
ffffffffc0203e4a:	6cf73523          	sd	a5,1738(a4) # ffffffffc02ac510 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0203e4e:	a82fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0203e52:	46c5                	li	a3,17
ffffffffc0203e54:	06ee                	slli	a3,a3,0x1b
ffffffffc0203e56:	40100613          	li	a2,1025
ffffffffc0203e5a:	16fd                	addi	a3,a3,-1
ffffffffc0203e5c:	0656                	slli	a2,a2,0x15
ffffffffc0203e5e:	07e005b7          	lui	a1,0x7e00
ffffffffc0203e62:	00004517          	auipc	a0,0x4
ffffffffc0203e66:	fd650513          	addi	a0,a0,-42 # ffffffffc0207e38 <default_pmm_manager+0xc8>
ffffffffc0203e6a:	a66fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);// 管理物理页面的信息
ffffffffc0203e6e:	777d                	lui	a4,0xfffff
ffffffffc0203e70:	000a9797          	auipc	a5,0xa9
ffffffffc0203e74:	6c778793          	addi	a5,a5,1735 # ffffffffc02ad537 <end+0xfff>
ffffffffc0203e78:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;// 物理页面的总数
ffffffffc0203e7a:	00088737          	lui	a4,0x88
ffffffffc0203e7e:	000a8697          	auipc	a3,0xa8
ffffffffc0203e82:	56e6b123          	sd	a4,1378(a3) # ffffffffc02ac3e0 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);// 管理物理页面的信息
ffffffffc0203e86:	000a8717          	auipc	a4,0xa8
ffffffffc0203e8a:	68f73d23          	sd	a5,1690(a4) # ffffffffc02ac520 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {// 标记为内核使用
ffffffffc0203e8e:	4701                	li	a4,0
ffffffffc0203e90:	4685                	li	a3,1
ffffffffc0203e92:	fff80837          	lui	a6,0xfff80
ffffffffc0203e96:	a019                	j	ffffffffc0203e9c <pmm_init+0xb4>
ffffffffc0203e98:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0203e9c:	00671613          	slli	a2,a4,0x6
ffffffffc0203ea0:	97b2                	add	a5,a5,a2
ffffffffc0203ea2:	07a1                	addi	a5,a5,8
ffffffffc0203ea4:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {// 标记为内核使用
ffffffffc0203ea8:	6090                	ld	a2,0(s1)
ffffffffc0203eaa:	0705                	addi	a4,a4,1
ffffffffc0203eac:	010607b3          	add	a5,a2,a6
ffffffffc0203eb0:	fef764e3          	bltu	a4,a5,ffffffffc0203e98 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));// 可用内存的起始地址
ffffffffc0203eb4:	00093503          	ld	a0,0(s2)
ffffffffc0203eb8:	fe0007b7          	lui	a5,0xfe000
ffffffffc0203ebc:	00661693          	slli	a3,a2,0x6
ffffffffc0203ec0:	97aa                	add	a5,a5,a0
ffffffffc0203ec2:	96be                	add	a3,a3,a5
ffffffffc0203ec4:	c02007b7          	lui	a5,0xc0200
ffffffffc0203ec8:	7af6ed63          	bltu	a3,a5,ffffffffc0204682 <pmm_init+0x89a>
ffffffffc0203ecc:	000a8997          	auipc	s3,0xa8
ffffffffc0203ed0:	64498993          	addi	s3,s3,1604 # ffffffffc02ac510 <va_pa_offset>
ffffffffc0203ed4:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0203ed8:	47c5                	li	a5,17
ffffffffc0203eda:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));// 可用内存的起始地址
ffffffffc0203edc:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0203ede:	02f6f763          	bleu	a5,a3,ffffffffc0203f0c <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0203ee2:	6585                	lui	a1,0x1
ffffffffc0203ee4:	15fd                	addi	a1,a1,-1
ffffffffc0203ee6:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0203ee8:	00c6d713          	srli	a4,a3,0xc
ffffffffc0203eec:	48c77a63          	bleu	a2,a4,ffffffffc0204380 <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc0203ef0:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);// 初始化页面映射信息
ffffffffc0203ef2:	75fd                	lui	a1,0xfffff
ffffffffc0203ef4:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0203ef6:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0203ef8:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);// 初始化页面映射信息
ffffffffc0203efa:	40d786b3          	sub	a3,a5,a3
ffffffffc0203efe:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0203f00:	00c6d593          	srli	a1,a3,0xc
ffffffffc0203f04:	953a                	add	a0,a0,a4
ffffffffc0203f06:	9602                	jalr	a2
ffffffffc0203f08:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0203f0c:	00004517          	auipc	a0,0x4
ffffffffc0203f10:	f5450513          	addi	a0,a0,-172 # ffffffffc0207e60 <default_pmm_manager+0xf0>
ffffffffc0203f14:	9bcfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0203f18:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203f1a:	000a8417          	auipc	s0,0xa8
ffffffffc0203f1e:	4be40413          	addi	s0,s0,1214 # ffffffffc02ac3d8 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203f22:	7b9c                	ld	a5,48(a5)
ffffffffc0203f24:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0203f26:	00004517          	auipc	a0,0x4
ffffffffc0203f2a:	f5250513          	addi	a0,a0,-174 # ffffffffc0207e78 <default_pmm_manager+0x108>
ffffffffc0203f2e:	9a2fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203f32:	00007697          	auipc	a3,0x7
ffffffffc0203f36:	0ce68693          	addi	a3,a3,206 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0203f3a:	000a8797          	auipc	a5,0xa8
ffffffffc0203f3e:	48d7bf23          	sd	a3,1182(a5) # ffffffffc02ac3d8 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203f42:	c02007b7          	lui	a5,0xc0200
ffffffffc0203f46:	10f6eae3          	bltu	a3,a5,ffffffffc020485a <pmm_init+0xa72>
ffffffffc0203f4a:	0009b783          	ld	a5,0(s3)
ffffffffc0203f4e:	8e9d                	sub	a3,a3,a5
ffffffffc0203f50:	000a8797          	auipc	a5,0xa8
ffffffffc0203f54:	5cd7b423          	sd	a3,1480(a5) # ffffffffc02ac518 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0203f58:	f7cff0ef          	jal	ra,ffffffffc02036d4 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203f5c:	6098                	ld	a4,0(s1)
ffffffffc0203f5e:	c80007b7          	lui	a5,0xc8000
ffffffffc0203f62:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0203f64:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203f66:	0ce7eae3          	bltu	a5,a4,ffffffffc020483a <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203f6a:	6008                	ld	a0,0(s0)
ffffffffc0203f6c:	44050463          	beqz	a0,ffffffffc02043b4 <pmm_init+0x5cc>
ffffffffc0203f70:	6785                	lui	a5,0x1
ffffffffc0203f72:	17fd                	addi	a5,a5,-1
ffffffffc0203f74:	8fe9                	and	a5,a5,a0
ffffffffc0203f76:	2781                	sext.w	a5,a5
ffffffffc0203f78:	42079e63          	bnez	a5,ffffffffc02043b4 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203f7c:	4601                	li	a2,0
ffffffffc0203f7e:	4581                	li	a1,0
ffffffffc0203f80:	967ff0ef          	jal	ra,ffffffffc02038e6 <get_page>
ffffffffc0203f84:	78051b63          	bnez	a0,ffffffffc020471a <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0203f88:	4505                	li	a0,1
ffffffffc0203f8a:	e7cff0ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0203f8e:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203f90:	6008                	ld	a0,0(s0)
ffffffffc0203f92:	4681                	li	a3,0
ffffffffc0203f94:	4601                	li	a2,0
ffffffffc0203f96:	85d6                	mv	a1,s5
ffffffffc0203f98:	d93ff0ef          	jal	ra,ffffffffc0203d2a <page_insert>
ffffffffc0203f9c:	7a051f63          	bnez	a0,ffffffffc020475a <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203fa0:	6008                	ld	a0,0(s0)
ffffffffc0203fa2:	4601                	li	a2,0
ffffffffc0203fa4:	4581                	li	a1,0
ffffffffc0203fa6:	f6eff0ef          	jal	ra,ffffffffc0203714 <get_pte>
ffffffffc0203faa:	78050863          	beqz	a0,ffffffffc020473a <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc0203fae:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203fb0:	0017f713          	andi	a4,a5,1
ffffffffc0203fb4:	3e070463          	beqz	a4,ffffffffc020439c <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0203fb8:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203fba:	078a                	slli	a5,a5,0x2
ffffffffc0203fbc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203fbe:	3ce7f163          	bleu	a4,a5,ffffffffc0204380 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0203fc2:	00093683          	ld	a3,0(s2)
ffffffffc0203fc6:	fff80637          	lui	a2,0xfff80
ffffffffc0203fca:	97b2                	add	a5,a5,a2
ffffffffc0203fcc:	079a                	slli	a5,a5,0x6
ffffffffc0203fce:	97b6                	add	a5,a5,a3
ffffffffc0203fd0:	72fa9563          	bne	s5,a5,ffffffffc02046fa <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc0203fd4:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
ffffffffc0203fd8:	4785                	li	a5,1
ffffffffc0203fda:	70fb9063          	bne	s7,a5,ffffffffc02046da <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203fde:	6008                	ld	a0,0(s0)
ffffffffc0203fe0:	76fd                	lui	a3,0xfffff
ffffffffc0203fe2:	611c                	ld	a5,0(a0)
ffffffffc0203fe4:	078a                	slli	a5,a5,0x2
ffffffffc0203fe6:	8ff5                	and	a5,a5,a3
ffffffffc0203fe8:	00c7d613          	srli	a2,a5,0xc
ffffffffc0203fec:	66e67e63          	bleu	a4,a2,ffffffffc0204668 <pmm_init+0x880>
ffffffffc0203ff0:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203ff4:	97e2                	add	a5,a5,s8
ffffffffc0203ff6:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
ffffffffc0203ffa:	0b0a                	slli	s6,s6,0x2
ffffffffc0203ffc:	00db7b33          	and	s6,s6,a3
ffffffffc0204000:	00cb5793          	srli	a5,s6,0xc
ffffffffc0204004:	56e7f863          	bleu	a4,a5,ffffffffc0204574 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0204008:	4601                	li	a2,0
ffffffffc020400a:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020400c:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020400e:	f06ff0ef          	jal	ra,ffffffffc0203714 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0204012:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0204014:	55651063          	bne	a0,s6,ffffffffc0204554 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc0204018:	4505                	li	a0,1
ffffffffc020401a:	decff0ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc020401e:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0204020:	6008                	ld	a0,0(s0)
ffffffffc0204022:	46d1                	li	a3,20
ffffffffc0204024:	6605                	lui	a2,0x1
ffffffffc0204026:	85da                	mv	a1,s6
ffffffffc0204028:	d03ff0ef          	jal	ra,ffffffffc0203d2a <page_insert>
ffffffffc020402c:	50051463          	bnez	a0,ffffffffc0204534 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0204030:	6008                	ld	a0,0(s0)
ffffffffc0204032:	4601                	li	a2,0
ffffffffc0204034:	6585                	lui	a1,0x1
ffffffffc0204036:	edeff0ef          	jal	ra,ffffffffc0203714 <get_pte>
ffffffffc020403a:	4c050d63          	beqz	a0,ffffffffc0204514 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc020403e:	611c                	ld	a5,0(a0)
ffffffffc0204040:	0107f713          	andi	a4,a5,16
ffffffffc0204044:	4a070863          	beqz	a4,ffffffffc02044f4 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc0204048:	8b91                	andi	a5,a5,4
ffffffffc020404a:	48078563          	beqz	a5,ffffffffc02044d4 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020404e:	6008                	ld	a0,0(s0)
ffffffffc0204050:	611c                	ld	a5,0(a0)
ffffffffc0204052:	8bc1                	andi	a5,a5,16
ffffffffc0204054:	46078063          	beqz	a5,ffffffffc02044b4 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc0204058:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5590>
ffffffffc020405c:	43779c63          	bne	a5,s7,ffffffffc0204494 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0204060:	4681                	li	a3,0
ffffffffc0204062:	6605                	lui	a2,0x1
ffffffffc0204064:	85d6                	mv	a1,s5
ffffffffc0204066:	cc5ff0ef          	jal	ra,ffffffffc0203d2a <page_insert>
ffffffffc020406a:	40051563          	bnez	a0,ffffffffc0204474 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc020406e:	000aa703          	lw	a4,0(s5)
ffffffffc0204072:	4789                	li	a5,2
ffffffffc0204074:	3ef71063          	bne	a4,a5,ffffffffc0204454 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc0204078:	000b2783          	lw	a5,0(s6)
ffffffffc020407c:	3a079c63          	bnez	a5,ffffffffc0204434 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0204080:	6008                	ld	a0,0(s0)
ffffffffc0204082:	4601                	li	a2,0
ffffffffc0204084:	6585                	lui	a1,0x1
ffffffffc0204086:	e8eff0ef          	jal	ra,ffffffffc0203714 <get_pte>
ffffffffc020408a:	38050563          	beqz	a0,ffffffffc0204414 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc020408e:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0204090:	00177793          	andi	a5,a4,1
ffffffffc0204094:	30078463          	beqz	a5,ffffffffc020439c <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0204098:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020409a:	00271793          	slli	a5,a4,0x2
ffffffffc020409e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02040a0:	2ed7f063          	bleu	a3,a5,ffffffffc0204380 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02040a4:	00093683          	ld	a3,0(s2)
ffffffffc02040a8:	fff80637          	lui	a2,0xfff80
ffffffffc02040ac:	97b2                	add	a5,a5,a2
ffffffffc02040ae:	079a                	slli	a5,a5,0x6
ffffffffc02040b0:	97b6                	add	a5,a5,a3
ffffffffc02040b2:	32fa9163          	bne	s5,a5,ffffffffc02043d4 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc02040b6:	8b41                	andi	a4,a4,16
ffffffffc02040b8:	70071163          	bnez	a4,ffffffffc02047ba <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc02040bc:	6008                	ld	a0,0(s0)
ffffffffc02040be:	4581                	li	a1,0
ffffffffc02040c0:	bf7ff0ef          	jal	ra,ffffffffc0203cb6 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02040c4:	000aa703          	lw	a4,0(s5)
ffffffffc02040c8:	4785                	li	a5,1
ffffffffc02040ca:	6cf71863          	bne	a4,a5,ffffffffc020479a <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc02040ce:	000b2783          	lw	a5,0(s6)
ffffffffc02040d2:	6a079463          	bnez	a5,ffffffffc020477a <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02040d6:	6008                	ld	a0,0(s0)
ffffffffc02040d8:	6585                	lui	a1,0x1
ffffffffc02040da:	bddff0ef          	jal	ra,ffffffffc0203cb6 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02040de:	000aa783          	lw	a5,0(s5)
ffffffffc02040e2:	50079363          	bnez	a5,ffffffffc02045e8 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc02040e6:	000b2783          	lw	a5,0(s6)
ffffffffc02040ea:	4c079f63          	bnez	a5,ffffffffc02045c8 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02040ee:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02040f2:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02040f4:	000ab783          	ld	a5,0(s5)
ffffffffc02040f8:	078a                	slli	a5,a5,0x2
ffffffffc02040fa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02040fc:	28c7f263          	bleu	a2,a5,ffffffffc0204380 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0204100:	fff80737          	lui	a4,0xfff80
ffffffffc0204104:	00093503          	ld	a0,0(s2)
ffffffffc0204108:	97ba                	add	a5,a5,a4
ffffffffc020410a:	079a                	slli	a5,a5,0x6
ffffffffc020410c:	00f50733          	add	a4,a0,a5
ffffffffc0204110:	4314                	lw	a3,0(a4)
ffffffffc0204112:	4705                	li	a4,1
ffffffffc0204114:	48e69a63          	bne	a3,a4,ffffffffc02045a8 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0204118:	8799                	srai	a5,a5,0x6
ffffffffc020411a:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020411e:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc0204120:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc0204122:	8331                	srli	a4,a4,0xc
ffffffffc0204124:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204126:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0204128:	46c77363          	bleu	a2,a4,ffffffffc020458e <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020412c:	0009b683          	ld	a3,0(s3)
ffffffffc0204130:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0204132:	639c                	ld	a5,0(a5)
ffffffffc0204134:	078a                	slli	a5,a5,0x2
ffffffffc0204136:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204138:	24c7f463          	bleu	a2,a5,ffffffffc0204380 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020413c:	416787b3          	sub	a5,a5,s6
ffffffffc0204140:	079a                	slli	a5,a5,0x6
ffffffffc0204142:	953e                	add	a0,a0,a5
ffffffffc0204144:	4585                	li	a1,1
ffffffffc0204146:	d48ff0ef          	jal	ra,ffffffffc020368e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020414a:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc020414e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204150:	078a                	slli	a5,a5,0x2
ffffffffc0204152:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204154:	22e7f663          	bleu	a4,a5,ffffffffc0204380 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0204158:	00093503          	ld	a0,0(s2)
ffffffffc020415c:	416787b3          	sub	a5,a5,s6
ffffffffc0204160:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0204162:	953e                	add	a0,a0,a5
ffffffffc0204164:	4585                	li	a1,1
ffffffffc0204166:	d28ff0ef          	jal	ra,ffffffffc020368e <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020416a:	601c                	ld	a5,0(s0)
ffffffffc020416c:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0204170:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0204174:	d60ff0ef          	jal	ra,ffffffffc02036d4 <nr_free_pages>
ffffffffc0204178:	68aa1163          	bne	s4,a0,ffffffffc02047fa <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020417c:	00004517          	auipc	a0,0x4
ffffffffc0204180:	fe450513          	addi	a0,a0,-28 # ffffffffc0208160 <default_pmm_manager+0x3f0>
ffffffffc0204184:	f4dfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0204188:	d4cff0ef          	jal	ra,ffffffffc02036d4 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020418c:	6098                	ld	a4,0(s1)
ffffffffc020418e:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0204192:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0204194:	00c71693          	slli	a3,a4,0xc
ffffffffc0204198:	18d7f563          	bleu	a3,a5,ffffffffc0204322 <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020419c:	83b1                	srli	a5,a5,0xc
ffffffffc020419e:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02041a0:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02041a4:	1ae7f163          	bleu	a4,a5,ffffffffc0204346 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02041a8:	7bfd                	lui	s7,0xfffff
ffffffffc02041aa:	6b05                	lui	s6,0x1
ffffffffc02041ac:	a029                	j	ffffffffc02041b6 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02041ae:	00cad713          	srli	a4,s5,0xc
ffffffffc02041b2:	18f77a63          	bleu	a5,a4,ffffffffc0204346 <pmm_init+0x55e>
ffffffffc02041b6:	0009b583          	ld	a1,0(s3)
ffffffffc02041ba:	4601                	li	a2,0
ffffffffc02041bc:	95d6                	add	a1,a1,s5
ffffffffc02041be:	d56ff0ef          	jal	ra,ffffffffc0203714 <get_pte>
ffffffffc02041c2:	16050263          	beqz	a0,ffffffffc0204326 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02041c6:	611c                	ld	a5,0(a0)
ffffffffc02041c8:	078a                	slli	a5,a5,0x2
ffffffffc02041ca:	0177f7b3          	and	a5,a5,s7
ffffffffc02041ce:	19579963          	bne	a5,s5,ffffffffc0204360 <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02041d2:	609c                	ld	a5,0(s1)
ffffffffc02041d4:	9ada                	add	s5,s5,s6
ffffffffc02041d6:	6008                	ld	a0,0(s0)
ffffffffc02041d8:	00c79713          	slli	a4,a5,0xc
ffffffffc02041dc:	fceae9e3          	bltu	s5,a4,ffffffffc02041ae <pmm_init+0x3c6>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02041e0:	611c                	ld	a5,0(a0)
ffffffffc02041e2:	62079c63          	bnez	a5,ffffffffc020481a <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc02041e6:	4505                	li	a0,1
ffffffffc02041e8:	c1eff0ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc02041ec:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02041ee:	6008                	ld	a0,0(s0)
ffffffffc02041f0:	4699                	li	a3,6
ffffffffc02041f2:	10000613          	li	a2,256
ffffffffc02041f6:	85d6                	mv	a1,s5
ffffffffc02041f8:	b33ff0ef          	jal	ra,ffffffffc0203d2a <page_insert>
ffffffffc02041fc:	1e051c63          	bnez	a0,ffffffffc02043f4 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0204200:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0204204:	4785                	li	a5,1
ffffffffc0204206:	44f71163          	bne	a4,a5,ffffffffc0204648 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020420a:	6008                	ld	a0,0(s0)
ffffffffc020420c:	6b05                	lui	s6,0x1
ffffffffc020420e:	4699                	li	a3,6
ffffffffc0204210:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x8470>
ffffffffc0204214:	85d6                	mv	a1,s5
ffffffffc0204216:	b15ff0ef          	jal	ra,ffffffffc0203d2a <page_insert>
ffffffffc020421a:	40051763          	bnez	a0,ffffffffc0204628 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc020421e:	000aa703          	lw	a4,0(s5)
ffffffffc0204222:	4789                	li	a5,2
ffffffffc0204224:	3ef71263          	bne	a4,a5,ffffffffc0204608 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0204228:	00004597          	auipc	a1,0x4
ffffffffc020422c:	07058593          	addi	a1,a1,112 # ffffffffc0208298 <default_pmm_manager+0x528>
ffffffffc0204230:	10000513          	li	a0,256
ffffffffc0204234:	74b010ef          	jal	ra,ffffffffc020617e <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0204238:	100b0593          	addi	a1,s6,256
ffffffffc020423c:	10000513          	li	a0,256
ffffffffc0204240:	751010ef          	jal	ra,ffffffffc0206190 <strcmp>
ffffffffc0204244:	44051b63          	bnez	a0,ffffffffc020469a <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0204248:	00093683          	ld	a3,0(s2)
ffffffffc020424c:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0204250:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0204252:	40da86b3          	sub	a3,s5,a3
ffffffffc0204256:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204258:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc020425a:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020425c:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0204260:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0204264:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204266:	10f77f63          	bleu	a5,a4,ffffffffc0204384 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020426a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020426e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0204272:	96be                	add	a3,a3,a5
ffffffffc0204274:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd52bc8>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0204278:	6c3010ef          	jal	ra,ffffffffc020613a <strlen>
ffffffffc020427c:	54051f63          	bnez	a0,ffffffffc02047da <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0204280:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0204284:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204286:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52ac8>
ffffffffc020428a:	068a                	slli	a3,a3,0x2
ffffffffc020428c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020428e:	0ef6f963          	bleu	a5,a3,ffffffffc0204380 <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0204292:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0204296:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204298:	0efb7663          	bleu	a5,s6,ffffffffc0204384 <pmm_init+0x59c>
ffffffffc020429c:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc02042a0:	4585                	li	a1,1
ffffffffc02042a2:	8556                	mv	a0,s5
ffffffffc02042a4:	99b6                	add	s3,s3,a3
ffffffffc02042a6:	be8ff0ef          	jal	ra,ffffffffc020368e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02042aa:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02042ae:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02042b0:	078a                	slli	a5,a5,0x2
ffffffffc02042b2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02042b4:	0ce7f663          	bleu	a4,a5,ffffffffc0204380 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02042b8:	00093503          	ld	a0,0(s2)
ffffffffc02042bc:	fff809b7          	lui	s3,0xfff80
ffffffffc02042c0:	97ce                	add	a5,a5,s3
ffffffffc02042c2:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02042c4:	953e                	add	a0,a0,a5
ffffffffc02042c6:	4585                	li	a1,1
ffffffffc02042c8:	bc6ff0ef          	jal	ra,ffffffffc020368e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02042cc:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02042d0:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02042d2:	078a                	slli	a5,a5,0x2
ffffffffc02042d4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02042d6:	0ae7f563          	bleu	a4,a5,ffffffffc0204380 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02042da:	00093503          	ld	a0,0(s2)
ffffffffc02042de:	97ce                	add	a5,a5,s3
ffffffffc02042e0:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02042e2:	953e                	add	a0,a0,a5
ffffffffc02042e4:	4585                	li	a1,1
ffffffffc02042e6:	ba8ff0ef          	jal	ra,ffffffffc020368e <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02042ea:	601c                	ld	a5,0(s0)
ffffffffc02042ec:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc02042f0:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02042f4:	be0ff0ef          	jal	ra,ffffffffc02036d4 <nr_free_pages>
ffffffffc02042f8:	3caa1163          	bne	s4,a0,ffffffffc02046ba <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02042fc:	00004517          	auipc	a0,0x4
ffffffffc0204300:	01450513          	addi	a0,a0,20 # ffffffffc0208310 <default_pmm_manager+0x5a0>
ffffffffc0204304:	dcdfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0204308:	6406                	ld	s0,64(sp)
ffffffffc020430a:	60a6                	ld	ra,72(sp)
ffffffffc020430c:	74e2                	ld	s1,56(sp)
ffffffffc020430e:	7942                	ld	s2,48(sp)
ffffffffc0204310:	79a2                	ld	s3,40(sp)
ffffffffc0204312:	7a02                	ld	s4,32(sp)
ffffffffc0204314:	6ae2                	ld	s5,24(sp)
ffffffffc0204316:	6b42                	ld	s6,16(sp)
ffffffffc0204318:	6ba2                	ld	s7,8(sp)
ffffffffc020431a:	6c02                	ld	s8,0(sp)
ffffffffc020431c:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc020431e:	992fe06f          	j	ffffffffc02024b0 <kmalloc_init>
ffffffffc0204322:	6008                	ld	a0,0(s0)
ffffffffc0204324:	bd75                	j	ffffffffc02041e0 <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0204326:	00004697          	auipc	a3,0x4
ffffffffc020432a:	e5a68693          	addi	a3,a3,-422 # ffffffffc0208180 <default_pmm_manager+0x410>
ffffffffc020432e:	00003617          	auipc	a2,0x3
ffffffffc0204332:	8da60613          	addi	a2,a2,-1830 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204336:	23800593          	li	a1,568
ffffffffc020433a:	00004517          	auipc	a0,0x4
ffffffffc020433e:	aa650513          	addi	a0,a0,-1370 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204342:	ed5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204346:	86d6                	mv	a3,s5
ffffffffc0204348:	00003617          	auipc	a2,0x3
ffffffffc020434c:	00860613          	addi	a2,a2,8 # ffffffffc0207350 <commands+0xbc8>
ffffffffc0204350:	23800593          	li	a1,568
ffffffffc0204354:	00004517          	auipc	a0,0x4
ffffffffc0204358:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc020435c:	ebbfb0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0204360:	00004697          	auipc	a3,0x4
ffffffffc0204364:	e6068693          	addi	a3,a3,-416 # ffffffffc02081c0 <default_pmm_manager+0x450>
ffffffffc0204368:	00003617          	auipc	a2,0x3
ffffffffc020436c:	8a060613          	addi	a2,a2,-1888 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204370:	23900593          	li	a1,569
ffffffffc0204374:	00004517          	auipc	a0,0x4
ffffffffc0204378:	a6c50513          	addi	a0,a0,-1428 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc020437c:	e9bfb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204380:	a6aff0ef          	jal	ra,ffffffffc02035ea <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0204384:	00003617          	auipc	a2,0x3
ffffffffc0204388:	fcc60613          	addi	a2,a2,-52 # ffffffffc0207350 <commands+0xbc8>
ffffffffc020438c:	06900593          	li	a1,105
ffffffffc0204390:	00003517          	auipc	a0,0x3
ffffffffc0204394:	fb050513          	addi	a0,a0,-80 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0204398:	e7ffb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020439c:	00003617          	auipc	a2,0x3
ffffffffc02043a0:	2bc60613          	addi	a2,a2,700 # ffffffffc0207658 <commands+0xed0>
ffffffffc02043a4:	07400593          	li	a1,116
ffffffffc02043a8:	00003517          	auipc	a0,0x3
ffffffffc02043ac:	f9850513          	addi	a0,a0,-104 # ffffffffc0207340 <commands+0xbb8>
ffffffffc02043b0:	e67fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02043b4:	00004697          	auipc	a3,0x4
ffffffffc02043b8:	b0468693          	addi	a3,a3,-1276 # ffffffffc0207eb8 <default_pmm_manager+0x148>
ffffffffc02043bc:	00003617          	auipc	a2,0x3
ffffffffc02043c0:	84c60613          	addi	a2,a2,-1972 # ffffffffc0206c08 <commands+0x480>
ffffffffc02043c4:	1fc00593          	li	a1,508
ffffffffc02043c8:	00004517          	auipc	a0,0x4
ffffffffc02043cc:	a1850513          	addi	a0,a0,-1512 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc02043d0:	e47fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02043d4:	00004697          	auipc	a3,0x4
ffffffffc02043d8:	ba468693          	addi	a3,a3,-1116 # ffffffffc0207f78 <default_pmm_manager+0x208>
ffffffffc02043dc:	00003617          	auipc	a2,0x3
ffffffffc02043e0:	82c60613          	addi	a2,a2,-2004 # ffffffffc0206c08 <commands+0x480>
ffffffffc02043e4:	21800593          	li	a1,536
ffffffffc02043e8:	00004517          	auipc	a0,0x4
ffffffffc02043ec:	9f850513          	addi	a0,a0,-1544 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc02043f0:	e27fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02043f4:	00004697          	auipc	a3,0x4
ffffffffc02043f8:	dfc68693          	addi	a3,a3,-516 # ffffffffc02081f0 <default_pmm_manager+0x480>
ffffffffc02043fc:	00003617          	auipc	a2,0x3
ffffffffc0204400:	80c60613          	addi	a2,a2,-2036 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204404:	24100593          	li	a1,577
ffffffffc0204408:	00004517          	auipc	a0,0x4
ffffffffc020440c:	9d850513          	addi	a0,a0,-1576 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204410:	e07fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0204414:	00004697          	auipc	a3,0x4
ffffffffc0204418:	bf468693          	addi	a3,a3,-1036 # ffffffffc0208008 <default_pmm_manager+0x298>
ffffffffc020441c:	00002617          	auipc	a2,0x2
ffffffffc0204420:	7ec60613          	addi	a2,a2,2028 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204424:	21700593          	li	a1,535
ffffffffc0204428:	00004517          	auipc	a0,0x4
ffffffffc020442c:	9b850513          	addi	a0,a0,-1608 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204430:	de7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0204434:	00004697          	auipc	a3,0x4
ffffffffc0204438:	c9c68693          	addi	a3,a3,-868 # ffffffffc02080d0 <default_pmm_manager+0x360>
ffffffffc020443c:	00002617          	auipc	a2,0x2
ffffffffc0204440:	7cc60613          	addi	a2,a2,1996 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204444:	21600593          	li	a1,534
ffffffffc0204448:	00004517          	auipc	a0,0x4
ffffffffc020444c:	99850513          	addi	a0,a0,-1640 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204450:	dc7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0204454:	00004697          	auipc	a3,0x4
ffffffffc0204458:	c6468693          	addi	a3,a3,-924 # ffffffffc02080b8 <default_pmm_manager+0x348>
ffffffffc020445c:	00002617          	auipc	a2,0x2
ffffffffc0204460:	7ac60613          	addi	a2,a2,1964 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204464:	21500593          	li	a1,533
ffffffffc0204468:	00004517          	auipc	a0,0x4
ffffffffc020446c:	97850513          	addi	a0,a0,-1672 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204470:	da7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0204474:	00004697          	auipc	a3,0x4
ffffffffc0204478:	c1468693          	addi	a3,a3,-1004 # ffffffffc0208088 <default_pmm_manager+0x318>
ffffffffc020447c:	00002617          	auipc	a2,0x2
ffffffffc0204480:	78c60613          	addi	a2,a2,1932 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204484:	21400593          	li	a1,532
ffffffffc0204488:	00004517          	auipc	a0,0x4
ffffffffc020448c:	95850513          	addi	a0,a0,-1704 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204490:	d87fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0204494:	00004697          	auipc	a3,0x4
ffffffffc0204498:	bdc68693          	addi	a3,a3,-1060 # ffffffffc0208070 <default_pmm_manager+0x300>
ffffffffc020449c:	00002617          	auipc	a2,0x2
ffffffffc02044a0:	76c60613          	addi	a2,a2,1900 # ffffffffc0206c08 <commands+0x480>
ffffffffc02044a4:	21200593          	li	a1,530
ffffffffc02044a8:	00004517          	auipc	a0,0x4
ffffffffc02044ac:	93850513          	addi	a0,a0,-1736 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc02044b0:	d67fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02044b4:	00004697          	auipc	a3,0x4
ffffffffc02044b8:	ba468693          	addi	a3,a3,-1116 # ffffffffc0208058 <default_pmm_manager+0x2e8>
ffffffffc02044bc:	00002617          	auipc	a2,0x2
ffffffffc02044c0:	74c60613          	addi	a2,a2,1868 # ffffffffc0206c08 <commands+0x480>
ffffffffc02044c4:	21100593          	li	a1,529
ffffffffc02044c8:	00004517          	auipc	a0,0x4
ffffffffc02044cc:	91850513          	addi	a0,a0,-1768 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc02044d0:	d47fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02044d4:	00004697          	auipc	a3,0x4
ffffffffc02044d8:	b7468693          	addi	a3,a3,-1164 # ffffffffc0208048 <default_pmm_manager+0x2d8>
ffffffffc02044dc:	00002617          	auipc	a2,0x2
ffffffffc02044e0:	72c60613          	addi	a2,a2,1836 # ffffffffc0206c08 <commands+0x480>
ffffffffc02044e4:	21000593          	li	a1,528
ffffffffc02044e8:	00004517          	auipc	a0,0x4
ffffffffc02044ec:	8f850513          	addi	a0,a0,-1800 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc02044f0:	d27fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02044f4:	00004697          	auipc	a3,0x4
ffffffffc02044f8:	b4468693          	addi	a3,a3,-1212 # ffffffffc0208038 <default_pmm_manager+0x2c8>
ffffffffc02044fc:	00002617          	auipc	a2,0x2
ffffffffc0204500:	70c60613          	addi	a2,a2,1804 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204504:	20f00593          	li	a1,527
ffffffffc0204508:	00004517          	auipc	a0,0x4
ffffffffc020450c:	8d850513          	addi	a0,a0,-1832 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204510:	d07fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0204514:	00004697          	auipc	a3,0x4
ffffffffc0204518:	af468693          	addi	a3,a3,-1292 # ffffffffc0208008 <default_pmm_manager+0x298>
ffffffffc020451c:	00002617          	auipc	a2,0x2
ffffffffc0204520:	6ec60613          	addi	a2,a2,1772 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204524:	20e00593          	li	a1,526
ffffffffc0204528:	00004517          	auipc	a0,0x4
ffffffffc020452c:	8b850513          	addi	a0,a0,-1864 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204530:	ce7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0204534:	00004697          	auipc	a3,0x4
ffffffffc0204538:	a9c68693          	addi	a3,a3,-1380 # ffffffffc0207fd0 <default_pmm_manager+0x260>
ffffffffc020453c:	00002617          	auipc	a2,0x2
ffffffffc0204540:	6cc60613          	addi	a2,a2,1740 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204544:	20d00593          	li	a1,525
ffffffffc0204548:	00004517          	auipc	a0,0x4
ffffffffc020454c:	89850513          	addi	a0,a0,-1896 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204550:	cc7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0204554:	00004697          	auipc	a3,0x4
ffffffffc0204558:	a5468693          	addi	a3,a3,-1452 # ffffffffc0207fa8 <default_pmm_manager+0x238>
ffffffffc020455c:	00002617          	auipc	a2,0x2
ffffffffc0204560:	6ac60613          	addi	a2,a2,1708 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204564:	20a00593          	li	a1,522
ffffffffc0204568:	00004517          	auipc	a0,0x4
ffffffffc020456c:	87850513          	addi	a0,a0,-1928 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204570:	ca7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0204574:	86da                	mv	a3,s6
ffffffffc0204576:	00003617          	auipc	a2,0x3
ffffffffc020457a:	dda60613          	addi	a2,a2,-550 # ffffffffc0207350 <commands+0xbc8>
ffffffffc020457e:	20900593          	li	a1,521
ffffffffc0204582:	00004517          	auipc	a0,0x4
ffffffffc0204586:	85e50513          	addi	a0,a0,-1954 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc020458a:	c8dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc020458e:	86be                	mv	a3,a5
ffffffffc0204590:	00003617          	auipc	a2,0x3
ffffffffc0204594:	dc060613          	addi	a2,a2,-576 # ffffffffc0207350 <commands+0xbc8>
ffffffffc0204598:	06900593          	li	a1,105
ffffffffc020459c:	00003517          	auipc	a0,0x3
ffffffffc02045a0:	da450513          	addi	a0,a0,-604 # ffffffffc0207340 <commands+0xbb8>
ffffffffc02045a4:	c73fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02045a8:	00004697          	auipc	a3,0x4
ffffffffc02045ac:	b7068693          	addi	a3,a3,-1168 # ffffffffc0208118 <default_pmm_manager+0x3a8>
ffffffffc02045b0:	00002617          	auipc	a2,0x2
ffffffffc02045b4:	65860613          	addi	a2,a2,1624 # ffffffffc0206c08 <commands+0x480>
ffffffffc02045b8:	22300593          	li	a1,547
ffffffffc02045bc:	00004517          	auipc	a0,0x4
ffffffffc02045c0:	82450513          	addi	a0,a0,-2012 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc02045c4:	c53fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02045c8:	00004697          	auipc	a3,0x4
ffffffffc02045cc:	b0868693          	addi	a3,a3,-1272 # ffffffffc02080d0 <default_pmm_manager+0x360>
ffffffffc02045d0:	00002617          	auipc	a2,0x2
ffffffffc02045d4:	63860613          	addi	a2,a2,1592 # ffffffffc0206c08 <commands+0x480>
ffffffffc02045d8:	22100593          	li	a1,545
ffffffffc02045dc:	00004517          	auipc	a0,0x4
ffffffffc02045e0:	80450513          	addi	a0,a0,-2044 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc02045e4:	c33fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02045e8:	00004697          	auipc	a3,0x4
ffffffffc02045ec:	b1868693          	addi	a3,a3,-1256 # ffffffffc0208100 <default_pmm_manager+0x390>
ffffffffc02045f0:	00002617          	auipc	a2,0x2
ffffffffc02045f4:	61860613          	addi	a2,a2,1560 # ffffffffc0206c08 <commands+0x480>
ffffffffc02045f8:	22000593          	li	a1,544
ffffffffc02045fc:	00003517          	auipc	a0,0x3
ffffffffc0204600:	7e450513          	addi	a0,a0,2020 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204604:	c13fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0204608:	00004697          	auipc	a3,0x4
ffffffffc020460c:	c7868693          	addi	a3,a3,-904 # ffffffffc0208280 <default_pmm_manager+0x510>
ffffffffc0204610:	00002617          	auipc	a2,0x2
ffffffffc0204614:	5f860613          	addi	a2,a2,1528 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204618:	24400593          	li	a1,580
ffffffffc020461c:	00003517          	auipc	a0,0x3
ffffffffc0204620:	7c450513          	addi	a0,a0,1988 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204624:	bf3fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0204628:	00004697          	auipc	a3,0x4
ffffffffc020462c:	c1868693          	addi	a3,a3,-1000 # ffffffffc0208240 <default_pmm_manager+0x4d0>
ffffffffc0204630:	00002617          	auipc	a2,0x2
ffffffffc0204634:	5d860613          	addi	a2,a2,1496 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204638:	24300593          	li	a1,579
ffffffffc020463c:	00003517          	auipc	a0,0x3
ffffffffc0204640:	7a450513          	addi	a0,a0,1956 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204644:	bd3fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0204648:	00004697          	auipc	a3,0x4
ffffffffc020464c:	be068693          	addi	a3,a3,-1056 # ffffffffc0208228 <default_pmm_manager+0x4b8>
ffffffffc0204650:	00002617          	auipc	a2,0x2
ffffffffc0204654:	5b860613          	addi	a2,a2,1464 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204658:	24200593          	li	a1,578
ffffffffc020465c:	00003517          	auipc	a0,0x3
ffffffffc0204660:	78450513          	addi	a0,a0,1924 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204664:	bb3fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0204668:	86be                	mv	a3,a5
ffffffffc020466a:	00003617          	auipc	a2,0x3
ffffffffc020466e:	ce660613          	addi	a2,a2,-794 # ffffffffc0207350 <commands+0xbc8>
ffffffffc0204672:	20800593          	li	a1,520
ffffffffc0204676:	00003517          	auipc	a0,0x3
ffffffffc020467a:	76a50513          	addi	a0,a0,1898 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc020467e:	b99fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));// 可用内存的起始地址
ffffffffc0204682:	00003617          	auipc	a2,0x3
ffffffffc0204686:	13660613          	addi	a2,a2,310 # ffffffffc02077b8 <commands+0x1030>
ffffffffc020468a:	07f00593          	li	a1,127
ffffffffc020468e:	00003517          	auipc	a0,0x3
ffffffffc0204692:	75250513          	addi	a0,a0,1874 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204696:	b81fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020469a:	00004697          	auipc	a3,0x4
ffffffffc020469e:	c1668693          	addi	a3,a3,-1002 # ffffffffc02082b0 <default_pmm_manager+0x540>
ffffffffc02046a2:	00002617          	auipc	a2,0x2
ffffffffc02046a6:	56660613          	addi	a2,a2,1382 # ffffffffc0206c08 <commands+0x480>
ffffffffc02046aa:	24800593          	li	a1,584
ffffffffc02046ae:	00003517          	auipc	a0,0x3
ffffffffc02046b2:	73250513          	addi	a0,a0,1842 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc02046b6:	b61fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02046ba:	00004697          	auipc	a3,0x4
ffffffffc02046be:	a8668693          	addi	a3,a3,-1402 # ffffffffc0208140 <default_pmm_manager+0x3d0>
ffffffffc02046c2:	00002617          	auipc	a2,0x2
ffffffffc02046c6:	54660613          	addi	a2,a2,1350 # ffffffffc0206c08 <commands+0x480>
ffffffffc02046ca:	25400593          	li	a1,596
ffffffffc02046ce:	00003517          	auipc	a0,0x3
ffffffffc02046d2:	71250513          	addi	a0,a0,1810 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc02046d6:	b41fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02046da:	00004697          	auipc	a3,0x4
ffffffffc02046de:	8b668693          	addi	a3,a3,-1866 # ffffffffc0207f90 <default_pmm_manager+0x220>
ffffffffc02046e2:	00002617          	auipc	a2,0x2
ffffffffc02046e6:	52660613          	addi	a2,a2,1318 # ffffffffc0206c08 <commands+0x480>
ffffffffc02046ea:	20600593          	li	a1,518
ffffffffc02046ee:	00003517          	auipc	a0,0x3
ffffffffc02046f2:	6f250513          	addi	a0,a0,1778 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc02046f6:	b21fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02046fa:	00004697          	auipc	a3,0x4
ffffffffc02046fe:	87e68693          	addi	a3,a3,-1922 # ffffffffc0207f78 <default_pmm_manager+0x208>
ffffffffc0204702:	00002617          	auipc	a2,0x2
ffffffffc0204706:	50660613          	addi	a2,a2,1286 # ffffffffc0206c08 <commands+0x480>
ffffffffc020470a:	20500593          	li	a1,517
ffffffffc020470e:	00003517          	auipc	a0,0x3
ffffffffc0204712:	6d250513          	addi	a0,a0,1746 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204716:	b01fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020471a:	00003697          	auipc	a3,0x3
ffffffffc020471e:	7d668693          	addi	a3,a3,2006 # ffffffffc0207ef0 <default_pmm_manager+0x180>
ffffffffc0204722:	00002617          	auipc	a2,0x2
ffffffffc0204726:	4e660613          	addi	a2,a2,1254 # ffffffffc0206c08 <commands+0x480>
ffffffffc020472a:	1fd00593          	li	a1,509
ffffffffc020472e:	00003517          	auipc	a0,0x3
ffffffffc0204732:	6b250513          	addi	a0,a0,1714 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204736:	ae1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020473a:	00004697          	auipc	a3,0x4
ffffffffc020473e:	80e68693          	addi	a3,a3,-2034 # ffffffffc0207f48 <default_pmm_manager+0x1d8>
ffffffffc0204742:	00002617          	auipc	a2,0x2
ffffffffc0204746:	4c660613          	addi	a2,a2,1222 # ffffffffc0206c08 <commands+0x480>
ffffffffc020474a:	20400593          	li	a1,516
ffffffffc020474e:	00003517          	auipc	a0,0x3
ffffffffc0204752:	69250513          	addi	a0,a0,1682 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204756:	ac1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020475a:	00003697          	auipc	a3,0x3
ffffffffc020475e:	7be68693          	addi	a3,a3,1982 # ffffffffc0207f18 <default_pmm_manager+0x1a8>
ffffffffc0204762:	00002617          	auipc	a2,0x2
ffffffffc0204766:	4a660613          	addi	a2,a2,1190 # ffffffffc0206c08 <commands+0x480>
ffffffffc020476a:	20100593          	li	a1,513
ffffffffc020476e:	00003517          	auipc	a0,0x3
ffffffffc0204772:	67250513          	addi	a0,a0,1650 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204776:	aa1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020477a:	00004697          	auipc	a3,0x4
ffffffffc020477e:	95668693          	addi	a3,a3,-1706 # ffffffffc02080d0 <default_pmm_manager+0x360>
ffffffffc0204782:	00002617          	auipc	a2,0x2
ffffffffc0204786:	48660613          	addi	a2,a2,1158 # ffffffffc0206c08 <commands+0x480>
ffffffffc020478a:	21d00593          	li	a1,541
ffffffffc020478e:	00003517          	auipc	a0,0x3
ffffffffc0204792:	65250513          	addi	a0,a0,1618 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204796:	a81fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020479a:	00003697          	auipc	a3,0x3
ffffffffc020479e:	7f668693          	addi	a3,a3,2038 # ffffffffc0207f90 <default_pmm_manager+0x220>
ffffffffc02047a2:	00002617          	auipc	a2,0x2
ffffffffc02047a6:	46660613          	addi	a2,a2,1126 # ffffffffc0206c08 <commands+0x480>
ffffffffc02047aa:	21c00593          	li	a1,540
ffffffffc02047ae:	00003517          	auipc	a0,0x3
ffffffffc02047b2:	63250513          	addi	a0,a0,1586 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc02047b6:	a61fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02047ba:	00004697          	auipc	a3,0x4
ffffffffc02047be:	92e68693          	addi	a3,a3,-1746 # ffffffffc02080e8 <default_pmm_manager+0x378>
ffffffffc02047c2:	00002617          	auipc	a2,0x2
ffffffffc02047c6:	44660613          	addi	a2,a2,1094 # ffffffffc0206c08 <commands+0x480>
ffffffffc02047ca:	21900593          	li	a1,537
ffffffffc02047ce:	00003517          	auipc	a0,0x3
ffffffffc02047d2:	61250513          	addi	a0,a0,1554 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc02047d6:	a41fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02047da:	00004697          	auipc	a3,0x4
ffffffffc02047de:	b0e68693          	addi	a3,a3,-1266 # ffffffffc02082e8 <default_pmm_manager+0x578>
ffffffffc02047e2:	00002617          	auipc	a2,0x2
ffffffffc02047e6:	42660613          	addi	a2,a2,1062 # ffffffffc0206c08 <commands+0x480>
ffffffffc02047ea:	24b00593          	li	a1,587
ffffffffc02047ee:	00003517          	auipc	a0,0x3
ffffffffc02047f2:	5f250513          	addi	a0,a0,1522 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc02047f6:	a21fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02047fa:	00004697          	auipc	a3,0x4
ffffffffc02047fe:	94668693          	addi	a3,a3,-1722 # ffffffffc0208140 <default_pmm_manager+0x3d0>
ffffffffc0204802:	00002617          	auipc	a2,0x2
ffffffffc0204806:	40660613          	addi	a2,a2,1030 # ffffffffc0206c08 <commands+0x480>
ffffffffc020480a:	22b00593          	li	a1,555
ffffffffc020480e:	00003517          	auipc	a0,0x3
ffffffffc0204812:	5d250513          	addi	a0,a0,1490 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204816:	a01fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc020481a:	00004697          	auipc	a3,0x4
ffffffffc020481e:	9be68693          	addi	a3,a3,-1602 # ffffffffc02081d8 <default_pmm_manager+0x468>
ffffffffc0204822:	00002617          	auipc	a2,0x2
ffffffffc0204826:	3e660613          	addi	a2,a2,998 # ffffffffc0206c08 <commands+0x480>
ffffffffc020482a:	23d00593          	li	a1,573
ffffffffc020482e:	00003517          	auipc	a0,0x3
ffffffffc0204832:	5b250513          	addi	a0,a0,1458 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204836:	9e1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020483a:	00003697          	auipc	a3,0x3
ffffffffc020483e:	65e68693          	addi	a3,a3,1630 # ffffffffc0207e98 <default_pmm_manager+0x128>
ffffffffc0204842:	00002617          	auipc	a2,0x2
ffffffffc0204846:	3c660613          	addi	a2,a2,966 # ffffffffc0206c08 <commands+0x480>
ffffffffc020484a:	1fb00593          	li	a1,507
ffffffffc020484e:	00003517          	auipc	a0,0x3
ffffffffc0204852:	59250513          	addi	a0,a0,1426 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204856:	9c1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020485a:	00003617          	auipc	a2,0x3
ffffffffc020485e:	f5e60613          	addi	a2,a2,-162 # ffffffffc02077b8 <commands+0x1030>
ffffffffc0204862:	0c300593          	li	a1,195
ffffffffc0204866:	00003517          	auipc	a0,0x3
ffffffffc020486a:	57a50513          	addi	a0,a0,1402 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc020486e:	9a9fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204872 <copy_range>:
               bool share) {
ffffffffc0204872:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0204874:	00d66733          	or	a4,a2,a3
               bool share) {
ffffffffc0204878:	fc86                	sd	ra,120(sp)
ffffffffc020487a:	f8a2                	sd	s0,112(sp)
ffffffffc020487c:	f4a6                	sd	s1,104(sp)
ffffffffc020487e:	f0ca                	sd	s2,96(sp)
ffffffffc0204880:	ecce                	sd	s3,88(sp)
ffffffffc0204882:	e8d2                	sd	s4,80(sp)
ffffffffc0204884:	e4d6                	sd	s5,72(sp)
ffffffffc0204886:	e0da                	sd	s6,64(sp)
ffffffffc0204888:	fc5e                	sd	s7,56(sp)
ffffffffc020488a:	f862                	sd	s8,48(sp)
ffffffffc020488c:	f466                	sd	s9,40(sp)
ffffffffc020488e:	f06a                	sd	s10,32(sp)
ffffffffc0204890:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0204892:	03471793          	slli	a5,a4,0x34
ffffffffc0204896:	1c079b63          	bnez	a5,ffffffffc0204a6c <copy_range+0x1fa>
    assert(USER_ACCESS(start, end));
ffffffffc020489a:	00200737          	lui	a4,0x200
ffffffffc020489e:	8db2                	mv	s11,a2
ffffffffc02048a0:	18e66663          	bltu	a2,a4,ffffffffc0204a2c <copy_range+0x1ba>
ffffffffc02048a4:	84b6                	mv	s1,a3
ffffffffc02048a6:	18d67363          	bleu	a3,a2,ffffffffc0204a2c <copy_range+0x1ba>
ffffffffc02048aa:	4705                	li	a4,1
ffffffffc02048ac:	077e                	slli	a4,a4,0x1f
ffffffffc02048ae:	16d76f63          	bltu	a4,a3,ffffffffc0204a2c <copy_range+0x1ba>
ffffffffc02048b2:	5a7d                	li	s4,-1
ffffffffc02048b4:	8aaa                	mv	s5,a0
ffffffffc02048b6:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc02048b8:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc02048ba:	000a8b97          	auipc	s7,0xa8
ffffffffc02048be:	b26b8b93          	addi	s7,s7,-1242 # ffffffffc02ac3e0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02048c2:	000a8b17          	auipc	s6,0xa8
ffffffffc02048c6:	c5eb0b13          	addi	s6,s6,-930 # ffffffffc02ac520 <pages>
    return page - pages + nbase;
ffffffffc02048ca:	00080c37          	lui	s8,0x80
    return KADDR(page2pa(page));
ffffffffc02048ce:	00ca5a13          	srli	s4,s4,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02048d2:	4601                	li	a2,0
ffffffffc02048d4:	85ee                	mv	a1,s11
ffffffffc02048d6:	854a                	mv	a0,s2
ffffffffc02048d8:	e3dfe0ef          	jal	ra,ffffffffc0203714 <get_pte>
ffffffffc02048dc:	842a                	mv	s0,a0
        if (ptep == NULL) {
ffffffffc02048de:	c179                	beqz	a0,ffffffffc02049a4 <copy_range+0x132>
        if (*ptep & PTE_V) {
ffffffffc02048e0:	6118                	ld	a4,0(a0)
ffffffffc02048e2:	8b05                	andi	a4,a4,1
ffffffffc02048e4:	e705                	bnez	a4,ffffffffc020490c <copy_range+0x9a>
        start += PGSIZE;
ffffffffc02048e6:	9dce                	add	s11,s11,s3
    } while (start != 0 && start < end);
ffffffffc02048e8:	fe9de5e3          	bltu	s11,s1,ffffffffc02048d2 <copy_range+0x60>
    return 0;
ffffffffc02048ec:	4501                	li	a0,0
}
ffffffffc02048ee:	70e6                	ld	ra,120(sp)
ffffffffc02048f0:	7446                	ld	s0,112(sp)
ffffffffc02048f2:	74a6                	ld	s1,104(sp)
ffffffffc02048f4:	7906                	ld	s2,96(sp)
ffffffffc02048f6:	69e6                	ld	s3,88(sp)
ffffffffc02048f8:	6a46                	ld	s4,80(sp)
ffffffffc02048fa:	6aa6                	ld	s5,72(sp)
ffffffffc02048fc:	6b06                	ld	s6,64(sp)
ffffffffc02048fe:	7be2                	ld	s7,56(sp)
ffffffffc0204900:	7c42                	ld	s8,48(sp)
ffffffffc0204902:	7ca2                	ld	s9,40(sp)
ffffffffc0204904:	7d02                	ld	s10,32(sp)
ffffffffc0204906:	6de2                	ld	s11,24(sp)
ffffffffc0204908:	6109                	addi	sp,sp,128
ffffffffc020490a:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc020490c:	4605                	li	a2,1
ffffffffc020490e:	85ee                	mv	a1,s11
ffffffffc0204910:	8556                	mv	a0,s5
ffffffffc0204912:	e03fe0ef          	jal	ra,ffffffffc0203714 <get_pte>
ffffffffc0204916:	c545                	beqz	a0,ffffffffc02049be <copy_range+0x14c>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0204918:	6018                	ld	a4,0(s0)
    if (!(pte & PTE_V)) {
ffffffffc020491a:	00177693          	andi	a3,a4,1
ffffffffc020491e:	01f77c93          	andi	s9,a4,31
ffffffffc0204922:	0e068963          	beqz	a3,ffffffffc0204a14 <copy_range+0x1a2>
    if (PPN(pa) >= npage) {
ffffffffc0204926:	000bb683          	ld	a3,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc020492a:	070a                	slli	a4,a4,0x2
ffffffffc020492c:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc020492e:	0cd77763          	bleu	a3,a4,ffffffffc02049fc <copy_range+0x18a>
    return &pages[PPN(pa) - nbase];
ffffffffc0204932:	000b3683          	ld	a3,0(s6)
ffffffffc0204936:	fff807b7          	lui	a5,0xfff80
ffffffffc020493a:	973e                	add	a4,a4,a5
ffffffffc020493c:	071a                	slli	a4,a4,0x6
ffffffffc020493e:	9736                	add	a4,a4,a3
            struct Page *npage = alloc_page();
ffffffffc0204940:	4505                	li	a0,1
ffffffffc0204942:	e43a                	sd	a4,8(sp)
ffffffffc0204944:	cc3fe0ef          	jal	ra,ffffffffc0203606 <alloc_pages>
            assert(page != NULL);
ffffffffc0204948:	6722                	ld	a4,8(sp)
            struct Page *npage = alloc_page();
ffffffffc020494a:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc020494c:	cb41                	beqz	a4,ffffffffc02049dc <copy_range+0x16a>
            assert(npage != NULL);
ffffffffc020494e:	0e050f63          	beqz	a0,ffffffffc0204a4c <copy_range+0x1da>
    return page - pages + nbase;
ffffffffc0204952:	000b3703          	ld	a4,0(s6)
    return KADDR(page2pa(page));
ffffffffc0204956:	000bb603          	ld	a2,0(s7)
    return page - pages + nbase;
ffffffffc020495a:	40e406b3          	sub	a3,s0,a4
ffffffffc020495e:	8699                	srai	a3,a3,0x6
ffffffffc0204960:	96e2                	add	a3,a3,s8
    return KADDR(page2pa(page));
ffffffffc0204962:	0146f5b3          	and	a1,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc0204966:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204968:	04c5fe63          	bleu	a2,a1,ffffffffc02049c4 <copy_range+0x152>
    return page - pages + nbase;
ffffffffc020496c:	40e50733          	sub	a4,a0,a4
    return KADDR(page2pa(page));
ffffffffc0204970:	000a8797          	auipc	a5,0xa8
ffffffffc0204974:	ba078793          	addi	a5,a5,-1120 # ffffffffc02ac510 <va_pa_offset>
ffffffffc0204978:	6388                	ld	a0,0(a5)
    return page - pages + nbase;
ffffffffc020497a:	8719                	srai	a4,a4,0x6
ffffffffc020497c:	9762                	add	a4,a4,s8
    return KADDR(page2pa(page));
ffffffffc020497e:	014778b3          	and	a7,a4,s4
ffffffffc0204982:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0204986:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc0204988:	02c8fd63          	bleu	a2,a7,ffffffffc02049c2 <copy_range+0x150>
            memcpy((void *)dst_kvaddr, (void *)src_kvaddr, PGSIZE);
ffffffffc020498c:	6605                	lui	a2,0x1
ffffffffc020498e:	953a                	add	a0,a0,a4
ffffffffc0204990:	05b010ef          	jal	ra,ffffffffc02061ea <memcpy>
            page_insert(to, npage, start, perm);
ffffffffc0204994:	866e                	mv	a2,s11
ffffffffc0204996:	86e6                	mv	a3,s9
ffffffffc0204998:	85ea                	mv	a1,s10
ffffffffc020499a:	8556                	mv	a0,s5
ffffffffc020499c:	b8eff0ef          	jal	ra,ffffffffc0203d2a <page_insert>
        start += PGSIZE;
ffffffffc02049a0:	9dce                	add	s11,s11,s3
ffffffffc02049a2:	b799                	j	ffffffffc02048e8 <copy_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02049a4:	00200737          	lui	a4,0x200
ffffffffc02049a8:	00ed87b3          	add	a5,s11,a4
ffffffffc02049ac:	ffe00737          	lui	a4,0xffe00
ffffffffc02049b0:	00e7fdb3          	and	s11,a5,a4
    } while (start != 0 && start < end);
ffffffffc02049b4:	f20d8ce3          	beqz	s11,ffffffffc02048ec <copy_range+0x7a>
ffffffffc02049b8:	f09dede3          	bltu	s11,s1,ffffffffc02048d2 <copy_range+0x60>
ffffffffc02049bc:	bf05                	j	ffffffffc02048ec <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc02049be:	5571                	li	a0,-4
ffffffffc02049c0:	b73d                	j	ffffffffc02048ee <copy_range+0x7c>
ffffffffc02049c2:	86ba                	mv	a3,a4
ffffffffc02049c4:	00003617          	auipc	a2,0x3
ffffffffc02049c8:	98c60613          	addi	a2,a2,-1652 # ffffffffc0207350 <commands+0xbc8>
ffffffffc02049cc:	06900593          	li	a1,105
ffffffffc02049d0:	00003517          	auipc	a0,0x3
ffffffffc02049d4:	97050513          	addi	a0,a0,-1680 # ffffffffc0207340 <commands+0xbb8>
ffffffffc02049d8:	83ffb0ef          	jal	ra,ffffffffc0200216 <__panic>
            assert(page != NULL);
ffffffffc02049dc:	00003697          	auipc	a3,0x3
ffffffffc02049e0:	3e468693          	addi	a3,a3,996 # ffffffffc0207dc0 <default_pmm_manager+0x50>
ffffffffc02049e4:	00002617          	auipc	a2,0x2
ffffffffc02049e8:	22460613          	addi	a2,a2,548 # ffffffffc0206c08 <commands+0x480>
ffffffffc02049ec:	17700593          	li	a1,375
ffffffffc02049f0:	00003517          	auipc	a0,0x3
ffffffffc02049f4:	3f050513          	addi	a0,a0,1008 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc02049f8:	81ffb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02049fc:	00003617          	auipc	a2,0x3
ffffffffc0204a00:	92460613          	addi	a2,a2,-1756 # ffffffffc0207320 <commands+0xb98>
ffffffffc0204a04:	06200593          	li	a1,98
ffffffffc0204a08:	00003517          	auipc	a0,0x3
ffffffffc0204a0c:	93850513          	addi	a0,a0,-1736 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0204a10:	807fb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0204a14:	00003617          	auipc	a2,0x3
ffffffffc0204a18:	c4460613          	addi	a2,a2,-956 # ffffffffc0207658 <commands+0xed0>
ffffffffc0204a1c:	07400593          	li	a1,116
ffffffffc0204a20:	00003517          	auipc	a0,0x3
ffffffffc0204a24:	92050513          	addi	a0,a0,-1760 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0204a28:	feefb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0204a2c:	00004697          	auipc	a3,0x4
ffffffffc0204a30:	93468693          	addi	a3,a3,-1740 # ffffffffc0208360 <default_pmm_manager+0x5f0>
ffffffffc0204a34:	00002617          	auipc	a2,0x2
ffffffffc0204a38:	1d460613          	addi	a2,a2,468 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204a3c:	16300593          	li	a1,355
ffffffffc0204a40:	00003517          	auipc	a0,0x3
ffffffffc0204a44:	3a050513          	addi	a0,a0,928 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204a48:	fcefb0ef          	jal	ra,ffffffffc0200216 <__panic>
            assert(npage != NULL);
ffffffffc0204a4c:	00003697          	auipc	a3,0x3
ffffffffc0204a50:	38468693          	addi	a3,a3,900 # ffffffffc0207dd0 <default_pmm_manager+0x60>
ffffffffc0204a54:	00002617          	auipc	a2,0x2
ffffffffc0204a58:	1b460613          	addi	a2,a2,436 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204a5c:	17800593          	li	a1,376
ffffffffc0204a60:	00003517          	auipc	a0,0x3
ffffffffc0204a64:	38050513          	addi	a0,a0,896 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204a68:	faefb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0204a6c:	00004697          	auipc	a3,0x4
ffffffffc0204a70:	8c468693          	addi	a3,a3,-1852 # ffffffffc0208330 <default_pmm_manager+0x5c0>
ffffffffc0204a74:	00002617          	auipc	a2,0x2
ffffffffc0204a78:	19460613          	addi	a2,a2,404 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204a7c:	16200593          	li	a1,354
ffffffffc0204a80:	00003517          	auipc	a0,0x3
ffffffffc0204a84:	36050513          	addi	a0,a0,864 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204a88:	f8efb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204a8c <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0204a8c:	12058073          	sfence.vma	a1
}
ffffffffc0204a90:	8082                	ret

ffffffffc0204a92 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204a92:	7179                	addi	sp,sp,-48
ffffffffc0204a94:	e84a                	sd	s2,16(sp)
ffffffffc0204a96:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0204a98:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204a9a:	f022                	sd	s0,32(sp)
ffffffffc0204a9c:	ec26                	sd	s1,24(sp)
ffffffffc0204a9e:	e44e                	sd	s3,8(sp)
ffffffffc0204aa0:	f406                	sd	ra,40(sp)
ffffffffc0204aa2:	84ae                	mv	s1,a1
ffffffffc0204aa4:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0204aa6:	b61fe0ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0204aaa:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0204aac:	cd1d                	beqz	a0,ffffffffc0204aea <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0204aae:	85aa                	mv	a1,a0
ffffffffc0204ab0:	86ce                	mv	a3,s3
ffffffffc0204ab2:	8626                	mv	a2,s1
ffffffffc0204ab4:	854a                	mv	a0,s2
ffffffffc0204ab6:	a74ff0ef          	jal	ra,ffffffffc0203d2a <page_insert>
ffffffffc0204aba:	e121                	bnez	a0,ffffffffc0204afa <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc0204abc:	000a8797          	auipc	a5,0xa8
ffffffffc0204ac0:	90c78793          	addi	a5,a5,-1780 # ffffffffc02ac3c8 <swap_init_ok>
ffffffffc0204ac4:	439c                	lw	a5,0(a5)
ffffffffc0204ac6:	2781                	sext.w	a5,a5
ffffffffc0204ac8:	c38d                	beqz	a5,ffffffffc0204aea <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc0204aca:	000a8797          	auipc	a5,0xa8
ffffffffc0204ace:	94678793          	addi	a5,a5,-1722 # ffffffffc02ac410 <check_mm_struct>
ffffffffc0204ad2:	6388                	ld	a0,0(a5)
ffffffffc0204ad4:	c919                	beqz	a0,ffffffffc0204aea <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0204ad6:	4681                	li	a3,0
ffffffffc0204ad8:	8622                	mv	a2,s0
ffffffffc0204ada:	85a6                	mv	a1,s1
ffffffffc0204adc:	da8fd0ef          	jal	ra,ffffffffc0202084 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0204ae0:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0204ae2:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0204ae4:	4785                	li	a5,1
ffffffffc0204ae6:	02f71063          	bne	a4,a5,ffffffffc0204b06 <pgdir_alloc_page+0x74>
}
ffffffffc0204aea:	8522                	mv	a0,s0
ffffffffc0204aec:	70a2                	ld	ra,40(sp)
ffffffffc0204aee:	7402                	ld	s0,32(sp)
ffffffffc0204af0:	64e2                	ld	s1,24(sp)
ffffffffc0204af2:	6942                	ld	s2,16(sp)
ffffffffc0204af4:	69a2                	ld	s3,8(sp)
ffffffffc0204af6:	6145                	addi	sp,sp,48
ffffffffc0204af8:	8082                	ret
            free_page(page);
ffffffffc0204afa:	8522                	mv	a0,s0
ffffffffc0204afc:	4585                	li	a1,1
ffffffffc0204afe:	b91fe0ef          	jal	ra,ffffffffc020368e <free_pages>
            return NULL;
ffffffffc0204b02:	4401                	li	s0,0
ffffffffc0204b04:	b7dd                	j	ffffffffc0204aea <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc0204b06:	00003697          	auipc	a3,0x3
ffffffffc0204b0a:	2ea68693          	addi	a3,a3,746 # ffffffffc0207df0 <default_pmm_manager+0x80>
ffffffffc0204b0e:	00002617          	auipc	a2,0x2
ffffffffc0204b12:	0fa60613          	addi	a2,a2,250 # ffffffffc0206c08 <commands+0x480>
ffffffffc0204b16:	1dc00593          	li	a1,476
ffffffffc0204b1a:	00003517          	auipc	a0,0x3
ffffffffc0204b1e:	2c650513          	addi	a0,a0,710 # ffffffffc0207de0 <default_pmm_manager+0x70>
ffffffffc0204b22:	ef4fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204b26 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b26:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b28:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b2a:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b2c:	a09fb0ef          	jal	ra,ffffffffc0200534 <ide_device_valid>
ffffffffc0204b30:	cd01                	beqz	a0,ffffffffc0204b48 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b32:	4505                	li	a0,1
ffffffffc0204b34:	a07fb0ef          	jal	ra,ffffffffc020053a <ide_device_size>
}
ffffffffc0204b38:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b3a:	810d                	srli	a0,a0,0x3
ffffffffc0204b3c:	000a8797          	auipc	a5,0xa8
ffffffffc0204b40:	96a7b223          	sd	a0,-1692(a5) # ffffffffc02ac4a0 <max_swap_offset>
}
ffffffffc0204b44:	0141                	addi	sp,sp,16
ffffffffc0204b46:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b48:	00004617          	auipc	a2,0x4
ffffffffc0204b4c:	83060613          	addi	a2,a2,-2000 # ffffffffc0208378 <default_pmm_manager+0x608>
ffffffffc0204b50:	45b5                	li	a1,13
ffffffffc0204b52:	00004517          	auipc	a0,0x4
ffffffffc0204b56:	84650513          	addi	a0,a0,-1978 # ffffffffc0208398 <default_pmm_manager+0x628>
ffffffffc0204b5a:	ebcfb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204b5e <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204b5e:	1141                	addi	sp,sp,-16
ffffffffc0204b60:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b62:	00855793          	srli	a5,a0,0x8
ffffffffc0204b66:	cfb9                	beqz	a5,ffffffffc0204bc4 <swapfs_read+0x66>
ffffffffc0204b68:	000a8717          	auipc	a4,0xa8
ffffffffc0204b6c:	93870713          	addi	a4,a4,-1736 # ffffffffc02ac4a0 <max_swap_offset>
ffffffffc0204b70:	6318                	ld	a4,0(a4)
ffffffffc0204b72:	04e7f963          	bleu	a4,a5,ffffffffc0204bc4 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204b76:	000a8717          	auipc	a4,0xa8
ffffffffc0204b7a:	9aa70713          	addi	a4,a4,-1622 # ffffffffc02ac520 <pages>
ffffffffc0204b7e:	6310                	ld	a2,0(a4)
ffffffffc0204b80:	00004717          	auipc	a4,0x4
ffffffffc0204b84:	19070713          	addi	a4,a4,400 # ffffffffc0208d10 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204b88:	000a8697          	auipc	a3,0xa8
ffffffffc0204b8c:	85868693          	addi	a3,a3,-1960 # ffffffffc02ac3e0 <npage>
    return page - pages + nbase;
ffffffffc0204b90:	40c58633          	sub	a2,a1,a2
ffffffffc0204b94:	630c                	ld	a1,0(a4)
ffffffffc0204b96:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204b98:	577d                	li	a4,-1
ffffffffc0204b9a:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204b9c:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204b9e:	8331                	srli	a4,a4,0xc
ffffffffc0204ba0:	8f71                	and	a4,a4,a2
ffffffffc0204ba2:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ba6:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204ba8:	02d77a63          	bleu	a3,a4,ffffffffc0204bdc <swapfs_read+0x7e>
ffffffffc0204bac:	000a8797          	auipc	a5,0xa8
ffffffffc0204bb0:	96478793          	addi	a5,a5,-1692 # ffffffffc02ac510 <va_pa_offset>
ffffffffc0204bb4:	639c                	ld	a5,0(a5)
}
ffffffffc0204bb6:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bb8:	46a1                	li	a3,8
ffffffffc0204bba:	963e                	add	a2,a2,a5
ffffffffc0204bbc:	4505                	li	a0,1
}
ffffffffc0204bbe:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bc0:	981fb06f          	j	ffffffffc0200540 <ide_read_secs>
ffffffffc0204bc4:	86aa                	mv	a3,a0
ffffffffc0204bc6:	00003617          	auipc	a2,0x3
ffffffffc0204bca:	7ea60613          	addi	a2,a2,2026 # ffffffffc02083b0 <default_pmm_manager+0x640>
ffffffffc0204bce:	45d1                	li	a1,20
ffffffffc0204bd0:	00003517          	auipc	a0,0x3
ffffffffc0204bd4:	7c850513          	addi	a0,a0,1992 # ffffffffc0208398 <default_pmm_manager+0x628>
ffffffffc0204bd8:	e3efb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204bdc:	86b2                	mv	a3,a2
ffffffffc0204bde:	06900593          	li	a1,105
ffffffffc0204be2:	00002617          	auipc	a2,0x2
ffffffffc0204be6:	76e60613          	addi	a2,a2,1902 # ffffffffc0207350 <commands+0xbc8>
ffffffffc0204bea:	00002517          	auipc	a0,0x2
ffffffffc0204bee:	75650513          	addi	a0,a0,1878 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0204bf2:	e24fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204bf6 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204bf6:	1141                	addi	sp,sp,-16
ffffffffc0204bf8:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bfa:	00855793          	srli	a5,a0,0x8
ffffffffc0204bfe:	cfb9                	beqz	a5,ffffffffc0204c5c <swapfs_write+0x66>
ffffffffc0204c00:	000a8717          	auipc	a4,0xa8
ffffffffc0204c04:	8a070713          	addi	a4,a4,-1888 # ffffffffc02ac4a0 <max_swap_offset>
ffffffffc0204c08:	6318                	ld	a4,0(a4)
ffffffffc0204c0a:	04e7f963          	bleu	a4,a5,ffffffffc0204c5c <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204c0e:	000a8717          	auipc	a4,0xa8
ffffffffc0204c12:	91270713          	addi	a4,a4,-1774 # ffffffffc02ac520 <pages>
ffffffffc0204c16:	6310                	ld	a2,0(a4)
ffffffffc0204c18:	00004717          	auipc	a4,0x4
ffffffffc0204c1c:	0f870713          	addi	a4,a4,248 # ffffffffc0208d10 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204c20:	000a7697          	auipc	a3,0xa7
ffffffffc0204c24:	7c068693          	addi	a3,a3,1984 # ffffffffc02ac3e0 <npage>
    return page - pages + nbase;
ffffffffc0204c28:	40c58633          	sub	a2,a1,a2
ffffffffc0204c2c:	630c                	ld	a1,0(a4)
ffffffffc0204c2e:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204c30:	577d                	li	a4,-1
ffffffffc0204c32:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204c34:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204c36:	8331                	srli	a4,a4,0xc
ffffffffc0204c38:	8f71                	and	a4,a4,a2
ffffffffc0204c3a:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c3e:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c40:	02d77a63          	bleu	a3,a4,ffffffffc0204c74 <swapfs_write+0x7e>
ffffffffc0204c44:	000a8797          	auipc	a5,0xa8
ffffffffc0204c48:	8cc78793          	addi	a5,a5,-1844 # ffffffffc02ac510 <va_pa_offset>
ffffffffc0204c4c:	639c                	ld	a5,0(a5)
}
ffffffffc0204c4e:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c50:	46a1                	li	a3,8
ffffffffc0204c52:	963e                	add	a2,a2,a5
ffffffffc0204c54:	4505                	li	a0,1
}
ffffffffc0204c56:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c58:	90dfb06f          	j	ffffffffc0200564 <ide_write_secs>
ffffffffc0204c5c:	86aa                	mv	a3,a0
ffffffffc0204c5e:	00003617          	auipc	a2,0x3
ffffffffc0204c62:	75260613          	addi	a2,a2,1874 # ffffffffc02083b0 <default_pmm_manager+0x640>
ffffffffc0204c66:	45e5                	li	a1,25
ffffffffc0204c68:	00003517          	auipc	a0,0x3
ffffffffc0204c6c:	73050513          	addi	a0,a0,1840 # ffffffffc0208398 <default_pmm_manager+0x628>
ffffffffc0204c70:	da6fb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204c74:	86b2                	mv	a3,a2
ffffffffc0204c76:	06900593          	li	a1,105
ffffffffc0204c7a:	00002617          	auipc	a2,0x2
ffffffffc0204c7e:	6d660613          	addi	a2,a2,1750 # ffffffffc0207350 <commands+0xbc8>
ffffffffc0204c82:	00002517          	auipc	a0,0x2
ffffffffc0204c86:	6be50513          	addi	a0,a0,1726 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0204c8a:	d8cfb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204c8e <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204c8e:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204c90:	9402                	jalr	s0

	jal do_exit
ffffffffc0204c92:	796000ef          	jal	ra,ffffffffc0205428 <do_exit>

ffffffffc0204c96 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204c96:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204c9a:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204c9e:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204ca0:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204ca2:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204ca6:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204caa:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204cae:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204cb2:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204cb6:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204cba:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204cbe:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204cc2:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204cc6:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204cca:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204cce:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204cd2:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204cd4:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204cd6:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204cda:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204cde:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204ce2:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204ce6:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204cea:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204cee:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204cf2:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204cf6:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204cfa:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204cfe:	8082                	ret

ffffffffc0204d00 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204d00:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d02:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204d06:	e022                	sd	s0,0(sp)
ffffffffc0204d08:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d0a:	fcafd0ef          	jal	ra,ffffffffc02024d4 <kmalloc>
ffffffffc0204d0e:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204d10:	cd29                	beqz	a0,ffffffffc0204d6a <alloc_proc+0x6a>
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
        // 初始化进程状态为 PROC_UNINIT，设置进程为“初始”态
        proc->state = PROC_UNINIT;
ffffffffc0204d12:	57fd                	li	a5,-1
ffffffffc0204d14:	1782                	slli	a5,a5,0x20
ffffffffc0204d16:	e11c                	sd	a5,0(a0)
        // 初始化父进程指针为 NULL
        proc->parent = NULL;
        // 初始化内存管理结构为 NULL
        proc->mm = NULL;
        // 初始化上下文结构
        memset(&proc->context, 0, sizeof(struct context));
ffffffffc0204d18:	07000613          	li	a2,112
ffffffffc0204d1c:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0204d1e:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204d22:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204d26:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204d2a:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204d2e:	02053423          	sd	zero,40(a0)
        memset(&proc->context, 0, sizeof(struct context));
ffffffffc0204d32:	03050513          	addi	a0,a0,48
ffffffffc0204d36:	4a2010ef          	jal	ra,ffffffffc02061d8 <memset>
        // 初始化中断帧指针为 NULL
        proc->tf = NULL;
        // 初始化 CR3 寄存器值为 boot_cr3?
        proc->cr3 = boot_cr3;
ffffffffc0204d3a:	000a7797          	auipc	a5,0xa7
ffffffffc0204d3e:	7de78793          	addi	a5,a5,2014 # ffffffffc02ac518 <boot_cr3>
ffffffffc0204d42:	639c                	ld	a5,0(a5)
        proc->tf = NULL;
ffffffffc0204d44:	0a043023          	sd	zero,160(s0)
        // 初始化进程标志位为 0
        proc->flags = 0;
ffffffffc0204d48:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3;
ffffffffc0204d4c:	f45c                	sd	a5,168(s0)
        // 初始化进程名字为空字符串，set_proc_name中以实现
        memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204d4e:	463d                	li	a2,15
ffffffffc0204d50:	4581                	li	a1,0
ffffffffc0204d52:	0b440513          	addi	a0,s0,180
ffffffffc0204d56:	482010ef          	jal	ra,ffffffffc02061d8 <memset>


        // 初始化等待状态为 0
        proc->wait_state = 0;
ffffffffc0204d5a:	0e042623          	sw	zero,236(s0)
        // 初始化子进程指针、兄弟进程指针、前一个进程指针均为 NULL
        proc->cptr = proc->yptr = proc->optr = NULL;
ffffffffc0204d5e:	10043023          	sd	zero,256(s0)
ffffffffc0204d62:	0e043c23          	sd	zero,248(s0)
ffffffffc0204d66:	0e043823          	sd	zero,240(s0)
    }
    return proc;
}
ffffffffc0204d6a:	8522                	mv	a0,s0
ffffffffc0204d6c:	60a2                	ld	ra,8(sp)
ffffffffc0204d6e:	6402                	ld	s0,0(sp)
ffffffffc0204d70:	0141                	addi	sp,sp,16
ffffffffc0204d72:	8082                	ret

ffffffffc0204d74 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204d74:	000a7797          	auipc	a5,0xa7
ffffffffc0204d78:	67478793          	addi	a5,a5,1652 # ffffffffc02ac3e8 <current>
ffffffffc0204d7c:	639c                	ld	a5,0(a5)
ffffffffc0204d7e:	73c8                	ld	a0,160(a5)
ffffffffc0204d80:	82afc06f          	j	ffffffffc0200daa <forkrets>

ffffffffc0204d84 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d84:	000a7797          	auipc	a5,0xa7
ffffffffc0204d88:	66478793          	addi	a5,a5,1636 # ffffffffc02ac3e8 <current>
ffffffffc0204d8c:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204d8e:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d90:	00004617          	auipc	a2,0x4
ffffffffc0204d94:	a5060613          	addi	a2,a2,-1456 # ffffffffc02087e0 <default_pmm_manager+0xa70>
ffffffffc0204d98:	43cc                	lw	a1,4(a5)
ffffffffc0204d9a:	00004517          	auipc	a0,0x4
ffffffffc0204d9e:	a5650513          	addi	a0,a0,-1450 # ffffffffc02087f0 <default_pmm_manager+0xa80>
user_main(void *arg) {
ffffffffc0204da2:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204da4:	b2cfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0204da8:	00004797          	auipc	a5,0x4
ffffffffc0204dac:	a3878793          	addi	a5,a5,-1480 # ffffffffc02087e0 <default_pmm_manager+0xa70>
ffffffffc0204db0:	3fe05717          	auipc	a4,0x3fe05
ffffffffc0204db4:	52070713          	addi	a4,a4,1312 # a2d0 <_binary_obj___user_forktest_out_size>
ffffffffc0204db8:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204dba:	853e                	mv	a0,a5
ffffffffc0204dbc:	00088717          	auipc	a4,0x88
ffffffffc0204dc0:	75470713          	addi	a4,a4,1876 # ffffffffc028d510 <_binary_obj___user_forktest_out_start>
ffffffffc0204dc4:	f03a                	sd	a4,32(sp)
ffffffffc0204dc6:	f43e                	sd	a5,40(sp)
ffffffffc0204dc8:	e802                	sd	zero,16(sp)
ffffffffc0204dca:	370010ef          	jal	ra,ffffffffc020613a <strlen>
ffffffffc0204dce:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204dd0:	4511                	li	a0,4
ffffffffc0204dd2:	55a2                	lw	a1,40(sp)
ffffffffc0204dd4:	4662                	lw	a2,24(sp)
ffffffffc0204dd6:	5682                	lw	a3,32(sp)
ffffffffc0204dd8:	4722                	lw	a4,8(sp)
ffffffffc0204dda:	48a9                	li	a7,10
ffffffffc0204ddc:	9002                	ebreak
ffffffffc0204dde:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204de0:	65c2                	ld	a1,16(sp)
ffffffffc0204de2:	00004517          	auipc	a0,0x4
ffffffffc0204de6:	a3650513          	addi	a0,a0,-1482 # ffffffffc0208818 <default_pmm_manager+0xaa8>
ffffffffc0204dea:	ae6fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204dee:	00004617          	auipc	a2,0x4
ffffffffc0204df2:	a3a60613          	addi	a2,a2,-1478 # ffffffffc0208828 <default_pmm_manager+0xab8>
ffffffffc0204df6:	3a900593          	li	a1,937
ffffffffc0204dfa:	00004517          	auipc	a0,0x4
ffffffffc0204dfe:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc0204e02:	c14fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204e06 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204e06:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204e08:	1141                	addi	sp,sp,-16
ffffffffc0204e0a:	e406                	sd	ra,8(sp)
ffffffffc0204e0c:	c02007b7          	lui	a5,0xc0200
ffffffffc0204e10:	04f6e263          	bltu	a3,a5,ffffffffc0204e54 <put_pgdir+0x4e>
ffffffffc0204e14:	000a7797          	auipc	a5,0xa7
ffffffffc0204e18:	6fc78793          	addi	a5,a5,1788 # ffffffffc02ac510 <va_pa_offset>
ffffffffc0204e1c:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204e1e:	000a7797          	auipc	a5,0xa7
ffffffffc0204e22:	5c278793          	addi	a5,a5,1474 # ffffffffc02ac3e0 <npage>
ffffffffc0204e26:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204e28:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204e2a:	82b1                	srli	a3,a3,0xc
ffffffffc0204e2c:	04f6f063          	bleu	a5,a3,ffffffffc0204e6c <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204e30:	00004797          	auipc	a5,0x4
ffffffffc0204e34:	ee078793          	addi	a5,a5,-288 # ffffffffc0208d10 <nbase>
ffffffffc0204e38:	639c                	ld	a5,0(a5)
ffffffffc0204e3a:	000a7717          	auipc	a4,0xa7
ffffffffc0204e3e:	6e670713          	addi	a4,a4,1766 # ffffffffc02ac520 <pages>
ffffffffc0204e42:	6308                	ld	a0,0(a4)
}
ffffffffc0204e44:	60a2                	ld	ra,8(sp)
ffffffffc0204e46:	8e9d                	sub	a3,a3,a5
ffffffffc0204e48:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204e4a:	4585                	li	a1,1
ffffffffc0204e4c:	9536                	add	a0,a0,a3
}
ffffffffc0204e4e:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204e50:	83ffe06f          	j	ffffffffc020368e <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204e54:	00003617          	auipc	a2,0x3
ffffffffc0204e58:	96460613          	addi	a2,a2,-1692 # ffffffffc02077b8 <commands+0x1030>
ffffffffc0204e5c:	06e00593          	li	a1,110
ffffffffc0204e60:	00002517          	auipc	a0,0x2
ffffffffc0204e64:	4e050513          	addi	a0,a0,1248 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0204e68:	baefb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e6c:	00002617          	auipc	a2,0x2
ffffffffc0204e70:	4b460613          	addi	a2,a2,1204 # ffffffffc0207320 <commands+0xb98>
ffffffffc0204e74:	06200593          	li	a1,98
ffffffffc0204e78:	00002517          	auipc	a0,0x2
ffffffffc0204e7c:	4c850513          	addi	a0,a0,1224 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0204e80:	b96fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204e84 <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204e84:	1101                	addi	sp,sp,-32
ffffffffc0204e86:	e426                	sd	s1,8(sp)
ffffffffc0204e88:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0204e8a:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204e8c:	ec06                	sd	ra,24(sp)
ffffffffc0204e8e:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0204e90:	f76fe0ef          	jal	ra,ffffffffc0203606 <alloc_pages>
ffffffffc0204e94:	c125                	beqz	a0,ffffffffc0204ef4 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204e96:	000a7797          	auipc	a5,0xa7
ffffffffc0204e9a:	68a78793          	addi	a5,a5,1674 # ffffffffc02ac520 <pages>
ffffffffc0204e9e:	6394                	ld	a3,0(a5)
ffffffffc0204ea0:	00004797          	auipc	a5,0x4
ffffffffc0204ea4:	e7078793          	addi	a5,a5,-400 # ffffffffc0208d10 <nbase>
ffffffffc0204ea8:	6380                	ld	s0,0(a5)
ffffffffc0204eaa:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204eae:	000a7717          	auipc	a4,0xa7
ffffffffc0204eb2:	53270713          	addi	a4,a4,1330 # ffffffffc02ac3e0 <npage>
    return page - pages + nbase;
ffffffffc0204eb6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204eb8:	57fd                	li	a5,-1
ffffffffc0204eba:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204ebc:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204ebe:	83b1                	srli	a5,a5,0xc
ffffffffc0204ec0:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ec2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ec4:	02e7fa63          	bleu	a4,a5,ffffffffc0204ef8 <setup_pgdir+0x74>
ffffffffc0204ec8:	000a7797          	auipc	a5,0xa7
ffffffffc0204ecc:	64878793          	addi	a5,a5,1608 # ffffffffc02ac510 <va_pa_offset>
ffffffffc0204ed0:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204ed2:	000a7797          	auipc	a5,0xa7
ffffffffc0204ed6:	50678793          	addi	a5,a5,1286 # ffffffffc02ac3d8 <boot_pgdir>
ffffffffc0204eda:	638c                	ld	a1,0(a5)
ffffffffc0204edc:	9436                	add	s0,s0,a3
ffffffffc0204ede:	6605                	lui	a2,0x1
ffffffffc0204ee0:	8522                	mv	a0,s0
ffffffffc0204ee2:	308010ef          	jal	ra,ffffffffc02061ea <memcpy>
    return 0;
ffffffffc0204ee6:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204ee8:	ec80                	sd	s0,24(s1)
}
ffffffffc0204eea:	60e2                	ld	ra,24(sp)
ffffffffc0204eec:	6442                	ld	s0,16(sp)
ffffffffc0204eee:	64a2                	ld	s1,8(sp)
ffffffffc0204ef0:	6105                	addi	sp,sp,32
ffffffffc0204ef2:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204ef4:	5571                	li	a0,-4
ffffffffc0204ef6:	bfd5                	j	ffffffffc0204eea <setup_pgdir+0x66>
ffffffffc0204ef8:	00002617          	auipc	a2,0x2
ffffffffc0204efc:	45860613          	addi	a2,a2,1112 # ffffffffc0207350 <commands+0xbc8>
ffffffffc0204f00:	06900593          	li	a1,105
ffffffffc0204f04:	00002517          	auipc	a0,0x2
ffffffffc0204f08:	43c50513          	addi	a0,a0,1084 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0204f0c:	b0afb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204f10 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204f10:	1101                	addi	sp,sp,-32
ffffffffc0204f12:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f14:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204f18:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f1a:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204f1c:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f1e:	8522                	mv	a0,s0
ffffffffc0204f20:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204f22:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f24:	2b4010ef          	jal	ra,ffffffffc02061d8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f28:	8522                	mv	a0,s0
}
ffffffffc0204f2a:	6442                	ld	s0,16(sp)
ffffffffc0204f2c:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f2e:	85a6                	mv	a1,s1
}
ffffffffc0204f30:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f32:	463d                	li	a2,15
}
ffffffffc0204f34:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f36:	2b40106f          	j	ffffffffc02061ea <memcpy>

ffffffffc0204f3a <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204f3a:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc0204f3c:	000a7797          	auipc	a5,0xa7
ffffffffc0204f40:	4ac78793          	addi	a5,a5,1196 # ffffffffc02ac3e8 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204f44:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204f46:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0204f48:	ec06                	sd	ra,24(sp)
ffffffffc0204f4a:	e822                	sd	s0,16(sp)
ffffffffc0204f4c:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204f4e:	02a48b63          	beq	s1,a0,ffffffffc0204f84 <proc_run+0x4a>
ffffffffc0204f52:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f54:	100027f3          	csrr	a5,sstatus
ffffffffc0204f58:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f5a:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f5c:	e3a9                	bnez	a5,ffffffffc0204f9e <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204f5e:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc0204f60:	000a7717          	auipc	a4,0xa7
ffffffffc0204f64:	48873423          	sd	s0,1160(a4) # ffffffffc02ac3e8 <current>
ffffffffc0204f68:	577d                	li	a4,-1
ffffffffc0204f6a:	177e                	slli	a4,a4,0x3f
ffffffffc0204f6c:	83b1                	srli	a5,a5,0xc
ffffffffc0204f6e:	8fd9                	or	a5,a5,a4
ffffffffc0204f70:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204f74:	03040593          	addi	a1,s0,48
ffffffffc0204f78:	03048513          	addi	a0,s1,48
ffffffffc0204f7c:	d1bff0ef          	jal	ra,ffffffffc0204c96 <switch_to>
    if (flag) {
ffffffffc0204f80:	00091863          	bnez	s2,ffffffffc0204f90 <proc_run+0x56>
}
ffffffffc0204f84:	60e2                	ld	ra,24(sp)
ffffffffc0204f86:	6442                	ld	s0,16(sp)
ffffffffc0204f88:	64a2                	ld	s1,8(sp)
ffffffffc0204f8a:	6902                	ld	s2,0(sp)
ffffffffc0204f8c:	6105                	addi	sp,sp,32
ffffffffc0204f8e:	8082                	ret
ffffffffc0204f90:	6442                	ld	s0,16(sp)
ffffffffc0204f92:	60e2                	ld	ra,24(sp)
ffffffffc0204f94:	64a2                	ld	s1,8(sp)
ffffffffc0204f96:	6902                	ld	s2,0(sp)
ffffffffc0204f98:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204f9a:	ebcfb06f          	j	ffffffffc0200656 <intr_enable>
        intr_disable();
ffffffffc0204f9e:	ebefb0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc0204fa2:	4905                	li	s2,1
ffffffffc0204fa4:	bf6d                	j	ffffffffc0204f5e <proc_run+0x24>

ffffffffc0204fa6 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204fa6:	0005071b          	sext.w	a4,a0
ffffffffc0204faa:	6789                	lui	a5,0x2
ffffffffc0204fac:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204fb0:	17f9                	addi	a5,a5,-2
ffffffffc0204fb2:	04d7e063          	bltu	a5,a3,ffffffffc0204ff2 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204fb6:	1141                	addi	sp,sp,-16
ffffffffc0204fb8:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204fba:	45a9                	li	a1,10
ffffffffc0204fbc:	842a                	mv	s0,a0
ffffffffc0204fbe:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204fc0:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204fc2:	638010ef          	jal	ra,ffffffffc02065fa <hash32>
ffffffffc0204fc6:	02051693          	slli	a3,a0,0x20
ffffffffc0204fca:	82f1                	srli	a3,a3,0x1c
ffffffffc0204fcc:	000a3517          	auipc	a0,0xa3
ffffffffc0204fd0:	3dc50513          	addi	a0,a0,988 # ffffffffc02a83a8 <hash_list>
ffffffffc0204fd4:	96aa                	add	a3,a3,a0
ffffffffc0204fd6:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204fd8:	a029                	j	ffffffffc0204fe2 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204fda:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7644>
ffffffffc0204fde:	00870c63          	beq	a4,s0,ffffffffc0204ff6 <find_proc+0x50>
    return listelm->next;
ffffffffc0204fe2:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204fe4:	fef69be3          	bne	a3,a5,ffffffffc0204fda <find_proc+0x34>
}
ffffffffc0204fe8:	60a2                	ld	ra,8(sp)
ffffffffc0204fea:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204fec:	4501                	li	a0,0
}
ffffffffc0204fee:	0141                	addi	sp,sp,16
ffffffffc0204ff0:	8082                	ret
    return NULL;
ffffffffc0204ff2:	4501                	li	a0,0
}
ffffffffc0204ff4:	8082                	ret
ffffffffc0204ff6:	60a2                	ld	ra,8(sp)
ffffffffc0204ff8:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204ffa:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204ffe:	0141                	addi	sp,sp,16
ffffffffc0205000:	8082                	ret

ffffffffc0205002 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0205002:	715d                	addi	sp,sp,-80
ffffffffc0205004:	f84a                	sd	s2,48(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0205006:	000a7917          	auipc	s2,0xa7
ffffffffc020500a:	3fa90913          	addi	s2,s2,1018 # ffffffffc02ac400 <nr_process>
ffffffffc020500e:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0205012:	e486                	sd	ra,72(sp)
ffffffffc0205014:	e0a2                	sd	s0,64(sp)
ffffffffc0205016:	fc26                	sd	s1,56(sp)
ffffffffc0205018:	f44e                	sd	s3,40(sp)
ffffffffc020501a:	f052                	sd	s4,32(sp)
ffffffffc020501c:	ec56                	sd	s5,24(sp)
ffffffffc020501e:	e85a                	sd	s6,16(sp)
ffffffffc0205020:	e45e                	sd	s7,8(sp)
ffffffffc0205022:	e062                	sd	s8,0(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0205024:	6785                	lui	a5,0x1
ffffffffc0205026:	32f75a63          	ble	a5,a4,ffffffffc020535a <do_fork+0x358>
ffffffffc020502a:	8aaa                	mv	s5,a0
ffffffffc020502c:	89ae                	mv	s3,a1
ffffffffc020502e:	84b2                	mv	s1,a2
    if ((proc = alloc_proc()) == NULL) {
ffffffffc0205030:	cd1ff0ef          	jal	ra,ffffffffc0204d00 <alloc_proc>
ffffffffc0205034:	842a                	mv	s0,a0
ffffffffc0205036:	30050163          	beqz	a0,ffffffffc0205338 <do_fork+0x336>
    proc->parent = current;
ffffffffc020503a:	000a7a17          	auipc	s4,0xa7
ffffffffc020503e:	3aea0a13          	addi	s4,s4,942 # ffffffffc02ac3e8 <current>
ffffffffc0205042:	000a3783          	ld	a5,0(s4)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0205046:	4509                	li	a0,2
    proc->parent = current;
ffffffffc0205048:	f01c                	sd	a5,32(s0)
    current->wait_state = 0;
ffffffffc020504a:	0e07a623          	sw	zero,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8484>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020504e:	db8fe0ef          	jal	ra,ffffffffc0203606 <alloc_pages>
    if (page != NULL) {
ffffffffc0205052:	2a050063          	beqz	a0,ffffffffc02052f2 <do_fork+0x2f0>
    return page - pages + nbase;
ffffffffc0205056:	000a7797          	auipc	a5,0xa7
ffffffffc020505a:	4ca78793          	addi	a5,a5,1226 # ffffffffc02ac520 <pages>
ffffffffc020505e:	6394                	ld	a3,0(a5)
ffffffffc0205060:	00004797          	auipc	a5,0x4
ffffffffc0205064:	cb078793          	addi	a5,a5,-848 # ffffffffc0208d10 <nbase>
    return KADDR(page2pa(page));
ffffffffc0205068:	000a7717          	auipc	a4,0xa7
ffffffffc020506c:	37870713          	addi	a4,a4,888 # ffffffffc02ac3e0 <npage>
    return page - pages + nbase;
ffffffffc0205070:	40d506b3          	sub	a3,a0,a3
ffffffffc0205074:	6388                	ld	a0,0(a5)
ffffffffc0205076:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205078:	57fd                	li	a5,-1
ffffffffc020507a:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc020507c:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc020507e:	83b1                	srli	a5,a5,0xc
ffffffffc0205080:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205082:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205084:	2ce7fd63          	bleu	a4,a5,ffffffffc020535e <do_fork+0x35c>
ffffffffc0205088:	000a7b17          	auipc	s6,0xa7
ffffffffc020508c:	488b0b13          	addi	s6,s6,1160 # ffffffffc02ac510 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0205090:	000a3703          	ld	a4,0(s4)
ffffffffc0205094:	000b3783          	ld	a5,0(s6)
ffffffffc0205098:	02873a03          	ld	s4,40(a4)
ffffffffc020509c:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc020509e:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc02050a0:	020a0863          	beqz	s4,ffffffffc02050d0 <do_fork+0xce>
    if (clone_flags & CLONE_VM) {
ffffffffc02050a4:	100afa93          	andi	s5,s5,256
ffffffffc02050a8:	1e0a8b63          	beqz	s5,ffffffffc020529e <do_fork+0x29c>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc02050ac:	030a2703          	lw	a4,48(s4)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02050b0:	018a3783          	ld	a5,24(s4)
ffffffffc02050b4:	c02006b7          	lui	a3,0xc0200
ffffffffc02050b8:	2705                	addiw	a4,a4,1
ffffffffc02050ba:	02ea2823          	sw	a4,48(s4)
    proc->mm = mm;
ffffffffc02050be:	03443423          	sd	s4,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02050c2:	2ad7ea63          	bltu	a5,a3,ffffffffc0205376 <do_fork+0x374>
ffffffffc02050c6:	000b3703          	ld	a4,0(s6)
ffffffffc02050ca:	6814                	ld	a3,16(s0)
ffffffffc02050cc:	8f99                	sub	a5,a5,a4
ffffffffc02050ce:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02050d0:	6789                	lui	a5,0x2
ffffffffc02050d2:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7690>
ffffffffc02050d6:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc02050d8:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02050da:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc02050dc:	87b6                	mv	a5,a3
ffffffffc02050de:	12048893          	addi	a7,s1,288
ffffffffc02050e2:	00063803          	ld	a6,0(a2)
ffffffffc02050e6:	6608                	ld	a0,8(a2)
ffffffffc02050e8:	6a0c                	ld	a1,16(a2)
ffffffffc02050ea:	6e18                	ld	a4,24(a2)
ffffffffc02050ec:	0107b023          	sd	a6,0(a5)
ffffffffc02050f0:	e788                	sd	a0,8(a5)
ffffffffc02050f2:	eb8c                	sd	a1,16(a5)
ffffffffc02050f4:	ef98                	sd	a4,24(a5)
ffffffffc02050f6:	02060613          	addi	a2,a2,32
ffffffffc02050fa:	02078793          	addi	a5,a5,32
ffffffffc02050fe:	ff1612e3          	bne	a2,a7,ffffffffc02050e2 <do_fork+0xe0>
    proc->tf->gpr.a0 = 0;
ffffffffc0205102:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205106:	14098563          	beqz	s3,ffffffffc0205250 <do_fork+0x24e>
ffffffffc020510a:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020510e:	00000797          	auipc	a5,0x0
ffffffffc0205112:	c6678793          	addi	a5,a5,-922 # ffffffffc0204d74 <forkret>
ffffffffc0205116:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205118:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020511a:	100027f3          	csrr	a5,sstatus
ffffffffc020511e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205120:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205122:	14079663          	bnez	a5,ffffffffc020526e <do_fork+0x26c>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205126:	0009c797          	auipc	a5,0x9c
ffffffffc020512a:	e7a78793          	addi	a5,a5,-390 # ffffffffc02a0fa0 <last_pid.1691>
ffffffffc020512e:	439c                	lw	a5,0(a5)
ffffffffc0205130:	6709                	lui	a4,0x2
ffffffffc0205132:	0017851b          	addiw	a0,a5,1
ffffffffc0205136:	0009c697          	auipc	a3,0x9c
ffffffffc020513a:	e6a6a523          	sw	a0,-406(a3) # ffffffffc02a0fa0 <last_pid.1691>
ffffffffc020513e:	14e55963          	ble	a4,a0,ffffffffc0205290 <do_fork+0x28e>
    if (last_pid >= next_safe) {
ffffffffc0205142:	0009c797          	auipc	a5,0x9c
ffffffffc0205146:	e6278793          	addi	a5,a5,-414 # ffffffffc02a0fa4 <next_safe.1690>
ffffffffc020514a:	439c                	lw	a5,0(a5)
ffffffffc020514c:	000a7497          	auipc	s1,0xa7
ffffffffc0205150:	3dc48493          	addi	s1,s1,988 # ffffffffc02ac528 <proc_list>
ffffffffc0205154:	06f54063          	blt	a0,a5,ffffffffc02051b4 <do_fork+0x1b2>
        next_safe = MAX_PID;
ffffffffc0205158:	6789                	lui	a5,0x2
ffffffffc020515a:	0009c717          	auipc	a4,0x9c
ffffffffc020515e:	e4f72523          	sw	a5,-438(a4) # ffffffffc02a0fa4 <next_safe.1690>
ffffffffc0205162:	4581                	li	a1,0
ffffffffc0205164:	87aa                	mv	a5,a0
ffffffffc0205166:	000a7497          	auipc	s1,0xa7
ffffffffc020516a:	3c248493          	addi	s1,s1,962 # ffffffffc02ac528 <proc_list>
    repeat:
ffffffffc020516e:	6889                	lui	a7,0x2
ffffffffc0205170:	882e                	mv	a6,a1
ffffffffc0205172:	6609                	lui	a2,0x2
        le = list;
ffffffffc0205174:	000a7697          	auipc	a3,0xa7
ffffffffc0205178:	3b468693          	addi	a3,a3,948 # ffffffffc02ac528 <proc_list>
ffffffffc020517c:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc020517e:	00968f63          	beq	a3,s1,ffffffffc020519c <do_fork+0x19a>
            if (proc->pid == last_pid) {
ffffffffc0205182:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0205186:	0cf70063          	beq	a4,a5,ffffffffc0205246 <do_fork+0x244>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc020518a:	fee7d9e3          	ble	a4,a5,ffffffffc020517c <do_fork+0x17a>
ffffffffc020518e:	fec757e3          	ble	a2,a4,ffffffffc020517c <do_fork+0x17a>
ffffffffc0205192:	6694                	ld	a3,8(a3)
ffffffffc0205194:	863a                	mv	a2,a4
ffffffffc0205196:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0205198:	fe9695e3          	bne	a3,s1,ffffffffc0205182 <do_fork+0x180>
ffffffffc020519c:	c591                	beqz	a1,ffffffffc02051a8 <do_fork+0x1a6>
ffffffffc020519e:	0009c717          	auipc	a4,0x9c
ffffffffc02051a2:	e0f72123          	sw	a5,-510(a4) # ffffffffc02a0fa0 <last_pid.1691>
ffffffffc02051a6:	853e                	mv	a0,a5
ffffffffc02051a8:	00080663          	beqz	a6,ffffffffc02051b4 <do_fork+0x1b2>
ffffffffc02051ac:	0009c797          	auipc	a5,0x9c
ffffffffc02051b0:	dec7ac23          	sw	a2,-520(a5) # ffffffffc02a0fa4 <next_safe.1690>
        proc->pid = get_pid();
ffffffffc02051b4:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02051b6:	45a9                	li	a1,10
ffffffffc02051b8:	2501                	sext.w	a0,a0
ffffffffc02051ba:	440010ef          	jal	ra,ffffffffc02065fa <hash32>
ffffffffc02051be:	1502                	slli	a0,a0,0x20
ffffffffc02051c0:	000a3797          	auipc	a5,0xa3
ffffffffc02051c4:	1e878793          	addi	a5,a5,488 # ffffffffc02a83a8 <hash_list>
ffffffffc02051c8:	8171                	srli	a0,a0,0x1c
ffffffffc02051ca:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02051cc:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051ce:	7010                	ld	a2,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02051d0:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc02051d4:	e19c                	sd	a5,0(a1)
ffffffffc02051d6:	0084b803          	ld	a6,8(s1)
ffffffffc02051da:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051dc:	7a74                	ld	a3,240(a2)
        list_add(&proc_list, &(proc->list_link));
ffffffffc02051de:	0c840793          	addi	a5,s0,200
    elm->prev = prev;
ffffffffc02051e2:	ec68                	sd	a0,216(s0)
    elm->next = next;
ffffffffc02051e4:	f06c                	sd	a1,224(s0)
    prev->next = next->prev = elm;
ffffffffc02051e6:	00f83023          	sd	a5,0(a6) # fffffffffff80000 <end+0x3fcd3ac8>
ffffffffc02051ea:	000a7517          	auipc	a0,0xa7
ffffffffc02051ee:	34f53323          	sd	a5,838(a0) # ffffffffc02ac530 <proc_list+0x8>
    elm->next = next;
ffffffffc02051f2:	e87c                	sd	a5,208(s0)
    elm->prev = prev;
ffffffffc02051f4:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc02051f6:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051fa:	10d43023          	sd	a3,256(s0)
        nr_process ++;
ffffffffc02051fe:	00092703          	lw	a4,0(s2)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205202:	c291                	beqz	a3,ffffffffc0205206 <do_fork+0x204>
        proc->optr->yptr = proc;
ffffffffc0205204:	fee0                	sd	s0,248(a3)
    nr_process ++;
ffffffffc0205206:	2709                	addiw	a4,a4,2
    proc->parent->cptr = proc;
ffffffffc0205208:	fa60                	sd	s0,240(a2)
    nr_process ++;
ffffffffc020520a:	000a7797          	auipc	a5,0xa7
ffffffffc020520e:	1ee7ab23          	sw	a4,502(a5) # ffffffffc02ac400 <nr_process>
    if (flag) {
ffffffffc0205212:	12099863          	bnez	s3,ffffffffc0205342 <do_fork+0x340>
    wakeup_proc(proc);// PROC_RUNNABLE
ffffffffc0205216:	8522                	mv	a0,s0
ffffffffc0205218:	531000ef          	jal	ra,ffffffffc0205f48 <wakeup_proc>
    cprintf("THIS MY: do_fork proc create over thread: %d! isNULL:%d \n", proc->pid, proc == NULL);
ffffffffc020521c:	404c                	lw	a1,4(s0)
ffffffffc020521e:	4601                	li	a2,0
ffffffffc0205220:	00003517          	auipc	a0,0x3
ffffffffc0205224:	3a050513          	addi	a0,a0,928 # ffffffffc02085c0 <default_pmm_manager+0x850>
ffffffffc0205228:	ea9fa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = proc->pid;
ffffffffc020522c:	4048                	lw	a0,4(s0)
}
ffffffffc020522e:	60a6                	ld	ra,72(sp)
ffffffffc0205230:	6406                	ld	s0,64(sp)
ffffffffc0205232:	74e2                	ld	s1,56(sp)
ffffffffc0205234:	7942                	ld	s2,48(sp)
ffffffffc0205236:	79a2                	ld	s3,40(sp)
ffffffffc0205238:	7a02                	ld	s4,32(sp)
ffffffffc020523a:	6ae2                	ld	s5,24(sp)
ffffffffc020523c:	6b42                	ld	s6,16(sp)
ffffffffc020523e:	6ba2                	ld	s7,8(sp)
ffffffffc0205240:	6c02                	ld	s8,0(sp)
ffffffffc0205242:	6161                	addi	sp,sp,80
ffffffffc0205244:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc0205246:	2785                	addiw	a5,a5,1
ffffffffc0205248:	10c7d063          	ble	a2,a5,ffffffffc0205348 <do_fork+0x346>
ffffffffc020524c:	4585                	li	a1,1
ffffffffc020524e:	b73d                	j	ffffffffc020517c <do_fork+0x17a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205250:	89b6                	mv	s3,a3
ffffffffc0205252:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205256:	00000797          	auipc	a5,0x0
ffffffffc020525a:	b1e78793          	addi	a5,a5,-1250 # ffffffffc0204d74 <forkret>
ffffffffc020525e:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205260:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205262:	100027f3          	csrr	a5,sstatus
ffffffffc0205266:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205268:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020526a:	ea078ee3          	beqz	a5,ffffffffc0205126 <do_fork+0x124>
        intr_disable();
ffffffffc020526e:	beefb0ef          	jal	ra,ffffffffc020065c <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205272:	0009c797          	auipc	a5,0x9c
ffffffffc0205276:	d2e78793          	addi	a5,a5,-722 # ffffffffc02a0fa0 <last_pid.1691>
ffffffffc020527a:	439c                	lw	a5,0(a5)
ffffffffc020527c:	6709                	lui	a4,0x2
        return 1;
ffffffffc020527e:	4985                	li	s3,1
ffffffffc0205280:	0017851b          	addiw	a0,a5,1
ffffffffc0205284:	0009c697          	auipc	a3,0x9c
ffffffffc0205288:	d0a6ae23          	sw	a0,-740(a3) # ffffffffc02a0fa0 <last_pid.1691>
ffffffffc020528c:	eae54be3          	blt	a0,a4,ffffffffc0205142 <do_fork+0x140>
        last_pid = 1;
ffffffffc0205290:	4785                	li	a5,1
ffffffffc0205292:	0009c717          	auipc	a4,0x9c
ffffffffc0205296:	d0f72723          	sw	a5,-754(a4) # ffffffffc02a0fa0 <last_pid.1691>
ffffffffc020529a:	4505                	li	a0,1
ffffffffc020529c:	bd75                	j	ffffffffc0205158 <do_fork+0x156>
    if ((mm = mm_create()) == NULL) {
ffffffffc020529e:	bddfb0ef          	jal	ra,ffffffffc0200e7a <mm_create>
ffffffffc02052a2:	8c2a                	mv	s8,a0
ffffffffc02052a4:	c539                	beqz	a0,ffffffffc02052f2 <do_fork+0x2f0>
    if (setup_pgdir(mm) != 0) {
ffffffffc02052a6:	bdfff0ef          	jal	ra,ffffffffc0204e84 <setup_pgdir>
ffffffffc02052aa:	e545                	bnez	a0,ffffffffc0205352 <do_fork+0x350>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc02052ac:	038a0a93          	addi	s5,s4,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02052b0:	4785                	li	a5,1
ffffffffc02052b2:	40fab7af          	amoor.d	a5,a5,(s5)
ffffffffc02052b6:	8b85                	andi	a5,a5,1
ffffffffc02052b8:	4b85                	li	s7,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc02052ba:	c799                	beqz	a5,ffffffffc02052c8 <do_fork+0x2c6>
        schedule();
ffffffffc02052bc:	509000ef          	jal	ra,ffffffffc0205fc4 <schedule>
ffffffffc02052c0:	417ab7af          	amoor.d	a5,s7,(s5)
ffffffffc02052c4:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc02052c6:	fbfd                	bnez	a5,ffffffffc02052bc <do_fork+0x2ba>
        ret = dup_mmap(mm, oldmm);
ffffffffc02052c8:	85d2                	mv	a1,s4
ffffffffc02052ca:	8562                	mv	a0,s8
ffffffffc02052cc:	e39fb0ef          	jal	ra,ffffffffc0201104 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02052d0:	57f9                	li	a5,-2
ffffffffc02052d2:	60fab7af          	amoand.d	a5,a5,(s5)
ffffffffc02052d6:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02052d8:	cfc5                	beqz	a5,ffffffffc0205390 <do_fork+0x38e>
    if (ret != 0) {
ffffffffc02052da:	8a62                	mv	s4,s8
ffffffffc02052dc:	dc0508e3          	beqz	a0,ffffffffc02050ac <do_fork+0xaa>
    exit_mmap(mm);
ffffffffc02052e0:	8562                	mv	a0,s8
ffffffffc02052e2:	ebffb0ef          	jal	ra,ffffffffc02011a0 <exit_mmap>
    put_pgdir(mm);
ffffffffc02052e6:	8562                	mv	a0,s8
ffffffffc02052e8:	b1fff0ef          	jal	ra,ffffffffc0204e06 <put_pgdir>
    mm_destroy(mm);
ffffffffc02052ec:	8562                	mv	a0,s8
ffffffffc02052ee:	d13fb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02052f2:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02052f4:	c02007b7          	lui	a5,0xc0200
ffffffffc02052f8:	0cf6e463          	bltu	a3,a5,ffffffffc02053c0 <do_fork+0x3be>
ffffffffc02052fc:	000a7797          	auipc	a5,0xa7
ffffffffc0205300:	21478793          	addi	a5,a5,532 # ffffffffc02ac510 <va_pa_offset>
ffffffffc0205304:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0205306:	000a7797          	auipc	a5,0xa7
ffffffffc020530a:	0da78793          	addi	a5,a5,218 # ffffffffc02ac3e0 <npage>
ffffffffc020530e:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0205310:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205312:	82b1                	srli	a3,a3,0xc
ffffffffc0205314:	08f6fa63          	bleu	a5,a3,ffffffffc02053a8 <do_fork+0x3a6>
    return &pages[PPN(pa) - nbase];
ffffffffc0205318:	00004797          	auipc	a5,0x4
ffffffffc020531c:	9f878793          	addi	a5,a5,-1544 # ffffffffc0208d10 <nbase>
ffffffffc0205320:	639c                	ld	a5,0(a5)
ffffffffc0205322:	000a7717          	auipc	a4,0xa7
ffffffffc0205326:	1fe70713          	addi	a4,a4,510 # ffffffffc02ac520 <pages>
ffffffffc020532a:	6308                	ld	a0,0(a4)
ffffffffc020532c:	8e9d                	sub	a3,a3,a5
ffffffffc020532e:	069a                	slli	a3,a3,0x6
ffffffffc0205330:	4589                	li	a1,2
ffffffffc0205332:	9536                	add	a0,a0,a3
ffffffffc0205334:	b5afe0ef          	jal	ra,ffffffffc020368e <free_pages>
    kfree(proc);
ffffffffc0205338:	8522                	mv	a0,s0
ffffffffc020533a:	a56fd0ef          	jal	ra,ffffffffc0202590 <kfree>
    ret = -E_NO_MEM;
ffffffffc020533e:	5571                	li	a0,-4
    return ret;
ffffffffc0205340:	b5fd                	j	ffffffffc020522e <do_fork+0x22c>
        intr_enable();
ffffffffc0205342:	b14fb0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0205346:	bdc1                	j	ffffffffc0205216 <do_fork+0x214>
                    if (last_pid >= MAX_PID) {
ffffffffc0205348:	0117c363          	blt	a5,a7,ffffffffc020534e <do_fork+0x34c>
                        last_pid = 1;
ffffffffc020534c:	4785                	li	a5,1
                    goto repeat;
ffffffffc020534e:	4585                	li	a1,1
ffffffffc0205350:	b505                	j	ffffffffc0205170 <do_fork+0x16e>
    mm_destroy(mm);
ffffffffc0205352:	8562                	mv	a0,s8
ffffffffc0205354:	cadfb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
ffffffffc0205358:	bf69                	j	ffffffffc02052f2 <do_fork+0x2f0>
    int ret = -E_NO_FREE_PROC;
ffffffffc020535a:	556d                	li	a0,-5
ffffffffc020535c:	bdc9                	j	ffffffffc020522e <do_fork+0x22c>
    return KADDR(page2pa(page));
ffffffffc020535e:	00002617          	auipc	a2,0x2
ffffffffc0205362:	ff260613          	addi	a2,a2,-14 # ffffffffc0207350 <commands+0xbc8>
ffffffffc0205366:	06900593          	li	a1,105
ffffffffc020536a:	00002517          	auipc	a0,0x2
ffffffffc020536e:	fd650513          	addi	a0,a0,-42 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0205372:	ea5fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205376:	86be                	mv	a3,a5
ffffffffc0205378:	00002617          	auipc	a2,0x2
ffffffffc020537c:	44060613          	addi	a2,a2,1088 # ffffffffc02077b8 <commands+0x1030>
ffffffffc0205380:	18c00593          	li	a1,396
ffffffffc0205384:	00003517          	auipc	a0,0x3
ffffffffc0205388:	4c450513          	addi	a0,a0,1220 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc020538c:	e8bfa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("Unlock failed.\n");
ffffffffc0205390:	00003617          	auipc	a2,0x3
ffffffffc0205394:	20860613          	addi	a2,a2,520 # ffffffffc0208598 <default_pmm_manager+0x828>
ffffffffc0205398:	03100593          	li	a1,49
ffffffffc020539c:	00003517          	auipc	a0,0x3
ffffffffc02053a0:	20c50513          	addi	a0,a0,524 # ffffffffc02085a8 <default_pmm_manager+0x838>
ffffffffc02053a4:	e73fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02053a8:	00002617          	auipc	a2,0x2
ffffffffc02053ac:	f7860613          	addi	a2,a2,-136 # ffffffffc0207320 <commands+0xb98>
ffffffffc02053b0:	06200593          	li	a1,98
ffffffffc02053b4:	00002517          	auipc	a0,0x2
ffffffffc02053b8:	f8c50513          	addi	a0,a0,-116 # ffffffffc0207340 <commands+0xbb8>
ffffffffc02053bc:	e5bfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02053c0:	00002617          	auipc	a2,0x2
ffffffffc02053c4:	3f860613          	addi	a2,a2,1016 # ffffffffc02077b8 <commands+0x1030>
ffffffffc02053c8:	06e00593          	li	a1,110
ffffffffc02053cc:	00002517          	auipc	a0,0x2
ffffffffc02053d0:	f7450513          	addi	a0,a0,-140 # ffffffffc0207340 <commands+0xbb8>
ffffffffc02053d4:	e43fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02053d8 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02053d8:	7129                	addi	sp,sp,-320
ffffffffc02053da:	fa22                	sd	s0,304(sp)
ffffffffc02053dc:	f626                	sd	s1,296(sp)
ffffffffc02053de:	f24a                	sd	s2,288(sp)
ffffffffc02053e0:	84ae                	mv	s1,a1
ffffffffc02053e2:	892a                	mv	s2,a0
ffffffffc02053e4:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053e6:	4581                	li	a1,0
ffffffffc02053e8:	12000613          	li	a2,288
ffffffffc02053ec:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02053ee:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053f0:	5e9000ef          	jal	ra,ffffffffc02061d8 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02053f4:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02053f6:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02053f8:	100027f3          	csrr	a5,sstatus
ffffffffc02053fc:	edd7f793          	andi	a5,a5,-291
ffffffffc0205400:	1207e793          	ori	a5,a5,288
ffffffffc0205404:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205406:	860a                	mv	a2,sp
ffffffffc0205408:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020540c:	00000797          	auipc	a5,0x0
ffffffffc0205410:	88278793          	addi	a5,a5,-1918 # ffffffffc0204c8e <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205414:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205416:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205418:	bebff0ef          	jal	ra,ffffffffc0205002 <do_fork>
}
ffffffffc020541c:	70f2                	ld	ra,312(sp)
ffffffffc020541e:	7452                	ld	s0,304(sp)
ffffffffc0205420:	74b2                	ld	s1,296(sp)
ffffffffc0205422:	7912                	ld	s2,288(sp)
ffffffffc0205424:	6131                	addi	sp,sp,320
ffffffffc0205426:	8082                	ret

ffffffffc0205428 <do_exit>:
do_exit(int error_code) {
ffffffffc0205428:	7179                	addi	sp,sp,-48
ffffffffc020542a:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc020542c:	000a7717          	auipc	a4,0xa7
ffffffffc0205430:	fc470713          	addi	a4,a4,-60 # ffffffffc02ac3f0 <idleproc>
ffffffffc0205434:	000a7917          	auipc	s2,0xa7
ffffffffc0205438:	fb490913          	addi	s2,s2,-76 # ffffffffc02ac3e8 <current>
ffffffffc020543c:	00093783          	ld	a5,0(s2)
ffffffffc0205440:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc0205442:	f406                	sd	ra,40(sp)
ffffffffc0205444:	f022                	sd	s0,32(sp)
ffffffffc0205446:	ec26                	sd	s1,24(sp)
ffffffffc0205448:	e44e                	sd	s3,8(sp)
ffffffffc020544a:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc020544c:	0ce78c63          	beq	a5,a4,ffffffffc0205524 <do_exit+0xfc>
    if (current == initproc) {
ffffffffc0205450:	000a7417          	auipc	s0,0xa7
ffffffffc0205454:	fa840413          	addi	s0,s0,-88 # ffffffffc02ac3f8 <initproc>
ffffffffc0205458:	6018                	ld	a4,0(s0)
ffffffffc020545a:	0ee78b63          	beq	a5,a4,ffffffffc0205550 <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc020545e:	7784                	ld	s1,40(a5)
ffffffffc0205460:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc0205462:	c48d                	beqz	s1,ffffffffc020548c <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc0205464:	000a7797          	auipc	a5,0xa7
ffffffffc0205468:	0b478793          	addi	a5,a5,180 # ffffffffc02ac518 <boot_cr3>
ffffffffc020546c:	639c                	ld	a5,0(a5)
ffffffffc020546e:	577d                	li	a4,-1
ffffffffc0205470:	177e                	slli	a4,a4,0x3f
ffffffffc0205472:	83b1                	srli	a5,a5,0xc
ffffffffc0205474:	8fd9                	or	a5,a5,a4
ffffffffc0205476:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc020547a:	589c                	lw	a5,48(s1)
ffffffffc020547c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205480:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205482:	cf4d                	beqz	a4,ffffffffc020553c <do_exit+0x114>
        current->mm = NULL;
ffffffffc0205484:	00093783          	ld	a5,0(s2)
ffffffffc0205488:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020548c:	00093783          	ld	a5,0(s2)
ffffffffc0205490:	470d                	li	a4,3
ffffffffc0205492:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205494:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205498:	100027f3          	csrr	a5,sstatus
ffffffffc020549c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020549e:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02054a0:	e7e1                	bnez	a5,ffffffffc0205568 <do_exit+0x140>
        proc = current->parent;
ffffffffc02054a2:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02054a6:	800007b7          	lui	a5,0x80000
ffffffffc02054aa:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02054ac:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02054ae:	0ec52703          	lw	a4,236(a0)
ffffffffc02054b2:	0af70f63          	beq	a4,a5,ffffffffc0205570 <do_exit+0x148>
ffffffffc02054b6:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054ba:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054be:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054c0:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc02054c2:	7afc                	ld	a5,240(a3)
ffffffffc02054c4:	cb95                	beqz	a5,ffffffffc02054f8 <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc02054c6:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5690>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02054ca:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc02054cc:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02054ce:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02054d0:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02054d4:	10e7b023          	sd	a4,256(a5)
ffffffffc02054d8:	c311                	beqz	a4,ffffffffc02054dc <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc02054da:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054dc:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02054de:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02054e0:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054e2:	fe9710e3          	bne	a4,s1,ffffffffc02054c2 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054e6:	0ec52783          	lw	a5,236(a0)
ffffffffc02054ea:	fd379ce3          	bne	a5,s3,ffffffffc02054c2 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02054ee:	25b000ef          	jal	ra,ffffffffc0205f48 <wakeup_proc>
ffffffffc02054f2:	00093683          	ld	a3,0(s2)
ffffffffc02054f6:	b7f1                	j	ffffffffc02054c2 <do_exit+0x9a>
    if (flag) {
ffffffffc02054f8:	020a1363          	bnez	s4,ffffffffc020551e <do_exit+0xf6>
    schedule();
ffffffffc02054fc:	2c9000ef          	jal	ra,ffffffffc0205fc4 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205500:	00093783          	ld	a5,0(s2)
ffffffffc0205504:	00003617          	auipc	a2,0x3
ffffffffc0205508:	07460613          	addi	a2,a2,116 # ffffffffc0208578 <default_pmm_manager+0x808>
ffffffffc020550c:	25b00593          	li	a1,603
ffffffffc0205510:	43d4                	lw	a3,4(a5)
ffffffffc0205512:	00003517          	auipc	a0,0x3
ffffffffc0205516:	33650513          	addi	a0,a0,822 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc020551a:	cfdfa0ef          	jal	ra,ffffffffc0200216 <__panic>
        intr_enable();
ffffffffc020551e:	938fb0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0205522:	bfe9                	j	ffffffffc02054fc <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc0205524:	00003617          	auipc	a2,0x3
ffffffffc0205528:	03460613          	addi	a2,a2,52 # ffffffffc0208558 <default_pmm_manager+0x7e8>
ffffffffc020552c:	22f00593          	li	a1,559
ffffffffc0205530:	00003517          	auipc	a0,0x3
ffffffffc0205534:	31850513          	addi	a0,a0,792 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc0205538:	cdffa0ef          	jal	ra,ffffffffc0200216 <__panic>
            exit_mmap(mm);
ffffffffc020553c:	8526                	mv	a0,s1
ffffffffc020553e:	c63fb0ef          	jal	ra,ffffffffc02011a0 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205542:	8526                	mv	a0,s1
ffffffffc0205544:	8c3ff0ef          	jal	ra,ffffffffc0204e06 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205548:	8526                	mv	a0,s1
ffffffffc020554a:	ab7fb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
ffffffffc020554e:	bf1d                	j	ffffffffc0205484 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc0205550:	00003617          	auipc	a2,0x3
ffffffffc0205554:	01860613          	addi	a2,a2,24 # ffffffffc0208568 <default_pmm_manager+0x7f8>
ffffffffc0205558:	23200593          	li	a1,562
ffffffffc020555c:	00003517          	auipc	a0,0x3
ffffffffc0205560:	2ec50513          	addi	a0,a0,748 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc0205564:	cb3fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        intr_disable();
ffffffffc0205568:	8f4fb0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc020556c:	4a05                	li	s4,1
ffffffffc020556e:	bf15                	j	ffffffffc02054a2 <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc0205570:	1d9000ef          	jal	ra,ffffffffc0205f48 <wakeup_proc>
ffffffffc0205574:	b789                	j	ffffffffc02054b6 <do_exit+0x8e>

ffffffffc0205576 <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc0205576:	7139                	addi	sp,sp,-64
ffffffffc0205578:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc020557a:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc020557e:	f426                	sd	s1,40(sp)
ffffffffc0205580:	f04a                	sd	s2,32(sp)
ffffffffc0205582:	ec4e                	sd	s3,24(sp)
ffffffffc0205584:	e456                	sd	s5,8(sp)
ffffffffc0205586:	e05a                	sd	s6,0(sp)
ffffffffc0205588:	fc06                	sd	ra,56(sp)
ffffffffc020558a:	f822                	sd	s0,48(sp)
ffffffffc020558c:	89aa                	mv	s3,a0
ffffffffc020558e:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc0205590:	000a7917          	auipc	s2,0xa7
ffffffffc0205594:	e5890913          	addi	s2,s2,-424 # ffffffffc02ac3e8 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205598:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc020559a:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc020559c:	2a05                	addiw	s4,s4,1
    if (pid != 0) {
ffffffffc020559e:	02098f63          	beqz	s3,ffffffffc02055dc <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc02055a2:	854e                	mv	a0,s3
ffffffffc02055a4:	a03ff0ef          	jal	ra,ffffffffc0204fa6 <find_proc>
ffffffffc02055a8:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc02055aa:	12050063          	beqz	a0,ffffffffc02056ca <do_wait.part.1+0x154>
ffffffffc02055ae:	00093703          	ld	a4,0(s2)
ffffffffc02055b2:	711c                	ld	a5,32(a0)
ffffffffc02055b4:	10e79b63          	bne	a5,a4,ffffffffc02056ca <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055b8:	411c                	lw	a5,0(a0)
ffffffffc02055ba:	02978c63          	beq	a5,s1,ffffffffc02055f2 <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc02055be:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc02055c2:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc02055c6:	1ff000ef          	jal	ra,ffffffffc0205fc4 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc02055ca:	00093783          	ld	a5,0(s2)
ffffffffc02055ce:	0b07a783          	lw	a5,176(a5)
ffffffffc02055d2:	8b85                	andi	a5,a5,1
ffffffffc02055d4:	d7e9                	beqz	a5,ffffffffc020559e <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc02055d6:	555d                	li	a0,-9
ffffffffc02055d8:	e51ff0ef          	jal	ra,ffffffffc0205428 <do_exit>
        proc = current->cptr;
ffffffffc02055dc:	00093703          	ld	a4,0(s2)
ffffffffc02055e0:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02055e2:	e409                	bnez	s0,ffffffffc02055ec <do_wait.part.1+0x76>
ffffffffc02055e4:	a0dd                	j	ffffffffc02056ca <do_wait.part.1+0x154>
ffffffffc02055e6:	10043403          	ld	s0,256(s0)
ffffffffc02055ea:	d871                	beqz	s0,ffffffffc02055be <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055ec:	401c                	lw	a5,0(s0)
ffffffffc02055ee:	fe979ce3          	bne	a5,s1,ffffffffc02055e6 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc02055f2:	000a7797          	auipc	a5,0xa7
ffffffffc02055f6:	dfe78793          	addi	a5,a5,-514 # ffffffffc02ac3f0 <idleproc>
ffffffffc02055fa:	639c                	ld	a5,0(a5)
ffffffffc02055fc:	0c878d63          	beq	a5,s0,ffffffffc02056d6 <do_wait.part.1+0x160>
ffffffffc0205600:	000a7797          	auipc	a5,0xa7
ffffffffc0205604:	df878793          	addi	a5,a5,-520 # ffffffffc02ac3f8 <initproc>
ffffffffc0205608:	639c                	ld	a5,0(a5)
ffffffffc020560a:	0cf40663          	beq	s0,a5,ffffffffc02056d6 <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc020560e:	000b0663          	beqz	s6,ffffffffc020561a <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc0205612:	0e842783          	lw	a5,232(s0)
ffffffffc0205616:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020561a:	100027f3          	csrr	a5,sstatus
ffffffffc020561e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205620:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205622:	e7d5                	bnez	a5,ffffffffc02056ce <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205624:	6c70                	ld	a2,216(s0)
ffffffffc0205626:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc0205628:	10043703          	ld	a4,256(s0)
ffffffffc020562c:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc020562e:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205630:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205632:	6470                	ld	a2,200(s0)
ffffffffc0205634:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0205636:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205638:	e290                	sd	a2,0(a3)
ffffffffc020563a:	c319                	beqz	a4,ffffffffc0205640 <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc020563c:	ff7c                	sd	a5,248(a4)
ffffffffc020563e:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc0205640:	c3d1                	beqz	a5,ffffffffc02056c4 <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc0205642:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0205646:	000a7797          	auipc	a5,0xa7
ffffffffc020564a:	dba78793          	addi	a5,a5,-582 # ffffffffc02ac400 <nr_process>
ffffffffc020564e:	439c                	lw	a5,0(a5)
ffffffffc0205650:	37fd                	addiw	a5,a5,-1
ffffffffc0205652:	000a7717          	auipc	a4,0xa7
ffffffffc0205656:	daf72723          	sw	a5,-594(a4) # ffffffffc02ac400 <nr_process>
    if (flag) {
ffffffffc020565a:	e1b5                	bnez	a1,ffffffffc02056be <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020565c:	6814                	ld	a3,16(s0)
ffffffffc020565e:	c02007b7          	lui	a5,0xc0200
ffffffffc0205662:	0af6e263          	bltu	a3,a5,ffffffffc0205706 <do_wait.part.1+0x190>
ffffffffc0205666:	000a7797          	auipc	a5,0xa7
ffffffffc020566a:	eaa78793          	addi	a5,a5,-342 # ffffffffc02ac510 <va_pa_offset>
ffffffffc020566e:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0205670:	000a7797          	auipc	a5,0xa7
ffffffffc0205674:	d7078793          	addi	a5,a5,-656 # ffffffffc02ac3e0 <npage>
ffffffffc0205678:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc020567a:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc020567c:	82b1                	srli	a3,a3,0xc
ffffffffc020567e:	06f6f863          	bleu	a5,a3,ffffffffc02056ee <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc0205682:	00003797          	auipc	a5,0x3
ffffffffc0205686:	68e78793          	addi	a5,a5,1678 # ffffffffc0208d10 <nbase>
ffffffffc020568a:	639c                	ld	a5,0(a5)
ffffffffc020568c:	000a7717          	auipc	a4,0xa7
ffffffffc0205690:	e9470713          	addi	a4,a4,-364 # ffffffffc02ac520 <pages>
ffffffffc0205694:	6308                	ld	a0,0(a4)
ffffffffc0205696:	8e9d                	sub	a3,a3,a5
ffffffffc0205698:	069a                	slli	a3,a3,0x6
ffffffffc020569a:	9536                	add	a0,a0,a3
ffffffffc020569c:	4589                	li	a1,2
ffffffffc020569e:	ff1fd0ef          	jal	ra,ffffffffc020368e <free_pages>
    kfree(proc);
ffffffffc02056a2:	8522                	mv	a0,s0
ffffffffc02056a4:	eedfc0ef          	jal	ra,ffffffffc0202590 <kfree>
    return 0;
ffffffffc02056a8:	4501                	li	a0,0
}
ffffffffc02056aa:	70e2                	ld	ra,56(sp)
ffffffffc02056ac:	7442                	ld	s0,48(sp)
ffffffffc02056ae:	74a2                	ld	s1,40(sp)
ffffffffc02056b0:	7902                	ld	s2,32(sp)
ffffffffc02056b2:	69e2                	ld	s3,24(sp)
ffffffffc02056b4:	6a42                	ld	s4,16(sp)
ffffffffc02056b6:	6aa2                	ld	s5,8(sp)
ffffffffc02056b8:	6b02                	ld	s6,0(sp)
ffffffffc02056ba:	6121                	addi	sp,sp,64
ffffffffc02056bc:	8082                	ret
        intr_enable();
ffffffffc02056be:	f99fa0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc02056c2:	bf69                	j	ffffffffc020565c <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc02056c4:	701c                	ld	a5,32(s0)
ffffffffc02056c6:	fbf8                	sd	a4,240(a5)
ffffffffc02056c8:	bfbd                	j	ffffffffc0205646 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc02056ca:	5579                	li	a0,-2
ffffffffc02056cc:	bff9                	j	ffffffffc02056aa <do_wait.part.1+0x134>
        intr_disable();
ffffffffc02056ce:	f8ffa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc02056d2:	4585                	li	a1,1
ffffffffc02056d4:	bf81                	j	ffffffffc0205624 <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc02056d6:	00003617          	auipc	a2,0x3
ffffffffc02056da:	f2a60613          	addi	a2,a2,-214 # ffffffffc0208600 <default_pmm_manager+0x890>
ffffffffc02056de:	35700593          	li	a1,855
ffffffffc02056e2:	00003517          	auipc	a0,0x3
ffffffffc02056e6:	16650513          	addi	a0,a0,358 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc02056ea:	b2dfa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02056ee:	00002617          	auipc	a2,0x2
ffffffffc02056f2:	c3260613          	addi	a2,a2,-974 # ffffffffc0207320 <commands+0xb98>
ffffffffc02056f6:	06200593          	li	a1,98
ffffffffc02056fa:	00002517          	auipc	a0,0x2
ffffffffc02056fe:	c4650513          	addi	a0,a0,-954 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0205702:	b15fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205706:	00002617          	auipc	a2,0x2
ffffffffc020570a:	0b260613          	addi	a2,a2,178 # ffffffffc02077b8 <commands+0x1030>
ffffffffc020570e:	06e00593          	li	a1,110
ffffffffc0205712:	00002517          	auipc	a0,0x2
ffffffffc0205716:	c2e50513          	addi	a0,a0,-978 # ffffffffc0207340 <commands+0xbb8>
ffffffffc020571a:	afdfa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020571e <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc020571e:	1141                	addi	sp,sp,-16
ffffffffc0205720:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205722:	fb3fd0ef          	jal	ra,ffffffffc02036d4 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205726:	dabfc0ef          	jal	ra,ffffffffc02024d0 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc020572a:	4601                	li	a2,0
ffffffffc020572c:	4581                	li	a1,0
ffffffffc020572e:	fffff517          	auipc	a0,0xfffff
ffffffffc0205732:	65650513          	addi	a0,a0,1622 # ffffffffc0204d84 <user_main>
ffffffffc0205736:	ca3ff0ef          	jal	ra,ffffffffc02053d8 <kernel_thread>
    if (pid <= 0) {
ffffffffc020573a:	00a04563          	bgtz	a0,ffffffffc0205744 <init_main+0x26>
ffffffffc020573e:	a841                	j	ffffffffc02057ce <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205740:	085000ef          	jal	ra,ffffffffc0205fc4 <schedule>
    if (code_store != NULL) {
ffffffffc0205744:	4581                	li	a1,0
ffffffffc0205746:	4501                	li	a0,0
ffffffffc0205748:	e2fff0ef          	jal	ra,ffffffffc0205576 <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc020574c:	d975                	beqz	a0,ffffffffc0205740 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc020574e:	00003517          	auipc	a0,0x3
ffffffffc0205752:	ef250513          	addi	a0,a0,-270 # ffffffffc0208640 <default_pmm_manager+0x8d0>
ffffffffc0205756:	97bfa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020575a:	000a7797          	auipc	a5,0xa7
ffffffffc020575e:	c9e78793          	addi	a5,a5,-866 # ffffffffc02ac3f8 <initproc>
ffffffffc0205762:	639c                	ld	a5,0(a5)
ffffffffc0205764:	7bf8                	ld	a4,240(a5)
ffffffffc0205766:	e721                	bnez	a4,ffffffffc02057ae <init_main+0x90>
ffffffffc0205768:	7ff8                	ld	a4,248(a5)
ffffffffc020576a:	e331                	bnez	a4,ffffffffc02057ae <init_main+0x90>
ffffffffc020576c:	1007b703          	ld	a4,256(a5)
ffffffffc0205770:	ef1d                	bnez	a4,ffffffffc02057ae <init_main+0x90>
    assert(nr_process == 2);
ffffffffc0205772:	000a7717          	auipc	a4,0xa7
ffffffffc0205776:	c8e70713          	addi	a4,a4,-882 # ffffffffc02ac400 <nr_process>
ffffffffc020577a:	4314                	lw	a3,0(a4)
ffffffffc020577c:	4709                	li	a4,2
ffffffffc020577e:	0ae69463          	bne	a3,a4,ffffffffc0205826 <init_main+0x108>
    return listelm->next;
ffffffffc0205782:	000a7697          	auipc	a3,0xa7
ffffffffc0205786:	da668693          	addi	a3,a3,-602 # ffffffffc02ac528 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020578a:	6698                	ld	a4,8(a3)
ffffffffc020578c:	0c878793          	addi	a5,a5,200
ffffffffc0205790:	06f71b63          	bne	a4,a5,ffffffffc0205806 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205794:	629c                	ld	a5,0(a3)
ffffffffc0205796:	04f71863          	bne	a4,a5,ffffffffc02057e6 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc020579a:	00003517          	auipc	a0,0x3
ffffffffc020579e:	f8e50513          	addi	a0,a0,-114 # ffffffffc0208728 <default_pmm_manager+0x9b8>
ffffffffc02057a2:	92ffa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
}
ffffffffc02057a6:	60a2                	ld	ra,8(sp)
ffffffffc02057a8:	4501                	li	a0,0
ffffffffc02057aa:	0141                	addi	sp,sp,16
ffffffffc02057ac:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02057ae:	00003697          	auipc	a3,0x3
ffffffffc02057b2:	eba68693          	addi	a3,a3,-326 # ffffffffc0208668 <default_pmm_manager+0x8f8>
ffffffffc02057b6:	00001617          	auipc	a2,0x1
ffffffffc02057ba:	45260613          	addi	a2,a2,1106 # ffffffffc0206c08 <commands+0x480>
ffffffffc02057be:	3bc00593          	li	a1,956
ffffffffc02057c2:	00003517          	auipc	a0,0x3
ffffffffc02057c6:	08650513          	addi	a0,a0,134 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc02057ca:	a4dfa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("create user_main failed.\n");
ffffffffc02057ce:	00003617          	auipc	a2,0x3
ffffffffc02057d2:	e5260613          	addi	a2,a2,-430 # ffffffffc0208620 <default_pmm_manager+0x8b0>
ffffffffc02057d6:	3b400593          	li	a1,948
ffffffffc02057da:	00003517          	auipc	a0,0x3
ffffffffc02057de:	06e50513          	addi	a0,a0,110 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc02057e2:	a35fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02057e6:	00003697          	auipc	a3,0x3
ffffffffc02057ea:	f1268693          	addi	a3,a3,-238 # ffffffffc02086f8 <default_pmm_manager+0x988>
ffffffffc02057ee:	00001617          	auipc	a2,0x1
ffffffffc02057f2:	41a60613          	addi	a2,a2,1050 # ffffffffc0206c08 <commands+0x480>
ffffffffc02057f6:	3bf00593          	li	a1,959
ffffffffc02057fa:	00003517          	auipc	a0,0x3
ffffffffc02057fe:	04e50513          	addi	a0,a0,78 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc0205802:	a15fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205806:	00003697          	auipc	a3,0x3
ffffffffc020580a:	ec268693          	addi	a3,a3,-318 # ffffffffc02086c8 <default_pmm_manager+0x958>
ffffffffc020580e:	00001617          	auipc	a2,0x1
ffffffffc0205812:	3fa60613          	addi	a2,a2,1018 # ffffffffc0206c08 <commands+0x480>
ffffffffc0205816:	3be00593          	li	a1,958
ffffffffc020581a:	00003517          	auipc	a0,0x3
ffffffffc020581e:	02e50513          	addi	a0,a0,46 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc0205822:	9f5fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_process == 2);
ffffffffc0205826:	00003697          	auipc	a3,0x3
ffffffffc020582a:	e9268693          	addi	a3,a3,-366 # ffffffffc02086b8 <default_pmm_manager+0x948>
ffffffffc020582e:	00001617          	auipc	a2,0x1
ffffffffc0205832:	3da60613          	addi	a2,a2,986 # ffffffffc0206c08 <commands+0x480>
ffffffffc0205836:	3bd00593          	li	a1,957
ffffffffc020583a:	00003517          	auipc	a0,0x3
ffffffffc020583e:	00e50513          	addi	a0,a0,14 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc0205842:	9d5fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205846 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205846:	7135                	addi	sp,sp,-160
ffffffffc0205848:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020584a:	000a7a17          	auipc	s4,0xa7
ffffffffc020584e:	b9ea0a13          	addi	s4,s4,-1122 # ffffffffc02ac3e8 <current>
ffffffffc0205852:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205856:	e14a                	sd	s2,128(sp)
ffffffffc0205858:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020585a:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020585e:	fcce                	sd	s3,120(sp)
ffffffffc0205860:	f0da                	sd	s6,96(sp)
ffffffffc0205862:	89aa                	mv	s3,a0
ffffffffc0205864:	842e                	mv	s0,a1
ffffffffc0205866:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205868:	4681                	li	a3,0
ffffffffc020586a:	862e                	mv	a2,a1
ffffffffc020586c:	85aa                	mv	a1,a0
ffffffffc020586e:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205870:	ed06                	sd	ra,152(sp)
ffffffffc0205872:	e526                	sd	s1,136(sp)
ffffffffc0205874:	f4d6                	sd	s5,104(sp)
ffffffffc0205876:	ecde                	sd	s7,88(sp)
ffffffffc0205878:	e8e2                	sd	s8,80(sp)
ffffffffc020587a:	e4e6                	sd	s9,72(sp)
ffffffffc020587c:	e0ea                	sd	s10,64(sp)
ffffffffc020587e:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205880:	fe1fb0ef          	jal	ra,ffffffffc0201860 <user_mem_check>
ffffffffc0205884:	40050663          	beqz	a0,ffffffffc0205c90 <do_execve+0x44a>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0205888:	4641                	li	a2,16
ffffffffc020588a:	4581                	li	a1,0
ffffffffc020588c:	1008                	addi	a0,sp,32
ffffffffc020588e:	14b000ef          	jal	ra,ffffffffc02061d8 <memset>
    memcpy(local_name, name, len);
ffffffffc0205892:	47bd                	li	a5,15
ffffffffc0205894:	8622                	mv	a2,s0
ffffffffc0205896:	0687ee63          	bltu	a5,s0,ffffffffc0205912 <do_execve+0xcc>
ffffffffc020589a:	85ce                	mv	a1,s3
ffffffffc020589c:	1008                	addi	a0,sp,32
ffffffffc020589e:	14d000ef          	jal	ra,ffffffffc02061ea <memcpy>
    if (mm != NULL) {
ffffffffc02058a2:	06090f63          	beqz	s2,ffffffffc0205920 <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc02058a6:	00002517          	auipc	a0,0x2
ffffffffc02058aa:	8b250513          	addi	a0,a0,-1870 # ffffffffc0207158 <commands+0x9d0>
ffffffffc02058ae:	85bfa0ef          	jal	ra,ffffffffc0200108 <cputs>
        lcr3(boot_cr3);
ffffffffc02058b2:	000a7797          	auipc	a5,0xa7
ffffffffc02058b6:	c6678793          	addi	a5,a5,-922 # ffffffffc02ac518 <boot_cr3>
ffffffffc02058ba:	639c                	ld	a5,0(a5)
ffffffffc02058bc:	577d                	li	a4,-1
ffffffffc02058be:	177e                	slli	a4,a4,0x3f
ffffffffc02058c0:	83b1                	srli	a5,a5,0xc
ffffffffc02058c2:	8fd9                	or	a5,a5,a4
ffffffffc02058c4:	18079073          	csrw	satp,a5
ffffffffc02058c8:	03092783          	lw	a5,48(s2)
ffffffffc02058cc:	fff7871b          	addiw	a4,a5,-1
ffffffffc02058d0:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc02058d4:	28070d63          	beqz	a4,ffffffffc0205b6e <do_execve+0x328>
        current->mm = NULL;
ffffffffc02058d8:	000a3783          	ld	a5,0(s4)
ffffffffc02058dc:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc02058e0:	d9afb0ef          	jal	ra,ffffffffc0200e7a <mm_create>
ffffffffc02058e4:	892a                	mv	s2,a0
ffffffffc02058e6:	c135                	beqz	a0,ffffffffc020594a <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc02058e8:	d9cff0ef          	jal	ra,ffffffffc0204e84 <setup_pgdir>
ffffffffc02058ec:	e931                	bnez	a0,ffffffffc0205940 <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02058ee:	000b2703          	lw	a4,0(s6)
ffffffffc02058f2:	464c47b7          	lui	a5,0x464c4
ffffffffc02058f6:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9b0f>
ffffffffc02058fa:	04f70a63          	beq	a4,a5,ffffffffc020594e <do_execve+0x108>
    put_pgdir(mm);
ffffffffc02058fe:	854a                	mv	a0,s2
ffffffffc0205900:	d06ff0ef          	jal	ra,ffffffffc0204e06 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205904:	854a                	mv	a0,s2
ffffffffc0205906:	efafb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc020590a:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc020590c:	854e                	mv	a0,s3
ffffffffc020590e:	b1bff0ef          	jal	ra,ffffffffc0205428 <do_exit>
    memcpy(local_name, name, len);
ffffffffc0205912:	463d                	li	a2,15
ffffffffc0205914:	85ce                	mv	a1,s3
ffffffffc0205916:	1008                	addi	a0,sp,32
ffffffffc0205918:	0d3000ef          	jal	ra,ffffffffc02061ea <memcpy>
    if (mm != NULL) {
ffffffffc020591c:	f80915e3          	bnez	s2,ffffffffc02058a6 <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc0205920:	000a3783          	ld	a5,0(s4)
ffffffffc0205924:	779c                	ld	a5,40(a5)
ffffffffc0205926:	dfcd                	beqz	a5,ffffffffc02058e0 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205928:	00003617          	auipc	a2,0x3
ffffffffc020592c:	aa860613          	addi	a2,a2,-1368 # ffffffffc02083d0 <default_pmm_manager+0x660>
ffffffffc0205930:	26500593          	li	a1,613
ffffffffc0205934:	00003517          	auipc	a0,0x3
ffffffffc0205938:	f1450513          	addi	a0,a0,-236 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc020593c:	8dbfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    mm_destroy(mm);
ffffffffc0205940:	854a                	mv	a0,s2
ffffffffc0205942:	ebefb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0205946:	59f1                	li	s3,-4
ffffffffc0205948:	b7d1                	j	ffffffffc020590c <do_execve+0xc6>
ffffffffc020594a:	59f1                	li	s3,-4
ffffffffc020594c:	b7c1                	j	ffffffffc020590c <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020594e:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205952:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205956:	00371793          	slli	a5,a4,0x3
ffffffffc020595a:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020595c:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020595e:	078e                	slli	a5,a5,0x3
ffffffffc0205960:	97a2                	add	a5,a5,s0
ffffffffc0205962:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205964:	02f47b63          	bleu	a5,s0,ffffffffc020599a <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc0205968:	5bfd                	li	s7,-1
ffffffffc020596a:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc020596e:	000a7d97          	auipc	s11,0xa7
ffffffffc0205972:	bb2d8d93          	addi	s11,s11,-1102 # ffffffffc02ac520 <pages>
ffffffffc0205976:	00003d17          	auipc	s10,0x3
ffffffffc020597a:	39ad0d13          	addi	s10,s10,922 # ffffffffc0208d10 <nbase>
    return KADDR(page2pa(page));
ffffffffc020597e:	e43e                	sd	a5,8(sp)
ffffffffc0205980:	000a7c97          	auipc	s9,0xa7
ffffffffc0205984:	a60c8c93          	addi	s9,s9,-1440 # ffffffffc02ac3e0 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205988:	4018                	lw	a4,0(s0)
ffffffffc020598a:	4785                	li	a5,1
ffffffffc020598c:	0ef70f63          	beq	a4,a5,ffffffffc0205a8a <do_execve+0x244>
    for (; ph < ph_end; ph ++) {
ffffffffc0205990:	67e2                	ld	a5,24(sp)
ffffffffc0205992:	03840413          	addi	s0,s0,56
ffffffffc0205996:	fef469e3          	bltu	s0,a5,ffffffffc0205988 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc020599a:	4701                	li	a4,0
ffffffffc020599c:	46ad                	li	a3,11
ffffffffc020599e:	00100637          	lui	a2,0x100
ffffffffc02059a2:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02059a6:	854a                	mv	a0,s2
ffffffffc02059a8:	eaafb0ef          	jal	ra,ffffffffc0201052 <mm_map>
ffffffffc02059ac:	89aa                	mv	s3,a0
ffffffffc02059ae:	1a051663          	bnez	a0,ffffffffc0205b5a <do_execve+0x314>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc02059b2:	01893503          	ld	a0,24(s2)
ffffffffc02059b6:	467d                	li	a2,31
ffffffffc02059b8:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02059bc:	8d6ff0ef          	jal	ra,ffffffffc0204a92 <pgdir_alloc_page>
ffffffffc02059c0:	36050463          	beqz	a0,ffffffffc0205d28 <do_execve+0x4e2>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc02059c4:	01893503          	ld	a0,24(s2)
ffffffffc02059c8:	467d                	li	a2,31
ffffffffc02059ca:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02059ce:	8c4ff0ef          	jal	ra,ffffffffc0204a92 <pgdir_alloc_page>
ffffffffc02059d2:	32050b63          	beqz	a0,ffffffffc0205d08 <do_execve+0x4c2>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc02059d6:	01893503          	ld	a0,24(s2)
ffffffffc02059da:	467d                	li	a2,31
ffffffffc02059dc:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02059e0:	8b2ff0ef          	jal	ra,ffffffffc0204a92 <pgdir_alloc_page>
ffffffffc02059e4:	30050263          	beqz	a0,ffffffffc0205ce8 <do_execve+0x4a2>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc02059e8:	01893503          	ld	a0,24(s2)
ffffffffc02059ec:	467d                	li	a2,31
ffffffffc02059ee:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02059f2:	8a0ff0ef          	jal	ra,ffffffffc0204a92 <pgdir_alloc_page>
ffffffffc02059f6:	2c050963          	beqz	a0,ffffffffc0205cc8 <do_execve+0x482>
    mm->mm_count += 1;
ffffffffc02059fa:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc02059fe:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205a02:	01893683          	ld	a3,24(s2)
ffffffffc0205a06:	2785                	addiw	a5,a5,1
ffffffffc0205a08:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc0205a0c:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf55b8>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205a10:	c02007b7          	lui	a5,0xc0200
ffffffffc0205a14:	28f6ee63          	bltu	a3,a5,ffffffffc0205cb0 <do_execve+0x46a>
ffffffffc0205a18:	000a7797          	auipc	a5,0xa7
ffffffffc0205a1c:	af878793          	addi	a5,a5,-1288 # ffffffffc02ac510 <va_pa_offset>
ffffffffc0205a20:	639c                	ld	a5,0(a5)
ffffffffc0205a22:	577d                	li	a4,-1
ffffffffc0205a24:	177e                	slli	a4,a4,0x3f
ffffffffc0205a26:	8e9d                	sub	a3,a3,a5
ffffffffc0205a28:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205a2c:	f654                	sd	a3,168(a2)
ffffffffc0205a2e:	8fd9                	or	a5,a5,a4
ffffffffc0205a30:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205a34:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a36:	4581                	li	a1,0
ffffffffc0205a38:	12000613          	li	a2,288
    uintptr_t sstatus = tf->status;
ffffffffc0205a3c:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a40:	8522                	mv	a0,s0
ffffffffc0205a42:	796000ef          	jal	ra,ffffffffc02061d8 <memset>
    tf->epc = elf->e_entry;
ffffffffc0205a46:	018b3703          	ld	a4,24(s6)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205a4a:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a4e:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc0205a50:	000a3503          	ld	a0,0(s4)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205a54:	0204e493          	ori	s1,s1,32
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a58:	07fe                	slli	a5,a5,0x1f
ffffffffc0205a5a:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205a5c:	10e43423          	sd	a4,264(s0)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205a60:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205a64:	100c                	addi	a1,sp,32
ffffffffc0205a66:	caaff0ef          	jal	ra,ffffffffc0204f10 <set_proc_name>
}
ffffffffc0205a6a:	60ea                	ld	ra,152(sp)
ffffffffc0205a6c:	644a                	ld	s0,144(sp)
ffffffffc0205a6e:	854e                	mv	a0,s3
ffffffffc0205a70:	64aa                	ld	s1,136(sp)
ffffffffc0205a72:	690a                	ld	s2,128(sp)
ffffffffc0205a74:	79e6                	ld	s3,120(sp)
ffffffffc0205a76:	7a46                	ld	s4,112(sp)
ffffffffc0205a78:	7aa6                	ld	s5,104(sp)
ffffffffc0205a7a:	7b06                	ld	s6,96(sp)
ffffffffc0205a7c:	6be6                	ld	s7,88(sp)
ffffffffc0205a7e:	6c46                	ld	s8,80(sp)
ffffffffc0205a80:	6ca6                	ld	s9,72(sp)
ffffffffc0205a82:	6d06                	ld	s10,64(sp)
ffffffffc0205a84:	7de2                	ld	s11,56(sp)
ffffffffc0205a86:	610d                	addi	sp,sp,160
ffffffffc0205a88:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205a8a:	7410                	ld	a2,40(s0)
ffffffffc0205a8c:	701c                	ld	a5,32(s0)
ffffffffc0205a8e:	20f66363          	bltu	a2,a5,ffffffffc0205c94 <do_execve+0x44e>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a92:	405c                	lw	a5,4(s0)
ffffffffc0205a94:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a98:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a9c:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a9e:	0e071263          	bnez	a4,ffffffffc0205b82 <do_execve+0x33c>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205aa2:	4745                	li	a4,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205aa4:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205aa6:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205aa8:	c789                	beqz	a5,ffffffffc0205ab2 <do_execve+0x26c>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205aaa:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205aac:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205ab0:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205ab2:	0026f793          	andi	a5,a3,2
ffffffffc0205ab6:	efe1                	bnez	a5,ffffffffc0205b8e <do_execve+0x348>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205ab8:	0046f793          	andi	a5,a3,4
ffffffffc0205abc:	c789                	beqz	a5,ffffffffc0205ac6 <do_execve+0x280>
ffffffffc0205abe:	6782                	ld	a5,0(sp)
ffffffffc0205ac0:	0087e793          	ori	a5,a5,8
ffffffffc0205ac4:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205ac6:	680c                	ld	a1,16(s0)
ffffffffc0205ac8:	4701                	li	a4,0
ffffffffc0205aca:	854a                	mv	a0,s2
ffffffffc0205acc:	d86fb0ef          	jal	ra,ffffffffc0201052 <mm_map>
ffffffffc0205ad0:	89aa                	mv	s3,a0
ffffffffc0205ad2:	e541                	bnez	a0,ffffffffc0205b5a <do_execve+0x314>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205ad4:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205ad8:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205adc:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205ae0:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205ae2:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205ae4:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205ae6:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205aea:	053bef63          	bltu	s7,s3,ffffffffc0205b48 <do_execve+0x302>
ffffffffc0205aee:	aa79                	j	ffffffffc0205c8c <do_execve+0x446>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205af0:	6785                	lui	a5,0x1
ffffffffc0205af2:	418b8533          	sub	a0,s7,s8
ffffffffc0205af6:	9c3e                	add	s8,s8,a5
ffffffffc0205af8:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205afc:	0189f463          	bleu	s8,s3,ffffffffc0205b04 <do_execve+0x2be>
                size -= la - end;
ffffffffc0205b00:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205b04:	000db683          	ld	a3,0(s11)
ffffffffc0205b08:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205b0c:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205b0e:	40d486b3          	sub	a3,s1,a3
ffffffffc0205b12:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205b14:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205b18:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205b1a:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b1e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b20:	16c5fc63          	bleu	a2,a1,ffffffffc0205c98 <do_execve+0x452>
ffffffffc0205b24:	000a7797          	auipc	a5,0xa7
ffffffffc0205b28:	9ec78793          	addi	a5,a5,-1556 # ffffffffc02ac510 <va_pa_offset>
ffffffffc0205b2c:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b30:	85d6                	mv	a1,s5
ffffffffc0205b32:	8642                	mv	a2,a6
ffffffffc0205b34:	96c6                	add	a3,a3,a7
ffffffffc0205b36:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205b38:	9bc2                	add	s7,s7,a6
ffffffffc0205b3a:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b3c:	6ae000ef          	jal	ra,ffffffffc02061ea <memcpy>
            start += size, from += size;
ffffffffc0205b40:	6842                	ld	a6,16(sp)
ffffffffc0205b42:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205b44:	053bf863          	bleu	s3,s7,ffffffffc0205b94 <do_execve+0x34e>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205b48:	01893503          	ld	a0,24(s2)
ffffffffc0205b4c:	6602                	ld	a2,0(sp)
ffffffffc0205b4e:	85e2                	mv	a1,s8
ffffffffc0205b50:	f43fe0ef          	jal	ra,ffffffffc0204a92 <pgdir_alloc_page>
ffffffffc0205b54:	84aa                	mv	s1,a0
ffffffffc0205b56:	fd49                	bnez	a0,ffffffffc0205af0 <do_execve+0x2aa>
        ret = -E_NO_MEM;
ffffffffc0205b58:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205b5a:	854a                	mv	a0,s2
ffffffffc0205b5c:	e44fb0ef          	jal	ra,ffffffffc02011a0 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205b60:	854a                	mv	a0,s2
ffffffffc0205b62:	aa4ff0ef          	jal	ra,ffffffffc0204e06 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b66:	854a                	mv	a0,s2
ffffffffc0205b68:	c98fb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
    return ret;
ffffffffc0205b6c:	b345                	j	ffffffffc020590c <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205b6e:	854a                	mv	a0,s2
ffffffffc0205b70:	e30fb0ef          	jal	ra,ffffffffc02011a0 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205b74:	854a                	mv	a0,s2
ffffffffc0205b76:	a90ff0ef          	jal	ra,ffffffffc0204e06 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205b7a:	854a                	mv	a0,s2
ffffffffc0205b7c:	c84fb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
ffffffffc0205b80:	bba1                	j	ffffffffc02058d8 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b82:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b86:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b88:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b8a:	f20790e3          	bnez	a5,ffffffffc0205aaa <do_execve+0x264>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b8e:	47dd                	li	a5,23
ffffffffc0205b90:	e03e                	sd	a5,0(sp)
ffffffffc0205b92:	b71d                	j	ffffffffc0205ab8 <do_execve+0x272>
ffffffffc0205b94:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b98:	7414                	ld	a3,40(s0)
ffffffffc0205b9a:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205b9c:	098bf163          	bleu	s8,s7,ffffffffc0205c1e <do_execve+0x3d8>
            if (start == end) {
ffffffffc0205ba0:	df7988e3          	beq	s3,s7,ffffffffc0205990 <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205ba4:	6505                	lui	a0,0x1
ffffffffc0205ba6:	955e                	add	a0,a0,s7
ffffffffc0205ba8:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205bac:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205bb0:	0d89fb63          	bleu	s8,s3,ffffffffc0205c86 <do_execve+0x440>
    return page - pages + nbase;
ffffffffc0205bb4:	000db683          	ld	a3,0(s11)
ffffffffc0205bb8:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205bbc:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205bbe:	40d486b3          	sub	a3,s1,a3
ffffffffc0205bc2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205bc4:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205bc8:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205bca:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205bce:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205bd0:	0cc5f463          	bleu	a2,a1,ffffffffc0205c98 <do_execve+0x452>
ffffffffc0205bd4:	000a7617          	auipc	a2,0xa7
ffffffffc0205bd8:	93c60613          	addi	a2,a2,-1732 # ffffffffc02ac510 <va_pa_offset>
ffffffffc0205bdc:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205be0:	4581                	li	a1,0
ffffffffc0205be2:	8656                	mv	a2,s5
ffffffffc0205be4:	96c2                	add	a3,a3,a6
ffffffffc0205be6:	9536                	add	a0,a0,a3
ffffffffc0205be8:	5f0000ef          	jal	ra,ffffffffc02061d8 <memset>
            start += size;
ffffffffc0205bec:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205bf0:	0389f463          	bleu	s8,s3,ffffffffc0205c18 <do_execve+0x3d2>
ffffffffc0205bf4:	d8e98ee3          	beq	s3,a4,ffffffffc0205990 <do_execve+0x14a>
ffffffffc0205bf8:	00003697          	auipc	a3,0x3
ffffffffc0205bfc:	80068693          	addi	a3,a3,-2048 # ffffffffc02083f8 <default_pmm_manager+0x688>
ffffffffc0205c00:	00001617          	auipc	a2,0x1
ffffffffc0205c04:	00860613          	addi	a2,a2,8 # ffffffffc0206c08 <commands+0x480>
ffffffffc0205c08:	2ba00593          	li	a1,698
ffffffffc0205c0c:	00003517          	auipc	a0,0x3
ffffffffc0205c10:	c3c50513          	addi	a0,a0,-964 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc0205c14:	e02fa0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0205c18:	ff8710e3          	bne	a4,s8,ffffffffc0205bf8 <do_execve+0x3b2>
ffffffffc0205c1c:	8be2                	mv	s7,s8
ffffffffc0205c1e:	000a7a97          	auipc	s5,0xa7
ffffffffc0205c22:	8f2a8a93          	addi	s5,s5,-1806 # ffffffffc02ac510 <va_pa_offset>
        while (start < end) {
ffffffffc0205c26:	053be763          	bltu	s7,s3,ffffffffc0205c74 <do_execve+0x42e>
ffffffffc0205c2a:	b39d                	j	ffffffffc0205990 <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c2c:	6785                	lui	a5,0x1
ffffffffc0205c2e:	418b8533          	sub	a0,s7,s8
ffffffffc0205c32:	9c3e                	add	s8,s8,a5
ffffffffc0205c34:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0205c38:	0189f463          	bleu	s8,s3,ffffffffc0205c40 <do_execve+0x3fa>
                size -= la - end;
ffffffffc0205c3c:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205c40:	000db683          	ld	a3,0(s11)
ffffffffc0205c44:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205c48:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205c4a:	40d486b3          	sub	a3,s1,a3
ffffffffc0205c4e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205c50:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205c54:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205c56:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c5a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c5c:	02b87e63          	bleu	a1,a6,ffffffffc0205c98 <do_execve+0x452>
ffffffffc0205c60:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205c64:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c66:	4581                	li	a1,0
ffffffffc0205c68:	96c2                	add	a3,a3,a6
ffffffffc0205c6a:	9536                	add	a0,a0,a3
ffffffffc0205c6c:	56c000ef          	jal	ra,ffffffffc02061d8 <memset>
        while (start < end) {
ffffffffc0205c70:	d33bf0e3          	bleu	s3,s7,ffffffffc0205990 <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205c74:	01893503          	ld	a0,24(s2)
ffffffffc0205c78:	6602                	ld	a2,0(sp)
ffffffffc0205c7a:	85e2                	mv	a1,s8
ffffffffc0205c7c:	e17fe0ef          	jal	ra,ffffffffc0204a92 <pgdir_alloc_page>
ffffffffc0205c80:	84aa                	mv	s1,a0
ffffffffc0205c82:	f54d                	bnez	a0,ffffffffc0205c2c <do_execve+0x3e6>
ffffffffc0205c84:	bdd1                	j	ffffffffc0205b58 <do_execve+0x312>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c86:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205c8a:	b72d                	j	ffffffffc0205bb4 <do_execve+0x36e>
        while (start < end) {
ffffffffc0205c8c:	89de                	mv	s3,s7
ffffffffc0205c8e:	b729                	j	ffffffffc0205b98 <do_execve+0x352>
        return -E_INVAL;
ffffffffc0205c90:	59f5                	li	s3,-3
ffffffffc0205c92:	bbe1                	j	ffffffffc0205a6a <do_execve+0x224>
            ret = -E_INVAL_ELF;
ffffffffc0205c94:	59e1                	li	s3,-8
ffffffffc0205c96:	b5d1                	j	ffffffffc0205b5a <do_execve+0x314>
ffffffffc0205c98:	00001617          	auipc	a2,0x1
ffffffffc0205c9c:	6b860613          	addi	a2,a2,1720 # ffffffffc0207350 <commands+0xbc8>
ffffffffc0205ca0:	06900593          	li	a1,105
ffffffffc0205ca4:	00001517          	auipc	a0,0x1
ffffffffc0205ca8:	69c50513          	addi	a0,a0,1692 # ffffffffc0207340 <commands+0xbb8>
ffffffffc0205cac:	d6afa0ef          	jal	ra,ffffffffc0200216 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205cb0:	00002617          	auipc	a2,0x2
ffffffffc0205cb4:	b0860613          	addi	a2,a2,-1272 # ffffffffc02077b8 <commands+0x1030>
ffffffffc0205cb8:	2d500593          	li	a1,725
ffffffffc0205cbc:	00003517          	auipc	a0,0x3
ffffffffc0205cc0:	b8c50513          	addi	a0,a0,-1140 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc0205cc4:	d52fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cc8:	00003697          	auipc	a3,0x3
ffffffffc0205ccc:	84868693          	addi	a3,a3,-1976 # ffffffffc0208510 <default_pmm_manager+0x7a0>
ffffffffc0205cd0:	00001617          	auipc	a2,0x1
ffffffffc0205cd4:	f3860613          	addi	a2,a2,-200 # ffffffffc0206c08 <commands+0x480>
ffffffffc0205cd8:	2d000593          	li	a1,720
ffffffffc0205cdc:	00003517          	auipc	a0,0x3
ffffffffc0205ce0:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc0205ce4:	d32fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205ce8:	00002697          	auipc	a3,0x2
ffffffffc0205cec:	7e068693          	addi	a3,a3,2016 # ffffffffc02084c8 <default_pmm_manager+0x758>
ffffffffc0205cf0:	00001617          	auipc	a2,0x1
ffffffffc0205cf4:	f1860613          	addi	a2,a2,-232 # ffffffffc0206c08 <commands+0x480>
ffffffffc0205cf8:	2cf00593          	li	a1,719
ffffffffc0205cfc:	00003517          	auipc	a0,0x3
ffffffffc0205d00:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc0205d04:	d12fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205d08:	00002697          	auipc	a3,0x2
ffffffffc0205d0c:	77868693          	addi	a3,a3,1912 # ffffffffc0208480 <default_pmm_manager+0x710>
ffffffffc0205d10:	00001617          	auipc	a2,0x1
ffffffffc0205d14:	ef860613          	addi	a2,a2,-264 # ffffffffc0206c08 <commands+0x480>
ffffffffc0205d18:	2ce00593          	li	a1,718
ffffffffc0205d1c:	00003517          	auipc	a0,0x3
ffffffffc0205d20:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc0205d24:	cf2fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205d28:	00002697          	auipc	a3,0x2
ffffffffc0205d2c:	71068693          	addi	a3,a3,1808 # ffffffffc0208438 <default_pmm_manager+0x6c8>
ffffffffc0205d30:	00001617          	auipc	a2,0x1
ffffffffc0205d34:	ed860613          	addi	a2,a2,-296 # ffffffffc0206c08 <commands+0x480>
ffffffffc0205d38:	2cd00593          	li	a1,717
ffffffffc0205d3c:	00003517          	auipc	a0,0x3
ffffffffc0205d40:	b0c50513          	addi	a0,a0,-1268 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc0205d44:	cd2fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205d48 <do_yield>:
    current->need_resched = 1;
ffffffffc0205d48:	000a6797          	auipc	a5,0xa6
ffffffffc0205d4c:	6a078793          	addi	a5,a5,1696 # ffffffffc02ac3e8 <current>
ffffffffc0205d50:	639c                	ld	a5,0(a5)
ffffffffc0205d52:	4705                	li	a4,1
}
ffffffffc0205d54:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205d56:	ef98                	sd	a4,24(a5)
}
ffffffffc0205d58:	8082                	ret

ffffffffc0205d5a <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205d5a:	1101                	addi	sp,sp,-32
ffffffffc0205d5c:	e822                	sd	s0,16(sp)
ffffffffc0205d5e:	e426                	sd	s1,8(sp)
ffffffffc0205d60:	ec06                	sd	ra,24(sp)
ffffffffc0205d62:	842e                	mv	s0,a1
ffffffffc0205d64:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205d66:	cd81                	beqz	a1,ffffffffc0205d7e <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205d68:	000a6797          	auipc	a5,0xa6
ffffffffc0205d6c:	68078793          	addi	a5,a5,1664 # ffffffffc02ac3e8 <current>
ffffffffc0205d70:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205d72:	4685                	li	a3,1
ffffffffc0205d74:	4611                	li	a2,4
ffffffffc0205d76:	7788                	ld	a0,40(a5)
ffffffffc0205d78:	ae9fb0ef          	jal	ra,ffffffffc0201860 <user_mem_check>
ffffffffc0205d7c:	c909                	beqz	a0,ffffffffc0205d8e <do_wait+0x34>
ffffffffc0205d7e:	85a2                	mv	a1,s0
}
ffffffffc0205d80:	6442                	ld	s0,16(sp)
ffffffffc0205d82:	60e2                	ld	ra,24(sp)
ffffffffc0205d84:	8526                	mv	a0,s1
ffffffffc0205d86:	64a2                	ld	s1,8(sp)
ffffffffc0205d88:	6105                	addi	sp,sp,32
ffffffffc0205d8a:	fecff06f          	j	ffffffffc0205576 <do_wait.part.1>
ffffffffc0205d8e:	60e2                	ld	ra,24(sp)
ffffffffc0205d90:	6442                	ld	s0,16(sp)
ffffffffc0205d92:	64a2                	ld	s1,8(sp)
ffffffffc0205d94:	5575                	li	a0,-3
ffffffffc0205d96:	6105                	addi	sp,sp,32
ffffffffc0205d98:	8082                	ret

ffffffffc0205d9a <do_kill>:
do_kill(int pid) {
ffffffffc0205d9a:	1141                	addi	sp,sp,-16
ffffffffc0205d9c:	e406                	sd	ra,8(sp)
ffffffffc0205d9e:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205da0:	a06ff0ef          	jal	ra,ffffffffc0204fa6 <find_proc>
ffffffffc0205da4:	cd0d                	beqz	a0,ffffffffc0205dde <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205da6:	0b052703          	lw	a4,176(a0)
ffffffffc0205daa:	00177693          	andi	a3,a4,1
ffffffffc0205dae:	e695                	bnez	a3,ffffffffc0205dda <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205db0:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205db4:	00176713          	ori	a4,a4,1
ffffffffc0205db8:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205dbc:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205dbe:	0006c763          	bltz	a3,ffffffffc0205dcc <do_kill+0x32>
}
ffffffffc0205dc2:	8522                	mv	a0,s0
ffffffffc0205dc4:	60a2                	ld	ra,8(sp)
ffffffffc0205dc6:	6402                	ld	s0,0(sp)
ffffffffc0205dc8:	0141                	addi	sp,sp,16
ffffffffc0205dca:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205dcc:	17c000ef          	jal	ra,ffffffffc0205f48 <wakeup_proc>
}
ffffffffc0205dd0:	8522                	mv	a0,s0
ffffffffc0205dd2:	60a2                	ld	ra,8(sp)
ffffffffc0205dd4:	6402                	ld	s0,0(sp)
ffffffffc0205dd6:	0141                	addi	sp,sp,16
ffffffffc0205dd8:	8082                	ret
        return -E_KILLED;
ffffffffc0205dda:	545d                	li	s0,-9
ffffffffc0205ddc:	b7dd                	j	ffffffffc0205dc2 <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205dde:	5475                	li	s0,-3
ffffffffc0205de0:	b7cd                	j	ffffffffc0205dc2 <do_kill+0x28>

ffffffffc0205de2 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205de2:	000a6797          	auipc	a5,0xa6
ffffffffc0205de6:	74678793          	addi	a5,a5,1862 # ffffffffc02ac528 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205dea:	1101                	addi	sp,sp,-32
ffffffffc0205dec:	000a6717          	auipc	a4,0xa6
ffffffffc0205df0:	74f73223          	sd	a5,1860(a4) # ffffffffc02ac530 <proc_list+0x8>
ffffffffc0205df4:	000a6717          	auipc	a4,0xa6
ffffffffc0205df8:	72f73a23          	sd	a5,1844(a4) # ffffffffc02ac528 <proc_list>
ffffffffc0205dfc:	ec06                	sd	ra,24(sp)
ffffffffc0205dfe:	e822                	sd	s0,16(sp)
ffffffffc0205e00:	e426                	sd	s1,8(sp)
ffffffffc0205e02:	000a2797          	auipc	a5,0xa2
ffffffffc0205e06:	5a678793          	addi	a5,a5,1446 # ffffffffc02a83a8 <hash_list>
ffffffffc0205e0a:	000a6717          	auipc	a4,0xa6
ffffffffc0205e0e:	59e70713          	addi	a4,a4,1438 # ffffffffc02ac3a8 <is_panic>
ffffffffc0205e12:	e79c                	sd	a5,8(a5)
ffffffffc0205e14:	e39c                	sd	a5,0(a5)
ffffffffc0205e16:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205e18:	fee79de3          	bne	a5,a4,ffffffffc0205e12 <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205e1c:	ee5fe0ef          	jal	ra,ffffffffc0204d00 <alloc_proc>
ffffffffc0205e20:	000a6717          	auipc	a4,0xa6
ffffffffc0205e24:	5ca73823          	sd	a0,1488(a4) # ffffffffc02ac3f0 <idleproc>
ffffffffc0205e28:	000a6497          	auipc	s1,0xa6
ffffffffc0205e2c:	5c848493          	addi	s1,s1,1480 # ffffffffc02ac3f0 <idleproc>
ffffffffc0205e30:	c559                	beqz	a0,ffffffffc0205ebe <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205e32:	4709                	li	a4,2
ffffffffc0205e34:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205e36:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e38:	00003717          	auipc	a4,0x3
ffffffffc0205e3c:	1c870713          	addi	a4,a4,456 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205e40:	00003597          	auipc	a1,0x3
ffffffffc0205e44:	92058593          	addi	a1,a1,-1760 # ffffffffc0208760 <default_pmm_manager+0x9f0>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e48:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205e4a:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205e4c:	8c4ff0ef          	jal	ra,ffffffffc0204f10 <set_proc_name>
    nr_process ++;
ffffffffc0205e50:	000a6797          	auipc	a5,0xa6
ffffffffc0205e54:	5b078793          	addi	a5,a5,1456 # ffffffffc02ac400 <nr_process>
ffffffffc0205e58:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205e5a:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e5c:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205e5e:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e60:	4581                	li	a1,0
ffffffffc0205e62:	00000517          	auipc	a0,0x0
ffffffffc0205e66:	8bc50513          	addi	a0,a0,-1860 # ffffffffc020571e <init_main>
    nr_process ++;
ffffffffc0205e6a:	000a6697          	auipc	a3,0xa6
ffffffffc0205e6e:	58f6ab23          	sw	a5,1430(a3) # ffffffffc02ac400 <nr_process>
    current = idleproc;
ffffffffc0205e72:	000a6797          	auipc	a5,0xa6
ffffffffc0205e76:	56e7bb23          	sd	a4,1398(a5) # ffffffffc02ac3e8 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e7a:	d5eff0ef          	jal	ra,ffffffffc02053d8 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205e7e:	08a05c63          	blez	a0,ffffffffc0205f16 <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205e82:	924ff0ef          	jal	ra,ffffffffc0204fa6 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205e86:	00003597          	auipc	a1,0x3
ffffffffc0205e8a:	90258593          	addi	a1,a1,-1790 # ffffffffc0208788 <default_pmm_manager+0xa18>
    initproc = find_proc(pid);
ffffffffc0205e8e:	000a6797          	auipc	a5,0xa6
ffffffffc0205e92:	56a7b523          	sd	a0,1386(a5) # ffffffffc02ac3f8 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205e96:	87aff0ef          	jal	ra,ffffffffc0204f10 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e9a:	609c                	ld	a5,0(s1)
ffffffffc0205e9c:	cfa9                	beqz	a5,ffffffffc0205ef6 <proc_init+0x114>
ffffffffc0205e9e:	43dc                	lw	a5,4(a5)
ffffffffc0205ea0:	ebb9                	bnez	a5,ffffffffc0205ef6 <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205ea2:	000a6797          	auipc	a5,0xa6
ffffffffc0205ea6:	55678793          	addi	a5,a5,1366 # ffffffffc02ac3f8 <initproc>
ffffffffc0205eaa:	639c                	ld	a5,0(a5)
ffffffffc0205eac:	c78d                	beqz	a5,ffffffffc0205ed6 <proc_init+0xf4>
ffffffffc0205eae:	43dc                	lw	a5,4(a5)
ffffffffc0205eb0:	02879363          	bne	a5,s0,ffffffffc0205ed6 <proc_init+0xf4>
}
ffffffffc0205eb4:	60e2                	ld	ra,24(sp)
ffffffffc0205eb6:	6442                	ld	s0,16(sp)
ffffffffc0205eb8:	64a2                	ld	s1,8(sp)
ffffffffc0205eba:	6105                	addi	sp,sp,32
ffffffffc0205ebc:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205ebe:	00003617          	auipc	a2,0x3
ffffffffc0205ec2:	88a60613          	addi	a2,a2,-1910 # ffffffffc0208748 <default_pmm_manager+0x9d8>
ffffffffc0205ec6:	3d100593          	li	a1,977
ffffffffc0205eca:	00003517          	auipc	a0,0x3
ffffffffc0205ece:	97e50513          	addi	a0,a0,-1666 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc0205ed2:	b44fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205ed6:	00003697          	auipc	a3,0x3
ffffffffc0205eda:	8e268693          	addi	a3,a3,-1822 # ffffffffc02087b8 <default_pmm_manager+0xa48>
ffffffffc0205ede:	00001617          	auipc	a2,0x1
ffffffffc0205ee2:	d2a60613          	addi	a2,a2,-726 # ffffffffc0206c08 <commands+0x480>
ffffffffc0205ee6:	3e600593          	li	a1,998
ffffffffc0205eea:	00003517          	auipc	a0,0x3
ffffffffc0205eee:	95e50513          	addi	a0,a0,-1698 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc0205ef2:	b24fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205ef6:	00003697          	auipc	a3,0x3
ffffffffc0205efa:	89a68693          	addi	a3,a3,-1894 # ffffffffc0208790 <default_pmm_manager+0xa20>
ffffffffc0205efe:	00001617          	auipc	a2,0x1
ffffffffc0205f02:	d0a60613          	addi	a2,a2,-758 # ffffffffc0206c08 <commands+0x480>
ffffffffc0205f06:	3e500593          	li	a1,997
ffffffffc0205f0a:	00003517          	auipc	a0,0x3
ffffffffc0205f0e:	93e50513          	addi	a0,a0,-1730 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc0205f12:	b04fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205f16:	00003617          	auipc	a2,0x3
ffffffffc0205f1a:	85260613          	addi	a2,a2,-1966 # ffffffffc0208768 <default_pmm_manager+0x9f8>
ffffffffc0205f1e:	3df00593          	li	a1,991
ffffffffc0205f22:	00003517          	auipc	a0,0x3
ffffffffc0205f26:	92650513          	addi	a0,a0,-1754 # ffffffffc0208848 <default_pmm_manager+0xad8>
ffffffffc0205f2a:	aecfa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205f2e <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205f2e:	1141                	addi	sp,sp,-16
ffffffffc0205f30:	e022                	sd	s0,0(sp)
ffffffffc0205f32:	e406                	sd	ra,8(sp)
ffffffffc0205f34:	000a6417          	auipc	s0,0xa6
ffffffffc0205f38:	4b440413          	addi	s0,s0,1204 # ffffffffc02ac3e8 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205f3c:	6018                	ld	a4,0(s0)
ffffffffc0205f3e:	6f1c                	ld	a5,24(a4)
ffffffffc0205f40:	dffd                	beqz	a5,ffffffffc0205f3e <cpu_idle+0x10>
            schedule();
ffffffffc0205f42:	082000ef          	jal	ra,ffffffffc0205fc4 <schedule>
ffffffffc0205f46:	bfdd                	j	ffffffffc0205f3c <cpu_idle+0xe>

ffffffffc0205f48 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f48:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205f4a:	1101                	addi	sp,sp,-32
ffffffffc0205f4c:	ec06                	sd	ra,24(sp)
ffffffffc0205f4e:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f50:	478d                	li	a5,3
ffffffffc0205f52:	04f70a63          	beq	a4,a5,ffffffffc0205fa6 <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f56:	100027f3          	csrr	a5,sstatus
ffffffffc0205f5a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205f5c:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f5e:	ef8d                	bnez	a5,ffffffffc0205f98 <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f60:	4789                	li	a5,2
ffffffffc0205f62:	00f70f63          	beq	a4,a5,ffffffffc0205f80 <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0205f66:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205f68:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0205f6c:	e409                	bnez	s0,ffffffffc0205f76 <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205f6e:	60e2                	ld	ra,24(sp)
ffffffffc0205f70:	6442                	ld	s0,16(sp)
ffffffffc0205f72:	6105                	addi	sp,sp,32
ffffffffc0205f74:	8082                	ret
ffffffffc0205f76:	6442                	ld	s0,16(sp)
ffffffffc0205f78:	60e2                	ld	ra,24(sp)
ffffffffc0205f7a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205f7c:	edafa06f          	j	ffffffffc0200656 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205f80:	00003617          	auipc	a2,0x3
ffffffffc0205f84:	91860613          	addi	a2,a2,-1768 # ffffffffc0208898 <default_pmm_manager+0xb28>
ffffffffc0205f88:	45c9                	li	a1,18
ffffffffc0205f8a:	00003517          	auipc	a0,0x3
ffffffffc0205f8e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0208880 <default_pmm_manager+0xb10>
ffffffffc0205f92:	af0fa0ef          	jal	ra,ffffffffc0200282 <__warn>
ffffffffc0205f96:	bfd9                	j	ffffffffc0205f6c <wakeup_proc+0x24>
ffffffffc0205f98:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205f9a:	ec2fa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc0205f9e:	6522                	ld	a0,8(sp)
ffffffffc0205fa0:	4405                	li	s0,1
ffffffffc0205fa2:	4118                	lw	a4,0(a0)
ffffffffc0205fa4:	bf75                	j	ffffffffc0205f60 <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205fa6:	00003697          	auipc	a3,0x3
ffffffffc0205faa:	8ba68693          	addi	a3,a3,-1862 # ffffffffc0208860 <default_pmm_manager+0xaf0>
ffffffffc0205fae:	00001617          	auipc	a2,0x1
ffffffffc0205fb2:	c5a60613          	addi	a2,a2,-934 # ffffffffc0206c08 <commands+0x480>
ffffffffc0205fb6:	45a5                	li	a1,9
ffffffffc0205fb8:	00003517          	auipc	a0,0x3
ffffffffc0205fbc:	8c850513          	addi	a0,a0,-1848 # ffffffffc0208880 <default_pmm_manager+0xb10>
ffffffffc0205fc0:	a56fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205fc4 <schedule>:

void
schedule(void) {
ffffffffc0205fc4:	1141                	addi	sp,sp,-16
ffffffffc0205fc6:	e406                	sd	ra,8(sp)
ffffffffc0205fc8:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205fca:	100027f3          	csrr	a5,sstatus
ffffffffc0205fce:	8b89                	andi	a5,a5,2
ffffffffc0205fd0:	4401                	li	s0,0
ffffffffc0205fd2:	e3d1                	bnez	a5,ffffffffc0206056 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205fd4:	000a6797          	auipc	a5,0xa6
ffffffffc0205fd8:	41478793          	addi	a5,a5,1044 # ffffffffc02ac3e8 <current>
ffffffffc0205fdc:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fe0:	000a6797          	auipc	a5,0xa6
ffffffffc0205fe4:	41078793          	addi	a5,a5,1040 # ffffffffc02ac3f0 <idleproc>
ffffffffc0205fe8:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0205fea:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x7558>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fee:	04a88e63          	beq	a7,a0,ffffffffc020604a <schedule+0x86>
ffffffffc0205ff2:	0c888693          	addi	a3,a7,200
ffffffffc0205ff6:	000a6617          	auipc	a2,0xa6
ffffffffc0205ffa:	53260613          	addi	a2,a2,1330 # ffffffffc02ac528 <proc_list>
        le = last;
ffffffffc0205ffe:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0206000:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206002:	4809                	li	a6,2
    return listelm->next;
ffffffffc0206004:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0206006:	00c78863          	beq	a5,a2,ffffffffc0206016 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc020600a:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc020600e:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206012:	01070463          	beq	a4,a6,ffffffffc020601a <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0206016:	fef697e3          	bne	a3,a5,ffffffffc0206004 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020601a:	c589                	beqz	a1,ffffffffc0206024 <schedule+0x60>
ffffffffc020601c:	4198                	lw	a4,0(a1)
ffffffffc020601e:	4789                	li	a5,2
ffffffffc0206020:	00f70e63          	beq	a4,a5,ffffffffc020603c <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0206024:	451c                	lw	a5,8(a0)
ffffffffc0206026:	2785                	addiw	a5,a5,1
ffffffffc0206028:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc020602a:	00a88463          	beq	a7,a0,ffffffffc0206032 <schedule+0x6e>
            proc_run(next);
ffffffffc020602e:	f0dfe0ef          	jal	ra,ffffffffc0204f3a <proc_run>
    if (flag) {
ffffffffc0206032:	e419                	bnez	s0,ffffffffc0206040 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206034:	60a2                	ld	ra,8(sp)
ffffffffc0206036:	6402                	ld	s0,0(sp)
ffffffffc0206038:	0141                	addi	sp,sp,16
ffffffffc020603a:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020603c:	852e                	mv	a0,a1
ffffffffc020603e:	b7dd                	j	ffffffffc0206024 <schedule+0x60>
}
ffffffffc0206040:	6402                	ld	s0,0(sp)
ffffffffc0206042:	60a2                	ld	ra,8(sp)
ffffffffc0206044:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0206046:	e10fa06f          	j	ffffffffc0200656 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020604a:	000a6617          	auipc	a2,0xa6
ffffffffc020604e:	4de60613          	addi	a2,a2,1246 # ffffffffc02ac528 <proc_list>
ffffffffc0206052:	86b2                	mv	a3,a2
ffffffffc0206054:	b76d                	j	ffffffffc0205ffe <schedule+0x3a>
        intr_disable();
ffffffffc0206056:	e06fa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc020605a:	4405                	li	s0,1
ffffffffc020605c:	bfa5                	j	ffffffffc0205fd4 <schedule+0x10>

ffffffffc020605e <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc020605e:	000a6797          	auipc	a5,0xa6
ffffffffc0206062:	38a78793          	addi	a5,a5,906 # ffffffffc02ac3e8 <current>
ffffffffc0206066:	639c                	ld	a5,0(a5)
}
ffffffffc0206068:	43c8                	lw	a0,4(a5)
ffffffffc020606a:	8082                	ret

ffffffffc020606c <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc020606c:	4501                	li	a0,0
ffffffffc020606e:	8082                	ret

ffffffffc0206070 <sys_putc>:
    cputchar(c);
ffffffffc0206070:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206072:	1141                	addi	sp,sp,-16
ffffffffc0206074:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0206076:	88efa0ef          	jal	ra,ffffffffc0200104 <cputchar>
}
ffffffffc020607a:	60a2                	ld	ra,8(sp)
ffffffffc020607c:	4501                	li	a0,0
ffffffffc020607e:	0141                	addi	sp,sp,16
ffffffffc0206080:	8082                	ret

ffffffffc0206082 <sys_kill>:
    return do_kill(pid);
ffffffffc0206082:	4108                	lw	a0,0(a0)
ffffffffc0206084:	d17ff06f          	j	ffffffffc0205d9a <do_kill>

ffffffffc0206088 <sys_yield>:
    return do_yield();
ffffffffc0206088:	cc1ff06f          	j	ffffffffc0205d48 <do_yield>

ffffffffc020608c <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc020608c:	6d14                	ld	a3,24(a0)
ffffffffc020608e:	6910                	ld	a2,16(a0)
ffffffffc0206090:	650c                	ld	a1,8(a0)
ffffffffc0206092:	6108                	ld	a0,0(a0)
ffffffffc0206094:	fb2ff06f          	j	ffffffffc0205846 <do_execve>

ffffffffc0206098 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0206098:	650c                	ld	a1,8(a0)
ffffffffc020609a:	4108                	lw	a0,0(a0)
ffffffffc020609c:	cbfff06f          	j	ffffffffc0205d5a <do_wait>

ffffffffc02060a0 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02060a0:	000a6797          	auipc	a5,0xa6
ffffffffc02060a4:	34878793          	addi	a5,a5,840 # ffffffffc02ac3e8 <current>
ffffffffc02060a8:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc02060aa:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc02060ac:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02060ae:	6a0c                	ld	a1,16(a2)
ffffffffc02060b0:	f53fe06f          	j	ffffffffc0205002 <do_fork>

ffffffffc02060b4 <sys_exit>:
    return do_exit(error_code);
ffffffffc02060b4:	4108                	lw	a0,0(a0)
ffffffffc02060b6:	b72ff06f          	j	ffffffffc0205428 <do_exit>

ffffffffc02060ba <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02060ba:	715d                	addi	sp,sp,-80
ffffffffc02060bc:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060be:	000a6497          	auipc	s1,0xa6
ffffffffc02060c2:	32a48493          	addi	s1,s1,810 # ffffffffc02ac3e8 <current>
ffffffffc02060c6:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02060c8:	e0a2                	sd	s0,64(sp)
ffffffffc02060ca:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060cc:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02060ce:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060d0:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02060d2:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060d6:	0327ee63          	bltu	a5,s2,ffffffffc0206112 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02060da:	00391713          	slli	a4,s2,0x3
ffffffffc02060de:	00003797          	auipc	a5,0x3
ffffffffc02060e2:	82278793          	addi	a5,a5,-2014 # ffffffffc0208900 <syscalls>
ffffffffc02060e6:	97ba                	add	a5,a5,a4
ffffffffc02060e8:	639c                	ld	a5,0(a5)
ffffffffc02060ea:	c785                	beqz	a5,ffffffffc0206112 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02060ec:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02060ee:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02060f0:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02060f2:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02060f4:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02060f6:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02060f8:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02060fa:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02060fc:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02060fe:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206100:	0028                	addi	a0,sp,8
ffffffffc0206102:	9782                	jalr	a5
ffffffffc0206104:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0206106:	60a6                	ld	ra,72(sp)
ffffffffc0206108:	6406                	ld	s0,64(sp)
ffffffffc020610a:	74e2                	ld	s1,56(sp)
ffffffffc020610c:	7942                	ld	s2,48(sp)
ffffffffc020610e:	6161                	addi	sp,sp,80
ffffffffc0206110:	8082                	ret
    print_trapframe(tf);
ffffffffc0206112:	8522                	mv	a0,s0
ffffffffc0206114:	f36fa0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0206118:	609c                	ld	a5,0(s1)
ffffffffc020611a:	86ca                	mv	a3,s2
ffffffffc020611c:	00002617          	auipc	a2,0x2
ffffffffc0206120:	79c60613          	addi	a2,a2,1948 # ffffffffc02088b8 <default_pmm_manager+0xb48>
ffffffffc0206124:	43d8                	lw	a4,4(a5)
ffffffffc0206126:	06300593          	li	a1,99
ffffffffc020612a:	0b478793          	addi	a5,a5,180
ffffffffc020612e:	00002517          	auipc	a0,0x2
ffffffffc0206132:	7ba50513          	addi	a0,a0,1978 # ffffffffc02088e8 <default_pmm_manager+0xb78>
ffffffffc0206136:	8e0fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020613a <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020613a:	00054783          	lbu	a5,0(a0)
ffffffffc020613e:	cb91                	beqz	a5,ffffffffc0206152 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0206140:	4781                	li	a5,0
        cnt ++;
ffffffffc0206142:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0206144:	00f50733          	add	a4,a0,a5
ffffffffc0206148:	00074703          	lbu	a4,0(a4)
ffffffffc020614c:	fb7d                	bnez	a4,ffffffffc0206142 <strlen+0x8>
    }
    return cnt;
}
ffffffffc020614e:	853e                	mv	a0,a5
ffffffffc0206150:	8082                	ret
    size_t cnt = 0;
ffffffffc0206152:	4781                	li	a5,0
}
ffffffffc0206154:	853e                	mv	a0,a5
ffffffffc0206156:	8082                	ret

ffffffffc0206158 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206158:	c185                	beqz	a1,ffffffffc0206178 <strnlen+0x20>
ffffffffc020615a:	00054783          	lbu	a5,0(a0)
ffffffffc020615e:	cf89                	beqz	a5,ffffffffc0206178 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0206160:	4781                	li	a5,0
ffffffffc0206162:	a021                	j	ffffffffc020616a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206164:	00074703          	lbu	a4,0(a4)
ffffffffc0206168:	c711                	beqz	a4,ffffffffc0206174 <strnlen+0x1c>
        cnt ++;
ffffffffc020616a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020616c:	00f50733          	add	a4,a0,a5
ffffffffc0206170:	fef59ae3          	bne	a1,a5,ffffffffc0206164 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0206174:	853e                	mv	a0,a5
ffffffffc0206176:	8082                	ret
    size_t cnt = 0;
ffffffffc0206178:	4781                	li	a5,0
}
ffffffffc020617a:	853e                	mv	a0,a5
ffffffffc020617c:	8082                	ret

ffffffffc020617e <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020617e:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206180:	0585                	addi	a1,a1,1
ffffffffc0206182:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0206186:	0785                	addi	a5,a5,1
ffffffffc0206188:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020618c:	fb75                	bnez	a4,ffffffffc0206180 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020618e:	8082                	ret

ffffffffc0206190 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206190:	00054783          	lbu	a5,0(a0)
ffffffffc0206194:	0005c703          	lbu	a4,0(a1)
ffffffffc0206198:	cb91                	beqz	a5,ffffffffc02061ac <strcmp+0x1c>
ffffffffc020619a:	00e79c63          	bne	a5,a4,ffffffffc02061b2 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020619e:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02061a0:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02061a4:	0585                	addi	a1,a1,1
ffffffffc02061a6:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02061aa:	fbe5                	bnez	a5,ffffffffc020619a <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02061ac:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02061ae:	9d19                	subw	a0,a0,a4
ffffffffc02061b0:	8082                	ret
ffffffffc02061b2:	0007851b          	sext.w	a0,a5
ffffffffc02061b6:	9d19                	subw	a0,a0,a4
ffffffffc02061b8:	8082                	ret

ffffffffc02061ba <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02061ba:	00054783          	lbu	a5,0(a0)
ffffffffc02061be:	cb91                	beqz	a5,ffffffffc02061d2 <strchr+0x18>
        if (*s == c) {
ffffffffc02061c0:	00b79563          	bne	a5,a1,ffffffffc02061ca <strchr+0x10>
ffffffffc02061c4:	a809                	j	ffffffffc02061d6 <strchr+0x1c>
ffffffffc02061c6:	00b78763          	beq	a5,a1,ffffffffc02061d4 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02061ca:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02061cc:	00054783          	lbu	a5,0(a0)
ffffffffc02061d0:	fbfd                	bnez	a5,ffffffffc02061c6 <strchr+0xc>
    }
    return NULL;
ffffffffc02061d2:	4501                	li	a0,0
}
ffffffffc02061d4:	8082                	ret
ffffffffc02061d6:	8082                	ret

ffffffffc02061d8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02061d8:	ca01                	beqz	a2,ffffffffc02061e8 <memset+0x10>
ffffffffc02061da:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02061dc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02061de:	0785                	addi	a5,a5,1
ffffffffc02061e0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02061e4:	fec79de3          	bne	a5,a2,ffffffffc02061de <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02061e8:	8082                	ret

ffffffffc02061ea <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02061ea:	ca19                	beqz	a2,ffffffffc0206200 <memcpy+0x16>
ffffffffc02061ec:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02061ee:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02061f0:	0585                	addi	a1,a1,1
ffffffffc02061f2:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02061f6:	0785                	addi	a5,a5,1
ffffffffc02061f8:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02061fc:	fec59ae3          	bne	a1,a2,ffffffffc02061f0 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0206200:	8082                	ret

ffffffffc0206202 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206202:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206206:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0206208:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020620c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020620e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206212:	f022                	sd	s0,32(sp)
ffffffffc0206214:	ec26                	sd	s1,24(sp)
ffffffffc0206216:	e84a                	sd	s2,16(sp)
ffffffffc0206218:	f406                	sd	ra,40(sp)
ffffffffc020621a:	e44e                	sd	s3,8(sp)
ffffffffc020621c:	84aa                	mv	s1,a0
ffffffffc020621e:	892e                	mv	s2,a1
ffffffffc0206220:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0206224:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0206226:	03067e63          	bleu	a6,a2,ffffffffc0206262 <printnum+0x60>
ffffffffc020622a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020622c:	00805763          	blez	s0,ffffffffc020623a <printnum+0x38>
ffffffffc0206230:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0206232:	85ca                	mv	a1,s2
ffffffffc0206234:	854e                	mv	a0,s3
ffffffffc0206236:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0206238:	fc65                	bnez	s0,ffffffffc0206230 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020623a:	1a02                	slli	s4,s4,0x20
ffffffffc020623c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0206240:	00003797          	auipc	a5,0x3
ffffffffc0206244:	9e078793          	addi	a5,a5,-1568 # ffffffffc0208c20 <error_string+0xc8>
ffffffffc0206248:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020624a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020624c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206250:	70a2                	ld	ra,40(sp)
ffffffffc0206252:	69a2                	ld	s3,8(sp)
ffffffffc0206254:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206256:	85ca                	mv	a1,s2
ffffffffc0206258:	8326                	mv	t1,s1
}
ffffffffc020625a:	6942                	ld	s2,16(sp)
ffffffffc020625c:	64e2                	ld	s1,24(sp)
ffffffffc020625e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206260:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206262:	03065633          	divu	a2,a2,a6
ffffffffc0206266:	8722                	mv	a4,s0
ffffffffc0206268:	f9bff0ef          	jal	ra,ffffffffc0206202 <printnum>
ffffffffc020626c:	b7f9                	j	ffffffffc020623a <printnum+0x38>

ffffffffc020626e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020626e:	7119                	addi	sp,sp,-128
ffffffffc0206270:	f4a6                	sd	s1,104(sp)
ffffffffc0206272:	f0ca                	sd	s2,96(sp)
ffffffffc0206274:	e8d2                	sd	s4,80(sp)
ffffffffc0206276:	e4d6                	sd	s5,72(sp)
ffffffffc0206278:	e0da                	sd	s6,64(sp)
ffffffffc020627a:	fc5e                	sd	s7,56(sp)
ffffffffc020627c:	f862                	sd	s8,48(sp)
ffffffffc020627e:	f06a                	sd	s10,32(sp)
ffffffffc0206280:	fc86                	sd	ra,120(sp)
ffffffffc0206282:	f8a2                	sd	s0,112(sp)
ffffffffc0206284:	ecce                	sd	s3,88(sp)
ffffffffc0206286:	f466                	sd	s9,40(sp)
ffffffffc0206288:	ec6e                	sd	s11,24(sp)
ffffffffc020628a:	892a                	mv	s2,a0
ffffffffc020628c:	84ae                	mv	s1,a1
ffffffffc020628e:	8d32                	mv	s10,a2
ffffffffc0206290:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0206292:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206294:	00002a17          	auipc	s4,0x2
ffffffffc0206298:	76ca0a13          	addi	s4,s4,1900 # ffffffffc0208a00 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020629c:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02062a0:	00003c17          	auipc	s8,0x3
ffffffffc02062a4:	8b8c0c13          	addi	s8,s8,-1864 # ffffffffc0208b58 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062a8:	000d4503          	lbu	a0,0(s10)
ffffffffc02062ac:	02500793          	li	a5,37
ffffffffc02062b0:	001d0413          	addi	s0,s10,1
ffffffffc02062b4:	00f50e63          	beq	a0,a5,ffffffffc02062d0 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02062b8:	c521                	beqz	a0,ffffffffc0206300 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062ba:	02500993          	li	s3,37
ffffffffc02062be:	a011                	j	ffffffffc02062c2 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02062c0:	c121                	beqz	a0,ffffffffc0206300 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02062c2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062c4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02062c6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062c8:	fff44503          	lbu	a0,-1(s0)
ffffffffc02062cc:	ff351ae3          	bne	a0,s3,ffffffffc02062c0 <vprintfmt+0x52>
ffffffffc02062d0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02062d4:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02062d8:	4981                	li	s3,0
ffffffffc02062da:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02062dc:	5cfd                	li	s9,-1
ffffffffc02062de:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062e0:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02062e4:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062e6:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02062ea:	0ff6f693          	andi	a3,a3,255
ffffffffc02062ee:	00140d13          	addi	s10,s0,1
ffffffffc02062f2:	20d5e563          	bltu	a1,a3,ffffffffc02064fc <vprintfmt+0x28e>
ffffffffc02062f6:	068a                	slli	a3,a3,0x2
ffffffffc02062f8:	96d2                	add	a3,a3,s4
ffffffffc02062fa:	4294                	lw	a3,0(a3)
ffffffffc02062fc:	96d2                	add	a3,a3,s4
ffffffffc02062fe:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206300:	70e6                	ld	ra,120(sp)
ffffffffc0206302:	7446                	ld	s0,112(sp)
ffffffffc0206304:	74a6                	ld	s1,104(sp)
ffffffffc0206306:	7906                	ld	s2,96(sp)
ffffffffc0206308:	69e6                	ld	s3,88(sp)
ffffffffc020630a:	6a46                	ld	s4,80(sp)
ffffffffc020630c:	6aa6                	ld	s5,72(sp)
ffffffffc020630e:	6b06                	ld	s6,64(sp)
ffffffffc0206310:	7be2                	ld	s7,56(sp)
ffffffffc0206312:	7c42                	ld	s8,48(sp)
ffffffffc0206314:	7ca2                	ld	s9,40(sp)
ffffffffc0206316:	7d02                	ld	s10,32(sp)
ffffffffc0206318:	6de2                	ld	s11,24(sp)
ffffffffc020631a:	6109                	addi	sp,sp,128
ffffffffc020631c:	8082                	ret
    if (lflag >= 2) {
ffffffffc020631e:	4705                	li	a4,1
ffffffffc0206320:	008a8593          	addi	a1,s5,8
ffffffffc0206324:	01074463          	blt	a4,a6,ffffffffc020632c <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0206328:	26080363          	beqz	a6,ffffffffc020658e <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc020632c:	000ab603          	ld	a2,0(s5)
ffffffffc0206330:	46c1                	li	a3,16
ffffffffc0206332:	8aae                	mv	s5,a1
ffffffffc0206334:	a06d                	j	ffffffffc02063de <vprintfmt+0x170>
            goto reswitch;
ffffffffc0206336:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020633a:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020633c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020633e:	b765                	j	ffffffffc02062e6 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0206340:	000aa503          	lw	a0,0(s5)
ffffffffc0206344:	85a6                	mv	a1,s1
ffffffffc0206346:	0aa1                	addi	s5,s5,8
ffffffffc0206348:	9902                	jalr	s2
            break;
ffffffffc020634a:	bfb9                	j	ffffffffc02062a8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020634c:	4705                	li	a4,1
ffffffffc020634e:	008a8993          	addi	s3,s5,8
ffffffffc0206352:	01074463          	blt	a4,a6,ffffffffc020635a <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0206356:	22080463          	beqz	a6,ffffffffc020657e <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc020635a:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc020635e:	24044463          	bltz	s0,ffffffffc02065a6 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0206362:	8622                	mv	a2,s0
ffffffffc0206364:	8ace                	mv	s5,s3
ffffffffc0206366:	46a9                	li	a3,10
ffffffffc0206368:	a89d                	j	ffffffffc02063de <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc020636a:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020636e:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0206370:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0206372:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0206376:	8fb5                	xor	a5,a5,a3
ffffffffc0206378:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020637c:	1ad74363          	blt	a4,a3,ffffffffc0206522 <vprintfmt+0x2b4>
ffffffffc0206380:	00369793          	slli	a5,a3,0x3
ffffffffc0206384:	97e2                	add	a5,a5,s8
ffffffffc0206386:	639c                	ld	a5,0(a5)
ffffffffc0206388:	18078d63          	beqz	a5,ffffffffc0206522 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc020638c:	86be                	mv	a3,a5
ffffffffc020638e:	00000617          	auipc	a2,0x0
ffffffffc0206392:	2b260613          	addi	a2,a2,690 # ffffffffc0206640 <etext+0x2e>
ffffffffc0206396:	85a6                	mv	a1,s1
ffffffffc0206398:	854a                	mv	a0,s2
ffffffffc020639a:	240000ef          	jal	ra,ffffffffc02065da <printfmt>
ffffffffc020639e:	b729                	j	ffffffffc02062a8 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02063a0:	00144603          	lbu	a2,1(s0)
ffffffffc02063a4:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063a6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02063a8:	bf3d                	j	ffffffffc02062e6 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02063aa:	4705                	li	a4,1
ffffffffc02063ac:	008a8593          	addi	a1,s5,8
ffffffffc02063b0:	01074463          	blt	a4,a6,ffffffffc02063b8 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02063b4:	1e080263          	beqz	a6,ffffffffc0206598 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02063b8:	000ab603          	ld	a2,0(s5)
ffffffffc02063bc:	46a1                	li	a3,8
ffffffffc02063be:	8aae                	mv	s5,a1
ffffffffc02063c0:	a839                	j	ffffffffc02063de <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02063c2:	03000513          	li	a0,48
ffffffffc02063c6:	85a6                	mv	a1,s1
ffffffffc02063c8:	e03e                	sd	a5,0(sp)
ffffffffc02063ca:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02063cc:	85a6                	mv	a1,s1
ffffffffc02063ce:	07800513          	li	a0,120
ffffffffc02063d2:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02063d4:	0aa1                	addi	s5,s5,8
ffffffffc02063d6:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02063da:	6782                	ld	a5,0(sp)
ffffffffc02063dc:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02063de:	876e                	mv	a4,s11
ffffffffc02063e0:	85a6                	mv	a1,s1
ffffffffc02063e2:	854a                	mv	a0,s2
ffffffffc02063e4:	e1fff0ef          	jal	ra,ffffffffc0206202 <printnum>
            break;
ffffffffc02063e8:	b5c1                	j	ffffffffc02062a8 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02063ea:	000ab603          	ld	a2,0(s5)
ffffffffc02063ee:	0aa1                	addi	s5,s5,8
ffffffffc02063f0:	1c060663          	beqz	a2,ffffffffc02065bc <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc02063f4:	00160413          	addi	s0,a2,1
ffffffffc02063f8:	17b05c63          	blez	s11,ffffffffc0206570 <vprintfmt+0x302>
ffffffffc02063fc:	02d00593          	li	a1,45
ffffffffc0206400:	14b79263          	bne	a5,a1,ffffffffc0206544 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206404:	00064783          	lbu	a5,0(a2)
ffffffffc0206408:	0007851b          	sext.w	a0,a5
ffffffffc020640c:	c905                	beqz	a0,ffffffffc020643c <vprintfmt+0x1ce>
ffffffffc020640e:	000cc563          	bltz	s9,ffffffffc0206418 <vprintfmt+0x1aa>
ffffffffc0206412:	3cfd                	addiw	s9,s9,-1
ffffffffc0206414:	036c8263          	beq	s9,s6,ffffffffc0206438 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0206418:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020641a:	18098463          	beqz	s3,ffffffffc02065a2 <vprintfmt+0x334>
ffffffffc020641e:	3781                	addiw	a5,a5,-32
ffffffffc0206420:	18fbf163          	bleu	a5,s7,ffffffffc02065a2 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0206424:	03f00513          	li	a0,63
ffffffffc0206428:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020642a:	0405                	addi	s0,s0,1
ffffffffc020642c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206430:	3dfd                	addiw	s11,s11,-1
ffffffffc0206432:	0007851b          	sext.w	a0,a5
ffffffffc0206436:	fd61                	bnez	a0,ffffffffc020640e <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0206438:	e7b058e3          	blez	s11,ffffffffc02062a8 <vprintfmt+0x3a>
ffffffffc020643c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020643e:	85a6                	mv	a1,s1
ffffffffc0206440:	02000513          	li	a0,32
ffffffffc0206444:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206446:	e60d81e3          	beqz	s11,ffffffffc02062a8 <vprintfmt+0x3a>
ffffffffc020644a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020644c:	85a6                	mv	a1,s1
ffffffffc020644e:	02000513          	li	a0,32
ffffffffc0206452:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206454:	fe0d94e3          	bnez	s11,ffffffffc020643c <vprintfmt+0x1ce>
ffffffffc0206458:	bd81                	j	ffffffffc02062a8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020645a:	4705                	li	a4,1
ffffffffc020645c:	008a8593          	addi	a1,s5,8
ffffffffc0206460:	01074463          	blt	a4,a6,ffffffffc0206468 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0206464:	12080063          	beqz	a6,ffffffffc0206584 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0206468:	000ab603          	ld	a2,0(s5)
ffffffffc020646c:	46a9                	li	a3,10
ffffffffc020646e:	8aae                	mv	s5,a1
ffffffffc0206470:	b7bd                	j	ffffffffc02063de <vprintfmt+0x170>
ffffffffc0206472:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0206476:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020647a:	846a                	mv	s0,s10
ffffffffc020647c:	b5ad                	j	ffffffffc02062e6 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020647e:	85a6                	mv	a1,s1
ffffffffc0206480:	02500513          	li	a0,37
ffffffffc0206484:	9902                	jalr	s2
            break;
ffffffffc0206486:	b50d                	j	ffffffffc02062a8 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0206488:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020648c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206490:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206492:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0206494:	e40dd9e3          	bgez	s11,ffffffffc02062e6 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0206498:	8de6                	mv	s11,s9
ffffffffc020649a:	5cfd                	li	s9,-1
ffffffffc020649c:	b5a9                	j	ffffffffc02062e6 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020649e:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02064a2:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064a6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02064a8:	bd3d                	j	ffffffffc02062e6 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02064aa:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02064ae:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064b2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02064b4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02064b8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02064bc:	fcd56ce3          	bltu	a0,a3,ffffffffc0206494 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02064c0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02064c2:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02064c6:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02064ca:	0196873b          	addw	a4,a3,s9
ffffffffc02064ce:	0017171b          	slliw	a4,a4,0x1
ffffffffc02064d2:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02064d6:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02064da:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02064de:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02064e2:	fcd57fe3          	bleu	a3,a0,ffffffffc02064c0 <vprintfmt+0x252>
ffffffffc02064e6:	b77d                	j	ffffffffc0206494 <vprintfmt+0x226>
            if (width < 0)
ffffffffc02064e8:	fffdc693          	not	a3,s11
ffffffffc02064ec:	96fd                	srai	a3,a3,0x3f
ffffffffc02064ee:	00ddfdb3          	and	s11,s11,a3
ffffffffc02064f2:	00144603          	lbu	a2,1(s0)
ffffffffc02064f6:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064f8:	846a                	mv	s0,s10
ffffffffc02064fa:	b3f5                	j	ffffffffc02062e6 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02064fc:	85a6                	mv	a1,s1
ffffffffc02064fe:	02500513          	li	a0,37
ffffffffc0206502:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0206504:	fff44703          	lbu	a4,-1(s0)
ffffffffc0206508:	02500793          	li	a5,37
ffffffffc020650c:	8d22                	mv	s10,s0
ffffffffc020650e:	d8f70de3          	beq	a4,a5,ffffffffc02062a8 <vprintfmt+0x3a>
ffffffffc0206512:	02500713          	li	a4,37
ffffffffc0206516:	1d7d                	addi	s10,s10,-1
ffffffffc0206518:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020651c:	fee79de3          	bne	a5,a4,ffffffffc0206516 <vprintfmt+0x2a8>
ffffffffc0206520:	b361                	j	ffffffffc02062a8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0206522:	00002617          	auipc	a2,0x2
ffffffffc0206526:	7de60613          	addi	a2,a2,2014 # ffffffffc0208d00 <error_string+0x1a8>
ffffffffc020652a:	85a6                	mv	a1,s1
ffffffffc020652c:	854a                	mv	a0,s2
ffffffffc020652e:	0ac000ef          	jal	ra,ffffffffc02065da <printfmt>
ffffffffc0206532:	bb9d                	j	ffffffffc02062a8 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0206534:	00002617          	auipc	a2,0x2
ffffffffc0206538:	7c460613          	addi	a2,a2,1988 # ffffffffc0208cf8 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc020653c:	00002417          	auipc	s0,0x2
ffffffffc0206540:	7bd40413          	addi	s0,s0,1981 # ffffffffc0208cf9 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206544:	8532                	mv	a0,a2
ffffffffc0206546:	85e6                	mv	a1,s9
ffffffffc0206548:	e032                	sd	a2,0(sp)
ffffffffc020654a:	e43e                	sd	a5,8(sp)
ffffffffc020654c:	c0dff0ef          	jal	ra,ffffffffc0206158 <strnlen>
ffffffffc0206550:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0206554:	6602                	ld	a2,0(sp)
ffffffffc0206556:	01b05d63          	blez	s11,ffffffffc0206570 <vprintfmt+0x302>
ffffffffc020655a:	67a2                	ld	a5,8(sp)
ffffffffc020655c:	2781                	sext.w	a5,a5
ffffffffc020655e:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0206560:	6522                	ld	a0,8(sp)
ffffffffc0206562:	85a6                	mv	a1,s1
ffffffffc0206564:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206566:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206568:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020656a:	6602                	ld	a2,0(sp)
ffffffffc020656c:	fe0d9ae3          	bnez	s11,ffffffffc0206560 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206570:	00064783          	lbu	a5,0(a2)
ffffffffc0206574:	0007851b          	sext.w	a0,a5
ffffffffc0206578:	e8051be3          	bnez	a0,ffffffffc020640e <vprintfmt+0x1a0>
ffffffffc020657c:	b335                	j	ffffffffc02062a8 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc020657e:	000aa403          	lw	s0,0(s5)
ffffffffc0206582:	bbf1                	j	ffffffffc020635e <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0206584:	000ae603          	lwu	a2,0(s5)
ffffffffc0206588:	46a9                	li	a3,10
ffffffffc020658a:	8aae                	mv	s5,a1
ffffffffc020658c:	bd89                	j	ffffffffc02063de <vprintfmt+0x170>
ffffffffc020658e:	000ae603          	lwu	a2,0(s5)
ffffffffc0206592:	46c1                	li	a3,16
ffffffffc0206594:	8aae                	mv	s5,a1
ffffffffc0206596:	b5a1                	j	ffffffffc02063de <vprintfmt+0x170>
ffffffffc0206598:	000ae603          	lwu	a2,0(s5)
ffffffffc020659c:	46a1                	li	a3,8
ffffffffc020659e:	8aae                	mv	s5,a1
ffffffffc02065a0:	bd3d                	j	ffffffffc02063de <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02065a2:	9902                	jalr	s2
ffffffffc02065a4:	b559                	j	ffffffffc020642a <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02065a6:	85a6                	mv	a1,s1
ffffffffc02065a8:	02d00513          	li	a0,45
ffffffffc02065ac:	e03e                	sd	a5,0(sp)
ffffffffc02065ae:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02065b0:	8ace                	mv	s5,s3
ffffffffc02065b2:	40800633          	neg	a2,s0
ffffffffc02065b6:	46a9                	li	a3,10
ffffffffc02065b8:	6782                	ld	a5,0(sp)
ffffffffc02065ba:	b515                	j	ffffffffc02063de <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02065bc:	01b05663          	blez	s11,ffffffffc02065c8 <vprintfmt+0x35a>
ffffffffc02065c0:	02d00693          	li	a3,45
ffffffffc02065c4:	f6d798e3          	bne	a5,a3,ffffffffc0206534 <vprintfmt+0x2c6>
ffffffffc02065c8:	00002417          	auipc	s0,0x2
ffffffffc02065cc:	73140413          	addi	s0,s0,1841 # ffffffffc0208cf9 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065d0:	02800513          	li	a0,40
ffffffffc02065d4:	02800793          	li	a5,40
ffffffffc02065d8:	bd1d                	j	ffffffffc020640e <vprintfmt+0x1a0>

ffffffffc02065da <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065da:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02065dc:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065e0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02065e2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065e4:	ec06                	sd	ra,24(sp)
ffffffffc02065e6:	f83a                	sd	a4,48(sp)
ffffffffc02065e8:	fc3e                	sd	a5,56(sp)
ffffffffc02065ea:	e0c2                	sd	a6,64(sp)
ffffffffc02065ec:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02065ee:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02065f0:	c7fff0ef          	jal	ra,ffffffffc020626e <vprintfmt>
}
ffffffffc02065f4:	60e2                	ld	ra,24(sp)
ffffffffc02065f6:	6161                	addi	sp,sp,80
ffffffffc02065f8:	8082                	ret

ffffffffc02065fa <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02065fa:	9e3707b7          	lui	a5,0x9e370
ffffffffc02065fe:	2785                	addiw	a5,a5,1
ffffffffc0206600:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0206604:	02000793          	li	a5,32
ffffffffc0206608:	40b785bb          	subw	a1,a5,a1
}
ffffffffc020660c:	00b5553b          	srlw	a0,a0,a1
ffffffffc0206610:	8082                	ret
