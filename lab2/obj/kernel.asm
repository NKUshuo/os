
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

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


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	43260613          	addi	a2,a2,1074 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	25f010ef          	jal	ra,ffffffffc0201aac <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0201ac0 <etext+0x2>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	31a010ef          	jal	ra,ffffffffc0201384 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	4f4010ef          	jal	ra,ffffffffc020159e <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	4c0010ef          	jal	ra,ffffffffc020159e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200140:	00002517          	auipc	a0,0x2
ffffffffc0200144:	9d050513          	addi	a0,a0,-1584 # ffffffffc0201b10 <etext+0x52>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00002517          	auipc	a0,0x2
ffffffffc020015a:	9da50513          	addi	a0,a0,-1574 # ffffffffc0201b30 <etext+0x72>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00002597          	auipc	a1,0x2
ffffffffc0200166:	95c58593          	addi	a1,a1,-1700 # ffffffffc0201abe <etext>
ffffffffc020016a:	00002517          	auipc	a0,0x2
ffffffffc020016e:	9e650513          	addi	a0,a0,-1562 # ffffffffc0201b50 <etext+0x92>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	9f250513          	addi	a0,a0,-1550 # ffffffffc0201b70 <etext+0xb2>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	2e658593          	addi	a1,a1,742 # ffffffffc0206470 <end>
ffffffffc0200192:	00002517          	auipc	a0,0x2
ffffffffc0200196:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0201b90 <etext+0xd2>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00006597          	auipc	a1,0x6
ffffffffc02001a2:	6d158593          	addi	a1,a1,1745 # ffffffffc020686f <end+0x3ff>
ffffffffc02001a6:	00000797          	auipc	a5,0x0
ffffffffc02001aa:	e9078793          	addi	a5,a5,-368 # ffffffffc0200036 <kern_init>
ffffffffc02001ae:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001bc:	95be                	add	a1,a1,a5
ffffffffc02001be:	85a9                	srai	a1,a1,0xa
ffffffffc02001c0:	00002517          	auipc	a0,0x2
ffffffffc02001c4:	9f050513          	addi	a0,a0,-1552 # ffffffffc0201bb0 <etext+0xf2>
}
ffffffffc02001c8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ca:	eedff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ce <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ce:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d0:	00002617          	auipc	a2,0x2
ffffffffc02001d4:	91060613          	addi	a2,a2,-1776 # ffffffffc0201ae0 <etext+0x22>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00002517          	auipc	a0,0x2
ffffffffc02001e0:	91c50513          	addi	a0,a0,-1764 # ffffffffc0201af8 <etext+0x3a>
void print_stackframe(void) {
ffffffffc02001e4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e6:	1c6000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001ea <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ea:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ec:	00002617          	auipc	a2,0x2
ffffffffc02001f0:	ad460613          	addi	a2,a2,-1324 # ffffffffc0201cc0 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	aec58593          	addi	a1,a1,-1300 # ffffffffc0201ce0 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	aec50513          	addi	a0,a0,-1300 # ffffffffc0201ce8 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	aee60613          	addi	a2,a2,-1298 # ffffffffc0201cf8 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	b0e58593          	addi	a1,a1,-1266 # ffffffffc0201d20 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	ace50513          	addi	a0,a0,-1330 # ffffffffc0201ce8 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	b0a60613          	addi	a2,a2,-1270 # ffffffffc0201d30 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	b2258593          	addi	a1,a1,-1246 # ffffffffc0201d50 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	ab250513          	addi	a0,a0,-1358 # ffffffffc0201ce8 <commands+0x108>
ffffffffc020023e:	e79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc0200242:	60a2                	ld	ra,8(sp)
ffffffffc0200244:	4501                	li	a0,0
ffffffffc0200246:	0141                	addi	sp,sp,16
ffffffffc0200248:	8082                	ret

ffffffffc020024a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
ffffffffc020024c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024e:	ef1ff0ef          	jal	ra,ffffffffc020013e <print_kerninfo>
    return 0;
}
ffffffffc0200252:	60a2                	ld	ra,8(sp)
ffffffffc0200254:	4501                	li	a0,0
ffffffffc0200256:	0141                	addi	sp,sp,16
ffffffffc0200258:	8082                	ret

ffffffffc020025a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
ffffffffc020025c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025e:	f71ff0ef          	jal	ra,ffffffffc02001ce <print_stackframe>
    return 0;
}
ffffffffc0200262:	60a2                	ld	ra,8(sp)
ffffffffc0200264:	4501                	li	a0,0
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	8082                	ret

ffffffffc020026a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	7115                	addi	sp,sp,-224
ffffffffc020026c:	e962                	sd	s8,144(sp)
ffffffffc020026e:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200270:	00002517          	auipc	a0,0x2
ffffffffc0200274:	9b850513          	addi	a0,a0,-1608 # ffffffffc0201c28 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200278:	ed86                	sd	ra,216(sp)
ffffffffc020027a:	e9a2                	sd	s0,208(sp)
ffffffffc020027c:	e5a6                	sd	s1,200(sp)
ffffffffc020027e:	e1ca                	sd	s2,192(sp)
ffffffffc0200280:	fd4e                	sd	s3,184(sp)
ffffffffc0200282:	f952                	sd	s4,176(sp)
ffffffffc0200284:	f556                	sd	s5,168(sp)
ffffffffc0200286:	f15a                	sd	s6,160(sp)
ffffffffc0200288:	ed5e                	sd	s7,152(sp)
ffffffffc020028a:	e566                	sd	s9,136(sp)
ffffffffc020028c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	e29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200292:	00002517          	auipc	a0,0x2
ffffffffc0200296:	9be50513          	addi	a0,a0,-1602 # ffffffffc0201c50 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00002c97          	auipc	s9,0x2
ffffffffc02002ac:	938c8c93          	addi	s9,s9,-1736 # ffffffffc0201be0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00002997          	auipc	s3,0x2
ffffffffc02002b4:	9c898993          	addi	s3,s3,-1592 # ffffffffc0201c78 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00002917          	auipc	s2,0x2
ffffffffc02002bc:	9c890913          	addi	s2,s2,-1592 # ffffffffc0201c80 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00002b17          	auipc	s6,0x2
ffffffffc02002c6:	9c6b0b13          	addi	s6,s6,-1594 # ffffffffc0201c88 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00002a97          	auipc	s5,0x2
ffffffffc02002ce:	a16a8a93          	addi	s5,s5,-1514 # ffffffffc0201ce0 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	654010ef          	jal	ra,ffffffffc020192a <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	7a6010ef          	jal	ra,ffffffffc0201a8e <strchr>
ffffffffc02002ec:	c925                	beqz	a0,ffffffffc020035c <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ee:	00144583          	lbu	a1,1(s0)
ffffffffc02002f2:	00040023          	sb	zero,0(s0)
ffffffffc02002f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f8:	f5fd                	bnez	a1,ffffffffc02002e6 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002fa:	dce9                	beqz	s1,ffffffffc02002d4 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002fc:	6582                	ld	a1,0(sp)
ffffffffc02002fe:	00002d17          	auipc	s10,0x2
ffffffffc0200302:	8e2d0d13          	addi	s10,s10,-1822 # ffffffffc0201be0 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	758010ef          	jal	ra,ffffffffc0201a64 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	744010ef          	jal	ra,ffffffffc0201a64 <strcmp>
ffffffffc0200324:	f57d                	bnez	a0,ffffffffc0200312 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200326:	00141793          	slli	a5,s0,0x1
ffffffffc020032a:	97a2                	add	a5,a5,s0
ffffffffc020032c:	078e                	slli	a5,a5,0x3
ffffffffc020032e:	97e6                	add	a5,a5,s9
ffffffffc0200330:	6b9c                	ld	a5,16(a5)
ffffffffc0200332:	8662                	mv	a2,s8
ffffffffc0200334:	002c                	addi	a1,sp,8
ffffffffc0200336:	fff4851b          	addiw	a0,s1,-1
ffffffffc020033a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020033c:	f8055ce3          	bgez	a0,ffffffffc02002d4 <kmonitor+0x6a>
}
ffffffffc0200340:	60ee                	ld	ra,216(sp)
ffffffffc0200342:	644e                	ld	s0,208(sp)
ffffffffc0200344:	64ae                	ld	s1,200(sp)
ffffffffc0200346:	690e                	ld	s2,192(sp)
ffffffffc0200348:	79ea                	ld	s3,184(sp)
ffffffffc020034a:	7a4a                	ld	s4,176(sp)
ffffffffc020034c:	7aaa                	ld	s5,168(sp)
ffffffffc020034e:	7b0a                	ld	s6,160(sp)
ffffffffc0200350:	6bea                	ld	s7,152(sp)
ffffffffc0200352:	6c4a                	ld	s8,144(sp)
ffffffffc0200354:	6caa                	ld	s9,136(sp)
ffffffffc0200356:	6d0a                	ld	s10,128(sp)
ffffffffc0200358:	612d                	addi	sp,sp,224
ffffffffc020035a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020035c:	00044783          	lbu	a5,0(s0)
ffffffffc0200360:	dfc9                	beqz	a5,ffffffffc02002fa <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200362:	03448863          	beq	s1,s4,ffffffffc0200392 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200366:	00349793          	slli	a5,s1,0x3
ffffffffc020036a:	0118                	addi	a4,sp,128
ffffffffc020036c:	97ba                	add	a5,a5,a4
ffffffffc020036e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200372:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200376:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	e591                	bnez	a1,ffffffffc0200384 <kmonitor+0x11a>
ffffffffc020037a:	b749                	j	ffffffffc02002fc <kmonitor+0x92>
            buf ++;
