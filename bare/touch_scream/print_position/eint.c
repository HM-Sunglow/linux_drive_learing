#include "eint.h"
#include "irq.h"
#include"s3c2440_soc.h"

//中断源配置
void key_init(void)
{
	//配置GPF0(EINT0) 、GPF2(EINT2)
	GPFCON &= ~(3<<(2*0) | 3<<(2*2));
	GPFCON |= (2<<(2*0) | 2<<(2*2));

	//配置GPG3(EINT11) 、GPG11(EINT19)
	GPGCON &= ~(3<<(2*3) | 3<<(2*11));
	GPGCON |= (2<<(2*3) | 2<<(2*11));

	//配置EXTINTn,设置双边沿触发
	EXTINT0 |= 7<<0 | 7<<8;
	EXTINT1 |= 7<<12;
	EXTINT2 |= 7<<12;

	//使能中断
	EINTMASK &= ~(1<<11 | 1<<19);

	//EINTPEND分辨4-23哪个中断发生，要软件清零	
}

//中断控制器配置
void EINT_init(void)
{
	//SRCPND显示哪些中断源发出中断请求或等待中断服务，写1清零
	
	//INTMSK使能中断
	
	//INTPND显示正在执行的中断服务，写1清零
	
	//INTOFFSET显示INTPND中哪位置1，清INTPND和SRCPND后自动清零

	//注册中断
	irq_register(0,EINT0_func);
	irq_register(2,EINT2_func);
	irq_register(5,EINT4_23_func);
}

void EINT0_func(int bit)
{
//外部中断0
	//判断按键是否按下
	if(!(GPFDAT & 1<<0))
	{
		//开灯
		GPFDAT &= ~(1<<4);
	}
	else
	{
		//关灯
		GPFDAT |= (1<<4);
	}
}

void EINT2_func(int bit)
{	
	if(!(GPFDAT & 1<<2))
	{
		GPFDAT &= ~(1<<5);
	}
	else
	{
		GPFDAT |= (1<<5);
	}
}

void EINT4_23_func(int bit)
{
	//外部中断4-23
	//外部中断11
	if(EINTPEND & 1<<11)
	{
		if(!(GPGDAT & 1<<3))
		{
			GPFDAT &= ~(1<<6);
		}
		else
		{
			GPFDAT |=  (1<<6);
		}
		//清零
		EINTPEND |= 1<<11;
	}
	//外部中断19
	else if(EINTPEND & 1<<19)
	{
		if(!(GPGDAT & 1<<11))
		{
			GPFDAT &= ~((1<<4) | (1<<5) | (1<<6));
		}
		else
		{
			GPFDAT |= (1<<4) | (1<<5) | (1<<6);
		}
		//清零
		EINTPEND |= 1<<19;
	}

}

