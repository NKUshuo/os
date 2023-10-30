
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
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
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	00a50513          	addi	a0,a0,10 # ffffffffc020a040 <edata>
ffffffffc020003e:	00011617          	auipc	a2,0x11
ffffffffc0200042:	55a60613          	addi	a2,a2,1370 # ffffffffc0211598 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	56d030ef          	jal	ra,ffffffffc0203dba <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	24e58593          	addi	a1,a1,590 # ffffffffc02042a0 <etext+0x6>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	26650513          	addi	a0,a0,614 # ffffffffc02042c0 <etext+0x26>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	100000ef          	jal	ra,ffffffffc0200166 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	639020ef          	jal	ra,ffffffffc0202ea2 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	504000ef          	jal	ra,ffffffffc0200572 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	76d000ef          	jal	ra,ffffffffc0200fde <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	35e000ef          	jal	ra,ffffffffc02003d4 <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	594010ef          	jal	ra,ffffffffc020160e <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	3ae000ef          	jal	ra,ffffffffc020042c <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x4c>

ffffffffc0200084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008c:	3f6000ef          	jal	ra,ffffffffc0200482 <cons_putc>
    (*cnt) ++;
ffffffffc0200090:	401c                	lw	a5,0(s0)
}
ffffffffc0200092:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
}
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	86ae                	mv	a3,a1
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fde50513          	addi	a0,a0,-34 # ffffffffc0200084 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	59f030ef          	jal	ra,ffffffffc0203e50 <vprintfmt>
    return cnt;
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000be:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c4:	f42e                	sd	a1,40(sp)
ffffffffc02000c6:	f832                	sd	a2,48(sp)
ffffffffc02000c8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	862a                	mv	a2,a0
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200084 <cputch>
ffffffffc02000d6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d8:	ec06                	sd	ra,24(sp)
ffffffffc02000da:	e0ba                	sd	a4,64(sp)
ffffffffc02000dc:	e4be                	sd	a5,72(sp)
ffffffffc02000de:	e8c2                	sd	a6,80(sp)
ffffffffc02000e0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e6:	56b030ef          	jal	ra,ffffffffc0203e50 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000ea:	60e2                	ld	ra,24(sp)
ffffffffc02000ec:	4512                	lw	a0,4(sp)
ffffffffc02000ee:	6125                	addi	sp,sp,96
ffffffffc02000f0:	8082                	ret

ffffffffc02000f2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f2:	3900006f          	j	ffffffffc0200482 <cons_putc>

ffffffffc02000f6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f6:	1141                	addi	sp,sp,-16
ffffffffc02000f8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000fa:	3be000ef          	jal	ra,ffffffffc02004b8 <cons_getc>
ffffffffc02000fe:	dd75                	beqz	a0,ffffffffc02000fa <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200100:	60a2                	ld	ra,8(sp)
ffffffffc0200102:	0141                	addi	sp,sp,16
ffffffffc0200104:	8082                	ret

ffffffffc0200106 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200106:	00011317          	auipc	t1,0x11
ffffffffc020010a:	33a30313          	addi	t1,t1,826 # ffffffffc0211440 <is_panic>
ffffffffc020010e:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200112:	715d                	addi	sp,sp,-80
ffffffffc0200114:	ec06                	sd	ra,24(sp)
ffffffffc0200116:	e822                	sd	s0,16(sp)
ffffffffc0200118:	f436                	sd	a3,40(sp)
ffffffffc020011a:	f83a                	sd	a4,48(sp)
ffffffffc020011c:	fc3e                	sd	a5,56(sp)
ffffffffc020011e:	e0c2                	sd	a6,64(sp)
ffffffffc0200120:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200122:	02031c63          	bnez	t1,ffffffffc020015a <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200126:	4785                	li	a5,1
ffffffffc0200128:	8432                	mv	s0,a2
ffffffffc020012a:	00011717          	auipc	a4,0x11
ffffffffc020012e:	30f72b23          	sw	a5,790(a4) # ffffffffc0211440 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200132:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200134:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200136:	85aa                	mv	a1,a0
ffffffffc0200138:	00004517          	auipc	a0,0x4
ffffffffc020013c:	19050513          	addi	a0,a0,400 # ffffffffc02042c8 <etext+0x2e>
    va_start(ap, fmt);
ffffffffc0200140:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200142:	f7dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200146:	65a2                	ld	a1,8(sp)
ffffffffc0200148:	8522                	mv	a0,s0
ffffffffc020014a:	f55ff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc020014e:	00006517          	auipc	a0,0x6
ffffffffc0200152:	ada50513          	addi	a0,a0,-1318 # ffffffffc0205c28 <default_pmm_manager+0x490>
ffffffffc0200156:	f69ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020015a:	3a0000ef          	jal	ra,ffffffffc02004fa <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020015e:	4501                	li	a0,0
ffffffffc0200160:	132000ef          	jal	ra,ffffffffc0200292 <kmonitor>
ffffffffc0200164:	bfed                	j	ffffffffc020015e <__panic+0x58>

ffffffffc0200166 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200166:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200168:	00004517          	auipc	a0,0x4
ffffffffc020016c:	1b050513          	addi	a0,a0,432 # ffffffffc0204318 <etext+0x7e>
void print_kerninfo(void) {
ffffffffc0200170:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200172:	f4dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200176:	00000597          	auipc	a1,0x0
ffffffffc020017a:	ec058593          	addi	a1,a1,-320 # ffffffffc0200036 <kern_init>
ffffffffc020017e:	00004517          	auipc	a0,0x4
ffffffffc0200182:	1ba50513          	addi	a0,a0,442 # ffffffffc0204338 <etext+0x9e>
ffffffffc0200186:	f39ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020018a:	00004597          	auipc	a1,0x4
ffffffffc020018e:	11058593          	addi	a1,a1,272 # ffffffffc020429a <etext>
ffffffffc0200192:	00004517          	auipc	a0,0x4
ffffffffc0200196:	1c650513          	addi	a0,a0,454 # ffffffffc0204358 <etext+0xbe>
ffffffffc020019a:	f25ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020019e:	0000a597          	auipc	a1,0xa
ffffffffc02001a2:	ea258593          	addi	a1,a1,-350 # ffffffffc020a040 <edata>
ffffffffc02001a6:	00004517          	auipc	a0,0x4
ffffffffc02001aa:	1d250513          	addi	a0,a0,466 # ffffffffc0204378 <etext+0xde>
ffffffffc02001ae:	f11ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001b2:	00011597          	auipc	a1,0x11
ffffffffc02001b6:	3e658593          	addi	a1,a1,998 # ffffffffc0211598 <end>
ffffffffc02001ba:	00004517          	auipc	a0,0x4
ffffffffc02001be:	1de50513          	addi	a0,a0,478 # ffffffffc0204398 <etext+0xfe>
ffffffffc02001c2:	efdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001c6:	00011597          	auipc	a1,0x11
ffffffffc02001ca:	7d158593          	addi	a1,a1,2001 # ffffffffc0211997 <end+0x3ff>
ffffffffc02001ce:	00000797          	auipc	a5,0x0
ffffffffc02001d2:	e6878793          	addi	a5,a5,-408 # ffffffffc0200036 <kern_init>
ffffffffc02001d6:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001da:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001de:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001e0:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001e4:	95be                	add	a1,a1,a5
ffffffffc02001e6:	85a9                	srai	a1,a1,0xa
ffffffffc02001e8:	00004517          	auipc	a0,0x4
ffffffffc02001ec:	1d050513          	addi	a0,a0,464 # ffffffffc02043b8 <etext+0x11e>
}
ffffffffc02001f0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001f2:	ecdff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02001f6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001f6:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001f8:	00004617          	auipc	a2,0x4
ffffffffc02001fc:	0f060613          	addi	a2,a2,240 # ffffffffc02042e8 <etext+0x4e>
ffffffffc0200200:	04e00593          	li	a1,78
ffffffffc0200204:	00004517          	auipc	a0,0x4
ffffffffc0200208:	0fc50513          	addi	a0,a0,252 # ffffffffc0204300 <etext+0x66>
void print_stackframe(void) {
ffffffffc020020c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020020e:	ef9ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200212 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200212:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200214:	00004617          	auipc	a2,0x4
ffffffffc0200218:	2ac60613          	addi	a2,a2,684 # ffffffffc02044c0 <commands+0xd8>
ffffffffc020021c:	00004597          	auipc	a1,0x4
ffffffffc0200220:	2c458593          	addi	a1,a1,708 # ffffffffc02044e0 <commands+0xf8>
ffffffffc0200224:	00004517          	auipc	a0,0x4
ffffffffc0200228:	2c450513          	addi	a0,a0,708 # ffffffffc02044e8 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020022c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020022e:	e91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200232:	00004617          	auipc	a2,0x4
ffffffffc0200236:	2c660613          	addi	a2,a2,710 # ffffffffc02044f8 <commands+0x110>
ffffffffc020023a:	00004597          	auipc	a1,0x4
ffffffffc020023e:	2e658593          	addi	a1,a1,742 # ffffffffc0204520 <commands+0x138>
ffffffffc0200242:	00004517          	auipc	a0,0x4
ffffffffc0200246:	2a650513          	addi	a0,a0,678 # ffffffffc02044e8 <commands+0x100>
ffffffffc020024a:	e75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020024e:	00004617          	auipc	a2,0x4
ffffffffc0200252:	2e260613          	addi	a2,a2,738 # ffffffffc0204530 <commands+0x148>
ffffffffc0200256:	00004597          	auipc	a1,0x4
ffffffffc020025a:	2fa58593          	addi	a1,a1,762 # ffffffffc0204550 <commands+0x168>
ffffffffc020025e:	00004517          	auipc	a0,0x4
ffffffffc0200262:	28a50513          	addi	a0,a0,650 # ffffffffc02044e8 <commands+0x100>
ffffffffc0200266:	e59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc020026a:	60a2                	ld	ra,8(sp)
ffffffffc020026c:	4501                	li	a0,0
ffffffffc020026e:	0141                	addi	sp,sp,16
ffffffffc0200270:	8082                	ret

ffffffffc0200272 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200272:	1141                	addi	sp,sp,-16
ffffffffc0200274:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200276:	ef1ff0ef          	jal	ra,ffffffffc0200166 <print_kerninfo>
    return 0;
}
ffffffffc020027a:	60a2                	ld	ra,8(sp)
ffffffffc020027c:	4501                	li	a0,0
ffffffffc020027e:	0141                	addi	sp,sp,16
ffffffffc0200280:	8082                	ret

ffffffffc0200282 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200282:	1141                	addi	sp,sp,-16
ffffffffc0200284:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200286:	f71ff0ef          	jal	ra,ffffffffc02001f6 <print_stackframe>
    return 0;
}
ffffffffc020028a:	60a2                	ld	ra,8(sp)
ffffffffc020028c:	4501                	li	a0,0
ffffffffc020028e:	0141                	addi	sp,sp,16
ffffffffc0200290:	8082                	ret

ffffffffc0200292 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200292:	7115                	addi	sp,sp,-224
ffffffffc0200294:	e962                	sd	s8,144(sp)
ffffffffc0200296:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200298:	00004517          	auipc	a0,0x4
ffffffffc020029c:	19850513          	addi	a0,a0,408 # ffffffffc0204430 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02002a0:	ed86                	sd	ra,216(sp)
ffffffffc02002a2:	e9a2                	sd	s0,208(sp)
ffffffffc02002a4:	e5a6                	sd	s1,200(sp)
ffffffffc02002a6:	e1ca                	sd	s2,192(sp)
ffffffffc02002a8:	fd4e                	sd	s3,184(sp)
ffffffffc02002aa:	f952                	sd	s4,176(sp)
ffffffffc02002ac:	f556                	sd	s5,168(sp)
ffffffffc02002ae:	f15a                	sd	s6,160(sp)
ffffffffc02002b0:	ed5e                	sd	s7,152(sp)
ffffffffc02002b2:	e566                	sd	s9,136(sp)
ffffffffc02002b4:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002b6:	e09ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002ba:	00004517          	auipc	a0,0x4
ffffffffc02002be:	19e50513          	addi	a0,a0,414 # ffffffffc0204458 <commands+0x70>
ffffffffc02002c2:	dfdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc02002c6:	000c0563          	beqz	s8,ffffffffc02002d0 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002ca:	8562                	mv	a0,s8
ffffffffc02002cc:	492000ef          	jal	ra,ffffffffc020075e <print_trapframe>
ffffffffc02002d0:	00004c97          	auipc	s9,0x4
ffffffffc02002d4:	118c8c93          	addi	s9,s9,280 # ffffffffc02043e8 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002d8:	00005997          	auipc	s3,0x5
ffffffffc02002dc:	0c098993          	addi	s3,s3,192 # ffffffffc0205398 <commands+0xfb0>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e0:	00004917          	auipc	s2,0x4
ffffffffc02002e4:	1a090913          	addi	s2,s2,416 # ffffffffc0204480 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc02002e8:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002ea:	00004b17          	auipc	s6,0x4
ffffffffc02002ee:	19eb0b13          	addi	s6,s6,414 # ffffffffc0204488 <commands+0xa0>
    if (argc == 0) {
ffffffffc02002f2:	00004a97          	auipc	s5,0x4
ffffffffc02002f6:	1eea8a93          	addi	s5,s5,494 # ffffffffc02044e0 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002fc:	854e                	mv	a0,s3
ffffffffc02002fe:	6df030ef          	jal	ra,ffffffffc02041dc <readline>
ffffffffc0200302:	842a                	mv	s0,a0
ffffffffc0200304:	dd65                	beqz	a0,ffffffffc02002fc <kmonitor+0x6a>
ffffffffc0200306:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020030a:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030c:	c999                	beqz	a1,ffffffffc0200322 <kmonitor+0x90>
ffffffffc020030e:	854a                	mv	a0,s2
ffffffffc0200310:	28d030ef          	jal	ra,ffffffffc0203d9c <strchr>
ffffffffc0200314:	c925                	beqz	a0,ffffffffc0200384 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc0200316:	00144583          	lbu	a1,1(s0)
ffffffffc020031a:	00040023          	sb	zero,0(s0)
ffffffffc020031e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200320:	f5fd                	bnez	a1,ffffffffc020030e <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200322:	dce9                	beqz	s1,ffffffffc02002fc <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200324:	6582                	ld	a1,0(sp)
ffffffffc0200326:	00004d17          	auipc	s10,0x4
ffffffffc020032a:	0c2d0d13          	addi	s10,s10,194 # ffffffffc02043e8 <commands>
    if (argc == 0) {
ffffffffc020032e:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200330:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200332:	0d61                	addi	s10,s10,24
ffffffffc0200334:	23f030ef          	jal	ra,ffffffffc0203d72 <strcmp>
ffffffffc0200338:	c919                	beqz	a0,ffffffffc020034e <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020033a:	2405                	addiw	s0,s0,1
ffffffffc020033c:	09740463          	beq	s0,s7,ffffffffc02003c4 <kmonitor+0x132>
ffffffffc0200340:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200344:	6582                	ld	a1,0(sp)
ffffffffc0200346:	0d61                	addi	s10,s10,24
ffffffffc0200348:	22b030ef          	jal	ra,ffffffffc0203d72 <strcmp>
ffffffffc020034c:	f57d                	bnez	a0,ffffffffc020033a <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020034e:	00141793          	slli	a5,s0,0x1
ffffffffc0200352:	97a2                	add	a5,a5,s0
ffffffffc0200354:	078e                	slli	a5,a5,0x3
ffffffffc0200356:	97e6                	add	a5,a5,s9
ffffffffc0200358:	6b9c                	ld	a5,16(a5)
ffffffffc020035a:	8662                	mv	a2,s8
ffffffffc020035c:	002c                	addi	a1,sp,8
ffffffffc020035e:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200362:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200364:	f8055ce3          	bgez	a0,ffffffffc02002fc <kmonitor+0x6a>
}
ffffffffc0200368:	60ee                	ld	ra,216(sp)
ffffffffc020036a:	644e                	ld	s0,208(sp)
ffffffffc020036c:	64ae                	ld	s1,200(sp)
ffffffffc020036e:	690e                	ld	s2,192(sp)
ffffffffc0200370:	79ea                	ld	s3,184(sp)
ffffffffc0200372:	7a4a                	ld	s4,176(sp)
ffffffffc0200374:	7aaa                	ld	s5,168(sp)
ffffffffc0200376:	7b0a                	ld	s6,160(sp)
ffffffffc0200378:	6bea                	ld	s7,152(sp)
ffffffffc020037a:	6c4a                	ld	s8,144(sp)
ffffffffc020037c:	6caa                	ld	s9,136(sp)
ffffffffc020037e:	6d0a                	ld	s10,128(sp)
ffffffffc0200380:	612d                	addi	sp,sp,224
ffffffffc0200382:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200384:	00044783          	lbu	a5,0(s0)
ffffffffc0200388:	dfc9                	beqz	a5,ffffffffc0200322 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020038a:	03448863          	beq	s1,s4,ffffffffc02003ba <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020038e:	00349793          	slli	a5,s1,0x3
ffffffffc0200392:	0118                	addi	a4,sp,128
ffffffffc0200394:	97ba                	add	a5,a5,a4
ffffffffc0200396:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020039a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020039e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a0:	e591                	bnez	a1,ffffffffc02003ac <kmonitor+0x11a>
ffffffffc02003a2:	b749                	j	ffffffffc0200324 <kmonitor+0x92>
            buf ++;
ffffffffc02003a4:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a6:	00044583          	lbu	a1,0(s0)
ffffffffc02003aa:	ddad                	beqz	a1,ffffffffc0200324 <kmonitor+0x92>
ffffffffc02003ac:	854a                	mv	a0,s2
ffffffffc02003ae:	1ef030ef          	jal	ra,ffffffffc0203d9c <strchr>
ffffffffc02003b2:	d96d                	beqz	a0,ffffffffc02003a4 <kmonitor+0x112>
ffffffffc02003b4:	00044583          	lbu	a1,0(s0)
ffffffffc02003b8:	bf91                	j	ffffffffc020030c <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003ba:	45c1                	li	a1,16
ffffffffc02003bc:	855a                	mv	a0,s6
ffffffffc02003be:	d01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02003c2:	b7f1                	j	ffffffffc020038e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003c4:	6582                	ld	a1,0(sp)
ffffffffc02003c6:	00004517          	auipc	a0,0x4
ffffffffc02003ca:	0e250513          	addi	a0,a0,226 # ffffffffc02044a8 <commands+0xc0>
ffffffffc02003ce:	cf1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc02003d2:	b72d                	j	ffffffffc02002fc <kmonitor+0x6a>

ffffffffc02003d4 <ide_init>:
#include <string.h>
#include <trap.h>
#include <riscv.h>

// 模拟硬盘
void ide_init(void) {}
ffffffffc02003d4:	8082                	ret

ffffffffc02003d6 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];// 56 * 512

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02003d6:	00253513          	sltiu	a0,a0,2
ffffffffc02003da:	8082                	ret

ffffffffc02003dc <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02003dc:	03800513          	li	a0,56
ffffffffc02003e0:	8082                	ret

ffffffffc02003e2 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {// 取数据
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003e2:	0000a797          	auipc	a5,0xa
ffffffffc02003e6:	c5e78793          	addi	a5,a5,-930 # ffffffffc020a040 <edata>
ffffffffc02003ea:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {// 取数据
ffffffffc02003ee:	1141                	addi	sp,sp,-16
ffffffffc02003f0:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003f2:	95be                	add	a1,a1,a5
ffffffffc02003f4:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {// 取数据
ffffffffc02003f8:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003fa:	1d3030ef          	jal	ra,ffffffffc0203dcc <memcpy>
    return 0;
}
ffffffffc02003fe:	60a2                	ld	ra,8(sp)
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	0141                	addi	sp,sp,16
ffffffffc0200404:	8082                	ret

ffffffffc0200406 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {// 写数据
ffffffffc0200406:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200408:	0095979b          	slliw	a5,a1,0x9
ffffffffc020040c:	0000a517          	auipc	a0,0xa
ffffffffc0200410:	c3450513          	addi	a0,a0,-972 # ffffffffc020a040 <edata>
                   size_t nsecs) {// 写数据
ffffffffc0200414:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200416:	00969613          	slli	a2,a3,0x9
ffffffffc020041a:	85ba                	mv	a1,a4
ffffffffc020041c:	953e                	add	a0,a0,a5
                   size_t nsecs) {// 写数据
ffffffffc020041e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200420:	1ad030ef          	jal	ra,ffffffffc0203dcc <memcpy>
    return 0;
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
ffffffffc0200426:	4501                	li	a0,0
ffffffffc0200428:	0141                	addi	sp,sp,16
ffffffffc020042a:	8082                	ret

ffffffffc020042c <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020042c:	67e1                	lui	a5,0x18
ffffffffc020042e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200432:	00011717          	auipc	a4,0x11
ffffffffc0200436:	00f73b23          	sd	a5,22(a4) # ffffffffc0211448 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020043e:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200440:	953e                	add	a0,a0,a5
ffffffffc0200442:	4601                	li	a2,0
ffffffffc0200444:	4881                	li	a7,0
ffffffffc0200446:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020044a:	02000793          	li	a5,32
ffffffffc020044e:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200452:	00004517          	auipc	a0,0x4
ffffffffc0200456:	10e50513          	addi	a0,a0,270 # ffffffffc0204560 <commands+0x178>
    ticks = 0;
ffffffffc020045a:	00011797          	auipc	a5,0x11
ffffffffc020045e:	0007bf23          	sd	zero,30(a5) # ffffffffc0211478 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200462:	c5dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200466 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200466:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020046a:	00011797          	auipc	a5,0x11
ffffffffc020046e:	fde78793          	addi	a5,a5,-34 # ffffffffc0211448 <timebase>
ffffffffc0200472:	639c                	ld	a5,0(a5)
ffffffffc0200474:	4581                	li	a1,0
ffffffffc0200476:	4601                	li	a2,0
ffffffffc0200478:	953e                	add	a0,a0,a5
ffffffffc020047a:	4881                	li	a7,0
ffffffffc020047c:	00000073          	ecall
ffffffffc0200480:	8082                	ret

ffffffffc0200482 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200482:	100027f3          	csrr	a5,sstatus
ffffffffc0200486:	8b89                	andi	a5,a5,2
ffffffffc0200488:	0ff57513          	andi	a0,a0,255
ffffffffc020048c:	e799                	bnez	a5,ffffffffc020049a <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020048e:	4581                	li	a1,0
ffffffffc0200490:	4601                	li	a2,0
ffffffffc0200492:	4885                	li	a7,1
ffffffffc0200494:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200498:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020049a:	1101                	addi	sp,sp,-32
ffffffffc020049c:	ec06                	sd	ra,24(sp)
ffffffffc020049e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02004a0:	05a000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02004a4:	6522                	ld	a0,8(sp)
ffffffffc02004a6:	4581                	li	a1,0
ffffffffc02004a8:	4601                	li	a2,0
ffffffffc02004aa:	4885                	li	a7,1
ffffffffc02004ac:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02004b0:	60e2                	ld	ra,24(sp)
ffffffffc02004b2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02004b4:	0400006f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc02004b8 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004b8:	100027f3          	csrr	a5,sstatus
ffffffffc02004bc:	8b89                	andi	a5,a5,2
ffffffffc02004be:	eb89                	bnez	a5,ffffffffc02004d0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02004c0:	4501                	li	a0,0
ffffffffc02004c2:	4581                	li	a1,0
ffffffffc02004c4:	4601                	li	a2,0
ffffffffc02004c6:	4889                	li	a7,2
ffffffffc02004c8:	00000073          	ecall
ffffffffc02004cc:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02004ce:	8082                	ret
int cons_getc(void) {
ffffffffc02004d0:	1101                	addi	sp,sp,-32
ffffffffc02004d2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02004d4:	026000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02004d8:	4501                	li	a0,0
ffffffffc02004da:	4581                	li	a1,0
ffffffffc02004dc:	4601                	li	a2,0
ffffffffc02004de:	4889                	li	a7,2
ffffffffc02004e0:	00000073          	ecall
ffffffffc02004e4:	2501                	sext.w	a0,a0
ffffffffc02004e6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02004e8:	00c000ef          	jal	ra,ffffffffc02004f4 <intr_enable>
}
ffffffffc02004ec:	60e2                	ld	ra,24(sp)
ffffffffc02004ee:	6522                	ld	a0,8(sp)
ffffffffc02004f0:	6105                	addi	sp,sp,32
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004f4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004f8:	8082                	ret

ffffffffc02004fa <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004fa:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004fe:	8082                	ret

ffffffffc0200500 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200500:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200504:	1141                	addi	sp,sp,-16
ffffffffc0200506:	e022                	sd	s0,0(sp)
ffffffffc0200508:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020050a:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc020050e:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200510:	11053583          	ld	a1,272(a0)
ffffffffc0200514:	05500613          	li	a2,85
ffffffffc0200518:	c399                	beqz	a5,ffffffffc020051e <pgfault_handler+0x1e>
ffffffffc020051a:	04b00613          	li	a2,75
ffffffffc020051e:	11843703          	ld	a4,280(s0)
ffffffffc0200522:	47bd                	li	a5,15
ffffffffc0200524:	05700693          	li	a3,87
ffffffffc0200528:	00f70463          	beq	a4,a5,ffffffffc0200530 <pgfault_handler+0x30>
ffffffffc020052c:	05200693          	li	a3,82
ffffffffc0200530:	00004517          	auipc	a0,0x4
ffffffffc0200534:	32850513          	addi	a0,a0,808 # ffffffffc0204858 <commands+0x470>
ffffffffc0200538:	b87ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020053c:	00011797          	auipc	a5,0x11
ffffffffc0200540:	f5478793          	addi	a5,a5,-172 # ffffffffc0211490 <check_mm_struct>
ffffffffc0200544:	6388                	ld	a0,0(a5)
ffffffffc0200546:	c911                	beqz	a0,ffffffffc020055a <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	11043603          	ld	a2,272(s0)
ffffffffc020054c:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200550:	6402                	ld	s0,0(sp)
ffffffffc0200552:	60a2                	ld	ra,8(sp)
ffffffffc0200554:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200556:	7c70006f          	j	ffffffffc020151c <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020055a:	00004617          	auipc	a2,0x4
ffffffffc020055e:	31e60613          	addi	a2,a2,798 # ffffffffc0204878 <commands+0x490>
ffffffffc0200562:	07800593          	li	a1,120
ffffffffc0200566:	00004517          	auipc	a0,0x4
ffffffffc020056a:	32a50513          	addi	a0,a0,810 # ffffffffc0204890 <commands+0x4a8>
ffffffffc020056e:	b99ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200572 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200572:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200576:	00000797          	auipc	a5,0x0
ffffffffc020057a:	49a78793          	addi	a5,a5,1178 # ffffffffc0200a10 <__alltraps>
ffffffffc020057e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200582:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200586:	000407b7          	lui	a5,0x40
ffffffffc020058a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020058e:	8082                	ret

ffffffffc0200590 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200590:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	1141                	addi	sp,sp,-16
ffffffffc0200594:	e022                	sd	s0,0(sp)
ffffffffc0200596:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200598:	00004517          	auipc	a0,0x4
ffffffffc020059c:	31050513          	addi	a0,a0,784 # ffffffffc02048a8 <commands+0x4c0>
void print_regs(struct pushregs *gpr) {
ffffffffc02005a0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02005a2:	b1dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02005a6:	640c                	ld	a1,8(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	31850513          	addi	a0,a0,792 # ffffffffc02048c0 <commands+0x4d8>
ffffffffc02005b0:	b0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005b4:	680c                	ld	a1,16(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	32250513          	addi	a0,a0,802 # ffffffffc02048d8 <commands+0x4f0>
ffffffffc02005be:	b01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005c2:	6c0c                	ld	a1,24(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	32c50513          	addi	a0,a0,812 # ffffffffc02048f0 <commands+0x508>
ffffffffc02005cc:	af3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005d0:	700c                	ld	a1,32(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	33650513          	addi	a0,a0,822 # ffffffffc0204908 <commands+0x520>
ffffffffc02005da:	ae5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005de:	740c                	ld	a1,40(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	34050513          	addi	a0,a0,832 # ffffffffc0204920 <commands+0x538>
ffffffffc02005e8:	ad7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005ec:	780c                	ld	a1,48(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	34a50513          	addi	a0,a0,842 # ffffffffc0204938 <commands+0x550>
ffffffffc02005f6:	ac9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005fa:	7c0c                	ld	a1,56(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	35450513          	addi	a0,a0,852 # ffffffffc0204950 <commands+0x568>
ffffffffc0200604:	abbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200608:	602c                	ld	a1,64(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	35e50513          	addi	a0,a0,862 # ffffffffc0204968 <commands+0x580>
ffffffffc0200612:	aadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200616:	642c                	ld	a1,72(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	36850513          	addi	a0,a0,872 # ffffffffc0204980 <commands+0x598>
ffffffffc0200620:	a9fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200624:	682c                	ld	a1,80(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	37250513          	addi	a0,a0,882 # ffffffffc0204998 <commands+0x5b0>
ffffffffc020062e:	a91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200632:	6c2c                	ld	a1,88(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	37c50513          	addi	a0,a0,892 # ffffffffc02049b0 <commands+0x5c8>
ffffffffc020063c:	a83ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200640:	702c                	ld	a1,96(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	38650513          	addi	a0,a0,902 # ffffffffc02049c8 <commands+0x5e0>
ffffffffc020064a:	a75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020064e:	742c                	ld	a1,104(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	39050513          	addi	a0,a0,912 # ffffffffc02049e0 <commands+0x5f8>
ffffffffc0200658:	a67ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020065c:	782c                	ld	a1,112(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	39a50513          	addi	a0,a0,922 # ffffffffc02049f8 <commands+0x610>
ffffffffc0200666:	a59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020066a:	7c2c                	ld	a1,120(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	3a450513          	addi	a0,a0,932 # ffffffffc0204a10 <commands+0x628>
ffffffffc0200674:	a4bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200678:	604c                	ld	a1,128(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	3ae50513          	addi	a0,a0,942 # ffffffffc0204a28 <commands+0x640>
ffffffffc0200682:	a3dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200686:	644c                	ld	a1,136(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	3b850513          	addi	a0,a0,952 # ffffffffc0204a40 <commands+0x658>
ffffffffc0200690:	a2fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200694:	684c                	ld	a1,144(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	3c250513          	addi	a0,a0,962 # ffffffffc0204a58 <commands+0x670>
ffffffffc020069e:	a21ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02006a2:	6c4c                	ld	a1,152(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	3cc50513          	addi	a0,a0,972 # ffffffffc0204a70 <commands+0x688>
ffffffffc02006ac:	a13ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006b0:	704c                	ld	a1,160(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	3d650513          	addi	a0,a0,982 # ffffffffc0204a88 <commands+0x6a0>
ffffffffc02006ba:	a05ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006be:	744c                	ld	a1,168(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	3e050513          	addi	a0,a0,992 # ffffffffc0204aa0 <commands+0x6b8>
ffffffffc02006c8:	9f7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006cc:	784c                	ld	a1,176(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	3ea50513          	addi	a0,a0,1002 # ffffffffc0204ab8 <commands+0x6d0>
ffffffffc02006d6:	9e9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006da:	7c4c                	ld	a1,184(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	3f450513          	addi	a0,a0,1012 # ffffffffc0204ad0 <commands+0x6e8>
ffffffffc02006e4:	9dbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006e8:	606c                	ld	a1,192(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	3fe50513          	addi	a0,a0,1022 # ffffffffc0204ae8 <commands+0x700>
ffffffffc02006f2:	9cdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006f6:	646c                	ld	a1,200(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	40850513          	addi	a0,a0,1032 # ffffffffc0204b00 <commands+0x718>
ffffffffc0200700:	9bfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200704:	686c                	ld	a1,208(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	41250513          	addi	a0,a0,1042 # ffffffffc0204b18 <commands+0x730>
ffffffffc020070e:	9b1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200712:	6c6c                	ld	a1,216(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	41c50513          	addi	a0,a0,1052 # ffffffffc0204b30 <commands+0x748>
ffffffffc020071c:	9a3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200720:	706c                	ld	a1,224(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	42650513          	addi	a0,a0,1062 # ffffffffc0204b48 <commands+0x760>
ffffffffc020072a:	995ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020072e:	746c                	ld	a1,232(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	43050513          	addi	a0,a0,1072 # ffffffffc0204b60 <commands+0x778>
ffffffffc0200738:	987ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020073c:	786c                	ld	a1,240(s0)
ffffffffc020073e:	00004517          	auipc	a0,0x4
ffffffffc0200742:	43a50513          	addi	a0,a0,1082 # ffffffffc0204b78 <commands+0x790>
ffffffffc0200746:	979ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020074c:	6402                	ld	s0,0(sp)
ffffffffc020074e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200750:	00004517          	auipc	a0,0x4
ffffffffc0200754:	44050513          	addi	a0,a0,1088 # ffffffffc0204b90 <commands+0x7a8>
}
ffffffffc0200758:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020075a:	965ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020075e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	1141                	addi	sp,sp,-16
ffffffffc0200760:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200762:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200764:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200766:	00004517          	auipc	a0,0x4
ffffffffc020076a:	44250513          	addi	a0,a0,1090 # ffffffffc0204ba8 <commands+0x7c0>
void print_trapframe(struct trapframe *tf) {
ffffffffc020076e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200770:	94fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200774:	8522                	mv	a0,s0
ffffffffc0200776:	e1bff0ef          	jal	ra,ffffffffc0200590 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020077a:	10043583          	ld	a1,256(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	44250513          	addi	a0,a0,1090 # ffffffffc0204bc0 <commands+0x7d8>
ffffffffc0200786:	939ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020078a:	10843583          	ld	a1,264(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	44a50513          	addi	a0,a0,1098 # ffffffffc0204bd8 <commands+0x7f0>
ffffffffc0200796:	929ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020079a:	11043583          	ld	a1,272(s0)
ffffffffc020079e:	00004517          	auipc	a0,0x4
ffffffffc02007a2:	45250513          	addi	a0,a0,1106 # ffffffffc0204bf0 <commands+0x808>
ffffffffc02007a6:	919ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007aa:	11843583          	ld	a1,280(s0)
}
ffffffffc02007ae:	6402                	ld	s0,0(sp)
ffffffffc02007b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007b2:	00004517          	auipc	a0,0x4
ffffffffc02007b6:	45650513          	addi	a0,a0,1110 # ffffffffc0204c08 <commands+0x820>
}
ffffffffc02007ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007bc:	903ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02007c0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007c0:	11853783          	ld	a5,280(a0)
ffffffffc02007c4:	577d                	li	a4,-1
ffffffffc02007c6:	8305                	srli	a4,a4,0x1
ffffffffc02007c8:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02007ca:	472d                	li	a4,11
ffffffffc02007cc:	06f76f63          	bltu	a4,a5,ffffffffc020084a <interrupt_handler+0x8a>
ffffffffc02007d0:	00004717          	auipc	a4,0x4
ffffffffc02007d4:	dac70713          	addi	a4,a4,-596 # ffffffffc020457c <commands+0x194>
ffffffffc02007d8:	078a                	slli	a5,a5,0x2
ffffffffc02007da:	97ba                	add	a5,a5,a4
ffffffffc02007dc:	439c                	lw	a5,0(a5)
ffffffffc02007de:	97ba                	add	a5,a5,a4
ffffffffc02007e0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	02650513          	addi	a0,a0,38 # ffffffffc0204808 <commands+0x420>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	ffa50513          	addi	a0,a0,-6 # ffffffffc02047e8 <commands+0x400>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007fa:	00004517          	auipc	a0,0x4
ffffffffc02007fe:	fae50513          	addi	a0,a0,-82 # ffffffffc02047a8 <commands+0x3c0>
ffffffffc0200802:	8bdff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200806:	00004517          	auipc	a0,0x4
ffffffffc020080a:	fc250513          	addi	a0,a0,-62 # ffffffffc02047c8 <commands+0x3e0>
ffffffffc020080e:	8b1ff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200812:	00004517          	auipc	a0,0x4
ffffffffc0200816:	02650513          	addi	a0,a0,38 # ffffffffc0204838 <commands+0x450>
ffffffffc020081a:	8a5ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200822:	c45ff0ef          	jal	ra,ffffffffc0200466 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200826:	00011797          	auipc	a5,0x11
ffffffffc020082a:	c5278793          	addi	a5,a5,-942 # ffffffffc0211478 <ticks>
ffffffffc020082e:	639c                	ld	a5,0(a5)
ffffffffc0200830:	06400713          	li	a4,100
ffffffffc0200834:	0785                	addi	a5,a5,1
ffffffffc0200836:	02e7f733          	remu	a4,a5,a4
ffffffffc020083a:	00011697          	auipc	a3,0x11
ffffffffc020083e:	c2f6bf23          	sd	a5,-962(a3) # ffffffffc0211478 <ticks>
ffffffffc0200842:	c711                	beqz	a4,ffffffffc020084e <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200844:	60a2                	ld	ra,8(sp)
ffffffffc0200846:	0141                	addi	sp,sp,16
ffffffffc0200848:	8082                	ret
            print_trapframe(tf);
ffffffffc020084a:	f15ff06f          	j	ffffffffc020075e <print_trapframe>
}
ffffffffc020084e:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200850:	06400593          	li	a1,100
ffffffffc0200854:	00004517          	auipc	a0,0x4
ffffffffc0200858:	fd450513          	addi	a0,a0,-44 # ffffffffc0204828 <commands+0x440>
}
ffffffffc020085c:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020085e:	861ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200862 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200862:	11853783          	ld	a5,280(a0)
ffffffffc0200866:	473d                	li	a4,15
ffffffffc0200868:	16f76563          	bltu	a4,a5,ffffffffc02009d2 <exception_handler+0x170>
ffffffffc020086c:	00004717          	auipc	a4,0x4
ffffffffc0200870:	d4070713          	addi	a4,a4,-704 # ffffffffc02045ac <commands+0x1c4>
ffffffffc0200874:	078a                	slli	a5,a5,0x2
ffffffffc0200876:	97ba                	add	a5,a5,a4
ffffffffc0200878:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc020087a:	1101                	addi	sp,sp,-32
ffffffffc020087c:	e822                	sd	s0,16(sp)
ffffffffc020087e:	ec06                	sd	ra,24(sp)
ffffffffc0200880:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200882:	97ba                	add	a5,a5,a4
ffffffffc0200884:	842a                	mv	s0,a0
ffffffffc0200886:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200888:	00004517          	auipc	a0,0x4
ffffffffc020088c:	f0850513          	addi	a0,a0,-248 # ffffffffc0204790 <commands+0x3a8>
ffffffffc0200890:	82fff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200894:	8522                	mv	a0,s0
ffffffffc0200896:	c6bff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc020089a:	84aa                	mv	s1,a0
ffffffffc020089c:	12051d63          	bnez	a0,ffffffffc02009d6 <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008a0:	60e2                	ld	ra,24(sp)
ffffffffc02008a2:	6442                	ld	s0,16(sp)
ffffffffc02008a4:	64a2                	ld	s1,8(sp)
ffffffffc02008a6:	6105                	addi	sp,sp,32
ffffffffc02008a8:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008aa:	00004517          	auipc	a0,0x4
ffffffffc02008ae:	d4650513          	addi	a0,a0,-698 # ffffffffc02045f0 <commands+0x208>
}
ffffffffc02008b2:	6442                	ld	s0,16(sp)
ffffffffc02008b4:	60e2                	ld	ra,24(sp)
ffffffffc02008b6:	64a2                	ld	s1,8(sp)
ffffffffc02008b8:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008ba:	805ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008be:	00004517          	auipc	a0,0x4
ffffffffc02008c2:	d5250513          	addi	a0,a0,-686 # ffffffffc0204610 <commands+0x228>
ffffffffc02008c6:	b7f5                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008c8:	00004517          	auipc	a0,0x4
ffffffffc02008cc:	d6850513          	addi	a0,a0,-664 # ffffffffc0204630 <commands+0x248>
ffffffffc02008d0:	b7cd                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008d2:	00004517          	auipc	a0,0x4
ffffffffc02008d6:	d7650513          	addi	a0,a0,-650 # ffffffffc0204648 <commands+0x260>
ffffffffc02008da:	bfe1                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008dc:	00004517          	auipc	a0,0x4
ffffffffc02008e0:	d7c50513          	addi	a0,a0,-644 # ffffffffc0204658 <commands+0x270>
ffffffffc02008e4:	b7f9                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008e6:	00004517          	auipc	a0,0x4
ffffffffc02008ea:	d9250513          	addi	a0,a0,-622 # ffffffffc0204678 <commands+0x290>
ffffffffc02008ee:	fd0ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008f2:	8522                	mv	a0,s0
ffffffffc02008f4:	c0dff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02008f8:	84aa                	mv	s1,a0
ffffffffc02008fa:	d15d                	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008fc:	8522                	mv	a0,s0
ffffffffc02008fe:	e61ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200902:	86a6                	mv	a3,s1
ffffffffc0200904:	00004617          	auipc	a2,0x4
ffffffffc0200908:	d8c60613          	addi	a2,a2,-628 # ffffffffc0204690 <commands+0x2a8>
ffffffffc020090c:	0ca00593          	li	a1,202
ffffffffc0200910:	00004517          	auipc	a0,0x4
ffffffffc0200914:	f8050513          	addi	a0,a0,-128 # ffffffffc0204890 <commands+0x4a8>
ffffffffc0200918:	feeff0ef          	jal	ra,ffffffffc0200106 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc020091c:	00004517          	auipc	a0,0x4
ffffffffc0200920:	d9450513          	addi	a0,a0,-620 # ffffffffc02046b0 <commands+0x2c8>
ffffffffc0200924:	b779                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200926:	00004517          	auipc	a0,0x4
ffffffffc020092a:	da250513          	addi	a0,a0,-606 # ffffffffc02046c8 <commands+0x2e0>
ffffffffc020092e:	f90ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200932:	8522                	mv	a0,s0
ffffffffc0200934:	bcdff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc0200938:	84aa                	mv	s1,a0
ffffffffc020093a:	d13d                	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020093c:	8522                	mv	a0,s0
ffffffffc020093e:	e21ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200942:	86a6                	mv	a3,s1
ffffffffc0200944:	00004617          	auipc	a2,0x4
ffffffffc0200948:	d4c60613          	addi	a2,a2,-692 # ffffffffc0204690 <commands+0x2a8>
ffffffffc020094c:	0d400593          	li	a1,212
ffffffffc0200950:	00004517          	auipc	a0,0x4
ffffffffc0200954:	f4050513          	addi	a0,a0,-192 # ffffffffc0204890 <commands+0x4a8>
ffffffffc0200958:	faeff0ef          	jal	ra,ffffffffc0200106 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc020095c:	00004517          	auipc	a0,0x4
ffffffffc0200960:	d8450513          	addi	a0,a0,-636 # ffffffffc02046e0 <commands+0x2f8>
ffffffffc0200964:	b7b9                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200966:	00004517          	auipc	a0,0x4
ffffffffc020096a:	d9a50513          	addi	a0,a0,-614 # ffffffffc0204700 <commands+0x318>
ffffffffc020096e:	b791                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200970:	00004517          	auipc	a0,0x4
ffffffffc0200974:	db050513          	addi	a0,a0,-592 # ffffffffc0204720 <commands+0x338>
ffffffffc0200978:	bf2d                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc020097a:	00004517          	auipc	a0,0x4
ffffffffc020097e:	dc650513          	addi	a0,a0,-570 # ffffffffc0204740 <commands+0x358>
ffffffffc0200982:	bf05                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200984:	00004517          	auipc	a0,0x4
ffffffffc0200988:	ddc50513          	addi	a0,a0,-548 # ffffffffc0204760 <commands+0x378>
ffffffffc020098c:	b71d                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc020098e:	00004517          	auipc	a0,0x4
ffffffffc0200992:	dea50513          	addi	a0,a0,-534 # ffffffffc0204778 <commands+0x390>
ffffffffc0200996:	f28ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020099a:	8522                	mv	a0,s0
ffffffffc020099c:	b65ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02009a0:	84aa                	mv	s1,a0
ffffffffc02009a2:	ee050fe3          	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009a6:	8522                	mv	a0,s0
ffffffffc02009a8:	db7ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ac:	86a6                	mv	a3,s1
ffffffffc02009ae:	00004617          	auipc	a2,0x4
ffffffffc02009b2:	ce260613          	addi	a2,a2,-798 # ffffffffc0204690 <commands+0x2a8>
ffffffffc02009b6:	0ea00593          	li	a1,234
ffffffffc02009ba:	00004517          	auipc	a0,0x4
ffffffffc02009be:	ed650513          	addi	a0,a0,-298 # ffffffffc0204890 <commands+0x4a8>
ffffffffc02009c2:	f44ff0ef          	jal	ra,ffffffffc0200106 <__panic>
}
ffffffffc02009c6:	6442                	ld	s0,16(sp)
ffffffffc02009c8:	60e2                	ld	ra,24(sp)
ffffffffc02009ca:	64a2                	ld	s1,8(sp)
ffffffffc02009cc:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009ce:	d91ff06f          	j	ffffffffc020075e <print_trapframe>
ffffffffc02009d2:	d8dff06f          	j	ffffffffc020075e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009d6:	8522                	mv	a0,s0
ffffffffc02009d8:	d87ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009dc:	86a6                	mv	a3,s1
ffffffffc02009de:	00004617          	auipc	a2,0x4
ffffffffc02009e2:	cb260613          	addi	a2,a2,-846 # ffffffffc0204690 <commands+0x2a8>
ffffffffc02009e6:	0f100593          	li	a1,241
ffffffffc02009ea:	00004517          	auipc	a0,0x4
ffffffffc02009ee:	ea650513          	addi	a0,a0,-346 # ffffffffc0204890 <commands+0x4a8>
ffffffffc02009f2:	f14ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02009f6 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009f6:	11853783          	ld	a5,280(a0)
ffffffffc02009fa:	0007c463          	bltz	a5,ffffffffc0200a02 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009fe:	e65ff06f          	j	ffffffffc0200862 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a02:	dbfff06f          	j	ffffffffc02007c0 <interrupt_handler>
	...

ffffffffc0200a10 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a10:	14011073          	csrw	sscratch,sp
ffffffffc0200a14:	712d                	addi	sp,sp,-288
ffffffffc0200a16:	e406                	sd	ra,8(sp)
ffffffffc0200a18:	ec0e                	sd	gp,24(sp)
ffffffffc0200a1a:	f012                	sd	tp,32(sp)
ffffffffc0200a1c:	f416                	sd	t0,40(sp)
ffffffffc0200a1e:	f81a                	sd	t1,48(sp)
ffffffffc0200a20:	fc1e                	sd	t2,56(sp)
ffffffffc0200a22:	e0a2                	sd	s0,64(sp)
ffffffffc0200a24:	e4a6                	sd	s1,72(sp)
ffffffffc0200a26:	e8aa                	sd	a0,80(sp)
ffffffffc0200a28:	ecae                	sd	a1,88(sp)
ffffffffc0200a2a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a2c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a2e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a30:	fcbe                	sd	a5,120(sp)
ffffffffc0200a32:	e142                	sd	a6,128(sp)
ffffffffc0200a34:	e546                	sd	a7,136(sp)
ffffffffc0200a36:	e94a                	sd	s2,144(sp)
ffffffffc0200a38:	ed4e                	sd	s3,152(sp)
ffffffffc0200a3a:	f152                	sd	s4,160(sp)
ffffffffc0200a3c:	f556                	sd	s5,168(sp)
ffffffffc0200a3e:	f95a                	sd	s6,176(sp)
ffffffffc0200a40:	fd5e                	sd	s7,184(sp)
ffffffffc0200a42:	e1e2                	sd	s8,192(sp)
ffffffffc0200a44:	e5e6                	sd	s9,200(sp)
ffffffffc0200a46:	e9ea                	sd	s10,208(sp)
ffffffffc0200a48:	edee                	sd	s11,216(sp)
ffffffffc0200a4a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a4c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a4e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a50:	fdfe                	sd	t6,248(sp)
ffffffffc0200a52:	14002473          	csrr	s0,sscratch
ffffffffc0200a56:	100024f3          	csrr	s1,sstatus
ffffffffc0200a5a:	14102973          	csrr	s2,sepc
ffffffffc0200a5e:	143029f3          	csrr	s3,stval
ffffffffc0200a62:	14202a73          	csrr	s4,scause
ffffffffc0200a66:	e822                	sd	s0,16(sp)
ffffffffc0200a68:	e226                	sd	s1,256(sp)
ffffffffc0200a6a:	e64a                	sd	s2,264(sp)
ffffffffc0200a6c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a6e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a70:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a72:	f85ff0ef          	jal	ra,ffffffffc02009f6 <trap>

ffffffffc0200a76 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a76:	6492                	ld	s1,256(sp)
ffffffffc0200a78:	6932                	ld	s2,264(sp)
ffffffffc0200a7a:	10049073          	csrw	sstatus,s1
ffffffffc0200a7e:	14191073          	csrw	sepc,s2
ffffffffc0200a82:	60a2                	ld	ra,8(sp)
ffffffffc0200a84:	61e2                	ld	gp,24(sp)
ffffffffc0200a86:	7202                	ld	tp,32(sp)
ffffffffc0200a88:	72a2                	ld	t0,40(sp)
ffffffffc0200a8a:	7342                	ld	t1,48(sp)
ffffffffc0200a8c:	73e2                	ld	t2,56(sp)
ffffffffc0200a8e:	6406                	ld	s0,64(sp)
ffffffffc0200a90:	64a6                	ld	s1,72(sp)
ffffffffc0200a92:	6546                	ld	a0,80(sp)
ffffffffc0200a94:	65e6                	ld	a1,88(sp)
ffffffffc0200a96:	7606                	ld	a2,96(sp)
ffffffffc0200a98:	76a6                	ld	a3,104(sp)
ffffffffc0200a9a:	7746                	ld	a4,112(sp)
ffffffffc0200a9c:	77e6                	ld	a5,120(sp)
ffffffffc0200a9e:	680a                	ld	a6,128(sp)
ffffffffc0200aa0:	68aa                	ld	a7,136(sp)
ffffffffc0200aa2:	694a                	ld	s2,144(sp)
ffffffffc0200aa4:	69ea                	ld	s3,152(sp)
ffffffffc0200aa6:	7a0a                	ld	s4,160(sp)
ffffffffc0200aa8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aaa:	7b4a                	ld	s6,176(sp)
ffffffffc0200aac:	7bea                	ld	s7,184(sp)
ffffffffc0200aae:	6c0e                	ld	s8,192(sp)
ffffffffc0200ab0:	6cae                	ld	s9,200(sp)
ffffffffc0200ab2:	6d4e                	ld	s10,208(sp)
ffffffffc0200ab4:	6dee                	ld	s11,216(sp)
ffffffffc0200ab6:	7e0e                	ld	t3,224(sp)
ffffffffc0200ab8:	7eae                	ld	t4,232(sp)
ffffffffc0200aba:	7f4e                	ld	t5,240(sp)
ffffffffc0200abc:	7fee                	ld	t6,248(sp)
ffffffffc0200abe:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200ac0:	10200073          	sret
	...

ffffffffc0200ad0 <_lru_init_mm>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ad0:	00011797          	auipc	a5,0x11
ffffffffc0200ad4:	9b078793          	addi	a5,a5,-1616 # ffffffffc0211480 <pra_list_head>
{     
    
    // 初始化
    list_init(&pra_list_head);
    // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
    mm->sm_priv = &pra_list_head;
ffffffffc0200ad8:	f51c                	sd	a5,40(a0)
ffffffffc0200ada:	e79c                	sd	a5,8(a5)
ffffffffc0200adc:	e39c                	sd	a5,0(a5)
    return 0;
}
ffffffffc0200ade:	4501                	li	a0,0
ffffffffc0200ae0:	8082                	ret

ffffffffc0200ae2 <_lru_swap_out_victim>:
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ae2:	00011697          	auipc	a3,0x11
ffffffffc0200ae6:	99e68693          	addi	a3,a3,-1634 # ffffffffc0211480 <pra_list_head>
ffffffffc0200aea:	6688                	ld	a0,8(a3)
{
    list_entry_t *entry = list_next(&pra_list_head);
    struct Page *victim = NULL;
    
    // 如果链表为空，没有可供置换的页面
    if (entry == &pra_list_head) {
ffffffffc0200aec:	04d50263          	beq	a0,a3,ffffffffc0200b30 <_lru_swap_out_victim+0x4e>
    }

    uint_t max_visited = 0;
    while (entry != &pra_list_head) {
        struct Page *page = le2page(entry, pra_page_link);
        if (page->visited >= max_visited) {
ffffffffc0200af0:	fe053603          	ld	a2,-32(a0)
        struct Page *page = le2page(entry, pra_page_link);
ffffffffc0200af4:	fd050893          	addi	a7,a0,-48
        if (page->visited >= max_visited) {
ffffffffc0200af8:	87aa                	mv	a5,a0
        struct Page *page = le2page(entry, pra_page_link);
ffffffffc0200afa:	8846                	mv	a6,a7
ffffffffc0200afc:	679c                	ld	a5,8(a5)
    while (entry != &pra_list_head) {
ffffffffc0200afe:	00d78c63          	beq	a5,a3,ffffffffc0200b16 <_lru_swap_out_victim+0x34>
        if (page->visited >= max_visited) {
ffffffffc0200b02:	fe07b703          	ld	a4,-32(a5)
ffffffffc0200b06:	fec76be3          	bltu	a4,a2,ffffffffc0200afc <_lru_swap_out_victim+0x1a>
        struct Page *page = le2page(entry, pra_page_link);
ffffffffc0200b0a:	fd078813          	addi	a6,a5,-48
ffffffffc0200b0e:	679c                	ld	a5,8(a5)
ffffffffc0200b10:	863a                	mv	a2,a4
    while (entry != &pra_list_head) {
ffffffffc0200b12:	fed798e3          	bne	a5,a3,ffffffffc0200b02 <_lru_swap_out_victim+0x20>
            max_visited = page->visited;
        }
        entry = list_next(entry);
    }

    if (victim == NULL) {
ffffffffc0200b16:	00080963          	beqz	a6,ffffffffc0200b28 <_lru_swap_out_victim+0x46>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b1a:	639c                	ld	a5,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200b1c:	e788                	sd	a0,8(a5)
    next->prev = prev;
ffffffffc0200b1e:	e11c                	sd	a5,0(a0)
        victim = le2page(entry, pra_page_link);
    }
    // 从链表中删除选中的页面
    list_del(entry);
    // 将选中的页面返回给 caller
    *ptr_page = victim;
ffffffffc0200b20:	0105b023          	sd	a6,0(a1)
    return 0;
}
ffffffffc0200b24:	4501                	li	a0,0
ffffffffc0200b26:	8082                	ret
    if (victim == NULL) {
ffffffffc0200b28:	87aa                	mv	a5,a0
        victim = le2page(entry, pra_page_link);
ffffffffc0200b2a:	8846                	mv	a6,a7
    if (victim == NULL) {
ffffffffc0200b2c:	6508                	ld	a0,8(a0)
ffffffffc0200b2e:	b7f5                	j	ffffffffc0200b1a <_lru_swap_out_victim+0x38>
        *ptr_page = NULL;
ffffffffc0200b30:	0005b023          	sd	zero,0(a1)
}
ffffffffc0200b34:	4501                	li	a0,0
ffffffffc0200b36:	8082                	ret

ffffffffc0200b38 <_lru_init>:

static int
_lru_init(void)
{
    return 0;
}
ffffffffc0200b38:	4501                	li	a0,0
ffffffffc0200b3a:	8082                	ret

ffffffffc0200b3c <_lru_set_unswappable>:

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0200b3c:	4501                	li	a0,0
ffffffffc0200b3e:	8082                	ret

ffffffffc0200b40 <_lru_tick_event>:

static int
_lru_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0200b40:	4501                	li	a0,0
ffffffffc0200b42:	8082                	ret

ffffffffc0200b44 <_lru_check_swap>:
_lru_check_swap(void) {
ffffffffc0200b44:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0200b46:	678d                	lui	a5,0x3
ffffffffc0200b48:	4731                	li	a4,12
_lru_check_swap(void) {
ffffffffc0200b4a:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0200b4c:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0200b50:	00011797          	auipc	a5,0x11
ffffffffc0200b54:	90078793          	addi	a5,a5,-1792 # ffffffffc0211450 <pgfault_num>
ffffffffc0200b58:	4398                	lw	a4,0(a5)
ffffffffc0200b5a:	4691                	li	a3,4
ffffffffc0200b5c:	2701                	sext.w	a4,a4
ffffffffc0200b5e:	08d71f63          	bne	a4,a3,ffffffffc0200bfc <_lru_check_swap+0xb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0200b62:	6685                	lui	a3,0x1
ffffffffc0200b64:	4629                	li	a2,10
ffffffffc0200b66:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0200b6a:	4394                	lw	a3,0(a5)
ffffffffc0200b6c:	2681                	sext.w	a3,a3
ffffffffc0200b6e:	20e69763          	bne	a3,a4,ffffffffc0200d7c <_lru_check_swap+0x238>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0200b72:	6711                	lui	a4,0x4
ffffffffc0200b74:	4635                	li	a2,13
ffffffffc0200b76:	00c70023          	sb	a2,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0200b7a:	4398                	lw	a4,0(a5)
ffffffffc0200b7c:	2701                	sext.w	a4,a4
ffffffffc0200b7e:	1cd71f63          	bne	a4,a3,ffffffffc0200d5c <_lru_check_swap+0x218>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0200b82:	6689                	lui	a3,0x2
ffffffffc0200b84:	462d                	li	a2,11
ffffffffc0200b86:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0200b8a:	4394                	lw	a3,0(a5)
ffffffffc0200b8c:	2681                	sext.w	a3,a3
ffffffffc0200b8e:	1ae69763          	bne	a3,a4,ffffffffc0200d3c <_lru_check_swap+0x1f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0200b92:	6715                	lui	a4,0x5
ffffffffc0200b94:	46b9                	li	a3,14
ffffffffc0200b96:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0200b9a:	4398                	lw	a4,0(a5)
ffffffffc0200b9c:	4695                	li	a3,5
ffffffffc0200b9e:	2701                	sext.w	a4,a4
ffffffffc0200ba0:	16d71e63          	bne	a4,a3,ffffffffc0200d1c <_lru_check_swap+0x1d8>
    assert(pgfault_num==5);
ffffffffc0200ba4:	4394                	lw	a3,0(a5)
ffffffffc0200ba6:	2681                	sext.w	a3,a3
ffffffffc0200ba8:	14e69a63          	bne	a3,a4,ffffffffc0200cfc <_lru_check_swap+0x1b8>
    assert(pgfault_num==5);
ffffffffc0200bac:	4398                	lw	a4,0(a5)
ffffffffc0200bae:	2701                	sext.w	a4,a4
ffffffffc0200bb0:	12d71663          	bne	a4,a3,ffffffffc0200cdc <_lru_check_swap+0x198>
    assert(pgfault_num==5);
ffffffffc0200bb4:	4394                	lw	a3,0(a5)
ffffffffc0200bb6:	2681                	sext.w	a3,a3
ffffffffc0200bb8:	10e69263          	bne	a3,a4,ffffffffc0200cbc <_lru_check_swap+0x178>
    assert(pgfault_num==5);
ffffffffc0200bbc:	4398                	lw	a4,0(a5)
ffffffffc0200bbe:	2701                	sext.w	a4,a4
ffffffffc0200bc0:	0cd71e63          	bne	a4,a3,ffffffffc0200c9c <_lru_check_swap+0x158>
    assert(pgfault_num==5);
ffffffffc0200bc4:	4394                	lw	a3,0(a5)
ffffffffc0200bc6:	2681                	sext.w	a3,a3
ffffffffc0200bc8:	0ae69a63          	bne	a3,a4,ffffffffc0200c7c <_lru_check_swap+0x138>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0200bcc:	6715                	lui	a4,0x5
ffffffffc0200bce:	46b9                	li	a3,14
ffffffffc0200bd0:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0200bd4:	4398                	lw	a4,0(a5)
ffffffffc0200bd6:	4695                	li	a3,5
ffffffffc0200bd8:	2701                	sext.w	a4,a4
ffffffffc0200bda:	08d71163          	bne	a4,a3,ffffffffc0200c5c <_lru_check_swap+0x118>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0200bde:	6705                	lui	a4,0x1
ffffffffc0200be0:	00074683          	lbu	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0200be4:	4729                	li	a4,10
ffffffffc0200be6:	04e69b63          	bne	a3,a4,ffffffffc0200c3c <_lru_check_swap+0xf8>
    assert(pgfault_num==6);
ffffffffc0200bea:	439c                	lw	a5,0(a5)
ffffffffc0200bec:	4719                	li	a4,6
ffffffffc0200bee:	2781                	sext.w	a5,a5
ffffffffc0200bf0:	02e79663          	bne	a5,a4,ffffffffc0200c1c <_lru_check_swap+0xd8>
}
ffffffffc0200bf4:	60a2                	ld	ra,8(sp)
ffffffffc0200bf6:	4501                	li	a0,0
ffffffffc0200bf8:	0141                	addi	sp,sp,16
ffffffffc0200bfa:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0200bfc:	00004697          	auipc	a3,0x4
ffffffffc0200c00:	02468693          	addi	a3,a3,36 # ffffffffc0204c20 <commands+0x838>
ffffffffc0200c04:	00004617          	auipc	a2,0x4
ffffffffc0200c08:	02c60613          	addi	a2,a2,44 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200c0c:	07400593          	li	a1,116
ffffffffc0200c10:	00004517          	auipc	a0,0x4
ffffffffc0200c14:	03850513          	addi	a0,a0,56 # ffffffffc0204c48 <commands+0x860>
ffffffffc0200c18:	ceeff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==6);
ffffffffc0200c1c:	00004697          	auipc	a3,0x4
ffffffffc0200c20:	07c68693          	addi	a3,a3,124 # ffffffffc0204c98 <commands+0x8b0>
ffffffffc0200c24:	00004617          	auipc	a2,0x4
ffffffffc0200c28:	00c60613          	addi	a2,a2,12 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200c2c:	08b00593          	li	a1,139
ffffffffc0200c30:	00004517          	auipc	a0,0x4
ffffffffc0200c34:	01850513          	addi	a0,a0,24 # ffffffffc0204c48 <commands+0x860>
ffffffffc0200c38:	cceff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0200c3c:	00004697          	auipc	a3,0x4
ffffffffc0200c40:	03468693          	addi	a3,a3,52 # ffffffffc0204c70 <commands+0x888>
ffffffffc0200c44:	00004617          	auipc	a2,0x4
ffffffffc0200c48:	fec60613          	addi	a2,a2,-20 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200c4c:	08900593          	li	a1,137
ffffffffc0200c50:	00004517          	auipc	a0,0x4
ffffffffc0200c54:	ff850513          	addi	a0,a0,-8 # ffffffffc0204c48 <commands+0x860>
ffffffffc0200c58:	caeff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0200c5c:	00004697          	auipc	a3,0x4
ffffffffc0200c60:	00468693          	addi	a3,a3,4 # ffffffffc0204c60 <commands+0x878>
ffffffffc0200c64:	00004617          	auipc	a2,0x4
ffffffffc0200c68:	fcc60613          	addi	a2,a2,-52 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200c6c:	08800593          	li	a1,136
ffffffffc0200c70:	00004517          	auipc	a0,0x4
ffffffffc0200c74:	fd850513          	addi	a0,a0,-40 # ffffffffc0204c48 <commands+0x860>
ffffffffc0200c78:	c8eff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0200c7c:	00004697          	auipc	a3,0x4
ffffffffc0200c80:	fe468693          	addi	a3,a3,-28 # ffffffffc0204c60 <commands+0x878>
ffffffffc0200c84:	00004617          	auipc	a2,0x4
ffffffffc0200c88:	fac60613          	addi	a2,a2,-84 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200c8c:	08600593          	li	a1,134
ffffffffc0200c90:	00004517          	auipc	a0,0x4
ffffffffc0200c94:	fb850513          	addi	a0,a0,-72 # ffffffffc0204c48 <commands+0x860>
ffffffffc0200c98:	c6eff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0200c9c:	00004697          	auipc	a3,0x4
ffffffffc0200ca0:	fc468693          	addi	a3,a3,-60 # ffffffffc0204c60 <commands+0x878>
ffffffffc0200ca4:	00004617          	auipc	a2,0x4
ffffffffc0200ca8:	f8c60613          	addi	a2,a2,-116 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200cac:	08400593          	li	a1,132
ffffffffc0200cb0:	00004517          	auipc	a0,0x4
ffffffffc0200cb4:	f9850513          	addi	a0,a0,-104 # ffffffffc0204c48 <commands+0x860>
ffffffffc0200cb8:	c4eff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0200cbc:	00004697          	auipc	a3,0x4
ffffffffc0200cc0:	fa468693          	addi	a3,a3,-92 # ffffffffc0204c60 <commands+0x878>
ffffffffc0200cc4:	00004617          	auipc	a2,0x4
ffffffffc0200cc8:	f6c60613          	addi	a2,a2,-148 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200ccc:	08200593          	li	a1,130
ffffffffc0200cd0:	00004517          	auipc	a0,0x4
ffffffffc0200cd4:	f7850513          	addi	a0,a0,-136 # ffffffffc0204c48 <commands+0x860>
ffffffffc0200cd8:	c2eff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0200cdc:	00004697          	auipc	a3,0x4
ffffffffc0200ce0:	f8468693          	addi	a3,a3,-124 # ffffffffc0204c60 <commands+0x878>
ffffffffc0200ce4:	00004617          	auipc	a2,0x4
ffffffffc0200ce8:	f4c60613          	addi	a2,a2,-180 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200cec:	08000593          	li	a1,128
ffffffffc0200cf0:	00004517          	auipc	a0,0x4
ffffffffc0200cf4:	f5850513          	addi	a0,a0,-168 # ffffffffc0204c48 <commands+0x860>
ffffffffc0200cf8:	c0eff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0200cfc:	00004697          	auipc	a3,0x4
ffffffffc0200d00:	f6468693          	addi	a3,a3,-156 # ffffffffc0204c60 <commands+0x878>
ffffffffc0200d04:	00004617          	auipc	a2,0x4
ffffffffc0200d08:	f2c60613          	addi	a2,a2,-212 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200d0c:	07e00593          	li	a1,126
ffffffffc0200d10:	00004517          	auipc	a0,0x4
ffffffffc0200d14:	f3850513          	addi	a0,a0,-200 # ffffffffc0204c48 <commands+0x860>
ffffffffc0200d18:	beeff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0200d1c:	00004697          	auipc	a3,0x4
ffffffffc0200d20:	f4468693          	addi	a3,a3,-188 # ffffffffc0204c60 <commands+0x878>
ffffffffc0200d24:	00004617          	auipc	a2,0x4
ffffffffc0200d28:	f0c60613          	addi	a2,a2,-244 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200d2c:	07c00593          	li	a1,124
ffffffffc0200d30:	00004517          	auipc	a0,0x4
ffffffffc0200d34:	f1850513          	addi	a0,a0,-232 # ffffffffc0204c48 <commands+0x860>
ffffffffc0200d38:	bceff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc0200d3c:	00004697          	auipc	a3,0x4
ffffffffc0200d40:	ee468693          	addi	a3,a3,-284 # ffffffffc0204c20 <commands+0x838>
ffffffffc0200d44:	00004617          	auipc	a2,0x4
ffffffffc0200d48:	eec60613          	addi	a2,a2,-276 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200d4c:	07a00593          	li	a1,122
ffffffffc0200d50:	00004517          	auipc	a0,0x4
ffffffffc0200d54:	ef850513          	addi	a0,a0,-264 # ffffffffc0204c48 <commands+0x860>
ffffffffc0200d58:	baeff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc0200d5c:	00004697          	auipc	a3,0x4
ffffffffc0200d60:	ec468693          	addi	a3,a3,-316 # ffffffffc0204c20 <commands+0x838>
ffffffffc0200d64:	00004617          	auipc	a2,0x4
ffffffffc0200d68:	ecc60613          	addi	a2,a2,-308 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200d6c:	07800593          	li	a1,120
ffffffffc0200d70:	00004517          	auipc	a0,0x4
ffffffffc0200d74:	ed850513          	addi	a0,a0,-296 # ffffffffc0204c48 <commands+0x860>
ffffffffc0200d78:	b8eff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc0200d7c:	00004697          	auipc	a3,0x4
ffffffffc0200d80:	ea468693          	addi	a3,a3,-348 # ffffffffc0204c20 <commands+0x838>
ffffffffc0200d84:	00004617          	auipc	a2,0x4
ffffffffc0200d88:	eac60613          	addi	a2,a2,-340 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200d8c:	07600593          	li	a1,118
ffffffffc0200d90:	00004517          	auipc	a0,0x4
ffffffffc0200d94:	eb850513          	addi	a0,a0,-328 # ffffffffc0204c48 <commands+0x860>
ffffffffc0200d98:	b6eff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200d9c <_lru_map_swappable>:
{
ffffffffc0200d9c:	1101                	addi	sp,sp,-32
ffffffffc0200d9e:	e426                	sd	s1,8(sp)
ffffffffc0200da0:	84aa                	mv	s1,a0
    cprintf("lru swappable done!");
ffffffffc0200da2:	00004517          	auipc	a0,0x4
ffffffffc0200da6:	f0650513          	addi	a0,a0,-250 # ffffffffc0204ca8 <commands+0x8c0>
{
ffffffffc0200daa:	e822                	sd	s0,16(sp)
ffffffffc0200dac:	ec06                	sd	ra,24(sp)
ffffffffc0200dae:	8432                	mv	s0,a2
    cprintf("lru swappable done!");
ffffffffc0200db0:	b0eff0ef          	jal	ra,ffffffffc02000be <cprintf>
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0200db4:	03040713          	addi	a4,s0,48
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0200db8:	749c                	ld	a5,40(s1)
    assert(entry != NULL && head!= NULL);
ffffffffc0200dba:	c315                	beqz	a4,ffffffffc0200dde <_lru_map_swappable+0x42>
ffffffffc0200dbc:	c38d                	beqz	a5,ffffffffc0200dde <_lru_map_swappable+0x42>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200dbe:	6790                	ld	a2,8(a5)
    page->visited |= mask;  // 以访问便按位或，将最高位设置为1
ffffffffc0200dc0:	6814                	ld	a3,16(s0)
}
ffffffffc0200dc2:	60e2                	ld	ra,24(sp)
    prev->next = next->prev = elm;
ffffffffc0200dc4:	e218                	sd	a4,0(a2)
ffffffffc0200dc6:	e798                	sd	a4,8(a5)
    page->visited |= mask;  // 以访问便按位或，将最高位设置为1
ffffffffc0200dc8:	577d                	li	a4,-1
ffffffffc0200dca:	177e                	slli	a4,a4,0x3f
ffffffffc0200dcc:	8f55                	or	a4,a4,a3
    elm->next = next;
ffffffffc0200dce:	fc10                	sd	a2,56(s0)
    elm->prev = prev;
ffffffffc0200dd0:	f81c                	sd	a5,48(s0)
ffffffffc0200dd2:	e818                	sd	a4,16(s0)
}
ffffffffc0200dd4:	6442                	ld	s0,16(sp)
ffffffffc0200dd6:	64a2                	ld	s1,8(sp)
ffffffffc0200dd8:	4501                	li	a0,0
ffffffffc0200dda:	6105                	addi	sp,sp,32
ffffffffc0200ddc:	8082                	ret
    assert(entry != NULL && head!= NULL);
ffffffffc0200dde:	00004697          	auipc	a3,0x4
ffffffffc0200de2:	ee268693          	addi	a3,a3,-286 # ffffffffc0204cc0 <commands+0x8d8>
ffffffffc0200de6:	00004617          	auipc	a2,0x4
ffffffffc0200dea:	e4a60613          	addi	a2,a2,-438 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200dee:	02100593          	li	a1,33
ffffffffc0200df2:	00004517          	auipc	a0,0x4
ffffffffc0200df6:	e5650513          	addi	a0,a0,-426 # ffffffffc0204c48 <commands+0x860>
ffffffffc0200dfa:	b0cff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200dfe <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {// 检查是否覆盖
ffffffffc0200dfe:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200e00:	00004697          	auipc	a3,0x4
ffffffffc0200e04:	ef868693          	addi	a3,a3,-264 # ffffffffc0204cf8 <commands+0x910>
ffffffffc0200e08:	00004617          	auipc	a2,0x4
ffffffffc0200e0c:	e2860613          	addi	a2,a2,-472 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200e10:	07d00593          	li	a1,125
ffffffffc0200e14:	00004517          	auipc	a0,0x4
ffffffffc0200e18:	f0450513          	addi	a0,a0,-252 # ffffffffc0204d18 <commands+0x930>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {// 检查是否覆盖
ffffffffc0200e1c:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200e1e:	ae8ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200e22 <mm_create>:
mm_create(void) {
ffffffffc0200e22:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e24:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0200e28:	e022                	sd	s0,0(sp)
ffffffffc0200e2a:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e2c:	3eb020ef          	jal	ra,ffffffffc0203a16 <kmalloc>
ffffffffc0200e30:	842a                	mv	s0,a0
    if (mm != NULL) {// 初始化
ffffffffc0200e32:	c115                	beqz	a0,ffffffffc0200e56 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200e34:	00010797          	auipc	a5,0x10
ffffffffc0200e38:	62c78793          	addi	a5,a5,1580 # ffffffffc0211460 <swap_init_ok>
ffffffffc0200e3c:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0200e3e:	e408                	sd	a0,8(s0)
ffffffffc0200e40:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200e42:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200e46:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200e4a:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200e4e:	2781                	sext.w	a5,a5
ffffffffc0200e50:	eb81                	bnez	a5,ffffffffc0200e60 <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0200e52:	02053423          	sd	zero,40(a0)
}
ffffffffc0200e56:	8522                	mv	a0,s0
ffffffffc0200e58:	60a2                	ld	ra,8(sp)
ffffffffc0200e5a:	6402                	ld	s0,0(sp)
ffffffffc0200e5c:	0141                	addi	sp,sp,16
ffffffffc0200e5e:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200e60:	64f000ef          	jal	ra,ffffffffc0201cae <swap_init_mm>
}
ffffffffc0200e64:	8522                	mv	a0,s0
ffffffffc0200e66:	60a2                	ld	ra,8(sp)
ffffffffc0200e68:	6402                	ld	s0,0(sp)
ffffffffc0200e6a:	0141                	addi	sp,sp,16
ffffffffc0200e6c:	8082                	ret

ffffffffc0200e6e <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200e6e:	1101                	addi	sp,sp,-32
ffffffffc0200e70:	e04a                	sd	s2,0(sp)
ffffffffc0200e72:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200e74:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200e78:	e822                	sd	s0,16(sp)
ffffffffc0200e7a:	e426                	sd	s1,8(sp)
ffffffffc0200e7c:	ec06                	sd	ra,24(sp)
ffffffffc0200e7e:	84ae                	mv	s1,a1
ffffffffc0200e80:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200e82:	395020ef          	jal	ra,ffffffffc0203a16 <kmalloc>
    if (vma != NULL) {
ffffffffc0200e86:	c509                	beqz	a0,ffffffffc0200e90 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200e88:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200e8c:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200e8e:	ed00                	sd	s0,24(a0)
}
ffffffffc0200e90:	60e2                	ld	ra,24(sp)
ffffffffc0200e92:	6442                	ld	s0,16(sp)
ffffffffc0200e94:	64a2                	ld	s1,8(sp)
ffffffffc0200e96:	6902                	ld	s2,0(sp)
ffffffffc0200e98:	6105                	addi	sp,sp,32
ffffffffc0200e9a:	8082                	ret

ffffffffc0200e9c <find_vma>:
    if (mm != NULL) {
ffffffffc0200e9c:	c51d                	beqz	a0,ffffffffc0200eca <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0200e9e:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200ea0:	c781                	beqz	a5,ffffffffc0200ea8 <find_vma+0xc>
ffffffffc0200ea2:	6798                	ld	a4,8(a5)
ffffffffc0200ea4:	02e5f663          	bleu	a4,a1,ffffffffc0200ed0 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0200ea8:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc0200eaa:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200eac:	00f50f63          	beq	a0,a5,ffffffffc0200eca <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200eb0:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200eb4:	fee5ebe3          	bltu	a1,a4,ffffffffc0200eaa <find_vma+0xe>
ffffffffc0200eb8:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200ebc:	fee5f7e3          	bleu	a4,a1,ffffffffc0200eaa <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0200ec0:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0200ec2:	c781                	beqz	a5,ffffffffc0200eca <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0200ec4:	e91c                	sd	a5,16(a0)
}
ffffffffc0200ec6:	853e                	mv	a0,a5
ffffffffc0200ec8:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0200eca:	4781                	li	a5,0
}
ffffffffc0200ecc:	853e                	mv	a0,a5
ffffffffc0200ece:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200ed0:	6b98                	ld	a4,16(a5)
ffffffffc0200ed2:	fce5fbe3          	bleu	a4,a1,ffffffffc0200ea8 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0200ed6:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0200ed8:	b7fd                	j	ffffffffc0200ec6 <find_vma+0x2a>

ffffffffc0200eda <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {// 插入vma
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200eda:	6590                	ld	a2,8(a1)
ffffffffc0200edc:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {// 插入vma
ffffffffc0200ee0:	1141                	addi	sp,sp,-16
ffffffffc0200ee2:	e406                	sd	ra,8(sp)
ffffffffc0200ee4:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200ee6:	01066863          	bltu	a2,a6,ffffffffc0200ef6 <insert_vma_struct+0x1c>
ffffffffc0200eea:	a8b9                	j	ffffffffc0200f48 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {// 比较vma的start地址，按地址排序
ffffffffc0200eec:	fe87b683          	ld	a3,-24(a5)
ffffffffc0200ef0:	04d66763          	bltu	a2,a3,ffffffffc0200f3e <insert_vma_struct+0x64>
ffffffffc0200ef4:	873e                	mv	a4,a5
ffffffffc0200ef6:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0200ef8:	fef51ae3          	bne	a0,a5,ffffffffc0200eec <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200efc:	02a70463          	beq	a4,a0,ffffffffc0200f24 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200f00:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200f04:	fe873883          	ld	a7,-24(a4)
ffffffffc0200f08:	08d8f063          	bleu	a3,a7,ffffffffc0200f88 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f0c:	04d66e63          	bltu	a2,a3,ffffffffc0200f68 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0200f10:	00f50a63          	beq	a0,a5,ffffffffc0200f24 <insert_vma_struct+0x4a>
ffffffffc0200f14:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f18:	0506e863          	bltu	a3,a6,ffffffffc0200f68 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0200f1c:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200f20:	02c6f263          	bleu	a2,a3,ffffffffc0200f44 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200f24:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0200f26:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200f28:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0200f2c:	e390                	sd	a2,0(a5)
ffffffffc0200f2e:	e710                	sd	a2,8(a4)
}
ffffffffc0200f30:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200f32:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200f34:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0200f36:	2685                	addiw	a3,a3,1
ffffffffc0200f38:	d114                	sw	a3,32(a0)
}
ffffffffc0200f3a:	0141                	addi	sp,sp,16
ffffffffc0200f3c:	8082                	ret
    if (le_prev != list) {
ffffffffc0200f3e:	fca711e3          	bne	a4,a0,ffffffffc0200f00 <insert_vma_struct+0x26>
ffffffffc0200f42:	bfd9                	j	ffffffffc0200f18 <insert_vma_struct+0x3e>
ffffffffc0200f44:	ebbff0ef          	jal	ra,ffffffffc0200dfe <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f48:	00004697          	auipc	a3,0x4
ffffffffc0200f4c:	e7068693          	addi	a3,a3,-400 # ffffffffc0204db8 <commands+0x9d0>
ffffffffc0200f50:	00004617          	auipc	a2,0x4
ffffffffc0200f54:	ce060613          	addi	a2,a2,-800 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200f58:	08400593          	li	a1,132
ffffffffc0200f5c:	00004517          	auipc	a0,0x4
ffffffffc0200f60:	dbc50513          	addi	a0,a0,-580 # ffffffffc0204d18 <commands+0x930>
ffffffffc0200f64:	9a2ff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f68:	00004697          	auipc	a3,0x4
ffffffffc0200f6c:	e9068693          	addi	a3,a3,-368 # ffffffffc0204df8 <commands+0xa10>
ffffffffc0200f70:	00004617          	auipc	a2,0x4
ffffffffc0200f74:	cc060613          	addi	a2,a2,-832 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200f78:	07c00593          	li	a1,124
ffffffffc0200f7c:	00004517          	auipc	a0,0x4
ffffffffc0200f80:	d9c50513          	addi	a0,a0,-612 # ffffffffc0204d18 <commands+0x930>
ffffffffc0200f84:	982ff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200f88:	00004697          	auipc	a3,0x4
ffffffffc0200f8c:	e5068693          	addi	a3,a3,-432 # ffffffffc0204dd8 <commands+0x9f0>
ffffffffc0200f90:	00004617          	auipc	a2,0x4
ffffffffc0200f94:	ca060613          	addi	a2,a2,-864 # ffffffffc0204c30 <commands+0x848>
ffffffffc0200f98:	07b00593          	li	a1,123
ffffffffc0200f9c:	00004517          	auipc	a0,0x4
ffffffffc0200fa0:	d7c50513          	addi	a0,a0,-644 # ffffffffc0204d18 <commands+0x930>
ffffffffc0200fa4:	962ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200fa8 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0200fa8:	1141                	addi	sp,sp,-16
ffffffffc0200faa:	e022                	sd	s0,0(sp)
ffffffffc0200fac:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200fae:	6508                	ld	a0,8(a0)
ffffffffc0200fb0:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200fb2:	00a40e63          	beq	s0,a0,ffffffffc0200fce <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200fb6:	6118                	ld	a4,0(a0)
ffffffffc0200fb8:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200fba:	03000593          	li	a1,48
ffffffffc0200fbe:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0200fc0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200fc2:	e398                	sd	a4,0(a5)
ffffffffc0200fc4:	315020ef          	jal	ra,ffffffffc0203ad8 <kfree>
    return listelm->next;
ffffffffc0200fc8:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200fca:	fea416e3          	bne	s0,a0,ffffffffc0200fb6 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200fce:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0200fd0:	6402                	ld	s0,0(sp)
ffffffffc0200fd2:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200fd4:	03000593          	li	a1,48
}
ffffffffc0200fd8:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200fda:	2ff0206f          	j	ffffffffc0203ad8 <kfree>

ffffffffc0200fde <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0200fde:	715d                	addi	sp,sp,-80
ffffffffc0200fe0:	e486                	sd	ra,72(sp)
ffffffffc0200fe2:	e0a2                	sd	s0,64(sp)
ffffffffc0200fe4:	fc26                	sd	s1,56(sp)
ffffffffc0200fe6:	f84a                	sd	s2,48(sp)
ffffffffc0200fe8:	f052                	sd	s4,32(sp)
ffffffffc0200fea:	f44e                	sd	s3,40(sp)
ffffffffc0200fec:	ec56                	sd	s5,24(sp)
ffffffffc0200fee:	e85a                	sd	s6,16(sp)
ffffffffc0200ff0:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200ff2:	2c7010ef          	jal	ra,ffffffffc0202ab8 <nr_free_pages>
ffffffffc0200ff6:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200ff8:	2c1010ef          	jal	ra,ffffffffc0202ab8 <nr_free_pages>
ffffffffc0200ffc:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc0200ffe:	e25ff0ef          	jal	ra,ffffffffc0200e22 <mm_create>
    assert(mm != NULL);
ffffffffc0201002:	842a                	mv	s0,a0
ffffffffc0201004:	03200493          	li	s1,50
ffffffffc0201008:	e919                	bnez	a0,ffffffffc020101e <vmm_init+0x40>
ffffffffc020100a:	aeed                	j	ffffffffc0201404 <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc020100c:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020100e:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201010:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201014:	14ed                	addi	s1,s1,-5
ffffffffc0201016:	8522                	mv	a0,s0
ffffffffc0201018:	ec3ff0ef          	jal	ra,ffffffffc0200eda <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc020101c:	c88d                	beqz	s1,ffffffffc020104e <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020101e:	03000513          	li	a0,48
ffffffffc0201022:	1f5020ef          	jal	ra,ffffffffc0203a16 <kmalloc>
ffffffffc0201026:	85aa                	mv	a1,a0
ffffffffc0201028:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc020102c:	f165                	bnez	a0,ffffffffc020100c <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc020102e:	00004697          	auipc	a3,0x4
ffffffffc0201032:	04268693          	addi	a3,a3,66 # ffffffffc0205070 <commands+0xc88>
ffffffffc0201036:	00004617          	auipc	a2,0x4
ffffffffc020103a:	bfa60613          	addi	a2,a2,-1030 # ffffffffc0204c30 <commands+0x848>
ffffffffc020103e:	0ce00593          	li	a1,206
ffffffffc0201042:	00004517          	auipc	a0,0x4
ffffffffc0201046:	cd650513          	addi	a0,a0,-810 # ffffffffc0204d18 <commands+0x930>
ffffffffc020104a:	8bcff0ef          	jal	ra,ffffffffc0200106 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc020104e:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201052:	1f900993          	li	s3,505
ffffffffc0201056:	a819                	j	ffffffffc020106c <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc0201058:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020105a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020105c:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201060:	0495                	addi	s1,s1,5
ffffffffc0201062:	8522                	mv	a0,s0
ffffffffc0201064:	e77ff0ef          	jal	ra,ffffffffc0200eda <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201068:	03348a63          	beq	s1,s3,ffffffffc020109c <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020106c:	03000513          	li	a0,48
ffffffffc0201070:	1a7020ef          	jal	ra,ffffffffc0203a16 <kmalloc>
ffffffffc0201074:	85aa                	mv	a1,a0
ffffffffc0201076:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc020107a:	fd79                	bnez	a0,ffffffffc0201058 <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc020107c:	00004697          	auipc	a3,0x4
ffffffffc0201080:	ff468693          	addi	a3,a3,-12 # ffffffffc0205070 <commands+0xc88>
ffffffffc0201084:	00004617          	auipc	a2,0x4
ffffffffc0201088:	bac60613          	addi	a2,a2,-1108 # ffffffffc0204c30 <commands+0x848>
ffffffffc020108c:	0d400593          	li	a1,212
ffffffffc0201090:	00004517          	auipc	a0,0x4
ffffffffc0201094:	c8850513          	addi	a0,a0,-888 # ffffffffc0204d18 <commands+0x930>
ffffffffc0201098:	86eff0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc020109c:	6418                	ld	a4,8(s0)
ffffffffc020109e:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02010a0:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02010a4:	2ae40063          	beq	s0,a4,ffffffffc0201344 <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02010a8:	fe873603          	ld	a2,-24(a4)
ffffffffc02010ac:	ffe78693          	addi	a3,a5,-2
ffffffffc02010b0:	20d61a63          	bne	a2,a3,ffffffffc02012c4 <vmm_init+0x2e6>
ffffffffc02010b4:	ff073683          	ld	a3,-16(a4)
ffffffffc02010b8:	20d79663          	bne	a5,a3,ffffffffc02012c4 <vmm_init+0x2e6>
ffffffffc02010bc:	0795                	addi	a5,a5,5
ffffffffc02010be:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc02010c0:	feb792e3          	bne	a5,a1,ffffffffc02010a4 <vmm_init+0xc6>
ffffffffc02010c4:	499d                	li	s3,7
ffffffffc02010c6:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02010c8:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02010cc:	85a6                	mv	a1,s1
ffffffffc02010ce:	8522                	mv	a0,s0
ffffffffc02010d0:	dcdff0ef          	jal	ra,ffffffffc0200e9c <find_vma>
ffffffffc02010d4:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc02010d6:	2e050763          	beqz	a0,ffffffffc02013c4 <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02010da:	00148593          	addi	a1,s1,1
ffffffffc02010de:	8522                	mv	a0,s0
ffffffffc02010e0:	dbdff0ef          	jal	ra,ffffffffc0200e9c <find_vma>
ffffffffc02010e4:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc02010e6:	2a050f63          	beqz	a0,ffffffffc02013a4 <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02010ea:	85ce                	mv	a1,s3
ffffffffc02010ec:	8522                	mv	a0,s0
ffffffffc02010ee:	dafff0ef          	jal	ra,ffffffffc0200e9c <find_vma>
        assert(vma3 == NULL);
ffffffffc02010f2:	28051963          	bnez	a0,ffffffffc0201384 <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02010f6:	00348593          	addi	a1,s1,3
ffffffffc02010fa:	8522                	mv	a0,s0
ffffffffc02010fc:	da1ff0ef          	jal	ra,ffffffffc0200e9c <find_vma>
        assert(vma4 == NULL);
ffffffffc0201100:	26051263          	bnez	a0,ffffffffc0201364 <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0201104:	00448593          	addi	a1,s1,4
ffffffffc0201108:	8522                	mv	a0,s0
ffffffffc020110a:	d93ff0ef          	jal	ra,ffffffffc0200e9c <find_vma>
        assert(vma5 == NULL);
ffffffffc020110e:	2c051b63          	bnez	a0,ffffffffc02013e4 <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201112:	008b3783          	ld	a5,8(s6)
ffffffffc0201116:	1c979763          	bne	a5,s1,ffffffffc02012e4 <vmm_init+0x306>
ffffffffc020111a:	010b3783          	ld	a5,16(s6)
ffffffffc020111e:	1d379363          	bne	a5,s3,ffffffffc02012e4 <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201122:	008ab783          	ld	a5,8(s5)
ffffffffc0201126:	1c979f63          	bne	a5,s1,ffffffffc0201304 <vmm_init+0x326>
ffffffffc020112a:	010ab783          	ld	a5,16(s5)
ffffffffc020112e:	1d379b63          	bne	a5,s3,ffffffffc0201304 <vmm_init+0x326>
ffffffffc0201132:	0495                	addi	s1,s1,5
ffffffffc0201134:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201136:	f9749be3          	bne	s1,s7,ffffffffc02010cc <vmm_init+0xee>
ffffffffc020113a:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc020113c:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020113e:	85a6                	mv	a1,s1
ffffffffc0201140:	8522                	mv	a0,s0
ffffffffc0201142:	d5bff0ef          	jal	ra,ffffffffc0200e9c <find_vma>
ffffffffc0201146:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc020114a:	c90d                	beqz	a0,ffffffffc020117c <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc020114c:	6914                	ld	a3,16(a0)
ffffffffc020114e:	6510                	ld	a2,8(a0)
ffffffffc0201150:	00004517          	auipc	a0,0x4
ffffffffc0201154:	dd850513          	addi	a0,a0,-552 # ffffffffc0204f28 <commands+0xb40>
ffffffffc0201158:	f67fe0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020115c:	00004697          	auipc	a3,0x4
ffffffffc0201160:	df468693          	addi	a3,a3,-524 # ffffffffc0204f50 <commands+0xb68>
ffffffffc0201164:	00004617          	auipc	a2,0x4
ffffffffc0201168:	acc60613          	addi	a2,a2,-1332 # ffffffffc0204c30 <commands+0x848>
ffffffffc020116c:	0f600593          	li	a1,246
ffffffffc0201170:	00004517          	auipc	a0,0x4
ffffffffc0201174:	ba850513          	addi	a0,a0,-1112 # ffffffffc0204d18 <commands+0x930>
ffffffffc0201178:	f8ffe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc020117c:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc020117e:	fd3490e3          	bne	s1,s3,ffffffffc020113e <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc0201182:	8522                	mv	a0,s0
ffffffffc0201184:	e25ff0ef          	jal	ra,ffffffffc0200fa8 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201188:	131010ef          	jal	ra,ffffffffc0202ab8 <nr_free_pages>
ffffffffc020118c:	28aa1c63          	bne	s4,a0,ffffffffc0201424 <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0201190:	00004517          	auipc	a0,0x4
ffffffffc0201194:	e0050513          	addi	a0,a0,-512 # ffffffffc0204f90 <commands+0xba8>
ffffffffc0201198:	f27fe0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020119c:	11d010ef          	jal	ra,ffffffffc0202ab8 <nr_free_pages>
ffffffffc02011a0:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02011a2:	c81ff0ef          	jal	ra,ffffffffc0200e22 <mm_create>
ffffffffc02011a6:	00010797          	auipc	a5,0x10
ffffffffc02011aa:	2ea7b523          	sd	a0,746(a5) # ffffffffc0211490 <check_mm_struct>
ffffffffc02011ae:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc02011b0:	2a050a63          	beqz	a0,ffffffffc0201464 <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02011b4:	00010797          	auipc	a5,0x10
ffffffffc02011b8:	2b478793          	addi	a5,a5,692 # ffffffffc0211468 <boot_pgdir>
ffffffffc02011bc:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc02011be:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02011c0:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02011c2:	32079d63          	bnez	a5,ffffffffc02014fc <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02011c6:	03000513          	li	a0,48
ffffffffc02011ca:	04d020ef          	jal	ra,ffffffffc0203a16 <kmalloc>
ffffffffc02011ce:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc02011d0:	14050a63          	beqz	a0,ffffffffc0201324 <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc02011d4:	002007b7          	lui	a5,0x200
ffffffffc02011d8:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc02011dc:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02011de:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02011e0:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc02011e4:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02011e6:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc02011ea:	cf1ff0ef          	jal	ra,ffffffffc0200eda <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02011ee:	10000593          	li	a1,256
ffffffffc02011f2:	8522                	mv	a0,s0
ffffffffc02011f4:	ca9ff0ef          	jal	ra,ffffffffc0200e9c <find_vma>
ffffffffc02011f8:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc02011fc:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0201200:	2aaa1263          	bne	s4,a0,ffffffffc02014a4 <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc0201204:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0201208:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc020120a:	fee79de3          	bne	a5,a4,ffffffffc0201204 <vmm_init+0x226>
        sum += i;
ffffffffc020120e:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0201210:	10000793          	li	a5,256
        sum += i;
ffffffffc0201214:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0201218:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020121c:	0007c683          	lbu	a3,0(a5)
ffffffffc0201220:	0785                	addi	a5,a5,1
ffffffffc0201222:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0201224:	fec79ce3          	bne	a5,a2,ffffffffc020121c <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc0201228:	2a071a63          	bnez	a4,ffffffffc02014dc <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc020122c:	4581                	li	a1,0
ffffffffc020122e:	8526                	mv	a0,s1
ffffffffc0201230:	32f010ef          	jal	ra,ffffffffc0202d5e <page_remove>
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0201234:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0201236:	00010717          	auipc	a4,0x10
ffffffffc020123a:	23a70713          	addi	a4,a4,570 # ffffffffc0211470 <npage>
ffffffffc020123e:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201240:	078a                	slli	a5,a5,0x2
ffffffffc0201242:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201244:	28e7f063          	bleu	a4,a5,ffffffffc02014c4 <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc0201248:	00005717          	auipc	a4,0x5
ffffffffc020124c:	e3870713          	addi	a4,a4,-456 # ffffffffc0206080 <nbase>
ffffffffc0201250:	6318                	ld	a4,0(a4)
ffffffffc0201252:	00010697          	auipc	a3,0x10
ffffffffc0201256:	33e68693          	addi	a3,a3,830 # ffffffffc0211590 <pages>
ffffffffc020125a:	6288                	ld	a0,0(a3)
ffffffffc020125c:	8f99                	sub	a5,a5,a4
ffffffffc020125e:	00379713          	slli	a4,a5,0x3
ffffffffc0201262:	97ba                	add	a5,a5,a4
ffffffffc0201264:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0201266:	953e                	add	a0,a0,a5
ffffffffc0201268:	4585                	li	a1,1
ffffffffc020126a:	009010ef          	jal	ra,ffffffffc0202a72 <free_pages>

    pgdir[0] = 0;
ffffffffc020126e:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc0201272:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0201274:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0201278:	d31ff0ef          	jal	ra,ffffffffc0200fa8 <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc020127c:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc020127e:	00010797          	auipc	a5,0x10
ffffffffc0201282:	2007b923          	sd	zero,530(a5) # ffffffffc0211490 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201286:	033010ef          	jal	ra,ffffffffc0202ab8 <nr_free_pages>
ffffffffc020128a:	1aa99d63          	bne	s3,a0,ffffffffc0201444 <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020128e:	00004517          	auipc	a0,0x4
ffffffffc0201292:	daa50513          	addi	a0,a0,-598 # ffffffffc0205038 <commands+0xc50>
ffffffffc0201296:	e29fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020129a:	01f010ef          	jal	ra,ffffffffc0202ab8 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc020129e:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02012a0:	1ea91263          	bne	s2,a0,ffffffffc0201484 <vmm_init+0x4a6>
}
ffffffffc02012a4:	6406                	ld	s0,64(sp)
ffffffffc02012a6:	60a6                	ld	ra,72(sp)
ffffffffc02012a8:	74e2                	ld	s1,56(sp)
ffffffffc02012aa:	7942                	ld	s2,48(sp)
ffffffffc02012ac:	79a2                	ld	s3,40(sp)
ffffffffc02012ae:	7a02                	ld	s4,32(sp)
ffffffffc02012b0:	6ae2                	ld	s5,24(sp)
ffffffffc02012b2:	6b42                	ld	s6,16(sp)
ffffffffc02012b4:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02012b6:	00004517          	auipc	a0,0x4
ffffffffc02012ba:	da250513          	addi	a0,a0,-606 # ffffffffc0205058 <commands+0xc70>
}
ffffffffc02012be:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc02012c0:	dfffe06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02012c4:	00004697          	auipc	a3,0x4
ffffffffc02012c8:	b7c68693          	addi	a3,a3,-1156 # ffffffffc0204e40 <commands+0xa58>
ffffffffc02012cc:	00004617          	auipc	a2,0x4
ffffffffc02012d0:	96460613          	addi	a2,a2,-1692 # ffffffffc0204c30 <commands+0x848>
ffffffffc02012d4:	0dd00593          	li	a1,221
ffffffffc02012d8:	00004517          	auipc	a0,0x4
ffffffffc02012dc:	a4050513          	addi	a0,a0,-1472 # ffffffffc0204d18 <commands+0x930>
ffffffffc02012e0:	e27fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02012e4:	00004697          	auipc	a3,0x4
ffffffffc02012e8:	be468693          	addi	a3,a3,-1052 # ffffffffc0204ec8 <commands+0xae0>
ffffffffc02012ec:	00004617          	auipc	a2,0x4
ffffffffc02012f0:	94460613          	addi	a2,a2,-1724 # ffffffffc0204c30 <commands+0x848>
ffffffffc02012f4:	0ed00593          	li	a1,237
ffffffffc02012f8:	00004517          	auipc	a0,0x4
ffffffffc02012fc:	a2050513          	addi	a0,a0,-1504 # ffffffffc0204d18 <commands+0x930>
ffffffffc0201300:	e07fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201304:	00004697          	auipc	a3,0x4
ffffffffc0201308:	bf468693          	addi	a3,a3,-1036 # ffffffffc0204ef8 <commands+0xb10>
ffffffffc020130c:	00004617          	auipc	a2,0x4
ffffffffc0201310:	92460613          	addi	a2,a2,-1756 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201314:	0ee00593          	li	a1,238
ffffffffc0201318:	00004517          	auipc	a0,0x4
ffffffffc020131c:	a0050513          	addi	a0,a0,-1536 # ffffffffc0204d18 <commands+0x930>
ffffffffc0201320:	de7fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(vma != NULL);
ffffffffc0201324:	00004697          	auipc	a3,0x4
ffffffffc0201328:	d4c68693          	addi	a3,a3,-692 # ffffffffc0205070 <commands+0xc88>
ffffffffc020132c:	00004617          	auipc	a2,0x4
ffffffffc0201330:	90460613          	addi	a2,a2,-1788 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201334:	11100593          	li	a1,273
ffffffffc0201338:	00004517          	auipc	a0,0x4
ffffffffc020133c:	9e050513          	addi	a0,a0,-1568 # ffffffffc0204d18 <commands+0x930>
ffffffffc0201340:	dc7fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201344:	00004697          	auipc	a3,0x4
ffffffffc0201348:	ae468693          	addi	a3,a3,-1308 # ffffffffc0204e28 <commands+0xa40>
ffffffffc020134c:	00004617          	auipc	a2,0x4
ffffffffc0201350:	8e460613          	addi	a2,a2,-1820 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201354:	0db00593          	li	a1,219
ffffffffc0201358:	00004517          	auipc	a0,0x4
ffffffffc020135c:	9c050513          	addi	a0,a0,-1600 # ffffffffc0204d18 <commands+0x930>
ffffffffc0201360:	da7fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma4 == NULL);
ffffffffc0201364:	00004697          	auipc	a3,0x4
ffffffffc0201368:	b4468693          	addi	a3,a3,-1212 # ffffffffc0204ea8 <commands+0xac0>
ffffffffc020136c:	00004617          	auipc	a2,0x4
ffffffffc0201370:	8c460613          	addi	a2,a2,-1852 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201374:	0e900593          	li	a1,233
ffffffffc0201378:	00004517          	auipc	a0,0x4
ffffffffc020137c:	9a050513          	addi	a0,a0,-1632 # ffffffffc0204d18 <commands+0x930>
ffffffffc0201380:	d87fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma3 == NULL);
ffffffffc0201384:	00004697          	auipc	a3,0x4
ffffffffc0201388:	b1468693          	addi	a3,a3,-1260 # ffffffffc0204e98 <commands+0xab0>
ffffffffc020138c:	00004617          	auipc	a2,0x4
ffffffffc0201390:	8a460613          	addi	a2,a2,-1884 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201394:	0e700593          	li	a1,231
ffffffffc0201398:	00004517          	auipc	a0,0x4
ffffffffc020139c:	98050513          	addi	a0,a0,-1664 # ffffffffc0204d18 <commands+0x930>
ffffffffc02013a0:	d67fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma2 != NULL);
ffffffffc02013a4:	00004697          	auipc	a3,0x4
ffffffffc02013a8:	ae468693          	addi	a3,a3,-1308 # ffffffffc0204e88 <commands+0xaa0>
ffffffffc02013ac:	00004617          	auipc	a2,0x4
ffffffffc02013b0:	88460613          	addi	a2,a2,-1916 # ffffffffc0204c30 <commands+0x848>
ffffffffc02013b4:	0e500593          	li	a1,229
ffffffffc02013b8:	00004517          	auipc	a0,0x4
ffffffffc02013bc:	96050513          	addi	a0,a0,-1696 # ffffffffc0204d18 <commands+0x930>
ffffffffc02013c0:	d47fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma1 != NULL);
ffffffffc02013c4:	00004697          	auipc	a3,0x4
ffffffffc02013c8:	ab468693          	addi	a3,a3,-1356 # ffffffffc0204e78 <commands+0xa90>
ffffffffc02013cc:	00004617          	auipc	a2,0x4
ffffffffc02013d0:	86460613          	addi	a2,a2,-1948 # ffffffffc0204c30 <commands+0x848>
ffffffffc02013d4:	0e300593          	li	a1,227
ffffffffc02013d8:	00004517          	auipc	a0,0x4
ffffffffc02013dc:	94050513          	addi	a0,a0,-1728 # ffffffffc0204d18 <commands+0x930>
ffffffffc02013e0:	d27fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma5 == NULL);
ffffffffc02013e4:	00004697          	auipc	a3,0x4
ffffffffc02013e8:	ad468693          	addi	a3,a3,-1324 # ffffffffc0204eb8 <commands+0xad0>
ffffffffc02013ec:	00004617          	auipc	a2,0x4
ffffffffc02013f0:	84460613          	addi	a2,a2,-1980 # ffffffffc0204c30 <commands+0x848>
ffffffffc02013f4:	0eb00593          	li	a1,235
ffffffffc02013f8:	00004517          	auipc	a0,0x4
ffffffffc02013fc:	92050513          	addi	a0,a0,-1760 # ffffffffc0204d18 <commands+0x930>
ffffffffc0201400:	d07fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(mm != NULL);
ffffffffc0201404:	00004697          	auipc	a3,0x4
ffffffffc0201408:	a1468693          	addi	a3,a3,-1516 # ffffffffc0204e18 <commands+0xa30>
ffffffffc020140c:	00004617          	auipc	a2,0x4
ffffffffc0201410:	82460613          	addi	a2,a2,-2012 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201414:	0c700593          	li	a1,199
ffffffffc0201418:	00004517          	auipc	a0,0x4
ffffffffc020141c:	90050513          	addi	a0,a0,-1792 # ffffffffc0204d18 <commands+0x930>
ffffffffc0201420:	ce7fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201424:	00004697          	auipc	a3,0x4
ffffffffc0201428:	b4468693          	addi	a3,a3,-1212 # ffffffffc0204f68 <commands+0xb80>
ffffffffc020142c:	00004617          	auipc	a2,0x4
ffffffffc0201430:	80460613          	addi	a2,a2,-2044 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201434:	0fb00593          	li	a1,251
ffffffffc0201438:	00004517          	auipc	a0,0x4
ffffffffc020143c:	8e050513          	addi	a0,a0,-1824 # ffffffffc0204d18 <commands+0x930>
ffffffffc0201440:	cc7fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201444:	00004697          	auipc	a3,0x4
ffffffffc0201448:	b2468693          	addi	a3,a3,-1244 # ffffffffc0204f68 <commands+0xb80>
ffffffffc020144c:	00003617          	auipc	a2,0x3
ffffffffc0201450:	7e460613          	addi	a2,a2,2020 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201454:	12e00593          	li	a1,302
ffffffffc0201458:	00004517          	auipc	a0,0x4
ffffffffc020145c:	8c050513          	addi	a0,a0,-1856 # ffffffffc0204d18 <commands+0x930>
ffffffffc0201460:	ca7fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0201464:	00004697          	auipc	a3,0x4
ffffffffc0201468:	b4c68693          	addi	a3,a3,-1204 # ffffffffc0204fb0 <commands+0xbc8>
ffffffffc020146c:	00003617          	auipc	a2,0x3
ffffffffc0201470:	7c460613          	addi	a2,a2,1988 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201474:	10a00593          	li	a1,266
ffffffffc0201478:	00004517          	auipc	a0,0x4
ffffffffc020147c:	8a050513          	addi	a0,a0,-1888 # ffffffffc0204d18 <commands+0x930>
ffffffffc0201480:	c87fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201484:	00004697          	auipc	a3,0x4
ffffffffc0201488:	ae468693          	addi	a3,a3,-1308 # ffffffffc0204f68 <commands+0xb80>
ffffffffc020148c:	00003617          	auipc	a2,0x3
ffffffffc0201490:	7a460613          	addi	a2,a2,1956 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201494:	0bd00593          	li	a1,189
ffffffffc0201498:	00004517          	auipc	a0,0x4
ffffffffc020149c:	88050513          	addi	a0,a0,-1920 # ffffffffc0204d18 <commands+0x930>
ffffffffc02014a0:	c67fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02014a4:	00004697          	auipc	a3,0x4
ffffffffc02014a8:	b3468693          	addi	a3,a3,-1228 # ffffffffc0204fd8 <commands+0xbf0>
ffffffffc02014ac:	00003617          	auipc	a2,0x3
ffffffffc02014b0:	78460613          	addi	a2,a2,1924 # ffffffffc0204c30 <commands+0x848>
ffffffffc02014b4:	11600593          	li	a1,278
ffffffffc02014b8:	00004517          	auipc	a0,0x4
ffffffffc02014bc:	86050513          	addi	a0,a0,-1952 # ffffffffc0204d18 <commands+0x930>
ffffffffc02014c0:	c47fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02014c4:	00004617          	auipc	a2,0x4
ffffffffc02014c8:	b4460613          	addi	a2,a2,-1212 # ffffffffc0205008 <commands+0xc20>
ffffffffc02014cc:	06500593          	li	a1,101
ffffffffc02014d0:	00004517          	auipc	a0,0x4
ffffffffc02014d4:	b5850513          	addi	a0,a0,-1192 # ffffffffc0205028 <commands+0xc40>
ffffffffc02014d8:	c2ffe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(sum == 0);
ffffffffc02014dc:	00004697          	auipc	a3,0x4
ffffffffc02014e0:	b1c68693          	addi	a3,a3,-1252 # ffffffffc0204ff8 <commands+0xc10>
ffffffffc02014e4:	00003617          	auipc	a2,0x3
ffffffffc02014e8:	74c60613          	addi	a2,a2,1868 # ffffffffc0204c30 <commands+0x848>
ffffffffc02014ec:	12000593          	li	a1,288
ffffffffc02014f0:	00004517          	auipc	a0,0x4
ffffffffc02014f4:	82850513          	addi	a0,a0,-2008 # ffffffffc0204d18 <commands+0x930>
ffffffffc02014f8:	c0ffe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02014fc:	00004697          	auipc	a3,0x4
ffffffffc0201500:	acc68693          	addi	a3,a3,-1332 # ffffffffc0204fc8 <commands+0xbe0>
ffffffffc0201504:	00003617          	auipc	a2,0x3
ffffffffc0201508:	72c60613          	addi	a2,a2,1836 # ffffffffc0204c30 <commands+0x848>
ffffffffc020150c:	10d00593          	li	a1,269
ffffffffc0201510:	00004517          	auipc	a0,0x4
ffffffffc0201514:	80850513          	addi	a0,a0,-2040 # ffffffffc0204d18 <commands+0x930>
ffffffffc0201518:	beffe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc020151c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020151c:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020151e:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201520:	f822                	sd	s0,48(sp)
ffffffffc0201522:	f426                	sd	s1,40(sp)
ffffffffc0201524:	fc06                	sd	ra,56(sp)
ffffffffc0201526:	f04a                	sd	s2,32(sp)
ffffffffc0201528:	ec4e                	sd	s3,24(sp)
ffffffffc020152a:	8432                	mv	s0,a2
ffffffffc020152c:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020152e:	96fff0ef          	jal	ra,ffffffffc0200e9c <find_vma>

    pgfault_num++;
ffffffffc0201532:	00010797          	auipc	a5,0x10
ffffffffc0201536:	f1e78793          	addi	a5,a5,-226 # ffffffffc0211450 <pgfault_num>
ffffffffc020153a:	439c                	lw	a5,0(a5)
ffffffffc020153c:	2785                	addiw	a5,a5,1
ffffffffc020153e:	00010717          	auipc	a4,0x10
ffffffffc0201542:	f0f72923          	sw	a5,-238(a4) # ffffffffc0211450 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201546:	c15d                	beqz	a0,ffffffffc02015ec <do_pgfault+0xd0>
ffffffffc0201548:	651c                	ld	a5,8(a0)
ffffffffc020154a:	0af46163          	bltu	s0,a5,ffffffffc02015ec <do_pgfault+0xd0>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020154e:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0201550:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201552:	8b89                	andi	a5,a5,2
ffffffffc0201554:	efa9                	bnez	a5,ffffffffc02015ae <do_pgfault+0x92>
        perm |= (PTE_R | PTE_W);// 可写那就可读
    }
    addr = ROUNDDOWN(addr, PGSIZE);// 取整对齐
ffffffffc0201556:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0201558:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);// 取整对齐
ffffffffc020155a:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc020155c:	85a2                	mv	a1,s0
ffffffffc020155e:	4605                	li	a2,1
ffffffffc0201560:	598010ef          	jal	ra,ffffffffc0202af8 <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0201564:	610c                	ld	a1,0(a0)
ffffffffc0201566:	c5a5                	beqz	a1,ffffffffc02015ce <do_pgfault+0xb2>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0201568:	00010797          	auipc	a5,0x10
ffffffffc020156c:	ef878793          	addi	a5,a5,-264 # ffffffffc0211460 <swap_init_ok>
ffffffffc0201570:	439c                	lw	a5,0(a5)
ffffffffc0201572:	2781                	sext.w	a5,a5
ffffffffc0201574:	c7c9                	beqz	a5,ffffffffc02015fe <do_pgfault+0xe2>
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            
            ret = swap_in(mm, addr, &page);// 将addr对应的在磁盘上的数据换到page上
ffffffffc0201576:	0030                	addi	a2,sp,8
ffffffffc0201578:	85a2                	mv	a1,s0
ffffffffc020157a:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc020157c:	e402                	sd	zero,8(sp)
            ret = swap_in(mm, addr, &page);// 将addr对应的在磁盘上的数据换到page上
ffffffffc020157e:	065000ef          	jal	ra,ffffffffc0201de2 <swap_in>
ffffffffc0201582:	892a                	mv	s2,a0
            if(ret!=0){
ffffffffc0201584:	e51d                	bnez	a0,ffffffffc02015b2 <do_pgfault+0x96>
                cprintf("swap_in failed\n");
                goto failed;
            }
            page_insert(mm->pgdir, page, addr, perm);// 建立索引：addr到page的映射关系，设置page的权限为perm
ffffffffc0201586:	65a2                	ld	a1,8(sp)
ffffffffc0201588:	6c88                	ld	a0,24(s1)
ffffffffc020158a:	86ce                	mv	a3,s3
ffffffffc020158c:	8622                	mv	a2,s0
ffffffffc020158e:	043010ef          	jal	ra,ffffffffc0202dd0 <page_insert>
            swap_map_swappable(mm, addr, page, 1);// 标记为可替换
ffffffffc0201592:	6622                	ld	a2,8(sp)
ffffffffc0201594:	4685                	li	a3,1
ffffffffc0201596:	85a2                	mv	a1,s0
ffffffffc0201598:	8526                	mv	a0,s1
ffffffffc020159a:	724000ef          	jal	ra,ffffffffc0201cbe <swap_map_swappable>
   }

   ret = 0;
failed:
    return ret;
}
ffffffffc020159e:	70e2                	ld	ra,56(sp)
ffffffffc02015a0:	7442                	ld	s0,48(sp)
ffffffffc02015a2:	854a                	mv	a0,s2
ffffffffc02015a4:	74a2                	ld	s1,40(sp)
ffffffffc02015a6:	7902                	ld	s2,32(sp)
ffffffffc02015a8:	69e2                	ld	s3,24(sp)
ffffffffc02015aa:	6121                	addi	sp,sp,64
ffffffffc02015ac:	8082                	ret
        perm |= (PTE_R | PTE_W);// 可写那就可读
ffffffffc02015ae:	49d9                	li	s3,22
ffffffffc02015b0:	b75d                	j	ffffffffc0201556 <do_pgfault+0x3a>
                cprintf("swap_in failed\n");
ffffffffc02015b2:	00003517          	auipc	a0,0x3
ffffffffc02015b6:	7ce50513          	addi	a0,a0,1998 # ffffffffc0204d80 <commands+0x998>
ffffffffc02015ba:	b05fe0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc02015be:	70e2                	ld	ra,56(sp)
ffffffffc02015c0:	7442                	ld	s0,48(sp)
ffffffffc02015c2:	854a                	mv	a0,s2
ffffffffc02015c4:	74a2                	ld	s1,40(sp)
ffffffffc02015c6:	7902                	ld	s2,32(sp)
ffffffffc02015c8:	69e2                	ld	s3,24(sp)
ffffffffc02015ca:	6121                	addi	sp,sp,64
ffffffffc02015cc:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02015ce:	6c88                	ld	a0,24(s1)
ffffffffc02015d0:	864e                	mv	a2,s3
ffffffffc02015d2:	85a2                	mv	a1,s0
ffffffffc02015d4:	3b0020ef          	jal	ra,ffffffffc0203984 <pgdir_alloc_page>
   ret = 0;
ffffffffc02015d8:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02015da:	f171                	bnez	a0,ffffffffc020159e <do_pgfault+0x82>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02015dc:	00003517          	auipc	a0,0x3
ffffffffc02015e0:	77c50513          	addi	a0,a0,1916 # ffffffffc0204d58 <commands+0x970>
ffffffffc02015e4:	adbfe0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc02015e8:	5971                	li	s2,-4
            goto failed;
ffffffffc02015ea:	bf55                	j	ffffffffc020159e <do_pgfault+0x82>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02015ec:	85a2                	mv	a1,s0
ffffffffc02015ee:	00003517          	auipc	a0,0x3
ffffffffc02015f2:	73a50513          	addi	a0,a0,1850 # ffffffffc0204d28 <commands+0x940>
ffffffffc02015f6:	ac9fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc02015fa:	5975                	li	s2,-3
        goto failed;
ffffffffc02015fc:	b74d                	j	ffffffffc020159e <do_pgfault+0x82>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02015fe:	00003517          	auipc	a0,0x3
ffffffffc0201602:	79250513          	addi	a0,a0,1938 # ffffffffc0204d90 <commands+0x9a8>
ffffffffc0201606:	ab9fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc020160a:	5971                	li	s2,-4
            goto failed;
ffffffffc020160c:	bf49                	j	ffffffffc020159e <do_pgfault+0x82>

ffffffffc020160e <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020160e:	7135                	addi	sp,sp,-160
ffffffffc0201610:	ed06                	sd	ra,152(sp)
ffffffffc0201612:	e922                	sd	s0,144(sp)
ffffffffc0201614:	e526                	sd	s1,136(sp)
ffffffffc0201616:	e14a                	sd	s2,128(sp)
ffffffffc0201618:	fcce                	sd	s3,120(sp)
ffffffffc020161a:	f8d2                	sd	s4,112(sp)
ffffffffc020161c:	f4d6                	sd	s5,104(sp)
ffffffffc020161e:	f0da                	sd	s6,96(sp)
ffffffffc0201620:	ecde                	sd	s7,88(sp)
ffffffffc0201622:	e8e2                	sd	s8,80(sp)
ffffffffc0201624:	e4e6                	sd	s9,72(sp)
ffffffffc0201626:	e0ea                	sd	s10,64(sp)
ffffffffc0201628:	fc6e                	sd	s11,56(sp)
     swapfs_init();// 初始化硬盘和一些检查
ffffffffc020162a:	56e020ef          	jal	ra,ffffffffc0203b98 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test// 56/8
     if (!(7 <= max_swap_offset &&
ffffffffc020162e:	00010797          	auipc	a5,0x10
ffffffffc0201632:	ef278793          	addi	a5,a5,-270 # ffffffffc0211520 <max_swap_offset>
ffffffffc0201636:	6394                	ld	a3,0(a5)
ffffffffc0201638:	010007b7          	lui	a5,0x1000
ffffffffc020163c:	17e1                	addi	a5,a5,-8
ffffffffc020163e:	ff968713          	addi	a4,a3,-7
ffffffffc0201642:	42e7ea63          	bltu	a5,a4,ffffffffc0201a76 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_lru;// 切换sm
ffffffffc0201646:	00009797          	auipc	a5,0x9
ffffffffc020164a:	9ba78793          	addi	a5,a5,-1606 # ffffffffc020a000 <swap_manager_lru>
     int r = sm->init();
ffffffffc020164e:	6798                	ld	a4,8(a5)
     sm = &swap_manager_lru;// 切换sm
ffffffffc0201650:	00010697          	auipc	a3,0x10
ffffffffc0201654:	e0f6b423          	sd	a5,-504(a3) # ffffffffc0211458 <sm>
     int r = sm->init();
ffffffffc0201658:	9702                	jalr	a4
ffffffffc020165a:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc020165c:	c10d                	beqz	a0,ffffffffc020167e <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020165e:	60ea                	ld	ra,152(sp)
ffffffffc0201660:	644a                	ld	s0,144(sp)
ffffffffc0201662:	855a                	mv	a0,s6
ffffffffc0201664:	64aa                	ld	s1,136(sp)
ffffffffc0201666:	690a                	ld	s2,128(sp)
ffffffffc0201668:	79e6                	ld	s3,120(sp)
ffffffffc020166a:	7a46                	ld	s4,112(sp)
ffffffffc020166c:	7aa6                	ld	s5,104(sp)
ffffffffc020166e:	7b06                	ld	s6,96(sp)
ffffffffc0201670:	6be6                	ld	s7,88(sp)
ffffffffc0201672:	6c46                	ld	s8,80(sp)
ffffffffc0201674:	6ca6                	ld	s9,72(sp)
ffffffffc0201676:	6d06                	ld	s10,64(sp)
ffffffffc0201678:	7de2                	ld	s11,56(sp)
ffffffffc020167a:	610d                	addi	sp,sp,160
ffffffffc020167c:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020167e:	00010797          	auipc	a5,0x10
ffffffffc0201682:	dda78793          	addi	a5,a5,-550 # ffffffffc0211458 <sm>
ffffffffc0201686:	639c                	ld	a5,0(a5)
ffffffffc0201688:	00004517          	auipc	a0,0x4
ffffffffc020168c:	a7850513          	addi	a0,a0,-1416 # ffffffffc0205100 <commands+0xd18>
ffffffffc0201690:	00010417          	auipc	s0,0x10
ffffffffc0201694:	ed040413          	addi	s0,s0,-304 # ffffffffc0211560 <free_area>
ffffffffc0201698:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;// 初始化成功
ffffffffc020169a:	4785                	li	a5,1
ffffffffc020169c:	00010717          	auipc	a4,0x10
ffffffffc02016a0:	dcf72223          	sw	a5,-572(a4) # ffffffffc0211460 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02016a4:	a1bfe0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02016a8:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02016aa:	2e878a63          	beq	a5,s0,ffffffffc020199e <swap_init+0x390>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02016ae:	fe87b703          	ld	a4,-24(a5)
ffffffffc02016b2:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02016b4:	8b05                	andi	a4,a4,1
ffffffffc02016b6:	2e070863          	beqz	a4,ffffffffc02019a6 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc02016ba:	4481                	li	s1,0
ffffffffc02016bc:	4901                	li	s2,0
ffffffffc02016be:	a031                	j	ffffffffc02016ca <swap_init+0xbc>
ffffffffc02016c0:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc02016c4:	8b09                	andi	a4,a4,2
ffffffffc02016c6:	2e070063          	beqz	a4,ffffffffc02019a6 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc02016ca:	ff87a703          	lw	a4,-8(a5)
ffffffffc02016ce:	679c                	ld	a5,8(a5)
ffffffffc02016d0:	2905                	addiw	s2,s2,1
ffffffffc02016d2:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02016d4:	fe8796e3          	bne	a5,s0,ffffffffc02016c0 <swap_init+0xb2>
ffffffffc02016d8:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc02016da:	3de010ef          	jal	ra,ffffffffc0202ab8 <nr_free_pages>
ffffffffc02016de:	5b351863          	bne	a0,s3,ffffffffc0201c8e <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02016e2:	8626                	mv	a2,s1
ffffffffc02016e4:	85ca                	mv	a1,s2
ffffffffc02016e6:	00004517          	auipc	a0,0x4
ffffffffc02016ea:	a6250513          	addi	a0,a0,-1438 # ffffffffc0205148 <commands+0xd60>
ffffffffc02016ee:	9d1fe0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02016f2:	f30ff0ef          	jal	ra,ffffffffc0200e22 <mm_create>
ffffffffc02016f6:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc02016f8:	50050b63          	beqz	a0,ffffffffc0201c0e <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02016fc:	00010797          	auipc	a5,0x10
ffffffffc0201700:	d9478793          	addi	a5,a5,-620 # ffffffffc0211490 <check_mm_struct>
ffffffffc0201704:	639c                	ld	a5,0(a5)
ffffffffc0201706:	52079463          	bnez	a5,ffffffffc0201c2e <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020170a:	00010797          	auipc	a5,0x10
ffffffffc020170e:	d5e78793          	addi	a5,a5,-674 # ffffffffc0211468 <boot_pgdir>
ffffffffc0201712:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc0201714:	00010797          	auipc	a5,0x10
ffffffffc0201718:	d6a7be23          	sd	a0,-644(a5) # ffffffffc0211490 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020171c:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020171e:	ec3a                	sd	a4,24(sp)
ffffffffc0201720:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0201722:	52079663          	bnez	a5,ffffffffc0201c4e <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0201726:	6599                	lui	a1,0x6
ffffffffc0201728:	460d                	li	a2,3
ffffffffc020172a:	6505                	lui	a0,0x1
ffffffffc020172c:	f42ff0ef          	jal	ra,ffffffffc0200e6e <vma_create>
ffffffffc0201730:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0201732:	52050e63          	beqz	a0,ffffffffc0201c6e <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc0201736:	855e                	mv	a0,s7
ffffffffc0201738:	fa2ff0ef          	jal	ra,ffffffffc0200eda <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020173c:	00004517          	auipc	a0,0x4
ffffffffc0201740:	a4c50513          	addi	a0,a0,-1460 # ffffffffc0205188 <commands+0xda0>
ffffffffc0201744:	97bfe0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0201748:	018bb503          	ld	a0,24(s7)
ffffffffc020174c:	4605                	li	a2,1
ffffffffc020174e:	6585                	lui	a1,0x1
ffffffffc0201750:	3a8010ef          	jal	ra,ffffffffc0202af8 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0201754:	40050d63          	beqz	a0,ffffffffc0201b6e <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201758:	00004517          	auipc	a0,0x4
ffffffffc020175c:	a8050513          	addi	a0,a0,-1408 # ffffffffc02051d8 <commands+0xdf0>
ffffffffc0201760:	00010a17          	auipc	s4,0x10
ffffffffc0201764:	d38a0a13          	addi	s4,s4,-712 # ffffffffc0211498 <check_rp>
ffffffffc0201768:	957fe0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020176c:	00010a97          	auipc	s5,0x10
ffffffffc0201770:	d4ca8a93          	addi	s5,s5,-692 # ffffffffc02114b8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201774:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc0201776:	4505                	li	a0,1
ffffffffc0201778:	272010ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc020177c:	00a9b023          	sd	a0,0(s3)
          assert(check_rp[i] != NULL );
ffffffffc0201780:	2a050b63          	beqz	a0,ffffffffc0201a36 <swap_init+0x428>
ffffffffc0201784:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0201786:	8b89                	andi	a5,a5,2
ffffffffc0201788:	28079763          	bnez	a5,ffffffffc0201a16 <swap_init+0x408>
ffffffffc020178c:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020178e:	ff5994e3          	bne	s3,s5,ffffffffc0201776 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0201792:	601c                	ld	a5,0(s0)
ffffffffc0201794:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0201798:	00010d17          	auipc	s10,0x10
ffffffffc020179c:	d00d0d13          	addi	s10,s10,-768 # ffffffffc0211498 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc02017a0:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02017a2:	481c                	lw	a5,16(s0)
ffffffffc02017a4:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc02017a6:	00010797          	auipc	a5,0x10
ffffffffc02017aa:	dc87b123          	sd	s0,-574(a5) # ffffffffc0211568 <free_area+0x8>
ffffffffc02017ae:	00010797          	auipc	a5,0x10
ffffffffc02017b2:	da87b923          	sd	s0,-590(a5) # ffffffffc0211560 <free_area>
     nr_free = 0;
ffffffffc02017b6:	00010797          	auipc	a5,0x10
ffffffffc02017ba:	da07ad23          	sw	zero,-582(a5) # ffffffffc0211570 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02017be:	000d3503          	ld	a0,0(s10)
ffffffffc02017c2:	4585                	li	a1,1
ffffffffc02017c4:	0d21                	addi	s10,s10,8
ffffffffc02017c6:	2ac010ef          	jal	ra,ffffffffc0202a72 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02017ca:	ff5d1ae3          	bne	s10,s5,ffffffffc02017be <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02017ce:	01042d03          	lw	s10,16(s0)
ffffffffc02017d2:	4791                	li	a5,4
ffffffffc02017d4:	36fd1d63          	bne	s10,a5,ffffffffc0201b4e <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02017d8:	00004517          	auipc	a0,0x4
ffffffffc02017dc:	a8850513          	addi	a0,a0,-1400 # ffffffffc0205260 <commands+0xe78>
ffffffffc02017e0:	8dffe0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02017e4:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02017e6:	00010797          	auipc	a5,0x10
ffffffffc02017ea:	c607a523          	sw	zero,-918(a5) # ffffffffc0211450 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02017ee:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc02017f0:	00010797          	auipc	a5,0x10
ffffffffc02017f4:	c6078793          	addi	a5,a5,-928 # ffffffffc0211450 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02017f8:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc02017fc:	4398                	lw	a4,0(a5)
ffffffffc02017fe:	4585                	li	a1,1
ffffffffc0201800:	2701                	sext.w	a4,a4
ffffffffc0201802:	30b71663          	bne	a4,a1,ffffffffc0201b0e <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0201806:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc020180a:	4394                	lw	a3,0(a5)
ffffffffc020180c:	2681                	sext.w	a3,a3
ffffffffc020180e:	32e69063          	bne	a3,a4,ffffffffc0201b2e <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201812:	6689                	lui	a3,0x2
ffffffffc0201814:	462d                	li	a2,11
ffffffffc0201816:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc020181a:	4398                	lw	a4,0(a5)
ffffffffc020181c:	4589                	li	a1,2
ffffffffc020181e:	2701                	sext.w	a4,a4
ffffffffc0201820:	26b71763          	bne	a4,a1,ffffffffc0201a8e <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0201824:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0201828:	4394                	lw	a3,0(a5)
ffffffffc020182a:	2681                	sext.w	a3,a3
ffffffffc020182c:	28e69163          	bne	a3,a4,ffffffffc0201aae <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201830:	668d                	lui	a3,0x3
ffffffffc0201832:	4631                	li	a2,12
ffffffffc0201834:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0201838:	4398                	lw	a4,0(a5)
ffffffffc020183a:	458d                	li	a1,3
ffffffffc020183c:	2701                	sext.w	a4,a4
ffffffffc020183e:	28b71863          	bne	a4,a1,ffffffffc0201ace <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0201842:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0201846:	4394                	lw	a3,0(a5)
ffffffffc0201848:	2681                	sext.w	a3,a3
ffffffffc020184a:	2ae69263          	bne	a3,a4,ffffffffc0201aee <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc020184e:	6691                	lui	a3,0x4
ffffffffc0201850:	4635                	li	a2,13
ffffffffc0201852:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0201856:	4398                	lw	a4,0(a5)
ffffffffc0201858:	2701                	sext.w	a4,a4
ffffffffc020185a:	33a71a63          	bne	a4,s10,ffffffffc0201b8e <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc020185e:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0201862:	439c                	lw	a5,0(a5)
ffffffffc0201864:	2781                	sext.w	a5,a5
ffffffffc0201866:	34e79463          	bne	a5,a4,ffffffffc0201bae <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc020186a:	481c                	lw	a5,16(s0)
ffffffffc020186c:	36079163          	bnez	a5,ffffffffc0201bce <swap_init+0x5c0>
ffffffffc0201870:	00010797          	auipc	a5,0x10
ffffffffc0201874:	c4878793          	addi	a5,a5,-952 # ffffffffc02114b8 <swap_in_seq_no>
ffffffffc0201878:	00010717          	auipc	a4,0x10
ffffffffc020187c:	c6870713          	addi	a4,a4,-920 # ffffffffc02114e0 <swap_out_seq_no>
ffffffffc0201880:	00010617          	auipc	a2,0x10
ffffffffc0201884:	c6060613          	addi	a2,a2,-928 # ffffffffc02114e0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0201888:	56fd                	li	a3,-1
ffffffffc020188a:	c394                	sw	a3,0(a5)
ffffffffc020188c:	c314                	sw	a3,0(a4)
ffffffffc020188e:	0791                	addi	a5,a5,4
ffffffffc0201890:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201892:	fec79ce3          	bne	a5,a2,ffffffffc020188a <swap_init+0x27c>
ffffffffc0201896:	00010697          	auipc	a3,0x10
ffffffffc020189a:	caa68693          	addi	a3,a3,-854 # ffffffffc0211540 <check_ptep>
ffffffffc020189e:	00010817          	auipc	a6,0x10
ffffffffc02018a2:	bfa80813          	addi	a6,a6,-1030 # ffffffffc0211498 <check_rp>
ffffffffc02018a6:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc02018a8:	00010c97          	auipc	s9,0x10
ffffffffc02018ac:	bc8c8c93          	addi	s9,s9,-1080 # ffffffffc0211470 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02018b0:	00010d97          	auipc	s11,0x10
ffffffffc02018b4:	ce0d8d93          	addi	s11,s11,-800 # ffffffffc0211590 <pages>
ffffffffc02018b8:	00004d17          	auipc	s10,0x4
ffffffffc02018bc:	7c8d0d13          	addi	s10,s10,1992 # ffffffffc0206080 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02018c0:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc02018c2:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02018c6:	4601                	li	a2,0
ffffffffc02018c8:	85e2                	mv	a1,s8
ffffffffc02018ca:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc02018cc:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02018ce:	22a010ef          	jal	ra,ffffffffc0202af8 <get_pte>
ffffffffc02018d2:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02018d4:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02018d6:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc02018d8:	16050f63          	beqz	a0,ffffffffc0201a56 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02018dc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02018de:	0017f613          	andi	a2,a5,1
ffffffffc02018e2:	10060263          	beqz	a2,ffffffffc02019e6 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc02018e6:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02018ea:	078a                	slli	a5,a5,0x2
ffffffffc02018ec:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02018ee:	10c7f863          	bleu	a2,a5,ffffffffc02019fe <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc02018f2:	000d3603          	ld	a2,0(s10)
ffffffffc02018f6:	000db583          	ld	a1,0(s11)
ffffffffc02018fa:	00083503          	ld	a0,0(a6)
ffffffffc02018fe:	8f91                	sub	a5,a5,a2
ffffffffc0201900:	00379613          	slli	a2,a5,0x3
ffffffffc0201904:	97b2                	add	a5,a5,a2
ffffffffc0201906:	078e                	slli	a5,a5,0x3
ffffffffc0201908:	97ae                	add	a5,a5,a1
ffffffffc020190a:	0af51e63          	bne	a0,a5,ffffffffc02019c6 <swap_init+0x3b8>
ffffffffc020190e:	6785                	lui	a5,0x1
ffffffffc0201910:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201912:	6795                	lui	a5,0x5
ffffffffc0201914:	06a1                	addi	a3,a3,8
ffffffffc0201916:	0821                	addi	a6,a6,8
ffffffffc0201918:	fafc14e3          	bne	s8,a5,ffffffffc02018c0 <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020191c:	00004517          	auipc	a0,0x4
ffffffffc0201920:	a1450513          	addi	a0,a0,-1516 # ffffffffc0205330 <commands+0xf48>
ffffffffc0201924:	f9afe0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc0201928:	00010797          	auipc	a5,0x10
ffffffffc020192c:	b3078793          	addi	a5,a5,-1232 # ffffffffc0211458 <sm>
ffffffffc0201930:	639c                	ld	a5,0(a5)
ffffffffc0201932:	7f9c                	ld	a5,56(a5)
ffffffffc0201934:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0201936:	2a051c63          	bnez	a0,ffffffffc0201bee <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc020193a:	000a3503          	ld	a0,0(s4)
ffffffffc020193e:	4585                	li	a1,1
ffffffffc0201940:	0a21                	addi	s4,s4,8
ffffffffc0201942:	130010ef          	jal	ra,ffffffffc0202a72 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201946:	ff5a1ae3          	bne	s4,s5,ffffffffc020193a <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc020194a:	855e                	mv	a0,s7
ffffffffc020194c:	e5cff0ef          	jal	ra,ffffffffc0200fa8 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0201950:	77a2                	ld	a5,40(sp)
ffffffffc0201952:	00010717          	auipc	a4,0x10
ffffffffc0201956:	c0f72f23          	sw	a5,-994(a4) # ffffffffc0211570 <free_area+0x10>
     free_list = free_list_store;
ffffffffc020195a:	7782                	ld	a5,32(sp)
ffffffffc020195c:	00010717          	auipc	a4,0x10
ffffffffc0201960:	c0f73223          	sd	a5,-1020(a4) # ffffffffc0211560 <free_area>
ffffffffc0201964:	00010797          	auipc	a5,0x10
ffffffffc0201968:	c137b223          	sd	s3,-1020(a5) # ffffffffc0211568 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020196c:	00898a63          	beq	s3,s0,ffffffffc0201980 <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201970:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0201974:	0089b983          	ld	s3,8(s3)
ffffffffc0201978:	397d                	addiw	s2,s2,-1
ffffffffc020197a:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc020197c:	fe899ae3          	bne	s3,s0,ffffffffc0201970 <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0201980:	8626                	mv	a2,s1
ffffffffc0201982:	85ca                	mv	a1,s2
ffffffffc0201984:	00004517          	auipc	a0,0x4
ffffffffc0201988:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0205360 <commands+0xf78>
ffffffffc020198c:	f32fe0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0201990:	00004517          	auipc	a0,0x4
ffffffffc0201994:	9f050513          	addi	a0,a0,-1552 # ffffffffc0205380 <commands+0xf98>
ffffffffc0201998:	f26fe0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020199c:	b1c9                	j	ffffffffc020165e <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc020199e:	4481                	li	s1,0
ffffffffc02019a0:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc02019a2:	4981                	li	s3,0
ffffffffc02019a4:	bb1d                	j	ffffffffc02016da <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc02019a6:	00003697          	auipc	a3,0x3
ffffffffc02019aa:	77268693          	addi	a3,a3,1906 # ffffffffc0205118 <commands+0xd30>
ffffffffc02019ae:	00003617          	auipc	a2,0x3
ffffffffc02019b2:	28260613          	addi	a2,a2,642 # ffffffffc0204c30 <commands+0x848>
ffffffffc02019b6:	0d300593          	li	a1,211
ffffffffc02019ba:	00003517          	auipc	a0,0x3
ffffffffc02019be:	73650513          	addi	a0,a0,1846 # ffffffffc02050f0 <commands+0xd08>
ffffffffc02019c2:	f44fe0ef          	jal	ra,ffffffffc0200106 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02019c6:	00004697          	auipc	a3,0x4
ffffffffc02019ca:	94268693          	addi	a3,a3,-1726 # ffffffffc0205308 <commands+0xf20>
ffffffffc02019ce:	00003617          	auipc	a2,0x3
ffffffffc02019d2:	26260613          	addi	a2,a2,610 # ffffffffc0204c30 <commands+0x848>
ffffffffc02019d6:	11300593          	li	a1,275
ffffffffc02019da:	00003517          	auipc	a0,0x3
ffffffffc02019de:	71650513          	addi	a0,a0,1814 # ffffffffc02050f0 <commands+0xd08>
ffffffffc02019e2:	f24fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02019e6:	00004617          	auipc	a2,0x4
ffffffffc02019ea:	8fa60613          	addi	a2,a2,-1798 # ffffffffc02052e0 <commands+0xef8>
ffffffffc02019ee:	07000593          	li	a1,112
ffffffffc02019f2:	00003517          	auipc	a0,0x3
ffffffffc02019f6:	63650513          	addi	a0,a0,1590 # ffffffffc0205028 <commands+0xc40>
ffffffffc02019fa:	f0cfe0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02019fe:	00003617          	auipc	a2,0x3
ffffffffc0201a02:	60a60613          	addi	a2,a2,1546 # ffffffffc0205008 <commands+0xc20>
ffffffffc0201a06:	06500593          	li	a1,101
ffffffffc0201a0a:	00003517          	auipc	a0,0x3
ffffffffc0201a0e:	61e50513          	addi	a0,a0,1566 # ffffffffc0205028 <commands+0xc40>
ffffffffc0201a12:	ef4fe0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0201a16:	00004697          	auipc	a3,0x4
ffffffffc0201a1a:	80268693          	addi	a3,a3,-2046 # ffffffffc0205218 <commands+0xe30>
ffffffffc0201a1e:	00003617          	auipc	a2,0x3
ffffffffc0201a22:	21260613          	addi	a2,a2,530 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201a26:	0f400593          	li	a1,244
ffffffffc0201a2a:	00003517          	auipc	a0,0x3
ffffffffc0201a2e:	6c650513          	addi	a0,a0,1734 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201a32:	ed4fe0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0201a36:	00003697          	auipc	a3,0x3
ffffffffc0201a3a:	7ca68693          	addi	a3,a3,1994 # ffffffffc0205200 <commands+0xe18>
ffffffffc0201a3e:	00003617          	auipc	a2,0x3
ffffffffc0201a42:	1f260613          	addi	a2,a2,498 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201a46:	0f300593          	li	a1,243
ffffffffc0201a4a:	00003517          	auipc	a0,0x3
ffffffffc0201a4e:	6a650513          	addi	a0,a0,1702 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201a52:	eb4fe0ef          	jal	ra,ffffffffc0200106 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0201a56:	00004697          	auipc	a3,0x4
ffffffffc0201a5a:	87268693          	addi	a3,a3,-1934 # ffffffffc02052c8 <commands+0xee0>
ffffffffc0201a5e:	00003617          	auipc	a2,0x3
ffffffffc0201a62:	1d260613          	addi	a2,a2,466 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201a66:	11200593          	li	a1,274
ffffffffc0201a6a:	00003517          	auipc	a0,0x3
ffffffffc0201a6e:	68650513          	addi	a0,a0,1670 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201a72:	e94fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0201a76:	00003617          	auipc	a2,0x3
ffffffffc0201a7a:	65a60613          	addi	a2,a2,1626 # ffffffffc02050d0 <commands+0xce8>
ffffffffc0201a7e:	02900593          	li	a1,41
ffffffffc0201a82:	00003517          	auipc	a0,0x3
ffffffffc0201a86:	66e50513          	addi	a0,a0,1646 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201a8a:	e7cfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==2);
ffffffffc0201a8e:	00004697          	auipc	a3,0x4
ffffffffc0201a92:	80a68693          	addi	a3,a3,-2038 # ffffffffc0205298 <commands+0xeb0>
ffffffffc0201a96:	00003617          	auipc	a2,0x3
ffffffffc0201a9a:	19a60613          	addi	a2,a2,410 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201a9e:	0ae00593          	li	a1,174
ffffffffc0201aa2:	00003517          	auipc	a0,0x3
ffffffffc0201aa6:	64e50513          	addi	a0,a0,1614 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201aaa:	e5cfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==2);
ffffffffc0201aae:	00003697          	auipc	a3,0x3
ffffffffc0201ab2:	7ea68693          	addi	a3,a3,2026 # ffffffffc0205298 <commands+0xeb0>
ffffffffc0201ab6:	00003617          	auipc	a2,0x3
ffffffffc0201aba:	17a60613          	addi	a2,a2,378 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201abe:	0b000593          	li	a1,176
ffffffffc0201ac2:	00003517          	auipc	a0,0x3
ffffffffc0201ac6:	62e50513          	addi	a0,a0,1582 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201aca:	e3cfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==3);
ffffffffc0201ace:	00003697          	auipc	a3,0x3
ffffffffc0201ad2:	7da68693          	addi	a3,a3,2010 # ffffffffc02052a8 <commands+0xec0>
ffffffffc0201ad6:	00003617          	auipc	a2,0x3
ffffffffc0201ada:	15a60613          	addi	a2,a2,346 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201ade:	0b200593          	li	a1,178
ffffffffc0201ae2:	00003517          	auipc	a0,0x3
ffffffffc0201ae6:	60e50513          	addi	a0,a0,1550 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201aea:	e1cfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==3);
ffffffffc0201aee:	00003697          	auipc	a3,0x3
ffffffffc0201af2:	7ba68693          	addi	a3,a3,1978 # ffffffffc02052a8 <commands+0xec0>
ffffffffc0201af6:	00003617          	auipc	a2,0x3
ffffffffc0201afa:	13a60613          	addi	a2,a2,314 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201afe:	0b400593          	li	a1,180
ffffffffc0201b02:	00003517          	auipc	a0,0x3
ffffffffc0201b06:	5ee50513          	addi	a0,a0,1518 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201b0a:	dfcfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==1);
ffffffffc0201b0e:	00003697          	auipc	a3,0x3
ffffffffc0201b12:	77a68693          	addi	a3,a3,1914 # ffffffffc0205288 <commands+0xea0>
ffffffffc0201b16:	00003617          	auipc	a2,0x3
ffffffffc0201b1a:	11a60613          	addi	a2,a2,282 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201b1e:	0aa00593          	li	a1,170
ffffffffc0201b22:	00003517          	auipc	a0,0x3
ffffffffc0201b26:	5ce50513          	addi	a0,a0,1486 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201b2a:	ddcfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==1);
ffffffffc0201b2e:	00003697          	auipc	a3,0x3
ffffffffc0201b32:	75a68693          	addi	a3,a3,1882 # ffffffffc0205288 <commands+0xea0>
ffffffffc0201b36:	00003617          	auipc	a2,0x3
ffffffffc0201b3a:	0fa60613          	addi	a2,a2,250 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201b3e:	0ac00593          	li	a1,172
ffffffffc0201b42:	00003517          	auipc	a0,0x3
ffffffffc0201b46:	5ae50513          	addi	a0,a0,1454 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201b4a:	dbcfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201b4e:	00003697          	auipc	a3,0x3
ffffffffc0201b52:	6ea68693          	addi	a3,a3,1770 # ffffffffc0205238 <commands+0xe50>
ffffffffc0201b56:	00003617          	auipc	a2,0x3
ffffffffc0201b5a:	0da60613          	addi	a2,a2,218 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201b5e:	10100593          	li	a1,257
ffffffffc0201b62:	00003517          	auipc	a0,0x3
ffffffffc0201b66:	58e50513          	addi	a0,a0,1422 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201b6a:	d9cfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0201b6e:	00003697          	auipc	a3,0x3
ffffffffc0201b72:	65268693          	addi	a3,a3,1618 # ffffffffc02051c0 <commands+0xdd8>
ffffffffc0201b76:	00003617          	auipc	a2,0x3
ffffffffc0201b7a:	0ba60613          	addi	a2,a2,186 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201b7e:	0ee00593          	li	a1,238
ffffffffc0201b82:	00003517          	auipc	a0,0x3
ffffffffc0201b86:	56e50513          	addi	a0,a0,1390 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201b8a:	d7cfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==4);
ffffffffc0201b8e:	00003697          	auipc	a3,0x3
ffffffffc0201b92:	09268693          	addi	a3,a3,146 # ffffffffc0204c20 <commands+0x838>
ffffffffc0201b96:	00003617          	auipc	a2,0x3
ffffffffc0201b9a:	09a60613          	addi	a2,a2,154 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201b9e:	0b600593          	li	a1,182
ffffffffc0201ba2:	00003517          	auipc	a0,0x3
ffffffffc0201ba6:	54e50513          	addi	a0,a0,1358 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201baa:	d5cfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==4);
ffffffffc0201bae:	00003697          	auipc	a3,0x3
ffffffffc0201bb2:	07268693          	addi	a3,a3,114 # ffffffffc0204c20 <commands+0x838>
ffffffffc0201bb6:	00003617          	auipc	a2,0x3
ffffffffc0201bba:	07a60613          	addi	a2,a2,122 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201bbe:	0b800593          	li	a1,184
ffffffffc0201bc2:	00003517          	auipc	a0,0x3
ffffffffc0201bc6:	52e50513          	addi	a0,a0,1326 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201bca:	d3cfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert( nr_free == 0);         
ffffffffc0201bce:	00003697          	auipc	a3,0x3
ffffffffc0201bd2:	6ea68693          	addi	a3,a3,1770 # ffffffffc02052b8 <commands+0xed0>
ffffffffc0201bd6:	00003617          	auipc	a2,0x3
ffffffffc0201bda:	05a60613          	addi	a2,a2,90 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201bde:	10a00593          	li	a1,266
ffffffffc0201be2:	00003517          	auipc	a0,0x3
ffffffffc0201be6:	50e50513          	addi	a0,a0,1294 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201bea:	d1cfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(ret==0);
ffffffffc0201bee:	00003697          	auipc	a3,0x3
ffffffffc0201bf2:	76a68693          	addi	a3,a3,1898 # ffffffffc0205358 <commands+0xf70>
ffffffffc0201bf6:	00003617          	auipc	a2,0x3
ffffffffc0201bfa:	03a60613          	addi	a2,a2,58 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201bfe:	11900593          	li	a1,281
ffffffffc0201c02:	00003517          	auipc	a0,0x3
ffffffffc0201c06:	4ee50513          	addi	a0,a0,1262 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201c0a:	cfcfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(mm != NULL);
ffffffffc0201c0e:	00003697          	auipc	a3,0x3
ffffffffc0201c12:	20a68693          	addi	a3,a3,522 # ffffffffc0204e18 <commands+0xa30>
ffffffffc0201c16:	00003617          	auipc	a2,0x3
ffffffffc0201c1a:	01a60613          	addi	a2,a2,26 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201c1e:	0db00593          	li	a1,219
ffffffffc0201c22:	00003517          	auipc	a0,0x3
ffffffffc0201c26:	4ce50513          	addi	a0,a0,1230 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201c2a:	cdcfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0201c2e:	00003697          	auipc	a3,0x3
ffffffffc0201c32:	54268693          	addi	a3,a3,1346 # ffffffffc0205170 <commands+0xd88>
ffffffffc0201c36:	00003617          	auipc	a2,0x3
ffffffffc0201c3a:	ffa60613          	addi	a2,a2,-6 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201c3e:	0de00593          	li	a1,222
ffffffffc0201c42:	00003517          	auipc	a0,0x3
ffffffffc0201c46:	4ae50513          	addi	a0,a0,1198 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201c4a:	cbcfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201c4e:	00003697          	auipc	a3,0x3
ffffffffc0201c52:	37a68693          	addi	a3,a3,890 # ffffffffc0204fc8 <commands+0xbe0>
ffffffffc0201c56:	00003617          	auipc	a2,0x3
ffffffffc0201c5a:	fda60613          	addi	a2,a2,-38 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201c5e:	0e300593          	li	a1,227
ffffffffc0201c62:	00003517          	auipc	a0,0x3
ffffffffc0201c66:	48e50513          	addi	a0,a0,1166 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201c6a:	c9cfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(vma != NULL);
ffffffffc0201c6e:	00003697          	auipc	a3,0x3
ffffffffc0201c72:	40268693          	addi	a3,a3,1026 # ffffffffc0205070 <commands+0xc88>
ffffffffc0201c76:	00003617          	auipc	a2,0x3
ffffffffc0201c7a:	fba60613          	addi	a2,a2,-70 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201c7e:	0e600593          	li	a1,230
ffffffffc0201c82:	00003517          	auipc	a0,0x3
ffffffffc0201c86:	46e50513          	addi	a0,a0,1134 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201c8a:	c7cfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(total == nr_free_pages());
ffffffffc0201c8e:	00003697          	auipc	a3,0x3
ffffffffc0201c92:	49a68693          	addi	a3,a3,1178 # ffffffffc0205128 <commands+0xd40>
ffffffffc0201c96:	00003617          	auipc	a2,0x3
ffffffffc0201c9a:	f9a60613          	addi	a2,a2,-102 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201c9e:	0d600593          	li	a1,214
ffffffffc0201ca2:	00003517          	auipc	a0,0x3
ffffffffc0201ca6:	44e50513          	addi	a0,a0,1102 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201caa:	c5cfe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201cae <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0201cae:	0000f797          	auipc	a5,0xf
ffffffffc0201cb2:	7aa78793          	addi	a5,a5,1962 # ffffffffc0211458 <sm>
ffffffffc0201cb6:	639c                	ld	a5,0(a5)
ffffffffc0201cb8:	0107b303          	ld	t1,16(a5)
ffffffffc0201cbc:	8302                	jr	t1

ffffffffc0201cbe <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0201cbe:	0000f797          	auipc	a5,0xf
ffffffffc0201cc2:	79a78793          	addi	a5,a5,1946 # ffffffffc0211458 <sm>
ffffffffc0201cc6:	639c                	ld	a5,0(a5)
ffffffffc0201cc8:	0207b303          	ld	t1,32(a5)
ffffffffc0201ccc:	8302                	jr	t1

ffffffffc0201cce <swap_out>:
{
ffffffffc0201cce:	711d                	addi	sp,sp,-96
ffffffffc0201cd0:	ec86                	sd	ra,88(sp)
ffffffffc0201cd2:	e8a2                	sd	s0,80(sp)
ffffffffc0201cd4:	e4a6                	sd	s1,72(sp)
ffffffffc0201cd6:	e0ca                	sd	s2,64(sp)
ffffffffc0201cd8:	fc4e                	sd	s3,56(sp)
ffffffffc0201cda:	f852                	sd	s4,48(sp)
ffffffffc0201cdc:	f456                	sd	s5,40(sp)
ffffffffc0201cde:	f05a                	sd	s6,32(sp)
ffffffffc0201ce0:	ec5e                	sd	s7,24(sp)
ffffffffc0201ce2:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0201ce4:	cde9                	beqz	a1,ffffffffc0201dbe <swap_out+0xf0>
ffffffffc0201ce6:	8ab2                	mv	s5,a2
ffffffffc0201ce8:	892a                	mv	s2,a0
ffffffffc0201cea:	8a2e                	mv	s4,a1
ffffffffc0201cec:	4401                	li	s0,0
ffffffffc0201cee:	0000f997          	auipc	s3,0xf
ffffffffc0201cf2:	76a98993          	addi	s3,s3,1898 # ffffffffc0211458 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201cf6:	00003b17          	auipc	s6,0x3
ffffffffc0201cfa:	70ab0b13          	addi	s6,s6,1802 # ffffffffc0205400 <commands+0x1018>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201cfe:	00003b97          	auipc	s7,0x3
ffffffffc0201d02:	6eab8b93          	addi	s7,s7,1770 # ffffffffc02053e8 <commands+0x1000>
ffffffffc0201d06:	a825                	j	ffffffffc0201d3e <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201d08:	67a2                	ld	a5,8(sp)
ffffffffc0201d0a:	8626                	mv	a2,s1
ffffffffc0201d0c:	85a2                	mv	a1,s0
ffffffffc0201d0e:	63b4                	ld	a3,64(a5)
ffffffffc0201d10:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0201d12:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201d14:	82b1                	srli	a3,a3,0xc
ffffffffc0201d16:	0685                	addi	a3,a3,1
ffffffffc0201d18:	ba6fe0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201d1c:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0201d1e:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201d20:	613c                	ld	a5,64(a0)
ffffffffc0201d22:	83b1                	srli	a5,a5,0xc
ffffffffc0201d24:	0785                	addi	a5,a5,1
ffffffffc0201d26:	07a2                	slli	a5,a5,0x8
ffffffffc0201d28:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc0201d2c:	547000ef          	jal	ra,ffffffffc0202a72 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0201d30:	01893503          	ld	a0,24(s2)
ffffffffc0201d34:	85a6                	mv	a1,s1
ffffffffc0201d36:	449010ef          	jal	ra,ffffffffc020397e <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0201d3a:	048a0d63          	beq	s4,s0,ffffffffc0201d94 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0201d3e:	0009b783          	ld	a5,0(s3)
ffffffffc0201d42:	8656                	mv	a2,s5
ffffffffc0201d44:	002c                	addi	a1,sp,8
ffffffffc0201d46:	7b9c                	ld	a5,48(a5)
ffffffffc0201d48:	854a                	mv	a0,s2
ffffffffc0201d4a:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0201d4c:	e12d                	bnez	a0,ffffffffc0201dae <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0201d4e:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201d50:	01893503          	ld	a0,24(s2)
ffffffffc0201d54:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0201d56:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201d58:	85a6                	mv	a1,s1
ffffffffc0201d5a:	59f000ef          	jal	ra,ffffffffc0202af8 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201d5e:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201d60:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0201d62:	8b85                	andi	a5,a5,1
ffffffffc0201d64:	cfb9                	beqz	a5,ffffffffc0201dc2 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0201d66:	65a2                	ld	a1,8(sp)
ffffffffc0201d68:	61bc                	ld	a5,64(a1)
ffffffffc0201d6a:	83b1                	srli	a5,a5,0xc
ffffffffc0201d6c:	00178513          	addi	a0,a5,1
ffffffffc0201d70:	0522                	slli	a0,a0,0x8
ffffffffc0201d72:	705010ef          	jal	ra,ffffffffc0203c76 <swapfs_write>
ffffffffc0201d76:	d949                	beqz	a0,ffffffffc0201d08 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201d78:	855e                	mv	a0,s7
ffffffffc0201d7a:	b44fe0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201d7e:	0009b783          	ld	a5,0(s3)
ffffffffc0201d82:	6622                	ld	a2,8(sp)
ffffffffc0201d84:	4681                	li	a3,0
ffffffffc0201d86:	739c                	ld	a5,32(a5)
ffffffffc0201d88:	85a6                	mv	a1,s1
ffffffffc0201d8a:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0201d8c:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201d8e:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0201d90:	fa8a17e3          	bne	s4,s0,ffffffffc0201d3e <swap_out+0x70>
}
ffffffffc0201d94:	8522                	mv	a0,s0
ffffffffc0201d96:	60e6                	ld	ra,88(sp)
ffffffffc0201d98:	6446                	ld	s0,80(sp)
ffffffffc0201d9a:	64a6                	ld	s1,72(sp)
ffffffffc0201d9c:	6906                	ld	s2,64(sp)
ffffffffc0201d9e:	79e2                	ld	s3,56(sp)
ffffffffc0201da0:	7a42                	ld	s4,48(sp)
ffffffffc0201da2:	7aa2                	ld	s5,40(sp)
ffffffffc0201da4:	7b02                	ld	s6,32(sp)
ffffffffc0201da6:	6be2                	ld	s7,24(sp)
ffffffffc0201da8:	6c42                	ld	s8,16(sp)
ffffffffc0201daa:	6125                	addi	sp,sp,96
ffffffffc0201dac:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0201dae:	85a2                	mv	a1,s0
ffffffffc0201db0:	00003517          	auipc	a0,0x3
ffffffffc0201db4:	5f050513          	addi	a0,a0,1520 # ffffffffc02053a0 <commands+0xfb8>
ffffffffc0201db8:	b06fe0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc0201dbc:	bfe1                	j	ffffffffc0201d94 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0201dbe:	4401                	li	s0,0
ffffffffc0201dc0:	bfd1                	j	ffffffffc0201d94 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201dc2:	00003697          	auipc	a3,0x3
ffffffffc0201dc6:	60e68693          	addi	a3,a3,1550 # ffffffffc02053d0 <commands+0xfe8>
ffffffffc0201dca:	00003617          	auipc	a2,0x3
ffffffffc0201dce:	e6660613          	addi	a2,a2,-410 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201dd2:	07f00593          	li	a1,127
ffffffffc0201dd6:	00003517          	auipc	a0,0x3
ffffffffc0201dda:	31a50513          	addi	a0,a0,794 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201dde:	b28fe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201de2 <swap_in>:
{
ffffffffc0201de2:	7179                	addi	sp,sp,-48
ffffffffc0201de4:	e84a                	sd	s2,16(sp)
ffffffffc0201de6:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0201de8:	4505                	li	a0,1
{
ffffffffc0201dea:	ec26                	sd	s1,24(sp)
ffffffffc0201dec:	e44e                	sd	s3,8(sp)
ffffffffc0201dee:	f406                	sd	ra,40(sp)
ffffffffc0201df0:	f022                	sd	s0,32(sp)
ffffffffc0201df2:	84ae                	mv	s1,a1
ffffffffc0201df4:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0201df6:	3f5000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
     assert(result!=NULL);
ffffffffc0201dfa:	c129                	beqz	a0,ffffffffc0201e3c <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0201dfc:	842a                	mv	s0,a0
ffffffffc0201dfe:	01893503          	ld	a0,24(s2)
ffffffffc0201e02:	4601                	li	a2,0
ffffffffc0201e04:	85a6                	mv	a1,s1
ffffffffc0201e06:	4f3000ef          	jal	ra,ffffffffc0202af8 <get_pte>
ffffffffc0201e0a:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0201e0c:	6108                	ld	a0,0(a0)
ffffffffc0201e0e:	85a2                	mv	a1,s0
ffffffffc0201e10:	5c1010ef          	jal	ra,ffffffffc0203bd0 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0201e14:	00093583          	ld	a1,0(s2)
ffffffffc0201e18:	8626                	mv	a2,s1
ffffffffc0201e1a:	00003517          	auipc	a0,0x3
ffffffffc0201e1e:	27650513          	addi	a0,a0,630 # ffffffffc0205090 <commands+0xca8>
ffffffffc0201e22:	81a1                	srli	a1,a1,0x8
ffffffffc0201e24:	a9afe0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0201e28:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0201e2a:	0089b023          	sd	s0,0(s3)
}
ffffffffc0201e2e:	7402                	ld	s0,32(sp)
ffffffffc0201e30:	64e2                	ld	s1,24(sp)
ffffffffc0201e32:	6942                	ld	s2,16(sp)
ffffffffc0201e34:	69a2                	ld	s3,8(sp)
ffffffffc0201e36:	4501                	li	a0,0
ffffffffc0201e38:	6145                	addi	sp,sp,48
ffffffffc0201e3a:	8082                	ret
     assert(result!=NULL);
ffffffffc0201e3c:	00003697          	auipc	a3,0x3
ffffffffc0201e40:	24468693          	addi	a3,a3,580 # ffffffffc0205080 <commands+0xc98>
ffffffffc0201e44:	00003617          	auipc	a2,0x3
ffffffffc0201e48:	dec60613          	addi	a2,a2,-532 # ffffffffc0204c30 <commands+0x848>
ffffffffc0201e4c:	09500593          	li	a1,149
ffffffffc0201e50:	00003517          	auipc	a0,0x3
ffffffffc0201e54:	2a050513          	addi	a0,a0,672 # ffffffffc02050f0 <commands+0xd08>
ffffffffc0201e58:	aaefe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201e5c <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201e5c:	0000f797          	auipc	a5,0xf
ffffffffc0201e60:	70478793          	addi	a5,a5,1796 # ffffffffc0211560 <free_area>
ffffffffc0201e64:	e79c                	sd	a5,8(a5)
ffffffffc0201e66:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201e68:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201e6c:	8082                	ret

ffffffffc0201e6e <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0201e6e:	0000f517          	auipc	a0,0xf
ffffffffc0201e72:	70256503          	lwu	a0,1794(a0) # ffffffffc0211570 <free_area+0x10>
ffffffffc0201e76:	8082                	ret

ffffffffc0201e78 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0201e78:	715d                	addi	sp,sp,-80
ffffffffc0201e7a:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0201e7c:	0000f917          	auipc	s2,0xf
ffffffffc0201e80:	6e490913          	addi	s2,s2,1764 # ffffffffc0211560 <free_area>
ffffffffc0201e84:	00893783          	ld	a5,8(s2)
ffffffffc0201e88:	e486                	sd	ra,72(sp)
ffffffffc0201e8a:	e0a2                	sd	s0,64(sp)
ffffffffc0201e8c:	fc26                	sd	s1,56(sp)
ffffffffc0201e8e:	f44e                	sd	s3,40(sp)
ffffffffc0201e90:	f052                	sd	s4,32(sp)
ffffffffc0201e92:	ec56                	sd	s5,24(sp)
ffffffffc0201e94:	e85a                	sd	s6,16(sp)
ffffffffc0201e96:	e45e                	sd	s7,8(sp)
ffffffffc0201e98:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e9a:	31278f63          	beq	a5,s2,ffffffffc02021b8 <default_check+0x340>
ffffffffc0201e9e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201ea2:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201ea4:	8b05                	andi	a4,a4,1
ffffffffc0201ea6:	30070d63          	beqz	a4,ffffffffc02021c0 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0201eaa:	4401                	li	s0,0
ffffffffc0201eac:	4481                	li	s1,0
ffffffffc0201eae:	a031                	j	ffffffffc0201eba <default_check+0x42>
ffffffffc0201eb0:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0201eb4:	8b09                	andi	a4,a4,2
ffffffffc0201eb6:	30070563          	beqz	a4,ffffffffc02021c0 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0201eba:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201ebe:	679c                	ld	a5,8(a5)
ffffffffc0201ec0:	2485                	addiw	s1,s1,1
ffffffffc0201ec2:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201ec4:	ff2796e3          	bne	a5,s2,ffffffffc0201eb0 <default_check+0x38>
ffffffffc0201ec8:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0201eca:	3ef000ef          	jal	ra,ffffffffc0202ab8 <nr_free_pages>
ffffffffc0201ece:	75351963          	bne	a0,s3,ffffffffc0202620 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201ed2:	4505                	li	a0,1
ffffffffc0201ed4:	317000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201ed8:	8a2a                	mv	s4,a0
ffffffffc0201eda:	48050363          	beqz	a0,ffffffffc0202360 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201ede:	4505                	li	a0,1
ffffffffc0201ee0:	30b000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201ee4:	89aa                	mv	s3,a0
ffffffffc0201ee6:	74050d63          	beqz	a0,ffffffffc0202640 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201eea:	4505                	li	a0,1
ffffffffc0201eec:	2ff000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201ef0:	8aaa                	mv	s5,a0
ffffffffc0201ef2:	4e050763          	beqz	a0,ffffffffc02023e0 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201ef6:	2f3a0563          	beq	s4,s3,ffffffffc02021e0 <default_check+0x368>
ffffffffc0201efa:	2eaa0363          	beq	s4,a0,ffffffffc02021e0 <default_check+0x368>
ffffffffc0201efe:	2ea98163          	beq	s3,a0,ffffffffc02021e0 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201f02:	000a2783          	lw	a5,0(s4)
ffffffffc0201f06:	2e079d63          	bnez	a5,ffffffffc0202200 <default_check+0x388>
ffffffffc0201f0a:	0009a783          	lw	a5,0(s3)
ffffffffc0201f0e:	2e079963          	bnez	a5,ffffffffc0202200 <default_check+0x388>
ffffffffc0201f12:	411c                	lw	a5,0(a0)
ffffffffc0201f14:	2e079663          	bnez	a5,ffffffffc0202200 <default_check+0x388>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f18:	0000f797          	auipc	a5,0xf
ffffffffc0201f1c:	67878793          	addi	a5,a5,1656 # ffffffffc0211590 <pages>
ffffffffc0201f20:	639c                	ld	a5,0(a5)
ffffffffc0201f22:	00003717          	auipc	a4,0x3
ffffffffc0201f26:	51e70713          	addi	a4,a4,1310 # ffffffffc0205440 <commands+0x1058>
ffffffffc0201f2a:	630c                	ld	a1,0(a4)
ffffffffc0201f2c:	40fa0733          	sub	a4,s4,a5
ffffffffc0201f30:	870d                	srai	a4,a4,0x3
ffffffffc0201f32:	02b70733          	mul	a4,a4,a1
ffffffffc0201f36:	00004697          	auipc	a3,0x4
ffffffffc0201f3a:	14a68693          	addi	a3,a3,330 # ffffffffc0206080 <nbase>
ffffffffc0201f3e:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201f40:	0000f697          	auipc	a3,0xf
ffffffffc0201f44:	53068693          	addi	a3,a3,1328 # ffffffffc0211470 <npage>
ffffffffc0201f48:	6294                	ld	a3,0(a3)
ffffffffc0201f4a:	06b2                	slli	a3,a3,0xc
ffffffffc0201f4c:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f4e:	0732                	slli	a4,a4,0xc
ffffffffc0201f50:	2cd77863          	bleu	a3,a4,ffffffffc0202220 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f54:	40f98733          	sub	a4,s3,a5
ffffffffc0201f58:	870d                	srai	a4,a4,0x3
ffffffffc0201f5a:	02b70733          	mul	a4,a4,a1
ffffffffc0201f5e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f60:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201f62:	4ed77f63          	bleu	a3,a4,ffffffffc0202460 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f66:	40f507b3          	sub	a5,a0,a5
ffffffffc0201f6a:	878d                	srai	a5,a5,0x3
ffffffffc0201f6c:	02b787b3          	mul	a5,a5,a1
ffffffffc0201f70:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f72:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201f74:	34d7f663          	bleu	a3,a5,ffffffffc02022c0 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0201f78:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201f7a:	00093c03          	ld	s8,0(s2)
ffffffffc0201f7e:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0201f82:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0201f86:	0000f797          	auipc	a5,0xf
ffffffffc0201f8a:	5f27b123          	sd	s2,1506(a5) # ffffffffc0211568 <free_area+0x8>
ffffffffc0201f8e:	0000f797          	auipc	a5,0xf
ffffffffc0201f92:	5d27b923          	sd	s2,1490(a5) # ffffffffc0211560 <free_area>
    nr_free = 0;
ffffffffc0201f96:	0000f797          	auipc	a5,0xf
ffffffffc0201f9a:	5c07ad23          	sw	zero,1498(a5) # ffffffffc0211570 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201f9e:	24d000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201fa2:	2e051f63          	bnez	a0,ffffffffc02022a0 <default_check+0x428>
    free_page(p0);
ffffffffc0201fa6:	4585                	li	a1,1
ffffffffc0201fa8:	8552                	mv	a0,s4
ffffffffc0201faa:	2c9000ef          	jal	ra,ffffffffc0202a72 <free_pages>
    free_page(p1);
ffffffffc0201fae:	4585                	li	a1,1
ffffffffc0201fb0:	854e                	mv	a0,s3
ffffffffc0201fb2:	2c1000ef          	jal	ra,ffffffffc0202a72 <free_pages>
    free_page(p2);
ffffffffc0201fb6:	4585                	li	a1,1
ffffffffc0201fb8:	8556                	mv	a0,s5
ffffffffc0201fba:	2b9000ef          	jal	ra,ffffffffc0202a72 <free_pages>
    assert(nr_free == 3);
ffffffffc0201fbe:	01092703          	lw	a4,16(s2)
ffffffffc0201fc2:	478d                	li	a5,3
ffffffffc0201fc4:	2af71e63          	bne	a4,a5,ffffffffc0202280 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201fc8:	4505                	li	a0,1
ffffffffc0201fca:	221000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201fce:	89aa                	mv	s3,a0
ffffffffc0201fd0:	28050863          	beqz	a0,ffffffffc0202260 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201fd4:	4505                	li	a0,1
ffffffffc0201fd6:	215000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201fda:	8aaa                	mv	s5,a0
ffffffffc0201fdc:	3e050263          	beqz	a0,ffffffffc02023c0 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201fe0:	4505                	li	a0,1
ffffffffc0201fe2:	209000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201fe6:	8a2a                	mv	s4,a0
ffffffffc0201fe8:	3a050c63          	beqz	a0,ffffffffc02023a0 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0201fec:	4505                	li	a0,1
ffffffffc0201fee:	1fd000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201ff2:	38051763          	bnez	a0,ffffffffc0202380 <default_check+0x508>
    free_page(p0);
ffffffffc0201ff6:	4585                	li	a1,1
ffffffffc0201ff8:	854e                	mv	a0,s3
ffffffffc0201ffa:	279000ef          	jal	ra,ffffffffc0202a72 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201ffe:	00893783          	ld	a5,8(s2)
ffffffffc0202002:	23278f63          	beq	a5,s2,ffffffffc0202240 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0202006:	4505                	li	a0,1
ffffffffc0202008:	1e3000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc020200c:	32a99a63          	bne	s3,a0,ffffffffc0202340 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0202010:	4505                	li	a0,1
ffffffffc0202012:	1d9000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0202016:	30051563          	bnez	a0,ffffffffc0202320 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc020201a:	01092783          	lw	a5,16(s2)
ffffffffc020201e:	2e079163          	bnez	a5,ffffffffc0202300 <default_check+0x488>
    free_page(p);
ffffffffc0202022:	854e                	mv	a0,s3
ffffffffc0202024:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202026:	0000f797          	auipc	a5,0xf
ffffffffc020202a:	5387bd23          	sd	s8,1338(a5) # ffffffffc0211560 <free_area>
ffffffffc020202e:	0000f797          	auipc	a5,0xf
ffffffffc0202032:	5377bd23          	sd	s7,1338(a5) # ffffffffc0211568 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0202036:	0000f797          	auipc	a5,0xf
ffffffffc020203a:	5367ad23          	sw	s6,1338(a5) # ffffffffc0211570 <free_area+0x10>
    free_page(p);
ffffffffc020203e:	235000ef          	jal	ra,ffffffffc0202a72 <free_pages>
    free_page(p1);
ffffffffc0202042:	4585                	li	a1,1
ffffffffc0202044:	8556                	mv	a0,s5
ffffffffc0202046:	22d000ef          	jal	ra,ffffffffc0202a72 <free_pages>
    free_page(p2);
ffffffffc020204a:	4585                	li	a1,1
ffffffffc020204c:	8552                	mv	a0,s4
ffffffffc020204e:	225000ef          	jal	ra,ffffffffc0202a72 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202052:	4515                	li	a0,5
ffffffffc0202054:	197000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0202058:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020205a:	28050363          	beqz	a0,ffffffffc02022e0 <default_check+0x468>
ffffffffc020205e:	651c                	ld	a5,8(a0)
ffffffffc0202060:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0202062:	8b85                	andi	a5,a5,1
ffffffffc0202064:	54079e63          	bnez	a5,ffffffffc02025c0 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202068:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020206a:	00093b03          	ld	s6,0(s2)
ffffffffc020206e:	00893a83          	ld	s5,8(s2)
ffffffffc0202072:	0000f797          	auipc	a5,0xf
ffffffffc0202076:	4f27b723          	sd	s2,1262(a5) # ffffffffc0211560 <free_area>
ffffffffc020207a:	0000f797          	auipc	a5,0xf
ffffffffc020207e:	4f27b723          	sd	s2,1262(a5) # ffffffffc0211568 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0202082:	169000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0202086:	50051d63          	bnez	a0,ffffffffc02025a0 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020208a:	09098a13          	addi	s4,s3,144
ffffffffc020208e:	8552                	mv	a0,s4
ffffffffc0202090:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202092:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0202096:	0000f797          	auipc	a5,0xf
ffffffffc020209a:	4c07ad23          	sw	zero,1242(a5) # ffffffffc0211570 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020209e:	1d5000ef          	jal	ra,ffffffffc0202a72 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02020a2:	4511                	li	a0,4
ffffffffc02020a4:	147000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc02020a8:	4c051c63          	bnez	a0,ffffffffc0202580 <default_check+0x708>
ffffffffc02020ac:	0989b783          	ld	a5,152(s3)
ffffffffc02020b0:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02020b2:	8b85                	andi	a5,a5,1
ffffffffc02020b4:	4a078663          	beqz	a5,ffffffffc0202560 <default_check+0x6e8>
ffffffffc02020b8:	0a89a703          	lw	a4,168(s3)
ffffffffc02020bc:	478d                	li	a5,3
ffffffffc02020be:	4af71163          	bne	a4,a5,ffffffffc0202560 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02020c2:	450d                	li	a0,3
ffffffffc02020c4:	127000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc02020c8:	8c2a                	mv	s8,a0
ffffffffc02020ca:	46050b63          	beqz	a0,ffffffffc0202540 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc02020ce:	4505                	li	a0,1
ffffffffc02020d0:	11b000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc02020d4:	44051663          	bnez	a0,ffffffffc0202520 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc02020d8:	438a1463          	bne	s4,s8,ffffffffc0202500 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02020dc:	4585                	li	a1,1
ffffffffc02020de:	854e                	mv	a0,s3
ffffffffc02020e0:	193000ef          	jal	ra,ffffffffc0202a72 <free_pages>
    free_pages(p1, 3);
ffffffffc02020e4:	458d                	li	a1,3
ffffffffc02020e6:	8552                	mv	a0,s4
ffffffffc02020e8:	18b000ef          	jal	ra,ffffffffc0202a72 <free_pages>
ffffffffc02020ec:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02020f0:	04898c13          	addi	s8,s3,72
ffffffffc02020f4:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02020f6:	8b85                	andi	a5,a5,1
ffffffffc02020f8:	3e078463          	beqz	a5,ffffffffc02024e0 <default_check+0x668>
ffffffffc02020fc:	0189a703          	lw	a4,24(s3)
ffffffffc0202100:	4785                	li	a5,1
ffffffffc0202102:	3cf71f63          	bne	a4,a5,ffffffffc02024e0 <default_check+0x668>
ffffffffc0202106:	008a3783          	ld	a5,8(s4)
ffffffffc020210a:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020210c:	8b85                	andi	a5,a5,1
ffffffffc020210e:	3a078963          	beqz	a5,ffffffffc02024c0 <default_check+0x648>
ffffffffc0202112:	018a2703          	lw	a4,24(s4)
ffffffffc0202116:	478d                	li	a5,3
ffffffffc0202118:	3af71463          	bne	a4,a5,ffffffffc02024c0 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020211c:	4505                	li	a0,1
ffffffffc020211e:	0cd000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0202122:	36a99f63          	bne	s3,a0,ffffffffc02024a0 <default_check+0x628>
    free_page(p0);
ffffffffc0202126:	4585                	li	a1,1
ffffffffc0202128:	14b000ef          	jal	ra,ffffffffc0202a72 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020212c:	4509                	li	a0,2
ffffffffc020212e:	0bd000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0202132:	34aa1763          	bne	s4,a0,ffffffffc0202480 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0202136:	4589                	li	a1,2
ffffffffc0202138:	13b000ef          	jal	ra,ffffffffc0202a72 <free_pages>
    free_page(p2);
ffffffffc020213c:	4585                	li	a1,1
ffffffffc020213e:	8562                	mv	a0,s8
ffffffffc0202140:	133000ef          	jal	ra,ffffffffc0202a72 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202144:	4515                	li	a0,5
ffffffffc0202146:	0a5000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc020214a:	89aa                	mv	s3,a0
ffffffffc020214c:	48050a63          	beqz	a0,ffffffffc02025e0 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0202150:	4505                	li	a0,1
ffffffffc0202152:	099000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0202156:	2e051563          	bnez	a0,ffffffffc0202440 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc020215a:	01092783          	lw	a5,16(s2)
ffffffffc020215e:	2c079163          	bnez	a5,ffffffffc0202420 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202162:	4595                	li	a1,5
ffffffffc0202164:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0202166:	0000f797          	auipc	a5,0xf
ffffffffc020216a:	4177a523          	sw	s7,1034(a5) # ffffffffc0211570 <free_area+0x10>
    free_list = free_list_store;
ffffffffc020216e:	0000f797          	auipc	a5,0xf
ffffffffc0202172:	3f67b923          	sd	s6,1010(a5) # ffffffffc0211560 <free_area>
ffffffffc0202176:	0000f797          	auipc	a5,0xf
ffffffffc020217a:	3f57b923          	sd	s5,1010(a5) # ffffffffc0211568 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc020217e:	0f5000ef          	jal	ra,ffffffffc0202a72 <free_pages>
    return listelm->next;
ffffffffc0202182:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202186:	01278963          	beq	a5,s2,ffffffffc0202198 <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020218a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020218e:	679c                	ld	a5,8(a5)
ffffffffc0202190:	34fd                	addiw	s1,s1,-1
ffffffffc0202192:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202194:	ff279be3          	bne	a5,s2,ffffffffc020218a <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0202198:	26049463          	bnez	s1,ffffffffc0202400 <default_check+0x588>
    assert(total == 0);
ffffffffc020219c:	46041263          	bnez	s0,ffffffffc0202600 <default_check+0x788>
}
ffffffffc02021a0:	60a6                	ld	ra,72(sp)
ffffffffc02021a2:	6406                	ld	s0,64(sp)
ffffffffc02021a4:	74e2                	ld	s1,56(sp)
ffffffffc02021a6:	7942                	ld	s2,48(sp)
ffffffffc02021a8:	79a2                	ld	s3,40(sp)
ffffffffc02021aa:	7a02                	ld	s4,32(sp)
ffffffffc02021ac:	6ae2                	ld	s5,24(sp)
ffffffffc02021ae:	6b42                	ld	s6,16(sp)
ffffffffc02021b0:	6ba2                	ld	s7,8(sp)
ffffffffc02021b2:	6c02                	ld	s8,0(sp)
ffffffffc02021b4:	6161                	addi	sp,sp,80
ffffffffc02021b6:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02021b8:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02021ba:	4401                	li	s0,0
ffffffffc02021bc:	4481                	li	s1,0
ffffffffc02021be:	b331                	j	ffffffffc0201eca <default_check+0x52>
        assert(PageProperty(p));
ffffffffc02021c0:	00003697          	auipc	a3,0x3
ffffffffc02021c4:	f5868693          	addi	a3,a3,-168 # ffffffffc0205118 <commands+0xd30>
ffffffffc02021c8:	00003617          	auipc	a2,0x3
ffffffffc02021cc:	a6860613          	addi	a2,a2,-1432 # ffffffffc0204c30 <commands+0x848>
ffffffffc02021d0:	0f000593          	li	a1,240
ffffffffc02021d4:	00003517          	auipc	a0,0x3
ffffffffc02021d8:	27450513          	addi	a0,a0,628 # ffffffffc0205448 <commands+0x1060>
ffffffffc02021dc:	f2bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02021e0:	00003697          	auipc	a3,0x3
ffffffffc02021e4:	2e068693          	addi	a3,a3,736 # ffffffffc02054c0 <commands+0x10d8>
ffffffffc02021e8:	00003617          	auipc	a2,0x3
ffffffffc02021ec:	a4860613          	addi	a2,a2,-1464 # ffffffffc0204c30 <commands+0x848>
ffffffffc02021f0:	0bd00593          	li	a1,189
ffffffffc02021f4:	00003517          	auipc	a0,0x3
ffffffffc02021f8:	25450513          	addi	a0,a0,596 # ffffffffc0205448 <commands+0x1060>
ffffffffc02021fc:	f0bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202200:	00003697          	auipc	a3,0x3
ffffffffc0202204:	2e868693          	addi	a3,a3,744 # ffffffffc02054e8 <commands+0x1100>
ffffffffc0202208:	00003617          	auipc	a2,0x3
ffffffffc020220c:	a2860613          	addi	a2,a2,-1496 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202210:	0be00593          	li	a1,190
ffffffffc0202214:	00003517          	auipc	a0,0x3
ffffffffc0202218:	23450513          	addi	a0,a0,564 # ffffffffc0205448 <commands+0x1060>
ffffffffc020221c:	eebfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202220:	00003697          	auipc	a3,0x3
ffffffffc0202224:	30868693          	addi	a3,a3,776 # ffffffffc0205528 <commands+0x1140>
ffffffffc0202228:	00003617          	auipc	a2,0x3
ffffffffc020222c:	a0860613          	addi	a2,a2,-1528 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202230:	0c000593          	li	a1,192
ffffffffc0202234:	00003517          	auipc	a0,0x3
ffffffffc0202238:	21450513          	addi	a0,a0,532 # ffffffffc0205448 <commands+0x1060>
ffffffffc020223c:	ecbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202240:	00003697          	auipc	a3,0x3
ffffffffc0202244:	37068693          	addi	a3,a3,880 # ffffffffc02055b0 <commands+0x11c8>
ffffffffc0202248:	00003617          	auipc	a2,0x3
ffffffffc020224c:	9e860613          	addi	a2,a2,-1560 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202250:	0d900593          	li	a1,217
ffffffffc0202254:	00003517          	auipc	a0,0x3
ffffffffc0202258:	1f450513          	addi	a0,a0,500 # ffffffffc0205448 <commands+0x1060>
ffffffffc020225c:	eabfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202260:	00003697          	auipc	a3,0x3
ffffffffc0202264:	20068693          	addi	a3,a3,512 # ffffffffc0205460 <commands+0x1078>
ffffffffc0202268:	00003617          	auipc	a2,0x3
ffffffffc020226c:	9c860613          	addi	a2,a2,-1592 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202270:	0d200593          	li	a1,210
ffffffffc0202274:	00003517          	auipc	a0,0x3
ffffffffc0202278:	1d450513          	addi	a0,a0,468 # ffffffffc0205448 <commands+0x1060>
ffffffffc020227c:	e8bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 3);
ffffffffc0202280:	00003697          	auipc	a3,0x3
ffffffffc0202284:	32068693          	addi	a3,a3,800 # ffffffffc02055a0 <commands+0x11b8>
ffffffffc0202288:	00003617          	auipc	a2,0x3
ffffffffc020228c:	9a860613          	addi	a2,a2,-1624 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202290:	0d000593          	li	a1,208
ffffffffc0202294:	00003517          	auipc	a0,0x3
ffffffffc0202298:	1b450513          	addi	a0,a0,436 # ffffffffc0205448 <commands+0x1060>
ffffffffc020229c:	e6bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02022a0:	00003697          	auipc	a3,0x3
ffffffffc02022a4:	2e868693          	addi	a3,a3,744 # ffffffffc0205588 <commands+0x11a0>
ffffffffc02022a8:	00003617          	auipc	a2,0x3
ffffffffc02022ac:	98860613          	addi	a2,a2,-1656 # ffffffffc0204c30 <commands+0x848>
ffffffffc02022b0:	0cb00593          	li	a1,203
ffffffffc02022b4:	00003517          	auipc	a0,0x3
ffffffffc02022b8:	19450513          	addi	a0,a0,404 # ffffffffc0205448 <commands+0x1060>
ffffffffc02022bc:	e4bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02022c0:	00003697          	auipc	a3,0x3
ffffffffc02022c4:	2a868693          	addi	a3,a3,680 # ffffffffc0205568 <commands+0x1180>
ffffffffc02022c8:	00003617          	auipc	a2,0x3
ffffffffc02022cc:	96860613          	addi	a2,a2,-1688 # ffffffffc0204c30 <commands+0x848>
ffffffffc02022d0:	0c200593          	li	a1,194
ffffffffc02022d4:	00003517          	auipc	a0,0x3
ffffffffc02022d8:	17450513          	addi	a0,a0,372 # ffffffffc0205448 <commands+0x1060>
ffffffffc02022dc:	e2bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 != NULL);
ffffffffc02022e0:	00003697          	auipc	a3,0x3
ffffffffc02022e4:	30868693          	addi	a3,a3,776 # ffffffffc02055e8 <commands+0x1200>
ffffffffc02022e8:	00003617          	auipc	a2,0x3
ffffffffc02022ec:	94860613          	addi	a2,a2,-1720 # ffffffffc0204c30 <commands+0x848>
ffffffffc02022f0:	0f800593          	li	a1,248
ffffffffc02022f4:	00003517          	auipc	a0,0x3
ffffffffc02022f8:	15450513          	addi	a0,a0,340 # ffffffffc0205448 <commands+0x1060>
ffffffffc02022fc:	e0bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 0);
ffffffffc0202300:	00003697          	auipc	a3,0x3
ffffffffc0202304:	fb868693          	addi	a3,a3,-72 # ffffffffc02052b8 <commands+0xed0>
ffffffffc0202308:	00003617          	auipc	a2,0x3
ffffffffc020230c:	92860613          	addi	a2,a2,-1752 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202310:	0df00593          	li	a1,223
ffffffffc0202314:	00003517          	auipc	a0,0x3
ffffffffc0202318:	13450513          	addi	a0,a0,308 # ffffffffc0205448 <commands+0x1060>
ffffffffc020231c:	debfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202320:	00003697          	auipc	a3,0x3
ffffffffc0202324:	26868693          	addi	a3,a3,616 # ffffffffc0205588 <commands+0x11a0>
ffffffffc0202328:	00003617          	auipc	a2,0x3
ffffffffc020232c:	90860613          	addi	a2,a2,-1784 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202330:	0dd00593          	li	a1,221
ffffffffc0202334:	00003517          	auipc	a0,0x3
ffffffffc0202338:	11450513          	addi	a0,a0,276 # ffffffffc0205448 <commands+0x1060>
ffffffffc020233c:	dcbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202340:	00003697          	auipc	a3,0x3
ffffffffc0202344:	28868693          	addi	a3,a3,648 # ffffffffc02055c8 <commands+0x11e0>
ffffffffc0202348:	00003617          	auipc	a2,0x3
ffffffffc020234c:	8e860613          	addi	a2,a2,-1816 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202350:	0dc00593          	li	a1,220
ffffffffc0202354:	00003517          	auipc	a0,0x3
ffffffffc0202358:	0f450513          	addi	a0,a0,244 # ffffffffc0205448 <commands+0x1060>
ffffffffc020235c:	dabfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202360:	00003697          	auipc	a3,0x3
ffffffffc0202364:	10068693          	addi	a3,a3,256 # ffffffffc0205460 <commands+0x1078>
ffffffffc0202368:	00003617          	auipc	a2,0x3
ffffffffc020236c:	8c860613          	addi	a2,a2,-1848 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202370:	0b900593          	li	a1,185
ffffffffc0202374:	00003517          	auipc	a0,0x3
ffffffffc0202378:	0d450513          	addi	a0,a0,212 # ffffffffc0205448 <commands+0x1060>
ffffffffc020237c:	d8bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202380:	00003697          	auipc	a3,0x3
ffffffffc0202384:	20868693          	addi	a3,a3,520 # ffffffffc0205588 <commands+0x11a0>
ffffffffc0202388:	00003617          	auipc	a2,0x3
ffffffffc020238c:	8a860613          	addi	a2,a2,-1880 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202390:	0d600593          	li	a1,214
ffffffffc0202394:	00003517          	auipc	a0,0x3
ffffffffc0202398:	0b450513          	addi	a0,a0,180 # ffffffffc0205448 <commands+0x1060>
ffffffffc020239c:	d6bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02023a0:	00003697          	auipc	a3,0x3
ffffffffc02023a4:	10068693          	addi	a3,a3,256 # ffffffffc02054a0 <commands+0x10b8>
ffffffffc02023a8:	00003617          	auipc	a2,0x3
ffffffffc02023ac:	88860613          	addi	a2,a2,-1912 # ffffffffc0204c30 <commands+0x848>
ffffffffc02023b0:	0d400593          	li	a1,212
ffffffffc02023b4:	00003517          	auipc	a0,0x3
ffffffffc02023b8:	09450513          	addi	a0,a0,148 # ffffffffc0205448 <commands+0x1060>
ffffffffc02023bc:	d4bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02023c0:	00003697          	auipc	a3,0x3
ffffffffc02023c4:	0c068693          	addi	a3,a3,192 # ffffffffc0205480 <commands+0x1098>
ffffffffc02023c8:	00003617          	auipc	a2,0x3
ffffffffc02023cc:	86860613          	addi	a2,a2,-1944 # ffffffffc0204c30 <commands+0x848>
ffffffffc02023d0:	0d300593          	li	a1,211
ffffffffc02023d4:	00003517          	auipc	a0,0x3
ffffffffc02023d8:	07450513          	addi	a0,a0,116 # ffffffffc0205448 <commands+0x1060>
ffffffffc02023dc:	d2bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02023e0:	00003697          	auipc	a3,0x3
ffffffffc02023e4:	0c068693          	addi	a3,a3,192 # ffffffffc02054a0 <commands+0x10b8>
ffffffffc02023e8:	00003617          	auipc	a2,0x3
ffffffffc02023ec:	84860613          	addi	a2,a2,-1976 # ffffffffc0204c30 <commands+0x848>
ffffffffc02023f0:	0bb00593          	li	a1,187
ffffffffc02023f4:	00003517          	auipc	a0,0x3
ffffffffc02023f8:	05450513          	addi	a0,a0,84 # ffffffffc0205448 <commands+0x1060>
ffffffffc02023fc:	d0bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(count == 0);
ffffffffc0202400:	00003697          	auipc	a3,0x3
ffffffffc0202404:	33868693          	addi	a3,a3,824 # ffffffffc0205738 <commands+0x1350>
ffffffffc0202408:	00003617          	auipc	a2,0x3
ffffffffc020240c:	82860613          	addi	a2,a2,-2008 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202410:	12500593          	li	a1,293
ffffffffc0202414:	00003517          	auipc	a0,0x3
ffffffffc0202418:	03450513          	addi	a0,a0,52 # ffffffffc0205448 <commands+0x1060>
ffffffffc020241c:	cebfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 0);
ffffffffc0202420:	00003697          	auipc	a3,0x3
ffffffffc0202424:	e9868693          	addi	a3,a3,-360 # ffffffffc02052b8 <commands+0xed0>
ffffffffc0202428:	00003617          	auipc	a2,0x3
ffffffffc020242c:	80860613          	addi	a2,a2,-2040 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202430:	11a00593          	li	a1,282
ffffffffc0202434:	00003517          	auipc	a0,0x3
ffffffffc0202438:	01450513          	addi	a0,a0,20 # ffffffffc0205448 <commands+0x1060>
ffffffffc020243c:	ccbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202440:	00003697          	auipc	a3,0x3
ffffffffc0202444:	14868693          	addi	a3,a3,328 # ffffffffc0205588 <commands+0x11a0>
ffffffffc0202448:	00002617          	auipc	a2,0x2
ffffffffc020244c:	7e860613          	addi	a2,a2,2024 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202450:	11800593          	li	a1,280
ffffffffc0202454:	00003517          	auipc	a0,0x3
ffffffffc0202458:	ff450513          	addi	a0,a0,-12 # ffffffffc0205448 <commands+0x1060>
ffffffffc020245c:	cabfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202460:	00003697          	auipc	a3,0x3
ffffffffc0202464:	0e868693          	addi	a3,a3,232 # ffffffffc0205548 <commands+0x1160>
ffffffffc0202468:	00002617          	auipc	a2,0x2
ffffffffc020246c:	7c860613          	addi	a2,a2,1992 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202470:	0c100593          	li	a1,193
ffffffffc0202474:	00003517          	auipc	a0,0x3
ffffffffc0202478:	fd450513          	addi	a0,a0,-44 # ffffffffc0205448 <commands+0x1060>
ffffffffc020247c:	c8bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202480:	00003697          	auipc	a3,0x3
ffffffffc0202484:	27868693          	addi	a3,a3,632 # ffffffffc02056f8 <commands+0x1310>
ffffffffc0202488:	00002617          	auipc	a2,0x2
ffffffffc020248c:	7a860613          	addi	a2,a2,1960 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202490:	11200593          	li	a1,274
ffffffffc0202494:	00003517          	auipc	a0,0x3
ffffffffc0202498:	fb450513          	addi	a0,a0,-76 # ffffffffc0205448 <commands+0x1060>
ffffffffc020249c:	c6bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02024a0:	00003697          	auipc	a3,0x3
ffffffffc02024a4:	23868693          	addi	a3,a3,568 # ffffffffc02056d8 <commands+0x12f0>
ffffffffc02024a8:	00002617          	auipc	a2,0x2
ffffffffc02024ac:	78860613          	addi	a2,a2,1928 # ffffffffc0204c30 <commands+0x848>
ffffffffc02024b0:	11000593          	li	a1,272
ffffffffc02024b4:	00003517          	auipc	a0,0x3
ffffffffc02024b8:	f9450513          	addi	a0,a0,-108 # ffffffffc0205448 <commands+0x1060>
ffffffffc02024bc:	c4bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02024c0:	00003697          	auipc	a3,0x3
ffffffffc02024c4:	1f068693          	addi	a3,a3,496 # ffffffffc02056b0 <commands+0x12c8>
ffffffffc02024c8:	00002617          	auipc	a2,0x2
ffffffffc02024cc:	76860613          	addi	a2,a2,1896 # ffffffffc0204c30 <commands+0x848>
ffffffffc02024d0:	10e00593          	li	a1,270
ffffffffc02024d4:	00003517          	auipc	a0,0x3
ffffffffc02024d8:	f7450513          	addi	a0,a0,-140 # ffffffffc0205448 <commands+0x1060>
ffffffffc02024dc:	c2bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02024e0:	00003697          	auipc	a3,0x3
ffffffffc02024e4:	1a868693          	addi	a3,a3,424 # ffffffffc0205688 <commands+0x12a0>
ffffffffc02024e8:	00002617          	auipc	a2,0x2
ffffffffc02024ec:	74860613          	addi	a2,a2,1864 # ffffffffc0204c30 <commands+0x848>
ffffffffc02024f0:	10d00593          	li	a1,269
ffffffffc02024f4:	00003517          	auipc	a0,0x3
ffffffffc02024f8:	f5450513          	addi	a0,a0,-172 # ffffffffc0205448 <commands+0x1060>
ffffffffc02024fc:	c0bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0202500:	00003697          	auipc	a3,0x3
ffffffffc0202504:	17868693          	addi	a3,a3,376 # ffffffffc0205678 <commands+0x1290>
ffffffffc0202508:	00002617          	auipc	a2,0x2
ffffffffc020250c:	72860613          	addi	a2,a2,1832 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202510:	10800593          	li	a1,264
ffffffffc0202514:	00003517          	auipc	a0,0x3
ffffffffc0202518:	f3450513          	addi	a0,a0,-204 # ffffffffc0205448 <commands+0x1060>
ffffffffc020251c:	bebfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202520:	00003697          	auipc	a3,0x3
ffffffffc0202524:	06868693          	addi	a3,a3,104 # ffffffffc0205588 <commands+0x11a0>
ffffffffc0202528:	00002617          	auipc	a2,0x2
ffffffffc020252c:	70860613          	addi	a2,a2,1800 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202530:	10700593          	li	a1,263
ffffffffc0202534:	00003517          	auipc	a0,0x3
ffffffffc0202538:	f1450513          	addi	a0,a0,-236 # ffffffffc0205448 <commands+0x1060>
ffffffffc020253c:	bcbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202540:	00003697          	auipc	a3,0x3
ffffffffc0202544:	11868693          	addi	a3,a3,280 # ffffffffc0205658 <commands+0x1270>
ffffffffc0202548:	00002617          	auipc	a2,0x2
ffffffffc020254c:	6e860613          	addi	a2,a2,1768 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202550:	10600593          	li	a1,262
ffffffffc0202554:	00003517          	auipc	a0,0x3
ffffffffc0202558:	ef450513          	addi	a0,a0,-268 # ffffffffc0205448 <commands+0x1060>
ffffffffc020255c:	babfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202560:	00003697          	auipc	a3,0x3
ffffffffc0202564:	0c868693          	addi	a3,a3,200 # ffffffffc0205628 <commands+0x1240>
ffffffffc0202568:	00002617          	auipc	a2,0x2
ffffffffc020256c:	6c860613          	addi	a2,a2,1736 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202570:	10500593          	li	a1,261
ffffffffc0202574:	00003517          	auipc	a0,0x3
ffffffffc0202578:	ed450513          	addi	a0,a0,-300 # ffffffffc0205448 <commands+0x1060>
ffffffffc020257c:	b8bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202580:	00003697          	auipc	a3,0x3
ffffffffc0202584:	09068693          	addi	a3,a3,144 # ffffffffc0205610 <commands+0x1228>
ffffffffc0202588:	00002617          	auipc	a2,0x2
ffffffffc020258c:	6a860613          	addi	a2,a2,1704 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202590:	10400593          	li	a1,260
ffffffffc0202594:	00003517          	auipc	a0,0x3
ffffffffc0202598:	eb450513          	addi	a0,a0,-332 # ffffffffc0205448 <commands+0x1060>
ffffffffc020259c:	b6bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02025a0:	00003697          	auipc	a3,0x3
ffffffffc02025a4:	fe868693          	addi	a3,a3,-24 # ffffffffc0205588 <commands+0x11a0>
ffffffffc02025a8:	00002617          	auipc	a2,0x2
ffffffffc02025ac:	68860613          	addi	a2,a2,1672 # ffffffffc0204c30 <commands+0x848>
ffffffffc02025b0:	0fe00593          	li	a1,254
ffffffffc02025b4:	00003517          	auipc	a0,0x3
ffffffffc02025b8:	e9450513          	addi	a0,a0,-364 # ffffffffc0205448 <commands+0x1060>
ffffffffc02025bc:	b4bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(!PageProperty(p0));
ffffffffc02025c0:	00003697          	auipc	a3,0x3
ffffffffc02025c4:	03868693          	addi	a3,a3,56 # ffffffffc02055f8 <commands+0x1210>
ffffffffc02025c8:	00002617          	auipc	a2,0x2
ffffffffc02025cc:	66860613          	addi	a2,a2,1640 # ffffffffc0204c30 <commands+0x848>
ffffffffc02025d0:	0f900593          	li	a1,249
ffffffffc02025d4:	00003517          	auipc	a0,0x3
ffffffffc02025d8:	e7450513          	addi	a0,a0,-396 # ffffffffc0205448 <commands+0x1060>
ffffffffc02025dc:	b2bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02025e0:	00003697          	auipc	a3,0x3
ffffffffc02025e4:	13868693          	addi	a3,a3,312 # ffffffffc0205718 <commands+0x1330>
ffffffffc02025e8:	00002617          	auipc	a2,0x2
ffffffffc02025ec:	64860613          	addi	a2,a2,1608 # ffffffffc0204c30 <commands+0x848>
ffffffffc02025f0:	11700593          	li	a1,279
ffffffffc02025f4:	00003517          	auipc	a0,0x3
ffffffffc02025f8:	e5450513          	addi	a0,a0,-428 # ffffffffc0205448 <commands+0x1060>
ffffffffc02025fc:	b0bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(total == 0);
ffffffffc0202600:	00003697          	auipc	a3,0x3
ffffffffc0202604:	14868693          	addi	a3,a3,328 # ffffffffc0205748 <commands+0x1360>
ffffffffc0202608:	00002617          	auipc	a2,0x2
ffffffffc020260c:	62860613          	addi	a2,a2,1576 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202610:	12600593          	li	a1,294
ffffffffc0202614:	00003517          	auipc	a0,0x3
ffffffffc0202618:	e3450513          	addi	a0,a0,-460 # ffffffffc0205448 <commands+0x1060>
ffffffffc020261c:	aebfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(total == nr_free_pages());
ffffffffc0202620:	00003697          	auipc	a3,0x3
ffffffffc0202624:	b0868693          	addi	a3,a3,-1272 # ffffffffc0205128 <commands+0xd40>
ffffffffc0202628:	00002617          	auipc	a2,0x2
ffffffffc020262c:	60860613          	addi	a2,a2,1544 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202630:	0f300593          	li	a1,243
ffffffffc0202634:	00003517          	auipc	a0,0x3
ffffffffc0202638:	e1450513          	addi	a0,a0,-492 # ffffffffc0205448 <commands+0x1060>
ffffffffc020263c:	acbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202640:	00003697          	auipc	a3,0x3
ffffffffc0202644:	e4068693          	addi	a3,a3,-448 # ffffffffc0205480 <commands+0x1098>
ffffffffc0202648:	00002617          	auipc	a2,0x2
ffffffffc020264c:	5e860613          	addi	a2,a2,1512 # ffffffffc0204c30 <commands+0x848>
ffffffffc0202650:	0ba00593          	li	a1,186
ffffffffc0202654:	00003517          	auipc	a0,0x3
ffffffffc0202658:	df450513          	addi	a0,a0,-524 # ffffffffc0205448 <commands+0x1060>
ffffffffc020265c:	aabfd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202660 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0202660:	1141                	addi	sp,sp,-16
ffffffffc0202662:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202664:	18058063          	beqz	a1,ffffffffc02027e4 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc0202668:	00359693          	slli	a3,a1,0x3
ffffffffc020266c:	96ae                	add	a3,a3,a1
ffffffffc020266e:	068e                	slli	a3,a3,0x3
ffffffffc0202670:	96aa                	add	a3,a3,a0
ffffffffc0202672:	02d50d63          	beq	a0,a3,ffffffffc02026ac <default_free_pages+0x4c>
ffffffffc0202676:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202678:	8b85                	andi	a5,a5,1
ffffffffc020267a:	14079563          	bnez	a5,ffffffffc02027c4 <default_free_pages+0x164>
ffffffffc020267e:	651c                	ld	a5,8(a0)
ffffffffc0202680:	8385                	srli	a5,a5,0x1
ffffffffc0202682:	8b85                	andi	a5,a5,1
ffffffffc0202684:	14079063          	bnez	a5,ffffffffc02027c4 <default_free_pages+0x164>
ffffffffc0202688:	87aa                	mv	a5,a0
ffffffffc020268a:	a809                	j	ffffffffc020269c <default_free_pages+0x3c>
ffffffffc020268c:	6798                	ld	a4,8(a5)
ffffffffc020268e:	8b05                	andi	a4,a4,1
ffffffffc0202690:	12071a63          	bnez	a4,ffffffffc02027c4 <default_free_pages+0x164>
ffffffffc0202694:	6798                	ld	a4,8(a5)
ffffffffc0202696:	8b09                	andi	a4,a4,2
ffffffffc0202698:	12071663          	bnez	a4,ffffffffc02027c4 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc020269c:	0007b423          	sd	zero,8(a5)
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02026a0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02026a4:	04878793          	addi	a5,a5,72
ffffffffc02026a8:	fed792e3          	bne	a5,a3,ffffffffc020268c <default_free_pages+0x2c>
    base->property = n;
ffffffffc02026ac:	2581                	sext.w	a1,a1
ffffffffc02026ae:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc02026b0:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02026b4:	4789                	li	a5,2
ffffffffc02026b6:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02026ba:	0000f697          	auipc	a3,0xf
ffffffffc02026be:	ea668693          	addi	a3,a3,-346 # ffffffffc0211560 <free_area>
ffffffffc02026c2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02026c4:	669c                	ld	a5,8(a3)
ffffffffc02026c6:	9db9                	addw	a1,a1,a4
ffffffffc02026c8:	0000f717          	auipc	a4,0xf
ffffffffc02026cc:	eab72423          	sw	a1,-344(a4) # ffffffffc0211570 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02026d0:	08d78f63          	beq	a5,a3,ffffffffc020276e <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc02026d4:	fe078713          	addi	a4,a5,-32
ffffffffc02026d8:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02026da:	4801                	li	a6,0
ffffffffc02026dc:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02026e0:	00e56a63          	bltu	a0,a4,ffffffffc02026f4 <default_free_pages+0x94>
    return listelm->next;
ffffffffc02026e4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02026e6:	02d70563          	beq	a4,a3,ffffffffc0202710 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02026ea:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02026ec:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02026f0:	fee57ae3          	bleu	a4,a0,ffffffffc02026e4 <default_free_pages+0x84>
ffffffffc02026f4:	00080663          	beqz	a6,ffffffffc0202700 <default_free_pages+0xa0>
ffffffffc02026f8:	0000f817          	auipc	a6,0xf
ffffffffc02026fc:	e6b83423          	sd	a1,-408(a6) # ffffffffc0211560 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202700:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0202702:	e390                	sd	a2,0(a5)
ffffffffc0202704:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0202706:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202708:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc020270a:	02d59163          	bne	a1,a3,ffffffffc020272c <default_free_pages+0xcc>
ffffffffc020270e:	a091                	j	ffffffffc0202752 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc0202710:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202712:	f514                	sd	a3,40(a0)
ffffffffc0202714:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202716:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc0202718:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020271a:	00d70563          	beq	a4,a3,ffffffffc0202724 <default_free_pages+0xc4>
ffffffffc020271e:	4805                	li	a6,1
ffffffffc0202720:	87ba                	mv	a5,a4
ffffffffc0202722:	b7e9                	j	ffffffffc02026ec <default_free_pages+0x8c>
ffffffffc0202724:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0202726:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0202728:	02d78163          	beq	a5,a3,ffffffffc020274a <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc020272c:	ff85a803          	lw	a6,-8(a1) # ff8 <BASE_ADDRESS-0xffffffffc01ff008>
        p = le2page(le, page_link);
ffffffffc0202730:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc0202734:	02081713          	slli	a4,a6,0x20
ffffffffc0202738:	9301                	srli	a4,a4,0x20
ffffffffc020273a:	00371793          	slli	a5,a4,0x3
ffffffffc020273e:	97ba                	add	a5,a5,a4
ffffffffc0202740:	078e                	slli	a5,a5,0x3
ffffffffc0202742:	97b2                	add	a5,a5,a2
ffffffffc0202744:	02f50e63          	beq	a0,a5,ffffffffc0202780 <default_free_pages+0x120>
ffffffffc0202748:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc020274a:	fe078713          	addi	a4,a5,-32
ffffffffc020274e:	00d78d63          	beq	a5,a3,ffffffffc0202768 <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0202752:	4d0c                	lw	a1,24(a0)
ffffffffc0202754:	02059613          	slli	a2,a1,0x20
ffffffffc0202758:	9201                	srli	a2,a2,0x20
ffffffffc020275a:	00361693          	slli	a3,a2,0x3
ffffffffc020275e:	96b2                	add	a3,a3,a2
ffffffffc0202760:	068e                	slli	a3,a3,0x3
ffffffffc0202762:	96aa                	add	a3,a3,a0
ffffffffc0202764:	04d70063          	beq	a4,a3,ffffffffc02027a4 <default_free_pages+0x144>
}
ffffffffc0202768:	60a2                	ld	ra,8(sp)
ffffffffc020276a:	0141                	addi	sp,sp,16
ffffffffc020276c:	8082                	ret
ffffffffc020276e:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0202770:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0202774:	e398                	sd	a4,0(a5)
ffffffffc0202776:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0202778:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020277a:	f11c                	sd	a5,32(a0)
}
ffffffffc020277c:	0141                	addi	sp,sp,16
ffffffffc020277e:	8082                	ret
            p->property += base->property;
ffffffffc0202780:	4d1c                	lw	a5,24(a0)
ffffffffc0202782:	0107883b          	addw	a6,a5,a6
ffffffffc0202786:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020278a:	57f5                	li	a5,-3
ffffffffc020278c:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202790:	02053803          	ld	a6,32(a0)
ffffffffc0202794:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc0202796:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0202798:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc020279c:	659c                	ld	a5,8(a1)
ffffffffc020279e:	01073023          	sd	a6,0(a4)
ffffffffc02027a2:	b765                	j	ffffffffc020274a <default_free_pages+0xea>
            base->property += p->property;
ffffffffc02027a4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02027a8:	fe878693          	addi	a3,a5,-24
ffffffffc02027ac:	9db9                	addw	a1,a1,a4
ffffffffc02027ae:	cd0c                	sw	a1,24(a0)
ffffffffc02027b0:	5775                	li	a4,-3
ffffffffc02027b2:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02027b6:	6398                	ld	a4,0(a5)
ffffffffc02027b8:	679c                	ld	a5,8(a5)
}
ffffffffc02027ba:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02027bc:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02027be:	e398                	sd	a4,0(a5)
ffffffffc02027c0:	0141                	addi	sp,sp,16
ffffffffc02027c2:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02027c4:	00003697          	auipc	a3,0x3
ffffffffc02027c8:	f9468693          	addi	a3,a3,-108 # ffffffffc0205758 <commands+0x1370>
ffffffffc02027cc:	00002617          	auipc	a2,0x2
ffffffffc02027d0:	46460613          	addi	a2,a2,1124 # ffffffffc0204c30 <commands+0x848>
ffffffffc02027d4:	08300593          	li	a1,131
ffffffffc02027d8:	00003517          	auipc	a0,0x3
ffffffffc02027dc:	c7050513          	addi	a0,a0,-912 # ffffffffc0205448 <commands+0x1060>
ffffffffc02027e0:	927fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(n > 0);
ffffffffc02027e4:	00003697          	auipc	a3,0x3
ffffffffc02027e8:	f9c68693          	addi	a3,a3,-100 # ffffffffc0205780 <commands+0x1398>
ffffffffc02027ec:	00002617          	auipc	a2,0x2
ffffffffc02027f0:	44460613          	addi	a2,a2,1092 # ffffffffc0204c30 <commands+0x848>
ffffffffc02027f4:	08000593          	li	a1,128
ffffffffc02027f8:	00003517          	auipc	a0,0x3
ffffffffc02027fc:	c5050513          	addi	a0,a0,-944 # ffffffffc0205448 <commands+0x1060>
ffffffffc0202800:	907fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202804 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0202804:	cd51                	beqz	a0,ffffffffc02028a0 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc0202806:	0000f597          	auipc	a1,0xf
ffffffffc020280a:	d5a58593          	addi	a1,a1,-678 # ffffffffc0211560 <free_area>
ffffffffc020280e:	0105a803          	lw	a6,16(a1)
ffffffffc0202812:	862a                	mv	a2,a0
ffffffffc0202814:	02081793          	slli	a5,a6,0x20
ffffffffc0202818:	9381                	srli	a5,a5,0x20
ffffffffc020281a:	00a7ee63          	bltu	a5,a0,ffffffffc0202836 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020281e:	87ae                	mv	a5,a1
ffffffffc0202820:	a801                	j	ffffffffc0202830 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0202822:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202826:	02071693          	slli	a3,a4,0x20
ffffffffc020282a:	9281                	srli	a3,a3,0x20
ffffffffc020282c:	00c6f763          	bleu	a2,a3,ffffffffc020283a <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0202830:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202832:	feb798e3          	bne	a5,a1,ffffffffc0202822 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0202836:	4501                	li	a0,0
}
ffffffffc0202838:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020283a:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc020283e:	dd6d                	beqz	a0,ffffffffc0202838 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0202840:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202844:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0202848:	00060e1b          	sext.w	t3,a2
ffffffffc020284c:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0202850:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0202854:	02d67b63          	bleu	a3,a2,ffffffffc020288a <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc0202858:	00361693          	slli	a3,a2,0x3
ffffffffc020285c:	96b2                	add	a3,a3,a2
ffffffffc020285e:	068e                	slli	a3,a3,0x3
ffffffffc0202860:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0202862:	41c7073b          	subw	a4,a4,t3
ffffffffc0202866:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202868:	00868613          	addi	a2,a3,8
ffffffffc020286c:	4709                	li	a4,2
ffffffffc020286e:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0202872:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0202876:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc020287a:	0105a803          	lw	a6,16(a1)
ffffffffc020287e:	e310                	sd	a2,0(a4)
ffffffffc0202880:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0202884:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc0202886:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc020288a:	41c8083b          	subw	a6,a6,t3
ffffffffc020288e:	0000f717          	auipc	a4,0xf
ffffffffc0202892:	cf072123          	sw	a6,-798(a4) # ffffffffc0211570 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202896:	5775                	li	a4,-3
ffffffffc0202898:	17a1                	addi	a5,a5,-24
ffffffffc020289a:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc020289e:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02028a0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02028a2:	00003697          	auipc	a3,0x3
ffffffffc02028a6:	ede68693          	addi	a3,a3,-290 # ffffffffc0205780 <commands+0x1398>
ffffffffc02028aa:	00002617          	auipc	a2,0x2
ffffffffc02028ae:	38660613          	addi	a2,a2,902 # ffffffffc0204c30 <commands+0x848>
ffffffffc02028b2:	06200593          	li	a1,98
ffffffffc02028b6:	00003517          	auipc	a0,0x3
ffffffffc02028ba:	b9250513          	addi	a0,a0,-1134 # ffffffffc0205448 <commands+0x1060>
default_alloc_pages(size_t n) {
ffffffffc02028be:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02028c0:	847fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02028c4 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02028c4:	1141                	addi	sp,sp,-16
ffffffffc02028c6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02028c8:	c1fd                	beqz	a1,ffffffffc02029ae <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc02028ca:	00359693          	slli	a3,a1,0x3
ffffffffc02028ce:	96ae                	add	a3,a3,a1
ffffffffc02028d0:	068e                	slli	a3,a3,0x3
ffffffffc02028d2:	96aa                	add	a3,a3,a0
ffffffffc02028d4:	02d50463          	beq	a0,a3,ffffffffc02028fc <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02028d8:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02028da:	87aa                	mv	a5,a0
ffffffffc02028dc:	8b05                	andi	a4,a4,1
ffffffffc02028de:	e709                	bnez	a4,ffffffffc02028e8 <default_init_memmap+0x24>
ffffffffc02028e0:	a07d                	j	ffffffffc020298e <default_init_memmap+0xca>
ffffffffc02028e2:	6798                	ld	a4,8(a5)
ffffffffc02028e4:	8b05                	andi	a4,a4,1
ffffffffc02028e6:	c745                	beqz	a4,ffffffffc020298e <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc02028e8:	0007ac23          	sw	zero,24(a5)
ffffffffc02028ec:	0007b423          	sd	zero,8(a5)
ffffffffc02028f0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02028f4:	04878793          	addi	a5,a5,72
ffffffffc02028f8:	fed795e3          	bne	a5,a3,ffffffffc02028e2 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc02028fc:	2581                	sext.w	a1,a1
ffffffffc02028fe:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202900:	4789                	li	a5,2
ffffffffc0202902:	00850713          	addi	a4,a0,8
ffffffffc0202906:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020290a:	0000f697          	auipc	a3,0xf
ffffffffc020290e:	c5668693          	addi	a3,a3,-938 # ffffffffc0211560 <free_area>
ffffffffc0202912:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202914:	669c                	ld	a5,8(a3)
ffffffffc0202916:	9db9                	addw	a1,a1,a4
ffffffffc0202918:	0000f717          	auipc	a4,0xf
ffffffffc020291c:	c4b72c23          	sw	a1,-936(a4) # ffffffffc0211570 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0202920:	04d78a63          	beq	a5,a3,ffffffffc0202974 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0202924:	fe078713          	addi	a4,a5,-32
ffffffffc0202928:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020292a:	4801                	li	a6,0
ffffffffc020292c:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0202930:	00e56a63          	bltu	a0,a4,ffffffffc0202944 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc0202934:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202936:	02d70563          	beq	a4,a3,ffffffffc0202960 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020293a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020293c:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0202940:	fee57ae3          	bleu	a4,a0,ffffffffc0202934 <default_init_memmap+0x70>
ffffffffc0202944:	00080663          	beqz	a6,ffffffffc0202950 <default_init_memmap+0x8c>
ffffffffc0202948:	0000f717          	auipc	a4,0xf
ffffffffc020294c:	c0b73c23          	sd	a1,-1000(a4) # ffffffffc0211560 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202950:	6398                	ld	a4,0(a5)
}
ffffffffc0202952:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202954:	e390                	sd	a2,0(a5)
ffffffffc0202956:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202958:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020295a:	f118                	sd	a4,32(a0)
ffffffffc020295c:	0141                	addi	sp,sp,16
ffffffffc020295e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202960:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202962:	f514                	sd	a3,40(a0)
ffffffffc0202964:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202966:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc0202968:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020296a:	00d70e63          	beq	a4,a3,ffffffffc0202986 <default_init_memmap+0xc2>
ffffffffc020296e:	4805                	li	a6,1
ffffffffc0202970:	87ba                	mv	a5,a4
ffffffffc0202972:	b7e9                	j	ffffffffc020293c <default_init_memmap+0x78>
}
ffffffffc0202974:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0202976:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc020297a:	e398                	sd	a4,0(a5)
ffffffffc020297c:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020297e:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202980:	f11c                	sd	a5,32(a0)
}
ffffffffc0202982:	0141                	addi	sp,sp,16
ffffffffc0202984:	8082                	ret
ffffffffc0202986:	60a2                	ld	ra,8(sp)
ffffffffc0202988:	e290                	sd	a2,0(a3)
ffffffffc020298a:	0141                	addi	sp,sp,16
ffffffffc020298c:	8082                	ret
        assert(PageReserved(p));
ffffffffc020298e:	00003697          	auipc	a3,0x3
ffffffffc0202992:	dfa68693          	addi	a3,a3,-518 # ffffffffc0205788 <commands+0x13a0>
ffffffffc0202996:	00002617          	auipc	a2,0x2
ffffffffc020299a:	29a60613          	addi	a2,a2,666 # ffffffffc0204c30 <commands+0x848>
ffffffffc020299e:	04900593          	li	a1,73
ffffffffc02029a2:	00003517          	auipc	a0,0x3
ffffffffc02029a6:	aa650513          	addi	a0,a0,-1370 # ffffffffc0205448 <commands+0x1060>
ffffffffc02029aa:	f5cfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(n > 0);
ffffffffc02029ae:	00003697          	auipc	a3,0x3
ffffffffc02029b2:	dd268693          	addi	a3,a3,-558 # ffffffffc0205780 <commands+0x1398>
ffffffffc02029b6:	00002617          	auipc	a2,0x2
ffffffffc02029ba:	27a60613          	addi	a2,a2,634 # ffffffffc0204c30 <commands+0x848>
ffffffffc02029be:	04600593          	li	a1,70
ffffffffc02029c2:	00003517          	auipc	a0,0x3
ffffffffc02029c6:	a8650513          	addi	a0,a0,-1402 # ffffffffc0205448 <commands+0x1060>
ffffffffc02029ca:	f3cfd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02029ce <pa2page.part.4>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02029ce:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02029d0:	00002617          	auipc	a2,0x2
ffffffffc02029d4:	63860613          	addi	a2,a2,1592 # ffffffffc0205008 <commands+0xc20>
ffffffffc02029d8:	06500593          	li	a1,101
ffffffffc02029dc:	00002517          	auipc	a0,0x2
ffffffffc02029e0:	64c50513          	addi	a0,a0,1612 # ffffffffc0205028 <commands+0xc40>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02029e4:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02029e6:	f20fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02029ea <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02029ea:	715d                	addi	sp,sp,-80
ffffffffc02029ec:	e0a2                	sd	s0,64(sp)
ffffffffc02029ee:	fc26                	sd	s1,56(sp)
ffffffffc02029f0:	f84a                	sd	s2,48(sp)
ffffffffc02029f2:	f44e                	sd	s3,40(sp)
ffffffffc02029f4:	f052                	sd	s4,32(sp)
ffffffffc02029f6:	ec56                	sd	s5,24(sp)
ffffffffc02029f8:	e486                	sd	ra,72(sp)
ffffffffc02029fa:	842a                	mv	s0,a0
ffffffffc02029fc:	0000f497          	auipc	s1,0xf
ffffffffc0202a00:	b7c48493          	addi	s1,s1,-1156 # ffffffffc0211578 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a04:	4985                	li	s3,1
ffffffffc0202a06:	0000fa17          	auipc	s4,0xf
ffffffffc0202a0a:	a5aa0a13          	addi	s4,s4,-1446 # ffffffffc0211460 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a0e:	0005091b          	sext.w	s2,a0
ffffffffc0202a12:	0000fa97          	auipc	s5,0xf
ffffffffc0202a16:	a7ea8a93          	addi	s5,s5,-1410 # ffffffffc0211490 <check_mm_struct>
ffffffffc0202a1a:	a00d                	j	ffffffffc0202a3c <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202a1c:	609c                	ld	a5,0(s1)
ffffffffc0202a1e:	6f9c                	ld	a5,24(a5)
ffffffffc0202a20:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a22:	4601                	li	a2,0
ffffffffc0202a24:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a26:	ed0d                	bnez	a0,ffffffffc0202a60 <alloc_pages+0x76>
ffffffffc0202a28:	0289ec63          	bltu	s3,s0,ffffffffc0202a60 <alloc_pages+0x76>
ffffffffc0202a2c:	000a2783          	lw	a5,0(s4)
ffffffffc0202a30:	2781                	sext.w	a5,a5
ffffffffc0202a32:	c79d                	beqz	a5,ffffffffc0202a60 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a34:	000ab503          	ld	a0,0(s5)
ffffffffc0202a38:	a96ff0ef          	jal	ra,ffffffffc0201cce <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202a3c:	100027f3          	csrr	a5,sstatus
ffffffffc0202a40:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202a42:	8522                	mv	a0,s0
ffffffffc0202a44:	dfe1                	beqz	a5,ffffffffc0202a1c <alloc_pages+0x32>
        intr_disable();
ffffffffc0202a46:	ab5fd0ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc0202a4a:	609c                	ld	a5,0(s1)
ffffffffc0202a4c:	8522                	mv	a0,s0
ffffffffc0202a4e:	6f9c                	ld	a5,24(a5)
ffffffffc0202a50:	9782                	jalr	a5
ffffffffc0202a52:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202a54:	aa1fd0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
ffffffffc0202a58:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a5a:	4601                	li	a2,0
ffffffffc0202a5c:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a5e:	d569                	beqz	a0,ffffffffc0202a28 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0202a60:	60a6                	ld	ra,72(sp)
ffffffffc0202a62:	6406                	ld	s0,64(sp)
ffffffffc0202a64:	74e2                	ld	s1,56(sp)
ffffffffc0202a66:	7942                	ld	s2,48(sp)
ffffffffc0202a68:	79a2                	ld	s3,40(sp)
ffffffffc0202a6a:	7a02                	ld	s4,32(sp)
ffffffffc0202a6c:	6ae2                	ld	s5,24(sp)
ffffffffc0202a6e:	6161                	addi	sp,sp,80
ffffffffc0202a70:	8082                	ret

ffffffffc0202a72 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202a72:	100027f3          	csrr	a5,sstatus
ffffffffc0202a76:	8b89                	andi	a5,a5,2
ffffffffc0202a78:	eb89                	bnez	a5,ffffffffc0202a8a <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0202a7a:	0000f797          	auipc	a5,0xf
ffffffffc0202a7e:	afe78793          	addi	a5,a5,-1282 # ffffffffc0211578 <pmm_manager>
ffffffffc0202a82:	639c                	ld	a5,0(a5)
ffffffffc0202a84:	0207b303          	ld	t1,32(a5)
ffffffffc0202a88:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0202a8a:	1101                	addi	sp,sp,-32
ffffffffc0202a8c:	ec06                	sd	ra,24(sp)
ffffffffc0202a8e:	e822                	sd	s0,16(sp)
ffffffffc0202a90:	e426                	sd	s1,8(sp)
ffffffffc0202a92:	842a                	mv	s0,a0
ffffffffc0202a94:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202a96:	a65fd0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202a9a:	0000f797          	auipc	a5,0xf
ffffffffc0202a9e:	ade78793          	addi	a5,a5,-1314 # ffffffffc0211578 <pmm_manager>
ffffffffc0202aa2:	639c                	ld	a5,0(a5)
ffffffffc0202aa4:	85a6                	mv	a1,s1
ffffffffc0202aa6:	8522                	mv	a0,s0
ffffffffc0202aa8:	739c                	ld	a5,32(a5)
ffffffffc0202aaa:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0202aac:	6442                	ld	s0,16(sp)
ffffffffc0202aae:	60e2                	ld	ra,24(sp)
ffffffffc0202ab0:	64a2                	ld	s1,8(sp)
ffffffffc0202ab2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202ab4:	a41fd06f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc0202ab8 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202ab8:	100027f3          	csrr	a5,sstatus
ffffffffc0202abc:	8b89                	andi	a5,a5,2
ffffffffc0202abe:	eb89                	bnez	a5,ffffffffc0202ad0 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202ac0:	0000f797          	auipc	a5,0xf
ffffffffc0202ac4:	ab878793          	addi	a5,a5,-1352 # ffffffffc0211578 <pmm_manager>
ffffffffc0202ac8:	639c                	ld	a5,0(a5)
ffffffffc0202aca:	0287b303          	ld	t1,40(a5)
ffffffffc0202ace:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0202ad0:	1141                	addi	sp,sp,-16
ffffffffc0202ad2:	e406                	sd	ra,8(sp)
ffffffffc0202ad4:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202ad6:	a25fd0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202ada:	0000f797          	auipc	a5,0xf
ffffffffc0202ade:	a9e78793          	addi	a5,a5,-1378 # ffffffffc0211578 <pmm_manager>
ffffffffc0202ae2:	639c                	ld	a5,0(a5)
ffffffffc0202ae4:	779c                	ld	a5,40(a5)
ffffffffc0202ae6:	9782                	jalr	a5
ffffffffc0202ae8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202aea:	a0bfd0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202aee:	8522                	mv	a0,s0
ffffffffc0202af0:	60a2                	ld	ra,8(sp)
ffffffffc0202af2:	6402                	ld	s0,0(sp)
ffffffffc0202af4:	0141                	addi	sp,sp,16
ffffffffc0202af6:	8082                	ret

ffffffffc0202af8 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202af8:	715d                	addi	sp,sp,-80
ffffffffc0202afa:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202afc:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0202b00:	1ff4f493          	andi	s1,s1,511
ffffffffc0202b04:	048e                	slli	s1,s1,0x3
ffffffffc0202b06:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202b08:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b0a:	f84a                	sd	s2,48(sp)
ffffffffc0202b0c:	f44e                	sd	s3,40(sp)
ffffffffc0202b0e:	f052                	sd	s4,32(sp)
ffffffffc0202b10:	e486                	sd	ra,72(sp)
ffffffffc0202b12:	e0a2                	sd	s0,64(sp)
ffffffffc0202b14:	ec56                	sd	s5,24(sp)
ffffffffc0202b16:	e85a                	sd	s6,16(sp)
ffffffffc0202b18:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202b1a:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b1e:	892e                	mv	s2,a1
ffffffffc0202b20:	8a32                	mv	s4,a2
ffffffffc0202b22:	0000f997          	auipc	s3,0xf
ffffffffc0202b26:	94e98993          	addi	s3,s3,-1714 # ffffffffc0211470 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202b2a:	e3c9                	bnez	a5,ffffffffc0202bac <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202b2c:	16060163          	beqz	a2,ffffffffc0202c8e <get_pte+0x196>
ffffffffc0202b30:	4505                	li	a0,1
ffffffffc0202b32:	eb9ff0ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0202b36:	842a                	mv	s0,a0
ffffffffc0202b38:	14050b63          	beqz	a0,ffffffffc0202c8e <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202b3c:	0000fb97          	auipc	s7,0xf
ffffffffc0202b40:	a54b8b93          	addi	s7,s7,-1452 # ffffffffc0211590 <pages>
ffffffffc0202b44:	000bb503          	ld	a0,0(s7)
ffffffffc0202b48:	00003797          	auipc	a5,0x3
ffffffffc0202b4c:	8f878793          	addi	a5,a5,-1800 # ffffffffc0205440 <commands+0x1058>
ffffffffc0202b50:	0007bb03          	ld	s6,0(a5)
ffffffffc0202b54:	40a40533          	sub	a0,s0,a0
ffffffffc0202b58:	850d                	srai	a0,a0,0x3
ffffffffc0202b5a:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202b5e:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202b60:	0000f997          	auipc	s3,0xf
ffffffffc0202b64:	91098993          	addi	s3,s3,-1776 # ffffffffc0211470 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202b68:	00080ab7          	lui	s5,0x80
ffffffffc0202b6c:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202b70:	c01c                	sw	a5,0(s0)
ffffffffc0202b72:	57fd                	li	a5,-1
ffffffffc0202b74:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202b76:	9556                	add	a0,a0,s5
ffffffffc0202b78:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b7a:	0532                	slli	a0,a0,0xc
ffffffffc0202b7c:	16e7f063          	bleu	a4,a5,ffffffffc0202cdc <get_pte+0x1e4>
ffffffffc0202b80:	0000f797          	auipc	a5,0xf
ffffffffc0202b84:	a0078793          	addi	a5,a5,-1536 # ffffffffc0211580 <va_pa_offset>
ffffffffc0202b88:	639c                	ld	a5,0(a5)
ffffffffc0202b8a:	6605                	lui	a2,0x1
ffffffffc0202b8c:	4581                	li	a1,0
ffffffffc0202b8e:	953e                	add	a0,a0,a5
ffffffffc0202b90:	22a010ef          	jal	ra,ffffffffc0203dba <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202b94:	000bb683          	ld	a3,0(s7)
ffffffffc0202b98:	40d406b3          	sub	a3,s0,a3
ffffffffc0202b9c:	868d                	srai	a3,a3,0x3
ffffffffc0202b9e:	036686b3          	mul	a3,a3,s6
ffffffffc0202ba2:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202ba4:	06aa                	slli	a3,a3,0xa
ffffffffc0202ba6:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202baa:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202bac:	77fd                	lui	a5,0xfffff
ffffffffc0202bae:	068a                	slli	a3,a3,0x2
ffffffffc0202bb0:	0009b703          	ld	a4,0(s3)
ffffffffc0202bb4:	8efd                	and	a3,a3,a5
ffffffffc0202bb6:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202bba:	0ce7fc63          	bleu	a4,a5,ffffffffc0202c92 <get_pte+0x19a>
ffffffffc0202bbe:	0000fa97          	auipc	s5,0xf
ffffffffc0202bc2:	9c2a8a93          	addi	s5,s5,-1598 # ffffffffc0211580 <va_pa_offset>
ffffffffc0202bc6:	000ab403          	ld	s0,0(s5)
ffffffffc0202bca:	01595793          	srli	a5,s2,0x15
ffffffffc0202bce:	1ff7f793          	andi	a5,a5,511
ffffffffc0202bd2:	96a2                	add	a3,a3,s0
ffffffffc0202bd4:	00379413          	slli	s0,a5,0x3
ffffffffc0202bd8:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0202bda:	6014                	ld	a3,0(s0)
ffffffffc0202bdc:	0016f793          	andi	a5,a3,1
ffffffffc0202be0:	ebbd                	bnez	a5,ffffffffc0202c56 <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202be2:	0a0a0663          	beqz	s4,ffffffffc0202c8e <get_pte+0x196>
ffffffffc0202be6:	4505                	li	a0,1
ffffffffc0202be8:	e03ff0ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0202bec:	84aa                	mv	s1,a0
ffffffffc0202bee:	c145                	beqz	a0,ffffffffc0202c8e <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202bf0:	0000fb97          	auipc	s7,0xf
ffffffffc0202bf4:	9a0b8b93          	addi	s7,s7,-1632 # ffffffffc0211590 <pages>
ffffffffc0202bf8:	000bb503          	ld	a0,0(s7)
ffffffffc0202bfc:	00003797          	auipc	a5,0x3
ffffffffc0202c00:	84478793          	addi	a5,a5,-1980 # ffffffffc0205440 <commands+0x1058>
ffffffffc0202c04:	0007bb03          	ld	s6,0(a5)
ffffffffc0202c08:	40a48533          	sub	a0,s1,a0
ffffffffc0202c0c:	850d                	srai	a0,a0,0x3
ffffffffc0202c0e:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202c12:	4785                	li	a5,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c14:	00080a37          	lui	s4,0x80
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202c18:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202c1c:	c09c                	sw	a5,0(s1)
ffffffffc0202c1e:	57fd                	li	a5,-1
ffffffffc0202c20:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c22:	9552                	add	a0,a0,s4
ffffffffc0202c24:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c26:	0532                	slli	a0,a0,0xc
ffffffffc0202c28:	08e7fd63          	bleu	a4,a5,ffffffffc0202cc2 <get_pte+0x1ca>
ffffffffc0202c2c:	000ab783          	ld	a5,0(s5)
ffffffffc0202c30:	6605                	lui	a2,0x1
ffffffffc0202c32:	4581                	li	a1,0
ffffffffc0202c34:	953e                	add	a0,a0,a5
ffffffffc0202c36:	184010ef          	jal	ra,ffffffffc0203dba <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c3a:	000bb683          	ld	a3,0(s7)
ffffffffc0202c3e:	40d486b3          	sub	a3,s1,a3
ffffffffc0202c42:	868d                	srai	a3,a3,0x3
ffffffffc0202c44:	036686b3          	mul	a3,a3,s6
ffffffffc0202c48:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202c4a:	06aa                	slli	a3,a3,0xa
ffffffffc0202c4c:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202c50:	e014                	sd	a3,0(s0)
ffffffffc0202c52:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202c56:	068a                	slli	a3,a3,0x2
ffffffffc0202c58:	757d                	lui	a0,0xfffff
ffffffffc0202c5a:	8ee9                	and	a3,a3,a0
ffffffffc0202c5c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202c60:	04e7f563          	bleu	a4,a5,ffffffffc0202caa <get_pte+0x1b2>
ffffffffc0202c64:	000ab503          	ld	a0,0(s5)
ffffffffc0202c68:	00c95793          	srli	a5,s2,0xc
ffffffffc0202c6c:	1ff7f793          	andi	a5,a5,511
ffffffffc0202c70:	96aa                	add	a3,a3,a0
ffffffffc0202c72:	00379513          	slli	a0,a5,0x3
ffffffffc0202c76:	9536                	add	a0,a0,a3
}
ffffffffc0202c78:	60a6                	ld	ra,72(sp)
ffffffffc0202c7a:	6406                	ld	s0,64(sp)
ffffffffc0202c7c:	74e2                	ld	s1,56(sp)
ffffffffc0202c7e:	7942                	ld	s2,48(sp)
ffffffffc0202c80:	79a2                	ld	s3,40(sp)
ffffffffc0202c82:	7a02                	ld	s4,32(sp)
ffffffffc0202c84:	6ae2                	ld	s5,24(sp)
ffffffffc0202c86:	6b42                	ld	s6,16(sp)
ffffffffc0202c88:	6ba2                	ld	s7,8(sp)
ffffffffc0202c8a:	6161                	addi	sp,sp,80
ffffffffc0202c8c:	8082                	ret
            return NULL;
ffffffffc0202c8e:	4501                	li	a0,0
ffffffffc0202c90:	b7e5                	j	ffffffffc0202c78 <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202c92:	00003617          	auipc	a2,0x3
ffffffffc0202c96:	b5660613          	addi	a2,a2,-1194 # ffffffffc02057e8 <default_pmm_manager+0x50>
ffffffffc0202c9a:	10200593          	li	a1,258
ffffffffc0202c9e:	00003517          	auipc	a0,0x3
ffffffffc0202ca2:	b7250513          	addi	a0,a0,-1166 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0202ca6:	c60fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202caa:	00003617          	auipc	a2,0x3
ffffffffc0202cae:	b3e60613          	addi	a2,a2,-1218 # ffffffffc02057e8 <default_pmm_manager+0x50>
ffffffffc0202cb2:	10f00593          	li	a1,271
ffffffffc0202cb6:	00003517          	auipc	a0,0x3
ffffffffc0202cba:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0202cbe:	c48fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202cc2:	86aa                	mv	a3,a0
ffffffffc0202cc4:	00003617          	auipc	a2,0x3
ffffffffc0202cc8:	b2460613          	addi	a2,a2,-1244 # ffffffffc02057e8 <default_pmm_manager+0x50>
ffffffffc0202ccc:	10b00593          	li	a1,267
ffffffffc0202cd0:	00003517          	auipc	a0,0x3
ffffffffc0202cd4:	b4050513          	addi	a0,a0,-1216 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0202cd8:	c2efd0ef          	jal	ra,ffffffffc0200106 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202cdc:	86aa                	mv	a3,a0
ffffffffc0202cde:	00003617          	auipc	a2,0x3
ffffffffc0202ce2:	b0a60613          	addi	a2,a2,-1270 # ffffffffc02057e8 <default_pmm_manager+0x50>
ffffffffc0202ce6:	0ff00593          	li	a1,255
ffffffffc0202cea:	00003517          	auipc	a0,0x3
ffffffffc0202cee:	b2650513          	addi	a0,a0,-1242 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0202cf2:	c14fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202cf6 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202cf6:	1141                	addi	sp,sp,-16
ffffffffc0202cf8:	e022                	sd	s0,0(sp)
ffffffffc0202cfa:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202cfc:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202cfe:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d00:	df9ff0ef          	jal	ra,ffffffffc0202af8 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202d04:	c011                	beqz	s0,ffffffffc0202d08 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202d06:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202d08:	c521                	beqz	a0,ffffffffc0202d50 <get_page+0x5a>
ffffffffc0202d0a:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202d0c:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202d0e:	0017f713          	andi	a4,a5,1
ffffffffc0202d12:	e709                	bnez	a4,ffffffffc0202d1c <get_page+0x26>
}
ffffffffc0202d14:	60a2                	ld	ra,8(sp)
ffffffffc0202d16:	6402                	ld	s0,0(sp)
ffffffffc0202d18:	0141                	addi	sp,sp,16
ffffffffc0202d1a:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202d1c:	0000e717          	auipc	a4,0xe
ffffffffc0202d20:	75470713          	addi	a4,a4,1876 # ffffffffc0211470 <npage>
ffffffffc0202d24:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202d26:	078a                	slli	a5,a5,0x2
ffffffffc0202d28:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d2a:	02e7f863          	bleu	a4,a5,ffffffffc0202d5a <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d2e:	fff80537          	lui	a0,0xfff80
ffffffffc0202d32:	97aa                	add	a5,a5,a0
ffffffffc0202d34:	0000f697          	auipc	a3,0xf
ffffffffc0202d38:	85c68693          	addi	a3,a3,-1956 # ffffffffc0211590 <pages>
ffffffffc0202d3c:	6288                	ld	a0,0(a3)
ffffffffc0202d3e:	60a2                	ld	ra,8(sp)
ffffffffc0202d40:	6402                	ld	s0,0(sp)
ffffffffc0202d42:	00379713          	slli	a4,a5,0x3
ffffffffc0202d46:	97ba                	add	a5,a5,a4
ffffffffc0202d48:	078e                	slli	a5,a5,0x3
ffffffffc0202d4a:	953e                	add	a0,a0,a5
ffffffffc0202d4c:	0141                	addi	sp,sp,16
ffffffffc0202d4e:	8082                	ret
ffffffffc0202d50:	60a2                	ld	ra,8(sp)
ffffffffc0202d52:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0202d54:	4501                	li	a0,0
}
ffffffffc0202d56:	0141                	addi	sp,sp,16
ffffffffc0202d58:	8082                	ret
ffffffffc0202d5a:	c75ff0ef          	jal	ra,ffffffffc02029ce <pa2page.part.4>

ffffffffc0202d5e <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202d5e:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d60:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202d62:	e406                	sd	ra,8(sp)
ffffffffc0202d64:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d66:	d93ff0ef          	jal	ra,ffffffffc0202af8 <get_pte>
    if (ptep != NULL) {
ffffffffc0202d6a:	c511                	beqz	a0,ffffffffc0202d76 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202d6c:	611c                	ld	a5,0(a0)
ffffffffc0202d6e:	842a                	mv	s0,a0
ffffffffc0202d70:	0017f713          	andi	a4,a5,1
ffffffffc0202d74:	e709                	bnez	a4,ffffffffc0202d7e <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0202d76:	60a2                	ld	ra,8(sp)
ffffffffc0202d78:	6402                	ld	s0,0(sp)
ffffffffc0202d7a:	0141                	addi	sp,sp,16
ffffffffc0202d7c:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202d7e:	0000e717          	auipc	a4,0xe
ffffffffc0202d82:	6f270713          	addi	a4,a4,1778 # ffffffffc0211470 <npage>
ffffffffc0202d86:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202d88:	078a                	slli	a5,a5,0x2
ffffffffc0202d8a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d8c:	04e7f063          	bleu	a4,a5,ffffffffc0202dcc <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d90:	fff80737          	lui	a4,0xfff80
ffffffffc0202d94:	97ba                	add	a5,a5,a4
ffffffffc0202d96:	0000e717          	auipc	a4,0xe
ffffffffc0202d9a:	7fa70713          	addi	a4,a4,2042 # ffffffffc0211590 <pages>
ffffffffc0202d9e:	6308                	ld	a0,0(a4)
ffffffffc0202da0:	00379713          	slli	a4,a5,0x3
ffffffffc0202da4:	97ba                	add	a5,a5,a4
ffffffffc0202da6:	078e                	slli	a5,a5,0x3
ffffffffc0202da8:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202daa:	411c                	lw	a5,0(a0)
ffffffffc0202dac:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202db0:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202db2:	cb09                	beqz	a4,ffffffffc0202dc4 <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202db4:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202db8:	12000073          	sfence.vma
}
ffffffffc0202dbc:	60a2                	ld	ra,8(sp)
ffffffffc0202dbe:	6402                	ld	s0,0(sp)
ffffffffc0202dc0:	0141                	addi	sp,sp,16
ffffffffc0202dc2:	8082                	ret
            free_page(page);
ffffffffc0202dc4:	4585                	li	a1,1
ffffffffc0202dc6:	cadff0ef          	jal	ra,ffffffffc0202a72 <free_pages>
ffffffffc0202dca:	b7ed                	j	ffffffffc0202db4 <page_remove+0x56>
ffffffffc0202dcc:	c03ff0ef          	jal	ra,ffffffffc02029ce <pa2page.part.4>

ffffffffc0202dd0 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202dd0:	7179                	addi	sp,sp,-48
ffffffffc0202dd2:	87b2                	mv	a5,a2
ffffffffc0202dd4:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202dd6:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202dd8:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202dda:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202ddc:	ec26                	sd	s1,24(sp)
ffffffffc0202dde:	f406                	sd	ra,40(sp)
ffffffffc0202de0:	e84a                	sd	s2,16(sp)
ffffffffc0202de2:	e44e                	sd	s3,8(sp)
ffffffffc0202de4:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202de6:	d13ff0ef          	jal	ra,ffffffffc0202af8 <get_pte>
    if (ptep == NULL) {
ffffffffc0202dea:	c945                	beqz	a0,ffffffffc0202e9a <page_insert+0xca>
    page->ref += 1;
ffffffffc0202dec:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0202dee:	611c                	ld	a5,0(a0)
ffffffffc0202df0:	892a                	mv	s2,a0
ffffffffc0202df2:	0016871b          	addiw	a4,a3,1
ffffffffc0202df6:	c018                	sw	a4,0(s0)
ffffffffc0202df8:	0017f713          	andi	a4,a5,1
ffffffffc0202dfc:	e339                	bnez	a4,ffffffffc0202e42 <page_insert+0x72>
ffffffffc0202dfe:	0000e797          	auipc	a5,0xe
ffffffffc0202e02:	79278793          	addi	a5,a5,1938 # ffffffffc0211590 <pages>
ffffffffc0202e06:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202e08:	00002717          	auipc	a4,0x2
ffffffffc0202e0c:	63870713          	addi	a4,a4,1592 # ffffffffc0205440 <commands+0x1058>
ffffffffc0202e10:	40f407b3          	sub	a5,s0,a5
ffffffffc0202e14:	6300                	ld	s0,0(a4)
ffffffffc0202e16:	878d                	srai	a5,a5,0x3
ffffffffc0202e18:	000806b7          	lui	a3,0x80
ffffffffc0202e1c:	028787b3          	mul	a5,a5,s0
ffffffffc0202e20:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202e22:	07aa                	slli	a5,a5,0xa
ffffffffc0202e24:	8fc5                	or	a5,a5,s1
ffffffffc0202e26:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202e2a:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202e2e:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0202e32:	4501                	li	a0,0
}
ffffffffc0202e34:	70a2                	ld	ra,40(sp)
ffffffffc0202e36:	7402                	ld	s0,32(sp)
ffffffffc0202e38:	64e2                	ld	s1,24(sp)
ffffffffc0202e3a:	6942                	ld	s2,16(sp)
ffffffffc0202e3c:	69a2                	ld	s3,8(sp)
ffffffffc0202e3e:	6145                	addi	sp,sp,48
ffffffffc0202e40:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202e42:	0000e717          	auipc	a4,0xe
ffffffffc0202e46:	62e70713          	addi	a4,a4,1582 # ffffffffc0211470 <npage>
ffffffffc0202e4a:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e4c:	00279513          	slli	a0,a5,0x2
ffffffffc0202e50:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e52:	04e57663          	bleu	a4,a0,ffffffffc0202e9e <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e56:	fff807b7          	lui	a5,0xfff80
ffffffffc0202e5a:	953e                	add	a0,a0,a5
ffffffffc0202e5c:	0000e997          	auipc	s3,0xe
ffffffffc0202e60:	73498993          	addi	s3,s3,1844 # ffffffffc0211590 <pages>
ffffffffc0202e64:	0009b783          	ld	a5,0(s3)
ffffffffc0202e68:	00351713          	slli	a4,a0,0x3
ffffffffc0202e6c:	953a                	add	a0,a0,a4
ffffffffc0202e6e:	050e                	slli	a0,a0,0x3
ffffffffc0202e70:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0202e72:	00a40e63          	beq	s0,a0,ffffffffc0202e8e <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0202e76:	411c                	lw	a5,0(a0)
ffffffffc0202e78:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202e7c:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202e7e:	cb11                	beqz	a4,ffffffffc0202e92 <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202e80:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202e84:	12000073          	sfence.vma
ffffffffc0202e88:	0009b783          	ld	a5,0(s3)
ffffffffc0202e8c:	bfb5                	j	ffffffffc0202e08 <page_insert+0x38>
    page->ref -= 1;
ffffffffc0202e8e:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202e90:	bfa5                	j	ffffffffc0202e08 <page_insert+0x38>
            free_page(page);
ffffffffc0202e92:	4585                	li	a1,1
ffffffffc0202e94:	bdfff0ef          	jal	ra,ffffffffc0202a72 <free_pages>
ffffffffc0202e98:	b7e5                	j	ffffffffc0202e80 <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0202e9a:	5571                	li	a0,-4
ffffffffc0202e9c:	bf61                	j	ffffffffc0202e34 <page_insert+0x64>
ffffffffc0202e9e:	b31ff0ef          	jal	ra,ffffffffc02029ce <pa2page.part.4>

ffffffffc0202ea2 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202ea2:	00003797          	auipc	a5,0x3
ffffffffc0202ea6:	8f678793          	addi	a5,a5,-1802 # ffffffffc0205798 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202eaa:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202eac:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202eae:	00003517          	auipc	a0,0x3
ffffffffc0202eb2:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0205878 <default_pmm_manager+0xe0>
void pmm_init(void) {
ffffffffc0202eb6:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202eb8:	0000e717          	auipc	a4,0xe
ffffffffc0202ebc:	6cf73023          	sd	a5,1728(a4) # ffffffffc0211578 <pmm_manager>
void pmm_init(void) {
ffffffffc0202ec0:	e8a2                	sd	s0,80(sp)
ffffffffc0202ec2:	e4a6                	sd	s1,72(sp)
ffffffffc0202ec4:	e0ca                	sd	s2,64(sp)
ffffffffc0202ec6:	fc4e                	sd	s3,56(sp)
ffffffffc0202ec8:	f852                	sd	s4,48(sp)
ffffffffc0202eca:	f456                	sd	s5,40(sp)
ffffffffc0202ecc:	f05a                	sd	s6,32(sp)
ffffffffc0202ece:	ec5e                	sd	s7,24(sp)
ffffffffc0202ed0:	e862                	sd	s8,16(sp)
ffffffffc0202ed2:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202ed4:	0000e417          	auipc	s0,0xe
ffffffffc0202ed8:	6a440413          	addi	s0,s0,1700 # ffffffffc0211578 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202edc:	9e2fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0202ee0:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202ee2:	49c5                	li	s3,17
ffffffffc0202ee4:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0202ee8:	679c                	ld	a5,8(a5)
ffffffffc0202eea:	0000e497          	auipc	s1,0xe
ffffffffc0202eee:	58648493          	addi	s1,s1,1414 # ffffffffc0211470 <npage>
ffffffffc0202ef2:	0000e917          	auipc	s2,0xe
ffffffffc0202ef6:	69e90913          	addi	s2,s2,1694 # ffffffffc0211590 <pages>
ffffffffc0202efa:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202efc:	57f5                	li	a5,-3
ffffffffc0202efe:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202f00:	07e006b7          	lui	a3,0x7e00
ffffffffc0202f04:	01b99613          	slli	a2,s3,0x1b
ffffffffc0202f08:	015a1593          	slli	a1,s4,0x15
ffffffffc0202f0c:	00003517          	auipc	a0,0x3
ffffffffc0202f10:	98450513          	addi	a0,a0,-1660 # ffffffffc0205890 <default_pmm_manager+0xf8>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202f14:	0000e717          	auipc	a4,0xe
ffffffffc0202f18:	66f73623          	sd	a5,1644(a4) # ffffffffc0211580 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202f1c:	9a2fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0202f20:	00003517          	auipc	a0,0x3
ffffffffc0202f24:	9a050513          	addi	a0,a0,-1632 # ffffffffc02058c0 <default_pmm_manager+0x128>
ffffffffc0202f28:	996fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202f2c:	01b99693          	slli	a3,s3,0x1b
ffffffffc0202f30:	16fd                	addi	a3,a3,-1
ffffffffc0202f32:	015a1613          	slli	a2,s4,0x15
ffffffffc0202f36:	07e005b7          	lui	a1,0x7e00
ffffffffc0202f3a:	00003517          	auipc	a0,0x3
ffffffffc0202f3e:	99e50513          	addi	a0,a0,-1634 # ffffffffc02058d8 <default_pmm_manager+0x140>
ffffffffc0202f42:	97cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202f46:	777d                	lui	a4,0xfffff
ffffffffc0202f48:	0000f797          	auipc	a5,0xf
ffffffffc0202f4c:	64f78793          	addi	a5,a5,1615 # ffffffffc0212597 <end+0xfff>
ffffffffc0202f50:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0202f52:	00088737          	lui	a4,0x88
ffffffffc0202f56:	0000e697          	auipc	a3,0xe
ffffffffc0202f5a:	50e6bd23          	sd	a4,1306(a3) # ffffffffc0211470 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202f5e:	0000e717          	auipc	a4,0xe
ffffffffc0202f62:	62f73923          	sd	a5,1586(a4) # ffffffffc0211590 <pages>
ffffffffc0202f66:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202f68:	4701                	li	a4,0
ffffffffc0202f6a:	4585                	li	a1,1
ffffffffc0202f6c:	fff80637          	lui	a2,0xfff80
ffffffffc0202f70:	a019                	j	ffffffffc0202f76 <pmm_init+0xd4>
ffffffffc0202f72:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0202f76:	97b6                	add	a5,a5,a3
ffffffffc0202f78:	07a1                	addi	a5,a5,8
ffffffffc0202f7a:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202f7e:	609c                	ld	a5,0(s1)
ffffffffc0202f80:	0705                	addi	a4,a4,1
ffffffffc0202f82:	04868693          	addi	a3,a3,72
ffffffffc0202f86:	00c78533          	add	a0,a5,a2
ffffffffc0202f8a:	fea764e3          	bltu	a4,a0,ffffffffc0202f72 <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202f8e:	00093503          	ld	a0,0(s2)
ffffffffc0202f92:	00379693          	slli	a3,a5,0x3
ffffffffc0202f96:	96be                	add	a3,a3,a5
ffffffffc0202f98:	fdc00737          	lui	a4,0xfdc00
ffffffffc0202f9c:	972a                	add	a4,a4,a0
ffffffffc0202f9e:	068e                	slli	a3,a3,0x3
ffffffffc0202fa0:	96ba                	add	a3,a3,a4
ffffffffc0202fa2:	c0200737          	lui	a4,0xc0200
ffffffffc0202fa6:	58e6ea63          	bltu	a3,a4,ffffffffc020353a <pmm_init+0x698>
ffffffffc0202faa:	0000e997          	auipc	s3,0xe
ffffffffc0202fae:	5d698993          	addi	s3,s3,1494 # ffffffffc0211580 <va_pa_offset>
ffffffffc0202fb2:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0202fb6:	45c5                	li	a1,17
ffffffffc0202fb8:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202fba:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0202fbc:	44b6ef63          	bltu	a3,a1,ffffffffc020341a <pmm_init+0x578>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202fc0:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202fc2:	0000e417          	auipc	s0,0xe
ffffffffc0202fc6:	4a640413          	addi	s0,s0,1190 # ffffffffc0211468 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202fca:	7b9c                	ld	a5,48(a5)
ffffffffc0202fcc:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202fce:	00003517          	auipc	a0,0x3
ffffffffc0202fd2:	95a50513          	addi	a0,a0,-1702 # ffffffffc0205928 <default_pmm_manager+0x190>
ffffffffc0202fd6:	8e8fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202fda:	00006697          	auipc	a3,0x6
ffffffffc0202fde:	02668693          	addi	a3,a3,38 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0202fe2:	0000e797          	auipc	a5,0xe
ffffffffc0202fe6:	48d7b323          	sd	a3,1158(a5) # ffffffffc0211468 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202fea:	c02007b7          	lui	a5,0xc0200
ffffffffc0202fee:	0ef6ece3          	bltu	a3,a5,ffffffffc02038e6 <pmm_init+0xa44>
ffffffffc0202ff2:	0009b783          	ld	a5,0(s3)
ffffffffc0202ff6:	8e9d                	sub	a3,a3,a5
ffffffffc0202ff8:	0000e797          	auipc	a5,0xe
ffffffffc0202ffc:	58d7b823          	sd	a3,1424(a5) # ffffffffc0211588 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0203000:	ab9ff0ef          	jal	ra,ffffffffc0202ab8 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203004:	6098                	ld	a4,0(s1)
ffffffffc0203006:	c80007b7          	lui	a5,0xc8000
ffffffffc020300a:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc020300c:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020300e:	0ae7ece3          	bltu	a5,a4,ffffffffc02038c6 <pmm_init+0xa24>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203012:	6008                	ld	a0,0(s0)
ffffffffc0203014:	4c050363          	beqz	a0,ffffffffc02034da <pmm_init+0x638>
ffffffffc0203018:	6785                	lui	a5,0x1
ffffffffc020301a:	17fd                	addi	a5,a5,-1
ffffffffc020301c:	8fe9                	and	a5,a5,a0
ffffffffc020301e:	2781                	sext.w	a5,a5
ffffffffc0203020:	4a079d63          	bnez	a5,ffffffffc02034da <pmm_init+0x638>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203024:	4601                	li	a2,0
ffffffffc0203026:	4581                	li	a1,0
ffffffffc0203028:	ccfff0ef          	jal	ra,ffffffffc0202cf6 <get_page>
ffffffffc020302c:	4c051763          	bnez	a0,ffffffffc02034fa <pmm_init+0x658>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0203030:	4505                	li	a0,1
ffffffffc0203032:	9b9ff0ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0203036:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203038:	6008                	ld	a0,0(s0)
ffffffffc020303a:	4681                	li	a3,0
ffffffffc020303c:	4601                	li	a2,0
ffffffffc020303e:	85d6                	mv	a1,s5
ffffffffc0203040:	d91ff0ef          	jal	ra,ffffffffc0202dd0 <page_insert>
ffffffffc0203044:	52051763          	bnez	a0,ffffffffc0203572 <pmm_init+0x6d0>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203048:	6008                	ld	a0,0(s0)
ffffffffc020304a:	4601                	li	a2,0
ffffffffc020304c:	4581                	li	a1,0
ffffffffc020304e:	aabff0ef          	jal	ra,ffffffffc0202af8 <get_pte>
ffffffffc0203052:	50050063          	beqz	a0,ffffffffc0203552 <pmm_init+0x6b0>
    assert(pte2page(*ptep) == p1);
ffffffffc0203056:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203058:	0017f713          	andi	a4,a5,1
ffffffffc020305c:	46070363          	beqz	a4,ffffffffc02034c2 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0203060:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203062:	078a                	slli	a5,a5,0x2
ffffffffc0203064:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203066:	44c7f063          	bleu	a2,a5,ffffffffc02034a6 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020306a:	fff80737          	lui	a4,0xfff80
ffffffffc020306e:	97ba                	add	a5,a5,a4
ffffffffc0203070:	00379713          	slli	a4,a5,0x3
ffffffffc0203074:	00093683          	ld	a3,0(s2)
ffffffffc0203078:	97ba                	add	a5,a5,a4
ffffffffc020307a:	078e                	slli	a5,a5,0x3
ffffffffc020307c:	97b6                	add	a5,a5,a3
ffffffffc020307e:	5efa9463          	bne	s5,a5,ffffffffc0203666 <pmm_init+0x7c4>
    assert(page_ref(p1) == 1);
ffffffffc0203082:	000aab83          	lw	s7,0(s5)
ffffffffc0203086:	4785                	li	a5,1
ffffffffc0203088:	5afb9f63          	bne	s7,a5,ffffffffc0203646 <pmm_init+0x7a4>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020308c:	6008                	ld	a0,0(s0)
ffffffffc020308e:	76fd                	lui	a3,0xfffff
ffffffffc0203090:	611c                	ld	a5,0(a0)
ffffffffc0203092:	078a                	slli	a5,a5,0x2
ffffffffc0203094:	8ff5                	and	a5,a5,a3
ffffffffc0203096:	00c7d713          	srli	a4,a5,0xc
ffffffffc020309a:	58c77963          	bleu	a2,a4,ffffffffc020362c <pmm_init+0x78a>
ffffffffc020309e:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02030a2:	97e2                	add	a5,a5,s8
ffffffffc02030a4:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc02030a8:	0b0a                	slli	s6,s6,0x2
ffffffffc02030aa:	00db7b33          	and	s6,s6,a3
ffffffffc02030ae:	00cb5793          	srli	a5,s6,0xc
ffffffffc02030b2:	56c7f063          	bleu	a2,a5,ffffffffc0203612 <pmm_init+0x770>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02030b6:	4601                	li	a2,0
ffffffffc02030b8:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02030ba:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02030bc:	a3dff0ef          	jal	ra,ffffffffc0202af8 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02030c0:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02030c2:	53651863          	bne	a0,s6,ffffffffc02035f2 <pmm_init+0x750>

    p2 = alloc_page();
ffffffffc02030c6:	4505                	li	a0,1
ffffffffc02030c8:	923ff0ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc02030cc:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02030ce:	6008                	ld	a0,0(s0)
ffffffffc02030d0:	46d1                	li	a3,20
ffffffffc02030d2:	6605                	lui	a2,0x1
ffffffffc02030d4:	85da                	mv	a1,s6
ffffffffc02030d6:	cfbff0ef          	jal	ra,ffffffffc0202dd0 <page_insert>
ffffffffc02030da:	4e051c63          	bnez	a0,ffffffffc02035d2 <pmm_init+0x730>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02030de:	6008                	ld	a0,0(s0)
ffffffffc02030e0:	4601                	li	a2,0
ffffffffc02030e2:	6585                	lui	a1,0x1
ffffffffc02030e4:	a15ff0ef          	jal	ra,ffffffffc0202af8 <get_pte>
ffffffffc02030e8:	4c050563          	beqz	a0,ffffffffc02035b2 <pmm_init+0x710>
    assert(*ptep & PTE_U);
ffffffffc02030ec:	611c                	ld	a5,0(a0)
ffffffffc02030ee:	0107f713          	andi	a4,a5,16
ffffffffc02030f2:	4a070063          	beqz	a4,ffffffffc0203592 <pmm_init+0x6f0>
    assert(*ptep & PTE_W);
ffffffffc02030f6:	8b91                	andi	a5,a5,4
ffffffffc02030f8:	66078763          	beqz	a5,ffffffffc0203766 <pmm_init+0x8c4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02030fc:	6008                	ld	a0,0(s0)
ffffffffc02030fe:	611c                	ld	a5,0(a0)
ffffffffc0203100:	8bc1                	andi	a5,a5,16
ffffffffc0203102:	64078263          	beqz	a5,ffffffffc0203746 <pmm_init+0x8a4>
    assert(page_ref(p2) == 1);
ffffffffc0203106:	000b2783          	lw	a5,0(s6)
ffffffffc020310a:	61779e63          	bne	a5,s7,ffffffffc0203726 <pmm_init+0x884>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020310e:	4681                	li	a3,0
ffffffffc0203110:	6605                	lui	a2,0x1
ffffffffc0203112:	85d6                	mv	a1,s5
ffffffffc0203114:	cbdff0ef          	jal	ra,ffffffffc0202dd0 <page_insert>
ffffffffc0203118:	5e051763          	bnez	a0,ffffffffc0203706 <pmm_init+0x864>
    assert(page_ref(p1) == 2);
ffffffffc020311c:	000aa703          	lw	a4,0(s5)
ffffffffc0203120:	4789                	li	a5,2
ffffffffc0203122:	5cf71263          	bne	a4,a5,ffffffffc02036e6 <pmm_init+0x844>
    assert(page_ref(p2) == 0);
ffffffffc0203126:	000b2783          	lw	a5,0(s6)
ffffffffc020312a:	58079e63          	bnez	a5,ffffffffc02036c6 <pmm_init+0x824>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020312e:	6008                	ld	a0,0(s0)
ffffffffc0203130:	4601                	li	a2,0
ffffffffc0203132:	6585                	lui	a1,0x1
ffffffffc0203134:	9c5ff0ef          	jal	ra,ffffffffc0202af8 <get_pte>
ffffffffc0203138:	56050763          	beqz	a0,ffffffffc02036a6 <pmm_init+0x804>
    assert(pte2page(*ptep) == p1);
ffffffffc020313c:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020313e:	0016f793          	andi	a5,a3,1
ffffffffc0203142:	38078063          	beqz	a5,ffffffffc02034c2 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0203146:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203148:	00269793          	slli	a5,a3,0x2
ffffffffc020314c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020314e:	34e7fc63          	bleu	a4,a5,ffffffffc02034a6 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0203152:	fff80737          	lui	a4,0xfff80
ffffffffc0203156:	97ba                	add	a5,a5,a4
ffffffffc0203158:	00379713          	slli	a4,a5,0x3
ffffffffc020315c:	00093603          	ld	a2,0(s2)
ffffffffc0203160:	97ba                	add	a5,a5,a4
ffffffffc0203162:	078e                	slli	a5,a5,0x3
ffffffffc0203164:	97b2                	add	a5,a5,a2
ffffffffc0203166:	52fa9063          	bne	s5,a5,ffffffffc0203686 <pmm_init+0x7e4>
    assert((*ptep & PTE_U) == 0);
ffffffffc020316a:	8ac1                	andi	a3,a3,16
ffffffffc020316c:	6e069d63          	bnez	a3,ffffffffc0203866 <pmm_init+0x9c4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0203170:	6008                	ld	a0,0(s0)
ffffffffc0203172:	4581                	li	a1,0
ffffffffc0203174:	bebff0ef          	jal	ra,ffffffffc0202d5e <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0203178:	000aa703          	lw	a4,0(s5)
ffffffffc020317c:	4785                	li	a5,1
ffffffffc020317e:	6cf71463          	bne	a4,a5,ffffffffc0203846 <pmm_init+0x9a4>
    assert(page_ref(p2) == 0);
ffffffffc0203182:	000b2783          	lw	a5,0(s6)
ffffffffc0203186:	6a079063          	bnez	a5,ffffffffc0203826 <pmm_init+0x984>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020318a:	6008                	ld	a0,0(s0)
ffffffffc020318c:	6585                	lui	a1,0x1
ffffffffc020318e:	bd1ff0ef          	jal	ra,ffffffffc0202d5e <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0203192:	000aa783          	lw	a5,0(s5)
ffffffffc0203196:	66079863          	bnez	a5,ffffffffc0203806 <pmm_init+0x964>
    assert(page_ref(p2) == 0);
ffffffffc020319a:	000b2783          	lw	a5,0(s6)
ffffffffc020319e:	70079463          	bnez	a5,ffffffffc02038a6 <pmm_init+0xa04>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02031a2:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02031a6:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02031a8:	000b3783          	ld	a5,0(s6)
ffffffffc02031ac:	078a                	slli	a5,a5,0x2
ffffffffc02031ae:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031b0:	2eb7fb63          	bleu	a1,a5,ffffffffc02034a6 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02031b4:	fff80737          	lui	a4,0xfff80
ffffffffc02031b8:	973e                	add	a4,a4,a5
ffffffffc02031ba:	00371793          	slli	a5,a4,0x3
ffffffffc02031be:	00093603          	ld	a2,0(s2)
ffffffffc02031c2:	97ba                	add	a5,a5,a4
ffffffffc02031c4:	078e                	slli	a5,a5,0x3
ffffffffc02031c6:	00f60733          	add	a4,a2,a5
ffffffffc02031ca:	4314                	lw	a3,0(a4)
ffffffffc02031cc:	4705                	li	a4,1
ffffffffc02031ce:	6ae69c63          	bne	a3,a4,ffffffffc0203886 <pmm_init+0x9e4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02031d2:	00002a97          	auipc	s5,0x2
ffffffffc02031d6:	26ea8a93          	addi	s5,s5,622 # ffffffffc0205440 <commands+0x1058>
ffffffffc02031da:	000ab703          	ld	a4,0(s5)
ffffffffc02031de:	4037d693          	srai	a3,a5,0x3
ffffffffc02031e2:	00080bb7          	lui	s7,0x80
ffffffffc02031e6:	02e686b3          	mul	a3,a3,a4
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02031ea:	577d                	li	a4,-1
ffffffffc02031ec:	8331                	srli	a4,a4,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02031ee:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02031f0:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02031f2:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02031f4:	2ab77b63          	bleu	a1,a4,ffffffffc02034aa <pmm_init+0x608>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02031f8:	0009b783          	ld	a5,0(s3)
ffffffffc02031fc:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02031fe:	629c                	ld	a5,0(a3)
ffffffffc0203200:	078a                	slli	a5,a5,0x2
ffffffffc0203202:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203204:	2ab7f163          	bleu	a1,a5,ffffffffc02034a6 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0203208:	417787b3          	sub	a5,a5,s7
ffffffffc020320c:	00379513          	slli	a0,a5,0x3
ffffffffc0203210:	97aa                	add	a5,a5,a0
ffffffffc0203212:	00379513          	slli	a0,a5,0x3
ffffffffc0203216:	9532                	add	a0,a0,a2
ffffffffc0203218:	4585                	li	a1,1
ffffffffc020321a:	859ff0ef          	jal	ra,ffffffffc0202a72 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020321e:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203222:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203224:	050a                	slli	a0,a0,0x2
ffffffffc0203226:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203228:	26f57f63          	bleu	a5,a0,ffffffffc02034a6 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020322c:	417507b3          	sub	a5,a0,s7
ffffffffc0203230:	00379513          	slli	a0,a5,0x3
ffffffffc0203234:	00093703          	ld	a4,0(s2)
ffffffffc0203238:	953e                	add	a0,a0,a5
ffffffffc020323a:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc020323c:	4585                	li	a1,1
ffffffffc020323e:	953a                	add	a0,a0,a4
ffffffffc0203240:	833ff0ef          	jal	ra,ffffffffc0202a72 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0203244:	601c                	ld	a5,0(s0)
ffffffffc0203246:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc020324a:	86fff0ef          	jal	ra,ffffffffc0202ab8 <nr_free_pages>
ffffffffc020324e:	2caa1663          	bne	s4,a0,ffffffffc020351a <pmm_init+0x678>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0203252:	00003517          	auipc	a0,0x3
ffffffffc0203256:	9be50513          	addi	a0,a0,-1602 # ffffffffc0205c10 <default_pmm_manager+0x478>
ffffffffc020325a:	e65fc0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc020325e:	85bff0ef          	jal	ra,ffffffffc0202ab8 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203262:	6098                	ld	a4,0(s1)
ffffffffc0203264:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0203268:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020326a:	00c71693          	slli	a3,a4,0xc
ffffffffc020326e:	1cd7fd63          	bleu	a3,a5,ffffffffc0203448 <pmm_init+0x5a6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203272:	83b1                	srli	a5,a5,0xc
ffffffffc0203274:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203276:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020327a:	1ce7f963          	bleu	a4,a5,ffffffffc020344c <pmm_init+0x5aa>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020327e:	7c7d                	lui	s8,0xfffff
ffffffffc0203280:	6b85                	lui	s7,0x1
ffffffffc0203282:	a029                	j	ffffffffc020328c <pmm_init+0x3ea>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203284:	00ca5713          	srli	a4,s4,0xc
ffffffffc0203288:	1cf77263          	bleu	a5,a4,ffffffffc020344c <pmm_init+0x5aa>
ffffffffc020328c:	0009b583          	ld	a1,0(s3)
ffffffffc0203290:	4601                	li	a2,0
ffffffffc0203292:	95d2                	add	a1,a1,s4
ffffffffc0203294:	865ff0ef          	jal	ra,ffffffffc0202af8 <get_pte>
ffffffffc0203298:	1c050763          	beqz	a0,ffffffffc0203466 <pmm_init+0x5c4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020329c:	611c                	ld	a5,0(a0)
ffffffffc020329e:	078a                	slli	a5,a5,0x2
ffffffffc02032a0:	0187f7b3          	and	a5,a5,s8
ffffffffc02032a4:	1f479163          	bne	a5,s4,ffffffffc0203486 <pmm_init+0x5e4>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02032a8:	609c                	ld	a5,0(s1)
ffffffffc02032aa:	9a5e                	add	s4,s4,s7
ffffffffc02032ac:	6008                	ld	a0,0(s0)
ffffffffc02032ae:	00c79713          	slli	a4,a5,0xc
ffffffffc02032b2:	fcea69e3          	bltu	s4,a4,ffffffffc0203284 <pmm_init+0x3e2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02032b6:	611c                	ld	a5,0(a0)
ffffffffc02032b8:	6a079363          	bnez	a5,ffffffffc020395e <pmm_init+0xabc>

    struct Page *p;
    p = alloc_page();
ffffffffc02032bc:	4505                	li	a0,1
ffffffffc02032be:	f2cff0ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc02032c2:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02032c4:	6008                	ld	a0,0(s0)
ffffffffc02032c6:	4699                	li	a3,6
ffffffffc02032c8:	10000613          	li	a2,256
ffffffffc02032cc:	85d2                	mv	a1,s4
ffffffffc02032ce:	b03ff0ef          	jal	ra,ffffffffc0202dd0 <page_insert>
ffffffffc02032d2:	66051663          	bnez	a0,ffffffffc020393e <pmm_init+0xa9c>
    assert(page_ref(p) == 1);
ffffffffc02032d6:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc02032da:	4785                	li	a5,1
ffffffffc02032dc:	64f71163          	bne	a4,a5,ffffffffc020391e <pmm_init+0xa7c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02032e0:	6008                	ld	a0,0(s0)
ffffffffc02032e2:	6b85                	lui	s7,0x1
ffffffffc02032e4:	4699                	li	a3,6
ffffffffc02032e6:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc02032ea:	85d2                	mv	a1,s4
ffffffffc02032ec:	ae5ff0ef          	jal	ra,ffffffffc0202dd0 <page_insert>
ffffffffc02032f0:	60051763          	bnez	a0,ffffffffc02038fe <pmm_init+0xa5c>
    assert(page_ref(p) == 2);
ffffffffc02032f4:	000a2703          	lw	a4,0(s4)
ffffffffc02032f8:	4789                	li	a5,2
ffffffffc02032fa:	4ef71663          	bne	a4,a5,ffffffffc02037e6 <pmm_init+0x944>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02032fe:	00003597          	auipc	a1,0x3
ffffffffc0203302:	a4a58593          	addi	a1,a1,-1462 # ffffffffc0205d48 <default_pmm_manager+0x5b0>
ffffffffc0203306:	10000513          	li	a0,256
ffffffffc020330a:	257000ef          	jal	ra,ffffffffc0203d60 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020330e:	100b8593          	addi	a1,s7,256
ffffffffc0203312:	10000513          	li	a0,256
ffffffffc0203316:	25d000ef          	jal	ra,ffffffffc0203d72 <strcmp>
ffffffffc020331a:	4a051663          	bnez	a0,ffffffffc02037c6 <pmm_init+0x924>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020331e:	00093683          	ld	a3,0(s2)
ffffffffc0203322:	000abc83          	ld	s9,0(s5)
ffffffffc0203326:	00080c37          	lui	s8,0x80
ffffffffc020332a:	40da06b3          	sub	a3,s4,a3
ffffffffc020332e:	868d                	srai	a3,a3,0x3
ffffffffc0203330:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203334:	5afd                	li	s5,-1
ffffffffc0203336:	609c                	ld	a5,0(s1)
ffffffffc0203338:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020333c:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020333e:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0203342:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203344:	16f77363          	bleu	a5,a4,ffffffffc02034aa <pmm_init+0x608>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203348:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020334c:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203350:	96be                	add	a3,a3,a5
ffffffffc0203352:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdedb68>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203356:	1c7000ef          	jal	ra,ffffffffc0203d1c <strlen>
ffffffffc020335a:	44051663          	bnez	a0,ffffffffc02037a6 <pmm_init+0x904>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020335e:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203362:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203364:	000bb783          	ld	a5,0(s7)
ffffffffc0203368:	078a                	slli	a5,a5,0x2
ffffffffc020336a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020336c:	12e7fd63          	bleu	a4,a5,ffffffffc02034a6 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0203370:	418787b3          	sub	a5,a5,s8
ffffffffc0203374:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203378:	96be                	add	a3,a3,a5
ffffffffc020337a:	039686b3          	mul	a3,a3,s9
ffffffffc020337e:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203380:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0203384:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203386:	12eaf263          	bleu	a4,s5,ffffffffc02034aa <pmm_init+0x608>
ffffffffc020338a:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc020338e:	4585                	li	a1,1
ffffffffc0203390:	8552                	mv	a0,s4
ffffffffc0203392:	99b6                	add	s3,s3,a3
ffffffffc0203394:	edeff0ef          	jal	ra,ffffffffc0202a72 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203398:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc020339c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020339e:	078a                	slli	a5,a5,0x2
ffffffffc02033a0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033a2:	10e7f263          	bleu	a4,a5,ffffffffc02034a6 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02033a6:	fff809b7          	lui	s3,0xfff80
ffffffffc02033aa:	97ce                	add	a5,a5,s3
ffffffffc02033ac:	00379513          	slli	a0,a5,0x3
ffffffffc02033b0:	00093703          	ld	a4,0(s2)
ffffffffc02033b4:	97aa                	add	a5,a5,a0
ffffffffc02033b6:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc02033ba:	953a                	add	a0,a0,a4
ffffffffc02033bc:	4585                	li	a1,1
ffffffffc02033be:	eb4ff0ef          	jal	ra,ffffffffc0202a72 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02033c2:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02033c6:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02033c8:	050a                	slli	a0,a0,0x2
ffffffffc02033ca:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033cc:	0cf57d63          	bleu	a5,a0,ffffffffc02034a6 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02033d0:	013507b3          	add	a5,a0,s3
ffffffffc02033d4:	00379513          	slli	a0,a5,0x3
ffffffffc02033d8:	00093703          	ld	a4,0(s2)
ffffffffc02033dc:	953e                	add	a0,a0,a5
ffffffffc02033de:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc02033e0:	4585                	li	a1,1
ffffffffc02033e2:	953a                	add	a0,a0,a4
ffffffffc02033e4:	e8eff0ef          	jal	ra,ffffffffc0202a72 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02033e8:	601c                	ld	a5,0(s0)
ffffffffc02033ea:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc02033ee:	ecaff0ef          	jal	ra,ffffffffc0202ab8 <nr_free_pages>
ffffffffc02033f2:	38ab1a63          	bne	s6,a0,ffffffffc0203786 <pmm_init+0x8e4>
}
ffffffffc02033f6:	6446                	ld	s0,80(sp)
ffffffffc02033f8:	60e6                	ld	ra,88(sp)
ffffffffc02033fa:	64a6                	ld	s1,72(sp)
ffffffffc02033fc:	6906                	ld	s2,64(sp)
ffffffffc02033fe:	79e2                	ld	s3,56(sp)
ffffffffc0203400:	7a42                	ld	s4,48(sp)
ffffffffc0203402:	7aa2                	ld	s5,40(sp)
ffffffffc0203404:	7b02                	ld	s6,32(sp)
ffffffffc0203406:	6be2                	ld	s7,24(sp)
ffffffffc0203408:	6c42                	ld	s8,16(sp)
ffffffffc020340a:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020340c:	00003517          	auipc	a0,0x3
ffffffffc0203410:	9b450513          	addi	a0,a0,-1612 # ffffffffc0205dc0 <default_pmm_manager+0x628>
}
ffffffffc0203414:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203416:	ca9fc06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020341a:	6705                	lui	a4,0x1
ffffffffc020341c:	177d                	addi	a4,a4,-1
ffffffffc020341e:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0203420:	00c6d713          	srli	a4,a3,0xc
ffffffffc0203424:	08f77163          	bleu	a5,a4,ffffffffc02034a6 <pmm_init+0x604>
    pmm_manager->init_memmap(base, n);
ffffffffc0203428:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc020342c:	9732                	add	a4,a4,a2
ffffffffc020342e:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203432:	767d                	lui	a2,0xfffff
ffffffffc0203434:	8ef1                	and	a3,a3,a2
ffffffffc0203436:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc0203438:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020343c:	8d95                	sub	a1,a1,a3
ffffffffc020343e:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0203440:	81b1                	srli	a1,a1,0xc
ffffffffc0203442:	953e                	add	a0,a0,a5
ffffffffc0203444:	9702                	jalr	a4
ffffffffc0203446:	bead                	j	ffffffffc0202fc0 <pmm_init+0x11e>
ffffffffc0203448:	6008                	ld	a0,0(s0)
ffffffffc020344a:	b5b5                	j	ffffffffc02032b6 <pmm_init+0x414>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020344c:	86d2                	mv	a3,s4
ffffffffc020344e:	00002617          	auipc	a2,0x2
ffffffffc0203452:	39a60613          	addi	a2,a2,922 # ffffffffc02057e8 <default_pmm_manager+0x50>
ffffffffc0203456:	1cd00593          	li	a1,461
ffffffffc020345a:	00002517          	auipc	a0,0x2
ffffffffc020345e:	3b650513          	addi	a0,a0,950 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203462:	ca5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203466:	00002697          	auipc	a3,0x2
ffffffffc020346a:	7ca68693          	addi	a3,a3,1994 # ffffffffc0205c30 <default_pmm_manager+0x498>
ffffffffc020346e:	00001617          	auipc	a2,0x1
ffffffffc0203472:	7c260613          	addi	a2,a2,1986 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203476:	1cd00593          	li	a1,461
ffffffffc020347a:	00002517          	auipc	a0,0x2
ffffffffc020347e:	39650513          	addi	a0,a0,918 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203482:	c85fc0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203486:	00002697          	auipc	a3,0x2
ffffffffc020348a:	7ea68693          	addi	a3,a3,2026 # ffffffffc0205c70 <default_pmm_manager+0x4d8>
ffffffffc020348e:	00001617          	auipc	a2,0x1
ffffffffc0203492:	7a260613          	addi	a2,a2,1954 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203496:	1ce00593          	li	a1,462
ffffffffc020349a:	00002517          	auipc	a0,0x2
ffffffffc020349e:	37650513          	addi	a0,a0,886 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc02034a2:	c65fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc02034a6:	d28ff0ef          	jal	ra,ffffffffc02029ce <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02034aa:	00002617          	auipc	a2,0x2
ffffffffc02034ae:	33e60613          	addi	a2,a2,830 # ffffffffc02057e8 <default_pmm_manager+0x50>
ffffffffc02034b2:	06a00593          	li	a1,106
ffffffffc02034b6:	00002517          	auipc	a0,0x2
ffffffffc02034ba:	b7250513          	addi	a0,a0,-1166 # ffffffffc0205028 <commands+0xc40>
ffffffffc02034be:	c49fc0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02034c2:	00002617          	auipc	a2,0x2
ffffffffc02034c6:	e1e60613          	addi	a2,a2,-482 # ffffffffc02052e0 <commands+0xef8>
ffffffffc02034ca:	07000593          	li	a1,112
ffffffffc02034ce:	00002517          	auipc	a0,0x2
ffffffffc02034d2:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0205028 <commands+0xc40>
ffffffffc02034d6:	c31fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02034da:	00002697          	auipc	a3,0x2
ffffffffc02034de:	48e68693          	addi	a3,a3,1166 # ffffffffc0205968 <default_pmm_manager+0x1d0>
ffffffffc02034e2:	00001617          	auipc	a2,0x1
ffffffffc02034e6:	74e60613          	addi	a2,a2,1870 # ffffffffc0204c30 <commands+0x848>
ffffffffc02034ea:	19300593          	li	a1,403
ffffffffc02034ee:	00002517          	auipc	a0,0x2
ffffffffc02034f2:	32250513          	addi	a0,a0,802 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc02034f6:	c11fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02034fa:	00002697          	auipc	a3,0x2
ffffffffc02034fe:	4a668693          	addi	a3,a3,1190 # ffffffffc02059a0 <default_pmm_manager+0x208>
ffffffffc0203502:	00001617          	auipc	a2,0x1
ffffffffc0203506:	72e60613          	addi	a2,a2,1838 # ffffffffc0204c30 <commands+0x848>
ffffffffc020350a:	19400593          	li	a1,404
ffffffffc020350e:	00002517          	auipc	a0,0x2
ffffffffc0203512:	30250513          	addi	a0,a0,770 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203516:	bf1fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020351a:	00002697          	auipc	a3,0x2
ffffffffc020351e:	6d668693          	addi	a3,a3,1750 # ffffffffc0205bf0 <default_pmm_manager+0x458>
ffffffffc0203522:	00001617          	auipc	a2,0x1
ffffffffc0203526:	70e60613          	addi	a2,a2,1806 # ffffffffc0204c30 <commands+0x848>
ffffffffc020352a:	1c000593          	li	a1,448
ffffffffc020352e:	00002517          	auipc	a0,0x2
ffffffffc0203532:	2e250513          	addi	a0,a0,738 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203536:	bd1fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020353a:	00002617          	auipc	a2,0x2
ffffffffc020353e:	3c660613          	addi	a2,a2,966 # ffffffffc0205900 <default_pmm_manager+0x168>
ffffffffc0203542:	07700593          	li	a1,119
ffffffffc0203546:	00002517          	auipc	a0,0x2
ffffffffc020354a:	2ca50513          	addi	a0,a0,714 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc020354e:	bb9fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203552:	00002697          	auipc	a3,0x2
ffffffffc0203556:	4a668693          	addi	a3,a3,1190 # ffffffffc02059f8 <default_pmm_manager+0x260>
ffffffffc020355a:	00001617          	auipc	a2,0x1
ffffffffc020355e:	6d660613          	addi	a2,a2,1750 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203562:	19a00593          	li	a1,410
ffffffffc0203566:	00002517          	auipc	a0,0x2
ffffffffc020356a:	2aa50513          	addi	a0,a0,682 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc020356e:	b99fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203572:	00002697          	auipc	a3,0x2
ffffffffc0203576:	45668693          	addi	a3,a3,1110 # ffffffffc02059c8 <default_pmm_manager+0x230>
ffffffffc020357a:	00001617          	auipc	a2,0x1
ffffffffc020357e:	6b660613          	addi	a2,a2,1718 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203582:	19800593          	li	a1,408
ffffffffc0203586:	00002517          	auipc	a0,0x2
ffffffffc020358a:	28a50513          	addi	a0,a0,650 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc020358e:	b79fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203592:	00002697          	auipc	a3,0x2
ffffffffc0203596:	55668693          	addi	a3,a3,1366 # ffffffffc0205ae8 <default_pmm_manager+0x350>
ffffffffc020359a:	00001617          	auipc	a2,0x1
ffffffffc020359e:	69660613          	addi	a2,a2,1686 # ffffffffc0204c30 <commands+0x848>
ffffffffc02035a2:	1a500593          	li	a1,421
ffffffffc02035a6:	00002517          	auipc	a0,0x2
ffffffffc02035aa:	26a50513          	addi	a0,a0,618 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc02035ae:	b59fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02035b2:	00002697          	auipc	a3,0x2
ffffffffc02035b6:	50668693          	addi	a3,a3,1286 # ffffffffc0205ab8 <default_pmm_manager+0x320>
ffffffffc02035ba:	00001617          	auipc	a2,0x1
ffffffffc02035be:	67660613          	addi	a2,a2,1654 # ffffffffc0204c30 <commands+0x848>
ffffffffc02035c2:	1a400593          	li	a1,420
ffffffffc02035c6:	00002517          	auipc	a0,0x2
ffffffffc02035ca:	24a50513          	addi	a0,a0,586 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc02035ce:	b39fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02035d2:	00002697          	auipc	a3,0x2
ffffffffc02035d6:	4ae68693          	addi	a3,a3,1198 # ffffffffc0205a80 <default_pmm_manager+0x2e8>
ffffffffc02035da:	00001617          	auipc	a2,0x1
ffffffffc02035de:	65660613          	addi	a2,a2,1622 # ffffffffc0204c30 <commands+0x848>
ffffffffc02035e2:	1a300593          	li	a1,419
ffffffffc02035e6:	00002517          	auipc	a0,0x2
ffffffffc02035ea:	22a50513          	addi	a0,a0,554 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc02035ee:	b19fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02035f2:	00002697          	auipc	a3,0x2
ffffffffc02035f6:	46668693          	addi	a3,a3,1126 # ffffffffc0205a58 <default_pmm_manager+0x2c0>
ffffffffc02035fa:	00001617          	auipc	a2,0x1
ffffffffc02035fe:	63660613          	addi	a2,a2,1590 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203602:	1a000593          	li	a1,416
ffffffffc0203606:	00002517          	auipc	a0,0x2
ffffffffc020360a:	20a50513          	addi	a0,a0,522 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc020360e:	af9fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203612:	86da                	mv	a3,s6
ffffffffc0203614:	00002617          	auipc	a2,0x2
ffffffffc0203618:	1d460613          	addi	a2,a2,468 # ffffffffc02057e8 <default_pmm_manager+0x50>
ffffffffc020361c:	19f00593          	li	a1,415
ffffffffc0203620:	00002517          	auipc	a0,0x2
ffffffffc0203624:	1f050513          	addi	a0,a0,496 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203628:	adffc0ef          	jal	ra,ffffffffc0200106 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020362c:	86be                	mv	a3,a5
ffffffffc020362e:	00002617          	auipc	a2,0x2
ffffffffc0203632:	1ba60613          	addi	a2,a2,442 # ffffffffc02057e8 <default_pmm_manager+0x50>
ffffffffc0203636:	19e00593          	li	a1,414
ffffffffc020363a:	00002517          	auipc	a0,0x2
ffffffffc020363e:	1d650513          	addi	a0,a0,470 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203642:	ac5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203646:	00002697          	auipc	a3,0x2
ffffffffc020364a:	3fa68693          	addi	a3,a3,1018 # ffffffffc0205a40 <default_pmm_manager+0x2a8>
ffffffffc020364e:	00001617          	auipc	a2,0x1
ffffffffc0203652:	5e260613          	addi	a2,a2,1506 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203656:	19c00593          	li	a1,412
ffffffffc020365a:	00002517          	auipc	a0,0x2
ffffffffc020365e:	1b650513          	addi	a0,a0,438 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203662:	aa5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203666:	00002697          	auipc	a3,0x2
ffffffffc020366a:	3c268693          	addi	a3,a3,962 # ffffffffc0205a28 <default_pmm_manager+0x290>
ffffffffc020366e:	00001617          	auipc	a2,0x1
ffffffffc0203672:	5c260613          	addi	a2,a2,1474 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203676:	19b00593          	li	a1,411
ffffffffc020367a:	00002517          	auipc	a0,0x2
ffffffffc020367e:	19650513          	addi	a0,a0,406 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203682:	a85fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203686:	00002697          	auipc	a3,0x2
ffffffffc020368a:	3a268693          	addi	a3,a3,930 # ffffffffc0205a28 <default_pmm_manager+0x290>
ffffffffc020368e:	00001617          	auipc	a2,0x1
ffffffffc0203692:	5a260613          	addi	a2,a2,1442 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203696:	1ae00593          	li	a1,430
ffffffffc020369a:	00002517          	auipc	a0,0x2
ffffffffc020369e:	17650513          	addi	a0,a0,374 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc02036a2:	a65fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02036a6:	00002697          	auipc	a3,0x2
ffffffffc02036aa:	41268693          	addi	a3,a3,1042 # ffffffffc0205ab8 <default_pmm_manager+0x320>
ffffffffc02036ae:	00001617          	auipc	a2,0x1
ffffffffc02036b2:	58260613          	addi	a2,a2,1410 # ffffffffc0204c30 <commands+0x848>
ffffffffc02036b6:	1ad00593          	li	a1,429
ffffffffc02036ba:	00002517          	auipc	a0,0x2
ffffffffc02036be:	15650513          	addi	a0,a0,342 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc02036c2:	a45fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02036c6:	00002697          	auipc	a3,0x2
ffffffffc02036ca:	4ba68693          	addi	a3,a3,1210 # ffffffffc0205b80 <default_pmm_manager+0x3e8>
ffffffffc02036ce:	00001617          	auipc	a2,0x1
ffffffffc02036d2:	56260613          	addi	a2,a2,1378 # ffffffffc0204c30 <commands+0x848>
ffffffffc02036d6:	1ac00593          	li	a1,428
ffffffffc02036da:	00002517          	auipc	a0,0x2
ffffffffc02036de:	13650513          	addi	a0,a0,310 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc02036e2:	a25fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02036e6:	00002697          	auipc	a3,0x2
ffffffffc02036ea:	48268693          	addi	a3,a3,1154 # ffffffffc0205b68 <default_pmm_manager+0x3d0>
ffffffffc02036ee:	00001617          	auipc	a2,0x1
ffffffffc02036f2:	54260613          	addi	a2,a2,1346 # ffffffffc0204c30 <commands+0x848>
ffffffffc02036f6:	1ab00593          	li	a1,427
ffffffffc02036fa:	00002517          	auipc	a0,0x2
ffffffffc02036fe:	11650513          	addi	a0,a0,278 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203702:	a05fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203706:	00002697          	auipc	a3,0x2
ffffffffc020370a:	43268693          	addi	a3,a3,1074 # ffffffffc0205b38 <default_pmm_manager+0x3a0>
ffffffffc020370e:	00001617          	auipc	a2,0x1
ffffffffc0203712:	52260613          	addi	a2,a2,1314 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203716:	1aa00593          	li	a1,426
ffffffffc020371a:	00002517          	auipc	a0,0x2
ffffffffc020371e:	0f650513          	addi	a0,a0,246 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203722:	9e5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203726:	00002697          	auipc	a3,0x2
ffffffffc020372a:	3fa68693          	addi	a3,a3,1018 # ffffffffc0205b20 <default_pmm_manager+0x388>
ffffffffc020372e:	00001617          	auipc	a2,0x1
ffffffffc0203732:	50260613          	addi	a2,a2,1282 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203736:	1a800593          	li	a1,424
ffffffffc020373a:	00002517          	auipc	a0,0x2
ffffffffc020373e:	0d650513          	addi	a0,a0,214 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203742:	9c5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203746:	00002697          	auipc	a3,0x2
ffffffffc020374a:	3c268693          	addi	a3,a3,962 # ffffffffc0205b08 <default_pmm_manager+0x370>
ffffffffc020374e:	00001617          	auipc	a2,0x1
ffffffffc0203752:	4e260613          	addi	a2,a2,1250 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203756:	1a700593          	li	a1,423
ffffffffc020375a:	00002517          	auipc	a0,0x2
ffffffffc020375e:	0b650513          	addi	a0,a0,182 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203762:	9a5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203766:	00002697          	auipc	a3,0x2
ffffffffc020376a:	39268693          	addi	a3,a3,914 # ffffffffc0205af8 <default_pmm_manager+0x360>
ffffffffc020376e:	00001617          	auipc	a2,0x1
ffffffffc0203772:	4c260613          	addi	a2,a2,1218 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203776:	1a600593          	li	a1,422
ffffffffc020377a:	00002517          	auipc	a0,0x2
ffffffffc020377e:	09650513          	addi	a0,a0,150 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203782:	985fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203786:	00002697          	auipc	a3,0x2
ffffffffc020378a:	46a68693          	addi	a3,a3,1130 # ffffffffc0205bf0 <default_pmm_manager+0x458>
ffffffffc020378e:	00001617          	auipc	a2,0x1
ffffffffc0203792:	4a260613          	addi	a2,a2,1186 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203796:	1e800593          	li	a1,488
ffffffffc020379a:	00002517          	auipc	a0,0x2
ffffffffc020379e:	07650513          	addi	a0,a0,118 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc02037a2:	965fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02037a6:	00002697          	auipc	a3,0x2
ffffffffc02037aa:	5f268693          	addi	a3,a3,1522 # ffffffffc0205d98 <default_pmm_manager+0x600>
ffffffffc02037ae:	00001617          	auipc	a2,0x1
ffffffffc02037b2:	48260613          	addi	a2,a2,1154 # ffffffffc0204c30 <commands+0x848>
ffffffffc02037b6:	1e000593          	li	a1,480
ffffffffc02037ba:	00002517          	auipc	a0,0x2
ffffffffc02037be:	05650513          	addi	a0,a0,86 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc02037c2:	945fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02037c6:	00002697          	auipc	a3,0x2
ffffffffc02037ca:	59a68693          	addi	a3,a3,1434 # ffffffffc0205d60 <default_pmm_manager+0x5c8>
ffffffffc02037ce:	00001617          	auipc	a2,0x1
ffffffffc02037d2:	46260613          	addi	a2,a2,1122 # ffffffffc0204c30 <commands+0x848>
ffffffffc02037d6:	1dd00593          	li	a1,477
ffffffffc02037da:	00002517          	auipc	a0,0x2
ffffffffc02037de:	03650513          	addi	a0,a0,54 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc02037e2:	925fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02037e6:	00002697          	auipc	a3,0x2
ffffffffc02037ea:	54a68693          	addi	a3,a3,1354 # ffffffffc0205d30 <default_pmm_manager+0x598>
ffffffffc02037ee:	00001617          	auipc	a2,0x1
ffffffffc02037f2:	44260613          	addi	a2,a2,1090 # ffffffffc0204c30 <commands+0x848>
ffffffffc02037f6:	1d900593          	li	a1,473
ffffffffc02037fa:	00002517          	auipc	a0,0x2
ffffffffc02037fe:	01650513          	addi	a0,a0,22 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203802:	905fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203806:	00002697          	auipc	a3,0x2
ffffffffc020380a:	3aa68693          	addi	a3,a3,938 # ffffffffc0205bb0 <default_pmm_manager+0x418>
ffffffffc020380e:	00001617          	auipc	a2,0x1
ffffffffc0203812:	42260613          	addi	a2,a2,1058 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203816:	1b600593          	li	a1,438
ffffffffc020381a:	00002517          	auipc	a0,0x2
ffffffffc020381e:	ff650513          	addi	a0,a0,-10 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203822:	8e5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203826:	00002697          	auipc	a3,0x2
ffffffffc020382a:	35a68693          	addi	a3,a3,858 # ffffffffc0205b80 <default_pmm_manager+0x3e8>
ffffffffc020382e:	00001617          	auipc	a2,0x1
ffffffffc0203832:	40260613          	addi	a2,a2,1026 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203836:	1b300593          	li	a1,435
ffffffffc020383a:	00002517          	auipc	a0,0x2
ffffffffc020383e:	fd650513          	addi	a0,a0,-42 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203842:	8c5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203846:	00002697          	auipc	a3,0x2
ffffffffc020384a:	1fa68693          	addi	a3,a3,506 # ffffffffc0205a40 <default_pmm_manager+0x2a8>
ffffffffc020384e:	00001617          	auipc	a2,0x1
ffffffffc0203852:	3e260613          	addi	a2,a2,994 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203856:	1b200593          	li	a1,434
ffffffffc020385a:	00002517          	auipc	a0,0x2
ffffffffc020385e:	fb650513          	addi	a0,a0,-74 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203862:	8a5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203866:	00002697          	auipc	a3,0x2
ffffffffc020386a:	33268693          	addi	a3,a3,818 # ffffffffc0205b98 <default_pmm_manager+0x400>
ffffffffc020386e:	00001617          	auipc	a2,0x1
ffffffffc0203872:	3c260613          	addi	a2,a2,962 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203876:	1af00593          	li	a1,431
ffffffffc020387a:	00002517          	auipc	a0,0x2
ffffffffc020387e:	f9650513          	addi	a0,a0,-106 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203882:	885fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203886:	00002697          	auipc	a3,0x2
ffffffffc020388a:	34268693          	addi	a3,a3,834 # ffffffffc0205bc8 <default_pmm_manager+0x430>
ffffffffc020388e:	00001617          	auipc	a2,0x1
ffffffffc0203892:	3a260613          	addi	a2,a2,930 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203896:	1b900593          	li	a1,441
ffffffffc020389a:	00002517          	auipc	a0,0x2
ffffffffc020389e:	f7650513          	addi	a0,a0,-138 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc02038a2:	865fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02038a6:	00002697          	auipc	a3,0x2
ffffffffc02038aa:	2da68693          	addi	a3,a3,730 # ffffffffc0205b80 <default_pmm_manager+0x3e8>
ffffffffc02038ae:	00001617          	auipc	a2,0x1
ffffffffc02038b2:	38260613          	addi	a2,a2,898 # ffffffffc0204c30 <commands+0x848>
ffffffffc02038b6:	1b700593          	li	a1,439
ffffffffc02038ba:	00002517          	auipc	a0,0x2
ffffffffc02038be:	f5650513          	addi	a0,a0,-170 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc02038c2:	845fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02038c6:	00002697          	auipc	a3,0x2
ffffffffc02038ca:	08268693          	addi	a3,a3,130 # ffffffffc0205948 <default_pmm_manager+0x1b0>
ffffffffc02038ce:	00001617          	auipc	a2,0x1
ffffffffc02038d2:	36260613          	addi	a2,a2,866 # ffffffffc0204c30 <commands+0x848>
ffffffffc02038d6:	19200593          	li	a1,402
ffffffffc02038da:	00002517          	auipc	a0,0x2
ffffffffc02038de:	f3650513          	addi	a0,a0,-202 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc02038e2:	825fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02038e6:	00002617          	auipc	a2,0x2
ffffffffc02038ea:	01a60613          	addi	a2,a2,26 # ffffffffc0205900 <default_pmm_manager+0x168>
ffffffffc02038ee:	0bd00593          	li	a1,189
ffffffffc02038f2:	00002517          	auipc	a0,0x2
ffffffffc02038f6:	f1e50513          	addi	a0,a0,-226 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc02038fa:	80dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02038fe:	00002697          	auipc	a3,0x2
ffffffffc0203902:	3f268693          	addi	a3,a3,1010 # ffffffffc0205cf0 <default_pmm_manager+0x558>
ffffffffc0203906:	00001617          	auipc	a2,0x1
ffffffffc020390a:	32a60613          	addi	a2,a2,810 # ffffffffc0204c30 <commands+0x848>
ffffffffc020390e:	1d800593          	li	a1,472
ffffffffc0203912:	00002517          	auipc	a0,0x2
ffffffffc0203916:	efe50513          	addi	a0,a0,-258 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc020391a:	fecfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p) == 1);
ffffffffc020391e:	00002697          	auipc	a3,0x2
ffffffffc0203922:	3ba68693          	addi	a3,a3,954 # ffffffffc0205cd8 <default_pmm_manager+0x540>
ffffffffc0203926:	00001617          	auipc	a2,0x1
ffffffffc020392a:	30a60613          	addi	a2,a2,778 # ffffffffc0204c30 <commands+0x848>
ffffffffc020392e:	1d700593          	li	a1,471
ffffffffc0203932:	00002517          	auipc	a0,0x2
ffffffffc0203936:	ede50513          	addi	a0,a0,-290 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc020393a:	fccfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020393e:	00002697          	auipc	a3,0x2
ffffffffc0203942:	36268693          	addi	a3,a3,866 # ffffffffc0205ca0 <default_pmm_manager+0x508>
ffffffffc0203946:	00001617          	auipc	a2,0x1
ffffffffc020394a:	2ea60613          	addi	a2,a2,746 # ffffffffc0204c30 <commands+0x848>
ffffffffc020394e:	1d600593          	li	a1,470
ffffffffc0203952:	00002517          	auipc	a0,0x2
ffffffffc0203956:	ebe50513          	addi	a0,a0,-322 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc020395a:	facfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc020395e:	00002697          	auipc	a3,0x2
ffffffffc0203962:	32a68693          	addi	a3,a3,810 # ffffffffc0205c88 <default_pmm_manager+0x4f0>
ffffffffc0203966:	00001617          	auipc	a2,0x1
ffffffffc020396a:	2ca60613          	addi	a2,a2,714 # ffffffffc0204c30 <commands+0x848>
ffffffffc020396e:	1d200593          	li	a1,466
ffffffffc0203972:	00002517          	auipc	a0,0x2
ffffffffc0203976:	e9e50513          	addi	a0,a0,-354 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc020397a:	f8cfc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc020397e <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc020397e:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0203982:	8082                	ret

ffffffffc0203984 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203984:	7179                	addi	sp,sp,-48
ffffffffc0203986:	e84a                	sd	s2,16(sp)
ffffffffc0203988:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020398a:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020398c:	f022                	sd	s0,32(sp)
ffffffffc020398e:	ec26                	sd	s1,24(sp)
ffffffffc0203990:	e44e                	sd	s3,8(sp)
ffffffffc0203992:	f406                	sd	ra,40(sp)
ffffffffc0203994:	84ae                	mv	s1,a1
ffffffffc0203996:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203998:	852ff0ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc020399c:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc020399e:	cd19                	beqz	a0,ffffffffc02039bc <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02039a0:	85aa                	mv	a1,a0
ffffffffc02039a2:	86ce                	mv	a3,s3
ffffffffc02039a4:	8626                	mv	a2,s1
ffffffffc02039a6:	854a                	mv	a0,s2
ffffffffc02039a8:	c28ff0ef          	jal	ra,ffffffffc0202dd0 <page_insert>
ffffffffc02039ac:	ed39                	bnez	a0,ffffffffc0203a0a <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc02039ae:	0000e797          	auipc	a5,0xe
ffffffffc02039b2:	ab278793          	addi	a5,a5,-1358 # ffffffffc0211460 <swap_init_ok>
ffffffffc02039b6:	439c                	lw	a5,0(a5)
ffffffffc02039b8:	2781                	sext.w	a5,a5
ffffffffc02039ba:	eb89                	bnez	a5,ffffffffc02039cc <pgdir_alloc_page+0x48>
}
ffffffffc02039bc:	8522                	mv	a0,s0
ffffffffc02039be:	70a2                	ld	ra,40(sp)
ffffffffc02039c0:	7402                	ld	s0,32(sp)
ffffffffc02039c2:	64e2                	ld	s1,24(sp)
ffffffffc02039c4:	6942                	ld	s2,16(sp)
ffffffffc02039c6:	69a2                	ld	s3,8(sp)
ffffffffc02039c8:	6145                	addi	sp,sp,48
ffffffffc02039ca:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02039cc:	0000e797          	auipc	a5,0xe
ffffffffc02039d0:	ac478793          	addi	a5,a5,-1340 # ffffffffc0211490 <check_mm_struct>
ffffffffc02039d4:	6388                	ld	a0,0(a5)
ffffffffc02039d6:	4681                	li	a3,0
ffffffffc02039d8:	8622                	mv	a2,s0
ffffffffc02039da:	85a6                	mv	a1,s1
ffffffffc02039dc:	ae2fe0ef          	jal	ra,ffffffffc0201cbe <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc02039e0:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc02039e2:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc02039e4:	4785                	li	a5,1
ffffffffc02039e6:	fcf70be3          	beq	a4,a5,ffffffffc02039bc <pgdir_alloc_page+0x38>
ffffffffc02039ea:	00002697          	auipc	a3,0x2
ffffffffc02039ee:	e7668693          	addi	a3,a3,-394 # ffffffffc0205860 <default_pmm_manager+0xc8>
ffffffffc02039f2:	00001617          	auipc	a2,0x1
ffffffffc02039f6:	23e60613          	addi	a2,a2,574 # ffffffffc0204c30 <commands+0x848>
ffffffffc02039fa:	17a00593          	li	a1,378
ffffffffc02039fe:	00002517          	auipc	a0,0x2
ffffffffc0203a02:	e1250513          	addi	a0,a0,-494 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203a06:	f00fc0ef          	jal	ra,ffffffffc0200106 <__panic>
            free_page(page);
ffffffffc0203a0a:	8522                	mv	a0,s0
ffffffffc0203a0c:	4585                	li	a1,1
ffffffffc0203a0e:	864ff0ef          	jal	ra,ffffffffc0202a72 <free_pages>
            return NULL;
ffffffffc0203a12:	4401                	li	s0,0
ffffffffc0203a14:	b765                	j	ffffffffc02039bc <pgdir_alloc_page+0x38>

ffffffffc0203a16 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0203a16:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203a18:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0203a1a:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203a1c:	fff50713          	addi	a4,a0,-1
ffffffffc0203a20:	17f9                	addi	a5,a5,-2
ffffffffc0203a22:	04e7ee63          	bltu	a5,a4,ffffffffc0203a7e <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203a26:	6785                	lui	a5,0x1
ffffffffc0203a28:	17fd                	addi	a5,a5,-1
ffffffffc0203a2a:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0203a2c:	8131                	srli	a0,a0,0xc
ffffffffc0203a2e:	fbdfe0ef          	jal	ra,ffffffffc02029ea <alloc_pages>
    assert(base != NULL);
ffffffffc0203a32:	c159                	beqz	a0,ffffffffc0203ab8 <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203a34:	0000e797          	auipc	a5,0xe
ffffffffc0203a38:	b5c78793          	addi	a5,a5,-1188 # ffffffffc0211590 <pages>
ffffffffc0203a3c:	639c                	ld	a5,0(a5)
ffffffffc0203a3e:	8d1d                	sub	a0,a0,a5
ffffffffc0203a40:	00002797          	auipc	a5,0x2
ffffffffc0203a44:	a0078793          	addi	a5,a5,-1536 # ffffffffc0205440 <commands+0x1058>
ffffffffc0203a48:	6394                	ld	a3,0(a5)
ffffffffc0203a4a:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203a4c:	0000e797          	auipc	a5,0xe
ffffffffc0203a50:	a2478793          	addi	a5,a5,-1500 # ffffffffc0211470 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203a54:	02d50533          	mul	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203a58:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203a5a:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203a5e:	57fd                	li	a5,-1
ffffffffc0203a60:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203a62:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203a64:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203a66:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203a68:	02e7fb63          	bleu	a4,a5,ffffffffc0203a9e <kmalloc+0x88>
ffffffffc0203a6c:	0000e797          	auipc	a5,0xe
ffffffffc0203a70:	b1478793          	addi	a5,a5,-1260 # ffffffffc0211580 <va_pa_offset>
ffffffffc0203a74:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0203a76:	60a2                	ld	ra,8(sp)
ffffffffc0203a78:	953e                	add	a0,a0,a5
ffffffffc0203a7a:	0141                	addi	sp,sp,16
ffffffffc0203a7c:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203a7e:	00002697          	auipc	a3,0x2
ffffffffc0203a82:	db268693          	addi	a3,a3,-590 # ffffffffc0205830 <default_pmm_manager+0x98>
ffffffffc0203a86:	00001617          	auipc	a2,0x1
ffffffffc0203a8a:	1aa60613          	addi	a2,a2,426 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203a8e:	1f000593          	li	a1,496
ffffffffc0203a92:	00002517          	auipc	a0,0x2
ffffffffc0203a96:	d7e50513          	addi	a0,a0,-642 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203a9a:	e6cfc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203a9e:	86aa                	mv	a3,a0
ffffffffc0203aa0:	00002617          	auipc	a2,0x2
ffffffffc0203aa4:	d4860613          	addi	a2,a2,-696 # ffffffffc02057e8 <default_pmm_manager+0x50>
ffffffffc0203aa8:	06a00593          	li	a1,106
ffffffffc0203aac:	00001517          	auipc	a0,0x1
ffffffffc0203ab0:	57c50513          	addi	a0,a0,1404 # ffffffffc0205028 <commands+0xc40>
ffffffffc0203ab4:	e52fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(base != NULL);
ffffffffc0203ab8:	00002697          	auipc	a3,0x2
ffffffffc0203abc:	d9868693          	addi	a3,a3,-616 # ffffffffc0205850 <default_pmm_manager+0xb8>
ffffffffc0203ac0:	00001617          	auipc	a2,0x1
ffffffffc0203ac4:	17060613          	addi	a2,a2,368 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203ac8:	1f300593          	li	a1,499
ffffffffc0203acc:	00002517          	auipc	a0,0x2
ffffffffc0203ad0:	d4450513          	addi	a0,a0,-700 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203ad4:	e32fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203ad8 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0203ad8:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203ada:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0203adc:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203ade:	fff58713          	addi	a4,a1,-1
ffffffffc0203ae2:	17f9                	addi	a5,a5,-2
ffffffffc0203ae4:	04e7eb63          	bltu	a5,a4,ffffffffc0203b3a <kfree+0x62>
    assert(ptr != NULL);
ffffffffc0203ae8:	c941                	beqz	a0,ffffffffc0203b78 <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203aea:	6785                	lui	a5,0x1
ffffffffc0203aec:	17fd                	addi	a5,a5,-1
ffffffffc0203aee:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203af0:	c02007b7          	lui	a5,0xc0200
ffffffffc0203af4:	81b1                	srli	a1,a1,0xc
ffffffffc0203af6:	06f56463          	bltu	a0,a5,ffffffffc0203b5e <kfree+0x86>
ffffffffc0203afa:	0000e797          	auipc	a5,0xe
ffffffffc0203afe:	a8678793          	addi	a5,a5,-1402 # ffffffffc0211580 <va_pa_offset>
ffffffffc0203b02:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203b04:	0000e717          	auipc	a4,0xe
ffffffffc0203b08:	96c70713          	addi	a4,a4,-1684 # ffffffffc0211470 <npage>
ffffffffc0203b0c:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203b0e:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc0203b12:	83b1                	srli	a5,a5,0xc
ffffffffc0203b14:	04e7f363          	bleu	a4,a5,ffffffffc0203b5a <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b18:	fff80537          	lui	a0,0xfff80
ffffffffc0203b1c:	97aa                	add	a5,a5,a0
ffffffffc0203b1e:	0000e697          	auipc	a3,0xe
ffffffffc0203b22:	a7268693          	addi	a3,a3,-1422 # ffffffffc0211590 <pages>
ffffffffc0203b26:	6288                	ld	a0,0(a3)
ffffffffc0203b28:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0203b2c:	60a2                	ld	ra,8(sp)
ffffffffc0203b2e:	97ba                	add	a5,a5,a4
ffffffffc0203b30:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc0203b32:	953e                	add	a0,a0,a5
}
ffffffffc0203b34:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc0203b36:	f3dfe06f          	j	ffffffffc0202a72 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203b3a:	00002697          	auipc	a3,0x2
ffffffffc0203b3e:	cf668693          	addi	a3,a3,-778 # ffffffffc0205830 <default_pmm_manager+0x98>
ffffffffc0203b42:	00001617          	auipc	a2,0x1
ffffffffc0203b46:	0ee60613          	addi	a2,a2,238 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203b4a:	1f900593          	li	a1,505
ffffffffc0203b4e:	00002517          	auipc	a0,0x2
ffffffffc0203b52:	cc250513          	addi	a0,a0,-830 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203b56:	db0fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203b5a:	e75fe0ef          	jal	ra,ffffffffc02029ce <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203b5e:	86aa                	mv	a3,a0
ffffffffc0203b60:	00002617          	auipc	a2,0x2
ffffffffc0203b64:	da060613          	addi	a2,a2,-608 # ffffffffc0205900 <default_pmm_manager+0x168>
ffffffffc0203b68:	06c00593          	li	a1,108
ffffffffc0203b6c:	00001517          	auipc	a0,0x1
ffffffffc0203b70:	4bc50513          	addi	a0,a0,1212 # ffffffffc0205028 <commands+0xc40>
ffffffffc0203b74:	d92fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(ptr != NULL);
ffffffffc0203b78:	00002697          	auipc	a3,0x2
ffffffffc0203b7c:	ca868693          	addi	a3,a3,-856 # ffffffffc0205820 <default_pmm_manager+0x88>
ffffffffc0203b80:	00001617          	auipc	a2,0x1
ffffffffc0203b84:	0b060613          	addi	a2,a2,176 # ffffffffc0204c30 <commands+0x848>
ffffffffc0203b88:	1fa00593          	li	a1,506
ffffffffc0203b8c:	00002517          	auipc	a0,0x2
ffffffffc0203b90:	c8450513          	addi	a0,a0,-892 # ffffffffc0205810 <default_pmm_manager+0x78>
ffffffffc0203b94:	d72fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203b98 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203b98:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);// 以SECTSIZE的整数倍读写，确保对齐
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203b9a:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203b9c:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203b9e:	839fc0ef          	jal	ra,ffffffffc02003d6 <ide_device_valid>
ffffffffc0203ba2:	cd01                	beqz	a0,ffffffffc0203bba <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);// 按页存，可以存多少页
ffffffffc0203ba4:	4505                	li	a0,1
ffffffffc0203ba6:	837fc0ef          	jal	ra,ffffffffc02003dc <ide_device_size>
}
ffffffffc0203baa:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);// 按页存，可以存多少页
ffffffffc0203bac:	810d                	srli	a0,a0,0x3
ffffffffc0203bae:	0000e797          	auipc	a5,0xe
ffffffffc0203bb2:	96a7b923          	sd	a0,-1678(a5) # ffffffffc0211520 <max_swap_offset>
}
ffffffffc0203bb6:	0141                	addi	sp,sp,16
ffffffffc0203bb8:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203bba:	00002617          	auipc	a2,0x2
ffffffffc0203bbe:	22660613          	addi	a2,a2,550 # ffffffffc0205de0 <default_pmm_manager+0x648>
ffffffffc0203bc2:	45b5                	li	a1,13
ffffffffc0203bc4:	00002517          	auipc	a0,0x2
ffffffffc0203bc8:	23c50513          	addi	a0,a0,572 # ffffffffc0205e00 <default_pmm_manager+0x668>
ffffffffc0203bcc:	d3afc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203bd0 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {// 读
ffffffffc0203bd0:	1141                	addi	sp,sp,-16
ffffffffc0203bd2:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203bd4:	00855793          	srli	a5,a0,0x8
ffffffffc0203bd8:	c7b5                	beqz	a5,ffffffffc0203c44 <swapfs_read+0x74>
ffffffffc0203bda:	0000e717          	auipc	a4,0xe
ffffffffc0203bde:	94670713          	addi	a4,a4,-1722 # ffffffffc0211520 <max_swap_offset>
ffffffffc0203be2:	6318                	ld	a4,0(a4)
ffffffffc0203be4:	06e7f063          	bleu	a4,a5,ffffffffc0203c44 <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203be8:	0000e717          	auipc	a4,0xe
ffffffffc0203bec:	9a870713          	addi	a4,a4,-1624 # ffffffffc0211590 <pages>
ffffffffc0203bf0:	6310                	ld	a2,0(a4)
ffffffffc0203bf2:	00002717          	auipc	a4,0x2
ffffffffc0203bf6:	84e70713          	addi	a4,a4,-1970 # ffffffffc0205440 <commands+0x1058>
ffffffffc0203bfa:	00002697          	auipc	a3,0x2
ffffffffc0203bfe:	48668693          	addi	a3,a3,1158 # ffffffffc0206080 <nbase>
ffffffffc0203c02:	40c58633          	sub	a2,a1,a2
ffffffffc0203c06:	630c                	ld	a1,0(a4)
ffffffffc0203c08:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c0a:	0000e717          	auipc	a4,0xe
ffffffffc0203c0e:	86670713          	addi	a4,a4,-1946 # ffffffffc0211470 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c12:	02b60633          	mul	a2,a2,a1
ffffffffc0203c16:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203c1a:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c1c:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c1e:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c20:	57fd                	li	a5,-1
ffffffffc0203c22:	83b1                	srli	a5,a5,0xc
ffffffffc0203c24:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203c26:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c28:	02e7fa63          	bleu	a4,a5,ffffffffc0203c5c <swapfs_read+0x8c>
ffffffffc0203c2c:	0000e797          	auipc	a5,0xe
ffffffffc0203c30:	95478793          	addi	a5,a5,-1708 # ffffffffc0211580 <va_pa_offset>
ffffffffc0203c34:	639c                	ld	a5,0(a5)
}
ffffffffc0203c36:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c38:	46a1                	li	a3,8
ffffffffc0203c3a:	963e                	add	a2,a2,a5
ffffffffc0203c3c:	4505                	li	a0,1
}
ffffffffc0203c3e:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c40:	fa2fc06f          	j	ffffffffc02003e2 <ide_read_secs>
ffffffffc0203c44:	86aa                	mv	a3,a0
ffffffffc0203c46:	00002617          	auipc	a2,0x2
ffffffffc0203c4a:	1d260613          	addi	a2,a2,466 # ffffffffc0205e18 <default_pmm_manager+0x680>
ffffffffc0203c4e:	45d1                	li	a1,20
ffffffffc0203c50:	00002517          	auipc	a0,0x2
ffffffffc0203c54:	1b050513          	addi	a0,a0,432 # ffffffffc0205e00 <default_pmm_manager+0x668>
ffffffffc0203c58:	caefc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203c5c:	86b2                	mv	a3,a2
ffffffffc0203c5e:	06a00593          	li	a1,106
ffffffffc0203c62:	00002617          	auipc	a2,0x2
ffffffffc0203c66:	b8660613          	addi	a2,a2,-1146 # ffffffffc02057e8 <default_pmm_manager+0x50>
ffffffffc0203c6a:	00001517          	auipc	a0,0x1
ffffffffc0203c6e:	3be50513          	addi	a0,a0,958 # ffffffffc0205028 <commands+0xc40>
ffffffffc0203c72:	c94fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203c76 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {// 写
ffffffffc0203c76:	1141                	addi	sp,sp,-16
ffffffffc0203c78:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c7a:	00855793          	srli	a5,a0,0x8
ffffffffc0203c7e:	c7b5                	beqz	a5,ffffffffc0203cea <swapfs_write+0x74>
ffffffffc0203c80:	0000e717          	auipc	a4,0xe
ffffffffc0203c84:	8a070713          	addi	a4,a4,-1888 # ffffffffc0211520 <max_swap_offset>
ffffffffc0203c88:	6318                	ld	a4,0(a4)
ffffffffc0203c8a:	06e7f063          	bleu	a4,a5,ffffffffc0203cea <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c8e:	0000e717          	auipc	a4,0xe
ffffffffc0203c92:	90270713          	addi	a4,a4,-1790 # ffffffffc0211590 <pages>
ffffffffc0203c96:	6310                	ld	a2,0(a4)
ffffffffc0203c98:	00001717          	auipc	a4,0x1
ffffffffc0203c9c:	7a870713          	addi	a4,a4,1960 # ffffffffc0205440 <commands+0x1058>
ffffffffc0203ca0:	00002697          	auipc	a3,0x2
ffffffffc0203ca4:	3e068693          	addi	a3,a3,992 # ffffffffc0206080 <nbase>
ffffffffc0203ca8:	40c58633          	sub	a2,a1,a2
ffffffffc0203cac:	630c                	ld	a1,0(a4)
ffffffffc0203cae:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cb0:	0000d717          	auipc	a4,0xd
ffffffffc0203cb4:	7c070713          	addi	a4,a4,1984 # ffffffffc0211470 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cb8:	02b60633          	mul	a2,a2,a1
ffffffffc0203cbc:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203cc0:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cc2:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cc4:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cc6:	57fd                	li	a5,-1
ffffffffc0203cc8:	83b1                	srli	a5,a5,0xc
ffffffffc0203cca:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ccc:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cce:	02e7fa63          	bleu	a4,a5,ffffffffc0203d02 <swapfs_write+0x8c>
ffffffffc0203cd2:	0000e797          	auipc	a5,0xe
ffffffffc0203cd6:	8ae78793          	addi	a5,a5,-1874 # ffffffffc0211580 <va_pa_offset>
ffffffffc0203cda:	639c                	ld	a5,0(a5)
}
ffffffffc0203cdc:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cde:	46a1                	li	a3,8
ffffffffc0203ce0:	963e                	add	a2,a2,a5
ffffffffc0203ce2:	4505                	li	a0,1
}
ffffffffc0203ce4:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ce6:	f20fc06f          	j	ffffffffc0200406 <ide_write_secs>
ffffffffc0203cea:	86aa                	mv	a3,a0
ffffffffc0203cec:	00002617          	auipc	a2,0x2
ffffffffc0203cf0:	12c60613          	addi	a2,a2,300 # ffffffffc0205e18 <default_pmm_manager+0x680>
ffffffffc0203cf4:	45e5                	li	a1,25
ffffffffc0203cf6:	00002517          	auipc	a0,0x2
ffffffffc0203cfa:	10a50513          	addi	a0,a0,266 # ffffffffc0205e00 <default_pmm_manager+0x668>
ffffffffc0203cfe:	c08fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203d02:	86b2                	mv	a3,a2
ffffffffc0203d04:	06a00593          	li	a1,106
ffffffffc0203d08:	00002617          	auipc	a2,0x2
ffffffffc0203d0c:	ae060613          	addi	a2,a2,-1312 # ffffffffc02057e8 <default_pmm_manager+0x50>
ffffffffc0203d10:	00001517          	auipc	a0,0x1
ffffffffc0203d14:	31850513          	addi	a0,a0,792 # ffffffffc0205028 <commands+0xc40>
ffffffffc0203d18:	beefc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203d1c <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203d1c:	00054783          	lbu	a5,0(a0)
ffffffffc0203d20:	cb91                	beqz	a5,ffffffffc0203d34 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0203d22:	4781                	li	a5,0
        cnt ++;
ffffffffc0203d24:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0203d26:	00f50733          	add	a4,a0,a5
ffffffffc0203d2a:	00074703          	lbu	a4,0(a4)
ffffffffc0203d2e:	fb7d                	bnez	a4,ffffffffc0203d24 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0203d30:	853e                	mv	a0,a5
ffffffffc0203d32:	8082                	ret
    size_t cnt = 0;
ffffffffc0203d34:	4781                	li	a5,0
}
ffffffffc0203d36:	853e                	mv	a0,a5
ffffffffc0203d38:	8082                	ret

ffffffffc0203d3a <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203d3a:	c185                	beqz	a1,ffffffffc0203d5a <strnlen+0x20>
ffffffffc0203d3c:	00054783          	lbu	a5,0(a0)
ffffffffc0203d40:	cf89                	beqz	a5,ffffffffc0203d5a <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0203d42:	4781                	li	a5,0
ffffffffc0203d44:	a021                	j	ffffffffc0203d4c <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203d46:	00074703          	lbu	a4,0(a4)
ffffffffc0203d4a:	c711                	beqz	a4,ffffffffc0203d56 <strnlen+0x1c>
        cnt ++;
ffffffffc0203d4c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203d4e:	00f50733          	add	a4,a0,a5
ffffffffc0203d52:	fef59ae3          	bne	a1,a5,ffffffffc0203d46 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0203d56:	853e                	mv	a0,a5
ffffffffc0203d58:	8082                	ret
    size_t cnt = 0;
ffffffffc0203d5a:	4781                	li	a5,0
}
ffffffffc0203d5c:	853e                	mv	a0,a5
ffffffffc0203d5e:	8082                	ret

ffffffffc0203d60 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203d60:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203d62:	0585                	addi	a1,a1,1
ffffffffc0203d64:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203d68:	0785                	addi	a5,a5,1
ffffffffc0203d6a:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203d6e:	fb75                	bnez	a4,ffffffffc0203d62 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203d70:	8082                	ret

ffffffffc0203d72 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203d72:	00054783          	lbu	a5,0(a0)
ffffffffc0203d76:	0005c703          	lbu	a4,0(a1)
ffffffffc0203d7a:	cb91                	beqz	a5,ffffffffc0203d8e <strcmp+0x1c>
ffffffffc0203d7c:	00e79c63          	bne	a5,a4,ffffffffc0203d94 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0203d80:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203d82:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0203d86:	0585                	addi	a1,a1,1
ffffffffc0203d88:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203d8c:	fbe5                	bnez	a5,ffffffffc0203d7c <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203d8e:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203d90:	9d19                	subw	a0,a0,a4
ffffffffc0203d92:	8082                	ret
ffffffffc0203d94:	0007851b          	sext.w	a0,a5
ffffffffc0203d98:	9d19                	subw	a0,a0,a4
ffffffffc0203d9a:	8082                	ret

ffffffffc0203d9c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203d9c:	00054783          	lbu	a5,0(a0)
ffffffffc0203da0:	cb91                	beqz	a5,ffffffffc0203db4 <strchr+0x18>
        if (*s == c) {
ffffffffc0203da2:	00b79563          	bne	a5,a1,ffffffffc0203dac <strchr+0x10>
ffffffffc0203da6:	a809                	j	ffffffffc0203db8 <strchr+0x1c>
ffffffffc0203da8:	00b78763          	beq	a5,a1,ffffffffc0203db6 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0203dac:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203dae:	00054783          	lbu	a5,0(a0)
ffffffffc0203db2:	fbfd                	bnez	a5,ffffffffc0203da8 <strchr+0xc>
    }
    return NULL;
ffffffffc0203db4:	4501                	li	a0,0
}
ffffffffc0203db6:	8082                	ret
ffffffffc0203db8:	8082                	ret

ffffffffc0203dba <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203dba:	ca01                	beqz	a2,ffffffffc0203dca <memset+0x10>
ffffffffc0203dbc:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203dbe:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203dc0:	0785                	addi	a5,a5,1
ffffffffc0203dc2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203dc6:	fec79de3          	bne	a5,a2,ffffffffc0203dc0 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203dca:	8082                	ret

ffffffffc0203dcc <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203dcc:	ca19                	beqz	a2,ffffffffc0203de2 <memcpy+0x16>
ffffffffc0203dce:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203dd0:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203dd2:	0585                	addi	a1,a1,1
ffffffffc0203dd4:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203dd8:	0785                	addi	a5,a5,1
ffffffffc0203dda:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203dde:	fec59ae3          	bne	a1,a2,ffffffffc0203dd2 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203de2:	8082                	ret

ffffffffc0203de4 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203de4:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203de8:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203dea:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203dee:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203df0:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203df4:	f022                	sd	s0,32(sp)
ffffffffc0203df6:	ec26                	sd	s1,24(sp)
ffffffffc0203df8:	e84a                	sd	s2,16(sp)
ffffffffc0203dfa:	f406                	sd	ra,40(sp)
ffffffffc0203dfc:	e44e                	sd	s3,8(sp)
ffffffffc0203dfe:	84aa                	mv	s1,a0
ffffffffc0203e00:	892e                	mv	s2,a1
ffffffffc0203e02:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203e06:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203e08:	03067e63          	bleu	a6,a2,ffffffffc0203e44 <printnum+0x60>
ffffffffc0203e0c:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203e0e:	00805763          	blez	s0,ffffffffc0203e1c <printnum+0x38>
ffffffffc0203e12:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203e14:	85ca                	mv	a1,s2
ffffffffc0203e16:	854e                	mv	a0,s3
ffffffffc0203e18:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203e1a:	fc65                	bnez	s0,ffffffffc0203e12 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e1c:	1a02                	slli	s4,s4,0x20
ffffffffc0203e1e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203e22:	00002797          	auipc	a5,0x2
ffffffffc0203e26:	1a678793          	addi	a5,a5,422 # ffffffffc0205fc8 <error_string+0x38>
ffffffffc0203e2a:	9a3e                	add	s4,s4,a5
}
ffffffffc0203e2c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e2e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203e32:	70a2                	ld	ra,40(sp)
ffffffffc0203e34:	69a2                	ld	s3,8(sp)
ffffffffc0203e36:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e38:	85ca                	mv	a1,s2
ffffffffc0203e3a:	8326                	mv	t1,s1
}
ffffffffc0203e3c:	6942                	ld	s2,16(sp)
ffffffffc0203e3e:	64e2                	ld	s1,24(sp)
ffffffffc0203e40:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e42:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203e44:	03065633          	divu	a2,a2,a6
ffffffffc0203e48:	8722                	mv	a4,s0
ffffffffc0203e4a:	f9bff0ef          	jal	ra,ffffffffc0203de4 <printnum>
ffffffffc0203e4e:	b7f9                	j	ffffffffc0203e1c <printnum+0x38>

ffffffffc0203e50 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203e50:	7119                	addi	sp,sp,-128
ffffffffc0203e52:	f4a6                	sd	s1,104(sp)
ffffffffc0203e54:	f0ca                	sd	s2,96(sp)
ffffffffc0203e56:	e8d2                	sd	s4,80(sp)
ffffffffc0203e58:	e4d6                	sd	s5,72(sp)
ffffffffc0203e5a:	e0da                	sd	s6,64(sp)
ffffffffc0203e5c:	fc5e                	sd	s7,56(sp)
ffffffffc0203e5e:	f862                	sd	s8,48(sp)
ffffffffc0203e60:	f06a                	sd	s10,32(sp)
ffffffffc0203e62:	fc86                	sd	ra,120(sp)
ffffffffc0203e64:	f8a2                	sd	s0,112(sp)
ffffffffc0203e66:	ecce                	sd	s3,88(sp)
ffffffffc0203e68:	f466                	sd	s9,40(sp)
ffffffffc0203e6a:	ec6e                	sd	s11,24(sp)
ffffffffc0203e6c:	892a                	mv	s2,a0
ffffffffc0203e6e:	84ae                	mv	s1,a1
ffffffffc0203e70:	8d32                	mv	s10,a2
ffffffffc0203e72:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203e74:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e76:	00002a17          	auipc	s4,0x2
ffffffffc0203e7a:	fc2a0a13          	addi	s4,s4,-62 # ffffffffc0205e38 <default_pmm_manager+0x6a0>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203e7e:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203e82:	00002c17          	auipc	s8,0x2
ffffffffc0203e86:	10ec0c13          	addi	s8,s8,270 # ffffffffc0205f90 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e8a:	000d4503          	lbu	a0,0(s10)
ffffffffc0203e8e:	02500793          	li	a5,37
ffffffffc0203e92:	001d0413          	addi	s0,s10,1
ffffffffc0203e96:	00f50e63          	beq	a0,a5,ffffffffc0203eb2 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203e9a:	c521                	beqz	a0,ffffffffc0203ee2 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e9c:	02500993          	li	s3,37
ffffffffc0203ea0:	a011                	j	ffffffffc0203ea4 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203ea2:	c121                	beqz	a0,ffffffffc0203ee2 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203ea4:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203ea6:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203ea8:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203eaa:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203eae:	ff351ae3          	bne	a0,s3,ffffffffc0203ea2 <vprintfmt+0x52>
ffffffffc0203eb2:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203eb6:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203eba:	4981                	li	s3,0
ffffffffc0203ebc:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203ebe:	5cfd                	li	s9,-1
ffffffffc0203ec0:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ec2:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203ec6:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ec8:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203ecc:	0ff6f693          	andi	a3,a3,255
ffffffffc0203ed0:	00140d13          	addi	s10,s0,1
ffffffffc0203ed4:	20d5e563          	bltu	a1,a3,ffffffffc02040de <vprintfmt+0x28e>
ffffffffc0203ed8:	068a                	slli	a3,a3,0x2
ffffffffc0203eda:	96d2                	add	a3,a3,s4
ffffffffc0203edc:	4294                	lw	a3,0(a3)
ffffffffc0203ede:	96d2                	add	a3,a3,s4
ffffffffc0203ee0:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203ee2:	70e6                	ld	ra,120(sp)
ffffffffc0203ee4:	7446                	ld	s0,112(sp)
ffffffffc0203ee6:	74a6                	ld	s1,104(sp)
ffffffffc0203ee8:	7906                	ld	s2,96(sp)
ffffffffc0203eea:	69e6                	ld	s3,88(sp)
ffffffffc0203eec:	6a46                	ld	s4,80(sp)
ffffffffc0203eee:	6aa6                	ld	s5,72(sp)
ffffffffc0203ef0:	6b06                	ld	s6,64(sp)
ffffffffc0203ef2:	7be2                	ld	s7,56(sp)
ffffffffc0203ef4:	7c42                	ld	s8,48(sp)
ffffffffc0203ef6:	7ca2                	ld	s9,40(sp)
ffffffffc0203ef8:	7d02                	ld	s10,32(sp)
ffffffffc0203efa:	6de2                	ld	s11,24(sp)
ffffffffc0203efc:	6109                	addi	sp,sp,128
ffffffffc0203efe:	8082                	ret
    if (lflag >= 2) {
ffffffffc0203f00:	4705                	li	a4,1
ffffffffc0203f02:	008a8593          	addi	a1,s5,8
ffffffffc0203f06:	01074463          	blt	a4,a6,ffffffffc0203f0e <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0203f0a:	26080363          	beqz	a6,ffffffffc0204170 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0203f0e:	000ab603          	ld	a2,0(s5)
ffffffffc0203f12:	46c1                	li	a3,16
ffffffffc0203f14:	8aae                	mv	s5,a1
ffffffffc0203f16:	a06d                	j	ffffffffc0203fc0 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0203f18:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203f1c:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f1e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203f20:	b765                	j	ffffffffc0203ec8 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0203f22:	000aa503          	lw	a0,0(s5)
ffffffffc0203f26:	85a6                	mv	a1,s1
ffffffffc0203f28:	0aa1                	addi	s5,s5,8
ffffffffc0203f2a:	9902                	jalr	s2
            break;
ffffffffc0203f2c:	bfb9                	j	ffffffffc0203e8a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203f2e:	4705                	li	a4,1
ffffffffc0203f30:	008a8993          	addi	s3,s5,8
ffffffffc0203f34:	01074463          	blt	a4,a6,ffffffffc0203f3c <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0203f38:	22080463          	beqz	a6,ffffffffc0204160 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0203f3c:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203f40:	24044463          	bltz	s0,ffffffffc0204188 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0203f44:	8622                	mv	a2,s0
ffffffffc0203f46:	8ace                	mv	s5,s3
ffffffffc0203f48:	46a9                	li	a3,10
ffffffffc0203f4a:	a89d                	j	ffffffffc0203fc0 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0203f4c:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f50:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203f52:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203f54:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203f58:	8fb5                	xor	a5,a5,a3
ffffffffc0203f5a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f5e:	1ad74363          	blt	a4,a3,ffffffffc0204104 <vprintfmt+0x2b4>
ffffffffc0203f62:	00369793          	slli	a5,a3,0x3
ffffffffc0203f66:	97e2                	add	a5,a5,s8
ffffffffc0203f68:	639c                	ld	a5,0(a5)
ffffffffc0203f6a:	18078d63          	beqz	a5,ffffffffc0204104 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203f6e:	86be                	mv	a3,a5
ffffffffc0203f70:	00002617          	auipc	a2,0x2
ffffffffc0203f74:	10860613          	addi	a2,a2,264 # ffffffffc0206078 <error_string+0xe8>
ffffffffc0203f78:	85a6                	mv	a1,s1
ffffffffc0203f7a:	854a                	mv	a0,s2
ffffffffc0203f7c:	240000ef          	jal	ra,ffffffffc02041bc <printfmt>
ffffffffc0203f80:	b729                	j	ffffffffc0203e8a <vprintfmt+0x3a>
            lflag ++;
ffffffffc0203f82:	00144603          	lbu	a2,1(s0)
ffffffffc0203f86:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f88:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203f8a:	bf3d                	j	ffffffffc0203ec8 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0203f8c:	4705                	li	a4,1
ffffffffc0203f8e:	008a8593          	addi	a1,s5,8
ffffffffc0203f92:	01074463          	blt	a4,a6,ffffffffc0203f9a <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0203f96:	1e080263          	beqz	a6,ffffffffc020417a <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0203f9a:	000ab603          	ld	a2,0(s5)
ffffffffc0203f9e:	46a1                	li	a3,8
ffffffffc0203fa0:	8aae                	mv	s5,a1
ffffffffc0203fa2:	a839                	j	ffffffffc0203fc0 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0203fa4:	03000513          	li	a0,48
ffffffffc0203fa8:	85a6                	mv	a1,s1
ffffffffc0203faa:	e03e                	sd	a5,0(sp)
ffffffffc0203fac:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203fae:	85a6                	mv	a1,s1
ffffffffc0203fb0:	07800513          	li	a0,120
ffffffffc0203fb4:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203fb6:	0aa1                	addi	s5,s5,8
ffffffffc0203fb8:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0203fbc:	6782                	ld	a5,0(sp)
ffffffffc0203fbe:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203fc0:	876e                	mv	a4,s11
ffffffffc0203fc2:	85a6                	mv	a1,s1
ffffffffc0203fc4:	854a                	mv	a0,s2
ffffffffc0203fc6:	e1fff0ef          	jal	ra,ffffffffc0203de4 <printnum>
            break;
ffffffffc0203fca:	b5c1                	j	ffffffffc0203e8a <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203fcc:	000ab603          	ld	a2,0(s5)
ffffffffc0203fd0:	0aa1                	addi	s5,s5,8
ffffffffc0203fd2:	1c060663          	beqz	a2,ffffffffc020419e <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0203fd6:	00160413          	addi	s0,a2,1
ffffffffc0203fda:	17b05c63          	blez	s11,ffffffffc0204152 <vprintfmt+0x302>
ffffffffc0203fde:	02d00593          	li	a1,45
ffffffffc0203fe2:	14b79263          	bne	a5,a1,ffffffffc0204126 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203fe6:	00064783          	lbu	a5,0(a2)
ffffffffc0203fea:	0007851b          	sext.w	a0,a5
ffffffffc0203fee:	c905                	beqz	a0,ffffffffc020401e <vprintfmt+0x1ce>
ffffffffc0203ff0:	000cc563          	bltz	s9,ffffffffc0203ffa <vprintfmt+0x1aa>
ffffffffc0203ff4:	3cfd                	addiw	s9,s9,-1
ffffffffc0203ff6:	036c8263          	beq	s9,s6,ffffffffc020401a <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0203ffa:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203ffc:	18098463          	beqz	s3,ffffffffc0204184 <vprintfmt+0x334>
ffffffffc0204000:	3781                	addiw	a5,a5,-32
ffffffffc0204002:	18fbf163          	bleu	a5,s7,ffffffffc0204184 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0204006:	03f00513          	li	a0,63
ffffffffc020400a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020400c:	0405                	addi	s0,s0,1
ffffffffc020400e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204012:	3dfd                	addiw	s11,s11,-1
ffffffffc0204014:	0007851b          	sext.w	a0,a5
ffffffffc0204018:	fd61                	bnez	a0,ffffffffc0203ff0 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc020401a:	e7b058e3          	blez	s11,ffffffffc0203e8a <vprintfmt+0x3a>
ffffffffc020401e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204020:	85a6                	mv	a1,s1
ffffffffc0204022:	02000513          	li	a0,32
ffffffffc0204026:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204028:	e60d81e3          	beqz	s11,ffffffffc0203e8a <vprintfmt+0x3a>
ffffffffc020402c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020402e:	85a6                	mv	a1,s1
ffffffffc0204030:	02000513          	li	a0,32
ffffffffc0204034:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204036:	fe0d94e3          	bnez	s11,ffffffffc020401e <vprintfmt+0x1ce>
ffffffffc020403a:	bd81                	j	ffffffffc0203e8a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020403c:	4705                	li	a4,1
ffffffffc020403e:	008a8593          	addi	a1,s5,8
ffffffffc0204042:	01074463          	blt	a4,a6,ffffffffc020404a <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0204046:	12080063          	beqz	a6,ffffffffc0204166 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc020404a:	000ab603          	ld	a2,0(s5)
ffffffffc020404e:	46a9                	li	a3,10
ffffffffc0204050:	8aae                	mv	s5,a1
ffffffffc0204052:	b7bd                	j	ffffffffc0203fc0 <vprintfmt+0x170>
ffffffffc0204054:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0204058:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020405c:	846a                	mv	s0,s10
ffffffffc020405e:	b5ad                	j	ffffffffc0203ec8 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0204060:	85a6                	mv	a1,s1
ffffffffc0204062:	02500513          	li	a0,37
ffffffffc0204066:	9902                	jalr	s2
            break;
ffffffffc0204068:	b50d                	j	ffffffffc0203e8a <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc020406a:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020406e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204072:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204074:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204076:	e40dd9e3          	bgez	s11,ffffffffc0203ec8 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc020407a:	8de6                	mv	s11,s9
ffffffffc020407c:	5cfd                	li	s9,-1
ffffffffc020407e:	b5a9                	j	ffffffffc0203ec8 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204080:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0204084:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204088:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020408a:	bd3d                	j	ffffffffc0203ec8 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc020408c:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204090:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204094:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204096:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020409a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020409e:	fcd56ce3          	bltu	a0,a3,ffffffffc0204076 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02040a2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02040a4:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02040a8:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02040ac:	0196873b          	addw	a4,a3,s9
ffffffffc02040b0:	0017171b          	slliw	a4,a4,0x1
ffffffffc02040b4:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02040b8:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02040bc:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02040c0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02040c4:	fcd57fe3          	bleu	a3,a0,ffffffffc02040a2 <vprintfmt+0x252>
ffffffffc02040c8:	b77d                	j	ffffffffc0204076 <vprintfmt+0x226>
            if (width < 0)
ffffffffc02040ca:	fffdc693          	not	a3,s11
ffffffffc02040ce:	96fd                	srai	a3,a3,0x3f
ffffffffc02040d0:	00ddfdb3          	and	s11,s11,a3
ffffffffc02040d4:	00144603          	lbu	a2,1(s0)
ffffffffc02040d8:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040da:	846a                	mv	s0,s10
ffffffffc02040dc:	b3f5                	j	ffffffffc0203ec8 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02040de:	85a6                	mv	a1,s1
ffffffffc02040e0:	02500513          	li	a0,37
ffffffffc02040e4:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02040e6:	fff44703          	lbu	a4,-1(s0)
ffffffffc02040ea:	02500793          	li	a5,37
ffffffffc02040ee:	8d22                	mv	s10,s0
ffffffffc02040f0:	d8f70de3          	beq	a4,a5,ffffffffc0203e8a <vprintfmt+0x3a>
ffffffffc02040f4:	02500713          	li	a4,37
ffffffffc02040f8:	1d7d                	addi	s10,s10,-1
ffffffffc02040fa:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02040fe:	fee79de3          	bne	a5,a4,ffffffffc02040f8 <vprintfmt+0x2a8>
ffffffffc0204102:	b361                	j	ffffffffc0203e8a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204104:	00002617          	auipc	a2,0x2
ffffffffc0204108:	f6460613          	addi	a2,a2,-156 # ffffffffc0206068 <error_string+0xd8>
ffffffffc020410c:	85a6                	mv	a1,s1
ffffffffc020410e:	854a                	mv	a0,s2
ffffffffc0204110:	0ac000ef          	jal	ra,ffffffffc02041bc <printfmt>
ffffffffc0204114:	bb9d                	j	ffffffffc0203e8a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204116:	00002617          	auipc	a2,0x2
ffffffffc020411a:	f4a60613          	addi	a2,a2,-182 # ffffffffc0206060 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020411e:	00002417          	auipc	s0,0x2
ffffffffc0204122:	f4340413          	addi	s0,s0,-189 # ffffffffc0206061 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204126:	8532                	mv	a0,a2
ffffffffc0204128:	85e6                	mv	a1,s9
ffffffffc020412a:	e032                	sd	a2,0(sp)
ffffffffc020412c:	e43e                	sd	a5,8(sp)
ffffffffc020412e:	c0dff0ef          	jal	ra,ffffffffc0203d3a <strnlen>
ffffffffc0204132:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204136:	6602                	ld	a2,0(sp)
ffffffffc0204138:	01b05d63          	blez	s11,ffffffffc0204152 <vprintfmt+0x302>
ffffffffc020413c:	67a2                	ld	a5,8(sp)
ffffffffc020413e:	2781                	sext.w	a5,a5
ffffffffc0204140:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0204142:	6522                	ld	a0,8(sp)
ffffffffc0204144:	85a6                	mv	a1,s1
ffffffffc0204146:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204148:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020414a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020414c:	6602                	ld	a2,0(sp)
ffffffffc020414e:	fe0d9ae3          	bnez	s11,ffffffffc0204142 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204152:	00064783          	lbu	a5,0(a2)
ffffffffc0204156:	0007851b          	sext.w	a0,a5
ffffffffc020415a:	e8051be3          	bnez	a0,ffffffffc0203ff0 <vprintfmt+0x1a0>
ffffffffc020415e:	b335                	j	ffffffffc0203e8a <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0204160:	000aa403          	lw	s0,0(s5)
ffffffffc0204164:	bbf1                	j	ffffffffc0203f40 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0204166:	000ae603          	lwu	a2,0(s5)
ffffffffc020416a:	46a9                	li	a3,10
ffffffffc020416c:	8aae                	mv	s5,a1
ffffffffc020416e:	bd89                	j	ffffffffc0203fc0 <vprintfmt+0x170>
ffffffffc0204170:	000ae603          	lwu	a2,0(s5)
ffffffffc0204174:	46c1                	li	a3,16
ffffffffc0204176:	8aae                	mv	s5,a1
ffffffffc0204178:	b5a1                	j	ffffffffc0203fc0 <vprintfmt+0x170>
ffffffffc020417a:	000ae603          	lwu	a2,0(s5)
ffffffffc020417e:	46a1                	li	a3,8
ffffffffc0204180:	8aae                	mv	s5,a1
ffffffffc0204182:	bd3d                	j	ffffffffc0203fc0 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0204184:	9902                	jalr	s2
ffffffffc0204186:	b559                	j	ffffffffc020400c <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0204188:	85a6                	mv	a1,s1
ffffffffc020418a:	02d00513          	li	a0,45
ffffffffc020418e:	e03e                	sd	a5,0(sp)
ffffffffc0204190:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204192:	8ace                	mv	s5,s3
ffffffffc0204194:	40800633          	neg	a2,s0
ffffffffc0204198:	46a9                	li	a3,10
ffffffffc020419a:	6782                	ld	a5,0(sp)
ffffffffc020419c:	b515                	j	ffffffffc0203fc0 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc020419e:	01b05663          	blez	s11,ffffffffc02041aa <vprintfmt+0x35a>
ffffffffc02041a2:	02d00693          	li	a3,45
ffffffffc02041a6:	f6d798e3          	bne	a5,a3,ffffffffc0204116 <vprintfmt+0x2c6>
ffffffffc02041aa:	00002417          	auipc	s0,0x2
ffffffffc02041ae:	eb740413          	addi	s0,s0,-329 # ffffffffc0206061 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041b2:	02800513          	li	a0,40
ffffffffc02041b6:	02800793          	li	a5,40
ffffffffc02041ba:	bd1d                	j	ffffffffc0203ff0 <vprintfmt+0x1a0>

ffffffffc02041bc <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041bc:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02041be:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041c2:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02041c4:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041c6:	ec06                	sd	ra,24(sp)
ffffffffc02041c8:	f83a                	sd	a4,48(sp)
ffffffffc02041ca:	fc3e                	sd	a5,56(sp)
ffffffffc02041cc:	e0c2                	sd	a6,64(sp)
ffffffffc02041ce:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02041d0:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02041d2:	c7fff0ef          	jal	ra,ffffffffc0203e50 <vprintfmt>
}
ffffffffc02041d6:	60e2                	ld	ra,24(sp)
ffffffffc02041d8:	6161                	addi	sp,sp,80
ffffffffc02041da:	8082                	ret

ffffffffc02041dc <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02041dc:	715d                	addi	sp,sp,-80
ffffffffc02041de:	e486                	sd	ra,72(sp)
ffffffffc02041e0:	e0a2                	sd	s0,64(sp)
ffffffffc02041e2:	fc26                	sd	s1,56(sp)
ffffffffc02041e4:	f84a                	sd	s2,48(sp)
ffffffffc02041e6:	f44e                	sd	s3,40(sp)
ffffffffc02041e8:	f052                	sd	s4,32(sp)
ffffffffc02041ea:	ec56                	sd	s5,24(sp)
ffffffffc02041ec:	e85a                	sd	s6,16(sp)
ffffffffc02041ee:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02041f0:	c901                	beqz	a0,ffffffffc0204200 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02041f2:	85aa                	mv	a1,a0
ffffffffc02041f4:	00002517          	auipc	a0,0x2
ffffffffc02041f8:	e8450513          	addi	a0,a0,-380 # ffffffffc0206078 <error_string+0xe8>
ffffffffc02041fc:	ec3fb0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc0204200:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204202:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0204204:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0204206:	4aa9                	li	s5,10
ffffffffc0204208:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020420a:	0000db97          	auipc	s7,0xd
ffffffffc020420e:	e36b8b93          	addi	s7,s7,-458 # ffffffffc0211040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204212:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0204216:	ee1fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc020421a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020421c:	00054b63          	bltz	a0,ffffffffc0204232 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204220:	00a95b63          	ble	a0,s2,ffffffffc0204236 <readline+0x5a>
ffffffffc0204224:	029a5463          	ble	s1,s4,ffffffffc020424c <readline+0x70>
        c = getchar();
ffffffffc0204228:	ecffb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc020422c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020422e:	fe0559e3          	bgez	a0,ffffffffc0204220 <readline+0x44>
            return NULL;
ffffffffc0204232:	4501                	li	a0,0
ffffffffc0204234:	a099                	j	ffffffffc020427a <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0204236:	03341463          	bne	s0,s3,ffffffffc020425e <readline+0x82>
ffffffffc020423a:	e8b9                	bnez	s1,ffffffffc0204290 <readline+0xb4>
        c = getchar();
ffffffffc020423c:	ebbfb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0204240:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0204242:	fe0548e3          	bltz	a0,ffffffffc0204232 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204246:	fea958e3          	ble	a0,s2,ffffffffc0204236 <readline+0x5a>
ffffffffc020424a:	4481                	li	s1,0
            cputchar(c);
ffffffffc020424c:	8522                	mv	a0,s0
ffffffffc020424e:	ea5fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc0204252:	009b87b3          	add	a5,s7,s1
ffffffffc0204256:	00878023          	sb	s0,0(a5)
ffffffffc020425a:	2485                	addiw	s1,s1,1
ffffffffc020425c:	bf6d                	j	ffffffffc0204216 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020425e:	01540463          	beq	s0,s5,ffffffffc0204266 <readline+0x8a>
ffffffffc0204262:	fb641ae3          	bne	s0,s6,ffffffffc0204216 <readline+0x3a>
            cputchar(c);
ffffffffc0204266:	8522                	mv	a0,s0
ffffffffc0204268:	e8bfb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc020426c:	0000d517          	auipc	a0,0xd
ffffffffc0204270:	dd450513          	addi	a0,a0,-556 # ffffffffc0211040 <buf>
ffffffffc0204274:	94aa                	add	s1,s1,a0
ffffffffc0204276:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020427a:	60a6                	ld	ra,72(sp)
ffffffffc020427c:	6406                	ld	s0,64(sp)
ffffffffc020427e:	74e2                	ld	s1,56(sp)
ffffffffc0204280:	7942                	ld	s2,48(sp)
ffffffffc0204282:	79a2                	ld	s3,40(sp)
ffffffffc0204284:	7a02                	ld	s4,32(sp)
ffffffffc0204286:	6ae2                	ld	s5,24(sp)
ffffffffc0204288:	6b42                	ld	s6,16(sp)
ffffffffc020428a:	6ba2                	ld	s7,8(sp)
ffffffffc020428c:	6161                	addi	sp,sp,80
ffffffffc020428e:	8082                	ret
            cputchar(c);
ffffffffc0204290:	4521                	li	a0,8
ffffffffc0204292:	e61fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc0204296:	34fd                	addiw	s1,s1,-1
ffffffffc0204298:	bfbd                	j	ffffffffc0204216 <readline+0x3a>