ffffffffc020037c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	00044583          	lbu	a1,0(s0)
ffffffffc0200382:	ddad                	beqz	a1,ffffffffc02002fc <kmonitor+0x92>
ffffffffc0200384:	854a                	mv	a0,s2
ffffffffc0200386:	708010ef          	jal	ra,ffffffffc0201a8e <strchr>
ffffffffc020038a:	d96d                	beqz	a0,ffffffffc020037c <kmonitor+0x112>
ffffffffc020038c:	00044583          	lbu	a1,0(s0)
ffffffffc0200390:	bf91                	j	ffffffffc02002e4 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020039a:	b7f1                	j	ffffffffc0200366 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	90a50513          	addi	a0,a0,-1782 # ffffffffc0201ca8 <commands+0xc8>
ffffffffc02003a6:	d11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003aa:	b72d                	j	ffffffffc02002d4 <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	06430313          	addi	t1,t1,100 # ffffffffc0206410 <is_panic>
ffffffffc02003b4:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	02031c63          	bnez	t1,ffffffffc0200400 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	8432                	mv	s0,a2
ffffffffc02003d0:	00006717          	auipc	a4,0x6
ffffffffc02003d4:	04f72023          	sw	a5,64(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00002517          	auipc	a0,0x2
ffffffffc02003e2:	98250513          	addi	a0,a0,-1662 # ffffffffc0201d60 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00001517          	auipc	a0,0x1
ffffffffc02003f8:	7e450513          	addi	a0,a0,2020 # ffffffffc0201bd8 <etext+0x11a>
ffffffffc02003fc:	cbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200400:	064000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e65ff0ef          	jal	ra,ffffffffc020026a <kmonitor>
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x58>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	5e0010ef          	jal	ra,ffffffffc0201a04 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	94e50513          	addi	a0,a0,-1714 # ffffffffc0201d80 <commands+0x1a0>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	5b80106f          	j	ffffffffc0201a04 <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	5920106f          	j	ffffffffc02019e8 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	5c60106f          	j	ffffffffc0201a20 <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	30678793          	addi	a5,a5,774 # ffffffffc0200774 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00002517          	auipc	a0,0x2
ffffffffc0200488:	a1450513          	addi	a0,a0,-1516 # ffffffffc0201e98 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0201eb0 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	a2650513          	addi	a0,a0,-1498 # ffffffffc0201ec8 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	a3050513          	addi	a0,a0,-1488 # ffffffffc0201ee0 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0201ef8 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	a4450513          	addi	a0,a0,-1468 # ffffffffc0201f10 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0201f28 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	a5850513          	addi	a0,a0,-1448 # ffffffffc0201f40 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	a6250513          	addi	a0,a0,-1438 # ffffffffc0201f58 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	a6c50513          	addi	a0,a0,-1428 # ffffffffc0201f70 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	a7650513          	addi	a0,a0,-1418 # ffffffffc0201f88 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	a8050513          	addi	a0,a0,-1408 # ffffffffc0201fa0 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0201fb8 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	a9450513          	addi	a0,a0,-1388 # ffffffffc0201fd0 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0201fe8 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	aa850513          	addi	a0,a0,-1368 # ffffffffc0202000 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	ab250513          	addi	a0,a0,-1358 # ffffffffc0202018 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	abc50513          	addi	a0,a0,-1348 # ffffffffc0202030 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	ac650513          	addi	a0,a0,-1338 # ffffffffc0202048 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	ad050513          	addi	a0,a0,-1328 # ffffffffc0202060 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	ada50513          	addi	a0,a0,-1318 # ffffffffc0202078 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	ae450513          	addi	a0,a0,-1308 # ffffffffc0202090 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	aee50513          	addi	a0,a0,-1298 # ffffffffc02020a8 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	af850513          	addi	a0,a0,-1288 # ffffffffc02020c0 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	b0250513          	addi	a0,a0,-1278 # ffffffffc02020d8 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	b0c50513          	addi	a0,a0,-1268 # ffffffffc02020f0 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	b1650513          	addi	a0,a0,-1258 # ffffffffc0202108 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	b2050513          	addi	a0,a0,-1248 # ffffffffc0202120 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0202138 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	b3450513          	addi	a0,a0,-1228 # ffffffffc0202150 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	b3e50513          	addi	a0,a0,-1218 # ffffffffc0202168 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	b4450513          	addi	a0,a0,-1212 # ffffffffc0202180 <commands+0x5a0>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	b4650513          	addi	a0,a0,-1210 # ffffffffc0202198 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	b4650513          	addi	a0,a0,-1210 # ffffffffc02021b0 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	b4e50513          	addi	a0,a0,-1202 # ffffffffc02021c8 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	b5650513          	addi	a0,a0,-1194 # ffffffffc02021e0 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	b5a50513          	addi	a0,a0,-1190 # ffffffffc02021f8 <commands+0x618>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	6e070713          	addi	a4,a4,1760 # ffffffffc0201d9c <commands+0x1bc>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	76250513          	addi	a0,a0,1890 # ffffffffc0201e30 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	73650513          	addi	a0,a0,1846 # ffffffffc0201e10 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	6ea50513          	addi	a0,a0,1770 # ffffffffc0201dd0 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	75e50513          	addi	a0,a0,1886 # ffffffffc0201e50 <commands+0x270>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200706:	00006797          	auipc	a5,0x6
ffffffffc020070a:	d2a78793          	addi	a5,a5,-726 # ffffffffc0206430 <ticks>
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	02e7f733          	remu	a4,a5,a4
ffffffffc020071a:	00006697          	auipc	a3,0x6
ffffffffc020071e:	d0f6bb23          	sd	a5,-746(a3) # ffffffffc0206430 <ticks>
ffffffffc0200722:	c315                	beqz	a4,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	74e50513          	addi	a0,a0,1870 # ffffffffc0201e78 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	6ba50513          	addi	a0,a0,1722 # ffffffffc0201df0 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	71c50513          	addi	a0,a0,1820 # ffffffffc0201e68 <commands+0x288>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	961ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	0007c863          	bltz	a5,ffffffffc020076e <trap+0x14>
    switch (tf->cause) {
ffffffffc0200762:	472d                	li	a4,11
ffffffffc0200764:	00f76363          	bltu	a4,a5,ffffffffc020076a <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200768:	8082                	ret
            print_trapframe(tf);
ffffffffc020076a:	ee1ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	f3fff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200774 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200774:	14011073          	csrw	sscratch,sp
ffffffffc0200778:	712d                	addi	sp,sp,-288
ffffffffc020077a:	e002                	sd	zero,0(sp)
ffffffffc020077c:	e406                	sd	ra,8(sp)
ffffffffc020077e:	ec0e                	sd	gp,24(sp)
ffffffffc0200780:	f012                	sd	tp,32(sp)
ffffffffc0200782:	f416                	sd	t0,40(sp)
ffffffffc0200784:	f81a                	sd	t1,48(sp)
ffffffffc0200786:	fc1e                	sd	t2,56(sp)
ffffffffc0200788:	e0a2                	sd	s0,64(sp)
ffffffffc020078a:	e4a6                	sd	s1,72(sp)
ffffffffc020078c:	e8aa                	sd	a0,80(sp)
ffffffffc020078e:	ecae                	sd	a1,88(sp)
ffffffffc0200790:	f0b2                	sd	a2,96(sp)
ffffffffc0200792:	f4b6                	sd	a3,104(sp)
ffffffffc0200794:	f8ba                	sd	a4,112(sp)
ffffffffc0200796:	fcbe                	sd	a5,120(sp)
ffffffffc0200798:	e142                	sd	a6,128(sp)
ffffffffc020079a:	e546                	sd	a7,136(sp)
ffffffffc020079c:	e94a                	sd	s2,144(sp)
ffffffffc020079e:	ed4e                	sd	s3,152(sp)
ffffffffc02007a0:	f152                	sd	s4,160(sp)
ffffffffc02007a2:	f556                	sd	s5,168(sp)
ffffffffc02007a4:	f95a                	sd	s6,176(sp)
ffffffffc02007a6:	fd5e                	sd	s7,184(sp)
ffffffffc02007a8:	e1e2                	sd	s8,192(sp)
ffffffffc02007aa:	e5e6                	sd	s9,200(sp)
ffffffffc02007ac:	e9ea                	sd	s10,208(sp)
ffffffffc02007ae:	edee                	sd	s11,216(sp)
ffffffffc02007b0:	f1f2                	sd	t3,224(sp)
ffffffffc02007b2:	f5f6                	sd	t4,232(sp)
ffffffffc02007b4:	f9fa                	sd	t5,240(sp)
ffffffffc02007b6:	fdfe                	sd	t6,248(sp)
ffffffffc02007b8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007bc:	100024f3          	csrr	s1,sstatus
ffffffffc02007c0:	14102973          	csrr	s2,sepc
ffffffffc02007c4:	143029f3          	csrr	s3,stval
ffffffffc02007c8:	14202a73          	csrr	s4,scause
ffffffffc02007cc:	e822                	sd	s0,16(sp)
ffffffffc02007ce:	e226                	sd	s1,256(sp)
ffffffffc02007d0:	e64a                	sd	s2,264(sp)
ffffffffc02007d2:	ea4e                	sd	s3,272(sp)
ffffffffc02007d4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d8:	f83ff0ef          	jal	ra,ffffffffc020075a <trap>

ffffffffc02007dc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007dc:	6492                	ld	s1,256(sp)
ffffffffc02007de:	6932                	ld	s2,264(sp)
ffffffffc02007e0:	10049073          	csrw	sstatus,s1
ffffffffc02007e4:	14191073          	csrw	sepc,s2
ffffffffc02007e8:	60a2                	ld	ra,8(sp)
ffffffffc02007ea:	61e2                	ld	gp,24(sp)
ffffffffc02007ec:	7202                	ld	tp,32(sp)
ffffffffc02007ee:	72a2                	ld	t0,40(sp)
ffffffffc02007f0:	7342                	ld	t1,48(sp)
ffffffffc02007f2:	73e2                	ld	t2,56(sp)
ffffffffc02007f4:	6406                	ld	s0,64(sp)
ffffffffc02007f6:	64a6                	ld	s1,72(sp)
ffffffffc02007f8:	6546                	ld	a0,80(sp)
ffffffffc02007fa:	65e6                	ld	a1,88(sp)
ffffffffc02007fc:	7606                	ld	a2,96(sp)
ffffffffc02007fe:	76a6                	ld	a3,104(sp)
ffffffffc0200800:	7746                	ld	a4,112(sp)
ffffffffc0200802:	77e6                	ld	a5,120(sp)
ffffffffc0200804:	680a                	ld	a6,128(sp)
ffffffffc0200806:	68aa                	ld	a7,136(sp)
ffffffffc0200808:	694a                	ld	s2,144(sp)
ffffffffc020080a:	69ea                	ld	s3,152(sp)
ffffffffc020080c:	7a0a                	ld	s4,160(sp)
ffffffffc020080e:	7aaa                	ld	s5,168(sp)
ffffffffc0200810:	7b4a                	ld	s6,176(sp)
ffffffffc0200812:	7bea                	ld	s7,184(sp)
ffffffffc0200814:	6c0e                	ld	s8,192(sp)
ffffffffc0200816:	6cae                	ld	s9,200(sp)
ffffffffc0200818:	6d4e                	ld	s10,208(sp)
ffffffffc020081a:	6dee                	ld	s11,216(sp)
ffffffffc020081c:	7e0e                	ld	t3,224(sp)
ffffffffc020081e:	7eae                	ld	t4,232(sp)
ffffffffc0200820:	7f4e                	ld	t5,240(sp)
ffffffffc0200822:	7fee                	ld	t6,248(sp)
ffffffffc0200824:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200826:	10200073          	sret

ffffffffc020082a <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020082a:	00006797          	auipc	a5,0x6
ffffffffc020082e:	c0e78793          	addi	a5,a5,-1010 # ffffffffc0206438 <free_area>
ffffffffc0200832:	e79c                	sd	a5,8(a5)
ffffffffc0200834:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200836:	0007a823          	sw	zero,16(a5)
}
ffffffffc020083a:	8082                	ret

ffffffffc020083c <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	c0c56503          	lwu	a0,-1012(a0) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200844:	8082                	ret

ffffffffc0200846 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200846:	715d                	addi	sp,sp,-80
ffffffffc0200848:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020084a:	00006917          	auipc	s2,0x6
ffffffffc020084e:	bee90913          	addi	s2,s2,-1042 # ffffffffc0206438 <free_area>
ffffffffc0200852:	00893783          	ld	a5,8(s2)
ffffffffc0200856:	e486                	sd	ra,72(sp)
ffffffffc0200858:	e0a2                	sd	s0,64(sp)
ffffffffc020085a:	fc26                	sd	s1,56(sp)
ffffffffc020085c:	f44e                	sd	s3,40(sp)
ffffffffc020085e:	f052                	sd	s4,32(sp)
ffffffffc0200860:	ec56                	sd	s5,24(sp)
ffffffffc0200862:	e85a                	sd	s6,16(sp)
ffffffffc0200864:	e45e                	sd	s7,8(sp)
ffffffffc0200866:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200868:	2d278363          	beq	a5,s2,ffffffffc0200b2e <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020086c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200870:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200872:	8b05                	andi	a4,a4,1
ffffffffc0200874:	2c070163          	beqz	a4,ffffffffc0200b36 <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc0200878:	4401                	li	s0,0
ffffffffc020087a:	4481                	li	s1,0
ffffffffc020087c:	a031                	j	ffffffffc0200888 <best_fit_check+0x42>
ffffffffc020087e:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200882:	8b09                	andi	a4,a4,2
ffffffffc0200884:	2a070963          	beqz	a4,ffffffffc0200b36 <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc0200888:	ff87a703          	lw	a4,-8(a5)
ffffffffc020088c:	679c                	ld	a5,8(a5)
ffffffffc020088e:	2485                	addiw	s1,s1,1
ffffffffc0200890:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200892:	ff2796e3          	bne	a5,s2,ffffffffc020087e <best_fit_check+0x38>
ffffffffc0200896:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200898:	2ad000ef          	jal	ra,ffffffffc0201344 <nr_free_pages>
ffffffffc020089c:	37351d63          	bne	a0,s3,ffffffffc0200c16 <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02008a0:	4505                	li	a0,1
ffffffffc02008a2:	219000ef          	jal	ra,ffffffffc02012ba <alloc_pages>
ffffffffc02008a6:	8a2a                	mv	s4,a0
ffffffffc02008a8:	3a050763          	beqz	a0,ffffffffc0200c56 <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02008ac:	4505                	li	a0,1
ffffffffc02008ae:	20d000ef          	jal	ra,ffffffffc02012ba <alloc_pages>
ffffffffc02008b2:	89aa                	mv	s3,a0
ffffffffc02008b4:	38050163          	beqz	a0,ffffffffc0200c36 <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02008b8:	4505                	li	a0,1
ffffffffc02008ba:	201000ef          	jal	ra,ffffffffc02012ba <alloc_pages>
ffffffffc02008be:	8aaa                	mv	s5,a0
ffffffffc02008c0:	30050b63          	beqz	a0,ffffffffc0200bd6 <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02008c4:	293a0963          	beq	s4,s3,ffffffffc0200b56 <best_fit_check+0x310>
ffffffffc02008c8:	28aa0763          	beq	s4,a0,ffffffffc0200b56 <best_fit_check+0x310>
ffffffffc02008cc:	28a98563          	beq	s3,a0,ffffffffc0200b56 <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02008d0:	000a2783          	lw	a5,0(s4)
ffffffffc02008d4:	2a079163          	bnez	a5,ffffffffc0200b76 <best_fit_check+0x330>
ffffffffc02008d8:	0009a783          	lw	a5,0(s3)
ffffffffc02008dc:	28079d63          	bnez	a5,ffffffffc0200b76 <best_fit_check+0x330>
ffffffffc02008e0:	411c                	lw	a5,0(a0)
ffffffffc02008e2:	28079a63          	bnez	a5,ffffffffc0200b76 <best_fit_check+0x330>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008e6:	00006797          	auipc	a5,0x6
ffffffffc02008ea:	b8278793          	addi	a5,a5,-1150 # ffffffffc0206468 <pages>
ffffffffc02008ee:	639c                	ld	a5,0(a5)
ffffffffc02008f0:	00002717          	auipc	a4,0x2
ffffffffc02008f4:	92070713          	addi	a4,a4,-1760 # ffffffffc0202210 <commands+0x630>
ffffffffc02008f8:	630c                	ld	a1,0(a4)
ffffffffc02008fa:	40fa0733          	sub	a4,s4,a5
ffffffffc02008fe:	870d                	srai	a4,a4,0x3
ffffffffc0200900:	02b70733          	mul	a4,a4,a1
ffffffffc0200904:	00002697          	auipc	a3,0x2
ffffffffc0200908:	00468693          	addi	a3,a3,4 # ffffffffc0202908 <nbase>
ffffffffc020090c:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020090e:	00006697          	auipc	a3,0x6
ffffffffc0200912:	b0a68693          	addi	a3,a3,-1270 # ffffffffc0206418 <npage>
ffffffffc0200916:	6294                	ld	a3,0(a3)
ffffffffc0200918:	06b2                	slli	a3,a3,0xc
ffffffffc020091a:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc020091c:	0732                	slli	a4,a4,0xc
ffffffffc020091e:	26d77c63          	bleu	a3,a4,ffffffffc0200b96 <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200922:	40f98733          	sub	a4,s3,a5
ffffffffc0200926:	870d                	srai	a4,a4,0x3
ffffffffc0200928:	02b70733          	mul	a4,a4,a1
ffffffffc020092c:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020092e:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200930:	42d77363          	bleu	a3,a4,ffffffffc0200d56 <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200934:	40f507b3          	sub	a5,a0,a5
ffffffffc0200938:	878d                	srai	a5,a5,0x3
ffffffffc020093a:	02b787b3          	mul	a5,a5,a1
ffffffffc020093e:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200940:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200942:	3ed7fa63          	bleu	a3,a5,ffffffffc0200d36 <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc0200946:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200948:	00093c03          	ld	s8,0(s2)
ffffffffc020094c:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200950:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200954:	00006797          	auipc	a5,0x6
ffffffffc0200958:	af27b623          	sd	s2,-1300(a5) # ffffffffc0206440 <free_area+0x8>
ffffffffc020095c:	00006797          	auipc	a5,0x6
ffffffffc0200960:	ad27be23          	sd	s2,-1316(a5) # ffffffffc0206438 <free_area>
    nr_free = 0;
ffffffffc0200964:	00006797          	auipc	a5,0x6
ffffffffc0200968:	ae07a223          	sw	zero,-1308(a5) # ffffffffc0206448 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc020096c:	14f000ef          	jal	ra,ffffffffc02012ba <alloc_pages>
ffffffffc0200970:	3a051363          	bnez	a0,ffffffffc0200d16 <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc0200974:	4585                	li	a1,1
ffffffffc0200976:	8552                	mv	a0,s4
ffffffffc0200978:	187000ef          	jal	ra,ffffffffc02012fe <free_pages>
    free_page(p1);
ffffffffc020097c:	4585                	li	a1,1
ffffffffc020097e:	854e                	mv	a0,s3
ffffffffc0200980:	17f000ef          	jal	ra,ffffffffc02012fe <free_pages>
    free_page(p2);
ffffffffc0200984:	4585                	li	a1,1
ffffffffc0200986:	8556                	mv	a0,s5
ffffffffc0200988:	177000ef          	jal	ra,ffffffffc02012fe <free_pages>
    assert(nr_free == 3);
ffffffffc020098c:	01092703          	lw	a4,16(s2)
ffffffffc0200990:	478d                	li	a5,3
ffffffffc0200992:	36f71263          	bne	a4,a5,ffffffffc0200cf6 <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200996:	4505                	li	a0,1
ffffffffc0200998:	123000ef          	jal	ra,ffffffffc02012ba <alloc_pages>
ffffffffc020099c:	89aa                	mv	s3,a0
ffffffffc020099e:	32050c63          	beqz	a0,ffffffffc0200cd6 <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02009a2:	4505                	li	a0,1
ffffffffc02009a4:	117000ef          	jal	ra,ffffffffc02012ba <alloc_pages>
ffffffffc02009a8:	8aaa                	mv	s5,a0
ffffffffc02009aa:	30050663          	beqz	a0,ffffffffc0200cb6 <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02009ae:	4505                	li	a0,1
ffffffffc02009b0:	10b000ef          	jal	ra,ffffffffc02012ba <alloc_pages>
ffffffffc02009b4:	8a2a                	mv	s4,a0
ffffffffc02009b6:	2e050063          	beqz	a0,ffffffffc0200c96 <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc02009ba:	4505                	li	a0,1
ffffffffc02009bc:	0ff000ef          	jal	ra,ffffffffc02012ba <alloc_pages>
ffffffffc02009c0:	2a051b63          	bnez	a0,ffffffffc0200c76 <best_fit_check+0x430>
    free_page(p0);
ffffffffc02009c4:	4585                	li	a1,1
ffffffffc02009c6:	854e                	mv	a0,s3
ffffffffc02009c8:	137000ef          	jal	ra,ffffffffc02012fe <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02009cc:	00893783          	ld	a5,8(s2)
ffffffffc02009d0:	1f278363          	beq	a5,s2,ffffffffc0200bb6 <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc02009d4:	4505                	li	a0,1
ffffffffc02009d6:	0e5000ef          	jal	ra,ffffffffc02012ba <alloc_pages>
ffffffffc02009da:	54a99e63          	bne	s3,a0,ffffffffc0200f36 <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc02009de:	4505                	li	a0,1
ffffffffc02009e0:	0db000ef          	jal	ra,ffffffffc02012ba <alloc_pages>
ffffffffc02009e4:	52051963          	bnez	a0,ffffffffc0200f16 <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc02009e8:	01092783          	lw	a5,16(s2)
ffffffffc02009ec:	50079563          	bnez	a5,ffffffffc0200ef6 <best_fit_check+0x6b0>
    free_page(p);
ffffffffc02009f0:	854e                	mv	a0,s3
ffffffffc02009f2:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02009f4:	00006797          	auipc	a5,0x6
ffffffffc02009f8:	a587b223          	sd	s8,-1468(a5) # ffffffffc0206438 <free_area>
ffffffffc02009fc:	00006797          	auipc	a5,0x6
ffffffffc0200a00:	a577b223          	sd	s7,-1468(a5) # ffffffffc0206440 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200a04:	00006797          	auipc	a5,0x6
ffffffffc0200a08:	a567a223          	sw	s6,-1468(a5) # ffffffffc0206448 <free_area+0x10>
    free_page(p);
ffffffffc0200a0c:	0f3000ef          	jal	ra,ffffffffc02012fe <free_pages>
    free_page(p1);
ffffffffc0200a10:	4585                	li	a1,1
ffffffffc0200a12:	8556                	mv	a0,s5
ffffffffc0200a14:	0eb000ef          	jal	ra,ffffffffc02012fe <free_pages>
    free_page(p2);
ffffffffc0200a18:	4585                	li	a1,1
ffffffffc0200a1a:	8552                	mv	a0,s4
ffffffffc0200a1c:	0e3000ef          	jal	ra,ffffffffc02012fe <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200a20:	4515                	li	a0,5
ffffffffc0200a22:	099000ef          	jal	ra,ffffffffc02012ba <alloc_pages>
ffffffffc0200a26:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200a28:	4a050763          	beqz	a0,ffffffffc0200ed6 <best_fit_check+0x690>
ffffffffc0200a2c:	651c                	ld	a5,8(a0)
ffffffffc0200a2e:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200a30:	8b85                	andi	a5,a5,1
ffffffffc0200a32:	48079263          	bnez	a5,ffffffffc0200eb6 <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200a36:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200a38:	00093b03          	ld	s6,0(s2)
ffffffffc0200a3c:	00893a83          	ld	s5,8(s2)
ffffffffc0200a40:	00006797          	auipc	a5,0x6
ffffffffc0200a44:	9f27bc23          	sd	s2,-1544(a5) # ffffffffc0206438 <free_area>
ffffffffc0200a48:	00006797          	auipc	a5,0x6
ffffffffc0200a4c:	9f27bc23          	sd	s2,-1544(a5) # ffffffffc0206440 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200a50:	06b000ef          	jal	ra,ffffffffc02012ba <alloc_pages>
ffffffffc0200a54:	44051163          	bnez	a0,ffffffffc0200e96 <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200a58:	4589                	li	a1,2
ffffffffc0200a5a:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200a5e:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc0200a62:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200a66:	00006797          	auipc	a5,0x6
ffffffffc0200a6a:	9e07a123          	sw	zero,-1566(a5) # ffffffffc0206448 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200a6e:	091000ef          	jal	ra,ffffffffc02012fe <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200a72:	8562                	mv	a0,s8
ffffffffc0200a74:	4585                	li	a1,1
ffffffffc0200a76:	089000ef          	jal	ra,ffffffffc02012fe <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200a7a:	4511                	li	a0,4
ffffffffc0200a7c:	03f000ef          	jal	ra,ffffffffc02012ba <alloc_pages>
ffffffffc0200a80:	3e051b63          	bnez	a0,ffffffffc0200e76 <best_fit_check+0x630>
ffffffffc0200a84:	0309b783          	ld	a5,48(s3)
ffffffffc0200a88:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200a8a:	8b85                	andi	a5,a5,1
ffffffffc0200a8c:	3c078563          	beqz	a5,ffffffffc0200e56 <best_fit_check+0x610>
ffffffffc0200a90:	0389a703          	lw	a4,56(s3)
ffffffffc0200a94:	4789                	li	a5,2
ffffffffc0200a96:	3cf71063          	bne	a4,a5,ffffffffc0200e56 <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200a9a:	4505                	li	a0,1
ffffffffc0200a9c:	01f000ef          	jal	ra,ffffffffc02012ba <alloc_pages>
ffffffffc0200aa0:	8a2a                	mv	s4,a0
ffffffffc0200aa2:	38050a63          	beqz	a0,ffffffffc0200e36 <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200aa6:	4509                	li	a0,2
ffffffffc0200aa8:	013000ef          	jal	ra,ffffffffc02012ba <alloc_pages>
ffffffffc0200aac:	36050563          	beqz	a0,ffffffffc0200e16 <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0200ab0:	354c1363          	bne	s8,s4,ffffffffc0200df6 <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200ab4:	854e                	mv	a0,s3
ffffffffc0200ab6:	4595                	li	a1,5
ffffffffc0200ab8:	047000ef          	jal	ra,ffffffffc02012fe <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200abc:	4515                	li	a0,5
ffffffffc0200abe:	7fc000ef          	jal	ra,ffffffffc02012ba <alloc_pages>
ffffffffc0200ac2:	89aa                	mv	s3,a0
ffffffffc0200ac4:	30050963          	beqz	a0,ffffffffc0200dd6 <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0200ac8:	4505                	li	a0,1
ffffffffc0200aca:	7f0000ef          	jal	ra,ffffffffc02012ba <alloc_pages>
ffffffffc0200ace:	2e051463          	bnez	a0,ffffffffc0200db6 <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200ad2:	01092783          	lw	a5,16(s2)
ffffffffc0200ad6:	2c079063          	bnez	a5,ffffffffc0200d96 <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200ada:	4595                	li	a1,5
ffffffffc0200adc:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200ade:	00006797          	auipc	a5,0x6
ffffffffc0200ae2:	9777a523          	sw	s7,-1686(a5) # ffffffffc0206448 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200ae6:	00006797          	auipc	a5,0x6
ffffffffc0200aea:	9567b923          	sd	s6,-1710(a5) # ffffffffc0206438 <free_area>
ffffffffc0200aee:	00006797          	auipc	a5,0x6
ffffffffc0200af2:	9557b923          	sd	s5,-1710(a5) # ffffffffc0206440 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200af6:	009000ef          	jal	ra,ffffffffc02012fe <free_pages>
    return listelm->next;
ffffffffc0200afa:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200afe:	01278963          	beq	a5,s2,ffffffffc0200b10 <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200b02:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b06:	679c                	ld	a5,8(a5)
ffffffffc0200b08:	34fd                	addiw	s1,s1,-1
ffffffffc0200b0a:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b0c:	ff279be3          	bne	a5,s2,ffffffffc0200b02 <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0200b10:	26049363          	bnez	s1,ffffffffc0200d76 <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0200b14:	e06d                	bnez	s0,ffffffffc0200bf6 <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200b16:	60a6                	ld	ra,72(sp)
ffffffffc0200b18:	6406                	ld	s0,64(sp)
ffffffffc0200b1a:	74e2                	ld	s1,56(sp)
ffffffffc0200b1c:	7942                	ld	s2,48(sp)
ffffffffc0200b1e:	79a2                	ld	s3,40(sp)
ffffffffc0200b20:	7a02                	ld	s4,32(sp)
ffffffffc0200b22:	6ae2                	ld	s5,24(sp)
ffffffffc0200b24:	6b42                	ld	s6,16(sp)
ffffffffc0200b26:	6ba2                	ld	s7,8(sp)
ffffffffc0200b28:	6c02                	ld	s8,0(sp)
ffffffffc0200b2a:	6161                	addi	sp,sp,80
ffffffffc0200b2c:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b2e:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200b30:	4401                	li	s0,0
ffffffffc0200b32:	4481                	li	s1,0
ffffffffc0200b34:	b395                	j	ffffffffc0200898 <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc0200b36:	00001697          	auipc	a3,0x1
ffffffffc0200b3a:	6e268693          	addi	a3,a3,1762 # ffffffffc0202218 <commands+0x638>
ffffffffc0200b3e:	00001617          	auipc	a2,0x1
ffffffffc0200b42:	6ea60613          	addi	a2,a2,1770 # ffffffffc0202228 <commands+0x648>
ffffffffc0200b46:	11200593          	li	a1,274
ffffffffc0200b4a:	00001517          	auipc	a0,0x1
ffffffffc0200b4e:	6f650513          	addi	a0,a0,1782 # ffffffffc0202240 <commands+0x660>
ffffffffc0200b52:	85bff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b56:	00001697          	auipc	a3,0x1
ffffffffc0200b5a:	78268693          	addi	a3,a3,1922 # ffffffffc02022d8 <commands+0x6f8>
ffffffffc0200b5e:	00001617          	auipc	a2,0x1
ffffffffc0200b62:	6ca60613          	addi	a2,a2,1738 # ffffffffc0202228 <commands+0x648>
ffffffffc0200b66:	0de00593          	li	a1,222
ffffffffc0200b6a:	00001517          	auipc	a0,0x1
ffffffffc0200b6e:	6d650513          	addi	a0,a0,1750 # ffffffffc0202240 <commands+0x660>
ffffffffc0200b72:	83bff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b76:	00001697          	auipc	a3,0x1
ffffffffc0200b7a:	78a68693          	addi	a3,a3,1930 # ffffffffc0202300 <commands+0x720>
ffffffffc0200b7e:	00001617          	auipc	a2,0x1
ffffffffc0200b82:	6aa60613          	addi	a2,a2,1706 # ffffffffc0202228 <commands+0x648>
ffffffffc0200b86:	0df00593          	li	a1,223
ffffffffc0200b8a:	00001517          	auipc	a0,0x1
ffffffffc0200b8e:	6b650513          	addi	a0,a0,1718 # ffffffffc0202240 <commands+0x660>
ffffffffc0200b92:	81bff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b96:	00001697          	auipc	a3,0x1
ffffffffc0200b9a:	7aa68693          	addi	a3,a3,1962 # ffffffffc0202340 <commands+0x760>
ffffffffc0200b9e:	00001617          	auipc	a2,0x1
ffffffffc0200ba2:	68a60613          	addi	a2,a2,1674 # ffffffffc0202228 <commands+0x648>
ffffffffc0200ba6:	0e100593          	li	a1,225
ffffffffc0200baa:	00001517          	auipc	a0,0x1
ffffffffc0200bae:	69650513          	addi	a0,a0,1686 # ffffffffc0202240 <commands+0x660>
ffffffffc0200bb2:	ffaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200bb6:	00002697          	auipc	a3,0x2
ffffffffc0200bba:	81268693          	addi	a3,a3,-2030 # ffffffffc02023c8 <commands+0x7e8>
ffffffffc0200bbe:	00001617          	auipc	a2,0x1
ffffffffc0200bc2:	66a60613          	addi	a2,a2,1642 # ffffffffc0202228 <commands+0x648>
ffffffffc0200bc6:	0fa00593          	li	a1,250
ffffffffc0200bca:	00001517          	auipc	a0,0x1
ffffffffc0200bce:	67650513          	addi	a0,a0,1654 # ffffffffc0202240 <commands+0x660>
ffffffffc0200bd2:	fdaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200bd6:	00001697          	auipc	a3,0x1
ffffffffc0200bda:	6e268693          	addi	a3,a3,1762 # ffffffffc02022b8 <commands+0x6d8>
ffffffffc0200bde:	00001617          	auipc	a2,0x1
ffffffffc0200be2:	64a60613          	addi	a2,a2,1610 # ffffffffc0202228 <commands+0x648>
ffffffffc0200be6:	0dc00593          	li	a1,220
ffffffffc0200bea:	00001517          	auipc	a0,0x1
ffffffffc0200bee:	65650513          	addi	a0,a0,1622 # ffffffffc0202240 <commands+0x660>
ffffffffc0200bf2:	fbaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200bf6:	00002697          	auipc	a3,0x2
ffffffffc0200bfa:	90268693          	addi	a3,a3,-1790 # ffffffffc02024f8 <commands+0x918>
ffffffffc0200bfe:	00001617          	auipc	a2,0x1
ffffffffc0200c02:	62a60613          	addi	a2,a2,1578 # ffffffffc0202228 <commands+0x648>
ffffffffc0200c06:	15400593          	li	a1,340
ffffffffc0200c0a:	00001517          	auipc	a0,0x1
ffffffffc0200c0e:	63650513          	addi	a0,a0,1590 # ffffffffc0202240 <commands+0x660>
ffffffffc0200c12:	f9aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200c16:	00001697          	auipc	a3,0x1
ffffffffc0200c1a:	64268693          	addi	a3,a3,1602 # ffffffffc0202258 <commands+0x678>
ffffffffc0200c1e:	00001617          	auipc	a2,0x1
ffffffffc0200c22:	60a60613          	addi	a2,a2,1546 # ffffffffc0202228 <commands+0x648>
ffffffffc0200c26:	11500593          	li	a1,277
ffffffffc0200c2a:	00001517          	auipc	a0,0x1
ffffffffc0200c2e:	61650513          	addi	a0,a0,1558 # ffffffffc0202240 <commands+0x660>
ffffffffc0200c32:	f7aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c36:	00001697          	auipc	a3,0x1
ffffffffc0200c3a:	66268693          	addi	a3,a3,1634 # ffffffffc0202298 <commands+0x6b8>
ffffffffc0200c3e:	00001617          	auipc	a2,0x1
ffffffffc0200c42:	5ea60613          	addi	a2,a2,1514 # ffffffffc0202228 <commands+0x648>
ffffffffc0200c46:	0db00593          	li	a1,219
ffffffffc0200c4a:	00001517          	auipc	a0,0x1
ffffffffc0200c4e:	5f650513          	addi	a0,a0,1526 # ffffffffc0202240 <commands+0x660>
ffffffffc0200c52:	f5aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c56:	00001697          	auipc	a3,0x1
ffffffffc0200c5a:	62268693          	addi	a3,a3,1570 # ffffffffc0202278 <commands+0x698>
ffffffffc0200c5e:	00001617          	auipc	a2,0x1
ffffffffc0200c62:	5ca60613          	addi	a2,a2,1482 # ffffffffc0202228 <commands+0x648>
ffffffffc0200c66:	0da00593          	li	a1,218
ffffffffc0200c6a:	00001517          	auipc	a0,0x1
ffffffffc0200c6e:	5d650513          	addi	a0,a0,1494 # ffffffffc0202240 <commands+0x660>
ffffffffc0200c72:	f3aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200c76:	00001697          	auipc	a3,0x1
ffffffffc0200c7a:	72a68693          	addi	a3,a3,1834 # ffffffffc02023a0 <commands+0x7c0>
ffffffffc0200c7e:	00001617          	auipc	a2,0x1
ffffffffc0200c82:	5aa60613          	addi	a2,a2,1450 # ffffffffc0202228 <commands+0x648>
ffffffffc0200c86:	0f700593          	li	a1,247
ffffffffc0200c8a:	00001517          	auipc	a0,0x1
ffffffffc0200c8e:	5b650513          	addi	a0,a0,1462 # ffffffffc0202240 <commands+0x660>
ffffffffc0200c92:	f1aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c96:	00001697          	auipc	a3,0x1
ffffffffc0200c9a:	62268693          	addi	a3,a3,1570 # ffffffffc02022b8 <commands+0x6d8>
ffffffffc0200c9e:	00001617          	auipc	a2,0x1
ffffffffc0200ca2:	58a60613          	addi	a2,a2,1418 # ffffffffc0202228 <commands+0x648>
ffffffffc0200ca6:	0f500593          	li	a1,245
ffffffffc0200caa:	00001517          	auipc	a0,0x1
ffffffffc0200cae:	59650513          	addi	a0,a0,1430 # ffffffffc0202240 <commands+0x660>
ffffffffc0200cb2:	efaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cb6:	00001697          	auipc	a3,0x1
ffffffffc0200cba:	5e268693          	addi	a3,a3,1506 # ffffffffc0202298 <commands+0x6b8>
ffffffffc0200cbe:	00001617          	auipc	a2,0x1
ffffffffc0200cc2:	56a60613          	addi	a2,a2,1386 # ffffffffc0202228 <commands+0x648>
ffffffffc0200cc6:	0f400593          	li	a1,244
ffffffffc0200cca:	00001517          	auipc	a0,0x1
ffffffffc0200cce:	57650513          	addi	a0,a0,1398 # ffffffffc0202240 <commands+0x660>
ffffffffc0200cd2:	edaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cd6:	00001697          	auipc	a3,0x1
ffffffffc0200cda:	5a268693          	addi	a3,a3,1442 # ffffffffc0202278 <commands+0x698>
ffffffffc0200cde:	00001617          	auipc	a2,0x1
ffffffffc0200ce2:	54a60613          	addi	a2,a2,1354 # ffffffffc0202228 <commands+0x648>
ffffffffc0200ce6:	0f300593          	li	a1,243
ffffffffc0200cea:	00001517          	auipc	a0,0x1
ffffffffc0200cee:	55650513          	addi	a0,a0,1366 # ffffffffc0202240 <commands+0x660>
ffffffffc0200cf2:	ebaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200cf6:	00001697          	auipc	a3,0x1
ffffffffc0200cfa:	6c268693          	addi	a3,a3,1730 # ffffffffc02023b8 <commands+0x7d8>
ffffffffc0200cfe:	00001617          	auipc	a2,0x1
ffffffffc0200d02:	52a60613          	addi	a2,a2,1322 # ffffffffc0202228 <commands+0x648>
ffffffffc0200d06:	0f100593          	li	a1,241
ffffffffc0200d0a:	00001517          	auipc	a0,0x1
ffffffffc0200d0e:	53650513          	addi	a0,a0,1334 # ffffffffc0202240 <commands+0x660>
ffffffffc0200d12:	e9aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d16:	00001697          	auipc	a3,0x1
ffffffffc0200d1a:	68a68693          	addi	a3,a3,1674 # ffffffffc02023a0 <commands+0x7c0>
ffffffffc0200d1e:	00001617          	auipc	a2,0x1
ffffffffc0200d22:	50a60613          	addi	a2,a2,1290 # ffffffffc0202228 <commands+0x648>
ffffffffc0200d26:	0ec00593          	li	a1,236
ffffffffc0200d2a:	00001517          	auipc	a0,0x1
ffffffffc0200d2e:	51650513          	addi	a0,a0,1302 # ffffffffc0202240 <commands+0x660>
ffffffffc0200d32:	e7aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200d36:	00001697          	auipc	a3,0x1
ffffffffc0200d3a:	64a68693          	addi	a3,a3,1610 # ffffffffc0202380 <commands+0x7a0>
ffffffffc0200d3e:	00001617          	auipc	a2,0x1
ffffffffc0200d42:	4ea60613          	addi	a2,a2,1258 # ffffffffc0202228 <commands+0x648>
ffffffffc0200d46:	0e300593          	li	a1,227
ffffffffc0200d4a:	00001517          	auipc	a0,0x1
ffffffffc0200d4e:	4f650513          	addi	a0,a0,1270 # ffffffffc0202240 <commands+0x660>
ffffffffc0200d52:	e5aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200d56:	00001697          	auipc	a3,0x1
ffffffffc0200d5a:	60a68693          	addi	a3,a3,1546 # ffffffffc0202360 <commands+0x780>
ffffffffc0200d5e:	00001617          	auipc	a2,0x1
ffffffffc0200d62:	4ca60613          	addi	a2,a2,1226 # ffffffffc0202228 <commands+0x648>
ffffffffc0200d66:	0e200593          	li	a1,226
ffffffffc0200d6a:	00001517          	auipc	a0,0x1
ffffffffc0200d6e:	4d650513          	addi	a0,a0,1238 # ffffffffc0202240 <commands+0x660>
ffffffffc0200d72:	e3aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200d76:	00001697          	auipc	a3,0x1
ffffffffc0200d7a:	77268693          	addi	a3,a3,1906 # ffffffffc02024e8 <commands+0x908>
ffffffffc0200d7e:	00001617          	auipc	a2,0x1
ffffffffc0200d82:	4aa60613          	addi	a2,a2,1194 # ffffffffc0202228 <commands+0x648>
ffffffffc0200d86:	15300593          	li	a1,339
ffffffffc0200d8a:	00001517          	auipc	a0,0x1
ffffffffc0200d8e:	4b650513          	addi	a0,a0,1206 # ffffffffc0202240 <commands+0x660>
ffffffffc0200d92:	e1aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200d96:	00001697          	auipc	a3,0x1
ffffffffc0200d9a:	66a68693          	addi	a3,a3,1642 # ffffffffc0202400 <commands+0x820>
ffffffffc0200d9e:	00001617          	auipc	a2,0x1
ffffffffc0200da2:	48a60613          	addi	a2,a2,1162 # ffffffffc0202228 <commands+0x648>
ffffffffc0200da6:	14800593          	li	a1,328
ffffffffc0200daa:	00001517          	auipc	a0,0x1
ffffffffc0200dae:	49650513          	addi	a0,a0,1174 # ffffffffc0202240 <commands+0x660>
ffffffffc0200db2:	dfaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200db6:	00001697          	auipc	a3,0x1
ffffffffc0200dba:	5ea68693          	addi	a3,a3,1514 # ffffffffc02023a0 <commands+0x7c0>
ffffffffc0200dbe:	00001617          	auipc	a2,0x1
ffffffffc0200dc2:	46a60613          	addi	a2,a2,1130 # ffffffffc0202228 <commands+0x648>
ffffffffc0200dc6:	14200593          	li	a1,322
ffffffffc0200dca:	00001517          	auipc	a0,0x1
ffffffffc0200dce:	47650513          	addi	a0,a0,1142 # ffffffffc0202240 <commands+0x660>
ffffffffc0200dd2:	ddaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200dd6:	00001697          	auipc	a3,0x1
ffffffffc0200dda:	6f268693          	addi	a3,a3,1778 # ffffffffc02024c8 <commands+0x8e8>
ffffffffc0200dde:	00001617          	auipc	a2,0x1
ffffffffc0200de2:	44a60613          	addi	a2,a2,1098 # ffffffffc0202228 <commands+0x648>
ffffffffc0200de6:	14100593          	li	a1,321
ffffffffc0200dea:	00001517          	auipc	a0,0x1
ffffffffc0200dee:	45650513          	addi	a0,a0,1110 # ffffffffc0202240 <commands+0x660>
ffffffffc0200df2:	dbaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200df6:	00001697          	auipc	a3,0x1
ffffffffc0200dfa:	6c268693          	addi	a3,a3,1730 # ffffffffc02024b8 <commands+0x8d8>
ffffffffc0200dfe:	00001617          	auipc	a2,0x1
ffffffffc0200e02:	42a60613          	addi	a2,a2,1066 # ffffffffc0202228 <commands+0x648>
ffffffffc0200e06:	13900593          	li	a1,313
ffffffffc0200e0a:	00001517          	auipc	a0,0x1
ffffffffc0200e0e:	43650513          	addi	a0,a0,1078 # ffffffffc0202240 <commands+0x660>
ffffffffc0200e12:	d9aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200e16:	00001697          	auipc	a3,0x1
ffffffffc0200e1a:	68a68693          	addi	a3,a3,1674 # ffffffffc02024a0 <commands+0x8c0>
ffffffffc0200e1e:	00001617          	auipc	a2,0x1
ffffffffc0200e22:	40a60613          	addi	a2,a2,1034 # ffffffffc0202228 <commands+0x648>
ffffffffc0200e26:	13800593          	li	a1,312
ffffffffc0200e2a:	00001517          	auipc	a0,0x1
ffffffffc0200e2e:	41650513          	addi	a0,a0,1046 # ffffffffc0202240 <commands+0x660>
ffffffffc0200e32:	d7aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200e36:	00001697          	auipc	a3,0x1
ffffffffc0200e3a:	64a68693          	addi	a3,a3,1610 # ffffffffc0202480 <commands+0x8a0>
ffffffffc0200e3e:	00001617          	auipc	a2,0x1
ffffffffc0200e42:	3ea60613          	addi	a2,a2,1002 # ffffffffc0202228 <commands+0x648>
ffffffffc0200e46:	13700593          	li	a1,311
ffffffffc0200e4a:	00001517          	auipc	a0,0x1
ffffffffc0200e4e:	3f650513          	addi	a0,a0,1014 # ffffffffc0202240 <commands+0x660>
ffffffffc0200e52:	d5aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200e56:	00001697          	auipc	a3,0x1
ffffffffc0200e5a:	5fa68693          	addi	a3,a3,1530 # ffffffffc0202450 <commands+0x870>
ffffffffc0200e5e:	00001617          	auipc	a2,0x1
ffffffffc0200e62:	3ca60613          	addi	a2,a2,970 # ffffffffc0202228 <commands+0x648>
ffffffffc0200e66:	13500593          	li	a1,309
ffffffffc0200e6a:	00001517          	auipc	a0,0x1
ffffffffc0200e6e:	3d650513          	addi	a0,a0,982 # ffffffffc0202240 <commands+0x660>
ffffffffc0200e72:	d3aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200e76:	00001697          	auipc	a3,0x1
ffffffffc0200e7a:	5c268693          	addi	a3,a3,1474 # ffffffffc0202438 <commands+0x858>
ffffffffc0200e7e:	00001617          	auipc	a2,0x1
ffffffffc0200e82:	3aa60613          	addi	a2,a2,938 # ffffffffc0202228 <commands+0x648>
ffffffffc0200e86:	13400593          	li	a1,308
ffffffffc0200e8a:	00001517          	auipc	a0,0x1
ffffffffc0200e8e:	3b650513          	addi	a0,a0,950 # ffffffffc0202240 <commands+0x660>
ffffffffc0200e92:	d1aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e96:	00001697          	auipc	a3,0x1
ffffffffc0200e9a:	50a68693          	addi	a3,a3,1290 # ffffffffc02023a0 <commands+0x7c0>
ffffffffc0200e9e:	00001617          	auipc	a2,0x1
ffffffffc0200ea2:	38a60613          	addi	a2,a2,906 # ffffffffc0202228 <commands+0x648>
ffffffffc0200ea6:	12800593          	li	a1,296
ffffffffc0200eaa:	00001517          	auipc	a0,0x1
ffffffffc0200eae:	39650513          	addi	a0,a0,918 # ffffffffc0202240 <commands+0x660>
ffffffffc0200eb2:	cfaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200eb6:	00001697          	auipc	a3,0x1
ffffffffc0200eba:	56a68693          	addi	a3,a3,1386 # ffffffffc0202420 <commands+0x840>
ffffffffc0200ebe:	00001617          	auipc	a2,0x1
ffffffffc0200ec2:	36a60613          	addi	a2,a2,874 # ffffffffc0202228 <commands+0x648>
ffffffffc0200ec6:	11f00593          	li	a1,287
ffffffffc0200eca:	00001517          	auipc	a0,0x1
ffffffffc0200ece:	37650513          	addi	a0,a0,886 # ffffffffc0202240 <commands+0x660>
ffffffffc0200ed2:	cdaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200ed6:	00001697          	auipc	a3,0x1
ffffffffc0200eda:	53a68693          	addi	a3,a3,1338 # ffffffffc0202410 <commands+0x830>
ffffffffc0200ede:	00001617          	auipc	a2,0x1
ffffffffc0200ee2:	34a60613          	addi	a2,a2,842 # ffffffffc0202228 <commands+0x648>
ffffffffc0200ee6:	11e00593          	li	a1,286
ffffffffc0200eea:	00001517          	auipc	a0,0x1
ffffffffc0200eee:	35650513          	addi	a0,a0,854 # ffffffffc0202240 <commands+0x660>
ffffffffc0200ef2:	cbaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200ef6:	00001697          	auipc	a3,0x1
ffffffffc0200efa:	50a68693          	addi	a3,a3,1290 # ffffffffc0202400 <commands+0x820>
ffffffffc0200efe:	00001617          	auipc	a2,0x1
ffffffffc0200f02:	32a60613          	addi	a2,a2,810 # ffffffffc0202228 <commands+0x648>
ffffffffc0200f06:	10000593          	li	a1,256
ffffffffc0200f0a:	00001517          	auipc	a0,0x1
ffffffffc0200f0e:	33650513          	addi	a0,a0,822 # ffffffffc0202240 <commands+0x660>
ffffffffc0200f12:	c9aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f16:	00001697          	auipc	a3,0x1
ffffffffc0200f1a:	48a68693          	addi	a3,a3,1162 # ffffffffc02023a0 <commands+0x7c0>
ffffffffc0200f1e:	00001617          	auipc	a2,0x1
ffffffffc0200f22:	30a60613          	addi	a2,a2,778 # ffffffffc0202228 <commands+0x648>
ffffffffc0200f26:	0fe00593          	li	a1,254
ffffffffc0200f2a:	00001517          	auipc	a0,0x1
ffffffffc0200f2e:	31650513          	addi	a0,a0,790 # ffffffffc0202240 <commands+0x660>
ffffffffc0200f32:	c7aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f36:	00001697          	auipc	a3,0x1
ffffffffc0200f3a:	4aa68693          	addi	a3,a3,1194 # ffffffffc02023e0 <commands+0x800>
ffffffffc0200f3e:	00001617          	auipc	a2,0x1
ffffffffc0200f42:	2ea60613          	addi	a2,a2,746 # ffffffffc0202228 <commands+0x648>
ffffffffc0200f46:	0fd00593          	li	a1,253
ffffffffc0200f4a:	00001517          	auipc	a0,0x1
ffffffffc0200f4e:	2f650513          	addi	a0,a0,758 # ffffffffc0202240 <commands+0x660>
ffffffffc0200f52:	c5aff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200f56 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0200f56:	1141                	addi	sp,sp,-16
ffffffffc0200f58:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200f5a:	18058063          	beqz	a1,ffffffffc02010da <best_fit_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc0200f5e:	00259693          	slli	a3,a1,0x2
ffffffffc0200f62:	96ae                	add	a3,a3,a1
ffffffffc0200f64:	068e                	slli	a3,a3,0x3
ffffffffc0200f66:	96aa                	add	a3,a3,a0
ffffffffc0200f68:	02d50d63          	beq	a0,a3,ffffffffc0200fa2 <best_fit_free_pages+0x4c>
ffffffffc0200f6c:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200f6e:	8b85                	andi	a5,a5,1
ffffffffc0200f70:	14079563          	bnez	a5,ffffffffc02010ba <best_fit_free_pages+0x164>
ffffffffc0200f74:	651c                	ld	a5,8(a0)
ffffffffc0200f76:	8385                	srli	a5,a5,0x1
ffffffffc0200f78:	8b85                	andi	a5,a5,1
ffffffffc0200f7a:	14079063          	bnez	a5,ffffffffc02010ba <best_fit_free_pages+0x164>
ffffffffc0200f7e:	87aa                	mv	a5,a0
ffffffffc0200f80:	a809                	j	ffffffffc0200f92 <best_fit_free_pages+0x3c>
ffffffffc0200f82:	6798                	ld	a4,8(a5)
ffffffffc0200f84:	8b05                	andi	a4,a4,1
ffffffffc0200f86:	12071a63          	bnez	a4,ffffffffc02010ba <best_fit_free_pages+0x164>
ffffffffc0200f8a:	6798                	ld	a4,8(a5)
ffffffffc0200f8c:	8b09                	andi	a4,a4,2
ffffffffc0200f8e:	12071663          	bnez	a4,ffffffffc02010ba <best_fit_free_pages+0x164>
        p->flags = 0;
ffffffffc0200f92:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200f96:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200f9a:	02878793          	addi	a5,a5,40
ffffffffc0200f9e:	fed792e3          	bne	a5,a3,ffffffffc0200f82 <best_fit_free_pages+0x2c>
    base->property = n;            // 设置页的属性为n
ffffffffc0200fa2:	2581                	sext.w	a1,a1
ffffffffc0200fa4:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);        // 将页面设置为属性页
ffffffffc0200fa6:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200faa:	4789                	li	a5,2
ffffffffc0200fac:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;                 // 更新空闲页数
ffffffffc0200fb0:	00005697          	auipc	a3,0x5
ffffffffc0200fb4:	48868693          	addi	a3,a3,1160 # ffffffffc0206438 <free_area>
ffffffffc0200fb8:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0200fba:	669c                	ld	a5,8(a3)
ffffffffc0200fbc:	9db9                	addw	a1,a1,a4
ffffffffc0200fbe:	00005717          	auipc	a4,0x5
ffffffffc0200fc2:	48b72523          	sw	a1,1162(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0200fc6:	08d78f63          	beq	a5,a3,ffffffffc0201064 <best_fit_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0200fca:	fe878713          	addi	a4,a5,-24
ffffffffc0200fce:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0200fd0:	4801                	li	a6,0
ffffffffc0200fd2:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0200fd6:	00e56a63          	bltu	a0,a4,ffffffffc0200fea <best_fit_free_pages+0x94>
    return listelm->next;
ffffffffc0200fda:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0200fdc:	02d70563          	beq	a4,a3,ffffffffc0201006 <best_fit_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200fe0:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0200fe2:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0200fe6:	fee57ae3          	bleu	a4,a0,ffffffffc0200fda <best_fit_free_pages+0x84>
ffffffffc0200fea:	00080663          	beqz	a6,ffffffffc0200ff6 <best_fit_free_pages+0xa0>
ffffffffc0200fee:	00005817          	auipc	a6,0x5
ffffffffc0200ff2:	44b83523          	sd	a1,1098(a6) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200ff6:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200ff8:	e390                	sd	a2,0(a5)
ffffffffc0200ffa:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0200ffc:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200ffe:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0201000:	02d59163          	bne	a1,a3,ffffffffc0201022 <best_fit_free_pages+0xcc>
ffffffffc0201004:	a091                	j	ffffffffc0201048 <best_fit_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc0201006:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201008:	f114                	sd	a3,32(a0)
ffffffffc020100a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020100c:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020100e:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201010:	00d70563          	beq	a4,a3,ffffffffc020101a <best_fit_free_pages+0xc4>
ffffffffc0201014:	4805                	li	a6,1
ffffffffc0201016:	87ba                	mv	a5,a4
ffffffffc0201018:	b7e9                	j	ffffffffc0200fe2 <best_fit_free_pages+0x8c>
ffffffffc020101a:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020101c:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020101e:	02d78163          	beq	a5,a3,ffffffffc0201040 <best_fit_free_pages+0xea>
        if (p + p->property == base){
ffffffffc0201022:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201026:	fe858613          	addi	a2,a1,-24
        if (p + p->property == base){
ffffffffc020102a:	02081713          	slli	a4,a6,0x20
ffffffffc020102e:	9301                	srli	a4,a4,0x20
ffffffffc0201030:	00271793          	slli	a5,a4,0x2
ffffffffc0201034:	97ba                	add	a5,a5,a4
ffffffffc0201036:	078e                	slli	a5,a5,0x3
ffffffffc0201038:	97b2                	add	a5,a5,a2
ffffffffc020103a:	02f50e63          	beq	a0,a5,ffffffffc0201076 <best_fit_free_pages+0x120>
ffffffffc020103e:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201040:	fe878713          	addi	a4,a5,-24
ffffffffc0201044:	00d78d63          	beq	a5,a3,ffffffffc020105e <best_fit_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0201048:	490c                	lw	a1,16(a0)
ffffffffc020104a:	02059613          	slli	a2,a1,0x20
ffffffffc020104e:	9201                	srli	a2,a2,0x20
ffffffffc0201050:	00261693          	slli	a3,a2,0x2
ffffffffc0201054:	96b2                	add	a3,a3,a2
ffffffffc0201056:	068e                	slli	a3,a3,0x3
ffffffffc0201058:	96aa                	add	a3,a3,a0
ffffffffc020105a:	04d70063          	beq	a4,a3,ffffffffc020109a <best_fit_free_pages+0x144>
}
ffffffffc020105e:	60a2                	ld	ra,8(sp)
ffffffffc0201060:	0141                	addi	sp,sp,16
ffffffffc0201062:	8082                	ret
ffffffffc0201064:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201066:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020106a:	e398                	sd	a4,0(a5)
ffffffffc020106c:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020106e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201070:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201072:	0141                	addi	sp,sp,16
ffffffffc0201074:	8082                	ret
            p->property += base->property;
ffffffffc0201076:	491c                	lw	a5,16(a0)
ffffffffc0201078:	0107883b          	addw	a6,a5,a6
ffffffffc020107c:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201080:	57f5                	li	a5,-3
ffffffffc0201082:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201086:	01853803          	ld	a6,24(a0)
ffffffffc020108a:	7118                	ld	a4,32(a0)
            base = p;
ffffffffc020108c:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020108e:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201092:	659c                	ld	a5,8(a1)
ffffffffc0201094:	01073023          	sd	a6,0(a4)
ffffffffc0201098:	b765                	j	ffffffffc0201040 <best_fit_free_pages+0xea>
            base->property += p->property;
ffffffffc020109a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020109e:	ff078693          	addi	a3,a5,-16
ffffffffc02010a2:	9db9                	addw	a1,a1,a4
ffffffffc02010a4:	c90c                	sw	a1,16(a0)
ffffffffc02010a6:	5775                	li	a4,-3
ffffffffc02010a8:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02010ac:	6398                	ld	a4,0(a5)
ffffffffc02010ae:	679c                	ld	a5,8(a5)
}
ffffffffc02010b0:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02010b2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02010b4:	e398                	sd	a4,0(a5)
ffffffffc02010b6:	0141                	addi	sp,sp,16
ffffffffc02010b8:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02010ba:	00001697          	auipc	a3,0x1
ffffffffc02010be:	44e68693          	addi	a3,a3,1102 # ffffffffc0202508 <commands+0x928>
ffffffffc02010c2:	00001617          	auipc	a2,0x1
ffffffffc02010c6:	16660613          	addi	a2,a2,358 # ffffffffc0202228 <commands+0x648>
ffffffffc02010ca:	09b00593          	li	a1,155
ffffffffc02010ce:	00001517          	auipc	a0,0x1
ffffffffc02010d2:	17250513          	addi	a0,a0,370 # ffffffffc0202240 <commands+0x660>
ffffffffc02010d6:	ad6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02010da:	00001697          	auipc	a3,0x1
ffffffffc02010de:	45668693          	addi	a3,a3,1110 # ffffffffc0202530 <commands+0x950>
ffffffffc02010e2:	00001617          	auipc	a2,0x1
ffffffffc02010e6:	14660613          	addi	a2,a2,326 # ffffffffc0202228 <commands+0x648>
ffffffffc02010ea:	09800593          	li	a1,152
ffffffffc02010ee:	00001517          	auipc	a0,0x1
ffffffffc02010f2:	15250513          	addi	a0,a0,338 # ffffffffc0202240 <commands+0x660>
ffffffffc02010f6:	ab6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02010fa <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc02010fa:	c55d                	beqz	a0,ffffffffc02011a8 <best_fit_alloc_pages+0xae>
    if (n > nr_free) {
ffffffffc02010fc:	00005617          	auipc	a2,0x5
ffffffffc0201100:	33c60613          	addi	a2,a2,828 # ffffffffc0206438 <free_area>
ffffffffc0201104:	01062803          	lw	a6,16(a2)
ffffffffc0201108:	86aa                	mv	a3,a0
ffffffffc020110a:	02081793          	slli	a5,a6,0x20
ffffffffc020110e:	9381                	srli	a5,a5,0x20
ffffffffc0201110:	08a7ea63          	bltu	a5,a0,ffffffffc02011a4 <best_fit_alloc_pages+0xaa>
    size_t smallest_gap = (size_t) -1; // 记录最小的超出的空闲空间，初始化为最大的size_t值
ffffffffc0201114:	557d                	li	a0,-1
    list_entry_t *best_fit = NULL; // 记录最佳匹配
ffffffffc0201116:	4581                	li	a1,0
    list_entry_t *le = &free_list;
ffffffffc0201118:	87b2                	mv	a5,a2
    return listelm->next;
ffffffffc020111a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020111c:	00c78e63          	beq	a5,a2,ffffffffc0201138 <best_fit_alloc_pages+0x3e>
        if (p->property >= n && (p->property - n) < smallest_gap) {
ffffffffc0201120:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0201124:	fed76be3          	bltu	a4,a3,ffffffffc020111a <best_fit_alloc_pages+0x20>
ffffffffc0201128:	8f15                	sub	a4,a4,a3
ffffffffc020112a:	fea778e3          	bleu	a0,a4,ffffffffc020111a <best_fit_alloc_pages+0x20>
ffffffffc020112e:	85be                	mv	a1,a5
ffffffffc0201130:	679c                	ld	a5,8(a5)
ffffffffc0201132:	853a                	mv	a0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201134:	fec796e3          	bne	a5,a2,ffffffffc0201120 <best_fit_alloc_pages+0x26>
        return NULL;
ffffffffc0201138:	4501                	li	a0,0
    if (best_fit != NULL) {
ffffffffc020113a:	c5b5                	beqz	a1,ffffffffc02011a6 <best_fit_alloc_pages+0xac>
    __list_del(listelm->prev, listelm->next);
ffffffffc020113c:	6598                	ld	a4,8(a1)
    return listelm->prev;
ffffffffc020113e:	6190                	ld	a2,0(a1)
        if (page->property > n) {
ffffffffc0201140:	ff85a883          	lw	a7,-8(a1)
        struct Page *page = le2page(best_fit, page_link);
ffffffffc0201144:	fe858513          	addi	a0,a1,-24
    prev->next = next;
ffffffffc0201148:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc020114a:	e310                	sd	a2,0(a4)
        if (page->property > n) {
ffffffffc020114c:	02089713          	slli	a4,a7,0x20
ffffffffc0201150:	9301                	srli	a4,a4,0x20
ffffffffc0201152:	0006831b          	sext.w	t1,a3
ffffffffc0201156:	02e6fb63          	bleu	a4,a3,ffffffffc020118c <best_fit_alloc_pages+0x92>
            struct Page *p = page + n;
ffffffffc020115a:	00269713          	slli	a4,a3,0x2
ffffffffc020115e:	9736                	add	a4,a4,a3
ffffffffc0201160:	070e                	slli	a4,a4,0x3
ffffffffc0201162:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201164:	406888bb          	subw	a7,a7,t1
ffffffffc0201168:	01172823          	sw	a7,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020116c:	4689                	li	a3,2
ffffffffc020116e:	00870813          	addi	a6,a4,8
ffffffffc0201172:	40d8302f          	amoor.d	zero,a3,(a6)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201176:	6614                	ld	a3,8(a2)
            list_add(prev, &(p->page_link));
ffffffffc0201178:	01870893          	addi	a7,a4,24
    prev->next = next->prev = elm;
ffffffffc020117c:	0107a803          	lw	a6,16(a5)
ffffffffc0201180:	0116b023          	sd	a7,0(a3)
ffffffffc0201184:	01163423          	sd	a7,8(a2)
    elm->next = next;
ffffffffc0201188:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc020118a:	ef10                	sd	a2,24(a4)
        nr_free -= n;
ffffffffc020118c:	4068083b          	subw	a6,a6,t1
ffffffffc0201190:	00005797          	auipc	a5,0x5
ffffffffc0201194:	2b07ac23          	sw	a6,696(a5) # ffffffffc0206448 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201198:	57f5                	li	a5,-3
ffffffffc020119a:	ff058713          	addi	a4,a1,-16
ffffffffc020119e:	60f7302f          	amoand.d	zero,a5,(a4)
        return page;
ffffffffc02011a2:	8082                	ret
        return NULL;
ffffffffc02011a4:	4501                	li	a0,0
}
ffffffffc02011a6:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02011a8:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02011aa:	00001697          	auipc	a3,0x1
ffffffffc02011ae:	38668693          	addi	a3,a3,902 # ffffffffc0202530 <commands+0x950>
ffffffffc02011b2:	00001617          	auipc	a2,0x1
ffffffffc02011b6:	07660613          	addi	a2,a2,118 # ffffffffc0202228 <commands+0x648>
ffffffffc02011ba:	06a00593          	li	a1,106
ffffffffc02011be:	00001517          	auipc	a0,0x1
ffffffffc02011c2:	08250513          	addi	a0,a0,130 # ffffffffc0202240 <commands+0x660>
best_fit_alloc_pages(size_t n) {
ffffffffc02011c6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011c8:	9e4ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02011cc <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc02011cc:	1141                	addi	sp,sp,-16
ffffffffc02011ce:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011d0:	c5e9                	beqz	a1,ffffffffc020129a <best_fit_init_memmap+0xce>
    for (; p != base + n; p ++) {
ffffffffc02011d2:	00259693          	slli	a3,a1,0x2
ffffffffc02011d6:	96ae                	add	a3,a3,a1
ffffffffc02011d8:	068e                	slli	a3,a3,0x3
ffffffffc02011da:	96aa                	add	a3,a3,a0
ffffffffc02011dc:	02d50463          	beq	a0,a3,ffffffffc0201204 <best_fit_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02011e0:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02011e2:	87aa                	mv	a5,a0
ffffffffc02011e4:	8b05                	andi	a4,a4,1
ffffffffc02011e6:	e709                	bnez	a4,ffffffffc02011f0 <best_fit_init_memmap+0x24>
ffffffffc02011e8:	a849                	j	ffffffffc020127a <best_fit_init_memmap+0xae>
ffffffffc02011ea:	6798                	ld	a4,8(a5)
ffffffffc02011ec:	8b05                	andi	a4,a4,1
ffffffffc02011ee:	c751                	beqz	a4,ffffffffc020127a <best_fit_init_memmap+0xae>
        p->flags=p->property=0;
ffffffffc02011f0:	0007a823          	sw	zero,16(a5)
ffffffffc02011f4:	0007b423          	sd	zero,8(a5)
ffffffffc02011f8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02011fc:	02878793          	addi	a5,a5,40
ffffffffc0201200:	fed795e3          	bne	a5,a3,ffffffffc02011ea <best_fit_init_memmap+0x1e>
    base->property = n;
ffffffffc0201204:	2581                	sext.w	a1,a1
ffffffffc0201206:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201208:	4789                	li	a5,2
ffffffffc020120a:	00850713          	addi	a4,a0,8
ffffffffc020120e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201212:	00005717          	auipc	a4,0x5
ffffffffc0201216:	22670713          	addi	a4,a4,550 # ffffffffc0206438 <free_area>
ffffffffc020121a:	4b14                	lw	a3,16(a4)
    return list->next == list;
ffffffffc020121c:	671c                	ld	a5,8(a4)
ffffffffc020121e:	01850613          	addi	a2,a0,24
ffffffffc0201222:	9db5                	addw	a1,a1,a3
ffffffffc0201224:	00005697          	auipc	a3,0x5
ffffffffc0201228:	22b6a223          	sw	a1,548(a3) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020122c:	02e78e63          	beq	a5,a4,ffffffffc0201268 <best_fit_init_memmap+0x9c>
            struct Page* page = le2page(le, page_link);
ffffffffc0201230:	fe878693          	addi	a3,a5,-24
            if(base < page){
ffffffffc0201234:	00d57d63          	bleu	a3,a0,ffffffffc020124e <best_fit_init_memmap+0x82>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201238:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc020123a:	e390                	sd	a2,0(a5)
ffffffffc020123c:	e690                	sd	a2,8(a3)
    elm->next = next;
ffffffffc020123e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201240:	679c                	ld	a5,8(a5)
ffffffffc0201242:	ed14                	sd	a3,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201244:	fee796e3          	bne	a5,a4,ffffffffc0201230 <best_fit_init_memmap+0x64>
}
ffffffffc0201248:	60a2                	ld	ra,8(sp)
ffffffffc020124a:	0141                	addi	sp,sp,16
ffffffffc020124c:	8082                	ret
    return listelm->next;
ffffffffc020124e:	6794                	ld	a3,8(a5)
            else if(list_next(le) == &free_list){
ffffffffc0201250:	00e68463          	beq	a3,a4,ffffffffc0201258 <best_fit_init_memmap+0x8c>
ffffffffc0201254:	87b6                	mv	a5,a3
ffffffffc0201256:	bfe9                	j	ffffffffc0201230 <best_fit_init_memmap+0x64>
    prev->next = next->prev = elm;
ffffffffc0201258:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020125a:	f118                	sd	a4,32(a0)
    elm->prev = prev;
ffffffffc020125c:	ed1c                	sd	a5,24(a0)
ffffffffc020125e:	679c                	ld	a5,8(a5)
    prev->next = next->prev = elm;
ffffffffc0201260:	e310                	sd	a2,0(a4)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201262:	fce797e3          	bne	a5,a4,ffffffffc0201230 <best_fit_init_memmap+0x64>
ffffffffc0201266:	b7cd                	j	ffffffffc0201248 <best_fit_init_memmap+0x7c>
}
ffffffffc0201268:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020126a:	01850713          	addi	a4,a0,24
ffffffffc020126e:	e398                	sd	a4,0(a5)
ffffffffc0201270:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201272:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201274:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201276:	0141                	addi	sp,sp,16
ffffffffc0201278:	8082                	ret
        assert(PageReserved(p));
ffffffffc020127a:	00001697          	auipc	a3,0x1
ffffffffc020127e:	2be68693          	addi	a3,a3,702 # ffffffffc0202538 <commands+0x958>
ffffffffc0201282:	00001617          	auipc	a2,0x1
ffffffffc0201286:	fa660613          	addi	a2,a2,-90 # ffffffffc0202228 <commands+0x648>
ffffffffc020128a:	04a00593          	li	a1,74
ffffffffc020128e:	00001517          	auipc	a0,0x1
ffffffffc0201292:	fb250513          	addi	a0,a0,-78 # ffffffffc0202240 <commands+0x660>
ffffffffc0201296:	916ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc020129a:	00001697          	auipc	a3,0x1
ffffffffc020129e:	29668693          	addi	a3,a3,662 # ffffffffc0202530 <commands+0x950>
ffffffffc02012a2:	00001617          	auipc	a2,0x1
ffffffffc02012a6:	f8660613          	addi	a2,a2,-122 # ffffffffc0202228 <commands+0x648>
ffffffffc02012aa:	04700593          	li	a1,71
ffffffffc02012ae:	00001517          	auipc	a0,0x1
ffffffffc02012b2:	f9250513          	addi	a0,a0,-110 # ffffffffc0202240 <commands+0x660>
ffffffffc02012b6:	8f6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02012ba <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012ba:	100027f3          	csrr	a5,sstatus
ffffffffc02012be:	8b89                	andi	a5,a5,2
ffffffffc02012c0:	eb89                	bnez	a5,ffffffffc02012d2 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02012c2:	00005797          	auipc	a5,0x5
ffffffffc02012c6:	19678793          	addi	a5,a5,406 # ffffffffc0206458 <pmm_manager>
ffffffffc02012ca:	639c                	ld	a5,0(a5)
ffffffffc02012cc:	0187b303          	ld	t1,24(a5)
ffffffffc02012d0:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc02012d2:	1141                	addi	sp,sp,-16
ffffffffc02012d4:	e406                	sd	ra,8(sp)
ffffffffc02012d6:	e022                	sd	s0,0(sp)
ffffffffc02012d8:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02012da:	98aff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02012de:	00005797          	auipc	a5,0x5
ffffffffc02012e2:	17a78793          	addi	a5,a5,378 # ffffffffc0206458 <pmm_manager>
ffffffffc02012e6:	639c                	ld	a5,0(a5)
ffffffffc02012e8:	8522                	mv	a0,s0
ffffffffc02012ea:	6f9c                	ld	a5,24(a5)
ffffffffc02012ec:	9782                	jalr	a5
ffffffffc02012ee:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02012f0:	96eff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02012f4:	8522                	mv	a0,s0
ffffffffc02012f6:	60a2                	ld	ra,8(sp)
ffffffffc02012f8:	6402                	ld	s0,0(sp)
ffffffffc02012fa:	0141                	addi	sp,sp,16
ffffffffc02012fc:	8082                	ret

ffffffffc02012fe <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012fe:	100027f3          	csrr	a5,sstatus
ffffffffc0201302:	8b89                	andi	a5,a5,2
ffffffffc0201304:	eb89                	bnez	a5,ffffffffc0201316 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201306:	00005797          	auipc	a5,0x5
ffffffffc020130a:	15278793          	addi	a5,a5,338 # ffffffffc0206458 <pmm_manager>
ffffffffc020130e:	639c                	ld	a5,0(a5)
ffffffffc0201310:	0207b303          	ld	t1,32(a5)
ffffffffc0201314:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201316:	1101                	addi	sp,sp,-32
ffffffffc0201318:	ec06                	sd	ra,24(sp)
ffffffffc020131a:	e822                	sd	s0,16(sp)
ffffffffc020131c:	e426                	sd	s1,8(sp)
ffffffffc020131e:	842a                	mv	s0,a0
ffffffffc0201320:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201322:	942ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201326:	00005797          	auipc	a5,0x5
ffffffffc020132a:	13278793          	addi	a5,a5,306 # ffffffffc0206458 <pmm_manager>
ffffffffc020132e:	639c                	ld	a5,0(a5)
ffffffffc0201330:	85a6                	mv	a1,s1
ffffffffc0201332:	8522                	mv	a0,s0
ffffffffc0201334:	739c                	ld	a5,32(a5)
ffffffffc0201336:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201338:	6442                	ld	s0,16(sp)
ffffffffc020133a:	60e2                	ld	ra,24(sp)
ffffffffc020133c:	64a2                	ld	s1,8(sp)
ffffffffc020133e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201340:	91eff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0201344 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201344:	100027f3          	csrr	a5,sstatus
ffffffffc0201348:	8b89                	andi	a5,a5,2
ffffffffc020134a:	eb89                	bnez	a5,ffffffffc020135c <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020134c:	00005797          	auipc	a5,0x5
ffffffffc0201350:	10c78793          	addi	a5,a5,268 # ffffffffc0206458 <pmm_manager>
ffffffffc0201354:	639c                	ld	a5,0(a5)
ffffffffc0201356:	0287b303          	ld	t1,40(a5)
ffffffffc020135a:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc020135c:	1141                	addi	sp,sp,-16
ffffffffc020135e:	e406                	sd	ra,8(sp)
ffffffffc0201360:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201362:	902ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201366:	00005797          	auipc	a5,0x5
ffffffffc020136a:	0f278793          	addi	a5,a5,242 # ffffffffc0206458 <pmm_manager>
ffffffffc020136e:	639c                	ld	a5,0(a5)
ffffffffc0201370:	779c                	ld	a5,40(a5)
ffffffffc0201372:	9782                	jalr	a5
ffffffffc0201374:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201376:	8e8ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc020137a:	8522                	mv	a0,s0
ffffffffc020137c:	60a2                	ld	ra,8(sp)
ffffffffc020137e:	6402                	ld	s0,0(sp)
ffffffffc0201380:	0141                	addi	sp,sp,16
ffffffffc0201382:	8082                	ret

ffffffffc0201384 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201384:	00001797          	auipc	a5,0x1
ffffffffc0201388:	1c478793          	addi	a5,a5,452 # ffffffffc0202548 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020138c:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020138e:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201390:	00001517          	auipc	a0,0x1
ffffffffc0201394:	20850513          	addi	a0,a0,520 # ffffffffc0202598 <best_fit_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc0201398:	ec06                	sd	ra,24(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020139a:	00005717          	auipc	a4,0x5
ffffffffc020139e:	0af73f23          	sd	a5,190(a4) # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc02013a2:	e822                	sd	s0,16(sp)
ffffffffc02013a4:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013a6:	00005417          	auipc	s0,0x5
ffffffffc02013aa:	0b240413          	addi	s0,s0,178 # ffffffffc0206458 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013ae:	d09fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc02013b2:	601c                	ld	a5,0(s0)
ffffffffc02013b4:	679c                	ld	a5,8(a5)
ffffffffc02013b6:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013b8:	57f5                	li	a5,-3
ffffffffc02013ba:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02013bc:	00001517          	auipc	a0,0x1
ffffffffc02013c0:	1f450513          	addi	a0,a0,500 # ffffffffc02025b0 <best_fit_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013c4:	00005717          	auipc	a4,0x5
ffffffffc02013c8:	08f73e23          	sd	a5,156(a4) # ffffffffc0206460 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02013cc:	cebfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02013d0:	46c5                	li	a3,17
ffffffffc02013d2:	06ee                	slli	a3,a3,0x1b
ffffffffc02013d4:	40100613          	li	a2,1025
ffffffffc02013d8:	16fd                	addi	a3,a3,-1
ffffffffc02013da:	0656                	slli	a2,a2,0x15
ffffffffc02013dc:	07e005b7          	lui	a1,0x7e00
ffffffffc02013e0:	00001517          	auipc	a0,0x1
ffffffffc02013e4:	1e850513          	addi	a0,a0,488 # ffffffffc02025c8 <best_fit_pmm_manager+0x80>
ffffffffc02013e8:	ccffe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013ec:	777d                	lui	a4,0xfffff
ffffffffc02013ee:	00006797          	auipc	a5,0x6
ffffffffc02013f2:	08178793          	addi	a5,a5,129 # ffffffffc020746f <end+0xfff>
ffffffffc02013f6:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02013f8:	00088737          	lui	a4,0x88
ffffffffc02013fc:	00005697          	auipc	a3,0x5
ffffffffc0201400:	00e6be23          	sd	a4,28(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201404:	4601                	li	a2,0
ffffffffc0201406:	00005717          	auipc	a4,0x5
ffffffffc020140a:	06f73123          	sd	a5,98(a4) # ffffffffc0206468 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020140e:	4681                	li	a3,0
ffffffffc0201410:	00005897          	auipc	a7,0x5
ffffffffc0201414:	00888893          	addi	a7,a7,8 # ffffffffc0206418 <npage>
ffffffffc0201418:	00005597          	auipc	a1,0x5
ffffffffc020141c:	05058593          	addi	a1,a1,80 # ffffffffc0206468 <pages>
ffffffffc0201420:	4805                	li	a6,1
ffffffffc0201422:	fff80537          	lui	a0,0xfff80
ffffffffc0201426:	a011                	j	ffffffffc020142a <pmm_init+0xa6>
ffffffffc0201428:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc020142a:	97b2                	add	a5,a5,a2
ffffffffc020142c:	07a1                	addi	a5,a5,8
ffffffffc020142e:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201432:	0008b703          	ld	a4,0(a7)
ffffffffc0201436:	0685                	addi	a3,a3,1
ffffffffc0201438:	02860613          	addi	a2,a2,40
ffffffffc020143c:	00a707b3          	add	a5,a4,a0
ffffffffc0201440:	fef6e4e3          	bltu	a3,a5,ffffffffc0201428 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201444:	6190                	ld	a2,0(a1)
ffffffffc0201446:	00271793          	slli	a5,a4,0x2
ffffffffc020144a:	97ba                	add	a5,a5,a4
ffffffffc020144c:	fec006b7          	lui	a3,0xfec00
ffffffffc0201450:	078e                	slli	a5,a5,0x3
ffffffffc0201452:	96b2                	add	a3,a3,a2
ffffffffc0201454:	96be                	add	a3,a3,a5
ffffffffc0201456:	c02007b7          	lui	a5,0xc0200
ffffffffc020145a:	08f6e863          	bltu	a3,a5,ffffffffc02014ea <pmm_init+0x166>
ffffffffc020145e:	00005497          	auipc	s1,0x5
ffffffffc0201462:	00248493          	addi	s1,s1,2 # ffffffffc0206460 <va_pa_offset>
ffffffffc0201466:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0201468:	45c5                	li	a1,17
ffffffffc020146a:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020146c:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc020146e:	04b6e963          	bltu	a3,a1,ffffffffc02014c0 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201472:	601c                	ld	a5,0(s0)
ffffffffc0201474:	7b9c                	ld	a5,48(a5)
ffffffffc0201476:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201478:	00001517          	auipc	a0,0x1
ffffffffc020147c:	1e850513          	addi	a0,a0,488 # ffffffffc0202660 <best_fit_pmm_manager+0x118>
ffffffffc0201480:	c37fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201484:	00004697          	auipc	a3,0x4
ffffffffc0201488:	b7c68693          	addi	a3,a3,-1156 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020148c:	00005797          	auipc	a5,0x5
ffffffffc0201490:	f8d7ba23          	sd	a3,-108(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201494:	c02007b7          	lui	a5,0xc0200
ffffffffc0201498:	06f6e563          	bltu	a3,a5,ffffffffc0201502 <pmm_init+0x17e>
ffffffffc020149c:	609c                	ld	a5,0(s1)
}
ffffffffc020149e:	6442                	ld	s0,16(sp)
ffffffffc02014a0:	60e2                	ld	ra,24(sp)
ffffffffc02014a2:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014a4:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02014a6:	8e9d                	sub	a3,a3,a5
ffffffffc02014a8:	00005797          	auipc	a5,0x5
ffffffffc02014ac:	fad7b423          	sd	a3,-88(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014b0:	00001517          	auipc	a0,0x1
ffffffffc02014b4:	1d050513          	addi	a0,a0,464 # ffffffffc0202680 <best_fit_pmm_manager+0x138>
ffffffffc02014b8:	8636                	mv	a2,a3
}
ffffffffc02014ba:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014bc:	bfbfe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02014c0:	6785                	lui	a5,0x1
ffffffffc02014c2:	17fd                	addi	a5,a5,-1
ffffffffc02014c4:	96be                	add	a3,a3,a5
ffffffffc02014c6:	77fd                	lui	a5,0xfffff
ffffffffc02014c8:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02014ca:	00c6d793          	srli	a5,a3,0xc
ffffffffc02014ce:	04e7f663          	bleu	a4,a5,ffffffffc020151a <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc02014d2:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02014d4:	97aa                	add	a5,a5,a0
ffffffffc02014d6:	00279513          	slli	a0,a5,0x2
ffffffffc02014da:	953e                	add	a0,a0,a5
ffffffffc02014dc:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02014de:	8d95                	sub	a1,a1,a3
ffffffffc02014e0:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02014e2:	81b1                	srli	a1,a1,0xc
ffffffffc02014e4:	9532                	add	a0,a0,a2
ffffffffc02014e6:	9782                	jalr	a5
ffffffffc02014e8:	b769                	j	ffffffffc0201472 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02014ea:	00001617          	auipc	a2,0x1
ffffffffc02014ee:	10e60613          	addi	a2,a2,270 # ffffffffc02025f8 <best_fit_pmm_manager+0xb0>
ffffffffc02014f2:	06e00593          	li	a1,110
ffffffffc02014f6:	00001517          	auipc	a0,0x1
ffffffffc02014fa:	12a50513          	addi	a0,a0,298 # ffffffffc0202620 <best_fit_pmm_manager+0xd8>
ffffffffc02014fe:	eaffe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201502:	00001617          	auipc	a2,0x1
ffffffffc0201506:	0f660613          	addi	a2,a2,246 # ffffffffc02025f8 <best_fit_pmm_manager+0xb0>
ffffffffc020150a:	08900593          	li	a1,137
ffffffffc020150e:	00001517          	auipc	a0,0x1
ffffffffc0201512:	11250513          	addi	a0,a0,274 # ffffffffc0202620 <best_fit_pmm_manager+0xd8>
ffffffffc0201516:	e97fe0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020151a:	00001617          	auipc	a2,0x1
ffffffffc020151e:	11660613          	addi	a2,a2,278 # ffffffffc0202630 <best_fit_pmm_manager+0xe8>
ffffffffc0201522:	06b00593          	li	a1,107
ffffffffc0201526:	00001517          	auipc	a0,0x1
ffffffffc020152a:	12a50513          	addi	a0,a0,298 # ffffffffc0202650 <best_fit_pmm_manager+0x108>
ffffffffc020152e:	e7ffe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201532 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201532:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201536:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201538:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020153c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020153e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201542:	f022                	sd	s0,32(sp)
ffffffffc0201544:	ec26                	sd	s1,24(sp)
ffffffffc0201546:	e84a                	sd	s2,16(sp)
ffffffffc0201548:	f406                	sd	ra,40(sp)
ffffffffc020154a:	e44e                	sd	s3,8(sp)
ffffffffc020154c:	84aa                	mv	s1,a0
ffffffffc020154e:	892e                	mv	s2,a1
ffffffffc0201550:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201554:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201556:	03067e63          	bleu	a6,a2,ffffffffc0201592 <printnum+0x60>
ffffffffc020155a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020155c:	00805763          	blez	s0,ffffffffc020156a <printnum+0x38>
ffffffffc0201560:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201562:	85ca                	mv	a1,s2
ffffffffc0201564:	854e                	mv	a0,s3
ffffffffc0201566:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201568:	fc65                	bnez	s0,ffffffffc0201560 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020156a:	1a02                	slli	s4,s4,0x20
ffffffffc020156c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201570:	00001797          	auipc	a5,0x1
ffffffffc0201574:	2e078793          	addi	a5,a5,736 # ffffffffc0202850 <error_string+0x38>
ffffffffc0201578:	9a3e                	add	s4,s4,a5
}
ffffffffc020157a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020157c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201580:	70a2                	ld	ra,40(sp)
ffffffffc0201582:	69a2                	ld	s3,8(sp)
ffffffffc0201584:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201586:	85ca                	mv	a1,s2
ffffffffc0201588:	8326                	mv	t1,s1
}
ffffffffc020158a:	6942                	ld	s2,16(sp)
ffffffffc020158c:	64e2                	ld	s1,24(sp)
ffffffffc020158e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201590:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201592:	03065633          	divu	a2,a2,a6
ffffffffc0201596:	8722                	mv	a4,s0
ffffffffc0201598:	f9bff0ef          	jal	ra,ffffffffc0201532 <printnum>
ffffffffc020159c:	b7f9                	j	ffffffffc020156a <printnum+0x38>

ffffffffc020159e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020159e:	7119                	addi	sp,sp,-128
ffffffffc02015a0:	f4a6                	sd	s1,104(sp)
ffffffffc02015a2:	f0ca                	sd	s2,96(sp)
ffffffffc02015a4:	e8d2                	sd	s4,80(sp)
ffffffffc02015a6:	e4d6                	sd	s5,72(sp)
ffffffffc02015a8:	e0da                	sd	s6,64(sp)
ffffffffc02015aa:	fc5e                	sd	s7,56(sp)
ffffffffc02015ac:	f862                	sd	s8,48(sp)
ffffffffc02015ae:	f06a                	sd	s10,32(sp)
ffffffffc02015b0:	fc86                	sd	ra,120(sp)
ffffffffc02015b2:	f8a2                	sd	s0,112(sp)
ffffffffc02015b4:	ecce                	sd	s3,88(sp)
ffffffffc02015b6:	f466                	sd	s9,40(sp)
ffffffffc02015b8:	ec6e                	sd	s11,24(sp)
ffffffffc02015ba:	892a                	mv	s2,a0
ffffffffc02015bc:	84ae                	mv	s1,a1
ffffffffc02015be:	8d32                	mv	s10,a2
ffffffffc02015c0:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02015c2:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015c4:	00001a17          	auipc	s4,0x1
ffffffffc02015c8:	0fca0a13          	addi	s4,s4,252 # ffffffffc02026c0 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02015cc:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02015d0:	00001c17          	auipc	s8,0x1
ffffffffc02015d4:	248c0c13          	addi	s8,s8,584 # ffffffffc0202818 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015d8:	000d4503          	lbu	a0,0(s10)
ffffffffc02015dc:	02500793          	li	a5,37
ffffffffc02015e0:	001d0413          	addi	s0,s10,1
ffffffffc02015e4:	00f50e63          	beq	a0,a5,ffffffffc0201600 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02015e8:	c521                	beqz	a0,ffffffffc0201630 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015ea:	02500993          	li	s3,37
ffffffffc02015ee:	a011                	j	ffffffffc02015f2 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02015f0:	c121                	beqz	a0,ffffffffc0201630 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02015f2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015f4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02015f6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015f8:	fff44503          	lbu	a0,-1(s0)
ffffffffc02015fc:	ff351ae3          	bne	a0,s3,ffffffffc02015f0 <vprintfmt+0x52>
ffffffffc0201600:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201604:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201608:	4981                	li	s3,0
ffffffffc020160a:	4801                	li	a6,0
        width = precision = -1;
ffffffffc020160c:	5cfd                	li	s9,-1
ffffffffc020160e:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201610:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201614:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201616:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020161a:	0ff6f693          	andi	a3,a3,255
ffffffffc020161e:	00140d13          	addi	s10,s0,1
ffffffffc0201622:	20d5e563          	bltu	a1,a3,ffffffffc020182c <vprintfmt+0x28e>
ffffffffc0201626:	068a                	slli	a3,a3,0x2
ffffffffc0201628:	96d2                	add	a3,a3,s4
ffffffffc020162a:	4294                	lw	a3,0(a3)
ffffffffc020162c:	96d2                	add	a3,a3,s4
ffffffffc020162e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201630:	70e6                	ld	ra,120(sp)
ffffffffc0201632:	7446                	ld	s0,112(sp)
ffffffffc0201634:	74a6                	ld	s1,104(sp)
ffffffffc0201636:	7906                	ld	s2,96(sp)
ffffffffc0201638:	69e6                	ld	s3,88(sp)
ffffffffc020163a:	6a46                	ld	s4,80(sp)
ffffffffc020163c:	6aa6                	ld	s5,72(sp)
ffffffffc020163e:	6b06                	ld	s6,64(sp)
ffffffffc0201640:	7be2                	ld	s7,56(sp)
ffffffffc0201642:	7c42                	ld	s8,48(sp)
ffffffffc0201644:	7ca2                	ld	s9,40(sp)
ffffffffc0201646:	7d02                	ld	s10,32(sp)
ffffffffc0201648:	6de2                	ld	s11,24(sp)
ffffffffc020164a:	6109                	addi	sp,sp,128
ffffffffc020164c:	8082                	ret
    if (lflag >= 2) {
ffffffffc020164e:	4705                	li	a4,1
ffffffffc0201650:	008a8593          	addi	a1,s5,8
ffffffffc0201654:	01074463          	blt	a4,a6,ffffffffc020165c <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201658:	26080363          	beqz	a6,ffffffffc02018be <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc020165c:	000ab603          	ld	a2,0(s5)
ffffffffc0201660:	46c1                	li	a3,16
ffffffffc0201662:	8aae                	mv	s5,a1
ffffffffc0201664:	a06d                	j	ffffffffc020170e <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201666:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020166a:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020166c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020166e:	b765                	j	ffffffffc0201616 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0201670:	000aa503          	lw	a0,0(s5)
ffffffffc0201674:	85a6                	mv	a1,s1
ffffffffc0201676:	0aa1                	addi	s5,s5,8
ffffffffc0201678:	9902                	jalr	s2
            break;
ffffffffc020167a:	bfb9                	j	ffffffffc02015d8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020167c:	4705                	li	a4,1
ffffffffc020167e:	008a8993          	addi	s3,s5,8
ffffffffc0201682:	01074463          	blt	a4,a6,ffffffffc020168a <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0201686:	22080463          	beqz	a6,ffffffffc02018ae <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc020168a:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc020168e:	24044463          	bltz	s0,ffffffffc02018d6 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0201692:	8622                	mv	a2,s0
ffffffffc0201694:	8ace                	mv	s5,s3
ffffffffc0201696:	46a9                	li	a3,10
ffffffffc0201698:	a89d                	j	ffffffffc020170e <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc020169a:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020169e:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02016a0:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02016a2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02016a6:	8fb5                	xor	a5,a5,a3
ffffffffc02016a8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016ac:	1ad74363          	blt	a4,a3,ffffffffc0201852 <vprintfmt+0x2b4>
ffffffffc02016b0:	00369793          	slli	a5,a3,0x3
ffffffffc02016b4:	97e2                	add	a5,a5,s8
ffffffffc02016b6:	639c                	ld	a5,0(a5)
ffffffffc02016b8:	18078d63          	beqz	a5,ffffffffc0201852 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02016bc:	86be                	mv	a3,a5
ffffffffc02016be:	00001617          	auipc	a2,0x1
ffffffffc02016c2:	24260613          	addi	a2,a2,578 # ffffffffc0202900 <error_string+0xe8>
ffffffffc02016c6:	85a6                	mv	a1,s1
ffffffffc02016c8:	854a                	mv	a0,s2
ffffffffc02016ca:	240000ef          	jal	ra,ffffffffc020190a <printfmt>
ffffffffc02016ce:	b729                	j	ffffffffc02015d8 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02016d0:	00144603          	lbu	a2,1(s0)
ffffffffc02016d4:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016d6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016d8:	bf3d                	j	ffffffffc0201616 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02016da:	4705                	li	a4,1
ffffffffc02016dc:	008a8593          	addi	a1,s5,8
ffffffffc02016e0:	01074463          	blt	a4,a6,ffffffffc02016e8 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02016e4:	1e080263          	beqz	a6,ffffffffc02018c8 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02016e8:	000ab603          	ld	a2,0(s5)
ffffffffc02016ec:	46a1                	li	a3,8
ffffffffc02016ee:	8aae                	mv	s5,a1
ffffffffc02016f0:	a839                	j	ffffffffc020170e <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02016f2:	03000513          	li	a0,48
ffffffffc02016f6:	85a6                	mv	a1,s1
ffffffffc02016f8:	e03e                	sd	a5,0(sp)
ffffffffc02016fa:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02016fc:	85a6                	mv	a1,s1
ffffffffc02016fe:	07800513          	li	a0,120
ffffffffc0201702:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201704:	0aa1                	addi	s5,s5,8
ffffffffc0201706:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020170a:	6782                	ld	a5,0(sp)
ffffffffc020170c:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020170e:	876e                	mv	a4,s11
ffffffffc0201710:	85a6                	mv	a1,s1
ffffffffc0201712:	854a                	mv	a0,s2
ffffffffc0201714:	e1fff0ef          	jal	ra,ffffffffc0201532 <printnum>
            break;
ffffffffc0201718:	b5c1                	j	ffffffffc02015d8 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020171a:	000ab603          	ld	a2,0(s5)
ffffffffc020171e:	0aa1                	addi	s5,s5,8
ffffffffc0201720:	1c060663          	beqz	a2,ffffffffc02018ec <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201724:	00160413          	addi	s0,a2,1
ffffffffc0201728:	17b05c63          	blez	s11,ffffffffc02018a0 <vprintfmt+0x302>
ffffffffc020172c:	02d00593          	li	a1,45
ffffffffc0201730:	14b79263          	bne	a5,a1,ffffffffc0201874 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201734:	00064783          	lbu	a5,0(a2)
ffffffffc0201738:	0007851b          	sext.w	a0,a5
ffffffffc020173c:	c905                	beqz	a0,ffffffffc020176c <vprintfmt+0x1ce>
ffffffffc020173e:	000cc563          	bltz	s9,ffffffffc0201748 <vprintfmt+0x1aa>
ffffffffc0201742:	3cfd                	addiw	s9,s9,-1
ffffffffc0201744:	036c8263          	beq	s9,s6,ffffffffc0201768 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201748:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020174a:	18098463          	beqz	s3,ffffffffc02018d2 <vprintfmt+0x334>
ffffffffc020174e:	3781                	addiw	a5,a5,-32
ffffffffc0201750:	18fbf163          	bleu	a5,s7,ffffffffc02018d2 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201754:	03f00513          	li	a0,63
ffffffffc0201758:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020175a:	0405                	addi	s0,s0,1
ffffffffc020175c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201760:	3dfd                	addiw	s11,s11,-1
ffffffffc0201762:	0007851b          	sext.w	a0,a5
ffffffffc0201766:	fd61                	bnez	a0,ffffffffc020173e <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201768:	e7b058e3          	blez	s11,ffffffffc02015d8 <vprintfmt+0x3a>
ffffffffc020176c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020176e:	85a6                	mv	a1,s1
ffffffffc0201770:	02000513          	li	a0,32
ffffffffc0201774:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201776:	e60d81e3          	beqz	s11,ffffffffc02015d8 <vprintfmt+0x3a>
ffffffffc020177a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020177c:	85a6                	mv	a1,s1
ffffffffc020177e:	02000513          	li	a0,32
ffffffffc0201782:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201784:	fe0d94e3          	bnez	s11,ffffffffc020176c <vprintfmt+0x1ce>
ffffffffc0201788:	bd81                	j	ffffffffc02015d8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020178a:	4705                	li	a4,1
ffffffffc020178c:	008a8593          	addi	a1,s5,8
ffffffffc0201790:	01074463          	blt	a4,a6,ffffffffc0201798 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0201794:	12080063          	beqz	a6,ffffffffc02018b4 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0201798:	000ab603          	ld	a2,0(s5)
ffffffffc020179c:	46a9                	li	a3,10
ffffffffc020179e:	8aae                	mv	s5,a1
ffffffffc02017a0:	b7bd                	j	ffffffffc020170e <vprintfmt+0x170>
ffffffffc02017a2:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02017a6:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017aa:	846a                	mv	s0,s10
ffffffffc02017ac:	b5ad                	j	ffffffffc0201616 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02017ae:	85a6                	mv	a1,s1
ffffffffc02017b0:	02500513          	li	a0,37
ffffffffc02017b4:	9902                	jalr	s2
            break;
ffffffffc02017b6:	b50d                	j	ffffffffc02015d8 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02017b8:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02017bc:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02017c0:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017c2:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02017c4:	e40dd9e3          	bgez	s11,ffffffffc0201616 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02017c8:	8de6                	mv	s11,s9
ffffffffc02017ca:	5cfd                	li	s9,-1
ffffffffc02017cc:	b5a9                	j	ffffffffc0201616 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02017ce:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02017d2:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017d6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02017d8:	bd3d                	j	ffffffffc0201616 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02017da:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02017de:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017e2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02017e4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02017e8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02017ec:	fcd56ce3          	bltu	a0,a3,ffffffffc02017c4 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02017f0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02017f2:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02017f6:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02017fa:	0196873b          	addw	a4,a3,s9
ffffffffc02017fe:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201802:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201806:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020180a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020180e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201812:	fcd57fe3          	bleu	a3,a0,ffffffffc02017f0 <vprintfmt+0x252>
ffffffffc0201816:	b77d                	j	ffffffffc02017c4 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201818:	fffdc693          	not	a3,s11
ffffffffc020181c:	96fd                	srai	a3,a3,0x3f
ffffffffc020181e:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201822:	00144603          	lbu	a2,1(s0)
ffffffffc0201826:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201828:	846a                	mv	s0,s10
ffffffffc020182a:	b3f5                	j	ffffffffc0201616 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020182c:	85a6                	mv	a1,s1
ffffffffc020182e:	02500513          	li	a0,37
ffffffffc0201832:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201834:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201838:	02500793          	li	a5,37
ffffffffc020183c:	8d22                	mv	s10,s0
ffffffffc020183e:	d8f70de3          	beq	a4,a5,ffffffffc02015d8 <vprintfmt+0x3a>
ffffffffc0201842:	02500713          	li	a4,37
ffffffffc0201846:	1d7d                	addi	s10,s10,-1
ffffffffc0201848:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020184c:	fee79de3          	bne	a5,a4,ffffffffc0201846 <vprintfmt+0x2a8>
ffffffffc0201850:	b361                	j	ffffffffc02015d8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201852:	00001617          	auipc	a2,0x1
ffffffffc0201856:	09e60613          	addi	a2,a2,158 # ffffffffc02028f0 <error_string+0xd8>
ffffffffc020185a:	85a6                	mv	a1,s1
ffffffffc020185c:	854a                	mv	a0,s2
ffffffffc020185e:	0ac000ef          	jal	ra,ffffffffc020190a <printfmt>
ffffffffc0201862:	bb9d                	j	ffffffffc02015d8 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201864:	00001617          	auipc	a2,0x1
ffffffffc0201868:	08460613          	addi	a2,a2,132 # ffffffffc02028e8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020186c:	00001417          	auipc	s0,0x1
ffffffffc0201870:	07d40413          	addi	s0,s0,125 # ffffffffc02028e9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201874:	8532                	mv	a0,a2
ffffffffc0201876:	85e6                	mv	a1,s9
ffffffffc0201878:	e032                	sd	a2,0(sp)
ffffffffc020187a:	e43e                	sd	a5,8(sp)
ffffffffc020187c:	1c2000ef          	jal	ra,ffffffffc0201a3e <strnlen>
ffffffffc0201880:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201884:	6602                	ld	a2,0(sp)
ffffffffc0201886:	01b05d63          	blez	s11,ffffffffc02018a0 <vprintfmt+0x302>
ffffffffc020188a:	67a2                	ld	a5,8(sp)
ffffffffc020188c:	2781                	sext.w	a5,a5
ffffffffc020188e:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201890:	6522                	ld	a0,8(sp)
ffffffffc0201892:	85a6                	mv	a1,s1
ffffffffc0201894:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201896:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201898:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020189a:	6602                	ld	a2,0(sp)
ffffffffc020189c:	fe0d9ae3          	bnez	s11,ffffffffc0201890 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018a0:	00064783          	lbu	a5,0(a2)
ffffffffc02018a4:	0007851b          	sext.w	a0,a5
ffffffffc02018a8:	e8051be3          	bnez	a0,ffffffffc020173e <vprintfmt+0x1a0>
ffffffffc02018ac:	b335                	j	ffffffffc02015d8 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02018ae:	000aa403          	lw	s0,0(s5)
ffffffffc02018b2:	bbf1                	j	ffffffffc020168e <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02018b4:	000ae603          	lwu	a2,0(s5)
ffffffffc02018b8:	46a9                	li	a3,10
ffffffffc02018ba:	8aae                	mv	s5,a1
ffffffffc02018bc:	bd89                	j	ffffffffc020170e <vprintfmt+0x170>
ffffffffc02018be:	000ae603          	lwu	a2,0(s5)
ffffffffc02018c2:	46c1                	li	a3,16
ffffffffc02018c4:	8aae                	mv	s5,a1
ffffffffc02018c6:	b5a1                	j	ffffffffc020170e <vprintfmt+0x170>
ffffffffc02018c8:	000ae603          	lwu	a2,0(s5)
ffffffffc02018cc:	46a1                	li	a3,8
ffffffffc02018ce:	8aae                	mv	s5,a1
ffffffffc02018d0:	bd3d                	j	ffffffffc020170e <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02018d2:	9902                	jalr	s2
ffffffffc02018d4:	b559                	j	ffffffffc020175a <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02018d6:	85a6                	mv	a1,s1
ffffffffc02018d8:	02d00513          	li	a0,45
ffffffffc02018dc:	e03e                	sd	a5,0(sp)
ffffffffc02018de:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02018e0:	8ace                	mv	s5,s3
ffffffffc02018e2:	40800633          	neg	a2,s0
ffffffffc02018e6:	46a9                	li	a3,10
ffffffffc02018e8:	6782                	ld	a5,0(sp)
ffffffffc02018ea:	b515                	j	ffffffffc020170e <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02018ec:	01b05663          	blez	s11,ffffffffc02018f8 <vprintfmt+0x35a>
ffffffffc02018f0:	02d00693          	li	a3,45
ffffffffc02018f4:	f6d798e3          	bne	a5,a3,ffffffffc0201864 <vprintfmt+0x2c6>
ffffffffc02018f8:	00001417          	auipc	s0,0x1
ffffffffc02018fc:	ff140413          	addi	s0,s0,-15 # ffffffffc02028e9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201900:	02800513          	li	a0,40
ffffffffc0201904:	02800793          	li	a5,40
ffffffffc0201908:	bd1d                	j	ffffffffc020173e <vprintfmt+0x1a0>

ffffffffc020190a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020190a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020190c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201910:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201912:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201914:	ec06                	sd	ra,24(sp)
ffffffffc0201916:	f83a                	sd	a4,48(sp)
ffffffffc0201918:	fc3e                	sd	a5,56(sp)
ffffffffc020191a:	e0c2                	sd	a6,64(sp)
ffffffffc020191c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020191e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201920:	c7fff0ef          	jal	ra,ffffffffc020159e <vprintfmt>
}
ffffffffc0201924:	60e2                	ld	ra,24(sp)
ffffffffc0201926:	6161                	addi	sp,sp,80
ffffffffc0201928:	8082                	ret

ffffffffc020192a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020192a:	715d                	addi	sp,sp,-80
ffffffffc020192c:	e486                	sd	ra,72(sp)
ffffffffc020192e:	e0a2                	sd	s0,64(sp)
ffffffffc0201930:	fc26                	sd	s1,56(sp)
ffffffffc0201932:	f84a                	sd	s2,48(sp)
ffffffffc0201934:	f44e                	sd	s3,40(sp)
ffffffffc0201936:	f052                	sd	s4,32(sp)
ffffffffc0201938:	ec56                	sd	s5,24(sp)
ffffffffc020193a:	e85a                	sd	s6,16(sp)
ffffffffc020193c:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020193e:	c901                	beqz	a0,ffffffffc020194e <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201940:	85aa                	mv	a1,a0
ffffffffc0201942:	00001517          	auipc	a0,0x1
ffffffffc0201946:	fbe50513          	addi	a0,a0,-66 # ffffffffc0202900 <error_string+0xe8>
ffffffffc020194a:	f6cfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc020194e:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201950:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201952:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201954:	4aa9                	li	s5,10
ffffffffc0201956:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201958:	00004b97          	auipc	s7,0x4
ffffffffc020195c:	6b8b8b93          	addi	s7,s7,1720 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201960:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201964:	fcafe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201968:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020196a:	00054b63          	bltz	a0,ffffffffc0201980 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020196e:	00a95b63          	ble	a0,s2,ffffffffc0201984 <readline+0x5a>
ffffffffc0201972:	029a5463          	ble	s1,s4,ffffffffc020199a <readline+0x70>
        c = getchar();
ffffffffc0201976:	fb8fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc020197a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020197c:	fe0559e3          	bgez	a0,ffffffffc020196e <readline+0x44>
            return NULL;
ffffffffc0201980:	4501                	li	a0,0
ffffffffc0201982:	a099                	j	ffffffffc02019c8 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201984:	03341463          	bne	s0,s3,ffffffffc02019ac <readline+0x82>
ffffffffc0201988:	e8b9                	bnez	s1,ffffffffc02019de <readline+0xb4>
        c = getchar();
ffffffffc020198a:	fa4fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc020198e:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201990:	fe0548e3          	bltz	a0,ffffffffc0201980 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201994:	fea958e3          	ble	a0,s2,ffffffffc0201984 <readline+0x5a>
ffffffffc0201998:	4481                	li	s1,0
            cputchar(c);
ffffffffc020199a:	8522                	mv	a0,s0
ffffffffc020199c:	f4efe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02019a0:	009b87b3          	add	a5,s7,s1
ffffffffc02019a4:	00878023          	sb	s0,0(a5)
ffffffffc02019a8:	2485                	addiw	s1,s1,1
ffffffffc02019aa:	bf6d                	j	ffffffffc0201964 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02019ac:	01540463          	beq	s0,s5,ffffffffc02019b4 <readline+0x8a>
ffffffffc02019b0:	fb641ae3          	bne	s0,s6,ffffffffc0201964 <readline+0x3a>
            cputchar(c);
ffffffffc02019b4:	8522                	mv	a0,s0
ffffffffc02019b6:	f34fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02019ba:	00004517          	auipc	a0,0x4
ffffffffc02019be:	65650513          	addi	a0,a0,1622 # ffffffffc0206010 <edata>
ffffffffc02019c2:	94aa                	add	s1,s1,a0
ffffffffc02019c4:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02019c8:	60a6                	ld	ra,72(sp)
ffffffffc02019ca:	6406                	ld	s0,64(sp)
ffffffffc02019cc:	74e2                	ld	s1,56(sp)
ffffffffc02019ce:	7942                	ld	s2,48(sp)
ffffffffc02019d0:	79a2                	ld	s3,40(sp)
ffffffffc02019d2:	7a02                	ld	s4,32(sp)
ffffffffc02019d4:	6ae2                	ld	s5,24(sp)
ffffffffc02019d6:	6b42                	ld	s6,16(sp)
ffffffffc02019d8:	6ba2                	ld	s7,8(sp)
ffffffffc02019da:	6161                	addi	sp,sp,80
ffffffffc02019dc:	8082                	ret
            cputchar(c);
ffffffffc02019de:	4521                	li	a0,8
ffffffffc02019e0:	f0afe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc02019e4:	34fd                	addiw	s1,s1,-1
ffffffffc02019e6:	bfbd                	j	ffffffffc0201964 <readline+0x3a>

ffffffffc02019e8 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc02019e8:	00004797          	auipc	a5,0x4
ffffffffc02019ec:	62078793          	addi	a5,a5,1568 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc02019f0:	6398                	ld	a4,0(a5)
ffffffffc02019f2:	4781                	li	a5,0
ffffffffc02019f4:	88ba                	mv	a7,a4
ffffffffc02019f6:	852a                	mv	a0,a0
ffffffffc02019f8:	85be                	mv	a1,a5
ffffffffc02019fa:	863e                	mv	a2,a5
ffffffffc02019fc:	00000073          	ecall
ffffffffc0201a00:	87aa                	mv	a5,a0
}
ffffffffc0201a02:	8082                	ret

ffffffffc0201a04 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201a04:	00005797          	auipc	a5,0x5
ffffffffc0201a08:	a2478793          	addi	a5,a5,-1500 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201a0c:	6398                	ld	a4,0(a5)
ffffffffc0201a0e:	4781                	li	a5,0
ffffffffc0201a10:	88ba                	mv	a7,a4
ffffffffc0201a12:	852a                	mv	a0,a0
ffffffffc0201a14:	85be                	mv	a1,a5
ffffffffc0201a16:	863e                	mv	a2,a5
ffffffffc0201a18:	00000073          	ecall
ffffffffc0201a1c:	87aa                	mv	a5,a0
}
ffffffffc0201a1e:	8082                	ret

ffffffffc0201a20 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201a20:	00004797          	auipc	a5,0x4
ffffffffc0201a24:	5e078793          	addi	a5,a5,1504 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201a28:	639c                	ld	a5,0(a5)
ffffffffc0201a2a:	4501                	li	a0,0
ffffffffc0201a2c:	88be                	mv	a7,a5
ffffffffc0201a2e:	852a                	mv	a0,a0
ffffffffc0201a30:	85aa                	mv	a1,a0
ffffffffc0201a32:	862a                	mv	a2,a0
ffffffffc0201a34:	00000073          	ecall
ffffffffc0201a38:	852a                	mv	a0,a0
ffffffffc0201a3a:	2501                	sext.w	a0,a0
ffffffffc0201a3c:	8082                	ret

ffffffffc0201a3e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a3e:	c185                	beqz	a1,ffffffffc0201a5e <strnlen+0x20>
ffffffffc0201a40:	00054783          	lbu	a5,0(a0)
ffffffffc0201a44:	cf89                	beqz	a5,ffffffffc0201a5e <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201a46:	4781                	li	a5,0
ffffffffc0201a48:	a021                	j	ffffffffc0201a50 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a4a:	00074703          	lbu	a4,0(a4)
ffffffffc0201a4e:	c711                	beqz	a4,ffffffffc0201a5a <strnlen+0x1c>
        cnt ++;
ffffffffc0201a50:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a52:	00f50733          	add	a4,a0,a5
ffffffffc0201a56:	fef59ae3          	bne	a1,a5,ffffffffc0201a4a <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201a5a:	853e                	mv	a0,a5
ffffffffc0201a5c:	8082                	ret
    size_t cnt = 0;
ffffffffc0201a5e:	4781                	li	a5,0
}
ffffffffc0201a60:	853e                	mv	a0,a5
ffffffffc0201a62:	8082                	ret

ffffffffc0201a64 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a64:	00054783          	lbu	a5,0(a0)
ffffffffc0201a68:	0005c703          	lbu	a4,0(a1)
ffffffffc0201a6c:	cb91                	beqz	a5,ffffffffc0201a80 <strcmp+0x1c>
ffffffffc0201a6e:	00e79c63          	bne	a5,a4,ffffffffc0201a86 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201a72:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a74:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201a78:	0585                	addi	a1,a1,1
ffffffffc0201a7a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a7e:	fbe5                	bnez	a5,ffffffffc0201a6e <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a80:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201a82:	9d19                	subw	a0,a0,a4
ffffffffc0201a84:	8082                	ret
ffffffffc0201a86:	0007851b          	sext.w	a0,a5
ffffffffc0201a8a:	9d19                	subw	a0,a0,a4
ffffffffc0201a8c:	8082                	ret

ffffffffc0201a8e <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201a8e:	00054783          	lbu	a5,0(a0)
ffffffffc0201a92:	cb91                	beqz	a5,ffffffffc0201aa6 <strchr+0x18>
        if (*s == c) {
ffffffffc0201a94:	00b79563          	bne	a5,a1,ffffffffc0201a9e <strchr+0x10>
ffffffffc0201a98:	a809                	j	ffffffffc0201aaa <strchr+0x1c>
ffffffffc0201a9a:	00b78763          	beq	a5,a1,ffffffffc0201aa8 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201a9e:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201aa0:	00054783          	lbu	a5,0(a0)
ffffffffc0201aa4:	fbfd                	bnez	a5,ffffffffc0201a9a <strchr+0xc>
    }
    return NULL;
ffffffffc0201aa6:	4501                	li	a0,0
}
ffffffffc0201aa8:	8082                	ret
ffffffffc0201aaa:	8082                	ret

ffffffffc0201aac <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201aac:	ca01                	beqz	a2,ffffffffc0201abc <memset+0x10>
ffffffffc0201aae:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201ab0:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201ab2:	0785                	addi	a5,a5,1
ffffffffc0201ab4:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201ab8:	fec79de3          	bne	a5,a2,ffffffffc0201ab2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201abc:	8082                	ret
