
.text 
.global _start

_start:
	//�ж�����
	b    resert			/*��λ			0    */
	ldr  pc, und_addr	/*δ�����쳣	0x4  */
	ldr  pc, swi_addr	/*swi�쳣		0x8  */
	bl halt				/*abt(prefetch)	0xc	 */
	bl halt				/*abt(data)		0x10 */
	bl halt				/*reserved     	0x14 */
	ldr  pc, irq_addr 	/*IRQ			0x18 */
	bl halt 			/*FIQ			0x1c */

swi_addr:
	.word swi_handle

und_addr:
	.word und_handle

irq_addr:
	.word irq_handle

und_handle:
	//����und_sp
	ldr sp, =0x34000000 
	//�����ֳ�
	stmdb sp!, {r0-r12, lr}
	//�쳣����
	mrs r0, cpsr
	ldr r1, =und_string
	bl und_deal
	//�ָ�
	ldmia sp!, {r0-r12, pc}^

swi_handle:
	ldr sp, =0x33f00000
	stmdb sp!, {r0-r12, lr}
	//��swiָ��ĵ�ַ����swi_deal,r4-r12��c�������غ��ָ�
	mov r0, lr
	sub r0, r0, #4
	bl swi_deal
	bl print1
	ldmia sp!, {r0-r12, pc}^
	
	
und_string:
	.string "undefined exception occur\r\n"

.align 4

irq_handle:
	ldr sp, =0x33d00000
	sub lr, lr, #4
	stmdb sp!, {r0-r12, lr}
	bl IRQ
	ldmia sp!, {r0-r12, pc}^

resert:
	//�رտ��Ź�
	ldr r0, =0x53000000
	mov r1, #0
	str r1, [r0]

	//ʱ������FCLK:400M HCLK:100M PCLK:50M
	//����HDIV��PDIV
	ldr r0, =0x4C000014
	mov r1, #0x5
	str r1, [r0]
	
	//����Ϊ�첽ģʽ
	mrc p15,0,r0,c1,c0,0 
 	orr r0,r0,#0xc0000000   //R1_nF:OR:R1_iA
 	mcr p15,0,r0,c1,c0,0

	//����MPLL,ʹFCLKΪ400M
	ldr r0, =0x4C000004
	ldr r1, =((92<<12) | (1<<4) | (1<<0))
	str r1, [r0]

	//����ջ sp �Զ�ʶ��nor|nand����
	//nor flash �Ķ�д��Ҫһ����ʽ������ֱ�Ӷ�д���ɴ��ж�����ģʽ
	mov r1, #0 //r1=0
	ldr r0, [r1]//[0]->r0
	str r1, [r1]//r1->[0]
	ldr r2, [r1]//[0]->r2
	cmp r1, r2//�Ƚ�r1,r2
	ldr sp, =0x40000000+4096//nor����
	moveq sp, #4096//���r1=r2��nand����
	streq r0, [r1]//��ԭ0��ַ����

	//��ʼ��SDRAM
	bl sdram_init

	//�����ض�λ
	mov r0, #0
	ldr r1, =_start
	ldr r2, =bass_start

copy:
	ldr  r3, [r0]
	str  r3, [r1]
	add  r0, r0, #4
	add  r1, r1, #4
	cmp	 r1, r2
	ble  copy

	ldr r1, =bass_end
	mov r0, #0

	//���bass������
clean:
	str r0, [r2]
	add r2, r2, #4
	cmp r2, r1
	ble clean	

	//����userģʽ
	mrs r0, cpsr
	bic r0, r0, #0xf//������λ����
	bic r0, r0, #1<<7//�������ж�
	msr cpsr, r0

	//����user_sp
	ldr sp, =0x33e00000

	
	//����SDRAM��ȥִ��
	ldr pc, =uart
uart:
	bl uart0_init

//	bl print1
und_code:
	.word 0xeeadc0de  /* δ����ָ�� */	
//	bl print2

	bl print2
	//����swi�쳣
	swi 0x123	//��������0x8ִ��

	//��ʼ���ж�Դ
	bl key_init
	//��ʼ���жϿ�����
	bl EINT_init

	//�þ��Ե�ַ��תָ�����SDRAM��ȥִ��
	ldr  pc, =main

halt:
	b halt

	
	